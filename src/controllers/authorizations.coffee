jsonGate = require 'json-gate'

Authorization = require '../models/authorization'
Client = require '../models/client'

authController = exports

listSchema = jsonGate.createSchema
    type: 'object'
    properties:
        clientId:
            type: 'string'
            required: true
        clientSecret:
            type: 'string'
            required: true

createSchema = jsonGate.createSchema
    type: 'object'
    properties:
        clientId:
            type: 'string'
            required: true
        clientSecret:
            type: 'string'
            required: true
        scopes:
            type: 'array'
            items:
                type: 'string'
            default: []

updateSchema = jsonGate.createSchema
    type: 'object'
    properties:
        clientId:
            type: 'string'
            required: true
        clientSecret:
            type: 'string'
            required: true
        scopes:
            type: 'array'
            items:
                type: 'string'
        addScopes:
            type: 'array'
            items:
                type: 'string'
        removeScopes:
            type: 'array'
            items:
                type: 'string'

deleteSchema = jsonGate.createSchema
    type: 'object'
    properties:
        clientId:
            type: 'string'
            required: true
        clientSecret:
            type: 'string'
            required: true

# Get the client, making sure it exists and the secrets match up
getClient = (key, secret, done) ->
    Client.findOne {key}, (err, client) ->
        if err then return done(err.toString(), 500)
        if not client then return done('Client not found', 401)
        if client.secret isnt secret then return done('Invalid client secret', 401)

        done(null, client)

authController.create = (req, res) ->
    createSchema.validate req.body, (err, data) ->
        if err then return res.send(400, err.toString())

        getClient data.clientId, data.clientSecret, (err, client) ->
            if err then return res.send(client, err)

            auth = new Authorization
                userId: req.user.id
                clientId: data.clientId
                scopes: data.scopes

            auth.save (err, auth) ->
                if err then return res.send(500, err.toString())

                res.json 201, auth

authController.list = (req, res) ->
    listSchema.validate req.query, (err, data) ->
        if err then return res.send(400, err.toString())

        getClient data.clientId, data.clientSecret, (err, client) ->
            if err then return res.send(client, err)

            params =
                clientId: data.clientId
                userId: req.user.id

            Authorization.find params, (err, auths) ->
                if err then return res.send(500, err.toString())

                res.json auths

authController.update = (req, res) ->
    updateSchema.validate req.body, (err, data) ->
        if err then return res.send(400, err.toString())

        count = [data.scopes, data.addScopes, data.removeScopes].filter((x) -> x).length

        if count is 0
            return res.send(400, 'Must supply at least one of scopes, addScopes or removeScopes')
        else if count > 1
            return res.send(400, 'Only one of scopes, addScopes or removeScopes can be given')

        getClient data.clientId, data.clientSecret, (err, client) ->
            if err then return res.send(client, err)

            update = {}

            if data.scopes then update.$set = {scopes: data.scopes}
            if data.addScopes then update.$addToSet = {scopes: {$each: data.addScopes}}
            if data.removeScopes then update.$pullAll = {scopes: data.removeScopes}

            # Find and update an entry
            Authorization.findByIdAndUpdate req.params.id, update, (err, auth) ->
                if err then return res.send(500, err.toString())

                res.json auth

authController.delete = (req, res) ->
    deleteSchema.validate req.body, (err, data) ->
        if err then return res.send(400, err.toString())

        getClient data.clientId, data.clientSecret, (err, client) ->
            if err then return res.send(client, err.toString())

            Authorization.findByIdAndRemove req.params.id, (err) ->
                if err then return res.send(500, err.toString())

                res.send 204, null