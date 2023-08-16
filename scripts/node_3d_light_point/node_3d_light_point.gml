function Node_3D_Light_Point(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Point Light";
	object = new __3dLightPoint();
	
	inputs[| input_light_index + 0] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light, input_light_index,
	]
	
	static update = function(frame = PROJECT.animator.current_frame) {
		setTransform();
		setLight();
		
		var _rad = inputs[| input_light_index + 0].getValue();
		object.radius = _rad;
	}
}