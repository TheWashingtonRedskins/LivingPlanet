@Conductor = new ConductorClass()

@mouse =
  x: 0
  y: 0

document.addEventListener "mousemove", ((e) ->
  mouse.x = e.clientX or e.pageX
  mouse.y = e.clientY or e.pageY
  return
), false
