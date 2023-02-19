globalvar BLEND_TYPES;
BLEND_TYPES = [ "Normal", "Add", "Subtract", "Multiply", "Screen", "Overlay", "Hue", "Saturation", "Luminosity", "Maximum", "Minimum" ];

function draw_surface_blend(background, foreground, blend, alpha, _pre_alp = true, _mask = 0, tile = 0) {
	if(!is_surface(background)) return;
	
	var sh = sh_blend_normal
	switch(array_safe_get(BLEND_TYPES, blend)) {
		case "Normal" :		sh = sh_blend_normal	break;
		case "Add" :		sh = sh_blend_add;		break;
		case "Subtract" :	sh = sh_blend_subtract;	break;
		case "Multiply" :	sh = sh_blend_multiply;	break;
		case "Screen" :		sh = sh_blend_screen;	break;
		case "Overlay" :	sh = sh_blend_overlay;	break;
		case "Hue" :		sh = sh_blend_hue;		break;
		case "Saturation" :	sh = sh_blend_sat;		break;
		case "Luminosity" :	sh = sh_blend_luma;		break;
		
		case "Maximum" :	sh = sh_blend_max;		break;
		case "Minimum" :	sh = sh_blend_min;		break;
		default: return;
	}
	
	var uniform_foreground	= shader_get_sampler_index(sh, "fore");
	var uniform_mask		= shader_get_sampler_index(sh, "mask");
	var uniform_dim_rat		= shader_get_uniform(sh, "dimension");
	var uniform_is_mask		= shader_get_uniform(sh, "useMask");
	var uniform_alpha		= shader_get_uniform(sh, "opacity");
	var uniform_tile		= shader_get_uniform(sh, "tile_type");
	var uniform_presalpha	= shader_get_uniform(sh, "preserveAlpha");
	
	var surf	= surface_get_target();
	var surf_w  = surface_get_width(surf);
	var surf_h  = surface_get_height(surf);
	
	if(is_surface(foreground)) {
		shader_set(sh);
		texture_set_stage(uniform_foreground,		surface_get_texture(foreground));
		if(_mask) texture_set_stage(uniform_mask,	surface_get_texture(_mask));
		shader_set_uniform_i(uniform_is_mask, _mask != 0? 1 : 0);
		shader_set_uniform_f_array(uniform_dim_rat,	[ surface_get_width(background) / surface_get_width(foreground), surface_get_height(background) / surface_get_height(foreground) ]);
		shader_set_uniform_f(uniform_alpha,	alpha);
		shader_set_uniform_i(uniform_presalpha,	_pre_alp);
		shader_set_uniform_i(uniform_tile,	tile);
	}
	
	BLEND_ALPHA
	draw_surface_stretched_safe(background, 0, 0, surf_w, surf_h);
	BLEND_NORMAL
	shader_reset();
}