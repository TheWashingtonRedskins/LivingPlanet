noop = ->
  undefined
defaultView =
  id: null
  slug: null
  template: null
  name: null
  subtitle: ""
  image: null
  iconTemplate: null
  subscriptions: noop
  waitOn: noop
  rendered: noop

class Conductor
  constructor: ->
    @views = []
    @updateViews()

  updateViews: ->
    Session.set "views", @views

  registerView: (view)->
    view = _.pick view, _.keys defaultView
    view = _.defaults view, defaultView
    requiredKeys = ["id", "slug", "template", "name"]
    uniqueKeys = ["id", "slug"]
    for k in requiredKeys
      if !view[k]?
        throw "A view requires #{k} to be defined."
    existing = _.find @views, (v)->
      for k in uniqueKeys
        return true if v[k] is view[k]
      false
    if existing?
      throw "That view already exists."
    @views.push view
    @updateViews()

@ConductorClass = Conductor
