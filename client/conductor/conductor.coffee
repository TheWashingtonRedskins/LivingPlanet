@Views = new Meteor.Collection null
noop = ->
  undefined

defaultView =
  id: null
  slug: null
  template: null
  name: null
  subtitle: ""
  image: null
  subscriptions: noop
  waitOn: noop
  rendered: noop
  showTile: true

class Conductor
  constructor: ->
    @views = []

  registerView: (view)->
    view = _.pick view, _.keys defaultView
    view = _.defaults view, defaultView
    requiredKeys = ["id", "slug", "template", "name"]
    uniqueKeys = ["id", "slug"]
    for k in requiredKeys
      if !view[k]?
        throw "A view requires #{k} to be defined."
    existing = _.find Views.find().fetch(), (v)->
      for k in uniqueKeys
        return true if v[k] is view[k]
      false
    if existing?
      throw "That view already exists."
    Views.insert view
    @registerRoute view

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
    if target?
      Router.go target
  , if target is "" then 500 else 700
  i2 = Meteor.setTimeout ->
    Session.set "loadingOverlay", false
  , if target is "" then 600 else 1500

Meteor.startup ->
  Session.set "pageTarget", null

@ConductorClass = Conductor
