function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Surface Extrude";
	
	object_class = __3dSurfaceExtrude;
	
	newInput(in_mesh + 0, nodeValue_D3Material("Front Surface", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Surface("Front Height", self));
	
	newInput(in_mesh + 2, nodeValue_Bool("Smooth", self, false))
	
	newInput(in_mesh + 3, nodeValue_Bool("Always update", self, false));
	
	newInput(in_mesh + 4, nodeValue_Bool("Double Side", self, false));
	
	newInput(in_mesh + 5, nodeValue_D3Material("Back Surface", self, new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 6, nodeValue_Surface("Back Height", self));
	
	newInput(in_mesh + 7, nodeValue_Slider_Range("Front Height Level", self, [ 0, 1 ]));
	
	newInput(in_mesh + 8, nodeValue_Slider_Range("Back Height Level", self, [ 0, 1 ]));
	
	newInput(in_mesh + 9, nodeValue_D3Material("Front Texture", self, new __d3dMaterial()));
	
	newInput(in_mesh + 10, nodeValue_D3Material("Back Texture", self, new __d3dMaterial()));
	
	newInput(in_mesh + 11, nodeValue_D3Material("Side Texture", self, new __d3dMaterial()));
	
	input_display_list = [ in_mesh + 3,
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Extrude",  false], in_mesh + 0,  in_mesh +  1,               in_mesh + 7,  
		["Backside", false,  in_mesh + 4], in_mesh +  5, in_mesh +  6, in_mesh + 8, 
		["Texture",	 false], in_mesh + 9,  in_mesh + 10, in_mesh + 11, 
	]
	
	temp_surface = [ noone, noone ];
	
	setTrigger(1, "Refresh", [ THEME.refresh_20, 0, COLORS._main_value_positive ], function() /*=>*/ { for(var i = 0; i < process_amount; i++) getObject(i).initModel(); });
	
	static step = function() {
		var _double = getSingleValue(in_mesh + 4);
		
		inputs[in_mesh + 5].setVisible(true, _double);
		inputs[in_mesh + 6].setVisible(true, _double);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _fmat = _data[in_mesh + 0];
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _updt = _data[in_mesh + 3];
		
		var _back = _data[in_mesh + 4];
		var _bmat = _data[in_mesh + 5];
		var _bhgt = _data[in_mesh + 6];
		
		var _flv  = _data[in_mesh + 7];
		var _blv  = _data[in_mesh + 8];
		
		var _matF = _data[in_mesh +  9];
		var _matB = _data[in_mesh + 10];
		var _matS = _data[in_mesh + 11];
		
		var _surf  = is(_fmat, __d3dMaterial)? _fmat.surface : noone;
		var _bsurf = is(_bmat, __d3dMaterial)? _bmat.surface : noone;
		if(!is_surface(_surf)) return noone;
		
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