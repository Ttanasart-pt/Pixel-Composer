function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Surface Extrude";
	object_class = __3dSurfaceExtrude;
	
	////- =Transform
	newInput(in_mesh+12, nodeValue_Bool(   "Voxel Scale", false ));
	newInput(in_mesh+13, nodeValue_Float(  "Voxel Size",  .1    ));
	
	////- =Extrude
	newInput(in_mesh+0,  nodeValue_D3Material(   "Front Surface", new __d3dMaterial() )).setVisible(true, true);
	newInput(in_mesh+1,  nodeValue_Surface(      "Front Height" ));
	newInput(in_mesh+7,  nodeValue_Slider_Range( "Front Height Level", [ 0, 1 ] ));
	
	////- =Backside
	newInput(in_mesh+4,  nodeValue_Bool(         "Double Side",  false ));
	newInput(in_mesh+5,  nodeValue_D3Material(   "Back Surface", new __d3dMaterial() )).setVisible(true, true);
	newInput(in_mesh+6,  nodeValue_Surface(      "Back Height" ));
	newInput(in_mesh+8,  nodeValue_Slider_Range( "Back Height Level", [ 0, 1 ] ));
	
	////- =Texture
	newInput(in_mesh+2,  nodeValue_Bool(         "Smooth",        false ))
	newInput(in_mesh+3,  nodeValue_Bool(         "Always update", false ));
	newInput(in_mesh+9,  nodeValue_D3Material(   "Front Texture", new __d3dMaterial() ));
	newInput(in_mesh+10, nodeValue_D3Material(   "Back Texture",  new __d3dMaterial() ));
	newInput(in_mesh+11, nodeValue_D3Material(   "Side Texture",  new __d3dMaterial() ));
	// in_mesh+14
	
	input_display_list = [ in_mesh + 3,
		__d3d_input_list_mesh,
		__d3d_input_list_transform, in_mesh+12, in_mesh+13, 
		["Extrude",  false], in_mesh+0,  in_mesh+1,             in_mesh+7,  
		["Backside", false,  in_mesh+4], in_mesh+5,  in_mesh+6, in_mesh+8, 
		["Texture",	 false], in_mesh+9,  in_mesh+10, in_mesh+11, 
	]
	
	temp_surface = [ noone, noone ];
	
	setTrigger(1, "Refresh", [ THEME.refresh_20, 0, COLORS._main_value_positive ], function() /*=>*/ { 
		for(var i = 0; i < process_amount; i++) getObject(i).initModel(); 
		triggerRender();
	});
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _updt = _data[in_mesh +  3];
			
			var _vox  = _data[in_mesh + 12];
			var _voxs = _data[in_mesh + 13];
			
			var _fmat = _data[in_mesh +  0];
			var _hght = _data[in_mesh +  1];
			var _flv  = _data[in_mesh +  7];
			
			var _back = _data[in_mesh +  4];
			var _bmat = _data[in_mesh +  5];
			var _bhgt = _data[in_mesh +  6];
			var _blv  = _data[in_mesh +  8];
			
			var _smt  = _data[in_mesh +  2];
			var _matF = _data[in_mesh +  9];
			var _matB = _data[in_mesh + 10];
			var _matS = _data[in_mesh + 11];
			
			inputs[in_mesh + 5].setVisible(true, _back);
			inputs[in_mesh + 6].setVisible(true, _back);
			
			var _surf  = is(_fmat, __d3dMaterial)? _fmat.surface : noone;
			var _bsurf = is(_bmat, __d3dMaterial)? _bmat.surface : noone;
			if(!is_surface(_surf)) return noone;
		#endregion
		
		var _object = getObject(_array_index);
		_object.checkParameter( { 
			smooth  : _smt,
			
			surface : _surf, 
			height  : _hght, 
			
			back     : _back,
			bsurface : _bsurf, 
			bheight  : _bhgt, 
			
			flevel_min : _flv[0], 
			flevel_max : _flv[1],
			blevel_min : _blv[0], 
			blevel_max : _blv[1],
			
			voxel_use   : _vox,
			voxel_scale : _voxs,
		}, _updt);
		
		var _texF = is_surface(_matF.surface)? _matF : _fmat;
		var _texB = is_surface(_matB.surface)? _matB : (_back? _bmat : _fmat);
		var _texS = is_surface(_matS.surface)? _matS : _fmat;
		
		_object.materials = [ _texF, _texB, _texS ];
		
		setTransform(_object, _data);
		
		return _object;
	}
	
	static getPreviewValues = function() /*=>*/ {return getSingleValue(in_mesh + 0)};
}