SCREEN_WIDTH = window.innerWidth
SCREEN_HEIGHT = window.innerHeight
SCREEN_WIDTH_HALF = SCREEN_WIDTH / 2
SCREEN_HEIGHT_HALF = SCREEN_HEIGHT / 2
camera = undefined
scene = undefined
renderer = undefined
birds = undefined
bird = undefined
boid = undefined
boids = undefined
stats = undefined
Bird = ->
  
  # f3( 0, 3, 2 );
  v = (x, y, z) ->
    scope.vertices.push new THREE.Vector3(x, y, z)
    return
  f3 = (a, b, c) ->
    scope.faces.push new THREE.Face3(a, b, c)
    return
  scope = this
  THREE.Geometry.call this
  v 5, 0, 0
  v -5, -2, 1
  v -5, 0, 0
  v -5, -2, -1
  v 0, 2, -6
  v 0, 2, 6
  v 2, 0, 0
  v -3, 0, 0
  f3 0, 2, 1
  f3 4, 7, 6
  f3 5, 6, 7
  @computeFaceNormals()
  return

Bird:: = Object.create(THREE.Geometry::)

Boid = ->
  vector = new THREE.Vector3()
  _acceleration = undefined
  _width = 500
  _height = 500
  _depth = 200
  _goal = undefined
  _neighborhoodRadius = 100
  _maxSpeed = 4
  _maxSteerForce = 0.1
  _avoidWalls = false
  @position = new THREE.Vector3()
  @velocity = new THREE.Vector3()
  _acceleration = new THREE.Vector3()
  @setGoal = (target) ->
    _goal = target
    return

  @setAvoidWalls = (value) ->
    _avoidWalls = value
    return

  @setWorldSize = (width, height, depth) ->
    _width = width
    _height = height
    _depth = depth
    return

  @run = (boids) ->
    if _avoidWalls
      vector.set -_width, @position.y, @position.z
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
      vector.set _width, @position.y, @position.z
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
      vector.set @position.x, -_height, @position.z
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
      vector.set @position.x, _height, @position.z
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
      vector.set @position.x, @position.y, -_depth
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
      vector.set @position.x, @position.y, _depth
      vector = @avoid(vector)
      vector.multiplyScalar 5
      _acceleration.add vector
    # else {
    #
    #                       this.checkBounds();
    #
    #                   }
    #                   
    @flock boids  if Math.random() > 0.5
    @move()
    return

  @flock = (boids) ->
    _acceleration.add @reach(_goal, 0.005)  if _goal
    _acceleration.add @alignment(boids)
    _acceleration.add @cohesion(boids)
    _acceleration.add @separation(boids)
    return

  @move = ->
    @velocity.add _acceleration
    l = @velocity.length()
    @velocity.divideScalar l / _maxSpeed  if l > _maxSpeed
    @position.add @velocity
    _acceleration.set 0, 0, 0
    return

  @checkBounds = ->
    @position.x = -_width  if @position.x > _width
    @position.x = _width  if @position.x < -_width
    @position.y = -_height  if @position.y > _height
    @position.y = _height  if @position.y < -_height
    @position.z = -_depth  if @position.z > _depth
    @position.z = _depth  if @position.z < -_depth
    return

  
  #
  @avoid = (target) ->
    steer = new THREE.Vector3()
    steer.copy @position
    steer.sub target
    steer.multiplyScalar 1 / @position.distanceToSquared(target)
    steer

  @repulse = (target) ->
    distance = @position.distanceTo(target)
    if distance < 150
      steer = new THREE.Vector3()
      steer.subVectors @position, target
      steer.multiplyScalar 0.5 / distance
      _acceleration.add steer
    return

  @reach = (target, amount) ->
    steer = new THREE.Vector3()
    steer.subVectors target, @position
    steer.multiplyScalar amount
    steer

  @alignment = (boids) ->
    boid = undefined
    velSum = new THREE.Vector3()
    count = 0
    i = 0
    il = boids.length

    while i < il
      if Math.random() > 0.6
        i++
        continue
      boid = boids[i]
      distance = boid.position.distanceTo(@position)
      if distance > 0 and distance <= _neighborhoodRadius
        velSum.add boid.velocity
        count++
      i++
    if count > 0
      velSum.divideScalar count
      l = velSum.length()
      velSum.divideScalar l / _maxSteerForce  if l > _maxSteerForce
    velSum

  @cohesion = (boids) ->
    boid = undefined
    distance = undefined
    posSum = new THREE.Vector3()
    steer = new THREE.Vector3()
    count = 0
    i = 0
    il = boids.length

    while i < il
      if Math.random() > 0.6
        i++
        continue
      boid = boids[i]
      distance = boid.position.distanceTo(@position)
      if distance > 0 and distance <= _neighborhoodRadius
        posSum.add boid.position
        count++
      i++
    posSum.divideScalar count  if count > 0
    steer.subVectors posSum, @position
    l = steer.length()
    steer.divideScalar l / _maxSteerForce  if l > _maxSteerForce
    steer

  @separation = (boids) ->
    boid = undefined
    distance = undefined
    posSum = new THREE.Vector3()
    repulse = new THREE.Vector3()
    i = 0
    il = boids.length

    while i < il
      if Math.random() > 0.6
        i++
        continue
      boid = boids[i]
      distance = boid.position.distanceTo(@position)
      if distance > 0 and distance <= _neighborhoodRadius
        repulse.subVectors @position, boid.position
        repulse.normalize()
        repulse.divideScalar distance
        posSum.add repulse
      i++
    posSum

  return

init = ->
  camera = new THREE.PerspectiveCamera(75, SCREEN_WIDTH / SCREEN_HEIGHT, 1, 10000)
  camera.position.z = 450
  scene = new THREE.Scene()
  birds = []
  boids = []
  i = 0

  while i < 200
    boid = boids[i] = new Boid()
    boid.position.x = Math.random() * 400 - 200
    boid.position.y = Math.random() * 400 - 200
    boid.position.z = Math.random() * 400 - 200
    boid.velocity.x = Math.random() * 2 - 1
    boid.velocity.y = Math.random() * 2 - 1
    boid.velocity.z = Math.random() * 2 - 1
    boid.setAvoidWalls true
    boid.setWorldSize 500, 500, 400
    bird = birds[i] = new THREE.Mesh(new Bird(), new THREE.MeshBasicMaterial(
      color: Math.random() * 0xffffff
      side: THREE.DoubleSide
    ))
    bird.phase = Math.floor(Math.random() * 62.83)
    scene.add bird
    i++
  renderer = new THREE.WebGLRenderer({devicePixelRatio: 1})
  renderer.setClearColor 0xffffff
  renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT
  document.addEventListener "mousemove", onDocumentMouseMove, false
  document.body.appendChild renderer.domElement
  stats = new Stats()
  stats.domElement.style.position = "absolute"
  stats.domElement.style.left = "0px"
  stats.domElement.style.top = "0px"
  document.getElementById("birdContainer").appendChild stats.domElement
  window.addEventListener "resize", onWindowResize, false
  return
onWindowResize = ->
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize window.innerWidth, window.innerHeight
  return
onDocumentMouseMove = (event) ->
  vector = new THREE.Vector3(event.clientX - SCREEN_WIDTH_HALF, -event.clientY + SCREEN_HEIGHT_HALF, 0)
  i = 0
  il = boids.length

  while i < il
    boid = boids[i]
    vector.z = boid.position.z
    boid.repulse vector
    i++
  return

#
animate = ->
  requestAnimationFrame animate
  render()
  stats.update()
  return
render = ->
  i = 0
  il = birds.length

  while i < il
    boid = boids[i]
    boid.run boids
    bird = birds[i]
    bird.position.copy boids[i].position
    color = bird.material.color
    color.r = color.g = color.b = (500 - bird.position.z) / 1000
    bird.rotation.y = Math.atan2(-boid.velocity.z, boid.velocity.x)
    bird.rotation.z = Math.asin(boid.velocity.y / boid.velocity.length())
    bird.phase = (bird.phase + (Math.max(0, bird.rotation.z) + 0.1)) % 62.83
    bird.geometry.vertices[5].y = bird.geometry.vertices[4].y = Math.sin(bird.phase) * 5
    i++
  renderer.render scene, camera
  return

Template.birds.rendered = ->
  SCREEN_WIDTH = window.innerWidth
  SCREEN_HEIGHT = window.innerHeight
  SCREEN_WIDTH_HALF = SCREEN_WIDTH / 2
  SCREEN_HEIGHT_HALF = SCREEN_HEIGHT / 2
  init()
  animate()
