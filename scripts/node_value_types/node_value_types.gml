#region ---- global names ----
	global.junctionEndName = [ "Hold", "Loop", "Ping pong", "Wrap" ];

	global.displaySuffix_Range		= [ "min", "max" ];
	global.displaySuffix_Area		= [ "x", "y", "w", "h", "shape" ];
	global.displaySuffix_Padding	= [ "right", "top", "left", "bottom" ];
	global.displaySuffix_VecRange	= [ "x min", "x max", "y min", "y max" ];
	global.displaySuffix_Axis		= [ "x", "y", "z", "w" ];
#endregion

enum JUNCTION_CONNECT {
	input,
	output
}

enum VALUE_TYPE {
	integer     =  0,
	float       =  1,
	boolean     =  2,
	color       =  3,
	surface     =  4,
	
	path        =  5,
	curve       =  6,
	text        =  7,
	object      =  8,
	node        =  9,
	d3object    = 10,
	
	any         = 11,
	
	pathnode    = 12,
	particle    = 13,
	rigid       = 14,
	
	sdomain     = 15,
	struct      = 16,
	strands     = 17,
	mesh	    = 18,
	trigger	    = 19,
	atlas	    = 20,
	
	d3vertex    = 21,
	gradient    = 22,
	armature    = 23,
	buffer      = 24,
	
	pbBox       = 25,
	
	d3Mesh	    = 26,
	d3Light	    = 27,
	d3Camera    = 28,
	d3Scene	    = 29,
	d3Material  = 30,
	
	dynaSurface = 31,
	PCXnode     = 32,
	audioBit    = 33,
	fdomain     = 34,
	sdf         = 35,
	
	action	    = 99,
}

enum VALUE_DISPLAY {
	_default,
	none,
	range,
	
	//Int
	enum_scroll,
	enum_button,
	rotation,
	rotation_range,
	rotation_random,
	slider,
	slider_range,
	
	//Color
	palette,
	
	//Int array
	padding,
	vector,
	vector_range,
	area,
	transform,
	corner,
	toggle,
	matrix,
	path_anchor,
	gradient_range,
	boolean_grid,
	
	//Curve
	curve,
	
	//Misc
	puppet_control,
	button,
	label,
	
	//Array
	path_array,
	
	//Text
	codeLUA,
	codeHLSL,
	text_array,
	text_box,
	text_tunnel,
	
	//path
	path_save,
	path_load,
	path_font,
	
	//d3d
	d3vertex,
	d3quarternion,
}

enum KEYFRAME_END {
	hold,
	loop,
	ping,
	wrap,
}

enum VALIDATION {
	pass,
	warning,
	error
}

enum VALUE_UNIT {
	constant,
	reference
}

enum VALUE_TAG {
	updateInTrigger		= -2,
	updateOutTrigger	= -3,
	none				= 0
}

enum LINE_STYLE {
	solid,
	dashed
}

function value_color(i) {
	static JUNCTION_COLORS = [ 
		#ff9166, //int 
		#ffe478, //float
		#8c3f5d, //bool
		#8fde5d, //color
		#ff6b97, //surface
		#eb004b, //path
		#c2c2d1, //curve
		#66ffe3, //text
		#ffb5b5, //object
		#4da6ff, //node
		#c1007c, //3D
		#808080, //any
		#ffb5b5, //path
		#8fde5d, //particle
		#88ffe9, //rigid
		#6d6e71, //sdomain
		#8c3f5d, //struct
		#ff9166, //strand
		#c2c2d1, //mesh
		#8fde5d, //trigger
		#ff6b97, //atlas
		#c1007c, //d3vertex
		#8fde5d, //gradient
		#ff9166, //armature
		#808080, //buffer
		#ff6b97, //pbBox
		#4da6ff, //d3Mesh	
		#4da6ff, //d3Light	
		#4da6ff, //d3Camera
		#4da6ff, //d3Scene	
		#ff6b97, //d3Material
		#ff6b97, //dynaSurf
		#c2c2d1, //PCX
		#8fde5d, //audiobit
		#4da6ff, //flipfluid
		#c1007c, //3D SDF
	];
	static JUNCTION_COLORS_LENGTH = array_length(JUNCTION_COLORS);
	
	if(i == 99) return #8fde5d;
	
	return JUNCTION_COLORS[i];
}

function value_color_bg(i) {
	return #3b3b4e;
}

function value_color_bg_array(i) {
	static JUNCTION_COLORS = [ 
		#e36956, //int 
		#ff9166, //float
		#5e315b, //bool
		#3ca370, //color
		#bd4882, //surface
		#bb003c, //path
		#83839b, //curve
		#4da6ff, //text
		#e28989, //object
		#4b5bab, //node
		#64003f, //3D
		#4d4d4d, //any
		#e28989, //path
		#3ca370, //particle
		#4da6ff, //rigid
		#4b5bab, //sdomain
		#5e315b, //struct
		#e36956, //strand
		#83839b, //mesh
		#3ca370, //trigger
		#9e2a69, //atlas
		#64003f, //d3vertex
		#3ca370, //gradient
		#e36956, //armature
		#4d4d4d, //buffer
		#bd4882, //pbBox
		#4b5bab, //d3Mesh	
		#4b5bab, //d3Light	
		#4b5bab, //d3Camera
		#4b5bab, //d3Scene	
		#bd4882, //d3Material
		#bd4882, //dynaSurf
		#83839b, //PCX
		#3ca370, //audiobit
		#4b5bab, //3D SDF
	];
	
	if(i == 99) return $5dde8f;
	return JUNCTION_COLORS[safe_mod(max(0, i), array_length(JUNCTION_COLORS))];
}

function value_bit(i) {
	switch(i) {
		case VALUE_TYPE.integer		: return 1 << 0 | 1 << 1;
		case VALUE_TYPE.float		: return 1 << 2 | 1 << 1;
		case VALUE_TYPE.boolean		: return 1 << 3 | 1 << 1;
		case VALUE_TYPE.color		: return 1 << 4;
		case VALUE_TYPE.gradient	: return 1 << 25;
		case VALUE_TYPE.dynaSurface	: 
		case VALUE_TYPE.surface		: return 1 << 5 | 1 << 23;
		case VALUE_TYPE.path		: return 1 << 10;
		case VALUE_TYPE.text		: return 1 << 10;
		case VALUE_TYPE.object		: return 1 << 13;
		case VALUE_TYPE.d3object	: return 1 << 14;
		case VALUE_TYPE.d3vertex	: return 1 << 24;
		
		case VALUE_TYPE.pathnode	: return 1 << 15;
		case VALUE_TYPE.particle	: return 1 << 16;
		case VALUE_TYPE.rigid   	: return 1 << 17;
		case VALUE_TYPE.sdomain 	: return 1 << 18;
		case VALUE_TYPE.struct   	: return 1 << 19;
		case VALUE_TYPE.strands   	: return 1 << 20;
		case VALUE_TYPE.mesh	  	: return 1 << 21;
		case VALUE_TYPE.armature  	: return 1 << 26 | 1 << 19;
		
		case VALUE_TYPE.node		: return 1 << 32;
		
		case VALUE_TYPE.buffer		: return 1 << 27;
		
		case VALUE_TYPE.pbBox		: return 1 << 28;
		
		case VALUE_TYPE.trigger		: return 1 << 22;
		case VALUE_TYPE.action		: return 1 << 22 | 1 << 3;
		
		case VALUE_TYPE.d3Mesh		: return 1 << 29;
		case VALUE_TYPE.d3Light		: return 1 << 29;
		case VALUE_TYPE.d3Camera	: return 1 << 29;
		case VALUE_TYPE.d3Scene		: return 1 << 29 | 1 << 30;
		case VALUE_TYPE.d3Material  : return 1 << 33;
		
		case VALUE_TYPE.PCXnode		: return 1 << 34;
		case VALUE_TYPE.audioBit	: return 1 << 35;
		case VALUE_TYPE.fdomain 	: return 1 << 36;
		case VALUE_TYPE.sdf 		: return 1 << 37;
		
		case VALUE_TYPE.curve 		: return 1 << 38;
		
		case VALUE_TYPE.any			: return ~0 & ~(1 << 32);
	}
	return 0;
}

function value_type_directional(f, t) {
	if(f == VALUE_TYPE.surface && t == VALUE_TYPE.integer)	return true;
	if(f == VALUE_TYPE.surface && t == VALUE_TYPE.float)	return true;
	
	if(f == VALUE_TYPE.integer && t == VALUE_TYPE.text) return true;
	if(f == VALUE_TYPE.float   && t == VALUE_TYPE.text) return true;
	if(f == VALUE_TYPE.boolean && t == VALUE_TYPE.text) return true;
	
	if(f == VALUE_TYPE.integer && t == VALUE_TYPE.color)	return true;
	if(f == VALUE_TYPE.float   && t == VALUE_TYPE.color)	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.integer)	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.float  )	return true;
	if(f == VALUE_TYPE.color   && t == VALUE_TYPE.gradient) return true;
	
	if(f == VALUE_TYPE.strands && t == VALUE_TYPE.pathnode ) return true;
	
	if(f == VALUE_TYPE.color    && t == VALUE_TYPE.struct ) return true;
	if(f == VALUE_TYPE.mesh     && t == VALUE_TYPE.struct ) return true;
	if(f == VALUE_TYPE.particle && t == VALUE_TYPE.struct ) return true;
	
	if(f == VALUE_TYPE.surface  && t == VALUE_TYPE.d3Material ) return true;
	
	return false;
}

function value_type_from_string(str) {
	switch(str) {
		case "integer"	: return VALUE_TYPE.integer;
		case "float"	: return VALUE_TYPE.float;
		case "boolean"	: return VALUE_TYPE.boolean;
		case "color"	: return VALUE_TYPE.color;
		case "surface"	: return VALUE_TYPE.surface;
		
		case "path"		: return VALUE_TYPE.path;
		case "curve"	: return VALUE_TYPE.curve;
		case "text"		: return VALUE_TYPE.text;
		case "object"	: return VALUE_TYPE.object;
		case "node"		: return VALUE_TYPE.node;
		case "d3object" : return VALUE_TYPE.d3object;
		
		case "any"		: return VALUE_TYPE.any;
		
		case "pathnode" : return VALUE_TYPE.pathnode;
		case "particle" : return VALUE_TYPE.particle;
		case "rigid"	: return VALUE_TYPE.rigid;
		case "sdomain"	: return VALUE_TYPE.sdomain;
		case "struct"	: return VALUE_TYPE.struct;
		case "strands"	: return VALUE_TYPE.strands;
		case "mesh"		: return VALUE_TYPE.mesh;
		case "trigger"	: return VALUE_TYPE.trigger;
		case "atlas"	: return VALUE_TYPE.atlas;
		
		case "d3vertex" : return VALUE_TYPE.d3vertex;
		case "gradient" : return VALUE_TYPE.gradient;
		case "armature" : return VALUE_TYPE.armature;
		case "buffer"	: return VALUE_TYPE.buffer;
		
		case "pbBox"	: return VALUE_TYPE.pbBox;
		
		case "d3Mesh"	:   return VALUE_TYPE.d3Mesh;
		case "d3Light"	:   return VALUE_TYPE.d3Light;
		case "d3Camera" :   return VALUE_TYPE.d3Camera;
		case "d3Scene"	:   return VALUE_TYPE.d3Scene;
		case "d3Material" : return VALUE_TYPE.d3Material;
		
		case "dynaSurface" : return VALUE_TYPE.dynaSurface;
		case "PCXnode"	   : return VALUE_TYPE.PCXnode;
		case "audioBit"	   : return VALUE_TYPE.audioBit;
		case "fDomain"	   : return VALUE_TYPE.fdomain;
		case "sdf"		   : return VALUE_TYPE.sdf;
		
		case "action"	: return VALUE_TYPE.action;
	}
	
	return VALUE_TYPE.any;
}

function value_type_direct_settable(type) {
	switch(type) {
		case VALUE_TYPE.integer :
		case VALUE_TYPE.float :
		case VALUE_TYPE.boolean :
		case VALUE_TYPE.color :
		case VALUE_TYPE.path :
		case VALUE_TYPE.text :
			return true;
	}
	
	return false;
}

function typeNumeric(type) {
	switch(type) {
		case VALUE_TYPE.integer :
		case VALUE_TYPE.float :
		case VALUE_TYPE.boolean :
			return true;
	}
	
	return false;
}

function typeArray(_type) {
	switch(_type) {
		case VALUE_DISPLAY.range :
		case VALUE_DISPLAY.vector_range :
		case VALUE_DISPLAY.rotation_range :
		case VALUE_DISPLAY.rotation_random :
		case VALUE_DISPLAY.slider_range :
		case VALUE_DISPLAY.path_anchor :
		case VALUE_DISPLAY.gradient_range :
		
		case VALUE_DISPLAY.vector :
		case VALUE_DISPLAY.padding :
		case VALUE_DISPLAY.area :
		case VALUE_DISPLAY.puppet_control :
		case VALUE_DISPLAY.matrix :
		case VALUE_DISPLAY.transform :
		case VALUE_DISPLAY.boolean_grid :
			
		case VALUE_DISPLAY.curve :
			
		case VALUE_DISPLAY.path_array :
		case VALUE_DISPLAY.palette :
		case VALUE_DISPLAY.text_array :
		
		case VALUE_DISPLAY.d3vertex :
		case VALUE_DISPLAY.d3quarternion :
			return 1;
	}
	return 0;
}

function typeCompatible(fromType, toType, directional_cast = true) {
	if(value_bit(fromType) & value_bit(toType) != 0)
		return true;
	if(!directional_cast) 
		return false;
	return value_type_directional(fromType, toType);
}

function typeIncompatible(from, to) {
	if(from.type == VALUE_TYPE.surface && (to.type == VALUE_TYPE.integer || to.type == VALUE_TYPE.float)) {
		switch(to.display_type) {
			case VALUE_DISPLAY.area : 
			case VALUE_DISPLAY.matrix : 
			case VALUE_DISPLAY.vector_range : 
			case VALUE_DISPLAY.puppet_control : 
			case VALUE_DISPLAY.padding : 
			case VALUE_DISPLAY.curve : 
				return true;
		}
	}
	
	return false;
}

function isGraphable(prop) {
	if(prop.type == VALUE_TYPE.integer || prop.type == VALUE_TYPE.float) {
		if(prop.display_type == VALUE_DISPLAY.puppet_control)
			return false;
		return true;
	}
	if(prop.type == VALUE_TYPE.color && prop.display_type == VALUE_DISPLAY._default) 
		return true;
		
	return false;
}

function nodeValueUnit(_nodeValue) constructor {
	self._nodeValue = _nodeValue;
	
	mode = VALUE_UNIT.constant;
	reference = noone;
	triggerButton = button(function() { 
		mode = !mode; 
		_nodeValue.cache_value[0] = false;
		_nodeValue.unitConvert(mode);
		_nodeValue.node.doUpdate();
	});
	triggerButton.icon_blend = COLORS._main_icon_light;
	triggerButton.icon       = THEME.unit_ref;
	triggerButton.tooltip    = new tooltipSelector("Unit", ["Pixel", "Fraction"]);
	
	static setMode = function(type) {
		if((type == "constant" || type == VALUE_UNIT.constant)  && mode == VALUE_UNIT.constant) return;
		if((type == "relative" || type == VALUE_UNIT.reference) && mode == VALUE_UNIT.reference) return;
		
		mode = (type == "constant" || type == VALUE_UNIT.constant)? VALUE_UNIT.constant : VALUE_UNIT.reference;
		_nodeValue.cache_value[0] = false;
		_nodeValue.unitConvert(mode);
		_nodeValue.node.doUpdate();
	}
	
	static draw = function(_x, _y, _w, _h, _m) {
		triggerButton.icon_index = mode;
		triggerButton.tooltip.index = mode;
		
		triggerButton.draw(_x, _y, _w, _h, _m, THEME.button_hide);
	}
	
	static invApply = function(value, index = 0) {
		if(mode == VALUE_UNIT.constant) 
			return value;
		if(reference == noone)
			return value;
		
		return convertUnit(value, VALUE_UNIT.reference, index);
	}
	
	static apply = function(value, index = 0) {
		if(mode == VALUE_UNIT.constant) return value;
		if(reference == noone)			return value;
		
		return convertUnit(value, VALUE_UNIT.constant, index);
	}
	
	static convertUnit = function(value, unitTo, index = 0) {
		var disp = _nodeValue.display_type;
		var base = reference(index);
		var inv  = unitTo == VALUE_UNIT.reference;
		
		if(!is_array(base)) {
			if(inv) base = base == 0? 0 : 1 / base;
			
			if(!is_array(value)) 
				return value * base;
				
			var _val = array_create(array_length(value));
			for( var i = 0, n = array_length(value); i < n; i++ )
				_val[i] = value[i] * base;
			return _val;
			
		} else if(is_array(value)) {
			if(inv) {
				base = [
					base[0] == 0? 0 : 1 / base[0],
					base[1] == 0? 0 : 1 / base[1],	
				];
			}
			
			switch(disp) {
				case VALUE_DISPLAY.padding :
				case VALUE_DISPLAY.vector :
				case VALUE_DISPLAY.vector_range :
					var _val = array_create(array_length(value));
					for( var i = 0, n = array_length(value); i < n; i++ )
						_val[i] = value[i] * base[i % 2];
					return _val;
					
				case VALUE_DISPLAY.area :
					var _val = array_clone(value);
					for( var i = 0; i < 4; i++ )
						_val[i] = value[i] * base[i % 2];
						
					return _val;
			}
		}
		
		return value;
		
	}
}