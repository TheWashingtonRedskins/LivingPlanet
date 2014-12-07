@pFS = """
uniform vec3 color;
uniform sampler2D texture;

varying float vAlpha;
varying float vDarken;

void main() {

    vec4 outColor = texture2D( texture, gl_PointCoord );

    gl_FragColor = vec4( outColor.xyz*color*vAlpha, (outColor.w*vAlpha)*0.5 );
    //gl_FragColor *= vDarken;
}
"""
@treeFS = """
uniform sampler2D map;
uniform vec3 color;
uniform vec2 lightPos;

varying vec2 vUv;
varying vec3 vNormal;
varying float vDarken;

uniform sampler2D shadow;
uniform float globalTime;


void main() {

    vec4 tex = texture2D( map, vUv );

    if (tex.w <= 0.99) {
        discard;
    }

    vec2 sUv = vec2(vUv.x-sin(vUv.x*0.3+globalTime)*0.15, vUv.y-cos(vUv.y*0.3+globalTime)*0.15);

    vec4 shd = texture2D( shadow, sUv*1.5 );
    float shadowAdd = 1.0;

    if (shd.w > 0.5) {
        shadowAdd = shd.z*vDarken;
    }

    // light
    vec3 light = vec3(lightPos.x,lightPos.y, -0.8);
    float d = pow(max(0.35,dot(vNormal.xyz, light))*1.3, 1.3);

    gl_FragColor = vec4( tex.xyz*color*d*shadowAdd*(vDarken), tex.w);

}
"""
@leafFS = """
uniform sampler2D map;
uniform sampler2D map2;

uniform vec3 fogColor;
uniform float fogNear;
uniform float fogFar;

varying vec2 vUv;
varying vec3 vColor;
varying vec3 vNormal;

uniform float globalTime;
varying float vSeed;
uniform float black;
varying float vDarken;
uniform vec2 lightPos;


void main() {

    float depth = gl_FragCoord.z / gl_FragCoord.w;
    float fogFactor = smoothstep( fogNear, fogFar, depth );

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

    // light
    vec3 light = vec3(lightPos.x,lightPos.y, -0.8);
    float d = pow(max(0.01,dot(vNormal.xyz, light))*1.5, 1.0);
    float d2 = pow(max(0.05,dot(-vNormal.xyz, light))*1.5, 1.0);

    float t = globalTime;

    gl_FragColor = vec4( mix( (tex.xyz*vColor*(d))*black*vDarken, fogColor, fogFactor ), tex.w);

    if (black > 0.5) {
        gl_FragColor.w *= pow( gl_FragCoord.z, 20.0 );
    }

}
"""
