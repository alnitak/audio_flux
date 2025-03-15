#include <common/common_header.frag>

uniform sampler2D iChannel1;

// Smoke Rings
// credits:
// https://www.shadertoy.com/view/dlK3RW

// ------ START SHADERTOY CODE -----

  // Adapted from https://www.shadertoy.com/view/4dVXDt
  
  
  // Use Microphone or Noise
  #define USEMIC
  
  // 3 color modes
  #define COLOR_MODE 3 // 1-3
 
  
  #define AMP_FACT 0.2
  #define uRingsN 18
  #define uWidth 0.2
  #define uSize 0.2
  
  #ifdef USEMIC
   #define IN_DATA   iChannel1
   #define NOISE_AMP 0.2
  #else
   #define IN_DATA   iChannel0
   #define NOISE_AMP 0.0
  #endif
  
  const vec4 kHue = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  #define hue2rgb(h) clamp(abs(fract(vec3(h) + kHue.xyz) * 6.0 - kHue.www) - kHue.xxx, 0.0, 1.0)
  #define _hls2rgb(x,y,z) z + y * (clamp(abs(mod(x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0) - 0.5) * (1.0 - abs(2.0 * z - 1.0))
  #define hsv2rgb(x,y,z) z * mix(kHue.xxx, clamp(abs(fract(vec3(x) + kHue.xyz) * 6.0 - kHue.www) - kHue.xxx, 0.0, 1.0), y)
  #define hsl2rgb(x,y,z) z * mix(kHue.xxx, clamp(abs(fract(vec3(x) + kHue.xyz) * 6.0 - kHue.www) - kHue.xxx, 0.0, 1.0), (1.0 - abs(2.0 * y - 1.0)))
  

  float waves(vec2 coord, vec2 coordMul1, vec2 coordMul2, vec2 phases, vec2 timeMuls) {
      return 0.5 * (sin(dot(coord, coordMul1) + timeMuls.x * iTime + phases.x) + cos(dot(coord, coordMul2) + timeMuls.y * iTime + phases.y));
  }
  
  const vec2 noiseDir1 = vec2(1.0, 0.0019);
  const vec2 noiseDir2 = vec2(1.0, 0.8000);
  
  float ringMultiplier(vec2 uv, float amp, float phase, float off, float power) {

#ifdef USEMIC
    vec3 noise1 = texture(IN_DATA, noiseDir1 * phase            ).r * vec3(1.0);
#else
    vec3 noise1 = texture(IN_DATA, noiseDir1 * phase            ).rgb;
#endif
    vec3 noise2 = texture(IN_DATA, noiseDir2 - noiseDir1 * phase).rgb;
    vec2 d = vec2(off, 0.5);
    d.x += 0.6 * waves(
      uv,
      vec2( 1.9 + 0.4 * noise1.r, 1.9 + 0.4 * noise1.g ) * 3.3,
      vec2( 5.7 + 1.4 * noise1.b, 5.7 + 1.4 * noise2.r ) * 2.8,
      vec2( noise1.r - noise2.r,  noise1.g + noise2.b  ) * 5.0,
      vec2( 1.1 )
    );
    d.y += 0.4 * waves(
      uv,
      vec2( -1.7 - 0.9 * noise2.g,  1.7 + 0.9 * noise2.b ) * 3.1,
      vec2(  5.9 + 0.8 * noise1.g, -5.9 - 0.8 * noise1.b ) * 3.7,
      vec2( noise1.g + noise2.g,    noise1.b - noise2.r  ) * 5.0,
      vec2( -0.9 )
    );
    float a = noise1.r * NOISE_AMP + 0.6 * (abs(d.x) + abs(d.y));
    vec2 duv = uv + normalize(d) * a * amp * AMP_FACT;
    return smoothstep( -power, power, pow(abs(length(duv) - uSize), noise1.r * noise2.r));
  }
  
  
  vec3 getColor(vec2 uv, float s){
    return vec3(
      dot(uv, vec2(cos(iTime + s), sin(iTime -s))),
      dot(uv, vec2(cos(iTime + 1.75* s),sin(iTime +s))),
      dot(uv, vec2(sin(iTime + s)))
    );
  }
  
  
  
  vec3 hue(vec2 uv, float h, float speed){
    return vec3(0.5) + hue2rgb(h + (dot(uv,vec2(0.5)) + iTime) * speed);  
  }
  
  void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 vuv = fragCoord/iResolution.xx;
    vec2 uv = vec2( 0.5, 0.260 ) - vuv;
    vec3 color = vec3( 1.0 );
    float power = pow( uWidth * 0.1, uWidth );
    float size = uSize * 0.38;
    
 #if (COLOR_MODE == 1)
    vec3 t1 = getColor(uv, 2.), t2 = 1. - getColor(uv, -2.1);
 #elif (COLOR_MODE == 2)
    vec3 t1 = .65 - hue(uv, 0.6, 0.005), t2 = .72 - hue(uv.yx, 0.8, 0.05);
 #elif (COLOR_MODE == 3)
    vec3 t1 = 1. - vec3(0.1, 0.5, 0.7), t2 = 1. - vec3(0.8, 0.1, 0.8);
 #else
    vec3 t1 = 1. - vec3(0.9, 0.5, 0.3), t2 = 1. - vec3(0.8, 0.1, 0.2);
 #endif
 
    float xoff = 0.5 * (0.9 * cos(iTime * 0.6 + 1.1) + 0.4 * cos(iTime * 2.4));
    for (int i = 0; i < uRingsN; i++) {
      float frac = float(i) / float(uRingsN);
      float amp = ringMultiplier(uv,
                                 0.1 + pow(frac, 3.0) * 0.7,
                                 pow(1.0 - frac, uWidth) * 0.09 + iTime * 0.0001,
                                 xoff,
                                 power);
      color *= mix(mix(t1, t2, pow(frac, 3.0)), vec3(1.0), pow(amp, 2.5));
    }
    color = 1. - color;
    fragColor = vec4(color, length(color));
  }
// ------ END SHADERTOY CODE -----

#include <common/main_shadertoy.frag>
