Meteor.startup ->
  Conductor.registerView
    id: "birds"
    slug: "birds" # Empty slug for /
    template: "birds"
    name: "Bird Test"
