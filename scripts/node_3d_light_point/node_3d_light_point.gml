function Node_3D_Light_Point(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Point Light";
	
	inputs[| in_light + 0] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light, in_light,
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var object = new __3dLightPoint();
		
		setTransform(object, _data);
		setLight(object, _data);
		
		var _rad = inputs[| in_light + 0].getValue();
		object.radius = _rad;
		
		return object;
	}
}