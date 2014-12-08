Template.layout.helpers
  "showBack": ->
    _.last(Router.current().route.url().split('/')) isnt ""
Template.layout.events
  "click #backBtn": ->
    Conductor.goTo ""
