global = @
Meteor.startup ->
  global.Conductor = new ConductorClass()
