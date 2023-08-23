varying float v_LightDepth;

void main() {
    gl_FragColor = vec4(v_LightDepth, v_LightDepth, v_LightDepth, 1.);
    //gl_FragColor = vec4(1.);
}
