#region vertex format
	vertex_format_begin();
	vertex_format_add_position_3d();
	global.VF_POS = vertex_format_end();
	
	vertex_format_begin();
	vertex_format_add_position_3d();    // x y z    // 12
	vertex_format_add_color();          // r g b a  // 4
	global.VF_POS_COL = vertex_format_end();
	global.VF_POS_COL_size = 16;
	
	vertex_format_begin();
	vertex_format_add_position_3d();	// x y z    // 12
	vertex_format_add_normal();			// x y z    // 12
	vertex_format_add_texcoord();		// u v      // 8
	vertex_format_add_color();			// r g b a  // 4
	vertex_format_add_custom(vertex_type_float3, vertex_usage_texcoord);	// x y z    // 12 // barycentric
	global.VF_POS_NORM_TEX_COL = vertex_format_end();
	global.VF_POS_NORM_TEX_COL_size = 48;
	
	#macro vertex_pos3 vertex_position_3d
	#macro vertex_norm vertex_normal
	#macro vertex_texc vertex_texcoord
	#macro vertex_colr vertex_color
	#macro vertex_vec3 vertex_float3
#endregion

function __3dObject_Edge(_ind0, _ind1) constructor { p0 = _ind0; p1 = _ind1; }

function __3dObject() constructor {
	object_counts = 1;
	vertex = [];
	VB     = [];
	VF     = global.VF_POS_COL;
	VBM    = undefined;
	NVB    = noone;
	WVB    = noone;
	name   = UUID_generate();
	
	edges  = [];
	EB     = noone;
	
	transform = new __transform();
	size      = new __vec3(1);
	
	normal_draw_size = 0.2;
	render_type      = pr_trianglelist;
	
	custom_shader  = noone;
	texture_flip   = false;
	materials      = [];
	material_index = [];
	
	log = false;
	
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
	
	static buildEdge = function() {
		if(array_empty(edges)) return;
		var _buffer = vertex_create_buffer();
		vertex_begin(_buffer, global.VF_POS_COL);
		
		for( var i = 0, n = array_length(edges); i < n; i++ ) {
			var e  = edges[i];
			
			vertex_position_3d( _buffer, e.p0[0], e.p0[1], e.p0[2]);
			vertex_color(       _buffer, c_white, 1);
			
			vertex_position_3d( _buffer, e.p1[0], e.p1[1], e.p1[2]);
			vertex_color(       _buffer, c_white, 1);
		}
		
		vertex_end(_buffer);
		EB = _buffer;
	}
	
	static build = function(_buffer = VB, _vertex = vertex, counts = object_counts) {
			 if(is_array(_buffer)) array_foreach(_buffer, function(b) /*=>*/ { if(b != noone) vertex_delete_buffer(b); });
		else if(_buffer != noone)  vertex_delete_buffer(_buffer);
		
		if(array_empty(_vertex)) return noone;
		
		var _res = array_create(counts);
		for( var i = 0; i < counts; i++ )
			_res[i] = buildVertex(_vertex[i]);
		
		buildEdge();
		return _res;
	}
	
	////- Submit
	
	static preSubmitVertex  = function(_sc = noone) /*=>*/ {}
	static postSubmitVertex = function(_sc = noone) /*=>*/ {}
	
	static getCenter = function() /*=>*/ {return new __vec3(transform.position.x, transform.position.y, transform.position.z)};
	static getBBOX   = function() /*=>*/ {return new __bbox3D(size.multiplyVec(transform.scale).multiply(-0.5), size.multiplyVec(transform.scale).multiply(0.5))};
	
	static submitShadow = function(_sc = noone, _ob = noone) /*=>*/ {}
	static submitSel	= function(_sc = noone, _sh = noone) /*=>*/ { submitVertex(_sc, sh_d3d_silhouette, true);  }
	static submitShader = function(_sc = noone, _sh = noone) /*=>*/ { submit(_sc, _sh); }
	static submit		= function(_sc = noone, _sh = noone) /*=>*/ { 
		if(!is(_sc, __3dScene)) return submitVertex(_sc, _sh);
		
		switch(_sc.show_wireframe) {
			case 0 : 
				submitVertex(_sc, _sh); 
				break;
				
			case 1 : 
				submitVertex(_sc, _sh);
				submitEdge(_sc.wireframe_color, _color_get_alpha(_sc.wireframe_color));
				break;
				
			case 2 : 
				gpu_set_blendmode_ext(bm_zero, bm_one);
				gpu_set_cullmode(cull_clockwise);
				submitVertex(_sc, _sh);
				gpu_set_cullmode(cull_counterclockwise);
				BLEND_NORMAL
				
				gpu_set_zfunc(cmpfunc_less);
				submitEdge(_sc.wireframe_color, _color_get_alpha(_sc.wireframe_color));
				gpu_set_zfunc(cmpfunc_lessequal);
				break;
				
			case 3 : 
				submitEdge(_sc.wireframe_color, _color_get_alpha(_sc.wireframe_color));
				break;
				
		}
	}
	
	static submitVertex = function(_sc = noone, _sh = noone, _selection = false) {
		var _shader;
		
		switch(VF) {
			case global.VF_POS_COL:			     _shader = sh_d3d_wireframe;         break;
			case global.VF_POS_NORM_TEX_COL:     
			default :                            _shader = sh_d3d_default;           break;
		}
		
		if(custom_shader != noone) _shader = custom_shader;
		if(_sh != noone)           _shader = _sh;
		if(!is_undefined(_sh))     shader_set(_shader);
		
		preSubmitVertex(_sc);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		gpu_set_tex_repeat(true);
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			if(VB[i] == noone) continue;
			
			var _ind  = array_safe_get_fast(material_index, i, i);
			var _mat  = array_safe_get_fast(materials, _ind, noone);
			var _uMat = is(_mat, __d3dMaterial);
			
			shader_set_i("mat_flip", texture_flip);
			var _tex = _uMat? _mat.getTexture() : -1;
			// if(log) print(i, _ind, _mat, _tex);
				
			if(_shader == sh_d3d_geometry) {
				if(_uMat) _mat.submitGeometry();
				else {
					shader_set_i("use_normal",   0);
					shader_set_f("mat_texScale", [ 1, 1 ] );
				}
				
			} else {
				if(_uMat) _mat.submitShader();
				else {
					shader_set_f("mat_diffuse",    1);
					shader_set_f("mat_specular",   0);
					shader_set_f("mat_shine",      1);
					shader_set_i("mat_metalic",    0);
					shader_set_f("mat_reflective", 0);
					shader_set_f("mat_texScale",   [ 1, 1 ] );
				}
			}
			
			if(VBM != undefined) { matrix_stack_push(VBM[i]); matrix_set(matrix_world, matrix_stack_top()); }
			vertex_submit(VB[i], render_type, _tex);
			if(VBM != undefined) { matrix_stack_pop();        matrix_set(matrix_world, matrix_stack_top()); }
		}
		// print(shader_get_name(_shader), instanceof(self));
		gpu_set_tex_repeat(false);
		
		if(!is_undefined(_sh)) shader_reset();
		
		if(_sc.show_normal && !_selection) {
			if(NVB == noone) generateNormal();
			if(NVB != noone) {
				shader_set(sh_d3d_wireframe);
				shader_set_color("blend", c_white);
				
				for( var i = 0, n = array_length(NVB); i < n; i++ ) {
					if(VBM != undefined) { matrix_stack_push(VBM[i]); matrix_set(matrix_world, matrix_stack_top()); }
					vertex_submit(NVB[i], pr_linelist, -1);
					if(VBM != undefined) { matrix_stack_pop();        matrix_set(matrix_world, matrix_stack_top()); }
				}
				
				shader_reset();
			}
		}
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		postSubmitVertex(_sc);
		
	}
	
	static submitEdge = function(cc = c_black, aa = 1) {
		if(EB == noone) return;
		
		shader_set(sh_d3d_wireframe);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		shader_set_c("blend", cc, aa);
		vertex_submit(EB, pr_linelist, -1);
		
		transform.clearMatrix();	
		matrix_set(matrix_world, matrix_build_identity());
		shader_reset();
		
		draw_set_alpha(1);
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