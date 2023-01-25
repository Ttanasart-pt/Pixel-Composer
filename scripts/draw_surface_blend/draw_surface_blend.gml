globalvar BLEND_TYPES;
BLEND_TYPES = [ "Normal", "Add", "Subtract", "Subtract keep alpha", "Multiply", "Multiply keep Alpha", "Screen", "Screen keep Alpha", "Contrast", "Overlay", "Maximum", "Minimum" ];

enum BLEND_MODE {
	normal,
	add,
	
	subtract,
	subtract_alpha,
	
	multiply,
	multiply_alpha,
	
	screen,
	screen_alpha,
	
	contrast,
	overlay,
	
	maxx,
	minn,
}

function draw_surface_blend(background, foreground, blend, alpha, _mask = 0, tile = 0) {
	if(!is_surface(background)) return;
	
	var sh = sh_blend_normal
	switch(blend) {
		case BLEND_MODE.normal :			sh = sh_blend_normal			break;
		case BLEND_MODE.add	:				sh = sh_blend_add;				break;
		case BLEND_MODE.subtract :			sh = sh_blend_subtract;			break;
		case BLEND_MODE.subtract_alpha :	sh = sh_blend_subtract_alpha;	break;
		case BLEND_MODE.multiply :			sh = sh_blend_multiply;			break;
		case BLEND_MODE.multiply_alpha :	sh = sh_blend_multiply_alpha;	break;
		case BLEND_MODE.screen :			sh = sh_blend_screen;			break;
		case BLEND_MODE.screen_alpha :		sh = sh_blend_screen_alpha;		break;
		case BLEND_MODE.contrast :			sh = sh_blend_contrast;			break;
		case BLEND_MODE.overlay :			sh = sh_blend_overlay;			break;
		case BLEND_MODE.maxx :				sh = sh_blend_max;				break;
		case BLEND_MODE.minn :				sh = sh_blend_min;				break;
	}
	
	var uniform_foreground	= shader_get_sampler_index(sh, "fore");
	var uniform_mask		= shader_get_sampler_index(sh, "mask");
	var uniform_dim_rat		= shader_get_uniform(sh, "dimension");
	var uniform_is_mask		= shader_get_uniform(sh, "useMask");
	var uniform_alpha		= shader_get_uniform(sh, "opacity");
	var uniform_tile		= shader_get_uniform(sh, "tile_type");
	
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
		shader_set_uniform_i(uniform_tile,	tile);
	}
	
	BLEND_OVERRIDE
	draw_surface_stretched_safe(background, 0, 0, surf_w, surf_h);
	BLEND_NORMAL
	shader_reset();
}