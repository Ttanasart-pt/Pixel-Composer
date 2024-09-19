function RM_Object() constructor {
	id = UUID_generate();
	shapeAmount   = 0;
	
	shape         = [];
	size          = [];
	radius        = [];
	thickness     = [];
	crop          = [];
	angle         = [];
	height        = [];
	radRange      = [];
	sizeUni       = [];
	elongate      = [];
	rounded       = [];
	corner        = [];
	size2D        = [];
	sides         = [];
	
	waveAmp       = [];
	waveInt       = [];
	waveShift     = [];
	
	twistAxis     = [];
	twistAmount   = [];
	
	position      = [];
	rotation      = [];
	objectScale   = [];
	
	tileActive    = [];
	tileAmount    = [];
	tileSpace     = [];
	tilePos       = [];
	tileRot       = [];
	tileSca       = [];
	
	diffuseColor  = [];
	reflective    = [];
	
	volumetric    = [];
	volumeDensity = [];
	
	texture       = [];
	useTexture    = [];
	textureFilter = [];
	textureScale  = [];
	triplanar     = [];
	
	opmap = -1;
	oparg = -1;
	
	uniformKeys   = [ "shape", "size", "radius", "thickness", "crop", "angle", "height", "radRange", "sizeUni", "elongate", "rounded", "corner", "size2D", "sides", 
					  "waveAmp", "waveInt", "waveShift", 
					  "twistAxis", "twistAmount", 
					  "position", "rotation", "objectScale", 
					  "tileActive", "tileAmount", "tileSpace", "tilePos", "tileRot", "tileSca", 
					  "diffuseColor", "reflective", 
					  "volumetric", "volumeDensity", 
					  "texture", "textureFilter", "useTexture", "textureScale", "triplanar" 
					];
	textureAtl    = noone;
	
	static flatten = function() {}
	
	static setTexture = function(textureAtlas) {
		var tx = 1024;
		
		surface_set_shader(textureAtlas);
			for (var i = 0; i < shapeAmount; i++) {
				gpu_set_tex_filter(textureFilter[i]);
				draw_surface_stretched_safe(texture[i], tx * (i % 8), tx * floor(i / 8), tx, tx);
				gpu_set_tex_filter(false);
			}
		surface_reset_shader();
		
		
		textureAtl = textureAtlas;
	}
	
	static apply = function() {
		// print(self);
		
		shader_set_i("shapeAmount",      shapeAmount);
		if(shapeAmount <= 0) return;
		
		shader_set_i("operations",       opmap); //print(opmap);
		shader_set_f("opArgument",       oparg);
		shader_set_i("opLength",         array_safe_length(opmap));
		
		shader_set_i("shape",            shape);
		shader_set_f("size",             size);
		shader_set_f("radius",           radius);
		shader_set_f("thickness",        thickness);
		shader_set_f("crop",             crop);
		shader_set_f("angle",            angle);
		shader_set_f("height",           height);
		shader_set_f("radRange",         radRange);
		shader_set_f("sizeUni",          sizeUni);
		shader_set_f("elongate",         elongate);
		shader_set_f("rounded",          rounded);
		shader_set_f("corner",           corner);
		shader_set_f("size2D",           size2D);
		shader_set_i("sides",            sides);
		
		shader_set_f("waveAmp",          waveAmp);
		shader_set_f("waveInt",          waveInt);
		shader_set_f("waveShift",        waveShift);
		
		shader_set_i("twistAxis",        twistAxis);
		shader_set_f("twistAmount",      twistAmount);
		
		shader_set_f("position",         position);
		shader_set_f("rotation",         rotation);
		shader_set_f("objectScale",      objectScale);
		
		shader_set_i("tileActive",       tileActive);
		shader_set_f("tileAmount",       tileAmount);
		shader_set_f("tileSize",         tileSpace);
		// shader_set_f("tileShiftPos",     tilePos);
		// shader_set_f("tileShiftRot",     tileRot);
		// shader_set_f("tileShiftSca",     tileSca);
		
		shader_set_f("diffuseColor",     diffuseColor); 
		shader_set_f("reflective",       reflective);
		
		shader_set_i("volumetric",       volumetric);
		shader_set_f("volumeDensity",    volumeDensity);
		
		///////////////////////////////////////////////////////////////
		
		shader_set_surface("texture1",   textureAtl);
		shader_set_i("textureFilter",    textureFilter);
		shader_set_i("useTexture",       useTexture);
		shader_set_f("textureScale",     textureScale);
		shader_set_f("triplanar",        triplanar);
	}
	
	static serialize   = function() { return ""};
	static deserialize = function() { };
}

function RM_Operation(type, left, right) : RM_Object() constructor {
	
	self.type  = type;
	self.left  = left;
	self.right = right;
	merge = 0;
	
	static reset = function() {
		
		for (var i = 0, n = array_length(uniformKeys); i < n; i++)
			self[$ uniformKeys[i]] = [];
	}
	
	static add = function(rmObject) {
		
		for (var i = 0, n = array_length(uniformKeys); i < n; i++)
			array_append(self[$ uniformKeys[i]], rmObject[$ uniformKeys[i]]);
	}
	
	static __flatten = function(node) {
		if(is_instanceof(node, RM_Shape)) 
			return node;
		
		var _op = node.type;
		var _l  = node.left;
		var _r  = node.right;
		
		var _arr = [  ];
		
		array_append(_arr, __flatten(_l));
		array_append(_arr, __flatten(_r));
		array_push(_arr, [ _op, node ]);
		
		return _arr;
	}
	
	static flatten = function() {
		var _arr   = __flatten(self);
		var _nodes = [];
		
		for (var i = 0, n = array_length(_arr); i < n; i++) {
			var _a = _arr[i];
			
			if(!is_struct(_a)) continue;
			if(array_exists(_nodes, _a)) continue;
			
			_a.flatten_index = array_length(_nodes);
			array_push(_nodes, _a);
		}
		
		opmap = [];
		oparg = [];
		
		for (var i = 0, n = array_length(_arr); i < n; i++) {
			var _a = _arr[i];
			
			if(is_array(_a)) {
				switch(_a[0]) {
					case "combine"   : array_push(opmap, 100); break;
					case "union"     : array_push(opmap, 101); break;
					case "subtract"  : array_push(opmap, 102); break;
					case "intersect" : array_push(opmap, 103); break;
				}
				
				array_push(oparg, _a[1].merge);
				
			} else if(is_struct(_a)) {
				array_push(opmap, _a.flatten_index);
				array_push(oparg, 0);
			}
		}
		
		shapeAmount = array_length(_nodes);
		
		reset();
		for (var i = 0, n = array_length(_nodes); i < n; i++) 
			add(_nodes[i]);
	}
	
}

function RM_Shape() : RM_Object() constructor {
	
}

function RM_Environment() constructor {
	surface = noone;
	bgEnv   = noone;
	
	envFilter  = false;
	projection = 0;
	fov        = 0;
	orthoScale = 1;
	viewRange  = [ 0, 1 ];
	depthInt   = 0;
	
	bgColor    = c_black;
	bgDraw     = false;
	ambInten   = 0;
	light      = [ 1, 0.5, 0 ];
	
	static apply = function() {
		
		shader_set_surface($"texture0", surface);
		
		shader_set_i("MAX_MARCHING_STEPS", 512);
		
		shader_set_i("ortho",       projection);
		shader_set_f("fov",         fov);
		shader_set_f("orthoScale",  orthoScale);
		shader_set_f("viewRange",   viewRange);
		shader_set_f("depthInt",    depthInt);
		
		shader_set_i("drawBg",  	   bgDraw);
		shader_set_color("background", bgColor);
		shader_set_f("ambientIntns",   ambInten);
		shader_set_f("lightPosition",  light);
		
		shader_set_i("envFilter",   envFilter);
		shader_set_i("useEnv",      is_surface(bgEnv));
		shader_set_i("drawGrid",  	false);
		
	}
}