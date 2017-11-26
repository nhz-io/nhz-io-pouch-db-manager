# Index test

    index = require '../src/index'

    Resource = require '../src/Resource'

    describe 'index', ->

      it 'should export Resource', -> expect(index.Resource).to.be.equal Resource

