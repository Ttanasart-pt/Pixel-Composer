function Node_3D_Mesh_Cube(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cube";
	object_class = noone;
	
	newInput(in_mesh + 0, nodeValue_Bool("Material per side", self, false ));
	
	newInput(in_mesh + 1, nodeValue_D3Material("Material", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 2, nodeValue_D3Material("Material Bottom", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 3, nodeValue_D3Material("Material Left", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 4, nodeValue_D3Material("Material Right", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 5, nodeValue_D3Material("Material Back", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 6, nodeValue_D3Material("Material Front", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 0, in_mesh + 1, in_mesh + 2, in_mesh + 3, in_mesh + 4, in_mesh + 5, in_mesh + 6, 
	]
	
	static onDrawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static step = function() { 
		var _mat_side = getInputData(in_mesh + 0);
		
		inputs[in_mesh + 1].name = _mat_side? "Material Top" : "Material";
		inputs[in_mesh + 1].setVisible(true, true);
		inputs[in_mesh + 2].setVisible(_mat_side, _mat_side);
		inputs[in_mesh + 3].setVisible(_mat_side, _mat_side);
		inputs[in_mesh + 4].setVisible(_mat_side, _mat_side);
		inputs[in_mesh + 5].setVisible(_mat_side, _mat_side);
		inputs[in_mesh + 6].setVisible(_mat_side, _mat_side);
	} 
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
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
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 1); }
}