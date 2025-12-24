function Node_3D_Mesh_Cylinder(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "3D Cylinder";
	object_class = __3dCylinder;
	
	////- Geometry
	
	newInput(in_mesh + 0, nodeValue_Int(   "Side", 8 )).setValidator(VV_min(3));
	newInput(in_mesh + 5, nodeValue_Bool(  "End caps", true ));
	newInput(in_mesh + 6, nodeValue_Int(   "Segments", 1 )).setValidator(VV_min(1));
	newInput(in_mesh + 7, nodeValue_Curve( "Profile", CURVE_DEF_11 ));
	
	////- Material
	
	newInput(in_mesh + 4, nodeValue_Bool(       "Smooth Side", false ));
	newInput(in_mesh + 1, nodeValue_D3Material( "Material Top")).setVisible(true, true);
	newInput(in_mesh + 2, nodeValue_D3Material( "Material Bottom")).setVisible(true, true);
	newInput(in_mesh + 3, nodeValue_D3Material( "Material Side")).setVisible(true, true);
		
	input_display_list = [
		__d3d_input_list_mesh, in_mesh + 0, in_mesh + 5, in_mesh + 6, in_mesh + 7, 
		__d3d_input_list_transform,
		["Material",	false], in_mesh + 4, in_mesh + 1, in_mesh + 2, in_mesh + 3, 
	]
	
	static step = function() {
		var _caps = getInputData(in_mesh + 5);
		
		inputs[in_mesh + 1].setVisible(_caps, _caps);
		inputs[in_mesh + 2].setVisible(_caps, _caps);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _side     = _data[in_mesh + 0];
		var _mat_top  = _data[in_mesh + 1];
		var _mat_bot  = _data[in_mesh + 2];
		var _mat_sid  = _data[in_mesh + 3];
		var _smt      = _data[in_mesh + 4];
		var _caps     = _data[in_mesh + 5];
		var _segments = _data[in_mesh + 6];
		var _profile  = _data[in_mesh + 7];
		
		var _profiles = array_create(_segments + 1);
		
		for( var i = 0; i <= _segments; i++ )
			_profiles[i] = eval_curve_x(_profile, i / _segments);
		
		var object = getObject(_array_index);
		object.checkParameter({ 
			sides:    _side, 
			smooth:   _smt,
			caps:     _caps,
			segment:  _segments,
			profiles: _profiles,
		});
		
		object.materials = [ _mat_sid, _mat_top, _mat_bot ];
		setTransform(object, _data);
		
		return object;
	}
	
	static getPreviewValues = function() { return getInputSingle(in_mesh + 1); }
}