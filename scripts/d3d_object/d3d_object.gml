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
	
	position = new __vec3(0, 0, 0);
	rotation = new __rot3(0, 0, 0);
	scale    = new __vec3(1, 1, 1);
	
	static build = function(_buffer = VB, _vertex = vertex, _normal = normals) {
		if(_buffer != noone) vertex_delete_buffer(_buffer);
		
		_buffer = vertex_create_buffer();
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
						var cc = array_length(v) > 3? v[3] : c_white;
						var aa = array_length(v) > 4? v[4] : 1;
						
						vertex_position_3d(_buffer, v[0], v[1], v[2]);
						vertex_normal(_buffer, nor[0], nor[1], nor[2]);
						vertex_texcoord(_buffer, 0, 0);
						vertex_color(_buffer, cc, aa);
						break;
				}
			}
		vertex_end(_buffer);
		
		return _buffer;
	}
	
	static presubmit = function(params = {}) {}
	static postsubmit = function(params = {}) {}
	
	static submit    = function(params = {}, shader = noone) { submitVertex(params, shader); }
	static submitUI  = function(params = {}, shader = noone) { submitVertex(params, shader); }
	static submitSel = function(params = {}) { submitVertex(params, sh_d3d_silhouette); }
	
	static submitVertex = function(params = {}, shader = noone) {
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
		
		presubmit(params);
		
		if(VB != noone) {
			var rot = matrix_build(0, 0, 0, 
								   rotation.x, rotation.y, rotation.z, 
								   1, 1, 1);
			var sca = matrix_build(0, 0, 0, 
								   0, 0, 0, 
								   scale.x,    scale.y,    scale.z);
			var pos = matrix_build(position.x, position.y, position.z, 
								   0, 0, 0, 
								   1, 1, 1);
		
			matrix_stack_clear();
			matrix_stack_push(pos);
			matrix_stack_push(rot);
			matrix_stack_push(sca);
			matrix_set(matrix_world, matrix_stack_top());
		
			vertex_submit(VB, render_type, -1);
		
			matrix_stack_clear();
			matrix_set(matrix_world, matrix_build_identity());
		}
		
		postsubmit(params);
		
		shader_reset();
	}
}

function __3dObjectParameters(camera) constructor {
	self.camera = camera;
}