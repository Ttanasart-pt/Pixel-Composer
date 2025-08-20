#region shader
	globalvar INSTANCE_SHADER_VS;   INSTANCE_SHADER_VS   = undefined;
	globalvar INSTANCE_SHADER_PS;   INSTANCE_SHADER_PS   = undefined;
	globalvar INSTANCE_GEOMETRY_PS; INSTANCE_GEOMETRY_PS = undefined;
	globalvar INSTANCE_BATCH_SIZE;  INSTANCE_BATCH_SIZE  = os_type == os_windows? 1024 : 500; 
	// INSTANCE_BATCH_SIZE = 500;
	
	function __initInstanceRenderer() {
		if(INSTANCE_SHADER_VS != undefined && INSTANCE_SHADER_PS != undefined) return;
		if(!GMD3D11_IS_SUPPORTED) return;
		
		var _vp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dInstanceVS.hlsl";
		var _fp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dInstancePS.hlsl";
		var _gp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dInstanceGeometryPS.hlsl";
		
		INSTANCE_SHADER_VS   = d3d11_shader_compile_vs(_vp, "main", "vs_4_0");
		if (!d3d11_shader_exists(INSTANCE_SHADER_PS))   noti_warning(d3d11_get_error_string());
		
		INSTANCE_SHADER_PS   = d3d11_shader_compile_ps(_fp, "main", "ps_4_0");
		if (!d3d11_shader_exists(INSTANCE_SHADER_VS))   noti_warning(d3d11_get_error_string());
		
		INSTANCE_GEOMETRY_PS = d3d11_shader_compile_ps(_gp, "main", "ps_4_0");
		if (!d3d11_shader_exists(INSTANCE_GEOMETRY_PS)) noti_warning(d3d11_get_error_string());
	}
	
#endregion

function __3dObjectInstancer() : __3dObject() constructor {
	instance_data   = [];
	instance_amount = 128;
	batch_count     = 0;
	batch_amount    = [];
	
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	objectTransform = new __transform();
	transform = new __transform();
	size      = new __vec3(1);
	
	__initInstanceRenderer();
	
	vs = INSTANCE_SHADER_VS;
	ps = INSTANCE_SHADER_PS;
	gs = INSTANCE_GEOMETRY_PS;
	
	glsl_shader_default  = sh_d3d_default_instanced;
	glsl_shader_geometry = sh_d3d_geometry_instanced;
	
	static setBuffer = function(_buffer, _index, _amount) {
		if(OS == os_windows) {
			d3d11_cbuffer_begin();
			d3d11_cbuffer_add_float(16 * _amount);
			instance_data[_index] = d3d11_cbuffer_end();
			d3d11_cbuffer_update(instance_data[_index], _buffer);
			
		} else {
			_buffer = buffer_clone(_buffer);
			buffer_resize(_buffer, INSTANCE_BATCH_SIZE * 4 * 4 * 4);
			instance_data[_index] = _buffer;
		}
		
		batch_amount[_index] = _amount;
	}
	
	static generateNormal = function(_s = normal_draw_size) {}
	
	static submitShadow = function(_sc = {}, object = noone) /*=>*/ {}
	static submitSel	= function(_sc = noone, _sh = noone) /*=>*/ { submit(_sc, _sh); }
	static submitShader = function(_sc = noone, _sh = noone) /*=>*/ { submit(_sc, _sh); }
	static submit		= function(_sc = noone, _sh = noone) /*=>*/ { 
		if(OS == os_windows) submitVertex_HLSL(_sc, _sh); 
		else submitVertex_OpenGL(_sc, _sh); 
	}
	
	static submitCbuffer = function(b = 0) {
		if(OS == os_windows) d3d11_shader_set_cbuffer_vs(10, instance_data[b]);
		else {
			var _uniId = shader_get_uniform(shader_current(), "InstanceTransforms");
			shader_set_uniform_f_buffer(_uniId, instance_data[b], 0, INSTANCE_BATCH_SIZE * 4 * 4);
		}
	}
	
	static submitVertex_HLSL = function(_sc = noone, _sh = noone) {
		if(!is(_sc, __3dScene)) return;
			
		d3d11_shader_override_vs(vs);
		
		if(_sh == sh_d3d_geometry) {
			d3d11_shader_override_ps(gs);
			
		} else {
			d3d11_shader_override_ps(ps);
				
			d3d11_cbuffer_begin();
			var _buffer = buffer_create(1, buffer_grow, 1); buffer_to_start(_buffer);
			var _cbSize = 0;
			_sc.fixArray();
			
			_cbSize += cbuffer_write_fs( _buffer, _sc.camera.position.toArray() );
			_cbSize += cbuffer_write_i(  _buffer, _sc.gammaCorrection     );
			
			_cbSize += cbuffer_write_c(  _buffer, _sc.lightAmbient        );
			
			_cbSize += cbuffer_write_i(  _buffer, _sc.lightDir_count      );
			_cbSize += cbuffer_write_i(  _buffer, _sc.lightPnt_count      );
			_cbSize += cbuffer_write_i(  _buffer, 0 );
			_cbSize += cbuffer_write_i(  _buffer, 0 );
			
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_direction );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_color     );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_intensity );
			
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_position  );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_color     );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_intensity );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_radius    );
			
			if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
			var cbuff = d3d11_cbuffer_end();
			buffer_resize(_buffer, d3d11_cbuffer_get_size(cbuff));
			d3d11_cbuffer_update(cbuff, _buffer);
			buffer_delete(_buffer);
			
			d3d11_shader_set_cbuffer_ps(10, cbuff);
			
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1); buffer_to_start(_buffer);
		var _cbSize = 0;
		
		_cbSize += cbuffer_write_fs( _buffer, objectTransform.matTran );
		_cbSize += cbuffer_write_fs( _buffer, _sc.camera.position.toArray());
		_cbSize += cbuffer_write_f(  _buffer, _sc.camera.view_near );
		_cbSize += cbuffer_write_f(  _buffer, _sc.camera.view_far  );
		
		if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		buffer_resize(_buffer, d3d11_cbuffer_get_size(cbuff));
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		
		d3d11_shader_set_cbuffer_vs(11, cbuff);
		
		preSubmitVertex(_sc);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		////////////////////////////////////////////////////////////////////////////////////////////////
		
		gpu_set_zwriteenable(!transparent);
		draw_set_color_alpha(c_white, 1);
		
		for( var b = 0; b < batch_count; b++ ) {
			submitCbuffer(b);
			
			for( var i = 0, n = array_length(VB); i < n; i++ ) {
				var _mat = materials[i];
				var _tex = _mat.texture;
				
				d3d11_cbuffer_begin();
				var _buffer = buffer_create(1, buffer_grow, 1); buffer_to_start(_buffer);
				var _cbSize = 0;
				
				if(_sh == sh_d3d_geometry) {
					_cbSize += cbuffer_write_fs( _buffer, _mat.mat_texScale   );
					_cbSize += cbuffer_write_fs( _buffer, _mat.mat_texShift   );
					_cbSize += cbuffer_write_i(  _buffer, texture_flip        );
					
				} else {
					_cbSize += cbuffer_write_f(  _buffer, _mat.mat_diffuse    );
					_cbSize += cbuffer_write_f(  _buffer, _mat.mat_specular   );
					_cbSize += cbuffer_write_f(  _buffer, _mat.mat_shine      );
					_cbSize += cbuffer_write_i(  _buffer, _mat.mat_metalic    );
					_cbSize += cbuffer_write_f(  _buffer, _mat.mat_reflective );
					_cbSize += cbuffer_write_fs( _buffer, _mat.mat_texScale   );
					_cbSize += cbuffer_write_fs( _buffer, _mat.mat_texShift   );
					_cbSize += cbuffer_write_i(  _buffer, texture_flip    );
				}
				
				if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
				var cbuff = d3d11_cbuffer_end();
				buffer_resize(_buffer, d3d11_cbuffer_get_size(cbuff));
				d3d11_cbuffer_update(cbuff, _buffer);
				buffer_delete(_buffer);
				
				d3d11_shader_set_cbuffer_ps(11, cbuff);
				gpu_set_tex_filter(_mat.tex_filter);
				
				switch(blend_mode) {
					case BLEND.normal:  BLEND_NORMAL; break;
					case BLEND.alpha:   BLEND_ALPHA;  break;
					case BLEND.add:     BLEND_ADD;    break;
					case BLEND.maximum: BLEND_MAX;    break;
				}
				
				vertex_submit_instanced(VB[i], render_type, _tex, batch_amount[b]);
				
				BLEND_NORMAL
			}
		}
		
		gpu_set_tex_filter(false);
		gpu_set_zwriteenable(true);
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		
		postSubmitVertex(_sc);
	}

	static submitVertex_OpenGL = function(_sc = noone, _sh = noone) {
		
		_sc.reApply(glsl_shader_default);
		
		if(_sh == sh_d3d_geometry)
			shader_set(glsl_shader_geometry);
		else 
			shader_set(glsl_shader_default);
			
		preSubmitVertex(_sc);
		
		shader_set_uniform_matrix_array(shader_get_uniform(shader_current(), "objectTransform"), objectTransform.matTran);
		shader_set_3("cameraPosition", _sc.camera.position.toArray());
		
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		draw_set_color_alpha(c_white, 1);
		
		gpu_set_tex_repeat(true);
		for( var b = 0; b < batch_count; b++ ) {
			submitCbuffer(b);
			var _bamo = batch_amount[b];
			var _bind = 0;
			
			repeat(_bamo) {
				shader_set_i("InstanceID", _bind++);
				shader_set_i("mat_flip", texture_flip);
				
				for( var i = 0, n = array_length(VB); i < n; i++ ) {
					var _mat = materials[i];
					var _tex = _mat.texture;
					
					shader_set_i("use_normal", is_surface(_mat.use_normal));
					
					shader_set_surface("normal_map", _mat.normal_map      );
					shader_set_f("normal_strength",  _mat.normal_strength );
					
					shader_set_f("mat_diffuse",      _mat.mat_diffuse     );
					shader_set_f("mat_specular",     _mat.mat_specular    );
					shader_set_f("mat_shine",        _mat.mat_shine       );
					shader_set_i("mat_metalic",      _mat.mat_metalic     );
					shader_set_f("mat_reflective",   _mat.mat_reflective  );
					
					shader_set_f("mat_texScale",     _mat.mat_texScale    ); 
					shader_set_f("mat_texShift",     _mat.mat_texShift    ); 
					gpu_set_tex_filter(_mat.tex_filter); 
					
					vertex_submit(VB[i], render_type, _tex);
				}
				
			}
		}
		
		gpu_set_tex_filter(false);
		gpu_set_tex_repeat(false);
		
		shader_reset();
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		postSubmitVertex(_sc);
		
	}
	
		
	static clone = function(_vertex = true) {}
	
	static destroy = function() {}
	
	static onDestroy = function() {} 
	
	static toString = function() { return $"[D3D Instanced Object]\n\t({instance_amount} instances\n\tPosition: {transform.position}\n\tRotation: {transform.rotation}\n\tScale: {transform.scale})" }
}