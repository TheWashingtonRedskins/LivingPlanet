Meteor.startup ->
  Conductor.registerView
    id: "disease"
    slug: "disease" # Empty slug for /
    template: "disease"
    name: "Disease"
