function Node_3D_Mesh(_x, _y, _group = noone) : Node_3DObject(_x, _y, _group) constructor {
	name = "3D Mesh";
	
	input_mesh_index = ds_list_size(inputs);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Mesh, noone);
	
	#macro __d3d_input_list_mesh ["Mesh", false]
	
	static update = function(frame = PROJECT.animator.current_frame) {
		setTransform();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}