function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Cube";
	
	inputs[| input_mesh_index + 0] = nodeValue("Texture per side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| input_mesh_index + 1] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| input_mesh_index + 2] = nodeValue("Texture 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| input_mesh_index + 3] = nodeValue("Texture 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| input_mesh_index + 4] = nodeValue("Texture 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| input_mesh_index + 5] = nodeValue("Texture 5", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| input_mesh_index + 6] = nodeValue("Texture 6", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Texture",	false], input_mesh_index + 0, input_mesh_index + 1, input_mesh_index + 2, input_mesh_index + 3, 
							input_mesh_index + 4, input_mesh_index + 5, input_mesh_index + 6, 
	]
	
	static step = function() { #region
		var _tex_side = inputs[| input_mesh_index + 0].getValue();
		
		inputs[| input_mesh_index + 1].name = _tex_side? "Texture 1" : "Texture";
		inputs[| input_mesh_index + 1].setVisible(true, true);
		inputs[| input_mesh_index + 2].setVisible(_tex_side, _tex_side);
		inputs[| input_mesh_index + 3].setVisible(_tex_side, _tex_side);
		inputs[| input_mesh_index + 4].setVisible(_tex_side, _tex_side);
		inputs[| input_mesh_index + 5].setVisible(_tex_side, _tex_side);
		inputs[| input_mesh_index + 6].setVisible(_tex_side, _tex_side);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _tex_side = _data[input_mesh_index + 0];
		var _tex_1    = _data[input_mesh_index + 1];
		var _tex_2    = _data[input_mesh_index + 2];
		var _tex_3    = _data[input_mesh_index + 3];
		var _tex_4    = _data[input_mesh_index + 4];
		var _tex_5    = _data[input_mesh_index + 5];
		var _tex_6    = _data[input_mesh_index + 6];
		
		var object;
		if(_tex_side) {
			object = new __3dCubeFaces();
			object.texture = [ surface_texture(_tex_1), surface_texture(_tex_2), 
							   surface_texture(_tex_3), surface_texture(_tex_4), 
							   surface_texture(_tex_5), surface_texture(_tex_6) ];
		} else {
			object = new __3dCube();
			object.texture = surface_texture(_tex_1);
		}
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, input_mesh_index + 1, noone); }
}