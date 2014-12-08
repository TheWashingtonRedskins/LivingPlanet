Meteor.startup ->
  Conductor.registerView
    id: "about"
    slug: "about" # Empty slug for /
    template: "about"
    name: "About Us"
    image: ""
    subtitle: ""
    showTile: false
