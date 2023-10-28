#region shader
	globalvar INSTANCE_SHADER_VS, INSTANCE_SHADER_PS;
	
	function __initInstanceRenderer() {
		INSTANCE_SHADER_VS = d3d11_shader_compile_vs(working_directory + "Shaders/3dInstance/3dInstanceVS.hlsl", "main", "vs_4_0");
		INSTANCE_SHADER_PS = d3d11_shader_compile_ps(working_directory + "Shaders/3dInstance/3dInstancePS.hlsl", "main", "ps_4_0");
		
		if (!d3d11_shader_exists(INSTANCE_SHADER_VS)) noti_warning(d3d11_get_error_string());
		if (!d3d11_shader_exists(INSTANCE_SHADER_PS)) noti_warning(d3d11_get_error_string());
	}
#endregion

function __3dObjectInstancer() : __3dObject() constructor {
	object_data   = noone;
	object_counts = 1;
	
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	transform = new __transform();
	size      = new __vec3(1);
	
	positions = [];
	rotations = [];
	scales    = [];
	
	static setData = function() { #region
		d3d11_cbuffer_begin();
		d3d11_cbuffer_add_float(16 * object_counts);
		object_data = d3d11_cbuffer_end();
		
		var _buffer = buffer_create(d3d11_cbuffer_get_size(object_data), buffer_fixed, 1);
		
		for(var i = 0; i < object_counts; i++) {
			var pos = array_safe_get(positions, i, 0);
			var rot = array_safe_get(rotations, i, 0);
			var sca = array_safe_get(scales,    i, 0);
			
			buffer_write(_buffer, buffer_f32, array_safe_get(pos, 0, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(pos, 1, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(pos, 2, 0)); 
			buffer_write(_buffer, buffer_f32, 0);
			
			buffer_write(_buffer, buffer_f32, array_safe_get(rot, 0, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(rot, 1, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(rot, 2, 0)); 
			buffer_write(_buffer, buffer_f32, 0);
			
			buffer_write(_buffer, buffer_f32, array_safe_get(sca, 0, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(sca, 1, 0)); 
			buffer_write(_buffer, buffer_f32, array_safe_get(sca, 2, 0)); 
			buffer_write(_buffer, buffer_f32, 0);
			
			buffer_write(_buffer, buffer_f32, 0);
			buffer_write(_buffer, buffer_f32, 0);
			buffer_write(_buffer, buffer_f32, 0);
			buffer_write(_buffer, buffer_f32, 0);
		}
		
		d3d11_cbuffer_update(object_data, _buffer);
		buffer_delete(_buffer);
	} #endregion
	
	static generateNormal = function(_s = normal_draw_size) {}
	
	static submit		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitUI		= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	static submitSel	= function(scene = {}, shader = noone) { submitVertex(scene, shader); }
	
	static submitShader = function(scene = {}, shader = noone) {}
	static submitShadow = function(scene = {}, object = noone) {}
	
	static submitVertex = function(scene = {}, shader = noone) { #region
		d3d11_shader_override_vs(INSTANCE_SHADER_VS);
		d3d11_shader_override_ps(INSTANCE_SHADER_PS);
		
		preSubmitVertex(scene);
		transform.submitMatrix();
		matrix_set(matrix_world, matrix_stack_top());
		
		d3d11_shader_set_cbuffer_vs(10, object_data);
		for( var i = 0, n = array_length(VB); i < n; i++ ) {
			var _ind = array_safe_get(material_index, i, i);
			var _mat = array_safe_get(materials, _ind, noone);
			var _tex = _mat == noone? -1 : _mat.getTexture();
					
			vertex_submit_instanced(VB[i], render_type, _tex, object_counts);
		}
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		
		transform.clearMatrix();
		matrix_set(matrix_world, matrix_build_identity());
		
		postSubmitVertex(scene);
	} #endregion
		
	static clone = function(_vertex = true) {}
	
	static destroy = function() {}
	
	static onDestroy = function() {} 
	
	static toString = function() { return $"[D3D Instanced Object]\n\t({object_counts} instances\n\tPosition: {transform.position}\n\tRotation: {transform.rotation}\n\tScale: {transform.scale})" }
}