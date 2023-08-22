function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Cube";
	
	object_class = noone;
	
	inputs[| in_mesh + 0] = nodeValue("Texture per side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_mesh + 1] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 2] = nodeValue("Texture Bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 3] = nodeValue("Texture Left", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 4] = nodeValue("Texture Right", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 5] = nodeValue("Texture Back", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| in_mesh + 6] = nodeValue("Texture Front", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Texture",	false], in_mesh + 0, in_mesh + 1, in_mesh + 2, in_mesh + 3, 
							in_mesh + 4, in_mesh + 5, in_mesh + 6, 
	]
	
	static newObject = function(_side) { 
		if(_side) return new __3dCubeFaces();
		return new __3dCube();
	}
	
	static step = function() { #region
		var _tex_side = inputs[| in_mesh + 0].getValue();
		
		inputs[| in_mesh + 1].name = _tex_side? "Texture Top" : "Texture";
		inputs[| in_mesh + 1].setVisible(true, true);
		inputs[| in_mesh + 2].setVisible(_tex_side, _tex_side);
		inputs[| in_mesh + 3].setVisible(_tex_side, _tex_side);
		inputs[| in_mesh + 4].setVisible(_tex_side, _tex_side);
		inputs[| in_mesh + 5].setVisible(_tex_side, _tex_side);
		inputs[| in_mesh + 6].setVisible(_tex_side, _tex_side);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _tex_side = _data[in_mesh + 0];
		var _tex_1    = _data[in_mesh + 1];
		var _tex_2    = _data[in_mesh + 2];
		var _tex_3    = _data[in_mesh + 3];
		var _tex_4    = _data[in_mesh + 4];
		var _tex_5    = _data[in_mesh + 5];
		var _tex_6    = _data[in_mesh + 6];
		
		var object;
		if(_tex_side) {
			object = getObject(_array_index, __3dCubeFaces);
			object.texture = [ surface_texture(_tex_1), surface_texture(_tex_2), 
							   surface_texture(_tex_3), surface_texture(_tex_4), 
							   surface_texture(_tex_5), surface_texture(_tex_6) ];
		} else {
			object = getObject(_array_index, __3dCube);
			object.texture = surface_texture(_tex_1);
		}
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get(all_inputs, in_mesh + 1, noone); }
}