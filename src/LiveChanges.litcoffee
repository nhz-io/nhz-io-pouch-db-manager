# Live Changes Manager

    Manager = require './Manager'

    class LiveChanges extends Manager

      register: (resource) -> @subscribe resource if resource.queue is 'live'

      subscribe: (resource) ->

        { remote, identifier: local, opts } = resource

        other = @registry.resources[local]?.find (r) -> r.changes and r.queue is 'live'

        return resource.changes = other.changes if other

        new Promise (resolve, reject) =>

          @queue.add () =>

            opts = Object.assign { since: 'now' }, opts, { live: true }

            resource.changes = (new @PouchDB remote).changes opts

            resource.changes.on 'change', (info) => @emit 'change', info, local, remote

            resource.changes.on 'complete', (info) => @emit 'complete', info, local, remote

            resource.changes.on 'error', (err) => @emit 'error', err, local, remote

            resolve resource.changes

            resource.changes

    module.exports = LiveChanges
