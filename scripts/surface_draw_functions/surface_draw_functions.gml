function __channel_pre(surf) {
	var f = surface_get_format(surf);
	
	switch(f) {
		case surface_r8unorm	 : shader_set(sh_draw_r8); return;
		case surface_r16float	 : shader_set(sh_draw_r16); return;
		case surface_r32float	 : shader_set(sh_draw_r32); return;
	}
}

function __channel_pos(surf) {
	var f = surface_get_format(surf);
	
	switch(f) {
		case surface_r8unorm	 :
		case surface_r16float	 :
		case surface_r32float	 :
			shader_reset();
			return;
	}
}