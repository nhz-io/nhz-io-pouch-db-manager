# Job

    class Job

      constructor: (config) ->

        throw TypeError 'Missing config' unless config

        { @key, @type, @queue, @live, @retry, @local, @remote } = config

        @reset()

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