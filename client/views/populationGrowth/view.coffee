Meteor.startup ->
  Conductor.registerView
    id: "population"
    slug: "population" # Empty slug for /
    template: "populationGrowth"
    name: "Population Growth"
    image: ""
    subtitle: "How quickly we are expanding"