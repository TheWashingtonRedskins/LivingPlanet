Meteor.startup ->
  Session.set "loadingOverlay", true

Template.loadingOverlay.helpers
  "showLoading": ->
    Session.get("loadingOverlay")
