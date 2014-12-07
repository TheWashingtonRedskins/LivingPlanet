container = null
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
effectRadialBlur = null
effectBloom = null
depthTarget = null
depthScale = 0.5
light = null
projector = new THREE.Projector()
cameraTarget = new THREE.Vector3()
pointLight = null
uniforms2 = null
lensflare = null
loader = null
overlay = null
trees = []
mouse = new THREE.Vector2(-0.5, 0.5)
touchDevice = (("ontouchstart" of document) or (navigator.userAgent.match(/ipad|iphone|android/i)?))
scaleRatio = 1
scaleRatio = 2  if touchDevice
bgSprite = null
particles = null
music = null
loadedItems = 0
checkLoading = ->
  ++loadedItems
  if loadedItems >= 8
    animate()
    if music
      music.play()
      volumeTween = new TWEEN.Tween(music).to(
        volume: 0.5
      , 4000).easing(TWEEN.Easing.Cubic.In)
      volumeTween.start()
    alphaTween = new TWEEN.Tween(bgSprite.material).to(
      opacity: 0
    , 4000).easing(TWEEN.Easing.Cubic.In).onComplete(->
      scene.remove bgSprite
      return
    )
    alphaTween.start()
    lensTween = new TWEEN.Tween(lensflare.uniforms["alpha"]).to(
      value: 1
    , 4000).easing(TWEEN.Easing.Cubic.In)
    lensTween.start()
  return
init = ->
  console.log "Initing"
  container = $("#introContainer")[0]
  global.camera = camera = new THREE.PerspectiveCamera(85, window.innerWidth / window.innerHeight, 1, 50000)
  camera.position.y = 750
  camera.position.z = 2000
  camera.position.x = 750
  camera.rotation.setX(-90)
  scene.add camera
  
  # black cover
  bgImage = new THREE.Texture(generateTexture())
  bgImage.needsUpdate = true
  spriteMaterial = new THREE.SpriteMaterial(
    map: bgImage
    useScreenCoordinates: true
  )
  bgSprite = new THREE.Sprite(spriteMaterial)
  bgSprite.position.set window.innerWidth >> 1, window.innerHeight >> 1, 0
  bgSprite.scale.set 5000, 5000
  scene.add bgSprite
  
  # tree
  loader = new THREE.JSONLoader()
  loader.load "/objects/Tree_04.js", treeLoaded
  fog = new THREE.Fog(0x1b0c02, 5000, 12000)
  
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

    customColor:
      type: "c"
      value: new THREE.Color(0xffffff)

  uniforms2 =
    map:
      type: "t"
      value: THREE.ImageUtils.loadTexture("/textures/leaf.png", `null`, checkLoading)

    map2:
      type: "t"
      value: THREE.ImageUtils.loadTexture("/textures/leaf2.png", `null`, checkLoading)

    fogColor:
      type: "c"
      value: fog.color

    fogNear:
      type: "f"
      value: fog.near

    fogFar:
      type: "f"
      value: fog.far

    globalTime:
      type: "f"
      value: 0.0

    bass:
      type: "f"
      value: 0.0

    black:
      type: "f"
      value: 1.0

    lightPos:
      type: "v2"
      value: new THREE.Vector2()

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
  while i < 30000
    plane.position.x = Math.random() * 15000 - 7500
    plane.position.y = Math.random() * 15000 - 7500
    plane.position.z = 0
    THREE.GeometryUtils.merge geometry, plane
    i++
  vertices = geometry.vertices
  values_direction = attributes.direction.value
  values_size = attributes.size.value
  values_seed = attributes.seed.value
  values_time = attributes.time.value
  values_colors = attributes.customColor.value
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
    color = new THREE.Color(0xffffff)
    color.setHSL 0.05 + Math.random() * 0.1, 1.0, 0.2 + Math.random() * 0.4
    values_colors[v] = color
    values_colors[v + 1] = color
    values_colors[v + 2] = color
    values_colors[v + 3] = color
    v += 4
  objects = new THREE.Mesh(geometry, material)
  objects.position.z = -7500
  scene.add objects
  
  # dirt
  overlayMaterial = new THREE.SpriteMaterial(
    map: THREE.ImageUtils.loadTexture("/textures/lensdirt.jpg", `null`, checkLoading)
    useScreenCoordinates: true
    fog: false
    opacity: 0.25
  )
  overlay = new THREE.Sprite(overlayMaterial)
  overlay.scale.set window.innerWidth / scaleRatio, window.innerHeight / scaleRatio, 1
  overlay.position.set (window.innerWidth / scaleRatio) / 2, (window.innerHeight / scaleRatio) / 2, 0
  camera.add overlay
  try
    
    # renderer
    renderer = new THREE.WebGLRenderer(antialias: false, alpha: true)
    renderer.setSize window.innerWidth / scaleRatio, window.innerHeight / scaleRatio
    renderer.setClearColor 0x151001
    renderer.sortObjects = false
    parameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      format: THREE.RGBFormat

    depthTarget = new THREE.WebGLRenderTarget((window.innerWidth / scaleRatio) * depthScale, (window.innerHeight / scaleRatio) * depthScale, parameters)
    
    # postprocessing
    renderer.autoClear = false
    renderModel = new THREE.RenderPass(scene, camera)
    effectRadialBlur = new THREE.ShaderPass(THREE.RadialBlurShader)
    effectRadialBlur.uniforms["tDepth"].value = depthTarget
    lensflare = new THREE.ShaderPass(THREE.LensflareShader)
    lensflare.uniforms["pos"].value = new THREE.Vector2(0.0, 0.5)
    lensflare.uniforms["res"].value = new THREE.Vector2(window.innerWidth / scaleRatio, window.innerHeight / scaleRatio)
    lensflare.uniforms["alpha"].value = 0
    effectBloom = new THREE.BloomPass(0.7)
    effectCopy = new THREE.ShaderPass(THREE.CopyShader)
    effectCopy.renderToScreen = true
    composer = new THREE.EffectComposer(renderer)
    composer.setSize window.innerWidth / scaleRatio, window.innerHeight / scaleRatio
    composer.addPass renderModel
    composer.addPass effectRadialBlur
    composer.addPass lensflare
    composer.addPass effectBloom
    composer.addPass effectCopy
    container.appendChild renderer.domElement
    has_gl = true
    document.addEventListener "mousemove", onMouseMove, false
    document.addEventListener "touchmove", onTouchMove, false
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
    document.getElementById("info").innerHTML = "<P><BR><B>Note.</B> You need a modern browser that supports WebGL for this to run the way it is intended.<BR>For example. <a href='http://www.google.com/landing/chrome/beta/' target='_blank'>Google Chrome 9+</a> or <a href='http://www.mozilla.com/firefox/beta/' target='_blank'>Firefox 4+</a>.<BR><BR>If you are already using one of those browsers and still see this message, it's possible that you<BR>have old blacklisted GPU drivers. Try updating the drivers for your graphic card.<BR>Or try to set a '--ignore-gpu-blacklist' switch for the browser.</P><CENTER><BR><img src='../general/WebGL_logo.png' border='0'></CENTER>"
    document.getElementById("info").style.display = "block"
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
  effectRadialBlur.uniforms["tDepth"].value = depthTarget
  lensflare.uniforms["res"].value = new THREE.Vector2(w / scaleRatio, h / scaleRatio)
  composer.reset()
  composer.setSize w / scaleRatio, h / scaleRatio
  if overlay
    overlay.scale.set w / scaleRatio, h / scaleRatio, 1
    overlay.position.set (w / scaleRatio) / 2, (h / scaleRatio) / 2, 0
  return
getTreeMaterial = (texture, shadow) ->
  attributes = {}
  uniforms =
    color:
      type: "c"
      value: new THREE.Color()

    map:
      type: "t"
      value: texture

    shadow:
      type: "t"
      value: shadow

    globalTime:
      type: "f"
      value: 0.0

    lightPos:
      type: "v2"
      value: new THREE.Vector2()

  material = new THREE.ShaderMaterial(
    uniforms: uniforms
    attributes: attributes
    vertexShader: treeVS
    fragmentShader: treeFS
    transparent: true
    side: THREE.DoubleSide
  )
  material
treeLoaded = (geometry, mm) ->
  geometry.applyMatrix new THREE.Matrix4().makeRotationFromEuler(new THREE.Vector3(-Math.PI / 2, 0, 0))
  
  #geometry.computeVertexNormals();
  #geometry.computeFaceNormals();
  center = new THREE.Vector3(0, 28, 0)
  i = 0

  while i < geometry.faces.length
    face = geometry.faces[i]
    a = geometry.vertices[face.a]
    b = geometry.vertices[face.b]
    c = geometry.vertices[face.c]
    face.vertexNormals[0] = new THREE.Vector3().copy(a).sub(center).normalize()
    face.vertexNormals[1] = new THREE.Vector3().copy(b).sub(center).normalize()
    face.vertexNormals[2] = new THREE.Vector3().copy(c).sub(center).normalize()
    i++
  texture = THREE.ImageUtils.loadTexture("/textures/test4.png", `null`, checkLoading)
  shadow = THREE.ImageUtils.loadTexture("/textures/test6.png", `null`, checkLoading)
  shadow.wrapS = THREE.MirroredRepeatWrapping
  shadow.wrapT = THREE.MirroredRepeatWrapping
  num = 1
  
  # trees
  i = 0

  while i < num
    material0 = getTreeMaterial(texture, shadow)
    material1 = new THREE.MeshBasicMaterial(
      color: 0x000000
      side: THREE.DoubleSide
    )
    c = new THREE.Color().setHSL(0.025 + Math.random() * 0.15, 0.75, 0.45)
    material0.uniforms.color.value = c
    material0.side = THREE.FrontSide  if i is 0
    mf = new THREE.MeshFaceMaterial([
      material0
      material1
    ])
    a = (i / num) * Math.PI * 2
    radius = 4000 + Math.random() * 4000
    tree = new THREE.Mesh(geometry, mf)
    s = 150 + Math.random() * 50
    tree.scale.set s, 150, s
    tree.position.set Math.sin(a) * radius, Math.cos(a) * radius, 2500
    tree.rotation.z = Math.random() * (Math.PI * 2)
    tree.seed = Math.random() * num
    tree.light = true
    if i is 0
      tree.position.set -9000, 0, -5500
      tree.rotation.x = 2
      tree.scale.set 200, 200, 200
      tree.rotation.y = -Math.PI / 2
    console.log scene
    scene.add tree
    trees.push tree
    i++
  
  # some "walls"
  cyl = new THREE.CylinderGeometry(15000, 15000, 18000, 100, 1, true)
  i = 0

  while i < cyl.vertices.length
    cyl.vertices[i].y += Math.random() * 4000 - 2000  if cyl.vertices[i].y > 0
    i++
  ma = new THREE.MeshBasicMaterial(
    color: 0x000000
    side: THREE.BackSide
  )
  mesh = new THREE.Mesh(cyl, ma)
  mesh.rotation.x = -Math.PI / 2
  mesh.position.z = 3000
  scene.add mesh
  
  # Particles
  map = THREE.ImageUtils.loadTexture("/textures/bob.png", `null`, checkLoading)
  attributes =
    size:
      type: "f"
      value: []

    time:
      type: "f"
      value: []

  uniforms =
    color:
      type: "c"
      value: new THREE.Color(0xffffff)

    texture:
      type: "t"
      value: map

    globalTime:
      type: "f"
      value: 0.0

    bass:
      type: "f"
      value: 0.0

  uniforms.color.value.setHSL 0.15, 1.0, 0.75
  shaderMaterial = new THREE.ShaderMaterial(
    uniforms: uniforms
    attributes: attributes
    vertexShader: pVS
    fragmentShader: pFS
    transparent: true
  )
  geometry = new THREE.Geometry()
  i = 0
  while i < 1000
    vertex = new THREE.Vector3(Math.random() * 4000 - 2000, Math.random() * 4000 - 2000, Math.random() * -3000 - 250)
    geometry.vertices.push vertex
    i++
  particles = new THREE.ParticleSystem(geometry, shaderMaterial)
  vertices = geometry.vertices
  values_size = attributes.size.value
  values_time = attributes.time.value
  v = 0

  while v < vertices.length
    values_size[v] = (40 + Math.random() * 40) / scaleRatio
    v++
  particles.position.z = camera.position.z
  scene.add particles
  return
getScreenPosition = (object) ->
  vector = projector.projectVector(new THREE.Vector3().getPositionFromMatrix(object.matrixWorld), camera)
  vector
onMouseMove = (event) ->
  event.preventDefault()
  mouse.x = (event.clientX / window.innerWidth) * 2 - 1
  mouse.y = -(event.clientY / window.innerHeight) * 2 + 1
  return
onTouchMove = (event) ->
  event.preventDefault()
  i = 0

  while i < event.changedTouches.length
    tx = (event.changedTouches[i].clientX / window.innerWidth) * 2 - 1
    ty = -(event.changedTouches[i].clientY / window.innerHeight) * 2 + 1
    mouse.x = tx
    mouse.y = ty
    i++
  return
animate = ->
  requestAnimationFrame animate
  render()
  return
render = ->
  time = Date.now()
  delta = time - oldTime
  oldTime = time
  delta = 1000 / 60  if isNaN(delta) or delta > 1000 or delta is 0
  optimalDivider = delta / 16
  #camera.position.x = 600
  #camera.position.y = 5000
  #camera.lookAt scene.position
  
  #camera.up.x += (mouse.x*0.25 - camera.up.x)/30;
  #camera.up.z += (mouse.y*0.25 - camera.up.z)/30;
  uniforms2.globalTime.value += delta * 0.00005
  TWEEN.update()
  pos = getScreenPosition(light)
  effectRadialBlur.uniforms["center"].value.x = (pos.x + 0.5) * 0.8 + 0.1
  effectRadialBlur.uniforms["center"].value.y = (pos.y + 0.5) * 0.8 + 0.1
  lensflare.uniforms["pos"].value.x = (pos.x) #*1.25;
  lensflare.uniforms["pos"].value.y = (pos.y * -1) #*1.25;
  uniforms2.lightPos.value.x = (pos.x + 0.5)
  uniforms2.lightPos.value.y = (pos.y + 0.5)
  light.lookAt camera.position
  lng = pos.x * pos.x + pos.y * pos.y
  overlay.material.opacity = Math.max(0.05, (0.2 - lng))
  particles.material.uniforms.globalTime.value += delta * 0.00005
  if has_gl
    renderer.clear()
    i = 0

    while i < trees.length
      if trees[i].light
        trees[i].material.materials[0].uniforms.lightPos.value.x = (pos.x + 0.5)
        trees[i].material.materials[0].uniforms.lightPos.value.y = (pos.y + 0.5)
        trees[i].material.materials[0].uniforms.globalTime.value += delta * 0.001
      i++
    uniforms2.black.value = 0
    light.visible = true
    light.material.opacity = 0.8
    renderer.render scene, camera, depthTarget, true
    uniforms2.black.value = 1
    light.material.opacity = 0.5
    composer.render 0.01
  return
Template.intro.rendered = ->
  startTime = Date.now()
  checkLoading()
  init()
