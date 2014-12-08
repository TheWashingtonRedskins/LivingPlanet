Meteor.startup ->
  Conductor.registerView
    id: "water"
    slug: "water"
    template: "water"
    name: "Water Shortage"
    image: "http://materializecss.com/images/sample-1.png"
    subtitle: "Water is super short yo!"
