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
	
	particle_data = noone;
	vs = INSTANCE_PARTICLE_VS;
	
	static setBufferParticle = function(_buffer) {
		d3d11_cbuffer_begin();
		d3d11_cbuffer_add_float(16 * instance_amount);
		particle_data = d3d11_cbuffer_end();
		d3d11_cbuffer_update(particle_data, _buffer);
	}
	
	static submitCbuffer = function() {
		d3d11_shader_set_cbuffer_vs(10, instance_data);
		d3d11_shader_set_cbuffer_vs(12, particle_data);
	}
	
}