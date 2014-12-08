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
  showTile: true

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
    @registerRoute view
    @updateViews()

  registerRoute: (view)->
    Router.route view.slug,
      layoutTemplate: "layout"
      template: view.template

  goTo: (url)->
    Session.set "pageTarget", url
    Session.set "loadingOverlay", true

i1 = null
i2 = null
Tracker.autorun ->
  target = Session.get "pageTarget"
  overlay = Session.get "loadingOverlay"
  return if !overlay
  Meteor.clearTimeout i1 if i1?
  Meteor.clearTimeout i2 if i2?
  i1 = Meteor.setTimeout ->
    Router.go target
  , 1000
  i2 = Meteor.setTimeout ->
    Session.set "loadingOverlay", false
  , 3250

@ConductorClass = Conductor
