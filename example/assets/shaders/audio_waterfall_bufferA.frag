#include <common/common_header.frag>

uniform sampler2D iChannel0;
uniform sampler2D iChannel1;

// Audio Waterfall 
// credits:
// https://www.shadertoy.com/view/Ml3fR7

// ------ START SHADERTOY CODE -----
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if(iResolution.y-fragCoord.y<1.){
    	fragColor = vec4(texture(iChannel0, vec2(.5*fragCoord.x/iResolution.x,.25)).x);
    } else {
    	fragColor = texture(iChannel1, (fragCoord+vec2(0,1)) / iResolution.xy);
    }
    
}
// ------ END SHADERTOY CODE -----

#include <common/main_shadertoy.frag>
