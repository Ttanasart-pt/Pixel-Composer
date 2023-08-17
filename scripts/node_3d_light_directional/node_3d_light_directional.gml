function Node_3D_Light_Directional(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Directional Light";
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light,
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var object = new __3dLightDirectional();
		
		setTransform(object, _data);
		setLight(object, _data);
		
		var _rot = new __rot3().lookAt(object.position, new __vec3());
		object.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		return object;
	}
}