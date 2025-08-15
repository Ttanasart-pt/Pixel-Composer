#region shader
	globalvar INSTANCE_SHADER_VS; INSTANCE_SHADER_VS = undefined;
	globalvar INSTANCE_SHADER_PS; INSTANCE_SHADER_PS = undefined;
	
	function __initInstanceRenderer() {
		if(INSTANCE_SHADER_VS != undefined && INSTANCE_SHADER_PS != undefined) return;
		if(!GMD3D11_IS_SUPPORTED) return;
		
		var _vp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dInstanceVS.hlsl";
		var _fp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dInstancePS.hlsl";
		
		INSTANCE_SHADER_VS = d3d11_shader_compile_vs(_vp, "main", "vs_4_0");
		INSTANCE_SHADER_PS = d3d11_shader_compile_ps(_fp, "main", "ps_4_0");
		
		if (!d3d11_shader_exists(INSTANCE_SHADER_VS)) noti_warning(d3d11_get_error_string());
		if (!d3d11_shader_exists(INSTANCE_SHADER_PS)) noti_warning(d3d11_get_error_string());
	}
	
#endregion

function __3dObjectInstancer() : __3dObject() constructor {
	instance_data   = noone;
	instance_amount = 128;
	
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	transform = new __transform();
	size      = new __vec3(1);
	
	__initInstanceRenderer();
	
	static setData = function() {
		d3d11_cbuffer_begin();
		d3d11_cbuffer_add_float(4 * instance_amount);
		instance_data = d3d11_cbuffer_end();
		
		if (!d3d11_cbuffer_exists(instance_data)) noti_warning("Could not create instanceData!");
		
		var _buffer = buffer_create(d3d11_cbuffer_get_size(instance_data), buffer_fixed, 1);
		
		repeat(instance_amount) {
			buffer_write(_buffer, buffer_f32, random_range(-20, 20)); 
			buffer_write(_buffer, buffer_f32, random_range(-20, 20)); 
			buffer_write(_buffer, buffer_f32, random_range(-20, 20));
			buffer_write(_buffer, buffer_f32, 0);
		}
		
		d3d11_cbuffer_update(instance_data, _buffer);
		buffer_delete(_buffer);
	}
	
	static generateNormal = function(_s = normal_draw_size) {}
	
	static submitShadow = function(_sc = {}, object = noone) /*=>*/ {}
	static submitSel	= function(_sc = noone, _sh = noone) /*=>*/ { submitVertex(_sc, _sh); }
	static submitShader = function(_sc = noone, _sh = noone) /*=>*/ { submitVertex(_sc, _sh); }
	static submit		= function(_sc = noone, _sh = noone) /*=>*/ { submitVertex(_sc, _sh); }
	
	static submitVertex = function(_sc = noone, _sh = noone) {
		d3d11_shader_override_vs(INSTANCE_SHADER_VS);
		d3d11_shader_override_ps(INSTANCE_SHADER_PS);
		
		if(is(_sc, __3dScene)) {
			d3d11_cbuffer_begin();
			var _buffer = buffer_create(1, buffer_grow, 1);
			var _cbSize = 0;
			_sc.fixArray();
			
			_cbSize += cbuffer_write_fs( _buffer, _sc.camera.position.toArray() );
			_cbSize += cbuffer_write_i(  _buffer, _sc.gammaCorrection     );
			
			_cbSize += cbuffer_write_c(  _buffer, _sc.lightAmbient        );
			_cbSize += cbuffer_write_i(  _buffer, _sc.lightDir_count      );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_direction );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_color     );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightDir_intensity );
			
			_cbSize += cbuffer_write_i(  _buffer, _sc.lightPnt_count      );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_position  );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_color     );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_intensity );
			_cbSize += cbuffer_write_fs( _buffer, _sc._lightPnt_radius    );
			
			if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
			var cbuff = d3d11_cbuffer_end();
			d3d11_cbuffer_update(cbuff, _buffer);
			buffer_delete(_buffer);
			
			d3d11_shader_set_cbuffer_ps(10, cbuff);
			
			////////////////////////////////////////////////////////////////////////////////////////////////
			
			d3d11_cbuffer_begin();
			var _buffer = buffer_create(1, buffer_grow, 1);
			var _cbSize = 0;
			
			_cbSize += cbuffer_write_f( _buffer, _sc.camera.view_near );
			_cbSize += cbuffer_write_f( _buffer, _sc.camera.view_far  );
			
			if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
			var cbuff = d3d11_cbuffer_end();
			d3d11_cbuffer_update(cbuff, _buffer);
			buffer_delete(_buffer);
			
			d3d11_shader_set_cbuffer_vs(11, cbuff);
			
		}
		
		preSubmitVertex(_sc);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		d3d11_shader_set_cbuffer_vs(10, instance_data);
		
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			var _ind = array_safe_get_fast(material_index, i, i);
			var _mat = array_safe_get_fast(materials, _ind, noone);
			var _tex = -1;
			
			if(is(_mat, __d3dMaterial)) {
				_tex = _mat.getTexture();
				
				d3d11_cbuffer_begin();
				var _buffer = buffer_create(1, buffer_grow, 1);
				var _cbSize = 0;
				
				_cbSize += cbuffer_write_f(  _buffer, _mat.diffuse    );
				_cbSize += cbuffer_write_f(  _buffer, _mat.specular   );
				_cbSize += cbuffer_write_f(  _buffer, _mat.shine      );
				_cbSize += cbuffer_write_i(  _buffer, _mat.metalic    );
				_cbSize += cbuffer_write_f(  _buffer, _mat.reflective );
				_cbSize += cbuffer_write_fs( _buffer, _mat.texScale   );
				_cbSize += cbuffer_write_fs( _buffer, _mat.texShift   );
				_cbSize += cbuffer_write_i(  _buffer, texture_flip    );
				
				if(_cbSize % 4) d3d11_cbuffer_add_float(4 - _cbSize % 4);
				var cbuff = d3d11_cbuffer_end();
				d3d11_cbuffer_update(cbuff, _buffer);
				buffer_delete(_buffer);
				
				d3d11_shader_set_cbuffer_ps(11, cbuff);
			}
					
			if(VBM != undefined) { matrix_stack_push(VBM[i]); matrix_set(matrix_world, matrix_stack_top()); }
			vertex_submit_instanced(VB[i], render_type, _tex, instance_amount);
			if(VBM != undefined) { matrix_stack_pop();        matrix_set(matrix_world, matrix_stack_top()); }
		}
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		
		postSubmitVertex(_sc);
	}
		
	static clone = function(_vertex = true) {}
	
	static destroy = function() {}
	
	static onDestroy = function() {} 
	
	static toString = function() { return $"[D3D Instanced Object]\n\t({instance_amount} instances\n\tPosition: {transform.position}\n\tRotation: {transform.rotation}\n\tScale: {transform.scale})" }
}