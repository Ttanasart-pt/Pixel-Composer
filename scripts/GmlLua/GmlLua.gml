function __lua_noti(txt) {
	noti_status(txt);
}

function __lua_draw_surface_general(surface, xx, yy, xs = 1, ys = 1, rot = 0, color = c_white, alpha = 1) { 
	draw_surface_ext(surface, xx, yy, xs, ys, rot, color, alpha); 
}
function __lua_draw_surface_transform(surface, xx, yy, xs = 1, ys = 1, rot = 0) { 
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

function __lua_set_color(color = c_white) {
	draw_set_color(color);
}
function __lua_set_alpha(alpha = 1) {;
	draw_set_alpha(alpha);
}
function __lua_set_color_alpha(color = c_white, alpha = 1) {
	draw_set_color(color);
	draw_set_alpha(alpha);
}

function __lua_color_make_rgb(r, g, b, normalize = false) {
	if(normalize)
		return make_color_rgb(r * 255, g * 255, b * 255);
	return make_color_rgb(r, g, b);
}

function __lua_color_make_hsv(h, s, v, normalize = false) {
	if(normalize)
		return make_color_hsv(h * 255, s * 255, v * 255);
	return make_color_hsv(h, s, v);
}

function __lua_random(from = 0, to = 1) {
	return random_range(from, to);
}

function __lua_irandom(from = 0, to = 1) {
	return irandom_range(from, to);
}

function __lua_clamp(number, minn = 0, maxx = 1) {
	return clamp(number, minn, maxx);
}

function __lua_string_search(str, sch) {
	return string_pos(sch, str);
}

function __initLua() {
	global.lua_functions = [
		"Draw Surface",
		["draw",			__lua_draw_surface, "draw(surface, x, y)", "Draw surface, with top left at (x, y).", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"]]],
		["drawBlend",		__lua_draw_surface_colored, "drawBlend(surface, x, y, color = white, alpha = 1)", "Draw surface with color blending.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["color", "color", "Blend color"], ["alpha", "number", "Alpha (tranparency)"]]],
		["drawTransform",	__lua_draw_surface_transform, "drawTransform(surface, x, y, xs = 1, ys = 1, rot = 0)", "Draw surface with extra transformation.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["xs", "number", "x scale"], ["ys", "number", "y scale"], ["rot", "number", "Rotation"]]],
		["drawGeneral",		__lua_draw_surface_general, "drawGeneral(surface, x, y, xs = 1, ys = 1, rot = 0, color = white, alpha = 1)", "Draw surface with all the controls.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["xs", "number", "x scale"], ["ys", "number", "y scale"], ["rot", "number", "Rotation"], ["color", "color", "Blend color"], ["alpha", "number", "Alpha (tranparency)"]]],
		
		"Draw Functions",
		["clear",		function(color = 0, alpha = 0) { draw_clear_alpha(color, alpha); }, "clear()", "Clear surface, need to be call every frame to refresh the surface. "],
		["setColor",		__lua_set_color, "setColor(color = white)", "Set current drawing color.", 
			[["color", "color", "Draw color"], ]],
		["setAlpha",		__lua_set_alpha, "setAlpha(alpha = 1)", "Set current drawing alpha.", 
			[["alpha", "number", "Draw alpha"], ]],
		["setColorAlpha",	__lua_set_color_alpha, "setColorAlpha(color = white, alpha = 1)", "Set current drawing color and alpha.", 
			[["color", "color", "Draw color"], ["alpha", "number", "Draw alpha"], ]],
		
		["drawRect",			__lua_draw_rectangle, "drawRect(x0, y0, x1, y1)", "Draw filled rectangle.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ]],
		["drawRectOutline",		__lua_draw_rectangle_outline, "drawRectOutline(x0, y0, x1, y1, thick = 1)", "Draw rectangle outline.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ["thick", "number", "Line thickness"], ]],
		["drawCircle",			__lua_draw_circle, "drawCircle(x, y, radius)", "Draw filled circle.", 
			[["x", "number", "Center x position"], ["y", "number", "Center y position"], ["radius", "number", "Circle radius"], ]],
		["drawCircleOutline",	__lua_draw_circle_outline, "drawCircleOutline(x, y, radius, thick = 1)", "Draw circle outline.", 
			[["x", "number", "Center x position"], ["y", "number", "Center y position"], ["radius", "number", "Circle radius"], ["thick", "number", "Line thickness"], ]],
		["drawEllipse",			__lua_draw_ellipse, "drawEllipse(x0, y0, x1, y1)", "Draw filled ellipse.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ]],
		["drawEllipseOutline",	__lua_draw_ellipse_outline, "drawEllipseOutline(x0, y0, x1, y1, thick = 1)", "Draw ellipse outline.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ["thick", "number", "Line thickness"], ]],
		["drawLine",			__lua_draw_line, "drawLine(x0, y0, x1, y1, thick = 1)", "Draw line.", 
			[["x0", "number", "x position of the first point"], ["y0", "number", "y position of the first point"], ["x1", "number", "x position of the second point"], ["y1", "number", "y position of the second point"], ["thick", "number", "Line thickness"], ]],
		["drawLineRound",		__lua_draw_line_round, "drawLineRound(x0, y0, x1, y1, thick = 1)", "Draw line with rounded cap.", 
			[["x0", "number", "x position of the first point"], ["y0", "number", "y position of the first point"], ["x1", "number", "x position of the second point"], ["y1", "number", "y position of the second point"], ["thick", "number", "Line thickness"], ]],
		["drawPixel",			__lua_draw_pixel, "drawPixel(x, y)", "Draw a single pixel.", 
			[["x", "number", "x position"], ["y", "number", "y position"]]],
		
		"Colors",
		["colorGetRed",			colour_get_red, "colorGetRed(color)", "Get red value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["colorGetGreen",		colour_get_green, "colorGetGreen(color)", "Get green value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["colorGetBlue",		colour_get_blue, "colorGetBlue(color)", "Get blue value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["colorGetHue",			colour_get_hue, "colorGetHue(color)", "Get hue value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["colorGetSaturation",	colour_get_saturation, "colorGetSaturation(color)", "Get seturation value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["colorGetValue",		colour_get_value, "colorGetValue(color)", "Get value value from color (0-255).", 
			[["color", "color", "color (very useful I know)"], ]],
		["getCurrentColor",		draw_get_colour, "getColor()", "Get current drawing color.", ],
		["getCurrentAlpha",		draw_get_alpha, "getAlpha()", "Get current drawing alpha.", ],
		["colorCreateRGB",		__lua_color_make_rgb, "colorCreateRGB(red, green, blue, normalize = false)", "Create color from RGB value.", 
			[["red", "number", "Red component"], ["green", "number", "Green component"], ["blue", "number", "Blue component"], ["normalize", "boolean", "Use normalized value (0-1) or non normalized value (0-255)"], ]],
		["colorCreateHSV",		__lua_color_make_hsv, "colorCreateHSV(hue, saturation, value, normalize = false)", "Create color from HSV value.", 
			[["hue", "number", "Hue component"], ["saturation", "number", "Saturation component"], ["value", "number", "Value component"], ["normalize", "boolean", "Use normalized value (0-1) or non normalized value (0-255)"], ]],
		["colorMerge",			merge_colour, "colorMerge(colorFrom, colorTo, ratio)", "Combine 2 colors.", 
			[["colorFrom", "color", "First color"], ["colorTo", "color", "Second color"], ["ratio", "number", "Blend amount 0 = colorFrom, 1 = colorTo"] ]],
		
		["setBlend",	__lua_blendmode_set, "setBlend(blend)", "Set blending mode: 0 = normal, 1 = add, 3 = subtract.", 
			[["blend", "number", "Blend mode."], ]],
		["resetBlend",	__lua_blendmode_reset, "resetBlend()", "Reset blending mode.", ],
		
		"Numbers",
		["randomize",			randomize, "randomize()", "Randomize all random functions.", ],
		["setSeed",			random_set_seed, "setSeed(seed)", "Set random seed to specific value.", 
			[["seed", "number", "seed value"], ]],
		["random",			__lua_random, "random(from = 0, to = 1)", "Random floating value.", 
			[["from", "number", "Minimum value"], ["to", "number", "Maximum value (exclusive)"], ]],
		["irandom",			__lua_irandom, "irandom(from = 0, to = 1)", "Random integer value.", 
			[["from", "number", "Minimum value"], ["to", "number", "Maximum value (inclusive)"], ]],
		
		["abs",		abs, "abs(number)", "Calculate absolute value.", 
			[["number", "number", "Number"], ]],
		["round",	round, "round(number)", "Round decimal to the closet integer.", 
			[["number", "number", "Number"], ]],
		["floor",	floor, "floor(number)", "Round decimal down to the closet integer.", 
			[["number", "number", "Number"], ]],
		["ceil",	ceil, "ceil(number)", "Round decimal up to the closet integer.", 
			[["number", "number", "Number"], ]],
		["max",		max, "max(number0, number1)", "Return maximum value between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"], ]],
		["min",		min, "min(number0, number1)", "Return minimum value between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"], ]],
		["clamp",	__lua_clamp, "clamp(number, min = 0, max = 1)", "Clamp number between 2 values.", 
			[["number", "number", "Number to clamp"], ["min", "number", "Minimum range"], ["max", "number", "Maximum range"], ]],
		["lerp",	lerp, "lerp(numberFrom, numberTo, ratio)", "Linearly interpolate between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"], ["ratio", "number", "Lerp amount 0 = first number, 1 = second number"], ]],
		
		["sqr",		sqr, "sqr(number)", "Return square value (n * n)", 
			[["number", "number", "n"], ]],
		["sqrt",	sqrt, "sqrt(number)", "Return square root of number.", 
			[["number", "number", "n"], ]],
		["power",	power, "power(base, exponent)", "Return a ^ b", 
			[["base", "number", "Base (a)"], ["exponent", "number", "Exponent (b)"], ]],
		["exp",		exp, "exp(exponent)", "Return exponent power(e, n)", 
			[["exponent", "number", "Exponent (n)"], ]],
		["ln",		ln, "ln(number)", "Return natural log (log(e, n))", 
			[["number", "number", "n"], ]],
		["log2",	log2, "log2(number)", "Return log 2 of n.", 
			[["number", "number", "Number (n)"], ]],
		["log10",	log10, "log10(number)", "Return log 10 of n.", 
			[["number", "number", "Number (n)"], ]],
		["logn",	logn, "logn(base, number)", "Return log b of a.", 
			[["base", "number", "Base (b)"], ["number", "number", "Number (a)"], ]],
		
		"Trigonometry, Vector",
		["sin",		sin, "sin(number)", "Return sin of radian angle.", 
			[["number", "number", "Angle in radian"], ]],
		["cos",		cos, "cos(number)", "Return cos of radian angle.", 
			[["number", "number", "Angle in radian"], ]],
		["tan",		tan, "tan(number)", "Return tan of radian angle.", 
			[["number", "number", "Angle in radian"], ]],
		["asin",	arcsin, "asin(number)", "Return arcsin (in radian).", 
			[["number", "number", "Value"], ]],
		["acos",	arccos, "acos(number)", "Return arccos (in radian).", 
			[["number", "number", "Value"], ]],
		["atan",	arctan, "atan(number)", "Return arctan (in radian).", 
			[["number", "number", "Value"], ]],
		["atan2",	arctan2, "atan2(y, x)", "Return arctan (in radian) from y, x.", 
			[["y", "number", "y value"], ["x", "number", "x value"], ]],
			
		["dsin",	dsin, "dsin(number)", "Return sin of degree angle.",
			[["number", "number", "Angle in degree"], ]],
		["dcos",	dcos, "dcos(number)", "Return cos of degree angle.", 
			[["number", "number", "Angle in degree"], ]],
		["dtan",	dtan, "dtan(number)", "Return tan of degree angle.", 
			[["number", "number", "Angle in degree"], ]],
		["dasin",	darcsin, "dasin(number)", "Return arcsin (in degree).", 
			[["number", "number", "Value"], ]],
		["dacos",	darccos, "dacos(number)", "Return arccos (in degree).", 
			[["number", "number", "Value"], ]],
		["datan",	darctan, "datan(number)", "Return arctan (in degree).", 
			[["number", "number", "Value"], ]],
		["datan2",  darctan2, "datan2(y, x)", "Return arctan (in degree) from y, x.", 
			[["y", "number", "y value"], ["x", "number", "x value"], ]],
			
		["rad",		degtorad, "rad(number)", "Convert degree angle to radian.", 
			[["number", "number", "Degree angle"], ]],
		["deg",		radtodeg, "deg(number)", "Convert radian angle to degree.", 
			[["number", "number", "Radian angle"], ]],
			
		["dot",		dot_product, "dot(x0, y0, x1, y1)", "Calculate dot product.", 
			[["x0", "number", "Value"], ["y0", "number", "Value"], ["x1", "number", "Value"], ["y1", "number", "Value"], ]],
		
		"String",
		["stringLength",		string_length, "stringLength(string)", "Return length of the string.", 
			[["string", "text", "Text to calculate length"], ]],
		["stringSearch",		__lua_string_search, "stringSearch(string, searchString)", "Return position of the substring in a string. (String position start at 1, curse you GameMaker.)", 
			[["string", "text", "Text to get position from"], ["searchString", "text", "Searching text."], ]],
		["stringCopy",			string_copy, "stringCopy(string, start, length)", "Return copy of a string.", 
			[["string", "text", "Original text"], ["start", "number", "Starting position"], ["length", "number", "Length of text to copy"], ]],
		["stringUpper",			string_upper, "stringUpper(string)", "Convert string to uppercase.", 
			[["string", "text", "Text to convert"], ]],
		["stringLower",			string_lower, "stringLower(string)", "Convert string to lowercase.", 
			[["string", "text", "Text to convert"], ]],
		["stringReplace",		string_replace, "stringReplace(string, replaceFrom, replaceTo)", "Replace the first occurance of a string with another string.", 
			[["string", "text", "Text input"], ["replaceFrom", "text", "Text that will be replace"], ["replaceTo", "text", "Text to replace to"], ]],
		["stringReplaceAll",	string_replace_all, "stringReplaceAll(string, replaceFrom, replaceTo)", "Replace every occurances of a string with another string.", 
			[["string", "text", "Text input"], ["replaceFrom", "text", "Text that will be replace"], ["replaceTo", "text", "Text to replace to"], ]],
		["stringSplit",			string_split, "stringSplit(string, delimiter)", "Separate string to arrays.", 
			[["string", "text", "Text input"], ["delimiter", "text", "Text that will use to cut the string"], ]],
		
		"Debug",
		["print",	 __lua_noti, "print(string)", "Display text on notification.", 
			[["string", "text", "Text to display"], ]],
	];
	
	globalvar LUA_API;
	LUA_API = ds_map_create();
	
	for( var i = 0; i < array_length(global.lua_functions); i++ ) {
		if(is_string(global.lua_functions[i])) continue;
		LUA_API[? global.lua_functions[i][0]] = global.lua_functions[i][1];
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
	noti_warning("Lua error: " + string(state));
}