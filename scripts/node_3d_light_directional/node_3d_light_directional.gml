function Node_3D_Light_Directional(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name = "Directional Light";
	
	object_class = __3dLightDirectional;
	
	inputs[| in_light + 0] = nodeValue("Cast Shadow", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_light + 1] = nodeValue("Shadow Map Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1024);
	
	inputs[| in_light + 2] = nodeValue("Shadow Map Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| in_light + 3] = nodeValue("Shadow Bias", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .001);
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light,
		["Shadow", false], in_light + 0, in_light + 1, in_light + 2, in_light + 3, 
	]
	
	tools = [ tool_pos ];
	tool_settings = [];
	tool_attribute.context = 1;
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _active = _data[in_d3d + 0];
		if(!_active) return noone;
		
		var _shadow_active   = _data[in_light + 0];
		var _shadow_map_size = _data[in_light + 1];
		var _shadow_map_scal = _data[in_light + 2];
		var _shadow_bias     = _data[in_light + 3];
		
		var object = getObject(_array_index);
		
		setTransform(object, _data);
		setLight(object, _data);
		object.setShadow(_shadow_active, _shadow_map_size, _shadow_map_scal);
		object.shadow_bias = _shadow_bias;
		
		var _rot = new __rot3().lookAt(object.transform.position, new __vec3());
		object.transform.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		return object;
	}
}