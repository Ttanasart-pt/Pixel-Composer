#region shader
	globalvar INSTANCE_PARTICLE_VS;   INSTANCE_PARTICLE_VS   = undefined;
	
	function __initInstanceParticleRenderer() {
		if(INSTANCE_PARTICLE_VS != undefined) return;
		if(!GMD3D11_IS_SUPPORTED) return;
		
		var _vp = $"{WORKING_DIRECTORY}Shaders/3dInstance/3dParticleVS.hlsl";
		
		INSTANCE_PARTICLE_VS   = d3d11_shader_compile_vs(_vp, "main", "vs_4_0");
		if (!d3d11_shader_exists(INSTANCE_PARTICLE_VS))   noti_warning(d3d11_get_error_string());
	}
	
#endregion

function __3dObjectParticle() : __3dObjectInstancer() constructor {
	__initInstanceParticleRenderer();
	
	particle_data  = [];
	vs = INSTANCE_PARTICLE_VS;
	
	glsl_shader_default  = sh_d3d_default_particle;
	glsl_shader_geometry = sh_d3d_geometry_particle;
	
	static setBufferParticle = function(_buffer, _index, _amount) {
		if(OS == os_windows) {
		d3d11_cbuffer_begin();
		d3d11_cbuffer_add_float(16 * _amount);
		particle_data[_index] = d3d11_cbuffer_end();
		d3d11_cbuffer_update(particle_data[_index], _buffer);
			
		} else {
			_buffer = buffer_clone(_buffer);
			buffer_resize(_buffer, INSTANCE_BATCH_SIZE * 4 * 4 * 4);
			particle_data[_index] = _buffer;
		}
		
	}
	
	static submitCbuffer = function(b = 0) {
		
		if(OS == os_windows) {
			d3d11_shader_set_cbuffer_vs(10, instance_data[b]);
			d3d11_shader_set_cbuffer_vs(12, particle_data[b]);
			
		} else {
			var _uniId = shader_get_uniform(shader_current(), "InstanceTransforms");
			shader_set_uniform_f_buffer(_uniId, instance_data[b], 0, INSTANCE_BATCH_SIZE * 4 * 4);
			
			var _uniId = shader_get_uniform(shader_current(), "particleData");
			shader_set_uniform_f_buffer(_uniId, particle_data[b], 0, INSTANCE_BATCH_SIZE * 4 * 4);
			
		}
	}
	
}