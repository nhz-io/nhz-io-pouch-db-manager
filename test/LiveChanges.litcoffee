# LiveChanges Tests

    PouchDB = require 'pouchdb-memory'

    Resource = require '../src/Resource'
    LiveChanges = require '../src/LiveChanges'

    describe 'LiveChanges', ->

      it 'should do stuff', ->
        await(new PouchDB 'remote').destroy()
        await(new PouchDB 'local').destroy()

        remote = new PouchDB 'remote'
        local = new PouchDB 'local'

        await remote.put { _id: 'from-remote' }
        await local.put { _id: 'from-local' }

        resource = new Resource 'local', { queue: 'live' }
        resource.remote = 'remote'

        manager = new LiveChanges PouchDB

        manager.on 'change', (args...) -> console.log 'UPDATE', args...
        manager.on 'complete', (args...) -> console.log 'DONE', args...
        manager.on 'error', (args...) -> console.log 'ERROR', args...

        manager.manage resource



      # describe '#manage()', ->

      #   it 'should `pull` replicate from remote', ->

      #     await(new PouchDB 'remote').destroy()
      #     await(new PouchDB 'local').destroy()

      #     remote = new PouchDB 'remote'
      #     local = new PouchDB 'local'

      #     await remote.put { _id: 'from-remote' }
      #     await local.put { _id: 'from-local' }

      #     resource = new Resource 'local'
      #     resource.remote = 'remote'

      #     manager = new LiveChanges PouchDB

      #     manager.manage resource

      #     expect(await resource.replication).to.have.property 'ok', true

      #     { rows } = await local.allDocs({ include_docs: true })

      #     expect(rows.map ({ id }) -> id).to.deep.equal ['from-local', 'from-remote']

      #   it 'should `push` replicate to remote', ->

      #     await(new PouchDB 'remote').destroy()
      #     await(new PouchDB 'local').destroy()

      #     remote = new PouchDB 'remote'
      #     local = new PouchDB 'local'

      #     await remote.put { _id: 'from-remote' }
      #     await local.put { _id: 'from-local' }

      #     resource = new Resource 'local', { type: 'push' }
      #     resource.remote = 'remote'

      #     manager = new LiveChanges PouchDB

      #     manager.manage resource

      #     expect(await resource.replication).to.have.property 'ok', true

      #     { rows } = await remote.allDocs({ include_docs: true })

      #     expect(rows.map ({ id }) -> id).to.deep.equal ['from-local', 'from-remote']

      #   it 'should `sync` replicate remote and local', ->

      #     await(new PouchDB 'remote').destroy()
      #     await(new PouchDB 'local').destroy()

      #     remote = new PouchDB 'remote'
      #     local = new PouchDB 'local'

      #     await remote.put { _id: 'from-remote' }
      #     await local.put { _id: 'from-local' }

      #     resource = new Resource 'local', { type: 'sync' }
      #     resource.remote = 'remote'

      #     manager = new LiveChanges PouchDB

      #     manager.manage resource

      #     res = await resource.replication

      #     expect(res.push).to.have.property 'ok', true
      #     expect(res.pull).to.have.property 'ok', true

      #     { rows } = await remote.allDocs({ include_docs: true })

      #     expect(rows.map ({ id }) -> id).to.deep.equal ['from-local', 'from-remote']

      #     { rows } = await local.allDocs({ include_docs: true })

      #     expect(rows.map ({ id }) -> id).to.deep.equal ['from-local', 'from-remote']