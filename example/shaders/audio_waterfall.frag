#include <common/common_header.frag>

uniform sampler2D iChannel0;

// Audio Waterfall 
// credits:
// https://www.shadertoy.com/view/Ml3fR7

// ------ START SHADERTOY CODE -----
vec3 pallet(float x){
    if(x<.33){
        return mix(vec3(0,0,0),vec3(1,0,0),smoothstep(0.,.33,x));
    } if(x<.67) {
        return mix(vec3(1,0,0),vec3(1,1,0),smoothstep(.33,.67,x));
    } else {
        return mix(vec3(1,1,0),vec3(1,1,1),smoothstep(.67,1.,x));
    }    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
	fragColor = vec4(pallet(texture(iChannel0, fragCoord / iResolution.xy).x),1);
}
// ------ END SHADERTOY CODE -----

#include <common/main_shadertoy.frag>
