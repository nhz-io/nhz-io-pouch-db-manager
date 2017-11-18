# PouchDB Manager (Connections control)

[![Travis Build][travis]](https://travis-ci.org/nhz-io/nhz-io-pouch-db-manager)
[![NPM Version][npm]](https://www.npmjs.com/package/@nhz.io/pouch-db-manager)

## Install

```bash
npm i -S @nhz.io/pouch-db-manager
```

## Usage
```js
const PouchDbManager = require('@nhz.io/pouch-db-manager')

...
```

## Literate Source

### Imports

    AbstractResourceManager = require '@nhz.io/abstract-resource-manager'
    Registry = require '@nhz.io/pouch-db-manager-registry'
    DefaultScheduler = require '@nhz.io/pouch-db-job-scheduler'
    sync = require '@nhz.io/pouch-db-sync-job'
    replicate = require '@nhz.io/pouch-db-replication-job'
    { mkconf, assign } = require '@nhz.io/pouch-db-manager-helpers'

### Job

    class Job

      constructor: (config) ->

        throw TypeError 'Missing config' unless config

        { @key, @type, @queue, @live, @retry, @local, @remote } = config

        @mkdefer()

      reset: ->

        @stop()

        done = new Promise (args) => { @resolve, @reject } = args

        @then = done.then.bind done
        @catch = done.catch.bind done

      start: (PouchDB, opts) ->

        opts = assign { @live, @retry }, opts

        run = switch @type

          when 'push' then replicate opts, @local, @remote

          when 'pull' then replicate opts, @remote, @local

          when 'sync' then sync opts, @local, @remote

        @instance = run { PouchDB }

        @instance.then @resolve
        @instance.catch @reject

        @instance

      stop: (args...) -> @instance?.stop args...

### Scheduler

    class Scheduler extends DefaultScheduler

      constructor: (args...) ->

        super args

        jobs = {}

      prepare: (job, opts) -> () =>

        instance = job.start @PouchDB, { live: false, retry: false }, opts

        @jobs[job.key] = job

        instance.then () => @cleanup job
        instance.catch (err) => @cleanup job, err

        instance

      cleanup: (job, err) ->

        delete @jobs[job.key]

        job.stop(err)

        null

### Manager

    class PouchDBManager extends AbstractResourceManager

      @Job = Job
      @Scheduler = Scheduler
      @Registry = Registry
      @Resource = Registry.Resource

      constructor: (@schedulers) ->

        super()

        throw TypeError 'Missing schedulers' unless @schedulers

        @registry = new Registry {

          types: ['push', 'pull', 'sync']

          queues: ['push', 'pull', 'sync', 'live', 'realtime']

        }

      register: (resource) -> @registry.register resource

      unregister: (resource) -> @registry.unregister resource

      findJob: (resource) ->

        queues = Object.keys @schedulers

        return job for queue in queues when job = @schedulers[queue]?.jobs[key]

      getJob: (resource) ->

        key = resource.key or resource

        return job if job = @findJob resource

        new Job @PouchDB, mkconf resource

      shouldStart: (job, resource) ->

        return true unless current = @findJob resource

        return false if job is current

        return true if (priority job.queue) > (priority current.queue)

        return true if (priority job.type) > (priority current.type)

      shouldStop: (job, resource) ->

        resources = @resources.find { local: job.local, remote: job.remote }

        return false unless current = @findJob resource

        return false unless job is current

        return true unless resources?.length

        return true if resources.length is 1 and resources[0] is resource

        return true if (priority resource.queue) > (priority job.queue)

        return true if (priority resource.type) > (priority job.type)

        return true if resource.type isnt job.type

      needUpgrade: (job, resource) ->

        config = {}

        config.queue = resource.queue if (priority resource.queue) > (priority job.queue)

        config.type = resource.type if (priority resource.type) > (priority job.type)

        config.queue = 'sync' if not config.queue and job.queue isnt resource.queue

        config.type = 'sync' if not config.type and job.type isnt resource.queue

        return config if (Object.keys config).length > 0

      needDowngrade: (job) ->

        [config, queue, type] = [{}, [], []]

        resources = @resources.find { local: job.local, remote: job.remote }

        resources.forEach (resource) ->

          queue.push resource.queue unless resource.queue in queue

          type.push resource.type unless resource.type in type

        queue.push 'sync' if ('push' in queue) and ('pull' in queue)

        type.push 'sync' if ('push' in type) and ('pull' in type)

        highestPriority = (acc, v) -> if (priority acc) > (priority v) then acc else v

        queue = queue.reduce highestPriority, queue[0]

        type = type.reduce highestType, type[0]

        config.queue = queue if (priority job.queue) > queue

        config.type = type if (priority job.type) > type

        return config if (Object.keys config).length > 0

      upgrade: (job, config) -> Object.assign job, config

      downgrade: (job, config) -> Object.assign job, config

      start: (job) ->

        return null unless scheduler = @schedulers[job.queue]

        scheduler.add job

      stop: (job) -> job.stop()

### Exports

    module.exports = PouchDBManager

## Tests

    test = require 'tape-async'

    test 'PouchDBManager constructor', (t) ->

      t.plan 2

      t.throws -> new PouchDBManager
      t.ok new PouchDBManager {}

## Version 0.1.3

## License [MIT](LICENSE)

[travis]: https://img.shields.io/travis/nhz-io/nhz-io-pouch-db-manager.svg?style=flat
[npm]: https://img.shields.io/npm/v/@nhz.io/pouch-db-manager.svg?style=flat
