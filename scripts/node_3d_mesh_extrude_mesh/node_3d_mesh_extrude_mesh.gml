function Node_3D_Mesh_Extrude_Mesh(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Mesh Extrude";
	object_class = __3dMeshExtrude;
	
	var i = in_mesh;
	newInput(i+3, nodeValue_Bool(  "Always update", false ));
	
	////- =Mesh
	newInput(i+0, nodeValue_Mesh(   "Mesh" )).setVisible(true, true);
	newInput(i+1, nodeValue_Float(  "Thickness",     1     ));
	newInput(i+2, nodeValue_Bool(   "Smooth",        false ))
	newInput(i+7, nodeValue_Slider( "Taper",         0     ))
	
	////- =Render
	newInput(i+4, nodeValue_D3Material( "Face Texture" )).setVisible(true, true);
	newInput(i+5, nodeValue_D3Material( "Side Texture" )).setVisible(true, true);
	newInput(i+6, nodeValue_D3Material( "Back Texture" )).setVisible(true, true);
	// input i+7
	
	input_display_list = [ i+3,
		__d3d_input_list_mesh, i+0, i+1, i+2, i+7, 
		__d3d_input_list_transform,
		["Render", false], i+4, i+5, i+6,  
	]
	
	////- Nodes
	
	temp_surface = [ noone, noone ];
	
	insp1button = button(function() /*=>*/ { 
		for(var i = 0; i < process_amount; i++) getObject(i).initModel(); 
		triggerRender();
	}).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _updt = _data[in_mesh + 3];
		
		var _mesh = _data[in_mesh + 0];
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _tap  = _data[in_mesh + 7];
		
		var _tex_crs = _data[in_mesh + 4];
		var _tex_sid = _data[in_mesh + 5];
		var _tex_bck = _data[in_mesh + 6];
		
		if(!is(_mesh, Mesh)) return noone;
		
		var _object = getObject(_array_index);
		_object.checkParameter( { 
			mesh   : _mesh,
			taper  : _tap,
			height : _hght, 
			smooth : _smt, 
		}, _updt);
		
		_object.materials = [ _tex_crs, _tex_bck, _tex_sid ];
		
		setTransform(_object, _data);
		
		return _object;
	}
	
	static getPreviewValues = function() { return getInputSingle(in_mesh + 0); }
}