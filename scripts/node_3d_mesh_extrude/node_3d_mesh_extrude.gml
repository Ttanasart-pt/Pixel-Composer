function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Surface Extrude";
	
	object_class = __3dSurfaceExtrude;
	
	inputs[| in_mesh + 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| in_mesh + 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| in_mesh + 3] = nodeValue("Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_mesh + 4] = nodeValue("Double Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| in_mesh + 5] = nodeValue("Back Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, new __d3dMaterial())
		.setVisible(true, true);
	
	inputs[| in_mesh + 6] = nodeValue("Back Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Extrude",		false], in_mesh + 0, in_mesh + 1, in_mesh + 3,
		["Textures",	false], in_mesh + 4, in_mesh + 5, in_mesh + 6, 
	]
	
	temp_surface = [ noone, noone ];
	
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
		
		var _surf  = is_instanceof(_mat, __d3dMaterial)?  _mat.surface  : noone;
		var _bsurf = is_instanceof(_bmat, __d3dMaterial)? _bmat.surface : noone;
		
		if(!is_surface(_surf)) return noone;
		
		var _matN  = _mat.clone();
		var object = getObject(_array_index);
		object.checkParameter( { 
			surface : _surf, 
			height  : _hght, 
			
			back     : _back,
			bsurface : _bsurf, 
			bheight  : _bhgt, 
			
			smooth  : _smt,
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
		object.materials = [ _matN ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}