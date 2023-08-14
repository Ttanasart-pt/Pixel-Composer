function Node_3D_Light_Directional(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name   = "Directional Light";
	object = new __3dLightDirectional();
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light,
	]
	
	static update = function(frame = PROJECT.animator.current_frame) {
		setTransform();
		setLight();
		
		object.rotation.lookAt(object.position, new __vec3());
	}
}