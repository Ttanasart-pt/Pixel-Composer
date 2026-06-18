#macro nodeValue_Rot nodeValue_Rotation
function nodeValue_Rotation(_name, _value, _tooltip = "") { return new __NodeValue_Rotation(_name, self, _value, _tooltip); }

function __NodeValue_Rotation(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, _tooltip) constructor {
	setDisplay(VALUE_DISPLAY.rotation);
	preview_hotkey_spr = THEME.tools_2d_rotate;
	hideLabel();
	
	anim_presets = [
		[ "0, 360",  [[ 0, 0 ], [ 1, 360 ]], THEME.apreset_01 ], 
		[ "360, 0",  [[ 0, 360 ], [ 1, 0 ]], THEME.apreset_10 ], 
		-1, 
		[ "Zero to Current", [[ 0, 0 ], noone] ], 
		[ "Current to 360 ", [noone, [ 1,360]] ], 
		-1, 
		[ "Current + 360", [[ 0, function(v) /*=>*/ {return v} ], [ 1, function(v) /*=>*/ {return v+360} ]] ], 
		[ "Current - 360", [[ 0, function(v) /*=>*/ {return v} ], [ 1, function(v) /*=>*/ {return v-360} ]] ], 
	];
	
	////- GET
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		
		if(typ == VALUE_TYPE.text) val = toNumber(val);
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _rad = 64, _type = 0) { 
		if(attributes[$ "mapped"]) return -1;
		if(expUse) return -1;
		
		__preview_bbox = node.__preview_bbox;
		return preview_overlay_rotation(hover, active, _x, _y, _s, _mx, _my, _rad, _type);
	}
	
}