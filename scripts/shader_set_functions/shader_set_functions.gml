function shader_set_i(shader, uniform, value) {
	if(is_array(value)) {
		shader_set_i_array(shader, uniform, value);
		return;
	}
		
	if(argument_count > 3) {
		var array = [];
		for( var i = 2; i < argument_count; i++ )
			array_push(array, argument[i]);
		shader_set_i_array(shader, uniform, array)
		return;
	}
	
	shader_set_uniform_i(shader_get_uniform(shader, uniform), value);
}

function shader_set_i_array(shader, uniform, array) {
	shader_set_uniform_i_array(shader_get_uniform(shader, uniform), array);
}

function shader_set_f(shader, uniform, value) {
	if(is_array(value)) {
		shader_set_f_array(shader, uniform, value);
		return;
	}
		
	if(argument_count > 3) {
		var array = [];
		for( var i = 2; i < argument_count; i++ )
			array_push(array, argument[i]);
		shader_set_f_array(shader, uniform, array)
		return;
	}
	
	shader_set_uniform_f(shader_get_uniform(shader, uniform), value);
}

function shader_set_f_array(shader, uniform, array) {
	shader_set_uniform_f_array(shader_get_uniform(shader, uniform), array);
}

function shader_set_uniform_f_array_safe(uniform, array) {
	if(!is_array(array)) return;
	if(array_length(array) == 0) return;
	
	shader_set_uniform_f_array(uniform, array);
}

function shader_set_surface(shader, sampler, surface) {
	if(!is_surface(surface)) return;
	
	var t = shader_get_sampler_index(shader, sampler);
	texture_set_stage(t, surface_get_texture(surface));
}