# PouchDB Resource

    arm = require '@nhz.io/arm'

    { URL } = require 'url'

    class Resource extends arm.Resource

      constructor: (name, opts) ->

> Database name

        if typeof name is 'object'

          opts = name
          name = opts.name

        opts ?= {}

        throw Error 'Missing resource name' unless name

> Remote resource

        if name.match /^https?:\/\//

          url = new URL name

          super "#{ url.host }#{ url.pathname }"

          @remote = name

> Local resource

        else super name

        @type = opts.type or 'pull'

### Queue Type

Valid types:

* `oneshot`
* `poll`
* `live`

>

        @queue = opts.queue or 'oneshot'

### Docs

> Either `all` or `Array` of **doc ids**

        @docs = opts.docs or 'all'

    module.exports = Resource