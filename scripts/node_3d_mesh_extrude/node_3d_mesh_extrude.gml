function Node_3D_Mesh_Extrude(_x, _y, _group = noone) : Node_3D_Mesh(_x, _y, _group) constructor {
	name     = "Surface Extrude";
	
	object_class = __3dSurfaceExtrude;
	
	inputs[| in_mesh + 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone)
		.setVisible(true, true);
	
	inputs[| in_mesh + 1] = nodeValue("Height map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| in_mesh + 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| in_mesh + 3] = nodeValue("Always update", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [
		__d3d_input_list_mesh,
		__d3d_input_list_transform,
		["Extrude",	false], in_mesh + 0, in_mesh + 1, in_mesh + 3, 
	]
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _mat  = _data[in_mesh + 0];
		if(!is_instanceof(_mat, __d3dMaterial)) return noone;
		
		var _hght = _data[in_mesh + 1];
		var _smt  = _data[in_mesh + 2];
		var _updt = _data[in_mesh + 3];
		var _surf = _mat.surface;
		
		temp_surface[0] = surface_cvt_8unorm(temp_surface[0], _surf);
		temp_surface[1] = surface_cvt_8unorm(temp_surface[1], _hght);
		
		var object = getObject(_array_index);
		object.checkParameter({ surface: temp_surface[0], height: temp_surface[1], smooth: _smt }, _updt);
		
		var _matN  = _mat.clone();
		var _nSurf = surface_create(surface_get_width(_surf), surface_get_height(_surf));
		
		surface_set_shader(_nSurf, sh_d3d_extrude_extends);
			shader_set_dim("dimension", _surf);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		_matN.surface    = _nSurf;
		object.materials = [ _matN ];
		
		setTransform(object, _data);
		
		return object;
	} #endregion
	
	static getPreviewValues = function() { return array_safe_get_fast(all_inputs, in_mesh + 0, noone); }
}