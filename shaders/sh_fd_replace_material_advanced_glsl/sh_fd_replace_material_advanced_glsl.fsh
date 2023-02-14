varying vec2 v_vTexcoord;
varying vec2 v_vScreencoord;
varying vec4 color;

uniform sampler2D texture_material_0;

void main() {
    vec4 destination = texture2D(texture_material_0, v_vScreencoord);
    vec4 source = color * texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor = source * vec4(source.aaa, 1.0) + destination * (1.0 - source.aaaa);
}
