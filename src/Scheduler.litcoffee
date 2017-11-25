# Scheduler

    class Scheduler extends DefaultScheduler

      constructor: (args...) ->

        super args...

        @jobs = {}

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