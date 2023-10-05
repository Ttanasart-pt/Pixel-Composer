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
	
	transform = new __transform();
	size      = new __vec3(1);
	
	materials      = [];
	material_index = [];
	texture_flip   = false;
	
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
	
	static generateNormal = function(_s = normal_draw_size) { #region
		if(render_type != pr_trianglelist) return;
		
		NVB = array_create(object_counts);
		
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
	
	static buildVertex = function(_vertex) { #region
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
		//vertex_freeze(_buffer);
		
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
	
	static getCenter = function() { return new __vec3(transform.position.x, transform.position.y, transform.position.z); }
	static getBBOX   = function() { return new __bbox3D(size.multiplyVec(transform.scale).multiply(-0.5), size.multiplyVec(transform.scale).multiply(0.5)); }
	
	static submit		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitUI		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitSel	= function(scene = {}, shader = noone) { #region
		var _s = variable_clone(scene);
		_s.show_normal = false;
		submitVertex(_s, sh_d3d_silhouette); 
	} #endregion
	static submitShader = function(scene = {}, shader = noone) {}
	static submitShadow = function(scene = {}, object = noone) {}
	
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
			transform.submitMatrix();
			
			matrix_set(matrix_world, matrix_stack_top());
		} #endregion
		
		#region ++++ Submit & Material ++++
			gpu_set_tex_repeat(true);
			
			for( var i = 0, n = array_length(VB); i < n; i++ ) {
				var _ind = array_safe_get(material_index, i, i);
				var _mat = array_safe_get(materials, _ind, noone);
					
				shader_set_i("mat_flip", texture_flip);
				var _tex = _mat == noone? -1 : _mat.getTexture();
					
				if(_shader == sh_d3d_default) {
					if(_mat == noone) {
						shader_set_f("mat_diffuse",    1);
						shader_set_f("mat_specular",   0);
						shader_set_f("mat_shine",      1);
						shader_set_i("mat_metalic",    0);
						shader_set_f("mat_reflective", 0);
					} else 
						_mat.submitShader();
					
					vertex_submit(VB[i], render_type, _tex);
				} else if(_shader == sh_d3d_geometry) {
					if(_mat == noone)
						shader_set_i("use_normal", 0);
					else 
						_mat.submitGeometry();
					
					vertex_submit(VB[i], render_type, _tex);
				} else
					vertex_submit(VB[i], render_type, _tex);
			}
			
			gpu_set_tex_repeat(false);
		#endregion
		
		shader_reset();
		
		if(scene.show_normal) { #region
			if(NVB == noone) generateNormal();
			if(NVB != noone) {
				shader_set(sh_d3d_wireframe);
				for( var i = 0, n = array_length(NVB); i < n; i++ ) 
					vertex_submit(NVB[i], pr_linelist, -1);
				shader_reset();
			}
		} #endregion
		
		transform.clearMatrix();
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
	
	static toString = function() { return $"[D3D Object]\n\t({array_length(vertex)} vertex groups\n\tPosition: {transform.position}\n\tRotation: {transform.rotation}\n\tScale: {transform.scale})" }
}