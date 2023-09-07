#macro shader_set shader_replace_simple_set_hook
#macro shader_replace_simple_set_base shader_set
#macro shader_reset shader_replace_simple_reset_hook
#macro shader_replace_simple_reset_base shader_reset
function shader_replace_simple_reset_hook() {
	shader_replace_simple_reset_base();
	shader_replace_simple_sync(-1);
}
function shader_replace_simple_set_hook() {
	shader_replace_simple_set_base(argument0);
	shader_replace_simple_sync(argument0);
}
function shader_replace_simple_macros(){
	if (false) {
		shader_replace_simple_set_base(0);
		shader_replace_simple_reset_base();
	}
}