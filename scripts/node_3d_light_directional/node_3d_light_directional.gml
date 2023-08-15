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
		
		var _rot = new __rot3().lookAt(object.position, new __vec3());
		object.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
	}
}