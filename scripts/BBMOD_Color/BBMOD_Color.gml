/// @macro {Real}
/// @private
#macro __BBMOD_RGBM_RANGE 6.0

/// @macro {Real} The maximum value of a single channel when using RGBM encoded
/// colors. This is always at least 255.
#macro BBMOD_RGBM_VALUE_MAX (255.0 * __BBMOD_RGBM_RANGE)

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_aqua)`.
/// @see BBMOD_Color
#macro BBMOD_C_AQUA (new BBMOD_Color().FromConstant(c_aqua))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_black)`.
/// @see BBMOD_Color
#macro BBMOD_C_BLACK (new BBMOD_Color().FromConstant(c_black))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_blue)`.
/// @see BBMOD_Color
#macro BBMOD_C_BLUE (new BBMOD_Color().FromConstant(c_blue))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_dkgray)`.
/// @see BBMOD_Color
#macro BBMOD_C_DKGRAY (new BBMOD_Color().FromConstant(c_dkgray))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_fuchsia)`.
/// @see BBMOD_Color
#macro BBMOD_C_FUCHSIA (new BBMOD_Color().FromConstant(c_fuchsia))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_gray)`.
/// @see BBMOD_Color
#macro BBMOD_C_GRAY (new BBMOD_Color().FromConstant(c_gray))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_green)`.
/// @see BBMOD_Color
#macro BBMOD_C_GREEN (new BBMOD_Color().FromConstant(c_green))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_lime)`.
/// @see BBMOD_Color
#macro BBMOD_C_LIME (new BBMOD_Color().FromConstant(c_lime))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_ltgray)`.
/// @see BBMOD_Color
#macro BBMOD_C_LTGRAY (new BBMOD_Color().FromConstant(c_ltgray))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_maroon)`.
/// @see BBMOD_Color
#macro BBMOD_C_MAROON (new BBMOD_Color().FromConstant(c_maroon))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_navy)`.
/// @see BBMOD_Color
#macro BBMOD_C_NAVY (new BBMOD_Color().FromConstant(c_navy))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_olive)`.
/// @see BBMOD_Color
#macro BBMOD_C_OLIVE (new BBMOD_Color().FromConstant(c_olive))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_orange)`.
/// @see BBMOD_Color
#macro BBMOD_C_ORANGE (new BBMOD_Color().FromConstant(c_orange))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_purple)`.
/// @see BBMOD_Color
#macro BBMOD_C_PURPLE (new BBMOD_Color().FromConstant(c_purple))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_red)`.
/// @see BBMOD_Color
#macro BBMOD_C_RED (new BBMOD_Color().FromConstant(c_red))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_silver)`.
/// @see BBMOD_Color
#macro BBMOD_C_SILVER (new BBMOD_Color().FromConstant(c_silver))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_teal)`.
/// @see BBMOD_Color
#macro BBMOD_C_TEAL (new BBMOD_Color().FromConstant(c_teal))

/// @macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_white)`.
/// @see BBMOD_Color
#macro BBMOD_C_WHITE (new BBMOD_Color().FromConstant(c_white))

///@macro {Struct.BBMOD_Color} Shorthand for `new BBMOD_Color().FromConstant(c_yellow)`.
/// @see BBMOD_Color
#macro BBMOD_C_YELLOW (new BBMOD_Color().FromConstant(c_yellow))

/// @func BBMOD_Color([_red[, _green[, _blue[, _alpha]]]])
///
/// @desc A color struct with support for high dynamic range.
///
/// @param {Real} [_red] The value of the red channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {Real} [_green] The value of the green channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {Real} [_blue] The value of the blue channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {Real} [_alpha] The value of the alpha channel. Use values in range
/// 0..1. Defaults to 1.
///
/// @see BBMOD_C_AQUA
/// @see BBMOD_C_BLACK
/// @see BBMOD_C_BLUE
/// @see BBMOD_C_DKGRAY
/// @see BBMOD_C_FUCHSIA
/// @see BBMOD_C_GRAY
/// @see BBMOD_C_GREEN
/// @see BBMOD_C_LIME
/// @see BBMOD_C_LTGRAY
/// @see BBMOD_C_MAROON
/// @see BBMOD_C_NAVY
/// @see BBMOD_C_OLIVE
/// @see BBMOD_C_ORANGE
/// @see BBMOD_C_PURPLE
/// @see BBMOD_C_RED
/// @see BBMOD_C_SILVER
/// @see BBMOD_C_TEAL
/// @see BBMOD_C_WHITE
/// @see BBMOD_C_YELLOW
/// @see BBMOD_RGBM_VALUE_MAX
function BBMOD_Color(
	_red=255.0,
	_green=255.0,
	_blue=255.0,
	_alpha=1.0) constructor
{
	/// @var {Real} The value of the red color channel.
	Red = _red;

	/// @var {Real} The value of the green color channel.
	Green = _green;

	/// @var {Real} The value of the blue color channel.
	Blue = _blue;

	/// @var {Real} The value of the alpha channel.
	Alpha = _alpha;

	/// @func Copy(_dest)
	///
	/// @desc Copies properties to another color struct.
	///
	/// @return {Struct.BBMOD_Color} Returns `self`.
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		_dest.Red = Red;
		_dest.Green = Green;
		_dest.Blue = Blue;
		_dest.Alpha = Alpha;
		return self;
	};

	/// @func Clone()
	///
	/// @desc Creates a clone of the color struct.
	///
	/// @return {Struct.BBMOD_Color} The created clone.
	static Clone = function () {
		gml_pragma("forceinline");
		var _clone = new BBMOD_Color();
		Copy(_clone);
		return _clone;
	};

	/// @func FromConstant(_color)
	///
	/// @desc Initializes the color using a color constant.
	///
	/// @param {Real} _color The color constant.
	///
	/// @return {Struct.BBMOD_Color} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _red = new BBMOD_Color().FromConstant(c_red);
	/// ```
	static FromConstant = function (_color) {
		gml_pragma("forceinline");
		Red = color_get_red(_color);
		Green = color_get_green(_color);
		Blue = color_get_blue(_color);
		return self;
	};

	/// @func FromRGBA(_red, _green, _blue[, _alpha])
	///
	/// @desc Initializes the color using RGBA.
	///
	/// @param {Real} _red The value of the red channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	/// @param {Real} _green The value of the green channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	/// @param {Real} _blue The value of the blue channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	///
	/// @param {Real} [_alpha] The value of the alpha channel. Defaults to 1.
	///
	/// @return {Struct.BBMOD_Color} Returns `self`.
	static FromRGBA = function (_red, _green, _blue, _alpha=1.0) {
		gml_pragma("forceinline");
		Red = _red;
		Green = _green;
		Blue = _blue;
		Alpha = _alpha;
		return self;
	};

	/// @func FromHex(_hex)
	///
	/// @desc Initializes the color using `RRGGBB` hexadecimal format. Alpha
	/// channel is set to 1.
	///
	/// @param {Real} _hex The hexadecimal color.
	///
	/// @return {Struct.BBMOD_Color} Returns `self`.
	///
	/// @example
	/// ```gml
	/// new BBMOD_Color().FromHex($FF0000); // Same as FromConstant(c_red)
	/// new BBMOD_Color().FromHex($00FF00); // Same as FromConstant(c_lime)
	/// new BBMOD_Color().FromHex($0000FF); // Same as FromConstant(c_blue)
	/// ```
	static FromHex = function (_hex) {
		gml_pragma("forceinline");
		Red = color_get_blue(_hex);
		Green = color_get_green(_hex);
		Blue = color_get_red(_hex);
		Alpha = 1.0;
		return self;
	};

	/// @func FromHSV(_hue, _saturation, _value)
	///
	/// @desc Initializes the color using HSV. Alpha channel is set to 1.
	///
	/// @param {Real} _hue Color hue. Use values in range 0..255.
	/// @param {Real} _saturation Color saturation. Use values in range 0..255.
	/// @param {Real} _value Color value. Use values in range 0..255.
	///
	/// @return {Struct.BBMOD_Color} Returns `self`.
	static FromHSV = function (_hue, _saturation, _value) {
		gml_pragma("forceinline");
		var _hsv = make_color_hsv(_hue, _saturation, _value);
		Red = color_get_red(_hsv);
		Green = color_get_green(_hsv);
		Blue = color_get_blue(_hsv);
		Alpha = 1.0;
		return self;
	};

	/// @func Mix(_color, _factor)
	///
	/// @desc Mixes two colors.
	///
	/// @param {Struct.BBMOD_Color} _color The other color to mix this one with.
	///
	/// @param {Real} _factor The mixing factor. Use values in range 0..1,
	/// where 0 would result into this color, 1 would be the other color and
	/// 0.5 would return a merge of both colors equally.
	///
	/// @return {Struct.BBMOD_Color} The new color.
	static Mix = function (_color, _factor) {
		gml_pragma("forceinline");
		return new BBMOD_Color(
			lerp(Red, _color.Red, _factor),
			lerp(Green, _color.Green, _factor),
			lerp(Blue, _color.Blue, _factor),
			lerp(Alpha, _color.Alpha, _factor));
	};

	/// @func ToConstant()
	///
	/// @desc Encodes the color into a single value, compatible with GameMaker's
	/// color constants. Ignores the alpha channel.
	///
	/// @return {Constant.Color} The color as a single value.
	///
	/// @example
	/// ```gml
	/// var _red = new BBMOD_Color(255, 0, 0);
	/// show_debug_message(_red.ToConstant() == c_red); // Prints true
	/// ```
	static ToConstant = function () {
		gml_pragma("forceinline");
		return make_color_rgb(Red, Green, Blue);
	};

	/// @func ToHSV([_array[, _index]])
	///
	/// @desc Encodes the color into HSV format, ignoring the alpha channel.
	///
	/// @param {Array<Real>} [_array] The array to output the values to. A new
	/// one is created if not defined.
	/// @param {Real} [_index] The index to start writing the values to. Defaults
	/// to 0.
	///
	/// @return {Array<Real>} Returns the array with HSV values.
	static ToHSV = function (_array, _index) {
		gml_pragma("forceinline");
		_array = (_array != undefined) ? _array : array_create(3, 0);
		_index = (_index != undefined) ? _index : 0;
		var _rgb = make_color_rgb(Red, Green, Blue);
		_array[@ _index] = color_get_hue(_rgb);
		_array[@ _index + 1] = color_get_saturation(_rgb);
		_array[@ _index + 2] = color_get_value(_rgb);
		return _array;
	};

	/// @func ToRGBM([_array[, _index]])
	///
	/// @desc Encodes the color into RGBM format, ignoring the alpha channel.
	///
	/// @param {Array<Real>} [_array] The array to output the values to. If
	/// `undefined`, then a new one is created.
	/// @param {Real} [_index] The index to start writing the values to.
	/// Defaults to 0.
	///
	/// @return {Array<Real>} Returns the array with RGBM values.
	static ToRGBM = function (_array=undefined, _index=0) {
		gml_pragma("forceinline");
		_array ??= array_create(4, 0);
		var _red = min(Red / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _green = min(Green / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _blue = min(Blue / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _alpha = clamp(max(_red, _green, _blue, 0.000001), 0.0, 1.0);
		_alpha = ceil(_alpha * 255.0) / 255.0;
		_array[@ _index] = _red / _alpha;
		_array[@ _index + 1] = _green / _alpha;
		_array[@ _index + 2] = _blue / _alpha;
		_array[@ _index + 3] = _alpha;
		return _array;
	};
}
