/// @macro {Real} Size of the SSAO noise texture. Must be the same as in shaders!
/// @private
#macro __BBMOD_SSAO_NOISE_TEXTURE_SIZE 4

/// @macro {Real} The size of SSAO sampling kernel. The higher the better quality,
/// but lower performance. Must be the same as in shaders!
/// @private
#macro __BBMOD_SSAO_KERNEL_SIZE 8

/// @var {Id.Sprite}
/// @private
global.__bbmodSSAONoise = __bbmod_ssao_make_noise(__BBMOD_SSAO_NOISE_TEXTURE_SIZE);

/// @var {Array<Real>}
/// @private
global.__bbmodSSAOKernel = __bbmod_ssao_create_kernel(__BBMOD_SSAO_KERNEL_SIZE);

/// @func __bbmod_ssao_make_noise(_size)
///
/// @desc Creates a sprite containing a random noise for the SSAO.
///
/// @param {Real} _size The size of the sprite.
///
/// @return {Id.Sprite} The created noise sprite.
///
/// @private
function __bbmod_ssao_make_noise(_size)
{
	var _seed = random_get_seed();
	randomize();
	var _sur = surface_create(_size, _size);
	surface_set_target(_sur);
	draw_clear(0);
	var _dir = 0;
	var _dirStep = 180 / (_size * _size);
	for (var i = 0; i < _size; ++i)
	{
		for (var j = 0; j < _size; ++j)
		{
			var _col = make_colour_rgb(
				(dcos(_dir) * 0.5 + 0.5) * 255,
				(dsin(_dir) * 0.5 + 0.5) * 255,
				0);
			draw_point_colour(i, j, _col);
			_dir += _dirStep;
		}
	}
	surface_reset_target();
	random_set_seed(_seed);
	var _sprite = sprite_create_from_surface(
		_sur, 0, 0, _size, _size, false, false, 0, 0);
	surface_free(_sur);
	return _sprite;
}

/// @func __bbmod_ssao_create_kernel(_size)
///
/// @desc Generates a kernel of random vectors to be used for the SSAO.
///
/// @param {Real} _size Number of vectors in the kernel.
///
/// @return {Array} The created kernel as
/// `[v1X, v1Y, v1Z, v2X, v2Y, v2Z, ..., vnX, vnY, vnZ]`.
///
/// @private
function __bbmod_ssao_create_kernel(_size)
{
	var _seed = random_get_seed();
	randomize();
	var _kernel = array_create(_size * 2, 0.0);
	var _dir = 0;
	var _dirStep = 360 / _size;
	for (var i = _size - 1; i >= 0; --i)
	{
		var _len = (i + 1) / _size;
		_kernel[i * 2 + 0] = lengthdir_x(_len, _dir);
		_kernel[i * 2 + 1] = lengthdir_y(_len, _dir);
		_dir += _dirStep;
	}
	random_set_seed(_seed);
	return _kernel;
}

/// @func bbmod_ssao_draw(_radius, _power, _angleBias, _depthRange, _surSsao, _surWork, _surDepth, _matProj, _clipFar[, _selfOcclusionBias[, _blurDepthRange]])
///
/// @desc Renders SSAO into the `_surSsao` surface.
///
/// @param {Real} _radius Screen-space radius of the occlusion effect.
/// @param {Real} _power Strength of the occlusion effect. Should be greater
/// than 0.
/// @param {Real} _angleBias Angle bias in radians.
/// @param {Real} _depthRange Maximum depth difference of samples.
/// @param {Id.Surface} _surSsao The surface to draw the SSAO to.
/// @param {Id.Surface} _surWork A working surface used for blurring the SSAO.
/// Must have the same size as `_surSsao`!
/// @param {Id.Surface} _surDepth G-buffer surface.
/// @param {Array<Real>} _matProj The projection matrix used when rendering the
/// scene.
/// @param {Real} _clipFar Distance to the far clipping plane (same as in the
/// projection used when rendering the scene).
/// @param {Real} [_selfOcclusionBias] Defaults to 0.01. Increase to fix
/// self-occlusion.
/// @param {Real} [_blurDepthRange] Maximum depth difference over which can be SSAO samples
/// blurred. Defaults to 2.
function bbmod_ssao_draw(
	_radius,
	_power,
	_angleBias,
	_depthRange,
	_surSsao,
	_surWork,
	_surDepth,
	_matProj,
	_clipFar,
	_selfOcclusionBias=0.01,
	_blurDepthRange=2.0)
{
	static _uTexNoise          = shader_get_sampler_index(BBMOD_ShSSAO, "u_texNoise");
	static _uTexel             = shader_get_uniform(BBMOD_ShSSAO, "u_vTexel");
	static _uClipFar           = shader_get_uniform(BBMOD_ShSSAO, "u_fClipFar");
	static _uTanAspect         = shader_get_uniform(BBMOD_ShSSAO, "u_vTanAspect");
	static _uSampleKernel      = shader_get_uniform(BBMOD_ShSSAO, "u_vSampleKernel");
	static _uRadius            = shader_get_uniform(BBMOD_ShSSAO, "u_fRadius");
	static _uPower             = shader_get_uniform(BBMOD_ShSSAO, "u_fPower");
	static _uNoiseScale        = shader_get_uniform(BBMOD_ShSSAO, "u_vNoiseScale");
	static _uAngleBias         = shader_get_uniform(BBMOD_ShSSAO, "u_fAngleBias");
	static _uDepthRange        = shader_get_uniform(BBMOD_ShSSAO, "u_fDepthRange");
	static _uSelfOcclusionBias = shader_get_uniform(BBMOD_ShSSAO, "u_fSelfOcclusionBias");
	static _uBlurTexel         = shader_get_uniform(BBMOD_ShSSAOBlur, "u_vTexel");
	static _uBlurTexDepth      = shader_get_sampler_index(BBMOD_ShSSAOBlur, "u_texDepth");
	static _uBlurClipFar       = shader_get_uniform(BBMOD_ShSSAOBlur, "u_fClipFar");
	static _uBlurDepthRange    = shader_get_uniform(BBMOD_ShSSAOBlur, "u_fDepthRange");

	var _tanAspect = (_matProj[11] == 0.0)
		? [1.0, -1.0] // Ortho
		: [1.0 / _matProj[0], -1.0 / _matProj[5]]; // Perspective
	var _width  = surface_get_width(_surSsao);
	var _height = surface_get_height(_surSsao);

	gpu_push_state();
	gpu_set_tex_repeat(false);

	static _cam = camera_create();
	camera_set_view_size(_cam, _width, _height);

	gpu_set_tex_filter(false);

	surface_set_target(_surSsao);
	camera_apply(_cam);
	matrix_set(matrix_world, matrix_build_identity());
	draw_clear(c_white);
	shader_set(BBMOD_ShSSAO);
	texture_set_stage(_uTexNoise, sprite_get_texture(global.__bbmodSSAONoise, 0));
	gpu_set_texrepeat_ext(_uTexNoise, true);
	shader_set_uniform_f(_uTexel, 1.0 / _width, 1.0 / _height);
	shader_set_uniform_f(_uClipFar, _clipFar);
	shader_set_uniform_f_array(_uTanAspect, _tanAspect);
	shader_set_uniform_f_array(_uSampleKernel, global.__bbmodSSAOKernel);
	shader_set_uniform_f(_uRadius, _radius);
	shader_set_uniform_f(_uPower, _power);
	shader_set_uniform_f(_uNoiseScale,
		_width / __BBMOD_SSAO_NOISE_TEXTURE_SIZE,
		_height / __BBMOD_SSAO_NOISE_TEXTURE_SIZE);
	shader_set_uniform_f(_uAngleBias, _angleBias);
	shader_set_uniform_f(_uDepthRange, _depthRange);
	shader_set_uniform_f(_uSelfOcclusionBias, _selfOcclusionBias);
	draw_surface_stretched(_surDepth, 0, 0, _width, _height);
	shader_reset();
	surface_reset_target();

	gpu_set_tex_filter(true);

	shader_set(BBMOD_ShSSAOBlur);
	shader_set_uniform_f(_uBlurTexel, 1.0 / _width, 0.0);
	shader_set_uniform_f(_uBlurClipFar, _clipFar);
	texture_set_stage(_uBlurTexDepth, surface_get_texture(_surDepth));
	gpu_set_tex_filter_ext(_uBlurTexDepth, false);
	shader_set_uniform_f(_uBlurDepthRange, _blurDepthRange);

	surface_set_target(_surWork);
	camera_apply(_cam);
	matrix_set(matrix_world, matrix_build_identity());
	draw_clear(0);
	shader_set_uniform_f(_uBlurTexel, 1.0 / _width, 0.0);
	draw_surface(_surSsao, 0, 0);
	surface_reset_target();

	surface_set_target(_surSsao);
	camera_apply(_cam);
	matrix_set(matrix_world, matrix_build_identity());
	draw_clear(0);
	shader_set_uniform_f(_uBlurTexel, 0.0, 1.0 / _height);
	draw_surface(_surWork, 0, 0);
	surface_reset_target();

	shader_reset();

	gpu_pop_state();
}
