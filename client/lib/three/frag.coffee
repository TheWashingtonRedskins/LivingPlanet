@leafFS = """
uniform sampler2D map;
uniform sampler2D map2;

varying vec2 vUv;
varying vec3 vNormal;

uniform float globalTime;
varying float vSeed;
uniform float black;


void main() {

    float depth = gl_FragCoord.z / gl_FragCoord.w;

    vec4 tex = vec4(0.0);

    if (vSeed > 0.5) {
        tex = texture2D( map2, vUv );
    } else {
        tex = texture2D( map, vUv );
    }

    float tres = 0.01;

    if (black > 0.5) {
        tres = 0.8;
    }

    if (tex.w <= tres) {
        discard;
    }

    float t = globalTime;

    gl_FragColor = vec4( tex.xyz*black, tex.w);

    if (black > 0.5) {
        gl_FragColor.w *= pow( gl_FragCoord.z, 20.0 );
    }

}
"""
