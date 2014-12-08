Template.layout.helpers
  "showBack": ->
    _.last(Router.current().route.url().split('/')) isnt ""
Template.layout.events
  "click #backBtn": ->
    Conductor.goTo ""

Template.layout.rendered = ->
  $(window).resize ->
    placeFooter()
    return

  placeFooter()
  $("#footerLinks").css "display", "inline"
  return

# hide it before it's positioned
placeFooter = ->
  windHeight = $(window).height()
  footerHeight = $("#footerLinks").height()
  offset = parseInt(windHeight) - parseInt(footerHeight)
  $("#footerLinks").css "top", offset
  return
