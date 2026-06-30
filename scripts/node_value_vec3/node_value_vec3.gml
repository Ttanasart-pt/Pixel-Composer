function nodeValue_Vec3(  _name, _value, _data = {} ) { return new __NodeValue_Vec3(  _name, self, _value, _data ); }
function nodeValue_IVec3( _name, _value, _data = {} ) { return new __NodeValue_IVec3( _name, self, _value, _data ); }

function __NodeValue_Vec3(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 3) constructor {
	if(is_bool(_data)) _data = {linked: _data};
	setDisplay(VALUE_DISPLAY.vector, _data);
	
	extract_node = "Node_Vector3";
	anim_presets = [
		[ "0, 1",  [ [0, [0,0,0]], [1, [1,1,1]] ], THEME.apreset_01 ], 
		[ "1, 0",  [ [0, [1,1,1]], [1, [0,0,0]] ], THEME.apreset_10 ], 
		-1, 
		[ "Zero to Current", [[0,[0,0,0]], noone] ], 
		[ "Current to One ", [noone, [1,[1,1,1]]] ], 
	];
	
}

function __NodeValue_IVec3(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	type_array = 1;
	def_length = 3;
	
	setDisplay(VALUE_DISPLAY.vector, _data);
}