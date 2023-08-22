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
	vertex  = [];
	normals = [];
	uv      = [];
	VB = noone;
	VF = global.VF_POS_COL;
	render_type = pr_trianglelist;
	
	custom_shader = noone;
	
	position = new __vec3(0);
	rotation = new BBMOD_Quaternion();
	scale    = new __vec3(1);
	size     = new __vec3(1);
	
	texture  = -1;
	
	static checkParameter = function(params = {}) { #region
		var _keys = struct_get_names(params);
		var check = false;
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var key = _keys[i];
			if(self[$ key] != params[$ key])
				check = true;
			self[$ key] = params[$ key];
		}
		
		if(check) onParameterUpdate();
	} #endregion
	
	static onParameterUpdate = function() {}
	
	static buildVertex = function(_vertex, _normal, _uv) { #region
		var _buffer = vertex_create_buffer();
		vertex_begin(_buffer, VF);
			for( var i = 0, n = array_length(_vertex); i < n; i++ ) {
				var v = _vertex[i];
				
				switch(VF) {
					case global.VF_POS_COL : 
						var cc = array_length(v) > 3? v[3] : c_gray;
						var aa = array_length(v) > 4? v[4] : 1;
						
						vertex_position_3d(_buffer, v[0], v[1], v[2]);
						vertex_color(_buffer, cc, aa);
						break;
					case global.VF_POS_NORM_TEX_COL : 
						var nor = _normal[i];
						var uuv = array_safe_get(_uv, i, [ 0, 0 ]);
						var cc  = array_length(v) > 3? v[3] : c_white;
						var aa  = array_length(v) > 4? v[4] : 1;
						
						vertex_add_pntc(_buffer, v, nor, uuv, cc, aa);
						break;
				}
			}
		vertex_end(_buffer);
		
		return _buffer;
	} #endregion
	
	static build = function(_buffer = VB, _vertex = vertex, _normal = normals, _uv = uv) { #region
		if(is_array(_buffer)) {
			for( var i = 0, n = array_length(_buffer); i < n; i++ )
				vertex_delete_buffer(_buffer[i])
		} else if(_buffer != noone) vertex_delete_buffer(_buffer);
		
		if(array_empty(_vertex)) return noone;
		var _buffer_count = is_array(_vertex[0][0])? array_length(_vertex) : 0;
		
		if(_buffer_count == 0) return buildVertex(_vertex, _normal, _uv);
		
		var _res = array_create(_buffer_count);
		for( var i = 0; i < _buffer_count; i++ )
			_res[i] = buildVertex(_vertex[i], _normal[i], _uv[i]);
		
		return _res;
	} #endregion
	
	static preSubmitVertex  = function(params = {}) {}
	static postSubmitVertex = function(params = {}) {}
	
	static getCenter = function() { return new __vec3(position.x, position.y, position.z); }
	static getBBOX   = function() { return new __bbox3D(size.multiplyVec(scale).multiply(-0.5), size.multiplyVec(scale).multiply(0.5)); }
	
	static submitShader = function(params = {}, shader = noone) {}
	
	static submit    = function(params = {}, shader = noone) { submitVertex(params, shader); }
	static submitUI  = function(params = {}, shader = noone) { submitVertex(params, shader); }
	static submitSel = function(params = {}) { submitVertex(params, sh_d3d_silhouette); }
	
	static submitVertex = function(params = {}, shader = noone) { #region
		if(shader != noone)
			shader_set(shader);
		else if(custom_shader != noone)
			shader_set(custom_shader);
		else {
			switch(VF) {
				case global.VF_POS_NORM_TEX_COL: shader_set(sh_d3d_default);	break;
				case global.VF_POS_COL:			 shader_set(sh_d3d_wireframe);	break;
			}
		}
		
		preSubmitVertex(params);
		
		if(VB != noone) {
			matrix_stack_clear();
			
			if(params.apply_transform) {
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
				var pos = matrix_build(position.x - params.custom_transform.x, position.y - params.custom_transform.y, position.z - params.custom_transform.z, 
									   0, 0, 0, 
									   1, 1, 1);
				var siz = matrix_build(0, 0, 0, 
									   0, 0, 0, 
									   scale.x,    scale.y,    scale.z);
				var sca = matrix_build(0, 0, 0, 
									   0, 0, 0, 
									   params.custom_scale.x, params.custom_scale.y, params.custom_scale.z);
									   
				matrix_stack_push(pos);
				matrix_stack_push(siz);
				matrix_stack_push(sca);
				matrix_set(matrix_world, matrix_stack_top());
			}
			
			if(is_array(VB)) {
				for( var i = 0, n = array_length(VB); i < n; i++ ) 
					vertex_submit(VB[i], render_type, array_safe_get(texture, i, -1));
			} else 
				vertex_submit(VB, render_type, texture);
			
			matrix_stack_clear();
			matrix_set(matrix_world, matrix_build_identity());
		}
		
		postSubmitVertex(params);
		
		shader_reset();
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
}