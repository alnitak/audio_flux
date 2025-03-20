#include <common/common_header.frag>

uniform sampler2D iChannel0;

// Dancing Flutter
// credits: Marco Bavagnoli

// ------ START SHADERTOY CODE -----
// Refs Inigo Quilez
// http://iquilezles.org/articles/distfunctions/
// http://iquilezles.org/articles/distfunctions2d/

// https://inspirnathan.com/posts/53-shadertoy-tutorial-part-7/ @method #3

#define MAX_MARCHING_STEPS 255.
#define MIN_DIST 0.0
#define MAX_DIST 15.0
#define PRECISION 0.001
#define EPSILON 0.0005
#define PI 3.14159265359
#define DISTANCE_BIAS 0.2
#define COLOR_BACKGROUND vec3(0., 0., 0.)
#define COLOR_AMBIENT vec3(0.15, 0.15, 0.15)

#define MAT_RED vec3(1.,0.,0.)
#define MAT_1 vec3(0.412,0.718,0.976)
#define MAT_2 vec3(0.259,0.647,0.965)
#define MAT_3 vec3(0.055,0.278,0.627)
#define MAT_4 vec3(1. + 0.7*mod(floor(p.x) + floor(p.z), 2.0))


float dot2( in vec3 v ) { return dot(v,v); }

float fftLow = 0.;
float fftHigh = 0.;

///////////////////////
// Primitives
///////////////////////
float sdPlane(vec3 p)
{
    return p.y;
}

float sdSphere(vec3 p, float r, vec3 offset)
{
    return length(p - offset) - r;
}

// Distance from p to box whose half-dimensions are b.x, b.y, b.z
float sdBox( vec3 p, vec3 b )
{
    vec3 d = abs(p) - b;
    return min( max(d.x,max(d.y,d.z) ),0.0) + length(max(d,0.0));
}

// Distance from p to box of half-dimensions b.x,y,z plus buffer radius r
float udRoundBox( vec3 p, vec3 b, float r)
{
    return length( max(abs(p)-b,0.0) )-r;
}


float udTriangle( in vec3 p, in vec3 v1, in vec3 v2, in vec3 v3 )
{
    vec3 v21 = v2 - v1; vec3 p1 = p - v1;
    vec3 v32 = v3 - v2; vec3 p2 = p - v2;
    vec3 v13 = v1 - v3; vec3 p3 = p - v3;
    vec3 nor = cross( v21, v13 );

    return sqrt( (sign(dot(cross(v21,nor),p1)) + 
                  sign(dot(cross(v32,nor),p2)) + 
                  sign(dot(cross(v13,nor),p3))<2.0) 
                  ?
                  min( min( 
                  dot2(v21*clamp(dot(v21,p1)/dot2(v21),0.0,1.0)-p1), 
                  dot2(v32*clamp(dot(v32,p2)/dot2(v32),0.0,1.0)-p2) ), 
                  dot2(v13*clamp(dot(v13,p3)/dot2(v13),0.0,1.0)-p3) )
                  :
                  dot(nor,p1)*dot(nor,p1)/dot2(nor) );
}

float sdTriangle( in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2 )
{
    vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
    vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
    vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
    vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
    return -sqrt(d.x)*sign(d.y);
}

float udQuad( vec3 p, vec3 a, vec3 b, vec3 c, vec3 d )
{
  vec3 ba = b - a; vec3 pa = p - a;
  vec3 cb = c - b; vec3 pb = p - b;
  vec3 dc = d - c; vec3 pc = p - c;
  vec3 ad = a - d; vec3 pd = p - d;
  vec3 nor = cross( ba, ad );

  return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(dc,nor),pc)) +
     sign(dot(cross(ad,nor),pd))<3.0)
     ?
     min( min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
     dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}


///////////////////////
// Matrix
///////////////////////
mat2 rotate2d(float theta) {
  float s = sin(theta), c = cos(theta);
  return mat2(c, -s, s, c);
}

// Rotation matrix around the X axis.
mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

// Rotation matrix around the Y axis.
mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

// Rotation matrix around the Z axis.
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}

// Identity matrix.
mat3 identity() {
    return mat3(
        vec3(1, 0, 0),
        vec3(0, 1, 0),
        vec3(0, 0, 1)
    );
}


// This function comes from glsl-rotate https://github.com/dmnsgn/glsl-rotate/blob/main/rotation-3d.glsl
mat4 rotation3d(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(
    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0
  );
}
vec3 rotate(vec3 v, vec3 axis, float angle) {
  mat4 m = rotation3d(axis, angle);
  return (m * vec4(v, 1.0)).xyz;
}



///////////////////////
// Boolean Operators
///////////////////////
vec4 opUnion(vec4 d1, vec4 d2) { 
  return (d1.x < d2.x) ? d1 : d2;
}

float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0., 1. );
  return mix( d2, d1, h ) - k*h*(1.-h);
}

vec4 opSmoothUnion(vec4 d1, vec4 d2, float k ) 
{
  float h = clamp(0.5 + 0.5*(d1.x-d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw,h);
  float d = mix(d1.x, d2.x, h) - k*h*(1.-h); 
   
  return vec4(d, c);
}



vec4 opIntersection(vec4 d1, vec4 d2) {
  return (d1.x > d2.x) ? d1 : d2;
}

float opSmoothIntersection(float d1, float d2, float k) {
  float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
  return mix( d2, d1, h ) + k*h*(1.0-h);
}

vec4 opSmoothIntersection(vec4 d1, vec4 d2, float k ) 
{
  float h = clamp(0.5 - 0.5*(d1.x-d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw, h);
  float d = mix(d1.x, d2.x, h) + k*h*(1.-h);
   
  return vec4(d, c);
}



vec4 opSubtraction(vec4 d1, vec4 d2) {
  return d1.x > -d2.x ? d1 : vec4(-d2.x, d2.yzw);
}

float opSmoothSubtraction(float d1, float d2, float k) {
  float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
  return mix( d2, -d1, h ) + k*h*(1.0-h);
}
 
vec4 opSmoothSubtraction(vec4 d1, vec4 d2, float k) 
{
  float h = clamp(0.5 - 0.5*(d1.x+d2.x)/k, 0., 1.);
  vec3 c = mix(d1.yzw, d2.yzw, h);
  float d = mix(d1.x, -d2.x, h ) + k*h*(1.-h);
   
  return vec4(d, c);
}



float opExtrusion(in vec3 p, in float sdf, in float h) {
  vec2 w = vec2(sdf, abs(p.z) - h);
  return min(max(w.x, w.y), 0.0) + length(max(w, 0.0));
}


vec4 flutterLogo(vec3 p) {
    float scale = 0.04;
    float extrusion = 0.35;
    float roundness = 0.03;
    
    
    vec3 s = vec3(8., 0., 5.);
    //vec3 id = round(p/s); // can we use this id here?
    //p = p - s*id;
        
    vec2 v1  = scale * vec2(50., 100. - 0.);
    vec2 v2  = scale * vec2(80., 100. - 0.);
    vec2 v3  = scale * vec2(0.,  100. - 50.);
    vec2 v4  = scale * vec2(50., 100. - 46.138);
    vec2 v5  = scale * vec2(80., 100. - 46.138);
    vec2 v6  = scale * vec2(38.086, 100. - 57.673);
    vec2 v7  = scale * vec2(15.25,  100. - 65.396);
    vec2 v8  = scale * vec2(22.873, 100. - 73.078);
    vec2 v9  = scale * vec2(53.335, 100. - 73.074);
    vec2 v10 = scale * vec2(38.095, 100. - 88.452);
    vec2 v11 = scale * vec2(49.507, 100. - 100.);
    vec2 v12 = scale * vec2(80.,    100. - 100.);
    
    float t1 = sdTriangle( p.xy, v1, v7, v3 );
    float t2 = sdTriangle( p.xy, v1, v2, v7 );
    float t3 = sdTriangle( p.xy, v4, v9, v6 );
    float t4 = sdTriangle( p.xy, v4, v5, v9 );
    float t5 = sdTriangle( p.xy, v6, v9, v8 );
    float t6 = sdTriangle( p.xy, v8, v9, v10 );
    float t7 = sdTriangle( p.xy, v10, v9, v11 );
    float t8 = sdTriangle( p.xy, v9, v12, v11 );
    

    vec4 sdf1 = vec4(opExtrusion(p, t1, extrusion) - roundness, MAT_1);
    vec4 sdf2 = vec4(opExtrusion(p, t2, extrusion) - roundness, MAT_1);
    vec4 sdf3 = vec4(opExtrusion(p, t3, extrusion) - roundness, MAT_1);
    vec4 sdf4 = vec4(opExtrusion(p, t4, extrusion) - roundness, MAT_1);
    
    vec4 sdf5 = vec4(opExtrusion(p, t5, extrusion) - roundness, MAT_2);
    vec4 sdf6 = vec4(opExtrusion(p, t6, extrusion) - roundness, MAT_2);
    
    vec4 sdf7 = vec4(opExtrusion(p, t7, extrusion) - roundness, MAT_3);
    vec4 sdf8 = vec4(opExtrusion(p, t8, extrusion) - roundness, MAT_3);
    
    vec4 res = opUnion(sdf1, sdf2);
    res = opUnion(res, sdf3);
    res = opUnion(res, sdf4);
    res = opUnion(res, sdf5);
    res = opUnion(res, sdf6);
    res = opUnion(res, sdf7);
    res = opUnion(res, sdf8);
    return res;
}

vec4 scene(vec3 p) {

  vec4 center = vec4(sdSphere(p, .2, vec3(0., 0., 0.)), MAT_RED);
  vec4 plane = vec4(sdPlane(p), MAT_4);
  
  vec3 p1 = rotate(
      vec3(p.x*fftHigh, p.y, p.z), 
      vec3(0., 1., 0.),
      0.
      )
      + vec3(2., sin(fftLow) - .7, -1.);
  vec4 flutter = flutterLogo(p1);
  
  
  vec4 res = opSmoothUnion(plane, flutter, 0.1);
  return res;
}

vec4 rayMarch(vec3 ro, vec3 rd) {
  float depth = MIN_DIST;
  vec4 d; // .yzw color   .x distance ray has travelled

  for (float i = 0.; i < MAX_MARCHING_STEPS; i++) {
    vec3 p = ro + depth * rd;
    d = scene(p);
    depth += d.x * DISTANCE_BIAS;
    if (d.x < PRECISION || depth > MAX_DIST) break;
  }
  
  d.x = depth;
  
  return d;
}

vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1., -1.) * EPSILON;
    return normalize(
      e.xyy * scene(p + e.xyy).x +
      e.yyx * scene(p + e.yyx).x +
      e.yxy * scene(p + e.yxy).x +
      e.xxx * scene(p + e.xxx).x);
}

mat3 camera(vec3 cameraPos, vec3 lookAtPoint) {
	vec3 cd = normalize(lookAtPoint - cameraPos);
	vec3 cr = normalize(cross(vec3(0, 1, 0), cd));
	vec3 cu = normalize(cross(cd, cr));
	
	return mat3(-cr, cu, -cd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = (fragCoord-.5*iResolution.xy)/(iResolution.y*-1.);
  vec2 mouseUV = iMouse.xy/iResolution.xy;
  
  for (float x=0.; x<0.1; x+=0.01)
      fftLow += texture( iChannel0, vec2(x,0.25) ).x;
  fftLow /= 10.;
  
  for (float x=0.1; x<0.8; x+=0.01)
      fftHigh += texture( iChannel0, vec2(x,0.25) ).x;
  fftHigh /= 70.;
  fftHigh = 1. - clamp(fftHigh, 0., .5);
  
  if (mouseUV == vec2(0.0)) 
      mouseUV = vec2(0.0, 0.0); // trick to center mouse on page load
      
  vec3 col = vec3(0);
  vec3 lp = vec3(0., 2.4, 0.);
  vec3 ro = vec3(1, -1.5, 1); // ray origin that represents camera position
  
  float cameraRadius = 4.;
  ro.yz = ro.yz * cameraRadius * rotate2d(mix(-PI/2., PI/2., clamp(mouseUV.y, 0., .15)));
  ro.xz = ro.xz * rotate2d(mix(-PI, PI, mouseUV.x)) + vec2(lp.x, lp.z);

  vec3 rd = camera(ro, lp) * normalize(vec3(uv, -1)); // ray direction

  vec4 d = rayMarch(ro, rd); // .yzw color   .x signed distance value to closest object

  if (d.x > MAX_DIST) {
    col = COLOR_BACKGROUND; // ray didn't hit anything
  } else {
    vec3 p = ro + rd * d.x; // point discovered from ray marching
    vec3 normal = calcNormal(p); // surface normal

    vec3 lightPosition = vec3(0., 5., 2.);
    vec3 lightDirection = normalize(lightPosition - p) * .65; // The 0.65 is used to decrease the light intensity a bit

    float dif = clamp(dot(normal, lightDirection), 0., 1.) * 0.5 + 0.5; // diffuse reflection mapped to values between 0.5 and 1.0

    col = dif * d.yzw + COLOR_AMBIENT;
    
  }

  fragColor = vec4(col, 1.0);
}
// ------ END SHADERTOY CODE -----

#include <common/main_shadertoy.frag>