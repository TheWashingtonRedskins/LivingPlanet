Meteor.startup ->
  Conductor.registerView
    id: "hunger"
    slug: "hunger" # Empty slug for /
    template: "hunger"
    name: "World Hunger"