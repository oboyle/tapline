mongoose = require 'mongoose'
util = require '../util'

ActionSchema = new mongoose.Schema
    user:
        type: mongoose.Schema.Types.ObjectId
        required: true
        ref: 'User'
    created:
        type: Date
        default: Date.now
    type:
        type: String
        required: true
        enum: [
            'user-joined',
            'user-followed',
            'recipe-created',
            'recipe-updated'
        ]
    targetId:
        type: mongoose.Schema.Types.ObjectId
    private:
        type: Boolean
        default: false
    data:
        type: mongoose.Schema.Types.Mixed

# Cover common queries
ActionSchema.index {id: 1, user: 1, private: 1}

module.exports = mongoose.model 'Action', ActionSchema
