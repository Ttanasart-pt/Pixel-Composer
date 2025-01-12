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

function __Custom_Shader() constructor {
	shader_vs = noone;
	shader_fs = noone;
	
	static compile = function(vs, fs) {
		shader_vs = shader_compile_vs(vs);
		if(!d3d11_shader_exists(shader_vs)) noti_warning(d3d11_get_error_string());
		
		shader_fs = shader_compile_ps(fs);
		if(!d3d11_shader_exists(shader_fs)) noti_warning(d3d11_get_error_string());
		
		return self;
	}
	
	static isValid = function() { return d3d11_shader_exists(shader_vs) && d3d11_shader_exists(shader_fs); }
	
	static setUniforms = function(uniforms, _reg) {
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _sample = 1;
		var _cbSize = 0;
		
		for( var i = 0, n = array_length(uniforms); i < n; i++ ) {
			var _unif  = uniforms[i];
			var _utype = _unif.type;
			var _value = _unif.value;
			
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
					d3d11_cbuffer_add_float(4);
					_cbSize += 4;
					
					var _clr = colToVec4(_value);
					buffer_write(_buffer, buffer_f32, _clr[0]);
					buffer_write(_buffer, buffer_f32, _clr[1]);
					buffer_write(_buffer, buffer_f32, _clr[2]);
					buffer_write(_buffer, buffer_f32, _clr[3]);
					break;
					
			}
		}
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		d3d11_shader_set_cbuffer_ps(_reg, cbuff);
		
	}
	
	static set = function() {
		d3d11_shader_override_vs(shader_vs);
		d3d11_shader_override_ps(shader_fs);
	}
	
	static reset = function() {
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
	}

	static drawSurface = function(surface) {
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, surface_get_width_safe(surface), surface_get_height_safe(surface), 1));
			vertex_submit(global.HLSL_VB_PLANE, pr_trianglestrip, surface_get_texture(surface));
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	static drawEmpty = function(sw, sh) {
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, sw, sh, 1));
			vertex_submit(global.HLSL_VB_PLANE, pr_trianglestrip, -1);
		matrix_set(matrix_world, matrix_build_identity());
	}
}

function Node_Custom_Shader(_x, _y, _group = noone, _param = {}) : Node_Custom(_x, _y, _group, _param) constructor {
	multipass = false;
	
	shader     = noone;
	uniform    = [];
	
	shaders    = [];
	uniformMap = {};
	
	surface_index   = noone;
	dimension_index = noone;
	texfilter       = "none";
	
	attribute_surface_depth();
	
	static onParseInfo = function() {
		multipass = struct_has(node_info, "passes");
		texfilter = node_info[$ "texfilter"] ?? "none";
		
		for( var i = 0, n = array_length(node_info.inputs); i < n; i++ ) {
			var _input = inputs[i];
			var _info  = node_info.inputs[i];
			var _type  = _info.type;
			var _flag  = _info[$ "flag"];
			var _unif  = _info[$ "uniform"];
			
			if(_flag == "SURFACE_IN") {
				_input.setVisible(true, true);
				surface_index = i;
				
			} else if(_flag == "DIMENSION") {
				dimension_index = i;
			}
			
			if(_unif != undefined) {
				if(multipass) uniformMap[$ _unif] = { type: _type, index: i };
				else          array_push(uniform, { type: _type, index: i });
			}
		}
		
		if(multipass) {
			for( var i = 0, n = array_length(node_info.passes); i < n; i++ ) {
				var _pass = node_info.passes[i];
				shaders[i] = {
					shader: new __Custom_Shader().compile($"{sourceDir}/{_pass.shader_vs}", $"{sourceDir}/{_pass.shader_fs}"),
					uniforms: _pass.uniforms
				}
			}
			
			temp_surface = array_create(n, 0);
			
		} else {
			shader = new __Custom_Shader().compile($"{sourceDir}/{node_info.shader_vs}", $"{sourceDir}/{node_info.shader_fs}");
		}
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _surf = noone;
		var sw = 0;
		var sh = 0;
		
		if(surface_index != noone) {
			_surf = _data[surface_index];
			if(!is_surface(_surf)) return _output;
		
			sw = surface_get_width_safe(_surf);
			sh = surface_get_height_safe(_surf);
		}
		
		if(dimension_index != noone) {
			var _dim = _data[dimension_index];
			
			sw = _dim[0];
			sh = _dim[1];
		}
		
		if(sw == 0 || sh == 0) return _output;
		
		_output = surface_verify(_output, sw, sh, attrDepth());
		
		if(multipass) {
			var _draw = _surf;
			
			for( var i = 0, n = array_length(shaders); i < n; i++ ) {
				temp_surface[i] = surface_verify(temp_surface[i], sw, sh, attrDepth());
				
				var _sh = shaders[i];
				var _shader  = _sh.shader;
				var _uniform = _sh.uniforms;
				if(!_shader.isValid()) continue;
				
				for( var j = 0, m = array_length(_uniform); j < m; j++ ) {
					var _n = _uniform[j].name;
					
					if(struct_has(uniformMap, _n)) _uniform[j].value = _data[uniformMap[$ _n].index];
				}
				
				surface_set_target(temp_surface[i]);
				DRAW_CLEAR
				_shader.set();
				
				_shader.setUniforms(_uniform, 10)
				_shader.setUniforms([{ type: "vec2", value: [sw, sh] }], 4)
				
					gpu_set_tex_filter(texfilter == "linear");
					if(is_surface(_draw)) _shader.drawSurface(_draw);
					else _shader.drawEmpty(sw, sh);
					gpu_set_tex_filter(false);
					
				_shader.reset();
				surface_reset_target();
				
				_draw = temp_surface[i];
			}
			
			surface_set_shader(_output);
				draw_surface(temp_surface[n - 1], 0, 0);
			surface_reset_shader();
			
			return _output;
		} 
		
		if(!shader.isValid()) return _output;
		
		for( var i = 0, n = array_length(uniform); i < n; i++ )
			uniform[i].value = _data[uniform[i].index];
		
		surface_set_target(_output);
		DRAW_CLEAR
		shader.set();
	
		shader.setUniforms(uniform, 10)
		shader.setUniforms([{ type: "vec2", value: [sw, sh] }], 4)
			
			gpu_set_tex_filter(texfilter == "linear");
			if(is_surface(_surf)) shader.drawSurface(_surf);
			else shader.drawEmpty(sw, sh);
			gpu_set_tex_filter(false);
			
		shader.reset();
		surface_reset_target();
		
		return _output;
	}
}