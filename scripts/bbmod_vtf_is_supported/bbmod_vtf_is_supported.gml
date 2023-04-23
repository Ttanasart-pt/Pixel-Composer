/// @func bbmod_vtf_is_supported()
///
/// @desc Checks whether vertex texture fetching is supported on the current
/// platform.
///
/// @return {Bool} Returns `true` if vertex texture fetching is supported on
/// the current platform.
function bbmod_vtf_is_supported()
{
	var _isSupported = undefined;

	if (_isSupported == undefined)
	{
		var _shader = __BBMOD_ShCheckVTF;

		if (shader_is_compiled(_shader))
		{
			var _surface = surface_create(1, 1);
			surface_set_target(_surface);
			draw_clear(c_black);
			shader_set(_shader);
			bbmod_texture_set_stage_vs(
				shader_get_sampler_index(_shader, "u_texTest"),
				sprite_get_texture(BBMOD_SprWhite, 0));
			draw_sprite(BBMOD_SprWhite, 0, 0, 0);
			shader_reset();
			surface_reset_target();

			var _pixel = surface_getpixel_ext(_surface, 0, 0);
			_isSupported = (_pixel == $FFFFFFFF);

			surface_free(_surface);
		}
		else
		{
			_isSupported = false;
		}
	}

	return _isSupported;
}

__bbmod_info("Vertex texture fetching " + (bbmod_vtf_is_supported() ? "IS" : "NOT") + " supported!");
