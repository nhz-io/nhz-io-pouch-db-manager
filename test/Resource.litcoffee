# PouchDB Resource Test

    Resource = require '../src/Resource'

    describe 'PouchResource', ->

      describe '#constructor()', ->

        it 'should use supplied name for local resource', ->

          resource = new Resource 'local'

          expect(resource).to.have.property 'identifier', 'local'
          expect(resource).to.not.have.property 'remote'

        it 'should use supplied name for remote resource', ->

          resource = new Resource 'http://remote/resource'

          expect(resource).to.have.property 'identifier', 'remote/resource'
          expect(resource).to.have.property 'remote', 'http://remote/resource'

        it 'should use name from opts for local resource', ->

          resource = new Resource { name: 'local' }

          expect(resource).to.have.property 'identifier', 'local'
          expect(resource).to.not.have.property 'remote'

        it 'should use name from opts for remote resource', ->

          resource = new Resource { name: 'http://remote/resource' }

          expect(resource).to.have.property 'identifier', 'remote/resource'
          expect(resource).to.have.property 'remote', 'http://remote/resource'

        it 'should use `pull` as default type', ->
          expect(new Resource 'local').to.have.property 'type', 'pull'

        it 'should use `oneshot` as default queue', ->
          expect(new Resource 'local').to.have.property 'queue', 'oneshot'

        it 'should use supplied type', ->
          expect(new Resource 'local', { type: 'test' }).to.have.property 'type', 'test'

        it 'should use supplied queue', ->
          expect(new Resource 'local', { queue: 'test' }).to.have.property 'queue', 'test'

        it 'should use `all` as default docs', ->
          expect(new Resource 'local').to.have.property 'docs', 'all'