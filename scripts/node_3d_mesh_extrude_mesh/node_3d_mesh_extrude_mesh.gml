function Node_3D_Mesh_Extrude_Mesh(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Mesh Extrude";
	object_class = __3dMeshExtrude;
	
	newInput(in_mesh + 0, nodeValue("Mesh", self, CONNECT_TYPE.input, VALUE_TYPE.mesh, noone))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Float("Thickness", self, 1));
	
	newInput(in_mesh + 2, nodeValue_Bool("Smooth", self, false))
	
	newInput(in_mesh + 3, nodeValue_Bool("Always update", self, false));
	
	newInput(in_mesh + 4, nodeValue_D3Material("Face Texture", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 5, nodeValue_D3Material("Side Texture", self, new __d3dMaterial()))
		.setVisible(true, true);
		
	newInput(in_mesh + 6, nodeValue_D3Material("Back Texture", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	input_display_list = [ in_mesh + 3,
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Mesh",   false], in_mesh + 0, in_mesh + 1, in_mesh + 2, 
		["Render", false], in_mesh + 4, in_mesh + 5, in_mesh + 6,  
	]
	
	temp_surface = [ noone, noone ];
	
	setTrigger(1, "Refresh", [ THEME.refresh_20, 0, COLORS._main_value_positive ], function() /*=>*/ { for(var i = 0; i < process_amount; i++) getObject(i).initModel(); });
	
	static processData = function(_output, _data, _array_index = 0) {
		var _mesh = _data[in_mesh + 0];
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _updt = _data[in_mesh + 3];
		
		var _tex_crs = _data[in_mesh + 4];
		var _tex_sid = _data[in_mesh + 5];
		var _tex_bck = _data[in_mesh + 6];
		
		if(!is(_mesh, Mesh)) return noone;
		
		var _object = getObject(_array_index);
		_object.checkParameter( { 
			mesh   : _mesh,
			height : _hght, 
			smooth : _smt, 
		}, _updt);
		
		_object.materials = [ _tex_crs, _tex_bck, _tex_sid ];
		
		setTransform(_object, _data);
		
		return _object;
	}
	
	static getPreviewValues = function() { return getSingleValue(in_mesh + 0); }
}