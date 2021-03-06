_ = require 'lodash'
async = require 'async'
brauhaus = require 'brauhaus'
jsonGate = require 'json-gate'
queue = require '../queue'
slug = require 'slug'
util = require '../util'

Action = require '../models/action'
Recipe = require '../models/recipe'
RecipeHistory = require '../models/recipeHistory'

require 'brauhaus-diff'

recipeController = exports

# Recipe list request schema
listSchema = jsonGate.createSchema
    type: 'object'
    properties:
        ids:
            type: 'array'
            minItems: 1
            maxItems: 60
            items:
                type: 'string'
        parentIds:
            type: 'array'
            minItems: 1
            maxItems: 60
            items:
                type: 'string'
        userIds:
            type: 'array'
            minItems: 1
            maxItems: 60
            items:
                type: 'string'
        slugs:
            type: 'array'
            minItems: 1
            maxItems: 60
            items:
                type: 'string'
        offset:
            type: 'number'
            default: 0
        limit:
            type: 'number'
            default: 20
            max: 60
        sort:
            type: 'string'
            enum: ['name', '-name', 'created', '-created']
            default: 'name'
        detail:
            type: 'boolean'
            default: false
        populateParent:
            type: 'boolean'
            default: false
        showPrivate:
            type: 'boolean'
            default: false

# Recipe creation request schema
# Takes in any valid Brauhaus.Recipe constructor values
creationSchema = jsonGate.createSchema
    type: 'object'
    properties:
        parent:
            type: 'string'
        private:
            type: 'boolean'
            default: false
        detail:
            type: 'boolean'
            default: false
        recipe:
            type: 'any'
        populateParent:
            type: 'boolean'
            default: false

updateSchema = jsonGate.createSchema
    type: 'object'
    properties:
        id:
            type: 'string'
            required: true
        parent:
            type: 'string'
        private:
            type: 'boolean'
        detail:
            type: 'boolean'
            default: false
        recipe:
            type: 'any'
        populateParent:
            type: 'boolean'
            default: false

deleteSchema = jsonGate.createSchema
    type: 'object'
    properties:
        id:
            type: 'string'
            required: true

# Increment a slug by one, adding '-1' if no number
# is already present.
incrementSlug = (slug) ->
    if isNaN slug.substr(slug.length - 1)
        "#{slug}-1"
    else
        slug.replace /\d+$/, (n) -> ++n

# Serialize a recipe for a JSON response
recipeController.serialize = (recipe, user, detail, populateParent, done) ->
    r = new brauhaus.Recipe(recipe.data)

    recipeData =
        agingDays: r.agingDays
        agingTemp: r.agingTemp
        agingTempF: brauhaus.cToF r.agingTemp
        author: r.author
        batchSize: r.batchSize
        batchSizeGallons: brauhaus.litersToGallons r.batchSize
        boilSize: r.boilSize
        boilSizeGallons: brauhaus.litersToGallons r.boilSize
        bottlingPressure: r.bottlingPressure
        bottlingTemp: r.bottlingTemp
        bottlingTempF: brauhaus.cToF r.bottlingTemp
        description: r.description
        fermentables: r.fermentables
        ibuMethod: r.ibuMethod
        mash: r.mash
        mashEfficiency: r.mashEfficiency
        name: r.name
        primaryDays: r.primaryDays
        primaryTemp: r.primaryTemp
        primaryTempF: brauhaus.cToF r.primaryTemp
        secondaryDays: r.secondaryDays
        secondaryTemp: r.secondaryTemp
        secondaryTempF: brauhaus.cToF r.secondaryTemp
        servingSize: r.servingSize
        servingSizeOz: brauhaus.litersToGallons r.servingSize
        spices: r.spices
        steepEfficiency: r.steepEfficiency
        steepTime: r.steepTime
        style: r.style
        tertiaryDays: r.tertiaryDays
        tertiaryTemp: r.tertiaryTemp
        tertiaryTempF: brauhaus.cToF r.tertiaryTemp
        yeast: r.yeast

    if detail
        r.calculate()

        _.extend recipeData,
            abv: r.abv
            abw: r.abw
            brewDayDuration: r.brewDayDuration
            buToGu: r.buToGu
            bv: r.bv
            calories: r.calories
            color: r.color
            colorEbc: brauhaus.srmToEbc r.color
            colorLovibond: brauhaus.srmToLovibond r.color
            colorRgb: brauhaus.srmToRgb r.color
            fg: r.fg
            fgPlato: r.fgPlato
            ibu: r.ibu
            og: r.og
            ogPlato: r.ogPlato
            price: r.price
            realExtract: r.realExtract
            timeline: r.timeline()
            timelineImperial: r.timeline false

    parentData = recipe.parent or null

    serialized =
        id: recipe.id
        parent: parentData
        user:
            id: user.id
            name: user.name
            image: user.image
        slug: recipe.slug
        created: recipe.created
        private: recipe.private
        data: recipeData

    if populateParent
        select = '_id user slug name description'
        if detail
            select += ' color og fg ibu abv'

        # Unfortunately we need to call populate multiple times to fill
        # in both the parent recipe and its user info. Since we are
        # querying directly by ObjectId it should be fast and use
        # an index. Considering the infrequency of username and profile
        # image changes it may be a good idea to denormalize this data
        # in the future. <- TODO
        recipe
            .populate(path: 'parent', select: select)
            .populate (err, recipeWithParent) ->
                recipeWithParent
                    .populate(path: 'parent.user', select: '_id name image', model: 'User')
                    .populate (err, recipeWithParentUser) ->
                        p = recipeWithParentUser.parent

                        serialized.parent =
                            id: p.id
                            user:
                                id: p.user.id
                                name: p.user.name
                                image: p.user.image
                            slug: p.slug
                            name: p.name
                            description: p.description

                        if detail
                            _.extend serialized.parent,
                                color: p.color
                                colorEbc: brauhaus.srmToEbc p.color
                                colorLovibond: brauhaus.srmToLovibond p.color
                                colorRgb: brauhaus.srmToRgb p.color
                                og: p.og
                                fg: p.fg
                                ibu: p.ibu
                                abv: p.abv

                        done null, serialized
    else
        done null, serialized

recipeController.list = (req, res) ->
    if req.params.id
        req.query.ids = req.params.id

    conversions =
        ids: Array
        userIds: Array
        slugs: Array
        offset: Number
        limit: Number
        detail: Boolean
        populateParent: Boolean
        showPrivate: Boolean

    util.queryConvert req.query, conversions, (err) ->
        if err then return res.send(400, err.toString())

        listSchema.validate req.query, (err, data) ->
            if err then return res.send(400, err.toString())

            select =
                $or: [
                    {private: false}
                ]

            if data.showPrivate
                if not req.user or req.authInfo?.scopes?.indexOf('private') is -1
                    return res.send(401, 'Scope "private" required to view private recipes!')
                select.$or.push {private: true, user: req.user._id}

            if data.ids then select._id =
                $in: data.ids

            if data.parentIds then select.parent =
                $in: data.parentIds

            if data.userIds then select.user =
                $in: data.userIds

            if data.slugs then select.slug =
                $in: data.slugs

            query = Recipe.find select

            query = query.sort data.sort

            query = query.populate 'user', '_id name image'

            query.skip(data.offset).limit(data.limit).exec (err, recipes) ->
                if err then return res.send(500, err.toString())

                async.map recipes,
                    (recipe, done) ->
                        recipeController.serialize recipe, recipe.user, data.detail, data.populateParent, done
                    (err, result) ->
                        if err then return res.send(500, err.toString())
                        res.json result

recipeController.create = (req, res) ->
    creationSchema.validate req.body, (err, data) ->
        if err then return res.send(400, err.toString())

        data.recipe.author ?= req.user.name

        recipeData = new brauhaus.Recipe(data.recipe)

        recipeData.calculate()

        recipe = new Recipe
            parent: data.parent
            user: req.user._id
            name: recipeData.name
            slug: slug(recipeData.name).toLowerCase()
            og: recipeData.og
            fg: recipeData.fg
            ibu: recipeData.ibu
            abv: recipeData.abv
            color: recipeData.color
            private: data.private
            data: recipeData.toJSON()

        saveHandler = (err, saved) ->
            if err?.code is util.ERROR_DB_DUPE
                recipe.slug = incrementSlug recipe.slug
                return recipe.save saveHandler

            if err then return res.send(500, err.toString())

            # Create user action
            action = new Action
                user: req.user._id
                type: 'recipe-created'
                targetId: saved.id
                private: recipe.private
                data:
                    name: recipe.name
                    slug: recipe.slug
                    description: recipeData.description
                    og: recipeData.og
                    fg: recipeData.fg
                    ibu: recipeData.ibu
                    abv: recipeData.abv
                    color: recipeData.color

            action.save()

            recipeController.serialize saved, req.user, data.detail, data.populateParent, (err, serialized) ->
                if err then return res.send(500, err.toString())
                res.json serialized

        recipe.save saveHandler

recipeController.update = (req, res) ->
    params = _.extend {}, req.params, req.body
    updateSchema.validate params, (err, data) ->
        if err then return res.send(400, err.toString())

        update =
            modified: Date.now()

        if data.parent then update.parent = data.parent
        if data.private then update.private = data.private
        if data.recipe
            recipe = new brauhaus.Recipe(data.recipe)
            recipe.calculate()
            recipe.timeline()

            update.name = recipe.name
            update.slug = slug(recipe.name).toLowerCase()
            update.og = recipe.og
            update.fg = recipe.fg
            update.ibu = recipe.ibu
            update.abv = recipe.abv
            update.color = recipe.color
            update.data = recipe

            #req.info(require('util').inspect(update))

        Recipe.findById data.id, (err, original) ->
            if err then return res.send(500, err.toString())
            if not original then return res.send(404, 'Recipe not found')

            if req.user.id.toString() isnt original.user.toString()
                return res.send 401, "Recipe owner does not match user ID"

            if data.recipe
                # Generate a diff of the old vs. new recipe
                diff = brauhaus.Diff.diff(new brauhaus.Recipe(original.data).toJSON(), recipe.toJSON())
                if Object.keys(diff).length
                    # TODO: Should this be replaced with an atomic action that
                    # upserts to create the entry when needed???
                    RecipeHistory.findOne recipe: original.id, (err, history) ->
                        if err then return req.error(err)

                        if not history
                            history = new RecipeHistory
                                recipe: original.id

                        history.entries ?= []
                        history.entries.push
                            date: Date.now()
                            diff: diff

                        history.save (err) ->
                            if err then console.log err

            updateHandler = (err, saved) ->
                # findByIdAndUpdate returns 11001 instead of 11000...?!?
                if err?.lastErrorObject?.code is 11001
                    # Increment slug and try to save again
                    # FIXME: This is pretty inefficient
                    update.slug = incrementSlug update.slug
                    return Recipe.findByIdAndUpdate data.id, update, updateHandler

                if err then return res.send(500, err.toString())

                # Update existing actions
                workerData =
                    id: saved.id
                    user: req.user.id
                    private: saved.private
                    info:
                        name: saved.name
                        slug: saved.slug
                        description: saved.data.description
                        og: saved.og
                        fg: saved.fg
                        ibu: saved.ibu
                        abv: saved.abv
                        color: saved.color

                queue.put 'recipe-updated', workerData

                recipeController.serialize saved, req.user, data.detail, data.populateParent, (err, serialized) ->
                    if err then return res.send(500, err.toString())
                    res.json serialized

            Recipe.findByIdAndUpdate data.id, update, updateHandler

recipeController.delete = (req, res) ->
    params = util.extend {}, req.params
    deleteSchema.validate params, (err, data) ->
        if err then return res.send(400, err.toString())

        Recipe.findById data.id, (err, recipe) ->
            if err then return res.send(500, err.toString())

            if req.user.id.toString() isnt recipe.user.toString()
                return res.send 401, "Recipe owner does not match user ID"

            recipe.remove (err) ->
                if err then return res.send(500, err.toString())

                res.send 204, null
