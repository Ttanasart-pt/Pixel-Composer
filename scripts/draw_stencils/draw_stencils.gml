function gpu_set_stencil_compare(_type, _ref) {
	gpu_set_stencil_func(_type);
	gpu_set_stencil_ref(_ref);
}

function gpu_stencil_roundrect_start(x0, y0, x1, y1, rad, colr = c_white) {
	gpu_set_stencil_enable(true);
	
	draw_clear_stencil(0);
	gpu_set_stencil_pass(stencilop_replace);
	
	gpu_set_stencil_compare(cmpfunc_greater, 128);
	draw_set_color_alpha(colr);
	draw_roundrect_ext(x0, y0, x1, y1, rad, rad, false);
	
	gpu_set_stencil_compare(cmpfunc_less, 64);
}

function gpu_stencil_roundrect_end() {
	gpu_set_stencil_enable(false);
}