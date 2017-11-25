# Manager

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

        key = resource.key or resource

        queues = Object.keys @schedulers

        return job for queue in queues when job = @schedulers[queue]?.jobs[key]

      getJob: (resource) ->

        return job if job = @findJob resource

        new Job mkconf resource

      shouldStart: (job, resource) ->

        return true unless current = @findJob resource

        return false if job is current

        return true if (priority job.queue) > (priority current.queue)

        return true if (priority job.type) > (priority current.type)

      shouldStop: (job, resource) ->

        resources = @registry.find { local: job.local, remote: job.remote }

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