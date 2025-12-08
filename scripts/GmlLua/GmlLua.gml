function lua_function(_name, _fn = noone, _syn = "", _desp = "", _despArg = [], _typeOut = "null") constructor {
	name    = _name;
	fn      = _fn;
	syn     = _syn;
	
	desp    = _desp;
	despArg = _despArg;
	typeOut = _typeOut;
}

function __initLua() {
	global.lua_functions = [
		"Draw Surface",
		new lua_function("draw",			function(ss,xx,yy) /*=>*/ { draw_surface_safe(ss,xx,yy); }, 
			"draw(surface, x, y)", "Draw surface, with top left at (x, y).", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"]]),
			
		new lua_function("drawBlend",		function(ss,xx,yy,cc=c_white,aa=1) /*=>*/ { draw_surface_ext_safe(ss,xx,yy,1,1,0,cc,aa); }, 
			"drawBlend(surface, x, y, color = white, alpha = 1)", "Draw surface with color blending.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["color", "color", "Blend color"], ["alpha", "number", "Alpha (tranparency)"]]),
			
		new lua_function("drawTransform",	function(ss,xx,yy,xs=1,ys=xs,r=0) /*=>*/ { draw_surface_ext_safe(ss,xx,yy,xs,ys,r,c_white,1); }, 
			"drawTransform(surface, x, y, xs = 1, ys = 1, rot = 0)", "Draw surface with extra transformation.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["xs", "number", "x scale"], ["ys", "number", "y scale"], ["rot", "number", "Rotation"]]),
			
		new lua_function("drawGeneral",		function(ss,xx,yy,xs=1,ys=1,r=0,cc=c_white,aa=1) /*=>*/ { draw_surface_ext_safe(ss,xx,yy,xs,ys,r,cc,aa); }, 
			"drawGeneral(surface, x, y, xs = 1, ys = 1, rot = 0, color = white, alpha = 1)", "Draw surface with all the controls.", 
			[["surface", "surface", "Surface to draw"], ["x", "number", "x position"], ["y", "number", "y position"], ["xs", "number", "x scale"], ["ys", "number", "y scale"], ["rot", "number", "Rotation"], ["color", "color", "Blend color"], ["alpha", "number", "Alpha (tranparency)"]]),
		
		"Draw Functions",
		new lua_function("clear",		    function(c=0,a=0) /*=>*/ { draw_clear_alpha(c,a); }, 
			"clear()", "Clear surface, need to be call every frame to refresh the surface. "),
	
		new lua_function("setColor",		function(c=c_white) /*=>*/ { draw_set_color(c); }, 
		"setColor(color = white)", "Set current drawing color.", 
			[["color", "color", "Draw color"]]),
			
		new lua_function("setAlpha",		function(a=1) /*=>*/ { draw_set_alpha(a); }, 
		"setAlpha(alpha = 1)", "Set current drawing alpha.", 
			[["alpha", "number", "Draw alpha"]]),
			
		new lua_function("setColorAlpha",	function(c=c_white,a=1) /*=>*/ { draw_set_color(c); draw_set_alpha(a); }, 
		"setColorAlpha(color = white, alpha = 1)", "Set current drawing color and alpha.", 
			[["color", "color", "Draw color"], ["alpha", "number", "Draw alpha"]]),
		
		new lua_function("drawRect",		function(x0,y0,x1,y1) /*=>*/ { draw_rectangle(x0,y0,x1,y1,0); }, 
			"drawRect(x0, y0, x1, y1)", "Draw filled rectangle.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"]]),
			
		new lua_function("drawRectOutline",	function(x0,y0,x1,y1,th=1) /*=>*/ { draw_rectangle_border(x0,y0,x1,y1,th); }, 
			"drawRectOutline(x0, y0, x1, y1, thick = 1)", "Draw rectangle outline.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ["thick", "number", "Line thickness"]]),
			
		new lua_function("drawCircle",		function(x0,y0,r) /*=>*/ { draw_circle(x0,y0,r,0); }, 
			"drawCircle(x, y, radius)", "Draw filled circle.", 
			[["x", "number", "Center x position"], ["y", "number", "Center y position"], ["radius", "number", "Circle radius"]]),
			
		new lua_function("drawCircleOutline",  function(x0,y0,r,th=1) /*=>*/ { draw_circle_border(x0,y0,r,th); }, 
			"drawCircleOutline(x, y, radius, thick = 1)", "Draw circle outline.", 
			[["x", "number", "Center x position"], ["y", "number", "Center y position"], ["radius", "number", "Circle radius"], ["thick", "number", "Line thickness"]]),
			
		new lua_function("drawEllipse",        function(x0,y0,x1,y1) /*=>*/ { draw_ellipse(x0,y0,x1,y1,0); }, 
			"drawEllipse(x0, y0, x1, y1)", "Draw filled ellipse.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"]]),
			
		new lua_function("drawEllipseOutline", function(x0,y0,x1,y1,th=1) /*=>*/ { draw_ellipse_border(x0,y0,x1,y1,th); }, 
			"drawEllipseOutline(x0, y0, x1, y1, thick = 1)", "Draw ellipse outline.", 
			[["x0", "number", "Left position"], ["y0", "number", "Top position"], ["x1", "number", "Right position"], ["y1", "number", "Bottom position"], ["thick", "number", "Line thickness"]]),
			
		new lua_function("drawLine",		   function(x0,y0,x1,y1,th=1) /*=>*/ { draw_line_width(x0,y0,x1,y1,th); }, 
			"drawLine(x0, y0, x1, y1, thick = 1)", "Draw line.", 
			[["x0", "number", "x position of the first point"], ["y0", "number", "y position of the first point"], ["x1", "number", "x position of the second point"], ["y1", "number", "y position of the second point"], ["thick", "number", "Line thickness"]]),
			
		new lua_function("drawLineRound",	   function(x0,y0,x1,y1,th=1) /*=>*/ { draw_line_round(x0,y0,x1,y1,th); }, 
			"drawLineRound(x0, y0, x1, y1, thick = 1)", "Draw line with rounded cap.", 
			[["x0", "number", "x position of the first point"], ["y0", "number", "y position of the first point"], ["x1", "number", "x position of the second point"], ["y1", "number", "y position of the second point"], ["thick", "number", "Line thickness"]]),
			
		new lua_function("drawPixel",		   function(x0,y0) /*=>*/ { draw_point(x0,y0); }, 
			"drawPixel(x, y)", "Draw a single pixel.", 
			[["x", "number", "x position"], ["y", "number", "y position"]]),
		
		"Colors",
		new lua_function("getColor",		function(_x,_y) /*=>*/ { var s = surface_get_target(); return is_surface(s)? surface_get_pixel_ext(s,_x,_y) : 0; }, 
		"getColor(x, y)", "Get color from current surface.", 
			[["x", "number", "Sample x position"], ["y", "number", "Sample y position"]], "color"),
			
		new lua_function("getColorSurface", function(ss,_x,_y) /*=>*/ {return is_surface(ss)? surface_get_pixel_ext(ss,_x,_y) : 0}, 
			"getColorSurface(surface, x, y)", "Get color from surface.", 
			[["surface", "surface", "Surface to get color from"], ["x", "number", "Sample x position"], ["y", "number", "Sample y position"]], "color"),
			
		new lua_function("colorGetRed",        colour_get_red,        "colorGetRed(color)",        "Get red value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("colorGetGreen",      colour_get_green,      "colorGetGreen(color)",      "Get green value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("colorGetBlue",       colour_get_blue,       "colorGetBlue(color)",       "Get blue value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("colorGetHue",        colour_get_hue,        "colorGetHue(color)",        "Get hue value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("colorGetSaturation", colour_get_saturation, "colorGetSaturation(color)", "Get seturation value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("colorGetValue",      colour_get_value,      "colorGetValue(color)",      "Get value value from color (0-255).", 
			[["color", "color", "color"]], "number"),
			
		new lua_function("getCurrentColor",    draw_get_colour, "getColor()", "Get current drawing color.", [], "number" ),
		new lua_function("getCurrentAlpha",	   draw_get_alpha,  "getAlpha()", "Get current drawing alpha.", [], "number" ),
		
		new lua_function("colorCreateRGB",		function(r,g,b,n=false) /*=>*/ {return n? make_color_rgb(r * 255, g * 255, b * 255) : make_color_rgb(r, g, b)}, 
			"colorCreateRGB(red, green, blue, normalize = false)", "Create color from RGB value.", 
			[["red", "number", "Red component"], ["green", "number", "Green component"], ["blue", "number", "Blue component"], ["normalize", "boolean", "Use normalized value (0-1) or non normalized value (0-255)"]], "color"),
		
		new lua_function("colorCreateHSV",		function(h,s,v,n=false) /*=>*/ {return n? make_color_hsv(h * 255, s * 255, v * 255) : make_color_hsv(h, s, v)}, 
			"colorCreateHSV(hue, saturation, value, normalize = false)", "Create color from HSV value.", 
			[["hue", "number", "Hue component"], ["saturation", "number", "Saturation component"], ["value", "number", "Value component"], ["normalize", "boolean", "Use normalized value (0-1) or non normalized value (0-255)"]], "color"),
		
		new lua_function("colorMerge",			merge_colour, "colorMerge(colorFrom, colorTo, ratio)", "Combine 2 colors.", 
			[["colorFrom", "color", "First color"], ["colorTo", "color", "Second color"], ["ratio", "number", "Blend amount 0 = colorFrom, 1 = colorTo"]], "color"),
		
		new lua_function("setBlend",	function(m) /*=>*/ { gpu_set_blendmode(m); }, 
			"setBlend(blend)", "Set blending mode: 0 = normal, 1 = add, 3 = subtract.", 
			[["blend", "number", "Blend mode."]]),
			
		new lua_function("resetBlend",	function() /*=>*/ { gpu_set_blendmode(bm_normal); }, 
			"resetBlend()", "Reset blending mode.", ),
	
		"Numbers",
		new lua_function("randomize", randomize, "randomize()", "Randomize all random functions."),
		
		new lua_function("setSeed",   random_set_seed, "setSeed(seed)", "Set random seed to specific value.", 
			[["seed", "number", "seed value"]]),
			
		new lua_function("random",    function(f=0,t=1) /*=>*/ {return random_range(f,t)}, "random(from = 0, to = 1)", "Random floating value.", 
			[["from", "number", "Minimum value"], ["to", "number", "Maximum value (exclusive)"]], "number"),
			
		new lua_function("irandom",   function(f=0,t=1) /*=>*/ {return irandom_range(f,t)}, "irandom(from = 0, to = 1)", "Random integer value.", 
			[["from", "number", "Minimum value"], ["to", "number", "Maximum value (inclusive)"]], "number"),
		
		new lua_function("abs",		abs, "abs(number)", "Calculate absolute value.", 
			[["number", "number", "Number"]], "number"),
			
		new lua_function("round",	round, "round(number)", "Round decimal to the closet integer.", 
			[["number", "number", "Number"]], "number"),
			
		new lua_function("floor",	floor, "floor(number)", "Round decimal down to the closet integer.", 
			[["number", "number", "Number"]], "number"),
			
		new lua_function("ceil",	ceil, "ceil(number)", "Round decimal up to the closet integer.", 
			[["number", "number", "Number"]], "number"),
			
		new lua_function("max",		max, "max(number0, number1)", "Return maximum value between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"]], "number"),
			
		new lua_function("min",		min, "min(number0, number1)", "Return minimum value between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"]], "number"),
			
		new lua_function("clamp",	function(n,nn=0,xx=1) /*=>*/ {return clamp(n,nn,xx)}, "clamp(number, min = 0, max = 1)", "Clamp number between 2 values.", 
			[["number", "number", "Number to clamp"], ["min", "number", "Minimum range"], ["max", "number", "Maximum range"]], "number"),
			
		new lua_function("lerp",	lerp, "lerp(numberFrom, numberTo, ratio)", "Linearly interpolate between 2 numbers.", 
			[["number0", "number", "First number"], ["number1", "number", "Second number"], ["ratio", "number", "Lerp amount 0 = first number, 1 = second number"]], "number"),
		
		new lua_function("sqr",		sqr, "sqr(number)", "Return square value (n * n)", 
			[["number", "number", "n"]], "number"),
			
		new lua_function("sqrt",	sqrt, "sqrt(number)", "Return square root of number.", 
			[["number", "number", "n"]], "number"),
			
		new lua_function("power",	power, "power(base, exponent)", "Return a ^ b", 
			[["base", "number", "Base (a)"], ["exponent", "number", "Exponent (b)"]], "number"),
			
		new lua_function("exp",		exp, "exp(exponent)", "Return exponent power(e, n)", 
			[["exponent", "number", "Exponent (n)"]], "number"),
			
		new lua_function("ln",		ln, "ln(number)", "Return natural log (log(e, n))", 
			[["number", "number", "n"]], "number"),
			
		new lua_function("log2",	log2, "log2(number)", "Return log 2 of n.", 
			[["number", "number", "Number (n)"]], "number"),
			
		new lua_function("log10",	log10, "log10(number)", "Return log 10 of n.", 
			[["number", "number", "Number (n)"]], "number"),
			
		new lua_function("logn",	logn, "logn(base, number)", "Return log b of a.", 
			[["base", "number", "Base (b)"], ["number", "number", "Number (a)"]], "number"),
		
		"Trigonometry, Vector",
		new lua_function("sin",		sin, "sin(number)", "Return sin of radian angle.", 
			[["number", "number", "Angle in radian"]], "number"),
			
		new lua_function("cos",		cos, "cos(number)", "Return cos of radian angle.", 
			[["number", "number", "Angle in radian"]], "number"),
			
		new lua_function("tan",		tan, "tan(number)", "Return tan of radian angle.", 
			[["number", "number", "Angle in radian"]], "number"),
			
		new lua_function("asin",	arcsin, "asin(number)", "Return arcsin (in radian).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("acos",	arccos, "acos(number)", "Return arccos (in radian).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("atan",	arctan, "atan(number)", "Return arctan (in radian).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("atan2",	arctan2, "atan2(y, x)", "Return arctan (in radian) from y, x.", 
			[["y", "number", "y value"], ["x", "number", "x value"]], "number"),
			
		new lua_function("dsin",	dsin, "dsin(number)", "Return sin of degree angle.",
			[["number", "number", "Angle in degree"]], "number"),
			
		new lua_function("dcos",	dcos, "dcos(number)", "Return cos of degree angle.", 
			[["number", "number", "Angle in degree"]], "number"),
			
		new lua_function("dtan",	dtan, "dtan(number)", "Return tan of degree angle.", 
			[["number", "number", "Angle in degree"]], "number"),
			
		new lua_function("dasin",	darcsin, "dasin(number)", "Return arcsin (in degree).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("dacos",	darccos, "dacos(number)", "Return arccos (in degree).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("datan",	darctan, "datan(number)", "Return arctan (in degree).", 
			[["number", "number", "Value"]], "number"),
			
		new lua_function("datan2",  darctan2, "datan2(y, x)", "Return arctan (in degree) from y, x.", 
			[["y", "number", "y value"], ["x", "number", "x value"]], "number"),
			
		new lua_function("rad",		degtorad, "rad(number)", "Convert degree angle to radian.", 
			[["number", "number", "Degree angle"]], "number"),
			
		new lua_function("deg",		radtodeg, "deg(number)", "Convert radian angle to degree.", 
			[["number", "number", "Radian angle"]], "number"),
			
		new lua_function("dot",		dot_product, "dot(x0, y0, x1, y1)", "Calculate dot product.", 
			[["x0", "number", "Value"], ["y0", "number", "Value"], ["x1", "number", "Value"], ["y1", "number", "Value"]], "number"),
		
		"String",
		new lua_function("stringLength",		string_length, "stringLength(string)", "Return length of the string.", 
			[["string", "text", "Text to calculate length"]], "number"),
			
		new lua_function("stringSearch",		function(t,s) /*=>*/ {return string_pos(s,t)}, "stringSearch(string, searchString)", "Return position of the substring in a string. (String position start at 1, curse you GameMaker.)", 
			[["string", "text", "Text to get position from"], ["searchString", "text", "Searching text."]], "number"),
			
		new lua_function("stringCopy",			string_copy, "stringCopy(string, start, length)", "Return copy of a string.", 
			[["string", "text", "Original text"], ["start", "number", "Starting position"], ["length", "number", "Length of text to copy"]], "text"),
			
		new lua_function("stringUpper",			string_upper, "stringUpper(string)", "Convert string to uppercase.", 
			[["string", "text", "Text to convert"]], "text"),
			
		new lua_function("stringLower",			string_lower, "stringLower(string)", "Convert string to lowercase.", 
			[["string", "text", "Text to convert"]], "text"),
			
		new lua_function("stringReplace",		string_replace, "stringReplace(string, replaceFrom, replaceTo)", "Replace the first occurance of a string with another string.", 
			[["string", "text", "Text input"], ["replaceFrom", "text", "Text that will be replace"], ["replaceTo", "text", "Text to replace to"]], "text"),
			
		new lua_function("stringReplaceAll",	string_replace_all, "stringReplaceAll(string, replaceFrom, replaceTo)", "Replace every occurances of a string with another string.", 
			[["string", "text", "Text input"], ["replaceFrom", "text", "Text that will be replace"], ["replaceTo", "text", "Text to replace to"]], "text"),
			
		new lua_function("stringSplit",			string_split, "stringSplit(string, delimiter)", "Separate string to arrays.", 
			[["string", "text", "Text input"], ["delimiter", "text", "Text that will use to cut the string"]], "text[]"),
		
		"Surface",
		new lua_function("surfaceGetWidth",    function(s) /*=>*/ {return surface_get_width_safe(s)}, 
			"surfaceGetWidth(surface)", "Get surface width in pixels.", 
			[["surface", "surface", "Surface to get"]], "number"),
		
		new lua_function("surfaceGetHeight",   function(s) /*=>*/ {return surface_get_height_safe(s)}, 
			"surfaceGetHeight(surface)", "Get surface height in pixels.", 
			[["surface", "surface", "Surface to get"]], "number"),
		
		new lua_function("surfaceGetFormat",   function(s) /*=>*/ {return surface_get_format_safe(s)}, 
			"surfaceGetFormat(surface)", "Get surface format.", 
			[["surface", "surface", "Surface to get"]], "number"),
		
		"Project",
		new lua_function("Project.frame",		noone, "Project.frame",			"Get current frame index (start at 0).", [], "number"),
		new lua_function("Project.frameTotal",	noone, "Project.frameTotal",	"Get animation length.", [], "number"),
		new lua_function("Project.fps",			noone, "Project.fps",			"Get animation framerate.", [], "number"),
	
		"Debug",
		new lua_function("print",	 function(txt) /*=>*/ { noti_status(txt); }, 
			"print(string)", "Display text on notification.", 
			[["string", "text", "Text to display"]]),
	];
	
	globalvar LUA_API; LUA_API = ds_map_create();
	if(OS == os_windows) lua_register_log();
	
	for( var i = 0, n = array_length(global.lua_functions); i < n; i++ ) {
		var _luaf = global.lua_functions[i];
		
		if(is_string(_luaf))  continue;
		if(_luaf.fn == noone) continue;
		
		LUA_API[? _luaf.name] = _luaf.fn;
	}
}

function lua_create() {
	var state = lua_state_create();
	var k = ds_map_find_first(LUA_API);
	
	repeat(ds_map_size(LUA_API)) {
		lua_add_function(state, k, LUA_API[? k]);
		k = ds_map_find_next(LUA_API, k);
	}
	
	lua_add_code(state, @"
Project = {};
Project.frame	   = 0;
Project.frameTotal = 0;
Project.fps		   = 0;
");
	lua_projectData(state);
	
	return state;
}

function lua_projectData(state) {
	lua_add_code(state, @"
Project.frame	   = " + string(GLOBAL_CURRENT_FRAME) + @";
Project.frameTotal = " + string(GLOBAL_TOTAL_FRAMES) + @";
Project.fps		   = " + string(PROJECT.animator.framerate) + @";
");
}

function _lua_error(state, msg) { noti_warning($"Lua error: {msg}"); }