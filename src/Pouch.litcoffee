# Live Changes Manager

    Manager = require './Manager'

    LiveChanges = require './LiveChanges'
    PollChanges = require './PollChanges'
    Replication = require './Replication'
    Resource = require './Resource'

    class Pouch extends Manager

      constructor: (PouchDB, registry) ->
        concurrency = 2

        super PouchDB, concurrency, registry

        @liveChanges = new LiveChanges PouchDB, concurrency, @registry
        @pollChanges = new PollChanges PouchDB, concurrency, @registry
        @replication = new Replication PouchDB, concurrency, @registry

        @liveChanges.on 'change', (args...) => @onChange args...
        @liveChanges.on 'complete', (args...) => @emit 'complete', args...
        @liveChanges.on 'error', (args...) => @emit 'error', args...

        @pollChanges.on 'change', (args...) =>  @onChange args...
        @pollChanges.on 'complete', (args...) => @emit 'complete', args...
        @pollChanges.on 'error', (args...) => @emit 'error', args...

        @replication.on 'change', (args...) => @onChange args...
        @replication.on 'paused', (args...) => @emit 'paused', args...
        @replication.on 'active', (args...) => @emit 'active', args...
        @replication.on 'denied', (args...) => @emit 'denied', args...
        @replication.on 'complete', (args...) => @emit 'complete', args...
        @replication.on 'error', (args...) => @emit 'error', args...


      onChange: (info, local, remote, mod) ->

        return unless _rev = info.changes?[0]?.rev

        try

          doc = await (new PouchDB local).get info.id

          return if doc and doc._rev is _rev

          return if not doc and info.deleted

        @emit 'change', info, local, remote, mod

    module.exports = Pouch

