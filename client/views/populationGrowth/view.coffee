Meteor.startup ->
  Conductor.registerView
    id: "population"
    slug: "population" # Empty slug for /
    template: "populationGrowth"
    name: "Population Growth"
    image: ""
    subtitle: "Humanity is expanding at an unsustainable rate"
