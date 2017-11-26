# Replication Manager

    Manager = require './Manager'

    class Replication extends Manager

      register: (resource) -> @replicate resource

      replicate: (resource) ->

        { remote, identifier: local, opts } = resource

        new Promise (resolve, reject) =>

          @queue.add () =>

            resource.replication = switch resource.type

              when 'push' then @PouchDB.replicate local, remote, opts

              when 'pull' then @PouchDB.replicate remote, local, opts

              when 'sync' then @PouchDB.sync local, remote, opts

              else Promise.reject TypeError 'Invalid resource type: ' + resource.type

            resource.replication.on 'change', (info) => @emit 'change', info, local, remote
            resource.replication.on 'paused', (err) => @emit 'paused', err, local, remote
            resource.replication.on 'active', () => @emit 'active', local, remote
            resource.replication.on 'denied', (err) => @emit 'denied', err, local, remote
            resource.replication.on 'complete', (info) => @emit 'complete', info, local, remote
            resource.replication.on 'error', (err) => @emit 'error', err, local, remote

            resolve await resource.replication

    module.exports = Replication
