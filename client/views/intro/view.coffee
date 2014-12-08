Meteor.startup ->
  Conductor.registerView
    id: "intro"
    slug: "" # Empty slug for /
    template: "intro"
    name: "Introduction Animation"
    showTile: false
    image: ""
