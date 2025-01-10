#region shader cache
	globalvar SHADER_CACHE;
	
	SHADER_CACHE = {};
	
	function shader_compile_vs(file) {
		if(struct_has(SHADER_CACHE, file)) return SHADER_CACHE[$ file];
			
		var _sh = d3d11_shader_compile_vs(file, "main", "vs_4_0");
		SHADER_CACHE[$ file] = _sh;
		return _sh;
	}
	
	function shader_compile_ps(file) {
		if(struct_has(SHADER_CACHE, file)) return SHADER_CACHE[$ file];
			
		var _sh = d3d11_shader_compile_ps(file, "main", "ps_4_0");
		SHADER_CACHE[$ file] = _sh;
		return _sh;
	}
#endregion

function Node_Custom_Shader(_x, _y, _group = noone, _param = {}) : Node_Processor(_x, _y, _group) constructor {
	itype = _param[$ "iname"] ?? noone;
	
	shader_vs = noone;
	shader_fs = noone;
	
	sourceDir = _param[$ "sourceDir"] ?? "";
	dataPath  = _param[$ "data"] ?? "";
	
	uniforms = [];
	
	surface_in_index = 0;
	
	var _infoPath = sourceDir + "/" + dataPath;
	if(file_exists_empty(_infoPath)) {
		var info = json_load_struct(_infoPath);
		var _dir = sourceDir;
		
		shader_vs = shader_compile_vs($"{_dir}/{info.shader_vs}");
		if(!d3d11_shader_exists(shader_vs)) noti_warning(d3d11_get_error_string());
		
		shader_fs = shader_compile_ps($"{_dir}/{info.shader_fs}");
		if(!d3d11_shader_exists(shader_fs)) noti_warning(d3d11_get_error_string());
		
		inputs  = [];
		outputs = [];
		
		for( var i = 0, n = array_length(info.inputs); i < n; i++ ) {
			var _input    = info.inputs[i];
			var _name     = _input.name;
			var _type     = _input.type;
			var _valu     = _input.value;
			var _showIns  = _input[$ "show_in_inspector"] ?? true;
			var _showGra  = _input[$ "show_in_graph"]     ?? false;
			var _flag     = _input[$ "flag"];
			var _unif     = _input[$ "uniform"];
			var _n = noone;
			
			switch(_type) {
				case "surface" : _n = nodeValue(_name, self, CONNECT_TYPE.input, VALUE_TYPE.surface, _valu); break;
				case "float"   : _n = nodeValue(_name, self, CONNECT_TYPE.input, VALUE_TYPE.float,   _valu); break;
				case "int"     : _n = nodeValue(_name, self, CONNECT_TYPE.input, VALUE_TYPE.integer, _valu); break;
				case "color"   : _n = nodeValue(_name, self, CONNECT_TYPE.input, VALUE_TYPE.color,   _valu); break;
			}
			
			if(_flag == "SURFACE_IN") {
				_showGra = true;
				surface_in_index = i;
			}
			
			newInput(i, _n).setVisible(_showIns, _showGra);
			
			if(_unif != undefined) {
				array_push(uniforms, {
					uniform: _unif, 
					type: _type,
					index: i
				});
			}
		}
		
		for( var i = 0, n = array_length(info.outputs); i < n; i++ ) {
			var _output   = info.outputs[i];
			var _name     = _output.name;
			var _type     = _output.type;
			var _valu     = _output.value;
			var _showGra  = _output[$ "show_in_graph"] ?? false;
			var _flag     = _output[$ "flag"];
			
			newOutput(i, nodeValue_Output(_name, self, value_type_from_string(_type), _valu)).setVisible(_showGra);
		}
	
		if(struct_has(info, "input_display"))  input_display_list  = info.input_display;
		if(struct_has(info, "output_display")) output_display_list = info.output_display;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		if(!d3d11_shader_exists(shader_vs)) return noone;
		if(!d3d11_shader_exists(shader_fs)) return noone;
		
		var _surf = _data[surface_in_index];
		_output   = surface_verify(_output, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
		
		surface_set_target(_output);
		DRAW_CLEAR
		
		d3d11_shader_override_vs(shader_vs);
		d3d11_shader_override_ps(shader_fs);
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _sample = 1;
		var _cbSize = 0;
		
		for( var i = 0, n = array_length(uniforms); i < n; i++ ) {
			var _unif  = uniforms[i];
			var _index = _unif.index;
			var _utype = _unif.type;
			var _value = _data[_index];
			
			switch(_utype) {
				
				case "float" :													// u_float
					d3d11_cbuffer_add_float(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_f32, _value);
					break;
					
				case "int" :													// u_int
					d3d11_cbuffer_add_int(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_s32, _value);
					break;
					
				case "vec2" :													// u_vec2
				case "vec3" :													// u_vec3
				case "vec4" :													// u_vec4
				case "mat3" :													// u_mat3
				case "mat4" :													// u_mat4
					if(is_array(_value)) {
						d3d11_cbuffer_add_float(array_length(_value)); 
						_cbSize += array_length(_value);
						
						for( var j = 0, m = array_length(_value); j < m; j++ ) 
							buffer_write(_buffer, buffer_f32, _value[j]);
					}
					break;
					
				case "surface" :												// u_sampler2D
					if(is_surface(_value))
						d3d11_texture_set_stage_ps(_sample, surface_get_texture(_value));
					_sample++;
					break;
					
				case "color" :													// u_vec4 color
					var _clr = colToVec4(_value);
					d3d11_cbuffer_add_float(4);
					_cbSize += 4;
					
					for( var j = 0, m = 4; j < m; j++ ) 
						buffer_write(_buffer, buffer_f32, _clr[i]);
					break;
					
			}
		}
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		d3d11_shader_set_cbuffer_ps(10, cbuff);
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _cbSize = 0;
		
		buffer_write(_buffer, buffer_f32, surface_get_width_safe(_surf));
		buffer_write(_buffer, buffer_f32, surface_get_height_safe(_surf));
		d3d11_cbuffer_add_float(2); _cbSize += 2;
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		d3d11_shader_set_cbuffer_ps(4, cbuff);
		
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, surface_get_width_safe(_surf), surface_get_height_safe(_surf), 1));
		vertex_submit(global.HLSL_VB_PLANE, pr_trianglestrip, surface_get_texture(_surf));
		matrix_set(matrix_world, matrix_build_identity());
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		surface_reset_target();
		
		return _output;
	}
}