function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name   = "3D Cube";
	object = new __3dCube();
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
	]
}