function __channel_pre(surf) {
	var f = surface_get_format(surf);
	
	switch(f) {
		case surface_r8unorm	 :
		case surface_r16float	 :
		case surface_r32float	 :
			shader_set(sh_draw_single_channel);
			return;
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