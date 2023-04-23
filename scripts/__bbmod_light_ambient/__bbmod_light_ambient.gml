/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodAmbientLightUp = BBMOD_C_WHITE;

/// @var {Struct.BBMOD_Color}
/// @private
global.__bbmodAmbientLightDown = BBMOD_C_GRAY;

/// @var {Bool}
/// @private
global.__bbmodAmbientAffectLightmap = true;

/// @func bbmod_light_ambient_set(_color)
///
/// @desc Defines color of the ambient light passed to shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the ambient light (both
/// upper and lower hemisphere).
///
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_set(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
	global.__bbmodAmbientLightDown = _color;
}

/// @func bbmod_light_ambient_get_up()
///
/// @desc Retrieves color of the upper hemisphere of the ambient light passed
/// to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the upper hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_get_up()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightUp;
}

/// @func bbmod_light_ambient_set_up(_color)
///
/// @desc Defines color of the upper hemisphere of the ambient light passed to
/// shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the upper hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_get_down
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_set_up(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightUp = _color;
}

/// @func bbmod_light_ambient_get_down()
///
/// @desc Retrieves color of the lower hemisphere of the ambient light passed
/// to shaders.
///
/// @return {Struct.BBMOD_Color} The color of the lower hemisphere of the
/// ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_set_down
/// @see BBMOD_Color
function bbmod_light_ambient_get_down()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientLightDown;
}

/// @func bbmod_light_ambient_set_down(_color)
///
/// @desc Defines color of the lower hemisphere of the ambient light passed to
/// shaders.
///
/// @param {Struct.BBMOD_Color} _color The new color of the lower hemisphere of
/// the ambient light.
///
/// @see bbmod_light_ambient_set
/// @see bbmod_light_ambient_get_up
/// @see bbmod_light_ambient_set_up
/// @see bbmod_light_ambient_get_down
/// @see BBMOD_Color
function bbmod_light_ambient_set_down(_color)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientLightDown = _color;
}

/// @func bbmod_light_ambient_get_affect_lightmaps()
///
/// @desc Checks whether ambient light affects materials that use baked
/// lightmaps.
///
/// @return {Bool} Returns `true` if ambient light affects materials that
/// use lightmaps.
function bbmod_light_ambient_get_affect_lightmaps()
{
	gml_pragma("forceinline");
	return global.__bbmodAmbientAffectLightmap;
}

/// @func bbmod_light_ambient_set_affect_lightmaps(_enable)
///
/// @desc Configures whether ambient light affects materials that use baked
/// lightmaps.
///
/// @param {Bool} _enable Use `true` to enable ambient light affecting materials
/// that use baked lightmaps.
function bbmod_light_ambient_set_affect_lightmaps(_enable)
{
	gml_pragma("forceinline");
	global.__bbmodAmbientAffectLightmap = _enable;
}
