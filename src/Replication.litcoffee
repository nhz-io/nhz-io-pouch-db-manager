# Replication Manager

    Manager = require './Manager'

    class Replication extends Manager

      register: (resource) -> @replicate resource

      replicate: (resource) ->

        { remote, identifier: local, opts } = resource

        new Promise (resolve, reject) =>

          @queue.add () =>

            resource.replication = switch resource.type

              when 'push' then @PouchDB.replicate local, remote, Object.assign {since: 0}, opts

              when 'pull' then @PouchDB.replicate remote, local, Object.assign {since: 0}, opts

              when 'sync' then @PouchDB.sync local, remote, Object.assign {since: 0}, opts

              else Promise.reject TypeError 'Invalid resource type: ' + resource.type

            resource.replication.on 'change', (info) => @emit 'change', info, local, remote, resource.type
            resource.replication.on 'paused', (err) => @emit 'paused', err, local, remote, resource.type
            resource.replication.on 'active', () => @emit 'active', local, remote, resource.type
            resource.replication.on 'denied', (err) => @emit 'denied', err, local, remote, resource.type
            resource.replication.on 'complete', (info) => @emit 'complete', info, local, remote, resource.type
            resource.replication.on 'error', (err) => @emit 'error', err, local, remote, resource.type

            resolve await resource.replication

            resource.replication

    module.exports = Replication
