function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Cube";
	
	object_class = noone;
	
	inputs[| in_mesh + 0] = nodeValue("Material per side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| in_mesh + 1] = nodeValue("Material", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 2] = nodeValue("Material Bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 3] = nodeValue("Material Left", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 4] = nodeValue("Material Right", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 5] = nodeValue("Material Back", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	inputs[| in_mesh + 6] = nodeValue("Material Front", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial() )
		.setVisible(true, true);
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 0, in_mesh + 1, in_mesh + 2, in_mesh + 3, 
							in_mesh + 4, in_mesh + 5, in_mesh + 6, 
	]
	
	static step = function() { #region
		var _mat_side = getInputData(in_mesh + 0);
		
		inputs[| in_mesh + 1].name = _mat_side? "Material Top" : "Material";
		inputs[| in_mesh + 1].setVisible(true, true);
		inputs[| in_mesh + 2].setVisible(_mat_side, _mat_side);
		inputs[| in_mesh + 3].setVisible(_mat_side, _mat_side);
		inputs[| in_mesh + 4].setVisible(_mat_side, _mat_side);
		inputs[| in_mesh + 5].setVisible(_mat_side, _mat_side);
		inputs[| in_mesh + 6].setVisible(_mat_side, _mat_side);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat_side = _data[in_mesh + 0];
		var _mat_1    = _data[in_mesh + 1];
		var _mat_2    = _data[in_mesh + 2];
		var _mat_3    = _data[in_mesh + 3];
		var _mat_4    = _data[in_mesh + 4];
		var _mat_5    = _data[in_mesh + 5];
		var _mat_6    = _data[in_mesh + 6];
		
		var object;
		if(_mat_side) {
			object = getObject(_array_index, __3dCubeFaces);
			object.materials = [ _mat_1, _mat_2, _mat_3, _mat_4, _mat_5, _mat_6 ];
		} else {
			object = getObject(_array_index, __3dCube);
			object.materials = [ _mat_1 ];
		}
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 1, noone); }
}