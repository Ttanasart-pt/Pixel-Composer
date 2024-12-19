#region vertex format
	vertex_format_begin();
	vertex_format_add_position_3d();
	global.VF_POS = vertex_format_end();
	
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_color();
	global.VF_POS_COL = vertex_format_end();
	
	vertex_format_begin();
	vertex_format_add_position_3d();	// x y z    // 12
	vertex_format_add_normal();			// x y z    // 12
	vertex_format_add_texcoord();		// u v      // 8
	vertex_format_add_color();			// r g b a  // 4
	vertex_format_add_custom(vertex_type_float3, vertex_usage_texcoord);	// x y z    // 12 // barycentric
	global.VF_POS_NORM_TEX_COL = vertex_format_end();
	global.VF_POS_NORM_TEX_COL_size = 48;
#endregion

function __3dObject() constructor {
	object_counts = 1;
	vertex = [];
	VB     = [];
	VF     = global.VF_POS_COL;
	NVB    = noone;
	WVB    = noone;
	
	transform = new __transform();
	size      = new __vec3(1);
	
	normal_draw_size = 0.2;
	render_type      = pr_trianglelist;
	
	custom_shader  = noone;
	texture_flip   = false;
	materials      = [];
	material_index = [];
	
	////- Object
	
	static checkParameter = function(params = {}, forceUpdate = false) {
		var _keys = struct_get_names(params);
		
		if(forceUpdate) {
			struct_override(self, params);
			onParameterUpdate();
			return;
		}
		
		var check = false;
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var key = _keys[i];
			if(!isEqual(self[$ key], params[$ key]))
				check = true;
			self[$ key] = params[$ key];
		}
		
		if(check) onParameterUpdate();
	}
	
	static onParameterUpdate = function() {}
	
	////- Verticies
	
	static generateNormal = function(_s = normal_draw_size) {
		if(render_type != pr_trianglelist) return;
		
		if(is_array(NVB)) array_foreach(NVB, function(v) /*=>*/ {return vertex_delete_buffer(v)});
		NVB = array_verify(NVB, object_counts);
		
		for( var i = 0; i < object_counts; i++ ) {
			var _obj = vertex[i];
			var _nvb = vertex_create_buffer();
			
			vertex_begin(_nvb, global.VF_POS_COL);
			for( var j = 0, n = array_length(_obj); j < n; j++ ) {
				var _v = _obj[j];
				
				vertex_position_3d(_nvb, _v.x, _v.y, _v.z);
				vertex_color(_nvb, c_red, 1);
				
				vertex_position_3d(_nvb, _v.x + _v.nx * _s, _v.y + _v.ny * _s, _v.z + _v.nz * _s);
				vertex_color(_nvb, c_red, 1);
			}
			vertex_end(_nvb);
			NVB[i] = _nvb;
		}
	}
	
	static buildVertex = function(_vertex) {
		var _buffer = vertex_create_buffer();
		vertex_begin(_buffer, VF);
		
		switch(VF) {
			case global.VF_POS_COL :			
				for( var i = 0, n = array_length(_vertex); i < n; i++ ) {
					var v = _vertex[i];
					vertex_position_3d( _buffer, v.x, v.y, v.z);
					vertex_color(       _buffer, v.color, v.alpha);
				}
				break;
				
			case global.VF_POS_NORM_TEX_COL : 
				for( var i = 0, n = array_length(_vertex); i < n; i += 3 ) {
					var v0 = _vertex[i + 0];
					var v1 = _vertex[i + 1];
					var v2 = _vertex[i + 2];
					
					vertex_position_3d( _buffer, v0.x, v0.y, v0.z);
					vertex_normal(      _buffer, v0.nx, v0.ny, v0.nz);
					vertex_texcoord(    _buffer, v0.u, v0.v);
					vertex_color(       _buffer, v0.color, v0.alpha);
					vertex_float3(      _buffer, 255, 0, 0);
					
					vertex_position_3d( _buffer, v1.x, v1.y, v1.z);
					vertex_normal(      _buffer, v1.nx, v1.ny, v1.nz);
					vertex_texcoord(    _buffer, v1.u, v1.v);
					vertex_color(       _buffer, v1.color, v1.alpha);
					vertex_float3(      _buffer, 0, 255, 0);
					
					vertex_position_3d( _buffer, v2.x, v2.y, v2.z);
					vertex_normal(      _buffer, v2.nx, v2.ny, v2.nz);
					vertex_texcoord(    _buffer, v2.u, v2.v);
					vertex_color(       _buffer, v2.color, v2.alpha);
					vertex_float3(      _buffer, 0, 0, 255);
				}
				break;
		}
		
		vertex_end(_buffer);
		
		return _buffer;
	}
	
	static build = function(_buffer = VB, _vertex = vertex, counts = object_counts) {
			 if(is_array(_buffer)) array_foreach(_buffer, function(b) /*=>*/ { if(b != noone) vertex_delete_buffer(b); });
		else if(_buffer != noone)  vertex_delete_buffer(_buffer);
		
		if(array_empty(_vertex)) return noone;
		
		var _res = array_create(counts);
		for( var i = 0; i < counts; i++ )
			_res[i] = buildVertex(_vertex[i]);
		
		return _res;
	}
	
	////- Submit
	
	static preSubmitVertex  = function(scene = {}) {}
	static postSubmitVertex = function(scene = {}) {}
	
	static getCenter = function() { return new __vec3(transform.position.x, transform.position.y, transform.position.z); }
	static getBBOX   = function() { return new __bbox3D(size.multiplyVec(transform.scale).multiply(-0.5), size.multiplyVec(transform.scale).multiply(0.5)); }
	
	static submit		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitUI		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitSel	= function(scene = {}, shader = noone) {
		var _s = variable_clone(scene);
		_s.show_normal = false;
		submitVertex(_s, sh_d3d_silhouette); 
	}
	
	static submitShader = function(scene = {}, shader = noone) {}
	static submitShadow = function(scene = {}, object = noone) {}
	
	static submitVertex = function(scene = {}, shader = noone) {
		var _shader;
		
		switch(VF) {
			case global.VF_POS_COL:			     _shader = sh_d3d_wireframe;         break;
			case global.VF_POS_NORM_TEX_COL:     
			default :                            _shader = sh_d3d_default;           break;
		}
		
		if(custom_shader != noone) _shader = custom_shader;
		if(shader != noone)        _shader = shader;
		if(!is_undefined(shader)) shader_set(_shader);
		
		preSubmitVertex(scene);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		gpu_set_tex_repeat(true);
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			var _ind = array_safe_get_fast(material_index, i, i);
			var _mat = array_safe_get_fast(materials, _ind, noone);
			var _useMat = is_instanceof(_mat, __d3dMaterial);
			
			shader_set_i("mat_flip", texture_flip);
			var _tex = _useMat? _mat.getTexture() : -1;
				
			if(_shader == sh_d3d_default) {
				if(_useMat) {
					_mat.submitShader();
				} else {
					shader_set_f("mat_diffuse",    1);
					shader_set_f("mat_specular",   0);
					shader_set_f("mat_shine",      1);
					shader_set_i("mat_metalic",    0);
					shader_set_f("mat_reflective", 0);
					shader_set_f("mat_texScale",   [ 1, 1 ] );
				}
				
			} else if(_shader == sh_d3d_geometry) {
				if(_useMat) _mat.submitGeometry();
				else {
					shader_set_i("use_normal",   0);
					shader_set_f("mat_texScale", [ 1, 1 ] );
				}
				
			}
			
			vertex_submit(VB[i], render_type, _tex);
		}
		gpu_set_tex_repeat(false);
		
		if(!is_undefined(shader)) shader_reset();
		
		if(scene.show_normal) {
			if(NVB == noone) generateNormal();
			if(NVB != noone) {
				shader_set(sh_d3d_wireframe);
				shader_set_color("blend", c_white);
				array_foreach(NVB, function(n) /*=>*/ {vertex_submit(n, pr_linelist, -1)});
				shader_reset();
			}
		}
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		postSubmitVertex(scene);
		
	}
	
	////- Actions
	
	static clone = function(_vertex = true, cloneBuffer = false) {
		var _obj = new __3dObject();
		
		if(_vertex) {
			_obj.vertex = array_create(array_length(vertex));
			for( var i = 0, n = array_length(vertex); i < n; i++ ) {
				_obj.vertex[i] = array_create(array_length(vertex[i]));
			
				for( var j = 0, m = array_length(vertex[i]); j < m; j++ )
					_obj.vertex[i][j] = vertex[i][j].clone();
			}
		}
		
		if(cloneBuffer) {
			_obj.VB = array_create(array_length(VB));
			
			for( var i = 0, n = array_length(VB); i < n; i++ ) {
				var _vnum = vertex_get_number(VB[i]);
				var _buff = buffer_create(1, buffer_grow, 1);
				buffer_copy_from_vertex_buffer(VB[i], 0, _vnum - 1, _buff, 0);
				
				_obj.VB[i] = vertex_create_buffer_from_buffer(_buff, VF);
			}
		} else {
			_obj.VB  = [];
		}
		
		_obj.NVB            = NVB;
		_obj.VF             = VF;
		_obj.render_type    = render_type;
		_obj.custom_shader  = custom_shader;
		_obj.object_counts  = object_counts;
		_obj.transform      = transform.clone();
		_obj.size           = size.clone();
		_obj.materials      = materials;
		_obj.material_index = material_index;
		_obj.texture_flip   = texture_flip;
		
		return _obj;
	}
	
	static destroy = function() {
		for( var i = 0, n = array_length(VB); i < n; i++ ) 
			vertex_delete_buffer(VB[i]);
		VB = [];
		onDestroy();
	}
	
	static onDestroy = function() { } 
	
	static toString = function() { return $"[D3D Object]\n\t({array_length(vertex)} vertex groups\n\tPosition: {transform.position}\n\tRotation: {transform.rotation}\n\tScale: {transform.scale})" }
}