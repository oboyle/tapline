accountController = module.exports

accountController.accountPage = (req, res) ->
    res.render 'account'

accountController.registerPage = (req, res) ->
    res.render 'register'

accountController.updateAccount = (req, res) ->
    # TODO: update user account info like email, password, etc
    res.send(404, 'Not implemented yet')
