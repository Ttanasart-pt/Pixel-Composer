#region vertex format
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_color();
	global.VF_POS_COL = vertex_format_end();
	
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	vertex_format_add_color();
	global.VF_POS_NORM_TEX_COL = vertex_format_end();
#endregion

function __3dObject() constructor {
	vertex = [];
	normal_vertex = [];
	object_counts = 1;
	VB  = noone;
	
	NVB = noone;
	normal_draw_size = 0.2;
	
	VF = global.VF_POS_COL;
	render_type = pr_trianglelist;
	
	custom_shader = noone;
	
	position = new __vec3(0);
	rotation = new BBMOD_Quaternion();
	scale    = new __vec3(1);
	size     = new __vec3(1);
	
	materials = [];
	
	static checkParameter = function(params = {}, forceUpdate = false) { #region
		var _keys = struct_get_names(params);
		var check = false;
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var key = _keys[i];
			if(self[$ key] != params[$ key])
				check = true;
			self[$ key] = params[$ key];
		}
		
		if(forceUpdate || check) onParameterUpdate();
	} #endregion
	
	static onParameterUpdate = function() {}
	
	static generateNormal = function() { #region
		if(render_type != pr_trianglelist) return;
		
		NVB = array_create(object_counts);
		var _s = normal_draw_size;
		
		for( var i = 0; i < object_counts; i++ ) {
			NVB[i] = vertex_create_buffer();
			
			vertex_begin(NVB[i], global.VF_POS_COL);
				for( var j = 0, n = array_length(vertex[i]); j < n; j++ ) {
					var _v = vertex[i][j];
					
					vertex_position_3d(NVB[i], _v.x, _v.y, _v.z);
					vertex_color(NVB[i], c_red, 1);
					
					vertex_position_3d(NVB[i], _v.x + _v.nx * _s, _v.y + _v.ny * _s, _v.z + _v.nz * _s);
					vertex_color(NVB[i], c_red, 1);
				}
			vertex_end(NVB[i]);
		}
	} #endregion
	
	static buildVertex = function(_vertex, _normal, _uv) { #region
		var _buffer = vertex_create_buffer();
		vertex_begin(_buffer, VF);
			for( var i = 0, n = array_length(_vertex); i < n; i++ ) {
				var v = _vertex[i];
				
				switch(VF) {
					case global.VF_POS_COL :			vertex_add_vc(_buffer, v);		break;
					case global.VF_POS_NORM_TEX_COL :	vertex_add_vntc(_buffer, v);	break;
				}
			}
		vertex_end(_buffer);
		
		return _buffer;
	} #endregion
	
	static build = function(_buffer = VB, _vertex = vertex, counts = object_counts) { #region
		if(is_array(_buffer)) {
			for( var i = 0, n = array_length(_buffer); i < n; i++ )
				vertex_delete_buffer(_buffer[i])
		} else if(_buffer != noone) vertex_delete_buffer(_buffer);
		
		if(array_empty(_vertex)) return noone;
		
		var _res = array_create(counts);
		for( var i = 0; i < counts; i++ )
			_res[i] = buildVertex(_vertex[i]);
		
		return _res;
	} #endregion
	
	static preSubmitVertex  = function(scene = {}) {}
	static postSubmitVertex = function(scene = {}) {}
	
	static getCenter = function() { return new __vec3(position.x, position.y, position.z); }
	static getBBOX   = function() { return new __bbox3D(size.multiplyVec(scale).multiply(-0.5), size.multiplyVec(scale).multiply(0.5)); }
	
	static submitShader = function(scene = {}, shader = noone) {}
	
	static submit    = function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitUI  = function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	
	static submitSel = function(scene = {}) { #region
		var _s = variable_clone(scene);
		_s.show_normal = false;
		submitVertex(_s, sh_d3d_silhouette); 
	} #endregion
	
	static submitVertex = function(scene = {}, shader = noone) { #region
		var _shader = sh_d3d_default;
		
		switch(VF) {
			case global.VF_POS_NORM_TEX_COL: _shader = sh_d3d_default;		break;
			case global.VF_POS_COL:			 _shader = sh_d3d_wireframe;	break;
		}
		
		if(custom_shader != noone) _shader = custom_shader;
		if(shader != noone)        _shader = shader;

		shader_set(_shader);
		
		preSubmitVertex(scene);
		
		if(VB != noone) { #region
			matrix_stack_clear();
			
			if(scene.apply_transform) {
				var pos = matrix_build(position.x, position.y, position.z, 
									   0, 0, 0, 
									   1, 1, 1);
				var rot = rotation.ToMatrix();
				var sca = matrix_build(0, 0, 0, 
									   0, 0, 0, 
									   scale.x,    scale.y,    scale.z);
								   
				matrix_stack_push(pos);
				matrix_stack_push(rot);
				matrix_stack_push(sca);
				matrix_set(matrix_world, matrix_stack_top());
			} else {
				var pos = matrix_build(position.x - scene.custom_transform.x, position.y - scene.custom_transform.y, position.z - scene.custom_transform.z, 
									   0, 0, 0, 
									   1, 1, 1);
				var siz = matrix_build(0, 0, 0, 
									   0, 0, 0, 
									   scale.x,    scale.y,    scale.z);
				var sca = matrix_build(0, 0, 0, 
									   0, 0, 0, 
									   scene.custom_scale.x, scene.custom_scale.y, scene.custom_scale.z);
				
				matrix_stack_push(pos);
				matrix_stack_push(siz);
				matrix_stack_push(sca);
				matrix_set(matrix_world, matrix_stack_top());
			}
		} #endregion
		
		#region ++++ Submit & Material ++++
			for( var i = 0, n = array_length(VB); i < n; i++ ) {
				if(_shader == sh_d3d_default) {
					var _mat = array_safe_get(materials, i, noone);
					if(_mat == noone) {
						shader_set_f("mat_diffuse",    1);
						shader_set_f("mat_specular",   0);
						shader_set_f("mat_shine",      1);
						shader_set_i("mat_metalic",    0);
						shader_set_i("mat_use_normal", 0);
						shader_set_f("mat_reflective", 0);
					} else 
						_mat.submitShader();
			
					var _tex = _mat == noone? -1 : _mat.getTexture();
					vertex_submit(VB[i], render_type, _tex);
				} else
					vertex_submit(VB[i], render_type, -1);
			}
		#endregion
		
		shader_reset();
		
		if(scene.show_normal && NVB != noone) { #region
			if(NVB == noone) generateNormal();
			if(NVB != noone) {
				shader_set(sh_d3d_wireframe);
				for( var i = 0, n = array_length(NVB); i < n; i++ ) 
					vertex_submit(NVB[i], pr_linelist, -1);
				shader_reset();
			}
		} #endregion
		
		matrix_stack_clear();
		matrix_set(matrix_world, matrix_build_identity());
		
		postSubmitVertex(scene);
		
	} #endregion
		
	static clone = function() { #region
		var _obj = variable_clone(self);		
		return _obj;
	} #endregion
	
	static destroy = function() { #region
		if(is_array(VB)) {
			for( var i = 0, n = array_length(VB); i < n; i++ ) 
				vertex_delete_buffer(VB[i]);
		} else if(VB != noone)
			vertex_delete_buffer(VB);
		onDestroy();
	} #endregion
	
	static onDestroy = function() { } 
	
	static toString = function() { return $"[D3D Object\n\t{array_length(vertex)} vertex groups\n\tPosition: {position}\n\tRotation: {rotation}\n\tScale: {scale}]" }
}