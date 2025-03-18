globalvar BLEND_TYPES;
BLEND_TYPES = [ 
	"Normal", "Replace", 
	-1,
	"Multiply", "Color Burn", "Linear Burn", "Minimum", 
	-1, 
	"Add", "Screen", "Color Dodge", "Maximum", 
	-1,
	"Overlay", "Soft Light", "Hard Light", "Vivid Light", "Linear Light", "Pin Light", 
	-1,
	"Difference", "Exclusion", "Subtract", "Divide", 
	-1,
	"Hue", "Saturation", "Luminosity", 
];

enum BLEND_MODE {
	normal       = 0,
	replace      = 1,
	//             2
	multiply     = 3,
	color_burn   = 4,
	linear_burn  = 5,
	minimum      = 6,
	//             7
	add          = 8,
	screen       = 9,
	color_dodge  = 10,
	maximum      = 11,
	//             12
	overlay      = 13,
	soft_light   = 14,
	hard_light   = 15,
	vivid_light  = 16,
	linear_light = 17,
	pin_light    = 18,
	//             19
	difference   = 20,
	exclusion    = 21,
	subtract     = 22,
	divide       = 23,
	//             24
	hue          = 25,
	saturation   = 26,
	luminosity   = 27,
}

global.node_blend_keys = array_create_ext(array_length(BLEND_TYPES), function(i) /*=>*/ {return string_lower(BLEND_TYPES[i])});

function draw_surface_blend(background, foreground, blend = BLEND_MODE.normal, alpha = 1, _pre_alp = true, _mask = 0, tile = 0) {
	if(!is_surface(background)) return;
	
	var sh = sh_blend_normal
	switch(blend) {
		case BLEND_MODE.normal :       sh = sh_blend_normal        break;
		case BLEND_MODE.replace :      sh = sh_blend_replace;      break;
		
		case BLEND_MODE.multiply :     sh = sh_blend_multiply;     break;
		case BLEND_MODE.color_burn :   sh = sh_blend_color_burn;   break;
		case BLEND_MODE.linear_burn :  sh = sh_blend_linear_burn;  break;
		case BLEND_MODE.minimum :      sh = sh_blend_min;          break;
		
		case BLEND_MODE.add :          sh = sh_blend_add;          break;
		case BLEND_MODE.screen :       sh = sh_blend_screen;       break;
		case BLEND_MODE.color_dodge :  sh = sh_blend_color_dodge;  break;
		// case BLEND_MODE. :             sh = sh_blend_linear_dodge; break;
		case BLEND_MODE.maximum :      sh = sh_blend_max;          break;
		
		case BLEND_MODE.overlay :      sh = sh_blend_overlay;      break;
		case BLEND_MODE.soft_light :   sh = sh_blend_soft_light;   break;
		case BLEND_MODE.hard_light :   sh = sh_blend_hard_light;   break;
		case BLEND_MODE.vivid_light :  sh = sh_blend_vivid_light;  break;
		case BLEND_MODE.linear_light : sh = sh_blend_linear_light; break;
		case BLEND_MODE.pin_light :    sh = sh_blend_pin_light;    break;
		
		case BLEND_MODE.difference :   sh = sh_blend_difference;   break;
		case BLEND_MODE.exclusion :    sh = sh_blend_exclusion;    break;
		case BLEND_MODE.subtract :     sh = sh_blend_subtract;     break;
		case BLEND_MODE.divide :       sh = sh_blend_divide;       break;
		
		case BLEND_MODE.hue :          sh = sh_blend_hue;          break;
		case BLEND_MODE.saturation :   sh = sh_blend_sat;          break;
		case BLEND_MODE.luminosity :   sh = sh_blend_luma;         break;
		
		// case "XOR" :			sh = sh_blend_xor;				break;
		default: return;
	}
	
	var surf	= surface_get_target();
	var surf_w  = surface_get_width_safe(surf);
	var surf_h  = surface_get_height_safe(surf);
	
	if(is_surface(foreground)) {
		shader_set(sh);
		shader_set_surface("fore",		foreground);
		shader_set_surface("mask",		_mask);
		shader_set_i("useMask",			is_surface(_mask));
		shader_set_f("dimension",		surface_get_width_safe(background) / surface_get_width_safe(foreground), surface_get_height_safe(background) / surface_get_height_safe(foreground));
		shader_set_f("opacity",			alpha);
		shader_set_i("preserveAlpha",	_pre_alp);
		shader_set_i("tile_type",		tile);
	}
	
	BLEND_OVERRIDE
	draw_surface_stretched_safe(background, 0, 0, surf_w, surf_h);
	BLEND_NORMAL
	shader_reset();
}

function draw_surface_blend_ext(bg, fg, _x, _y, _sx = 1, _sy = 1, _rot = 0, _col = c_white, _alpha = 1, _blend = 0, _pre_alp = false) {
	surface_set_shader(blend_temp_surface);
		shader_set_interpolation(fg);
		draw_surface_ext_safe(fg, _x, _y, _sx, _sy, _rot, _col, 1);
	surface_reset_shader();
	
	draw_surface_blend(bg, blend_temp_surface, _blend, _alpha, _pre_alp);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

global.BLEND_TYPES_18 = [ 
	"Normal",  "Add",     "Subtract",   "Multiply",   "Screen", 
	"Overlay", "Hue",     "Saturation", "Luminosity", "Maximum", 
	"Minimum", "Replace", "Difference", 
];
