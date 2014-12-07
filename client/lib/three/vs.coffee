@leafVS = """
uniform float globalTime;

attribute vec3 direction;
attribute float size;
attribute float seed;
attribute float time;

varying vec2 vUv;
varying vec3 vNormal;
varying float vSeed;

void main() {

    vSeed = seed;

    vec3 animated = position;

    // time
    float localTime = time + globalTime*(0.5+seed);
    float modTime = mod( localTime, 1.0 );
    float accTime = modTime * modTime;

    animated.z = accTime*11000.0;

    float rotation = localTime*40.0;
    if (seed < 0.5) {
        rotation *= -1.0;
    }

    float s = sin(rotation);
    float c = cos(rotation);

    mat3 rotX = mat3(
        vec3( 1.0, 0.0,0.0),
        vec3( 0.0, c,  s),
        vec3( 0.0,-s,  c)
    );

    mat3 rotZ = mat3(
        vec3( c,  s,  0.0),
        vec3(-s,  c,  0.0),
        vec3( 0.0,0.0,1.0)
    );


    vec3 dd = direction;
    dd.y *= sin(rotation);

    vec3 rotatedDirection = dd*(rotZ*rotX);

    vNormal = normal*(rotZ*rotX);

    animated += rotatedDirection*size;

    vUv = uv;

    vec4 mvPosition = modelViewMatrix * vec4( animated, 1.0 );

    gl_Position = projectionMatrix * mvPosition;

}
"""
