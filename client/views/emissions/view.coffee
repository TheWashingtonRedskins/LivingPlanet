Meteor.startup ->
  Conductor.registerView
    id: "emissions"
    slug: "emissions" # Empty slug for /
    template: "emissions"
    name: "CO2 emissions"
    image: ""
    subtitle: "Our constant emission of CO2 drastically alters our environmnet"
