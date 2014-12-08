Meteor.startup ->
  Conductor.registerView
    id: "water"
    slug: "water"
    template: "water"
    name: "Water Shortage"
    image: "http://materializecss.com/images/sample-1.png"
    subtitle: "Millions are left without water despite current technology"