#include <common/common_header.frag>

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;

// ------ START SHADERTOY CODE -----
float fftLow = 0.;
float fftMid = 0.;
float fftHigh = 0.;

vec2 barrelDistortion(vec2 coord, float strength) {
    vec2 cc = coord - 0.5;
    float dist = dot(cc, cc);
    return coord + cc * dist * strength;
}

// Star shape function
float star(vec2 uv, float size, float points) {
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);

    // Add optical flares
    float flare = 0.0;
    float rot = iTime / 2.;
    for(float i = 0.0; i < 6.0; i++) {
        float flareAngle = (i / 6.0) * 6.28318 + rot;
        vec2 flareDir = vec2(cos(flareAngle), sin(flareAngle));
        float flareDot = max(0.0, dot(normalize(uv), flareDir));
        flare += pow(flareDot, 32.0) * exp(-radius * 2.0) * .1;
    }
    
    return flare;
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord/iResolution.xy;
    float time = iTime * 0.5;
    
    // Sample low and high frequencies
    for (float x=0.0; x<0.1; x+=0.01)
        fftLow += texture(iChannel0, vec2(x,0.25)).x;
    for (float x=0.4; x<0.5; x+=0.01)
        fftMid += texture(iChannel0, vec2(x,0.25)).x;
    for (float x=0.8; x<0.9; x+=0.01)
        fftHigh += texture(iChannel0, vec2(x,0.25)).x;
    fftLow /= 10.;
    fftMid /= 10.;
    fftHigh /= 10.;
    
    // Dynamic distortion
    float distortionStrength = fftLow * 2.0 + sin(time) * fftHigh * 0.5;
    vec2 distortedUV = barrelDistortion(uv, distortionStrength);
    
    // Add chromatic aberration
    float ca = fftHigh * 0.02;
    vec3 color;
    color.r = texture(iChannel1, distortedUV + vec2(ca, 0.0)).r;
    color.g = texture(iChannel1, distortedUV).g;
    color.b = texture(iChannel1, distortedUV - vec2(ca, 0.0)).b;
    
    // Color manipulation based on audio
    vec3 hsv = rgb2hsv(color);
    hsv.x += fftLow * 0.2 + time * 0.1; // Hue shift
    hsv.y *= 1.0 + fftHigh * 0.5;       // Saturation boost
    color = hsv2rgb(hsv);

    // Add floating star
    vec2 starCenter = vec2(
        0.5 + cos(time * 0.7) * 0.3 * (1.0 + fftMid),
        0.5 + sin(time * 0.5) * 0.3 * (1.0 + fftHigh)
    );
    vec2 starUV = uv - starCenter;
    float starSize = 0.05 * (1.0 + fftMid * 2.0);
    float starGlow = star(starUV, starSize, 6.0);
    
    // Star color
    vec3 starColor = hsv2rgb(vec3(
        time * 0.1 + fftHigh * 0.5,  // Hue
        0.8,                         // Saturation
        1.0                          // Value
    ));
    
    // Add glow effect
    float glow = starGlow * (1. + fftMid * 100.0);
    color += starColor * glow;
    
    // Add subtle pulsing vignette
    vec2 vigUV = uv * 2.0 - 1.0;
    float vig = 1.0 - dot(vigUV, vigUV) * (0.5 + fftLow * 0.5);
    color *= vig;
    
    fragColor = vec4(color, 1.0);
}
// ------ END SHADERTOY CODE -----

#include <common/main_shadertoy.frag>
