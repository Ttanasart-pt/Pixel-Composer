function Node_3D_Light_Point(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Point Light";
	
	object_class = __3dLightPoint;
	
	newInput(in_light + 0, nodeValue_Float("Radius", self, 4))
	
	newInput(in_light + 1, nodeValue_Bool("Cast Shadow", self, false))
		.setWindows();
	
	newInput(in_light + 2, nodeValue_Int("Shadow Map Size", self, 1024))
		.setWindows();
	
	newInput(in_light + 3, nodeValue_Float("Shadow Bias", self, 0.01))
		.setWindows();
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light, in_light,
		["Shadow", false, in_light + 1], in_light + 2, in_light + 3, 
	]
	
	tools = [ tool_pos ];
	tool_settings = [];
	tool_attribute.context = 1;
	
	static processData = function(_output, _data, _array_index = 0) {
		var _active = _data[in_d3d + 0];
		if(!_active) return noone;
		
		var _radius          = _data[in_light + 0];
		var _shadow_active   = _data[in_light + 1];
		var _shadow_map_size = _data[in_light + 2];
		var _shadow_bias     = _data[in_light + 3];
		
		var _object = getObject(_array_index);
		
		setTransform(_object, _data);
		setLight(_object, _data);
		_object.setShadow(_shadow_active, _shadow_map_size);
		_object.radius = _radius;
		_object.shadow_bias = _shadow_bias * 100;
		
		return _object;
	}
}