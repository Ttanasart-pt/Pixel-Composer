function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name = "Surface Extrude";
	object_class = __3dSurfaceExtrude;
	var i = in_mesh;
	
	////- =Transform
	newInput(i+12, nodeValue_Bool(   "Voxel Scale", false ));
	newInput(i+13, nodeValue_Float(  "Voxel Size",  .1    ));
	
	////- =Extrude
	newInput(i+ 0, nodeValue_D3Material(   "Front Surface", new __d3dMaterial() )).setVisible(true, true);
	newInput(i+ 1, nodeValue_Surface(      "Front Height" ));
	newInput(i+ 7, nodeValue_Slider_Range( "Front Height Level", [ 0, 1 ] ));
	
	////- =Backside
	newInput(i+ 4, nodeValue_Bool(         "Double Side",  false ));
	newInput(i+ 5, nodeValue_D3Material(   "Back Surface", new __d3dMaterial() )).setVisible(true, true);
	newInput(i+ 6, nodeValue_Surface(      "Back Height" ));
	newInput(i+ 8, nodeValue_Slider_Range( "Back Height Level", [ 0, 1 ] ));
	
	////- =Texture
	newInput(i+ 2, nodeValue_Bool(         "Smooth",        false ))
	newInput(i+ 3, nodeValue_Bool(         "Always update", false ));
	newInput(i+ 9, nodeValue_D3Material(   "Front Texture", new __d3dMaterial() ));
	newInput(i+10, nodeValue_D3Material(   "Back Texture",  new __d3dMaterial() ));
	newInput(i+11, nodeValue_D3Material(   "Side Texture",  new __d3dMaterial() ));
	// i+14
	
	input_display_list = [ i+ 3,
		__d3d_input_list_mesh,
		__d3d_input_list_transform, i+12, i+13, 
		[ "Extrude",  false       ], i+ 0, i+ 1, i+ 7,  
		[ "Backside", false, i+ 4 ], i+ 5, i+ 6, i+ 8, 
		[ "Texture",  false       ], i+ 9, i+10, i+11, 
	]
	
	////- Nodes
	
	toRefresh    = false;
	temp_surface = [ noone ];
	
	insp1button = button(function() /*=>*/ { 
		toRefresh = true;
		triggerRender();
		
	}).setTooltip(__txt("Refresh"))
		.setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var i = in_mesh;
	
			var _updt = _data[i+ 3];
			
			var _vox  = _data[i+12];
			var _voxs = _data[i+13];
			
			var _fmat = _data[i+ 0];
			var _hght = _data[i+ 1];
			var _flv  = _data[i+ 7];
			
			var _back = _data[i+ 4];
			var _bmat = _data[i+ 5];
			var _bhgt = _data[i+ 6];
			var _blv  = _data[i+ 8];
			
			var _smt  = _data[i+ 2];
			var _matF = _data[i+ 9];
			var _matB = _data[i+10];
			var _matS = _data[i+11];
			
			inputs[i+5].setVisible(true, _back);
			inputs[i+6].setVisible(true, _back);
			
			var _surf  = is(_fmat, __d3dMaterial)? _fmat.surface : _fmat;
			var _bsurf = is(_bmat, __d3dMaterial)? _bmat.surface : _bmat;
		#endregion
		
		var _object = getObject(_array_index);
		if(!is_surface(_surf)) return _object;
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		var ss = max(ww, hh);
		
		temp_surface[0] = surface_verify(temp_surface[0], ss, ss);
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface(_surf, floor(ss / 2 - ww / 2), floor(ss / 2 - hh / 2));
			BLEND_NORMAL
		surface_reset_target();
		
		if(toRefresh) {
			_object.destroy();
			_object = new __3dSurfaceExtrude();
			toRefresh = false;
		}
		
		_object.checkParameter({ 
			smooth  : _smt,
			
			surface : temp_surface[0], 
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
	
}