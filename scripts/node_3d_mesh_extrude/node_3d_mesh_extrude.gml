function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Surface Extrude";
	
	object_class = __3dSurfaceExtrude;
	
	inputs[| in_mesh + 0] = nodeValue("Front Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Front Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| in_mesh + 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| in_mesh + 3] = nodeValue("Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_mesh + 4] = nodeValue("Double Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_mesh + 5] = nodeValue("Back Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[| in_mesh + 6] = nodeValue("Back Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| in_mesh + 7] = nodeValue("Front Height Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| in_mesh + 8] = nodeValue("Back Height Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [ in_mesh + 3,
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Extrude",		false], in_mesh + 0, in_mesh + 1,              in_mesh + 7,  
		["Backside",	false], in_mesh + 4, in_mesh + 5, in_mesh + 6, in_mesh + 8, 
	]
	
	temp_surface = [ noone, noone ];
	
	insp1UpdateTooltip   = "Refresh";
	insp1UpdateIcon      = [ THEME.refresh_20, 0, COLORS._main_value_positive ];
	
	static onInspector1Update = function(_fromValue = false) {
		for(var i = 0; i < process_amount; i++) {
			var _object = getObject(i);
			_object.initModel();
		}
	}
	
	static step = function() {
		var _double = getSingleValue(in_mesh + 4);
		
		inputs[| in_mesh + 5].setVisible(true, _double);
		inputs[| in_mesh + 6].setVisible(true, _double);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat  = _data[in_mesh + 0];
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _updt = _data[in_mesh + 3];
		
		var _back = _data[in_mesh + 4];
		var _bmat = _data[in_mesh + 5];
		var _bhgt = _data[in_mesh + 6];
		
		var _flv  = _data[in_mesh + 7];
		var _blv  = _data[in_mesh + 8];
		
		var _surf  = is_instanceof(_mat, __d3dMaterial)?  _mat.surface  : noone;
		var _bsurf = is_instanceof(_bmat, __d3dMaterial)? _bmat.surface : noone;
		
		if(!is_surface(_surf)) return noone;
		
		var _matN   = _mat.clone();
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
		
		var _dim   = surface_get_dimension(_surf);
		var _nSurf = surface_create(_dim[0] * 2, _dim[1]);
		
		surface_set_shader(_nSurf, sh_d3d_extrude_extends);
			shader_set_dim("dimension", _surf);
			
			draw_surface_safe(_surf, 0);
			if(_back) draw_surface_stretched_safe(_bsurf, _dim[0], 0, _dim[0], _dim[1]);
			else      draw_surface_stretched_safe(_surf,  _dim[0], 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		_matN.surface    = _nSurf;
		_object.materials = [ _matN ];
		
		setTransform(_object, _data);
		
		return _object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}