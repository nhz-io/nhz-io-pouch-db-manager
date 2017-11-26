# Manager

    PQueue = require 'p-queue'
    arm = require '@nhz.io/arm'

    class Manager extends arm.Manager

      constructor: (PouchDB, concurrency, registry) ->

        throw TypeError 'Missing PouchDB' unless PouchDB?

        super registry

        concurrency ?= 2

        @PouchDB = PouchDB
        @queue = new PQueue { concurrency }

    module.exports = Manager
