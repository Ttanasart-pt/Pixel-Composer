function Node_3D_Light_Point(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Point Light";
	
	object_class = __3dLightPoint;
	
	inputs[| in_light + 0] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
	
	inputs[| in_light + 1] = nodeValue("Cast Shadow", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_light + 2] = nodeValue("Shadow Map Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1024);
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light, in_light,
		["Shadow", false], in_light + 1, in_light + 2, in_light + 3, 
	]
	
	tools = [ tool_pos ];
	tool_settings = [];
	tool_attribute.context = 1;
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _active = _data[in_d3d + 0];
		if(!_active) return noone;
		
		var _radius          = _data[in_light + 0];
		var _shadow_active   = _data[in_light + 1];
		var _shadow_map_size = _data[in_light + 2];
		
		var object = getObject(_array_index);
		
		setTransform(object, _data);
		setLight(object, _data);
		object.setShadow(_shadow_active, _shadow_map_size);
		object.radius = _radius;
		
		return object;
	}
}