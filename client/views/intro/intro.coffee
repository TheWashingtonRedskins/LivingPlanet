is_rendering = false
global = @
@camera = null
camera = null
console.log "Creating scene"
scene = new THREE.Scene()
@scene = scene
renderer = null
composer = null
has_gl = false
delta = null
time = null
oldTime = null
depthTarget = null
depthScale = 0.5
light = null
projector = new THREE.Projector()
cameraTarget = new THREE.Vector3()
pointLight = null
uniforms2 = null
scaleRatio = 1.1
#bgSprite = null
loadedItems = 0
checkLoading = ->
  ++loadedItems
  if loadedItems >= 4
    animate()
  return
init = ->
  console.log "Initing"
  global.camera = camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 1, 50000)
  camera.position.y = 500
  camera.position.z = 2000
  camera.position.x = 750
  camera.rotation.setX(45)
  camera.rotation.setY(0)
  camera.rotation.setZ(85)
  scene.add camera
  
  # black cover
  #bgImage = new THREE.Texture(generateTexture())
  #bgImage.needsUpdate = true
  #spriteMaterial = new THREE.SpriteMaterial(
  #  map: bgImage
  #  useScreenCoordinates: true
  #)
  #bgSprite = new THREE.Sprite(spriteMaterial)
  #bgSprite.position.set window.innerWidth >> 1, window.innerHeight >> 1, 0
  #bgSprite.scale.set 5000, 5000
  #scene.add bgSprite
  
  #fog = new THREE.Fog(0x1b0c02, 5000, 12000)
  
  # sun
  m = new THREE.MeshBasicMaterial(
    color: 0xffffff
    transparent: true
    fog: false
    opacity: 0.25
    blending: THREE.AdditiveBlending
    map: THREE.ImageUtils.loadTexture("/textures/lensflare0.png", `null`, checkLoading)
  )
  light = new THREE.Mesh(new THREE.PlaneGeometry(10, 10), m)
  s = 5000
  light.scale.set s, s, s
  light.position.set 0, 0, -10000
  scene.add light
  
  # leaves
  geometry = new THREE.Geometry()
  attributes =
    direction:
      type: "v3"
      value: new THREE.Vector3(0, 0, 0)

    seed:
      type: "f"
      value: []

    time:
      type: "f"
      value: []

    size:
      type: "f"
      value: []

  uniforms2 =
    map:
      type: "t"
      value: THREE.ImageUtils.loadTexture("/textures/leaf.png", `null`, checkLoading)

    map2:
      type: "t"
      value: THREE.ImageUtils.loadTexture("/textures/leaf2.png", `null`, checkLoading)

    globalTime:
      type: "f"
      value: 0.0

    bass:
      type: "f"
      value: 0.0

    black:
      type: "f"
      value: 0.0

  material = new THREE.ShaderMaterial(
    uniforms: uniforms2
    attributes: attributes
    vertexShader: leafVS
    fragmentShader: leafFS
    transparent: true
    side: THREE.DoubleSide
  )
  geo = new THREE.PlaneGeometry(2, 2)
  THREE.GeometryUtils.triangulateQuads geo
  geo.applyMatrix new THREE.Matrix4().makeRotationFromEuler(new THREE.Vector3(-Math.PI / 2, 0, 0))
  geo.vertices[0].y = 0.5
  geo.vertices[3].y = 0.5
  geo.computeVertexNormals()
  geo.computeFaceNormals()
  plane = new THREE.Mesh(geo)
  i = 0
  while i < 500
    plane.position.x = Math.random() * 10000 - 2500
    plane.position.y = Math.random() * 5000 - 250
    plane.position.z = 0
    THREE.GeometryUtils.merge geometry, plane
    i++
  vertices = geometry.vertices
  values_direction = attributes.direction.value
  values_size = attributes.size.value
  values_seed = attributes.seed.value
  values_time = attributes.time.value
  testGeometry = new THREE.PlaneGeometry(2, 2)
  THREE.GeometryUtils.triangulateQuads testGeometry
  testGeometry.applyMatrix new THREE.Matrix4().makeRotationFromEuler(new THREE.Vector3(-Math.PI / 2, 0, 0))
  testGeometry.applyMatrix new THREE.Matrix4().setPosition(new THREE.Vector3(1.0, 0, 1.0))
  testGeometry.vertices[0].y = 0.5
  testGeometry.vertices[3].y = 0.5
  v = 0

  while v < vertices.length
    values_direction[v] = testGeometry.vertices[0]
    values_direction[v + 1] = testGeometry.vertices[1]
    values_direction[v + 2] = testGeometry.vertices[2]
    values_direction[v + 3] = testGeometry.vertices[3]
    size = 40 + Math.random() * 100
    values_size[v] = size
    values_size[v + 1] = size
    values_size[v + 2] = size
    values_size[v + 3] = size
    seed = Math.random()
    values_seed[v] = seed
    values_seed[v + 1] = seed
    values_seed[v + 2] = seed
    values_seed[v + 3] = seed
    time = Math.random()
    values_time[v] = time
    values_time[v + 1] = time
    values_time[v + 2] = time
    values_time[v + 3] = time
    v += 4
  objects = new THREE.Mesh(geometry, material)
  objects.position.z = -7500
  scene.add objects
  
  light.lookAt camera.position

  try
    
    # renderer
    renderer = new THREE.WebGLRenderer(antialias: false, alpha: true)
    renderer.setSize window.innerWidth / scaleRatio, window.innerHeight / scaleRatio
    renderer.setClearColor 0xffffff, 0
    renderer.sortObjects = false
    parameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat

    depthTarget = new THREE.WebGLRenderTarget((window.innerWidth / scaleRatio) * depthScale, (window.innerHeight / scaleRatio) * depthScale, parameters)
    
    # postprocessing
    renderer.autoClear = false
    renderModel = new THREE.RenderPass(scene, camera)
    effectCopy = new THREE.ShaderPass(THREE.CopyShader)
    effectCopy.renderToScreen = true
    composer = new THREE.EffectComposer(renderer)
    composer.setSize window.innerWidth / scaleRatio, window.innerHeight / scaleRatio
    composer.addPass renderModel
    composer.addPass effectCopy
    has_gl = true
    window.addEventListener "resize", onWindowResize, false
    if scaleRatio > 1
      renderer.domElement.style.webkitTransform = "scale3d(" + scaleRatio + ", " + scaleRatio + ", 1)"
      renderer.domElement.style.webkitTransformOrigin = "0 0 0"
      renderer.domElement.style.transform = "scale3d(" + scaleRatio + ", " + scaleRatio + ", 1)"
      renderer.domElement.style.transformOrigin = "0 0 0"
      renderer.domElement.style.position = "absolute"
      renderer.domElement.style.top = "0px"
      renderer.domElement.style.left = "0px"
  catch e
    
    # need webgl
    console.log e
    alert "Please view this website in a browser that supports webgl."
    return
  return
generateTexture = ->
  canvas = document.createElement("canvas")
  canvas.width = 32
  canvas.height = 32
  context = canvas.getContext("2d")
  context.fillStyle = "#000000"
  context.fillRect 0, 0, 32, 32
  canvas
onWindowResize = (event) ->
  w = window.innerWidth
  h = window.innerHeight
  renderer.setSize w / scaleRatio, h / scaleRatio
  camera.aspect = w / h
  camera.updateProjectionMatrix()
  parameters =
    minFilter: THREE.LinearFilter
    magFilter: THREE.LinearFilter
    format: THREE.RGBFormat

  depthTarget = new THREE.WebGLRenderTarget((w / scaleRatio) * depthScale, (w / scaleRatio) * depthScale, parameters)
  composer.reset()
  composer.setSize w / scaleRatio, h / scaleRatio
animate = ->
  if is_rendering
    requestAnimationFrame animate
  render()
  return
render = ->
  time = Date.now()
  delta = time - oldTime
  oldTime = time
  delta = 1000 / 60  if isNaN(delta) or delta > 1000 or delta is 0
  optimalDivider = delta / 16
  uniforms2.globalTime.value += delta * 0.00005
  if has_gl
    renderer.clear()
    renderer.render scene, camera, depthTarget, true
    composer.render 0.01
  return
Meteor.startup ->
  checkLoading()
  init()
Template.intro.rendered = ->
  startTime = Date.now()
  container = $("#introContainer")[0]
  container.appendChild renderer.domElement
  is_rendering = true
  animate()
Template.intro.destroyed = ->
  is_rendering = false

Template.intro.helpers
  view: ->
    Views.find({showTile: true})
Template.intro.events
  "click .learnMore": ->
    Conductor.goTo @slug
