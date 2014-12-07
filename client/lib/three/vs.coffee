@pVS = """
attribute float size;
attribute float time;
uniform float globalTime;

varying float vAlpha;
varying float vDarken;

void main() {

    vec3 pos = position; 

    // time
    float localTime = time + globalTime;
    float modTime = mod( localTime, 1.0 );
    float accTime = modTime * modTime;

    pos.x += cos(modTime*32.0 + (position.z))*100.0; 
    pos.y += sin(modTime*24.0 + (position.x))*100.0; 
    pos.z += sin(modTime*24.0 + (position.y))*100.0;

    vec3 animated = vec3( pos.x, pos.y, pos.z );

    vAlpha = sin((globalTime + animated.y*0.025)*0.5);

    vDarken = 1.0 - length(vec2(animated.x, animated.y))/6000.0;

    vec4 mvPosition = modelViewMatrix * vec4( animated, 1.0 );

    gl_PointSize = min(10.0, (size * ( 250.0 / length( mvPosition.xyz ) ) ) );

    gl_Position = projectionMatrix * mvPosition;

}

"""
@treeVS = """
uniform float globalTime;

varying vec2 vUv;
varying vec3 vNormal;
varying float vDarken;

void main() {

    vUv = uv;
    vNormal = normal;

    vDarken = 1.25-max( 0.25, (position.z+30.0)/10.0 );

    vec3 animated = position;

    animated.x += sin(position.y*0.04+globalTime)*1.0;
    animated.y += cos(position.x*0.03+globalTime)*1.0;
    animated.z += cos(position.z*0.02+globalTime)*1.0;

    vec4 mvPosition = modelViewMatrix * vec4( animated, 1.0 );

    gl_Position = projectionMatrix * mvPosition;

}
"""
@leafVS = """
uniform float globalTime;

attribute vec3 direction;
attribute float size;
attribute float seed;
attribute float time;
attribute vec3 customColor;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vNormal;
varying float vSeed;
varying float vDarken;

void main() {

    vColor = customColor;
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

    vDarken = 1.0 - length(vec2(animated.x, animated.y))/7000.0;

    vUv = uv;

    vec4 mvPosition = modelViewMatrix * vec4( animated, 1.0 );

    gl_Position = projectionMatrix * mvPosition;

}
"""
