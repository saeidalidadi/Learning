###
#
# model.coffee
#
###

odme = require('odme')
_       = require "lodash"

module.exports = (options) ->
  class Post extends odme.CB
    search: (query, cb) ->
      cb options.searchEng.search(query)
    source: options.db
    props:
      title: on
      body: on
      author_key: on
      no: on
    PREFIX: 'p'

    getPost: (key, cb) ->
      Post.get(key).then (post) ->
        cb(null, post)

    getPosts: (size, from, user_mail, cb) ->
      query =
        index: 'blog'
        type: 'posts'
        body:
          size: size
          from: from
          sort: [{
            no: order: "asc"
          }]
          query:
            match_all: {}
      @search query, (searched) =>
        searched.then (docs) =>
          _this = @
          if docs.hits.total isnt 0
            keys = for doc in docs.hits.hits
              doc._id
            Post.find(keys,'title,body,author_key,doc_key').then (posts) ->
              auth_keys = _.uniq _.map posts, (post) ->
                return post.author_key
              query =
                index: 'blog'
                type: 'users'
                body:
                  query:
                    terms:
                      doc_key: auth_keys
              _this.search query, (searched) ->
                searched.then (users) ->
                  for post in posts
                    for user in users.hits.hits
                      if post.author_key is user._id
                        post.author = user._source.doc.name
                        if user_mail?
                          if user._source.doc.email isnt user_mail
                            delete post.doc_key
                  cb(null, posts)

    getPostsOf: (email, size, from, cb) ->
      _this = @
      @search {
        index: @_index
        type: 'users'
        body:
          query:
            term:
              email: email
      }, (searched) ->
        searched.then (user) ->
          author_key = user.hits.hits[0]._source.doc.doc_key
          _this.search {
            index: 'blog'
            type: 'posts'
            body:
              size: size
              from: from
              sort: [{
                no: order: "asc"
              }]
              query:
                match:
                  author_key: author_key
          }, (searched) ->
            searched.then (posts) ->
              doc_keys = _.map posts.hits.hits, (post) ->
                post._source.doc.doc_key
              Post.get(doc_keys).then (docs) ->
                ps = _.map docs, (p) ->
                  p.doc
                cb(null, ps)

    getRandomPosts: (rands, cb) ->
      @search {
        index: 'blog'
        type: 'posts'
        body:
          query: terms: no: rands
      }, (searched) ->
        searched.then (docs) ->
          posts = _.map docs.hits.hits, (doc) ->
            doc._source.doc
          cb(null, posts)

    setPost: (post, cb) ->
      @search {
        index: 'blog'
        type: 'users'
        body:
          query:
            term:
              email: post.author_email
      }, (searched) =>
        searched.then (doc) =>
          key = doc.hits.hits[0]._id
          @countPosts(null, true, (all, lastPostNo) ->
            post =
              title: post.title
              body: post.body
              author_key: key
              no: ++lastPostNo
            post = new Post post
            post.create(true).then (d) ->
              cb(null, true)
          )
    updatePost: (updated, key, cb) ->
      Post.get(key).then (post) ->
        post.doc.title = updated.title
        post.doc.body = updated.body
        post.update()
        cb null, on

    deletePost: (key, cb) ->
      Post.remove(key).then (d) ->

    countPosts: (email, max, cb) ->
      cb = max if typeof max is 'function'
      if email?
        @search {
          index: 'blog'
          type: 'users'
          body:
            query:
              term: email: email
        }, (searched) =>
          searched.then (result) =>
            author_key = result.hits.hits[0]._source.doc.doc_key
            @search {
              index: 'blog'
              type: 'posts'
              body:
                size: 0
                query:
                  match: author_key: author_key
            }, (searched) ->
              searched.then (doc) ->
                cb doc.hits.total
      else
        if max
          @search {
            index: 'blog'
            type: 'posts'
            body:
              size: 0
              aggs: max_no: max: field: 'no'
          }, (searched) ->
            searched.then (d) ->
              cb d.hits.total, d.aggregations.max_no.value
        else
          @search {
            index: 'blog'
            type: 'posts'
            body:
              size: 0
              query:
                match_all: {}
          }, (searched) ->
            searched.then (d) ->
              cb d.hits.total

