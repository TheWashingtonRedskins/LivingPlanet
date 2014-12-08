Meteor.startup ->
  Conductor.registerView
    id: "hunger"
    slug: "hunger" # Empty slug for /
    template: "hunger"
    name: "World Hunger"
    subtitle: "Nearly one billion people can't get the nutrition they need"
    image: ""
