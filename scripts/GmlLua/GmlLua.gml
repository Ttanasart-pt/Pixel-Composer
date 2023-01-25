function __lua_noti(txt) {
	noti_status(txt);
}

function __lua_draw_surface_general(surface, xx, yy, xs, ys, ang, color, alpha) { 
	draw_surface_ext(surface, xx, yy, xs, ys, ang, color, alpha); 
}
function __lua_draw_surface_transform(surface, xx, yy, rot = 0, xs = 1, ys = 1) { 
	if(argument_count == 5) ys = argument[4];
	draw_surface_ext(surface, xx, yy, xs, ys, rot, c_white, 1); 
}
function __lua_draw_surface_colored(surface, xx, yy, color = c_white, alpha = 1) { 
	draw_surface_ext(surface, xx, yy, 1, 1, 0, color, alpha); 
}
function __lua_draw_surface(surface, xx, yy) { 
	draw_surface(surface, xx, yy); 
}
function __lua_draw_rectangle(x0, y0, x1, y1) { 
	draw_rectangle(x0, y0, x1, y1, false);
}
function __lua_draw_rectangle_outline(x0, y0, x1, y1, thick = 1) { 
	draw_rectangle_border(x0, y0, x1, y1, thick);
}
function __lua_draw_circle(x0, y0, r) { 
	draw_circle(x0, y0, r, false);
}
function __lua_draw_circle_outline(x0, y0, r, thick = 1) { 
	draw_circle_border(x0, y0, r, thick);
}
function __lua_draw_ellipse(x0, y0, x1, y1) { 
	draw_ellipse(x0, y0, x1, y1, false);
}
function __lua_draw_ellipse_outline(x0, y0, x1, y1, thick = 1) { 
	draw_ellipse_border(x0, y0, x1, y1, thick);
}
function __lua_draw_line(x0, y0, x1, y1, thick = 1) { 
	draw_line_width(x0, y0, x1, y1, thick);
}
function __lua_draw_line_round(x0, y0, x1, y1, thick = 1) { 
	draw_line_round(x0, y0, x1, y1, thick);
}
function __lua_draw_pixel(x0, y0) { 
	draw_point(x0, y0);
}
function __lua_blendmode_set(mode) { 
	gpu_set_blendmode(mode);
}
function __lua_blendmode_reset() { 
	gpu_set_blendmode(bm_normal);
}


function __initLua() {
	var lua_functions = [
		["print",	 __lua_noti],
	
		["drawGeneral",		__lua_draw_surface_general],
		["drawBlend",		__lua_draw_surface_colored],
		["drawTransform",	__lua_draw_surface_transform],
		["draw",			__lua_draw_surface],
		
		["clear",		function(color = 0, alpha = 0) { draw_clear_alpha(color, alpha); }],
		["setColor",	draw_set_color],
		["setAlpha",	draw_set_alpha],
	
		["drawRect",			__lua_draw_rectangle],
		["drawRectOutline",		__lua_draw_rectangle_outline],
		["drawCircle",			__lua_draw_circle],
		["drawCircleOutline",	__lua_draw_circle_outline],
		["drawEllipse",			__lua_draw_ellipse],
		["drawEllipseOutline",	__lua_draw_ellipse_outline],
		["drawLine",			__lua_draw_line],
		["drawLineRound",		__lua_draw_line_round],
		["drawPixel",			__lua_draw_pixel],
		
		["colorGetBlue",		colour_get_blue],
		["colorGetGreen",		colour_get_green],
		["colorGetRed",			colour_get_red],
		["colorGetHue",			colour_get_hue],
		["colorGetSaturation",	colour_get_saturation],
		["colorGetValue",		colour_get_value],
		["getColor",			draw_get_colour],
		["getAlpha",			draw_get_alpha],
		["colorMakeHSV",		make_colour_hsv],
		["colorMakeRGB",		make_colour_rgb],
		["colorMerge",			merge_colour],
		
		["setBlend",	__lua_blendmode_set],
		["resetBlend",	__lua_blendmode_reset],
	
		["seed",			random_set_seed],
		["random",			random],
		["randomRange",		random_range],
		["irandom",			irandom],
		["irandomRange",	irandom_range],
	
		["abs",		abs],
		["round",	round],
		["floor",	floor],
		["ceil",	ceil],
		["max",		max],
		["min",		min],
		["clamp",	clamp],
		["lerp",	lerp],
		
		["exp",		exp],
		["ln",		ln],
		["power",	power],
		["sqr",		sqr],
		["sqrt",	sqrt],
		["log2",	log2],
		["log10",	log10],
		["logn",	logn],
		
		["acos",	arccos],
		["asin",	arcsin],
		["atan",	arctan],
		["atan2",	arctan2],
		["cos",		cos],
		["sin",		sin],
		["tan",		tan],
		["dcos",	dcos],
		["dsin",	dsin],
		["dtan",	dtan],
		["dacos",	darccos],
		["dasin",	darcsin],
		["datan",	darctan],
		["datan2",  darctan2],
		["rad",		degtorad],
		["deg",		radtodeg],
		["dot",		dot_product],
		
		["stringLength",		string_length],
		["stringSearch",		string_pos],
		["stringCopy",			string_copy],
		["stringUpper",			string_upper],
		["stringLower",			string_lower],
		["stringReplace",		string_replace],
		["stringReplaceAll",	string_replace_all],
		["stringSplit",			string_split],
	];
	
	globalvar LUA_API;
	LUA_API = ds_map_create();
	
	for( var i = 0; i < array_length(lua_functions); i++ ) {
		LUA_API[? lua_functions[i][0]] = lua_functions[i][1];
	}
}

function lua_create() {
	var state = lua_state_create();
	var k = ds_map_find_first(LUA_API);
	
	repeat(ds_map_size(LUA_API)) {
		lua_add_function(state, k, LUA_API[? k]);
		k = ds_map_find_next(LUA_API, k);
	}
	
	return state;
}

function _lua_error(msg, state) {
	noti_error("A Lua error occurred: " + msg);
}

lua_error_handler = _lua_error;