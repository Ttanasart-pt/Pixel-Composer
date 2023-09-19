function Node_create_Custom(_x, _y, _group = noone, _param = {}) {
	if(!struct_has(_param, "path")) return noone;
	var path = _param.path;
	
	var node = new Node_Custom(_x, _y, _group);
	node.setPath(path);
	return node;
}

function Node_create_Custom_path(_x, _y, path) {
	if(!file_exists(path)) return noone;
	
	var node = new Node_Custom(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.setPath(path);
	return node;	
}

function Node_Custom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Custom";
	path = "";
	
	inputs[| 0] = nodeValue("Base Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	static setPath = function(path) {
		self.path = path;
	}
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Uniform", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
	}
	
	static onValueUpdate = function(index) { #region
		var _refresh = index == 0 || index == 1 ||
				(index >= input_fix_len && (index - input_fix_len) % data_length != 2);
		
		if(_refresh) {
			refreshShader();
			refreshDynamicInput();
		}
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _surf = _data[2];
		if(!is_surface(_surf)) return noone;
		if(!d3d11_shader_exists(shader.vs)) return noone;
		if(!d3d11_shader_exists(shader.fs)) return noone;
		
		_output = surface_verify(_output, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
		
		surface_set_target(_output);
		DRAW_CLEAR
		
		d3d11_shader_override_vs(shader.vs);
		d3d11_shader_override_ps(shader.fs);
		
		var uTypes = array_create(8, 0);
		var sampler_slot = 1;
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _cbSize = 0;
		
		for( var i = input_fix_len, n = array_length(_data); i < n; i += data_length ) {
			var _arg_name = _data[i + 0];
			var _arg_type = _data[i + 1];
			var _arg_valu = _data[i + 2];
			
			if(_arg_name == "") continue;
			
			var _uni = shader_get_uniform(shader.fs, _arg_name);
			
			switch(_arg_type) {
				case 1 : 
					d3d11_cbuffer_add_int(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_s32, _arg_valu);
					break;
				case 0 : 
					d3d11_cbuffer_add_float(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_f32, _arg_valu);
					break;
				case 2 : 
				case 3 : 
				case 4 : 
				case 5 : 
				case 6 : 
					if(is_array(_arg_valu)) {
						d3d11_cbuffer_add_float(array_length(_arg_valu)); 
						_cbSize += array_length(_arg_valu);
						
						for( var j = 0, m = array_length(_arg_valu); j < m; j++ ) 
							buffer_write(_buffer, buffer_f32, _arg_valu[j]);
					}
					break;
				case 8 : 
					var _clr = colToVec4(_arg_valu);
					d3d11_cbuffer_add_float(4);
					_cbSize += 4;
					
					for( var j = 0, m = 4; j < m; j++ ) 
						buffer_write(_buffer, buffer_f32, _clr[i]);
					break;
				case 7 : 
					if(is_surface(_arg_valu))
						d3d11_texture_set_stage_ps(sampler_slot, surface_get_texture(_arg_valu));
					sampler_slot++;
					break;
			}
		}
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		
		d3d11_shader_set_cbuffer_ps(10, cbuff);

		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 
			surface_get_width_safe(_surf), surface_get_height_safe(_surf), 1));
		vertex_submit(global.HLSL_VB, pr_trianglestrip, surface_get_texture(_surf));
		matrix_set(matrix_world, matrix_build_identity());
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		surface_reset_target();
		
		return _output;
	} #endregion
	
	static postConnect = function() { 
		refreshShader(); 
		refreshDynamicInput();
	}
}