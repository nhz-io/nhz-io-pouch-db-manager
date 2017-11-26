# Poll Changes Manager

    Manager = require './Manager'

    class PollChanges extends Manager

      register: (resource) -> @subscribe resource if resource.queue is 'poll'

      subscribe: (resource) ->

        { remote, identifier: local, opts } = resource

        other = @registry.resources[local]?.find (r) -> r.changes and r.queue is 'live'

        return resource.changes = other.changes if other

        new Promise (resolve, reject) =>

          opts = Object.assign { since: 'now', period: 3 }, opts, { live: true }

          enqueue = =>

            if resource.changes

              return resolve resource.changes if resource.changes.isCancelled

              resource._restart = true
              resource.changes.cancel()

            @queue.add () =>

              resource.changes = (new @PouchDB remote).changes opts

              resource.changes.on 'change', (info) => @emit 'change', info, local, remote

              resource.changes.on 'complete', (info) =>
                return @emit 'complete', info, local, remote unless resource._restart

                resource._restart = undefined

              resource.changes.on 'error', (args...) => @emit 'error', err, local, remote

              setTimeout enqueue, opts.period * 1000

              resource.changes

          enqueue()

    module.exports = PollChanges
