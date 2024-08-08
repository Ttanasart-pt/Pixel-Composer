function Node_3D_Mesh_Cylinder(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "3D Cylinder";
	
	object_class = __3dCylinder;
	
	inputs[in_mesh + 0] = nodeValue_Int("Side", self, 8 )
		.setValidator(VV_min(3));
	
	inputs[in_mesh + 1] = nodeValue_D3Material("Material Top", self, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[in_mesh + 2] = nodeValue_D3Material("Material Bottom", self, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[in_mesh + 3] = nodeValue_D3Material("Material Side", self, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[in_mesh + 4] = nodeValue_Bool("Smooth Side", self, false );
	
	inputs[in_mesh + 5] = nodeValue_Bool("End caps", self, true );
	
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 4, in_mesh + 5, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 1, in_mesh + 2, in_mesh + 3, 
	]
	
	static step = function() { #region
		var _caps = getInputData(in_mesh + 5);
		
		inputs[in_mesh + 1].setVisible(_caps, _caps);
		inputs[in_mesh + 2].setVisible(_caps, _caps);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _side     = _data[in_mesh + 0];
		var _mat_top  = _data[in_mesh + 1];
		var _mat_bot  = _data[in_mesh + 2];
		var _mat_sid  = _data[in_mesh + 3];
		var _smt      = _data[in_mesh + 4];
		var _caps     = _data[in_mesh + 5];
		
		object_class = _caps? __3dCylinder : __3dCylinder_noCaps;
		
		var object = getObject(_array_index);
		object.checkParameter({ sides: _side, smooth: _smt });
		object.materials = _caps? [ _mat_top, _mat_bot, _mat_sid ] : [ _mat_sid ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 1, noone); }
}