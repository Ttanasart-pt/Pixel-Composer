// Generated at 2022-12-14 10:28:54 (1226ms) for v2.3.7+
/// @lint nullToAny true
// Feather disable all
#region prototypes
globalvar mq_game_frame_button; mq_game_frame_button = [undefined, /* 1:name */undefined, /* 2:custom */undefined, /* 3:icon */undefined, /* 4:subimg */0, /* 5:margin_left */0, /* 6:margin_right */0, /* 7:hover */undefined, /* 8:pressed */undefined, /* 9:enabled */undefined, /* 10:fade */0, /* 11:click */undefined, /* 12:get_width */0, /* 13:update */undefined, /* 14:draw_underlay */undefined, /* 15:draw_icon */undefined];
globalvar mq_gameframe_delayed_item; mq_gameframe_delayed_item = [undefined, /* 1:func */undefined, /* 2:time */0, /* 3:arg0 */undefined, /* 4:arg1 */undefined, /* 5:arg2 */undefined, /* 6:arg3 */undefined];
#endregion
#region metatype
globalvar gameframe_std_haxe_type_markerValue; gameframe_std_haxe_type_markerValue = [];
globalvar mt_game_frame_button;
globalvar mt_gameframe_delayed_item;
globalvar mt_gameframe_std_haxe_class;
(function() {
mt_game_frame_button = new gameframe_std_haxe_class(7, "game_frame_button");
mt_gameframe_delayed_item = new gameframe_std_haxe_class(8, "gameframe_delayed_item");
mt_gameframe_std_haxe_class = new gameframe_std_haxe_class(-1, "gameframe_std_haxe_class");
})();
#endregion

#region gameframe

function gameframe_log(_args1) {
	// gameframe_log(args:haxe_Rest<any>)
	if (!gameframe_debug) exit;
	var _s = "[Gameframe]";
	var __g = 0;
	while (__g < argument_count) {
		var _arg = argument[__g];
		__g++;
		_s += " " + gameframe_std_Std_stringify(_arg);
	}
	show_debug_message(_s);
}

function gameframe_update() {
	/// gameframe_update()
	/// @returns {void}
	if (!gameframe_is_ready) exit;
	gameframe_effective_scale = display_get_dpi_x() / 96 / gameframe_dpi_scale;
	gameframe_mouse_over_frame = false;
	gameframe_delayed_update();
	gameframe_cover_ensure();
	if (window_get_fullscreen() || gameframe_isFullscreen_hx) {
		gameframe_tools_keyctl_reset();
		exit;
	}
	gameframe_tools_keyctl_update();
	if (!gameframe_isMaximized_hx && gameframe_has_native_extension && gameframe_delayed_frame_index > 3 && !gameframe_get_shadow()) gameframe_set_shadow(true);
	var _mx = (window_mouse_get_x() | 0);
	var _my = (window_mouse_get_y() | 0);
	var _gw = window_get_width();
	var _gh = window_get_height();
	var __borderWidth = (gameframe_isMaximized_hx ? 0 : gameframe_border_width);
	var __titleHeight = gameframe_caption_get_height();
	var __buttons_x = gameframe_button_get_combined_offset(_gw);
	var __flags = 0;
	var __titleHit = false;
	var __hitSomething = true;
	var _resizePadding = gameframe_resize_padding;
	if (!point_in_rectangle(_mx, _my, __buttons_x, __borderWidth, _gw - __borderWidth - ((gameframe_isMaximized_hx ? 0 : _resizePadding)), __borderWidth + __titleHeight)) {
		if (!gameframe_isMaximized_hx && gameframe_can_resize && !point_in_rectangle(_mx, _my, _resizePadding, _resizePadding, _gw - _resizePadding, _gh - _resizePadding)) {
			if (_mx < _resizePadding) __flags |= 1;
			if (_my < _resizePadding) __flags |= 2;
			if (_mx >= _gw - _resizePadding) __flags |= 4;
			if (_my >= _gh - _resizePadding) __flags |= 8;
		} else if (point_in_rectangle(_mx, _my, 0, 0, _gw, __titleHeight)) {
			__titleHit = true;
		} else __hitSomething = false;
	}
	gameframe_mouse_over_frame = __hitSomething;
	if (gameframe_drag_flags == 0) {
		var __cursor = gameframe_default_cursor;
		if (gameframe_can_input && gameframe_can_resize) switch (__flags) {
			case 1: case 4: __cursor = cr_size_we; break;
			case 2: case 8: __cursor = cr_size_ns; break;
			case 3: case 12: __cursor = cr_size_nwse; break;
			case 6: case 9: __cursor = cr_size_nesw; break;
		}
		gameframe_set_window_cursor(__cursor);
	}
	gameframe_button_update(__buttons_x, __borderWidth, __titleHeight, _mx, _my);
	if (gameframe_can_input && mouse_check_button_pressed(1)) {
		if (__titleHit) {
			var __now = current_time;
			if (__now < gameframe_last_title_click_at + gameframe_double_click_time) {
				//if (gameframe_isMaximized_hx) gameframe_restore(); else gameframe_maximize();
			} else {
				gameframe_last_title_click_at = __now;
				if (gameframe_isMaximized_hx) {
					gameframe_drag_start(32); 
				} else {
					gameframe_drag_start(16);
				}
			}
		} else if (__flags != 0 && gameframe_can_resize) {
			gameframe_drag_start(__flags);
		}
	}
	if (gameframe_can_input) {
		if (mouse_check_button_released(1)) gameframe_drag_stop(); else gameframe_drag_update();
	} else if (gameframe_drag_flags != 0) {
		gameframe_drag_stop();
	}
}

function gameframe_init() {
	/// gameframe_init()
	/// @returns {void}
	gameframe_is_ready = true;
	gameframe_has_native_extension = gameframe_check_native_extension();
	gameframe_double_click_time = (gameframe_has_native_extension ? gameframe_get_double_click_time() : 500);
	gameframe_init_native();
	gameframe_tools_rect_get_window_rect(gameframe_restoreRect_hx);
	gameframe_button_add_defaults();
	gameframe_set_shadow(true);
}

#endregion

#region game_frame_button

function game_frame_button_create(_name, _icon, _subimg, _onClick) {
	/// game_frame_button_create(name:string, icon:sprite, subimg:int, onClick:function<game_frame_button; void>)
	/// @param {string} name
	/// @param {sprite} icon
	/// @param {int} subimg
	/// @param {function<game_frame_button; void>} onClick
	/// @returns {game_frame_button}
	var _this = [mt_game_frame_button];
	array_copy(_this, 1, mq_game_frame_button, 1, 15);
	/// @typedef {tuple<any,name:string,custom:any,icon:sprite,subimg:int,margin_left:int,margin_right:int,hover:bool,pressed:bool,enabled:bool,fade:number,click:function<button:game_frame_button; void>,get_width:function<button:game_frame_button; int>,update:function<button:game_frame_button; void>,draw_underlay:function<button:game_frame_button; x:number; y:number; width:number; height:number; void>,draw_icon:function<button:game_frame_button; x:number; y:number; width:number; height:number; void>>} game_frame_button
	_this[@15/* draw_icon */] = game_frame_button_draw_icon_default;
	_this[@14/* draw_underlay */] = game_frame_button_draw_underlay_default;
	_this[@13/* update */] = game_frame_button_update_default;
	_this[@12/* get_width */] = game_frame_button_get_width_default;
	_this[@10/* fade */] = 0.;
	_this[@9/* enabled */] = true;
	_this[@8/* pressed */] = false;
	_this[@7/* hover */] = false;
	_this[@6/* margin_right */] = 0;
	_this[@5/* margin_left */] = 0;
	_this[@1/* name */] = _name;
	_this[@3/* icon */] = _icon;
	_this[@4/* subimg */] = _subimg;
	_this[@11/* click */] = _onClick;
	return _this;
}

function game_frame_button_get_width_default(_b) {
	// game_frame_button_get_width_default(b:game_frame_button)->int
	return sprite_get_width(_b[3/* icon */]);
}

function game_frame_button_update_default(_b) {
	// game_frame_button_update_default(b:game_frame_button)
	
}

function game_frame_button_draw_underlay_default(_b, _x, _y, _width, _height) {
	// game_frame_button_draw_underlay_default(b:game_frame_button, x:number, y:number, width:number, height:number)
	var _alpha1;
	if (_b[9/* enabled */]) {
		if (_b[8/* pressed */]) {
			_alpha1 = 0.7;
			_b[@10/* fade */] = 1;
		} else {
			var _dt = delta_time / 1000000;
			if (_b[7/* hover */]) {
				if (_b[10/* fade */] < 1) _b[@10/* fade */] = min(_b[10/* fade */] + _dt / gameframe_button_fade_time, 1);
			} else if (_b[10/* fade */] > 0) {
				_b[@10/* fade */] = max(_b[10/* fade */] - _dt / gameframe_button_fade_time, 0);
			}
			_alpha1 = _b[10/* fade */] * 0.3;
		}
	} else _alpha1 = 0.;
	draw_sprite_stretched_ext(gameframe_spr_pixel, 0, _x, _y, _width, _height, gameframe_blend, gameframe_alpha * _alpha1);
}

function game_frame_button_draw_icon_default(_b, _x, _y, _width, _height) {
	// game_frame_button_draw_icon_default(b:game_frame_button, x:number, y:number, width:number, height:number)
	var _icon = _b[3/* icon */];
	var _scale = gameframe_effective_scale;
	draw_sprite_ext(_icon, _b[4/* subimg */], (_x + ((_width - sprite_get_width(_icon) * _scale) div 2) + (sprite_get_xoffset(_icon) * _scale | 0)), _y + ((_height - sprite_get_height(_icon) * _scale) div 2) + (sprite_get_yoffset(_icon) * _scale | 0), _scale, _scale, 0, gameframe_blend, gameframe_alpha * ((_b[9/* enabled */] ? 1 : 0.3)));
}

function game_frame_button_set_name(_this, _value) {
	/// game_frame_button_set_name(this:game_frame_button, value:string)
	/// @param {game_frame_button} this
	/// @param {string} value
	/// @returns {void}
	_this[@1/* name */] = _value;
}

function game_frame_button_get_name(_this) {
	/// game_frame_button_get_name(this:game_frame_button)->string
	/// @param {game_frame_button} this
	/// @returns {string}
	return _this[1/* name */];
}

function game_frame_button_set_custom(_this, _value) {
	/// game_frame_button_set_custom(this:game_frame_button, value:any)
	/// @param {game_frame_button} this
	/// @param {any} value
	/// @returns {void}
	_this[@2/* custom */] = _value;
}

function game_frame_button_get_custom(_this) {
	/// game_frame_button_get_custom(this:game_frame_button)->any
	/// @param {game_frame_button} this
	/// @returns {any}
	return _this[2/* custom */];
}

function game_frame_button_set_icon(_this, _value) {
	/// game_frame_button_set_icon(this:game_frame_button, value:sprite)
	/// @param {game_frame_button} this
	/// @param {sprite} value
	/// @returns {void}
	_this[@3/* icon */] = _value;
}

function game_frame_button_get_icon(_this) {
	/// game_frame_button_get_icon(this:game_frame_button)->sprite
	/// @param {game_frame_button} this
	/// @returns {sprite}
	return _this[3/* icon */];
}

function game_frame_button_set_subimg(_this, _value) {
	/// game_frame_button_set_subimg(this:game_frame_button, value:int)
	/// @param {game_frame_button} this
	/// @param {int} value
	/// @returns {void}
	_this[@4/* subimg */] = _value;
}

function game_frame_button_get_subimg(_this) {
	/// game_frame_button_get_subimg(this:game_frame_button)->int
	/// @param {game_frame_button} this
	/// @returns {int}
	return _this[4/* subimg */];
}

function game_frame_button_set_margin_left(_this, _value) {
	/// game_frame_button_set_margin_left(this:game_frame_button, value:int)
	/// @param {game_frame_button} this
	/// @param {int} value
	/// @returns {void}
	_this[@5/* margin_left */] = _value;
}

function game_frame_button_get_margin_left(_this) {
	/// game_frame_button_get_margin_left(this:game_frame_button)->int
	/// @param {game_frame_button} this
	/// @returns {int}
	return _this[5/* margin_left */];
}

function game_frame_button_set_margin_right(_this, _value) {
	/// game_frame_button_set_margin_right(this:game_frame_button, value:int)
	/// @param {game_frame_button} this
	/// @param {int} value
	/// @returns {void}
	_this[@6/* margin_right */] = _value;
}

function game_frame_button_get_margin_right(_this) {
	/// game_frame_button_get_margin_right(this:game_frame_button)->int
	/// @param {game_frame_button} this
	/// @returns {int}
	return _this[6/* margin_right */];
}

function game_frame_button_set_hover(_this, _value) {
	/// game_frame_button_set_hover(this:game_frame_button, value:bool)
	/// @param {game_frame_button} this
	/// @param {bool} value
	/// @returns {void}
	_this[@7/* hover */] = _value;
}

function game_frame_button_get_hover(_this) {
	/// game_frame_button_get_hover(this:game_frame_button)->bool
	/// @param {game_frame_button} this
	/// @returns {bool}
	return _this[7/* hover */];
}

function game_frame_button_set_pressed(_this, _value) {
	/// game_frame_button_set_pressed(this:game_frame_button, value:bool)
	/// @param {game_frame_button} this
	/// @param {bool} value
	/// @returns {void}
	_this[@8/* pressed */] = _value;
}

function game_frame_button_get_pressed(_this) {
	/// game_frame_button_get_pressed(this:game_frame_button)->bool
	/// @param {game_frame_button} this
	/// @returns {bool}
	return _this[8/* pressed */];
}

function game_frame_button_set_enabled(_this, _value) {
	/// game_frame_button_set_enabled(this:game_frame_button, value:bool)
	/// @param {game_frame_button} this
	/// @param {bool} value
	/// @returns {void}
	_this[@9/* enabled */] = _value;
}

function game_frame_button_get_enabled(_this) {
	/// game_frame_button_get_enabled(this:game_frame_button)->bool
	/// @param {game_frame_button} this
	/// @returns {bool}
	return _this[9/* enabled */];
}

function game_frame_button_set_fade(_this, _value) {
	/// game_frame_button_set_fade(this:game_frame_button, value:number)
	/// @param {game_frame_button} this
	/// @param {number} value
	/// @returns {void}
	_this[@10/* fade */] = _value;
}

function game_frame_button_get_fade(_this) {
	/// game_frame_button_get_fade(this:game_frame_button)->number
	/// @param {game_frame_button} this
	/// @returns {number}
	return _this[10/* fade */];
}

function game_frame_button_set_click(_this, _value) {
	/// game_frame_button_set_click(this:game_frame_button, value:function<button:game_frame_button; void>)
	/// @param {game_frame_button} this
	/// @param {function<button:game_frame_button; void>} value
	/// @returns {void}
	_this[@11/* click */] = _value;
}

function game_frame_button_get_click(_this) {
	/// game_frame_button_get_click(this:game_frame_button)->function<button:game_frame_button; void>
	/// @param {game_frame_button} this
	/// @returns {function<button:game_frame_button; void>}
	return _this[11/* click */];
}

function game_frame_button_set_get_width(_this, _value) {
	/// game_frame_button_set_get_width(this:game_frame_button, value:function<button:game_frame_button; int>)
	/// @param {game_frame_button} this
	/// @param {function<button:game_frame_button; int>} value
	/// @returns {void}
	_this[@12/* get_width */] = _value;
}

function game_frame_button_get_get_width(_this) {
	/// game_frame_button_get_get_width(this:game_frame_button)->function<button:game_frame_button; int>
	/// @param {game_frame_button} this
	/// @returns {function<button:game_frame_button; int>}
	return _this[12/* get_width */];
}

function game_frame_button_set_update(_this, _value) {
	/// game_frame_button_set_update(this:game_frame_button, value:function<button:game_frame_button; void>)
	/// @param {game_frame_button} this
	/// @param {function<button:game_frame_button; void>} value
	/// @returns {void}
	_this[@13/* update */] = _value;
}

function game_frame_button_get_update(_this) {
	/// game_frame_button_get_update(this:game_frame_button)->function<button:game_frame_button; void>
	/// @param {game_frame_button} this
	/// @returns {function<button:game_frame_button; void>}
	return _this[13/* update */];
}

function game_frame_button_set_draw_underlay(_this, _value) {
	/// game_frame_button_set_draw_underlay(this:game_frame_button, value:function<button:game_frame_button; x:number; y:number; width:number; height:number; void>)
	/// @param {game_frame_button} this
	/// @param {function<button:game_frame_button; x:number; y:number; width:number; height:number; void>} value
	/// @returns {void}
	_this[@14/* draw_underlay */] = _value;
}

function game_frame_button_get_draw_underlay(_this) {
	/// game_frame_button_get_draw_underlay(this:game_frame_button)->function<button:game_frame_button; x:number; y:number; width:number; height:number; void>
	/// @param {game_frame_button} this
	/// @returns {function<button:game_frame_button; x:number; y:number; width:number; height:number; void>}
	return _this[14/* draw_underlay */];
}

function game_frame_button_set_draw_icon(_this, _value) {
	/// game_frame_button_set_draw_icon(this:game_frame_button, value:function<button:game_frame_button; x:number; y:number; width:number; height:number; void>)
	/// @param {game_frame_button} this
	/// @param {function<button:game_frame_button; x:number; y:number; width:number; height:number; void>} value
	/// @returns {void}
	_this[@15/* draw_icon */] = _value;
}

function game_frame_button_get_draw_icon(_this) {
	/// game_frame_button_get_draw_icon(this:game_frame_button)->function<button:game_frame_button; x:number; y:number; width:number; height:number; void>
	/// @param {game_frame_button} this
	/// @returns {function<button:game_frame_button; x:number; y:number; width:number; height:number; void>}
	return _this[15/* draw_icon */];
}

#endregion

#region gameframe_button

function gameframe_button_get_combined_width() {
	/// gameframe_button_get_combined_width()->int
	/// @returns {int}
	var _w = 0;
	var __g = 0;
	var __g1 = gameframe_button_array;
	while (__g < array_length(__g1)) {
		var _b = __g1[__g];
		__g++;
		_w += _b[5/* margin_left */] + _b[12/* get_width */](_b) + _b[6/* margin_right */];
	}
	return ceil(_w * gameframe_effective_scale);
}

function gameframe_button_get_combined_offset(_windowWidth) {
	/// gameframe_button_get_combined_offset(windowWidth:int)->int
	/// @param {int} windowWidth
	/// @returns {int}
	return _windowWidth - ((gameframe_isMaximized_hx ? 0 : gameframe_border_width)) - gameframe_button_get_combined_width();
}

function gameframe_button_reset() {
	/// gameframe_button_reset()
	/// @returns {void}
	var __g = 0;
	var __g1 = gameframe_button_array;
	while (__g < array_length(__g1)) {
		var _b = __g1[__g];
		__g++;
		_b[@7/* hover */] = false;
		_b[@10/* fade */] = 0.;
		_b[@8/* pressed */] = false;
	}
}

function gameframe_button_update(_x, _y, _height, _mx, _my) {
	// gameframe_button_update(x:number, y:number, height:int, mx:int, my:int)
	var _over_row = _mx >= _y && _my < _y + _height;
	if (_over_row) {
		if (gameframe_has_native_extension) {
			_over_row = gameframe_mouse_in_window();
		} else {
			var _wx = window_get_x();
			var _wy = window_get_y();
			var _dmx = display_mouse_get_x();
			var _dmy = display_mouse_get_y();
			_over_row = _dmx >= _wx && _dmy >= _wy && _dmx < _wx + window_get_width() && _dmy < _wy + window_get_height();
		}
	}
	if (gameframe_button_wait_for_movement) {
		if (_mx != gameframe_button_wait_for_movement_x || _my != gameframe_button_wait_for_movement_y) gameframe_button_wait_for_movement = false; else _over_row = false;
	}
	var _dpiScale = gameframe_effective_scale;
	var _pressed = mouse_check_button_pressed(1);
	var _released = mouse_check_button_released(1);
	var _disable = gameframe_drag_flags != 0 || !gameframe_can_input;
	var _i = 0;
	for (var __g1 = array_length(gameframe_button_array); _i < __g1; _i++) {
		var _button = gameframe_button_array[_i];
		_button[13/* update */](_button);
		_x += _button[5/* margin_left */] * _dpiScale;
		var _width = _button[12/* get_width */](_button) * _dpiScale;
		if (_disable || !_button[9/* enabled */]) {
			_button[@7/* hover */] = false;
			_button[@8/* pressed */] = false;
		} else if (_over_row && _mx >= _x && _mx < _x + _width) {
			_button[@7/* hover */] = true;
			if (_pressed) _button[@8/* pressed */] = true;
		} else _button[@7/* hover */] = false;
		if (_released && _button[8/* pressed */] && _button[7/* hover */]) {
			_button[@8/* pressed */] = false;
			_button[11/* click */](_button);
		}
		_x += _width + _button[6/* margin_right */] * _dpiScale;
	}
}

function gameframe_button_draw(_x, _y, _height) {
	// gameframe_button_draw(x:number, y:number, height:int)
	var _dpiScale = gameframe_effective_scale;
	var _i = 0;
	for (var __g1 = array_length(gameframe_button_array); _i < __g1; _i++) {
		var _button = gameframe_button_array[_i];
		_x += _button[5/* margin_left */] * _dpiScale;
		var _width = _button[12/* get_width */](_button) * _dpiScale;
		_button[14/* draw_underlay */](_button, _x, _y, _width, _height);
		_button[15/* draw_icon */](_button, _x, _y, _width, _height);
		_x += _width + _button[6/* margin_right */] * _dpiScale;
	}
}

function gameframe_button_add_defaults() {
	// gameframe_button_add_defaults()
	gameframe_button_array = [];
	var _minimize = game_frame_button_create("minimize", gameframe_spr_buttons, 0, function(_button) {
		gameframe_minimize()
	});
	if (!gameframe_has_native_extension) _minimize[@9/* enabled */] = false;
	array_push(gameframe_button_array, _minimize);
	var _maxrest = game_frame_button_create("maxrest", gameframe_spr_buttons, 1, function(_button) {
		if (gameframe_isMaximized_hx) gameframe_restore(); else gameframe_maximize();
		gameframe_button_reset();
	});
	_maxrest[@13/* update */] = function(_b) {
		_b[@4/* subimg */] = (gameframe_isMaximized_hx ? 2 : 1);
		_b[@9/* enabled */] = gameframe_can_resize;
	}
	array_push(gameframe_button_array, _maxrest);
	var _close = game_frame_button_create("close", gameframe_spr_buttons, 3, function(__) {
		game_end()
	});
	_close[@14/* draw_underlay */] = function(_b, __x, __y, __width, __height) {
		var __alpha = 0.;
		if (_b[8/* pressed */]) {
			__alpha = 0.7;
			_b[@10/* fade */] = 1;
		} else {
			var _dt = delta_time / 1000000;
			if (_b[7/* hover */]) {
				if (_b[10/* fade */] < 1) {
					_b[@10/* fade */] = max(_b[10/* fade */], 0.5);
					_b[@10/* fade */] = min(_b[10/* fade */] + _dt / gameframe_button_fade_time, 1);
				}
			} else if (_b[10/* fade */] > 0) {
				_b[@10/* fade */] = max(_b[10/* fade */] - _dt / gameframe_button_fade_time, 0);
			}
			__alpha = gameframe_alpha * _b[10/* fade */];
		}
		draw_sprite_stretched_ext(gameframe_spr_pixel, 0, __x, __y, __width, __height, 2298344, __alpha);
	}
	array_push(gameframe_button_array, _close);
}

#endregion

#region gameframe_tools_rect

function gameframe_tools_rect__new(_x, _y, _w, _h) {
	// gameframe_tools_rect__new(...:int)->gameframe_tools_rect
	if (_x == undefined) _x = 0;
	if (_y == undefined) _y = 0;
	if (_w == undefined) _w = 0;
	if (_h == undefined) _h = 0;
	if (false) show_debug_message(argument[3]);
	return [/* x: */_x, /* y: */_y, /* width: */_w, /* height: */_h];
}

function gameframe_tools_rect_get_window_rect(_this1) {
	// gameframe_tools_rect_get_window_rect(this:tools_GfRectImpl)
	_this1[@0/* x */] = window_get_x();
	_this1[@1/* y */] = window_get_y();
	_this1[@2/* width */] = window_get_width();
	_this1[@3/* height */] = window_get_height();
}

function gameframe_tools_rect_set_window_rect(_this1) {
	// gameframe_tools_rect_set_window_rect(this:tools_GfRectImpl)
	window_set_rectangle(_this1[0/* x */], _this1[1/* y */], _this1[2/* width */], _this1[3/* height */]);
}

function gameframe_tools_rect_equals(_this1, _o) {
	// gameframe_tools_rect_equals(this:tools_GfRectImpl, o:gameframe_tools_rect)->bool
	return _this1[0/* x */] == _o[0/* x */] && _this1[1/* y */] == _o[1/* y */] && _this1[2/* width */] == _o[2/* width */] && _this1[3/* height */] == _o[3/* height */];
}

function gameframe_tools_rect_set_to(_this1, _o) {
	// gameframe_tools_rect_set_to(this:tools_GfRectImpl, o:gameframe_tools_rect)
	_this1[@0/* x */] = _o[0/* x */];
	_this1[@1/* y */] = _o[1/* y */];
	_this1[@2/* width */] = _o[2/* width */];
	_this1[@3/* height */] = _o[3/* height */];
}

#endregion

#region gameframe

function gameframe_minimize() {
	gameframe_drag_flags = 0;
	/// gameframe_minimize()
	/// @returns {void}
	if (gameframe_is_natively_minimized()) exit;
	gameframe_button_reset();
	gameframe_delayed_call_impl(function() {
		gameframe_button_wait_for_movement = true;
		gameframe_button_wait_for_movement_x = window_mouse_get_x();
		gameframe_button_wait_for_movement_y = window_mouse_get_y();
		gameframe_syscommand(61472);
	}, 1, undefined, undefined, undefined, undefined);
}

function gameframe_minimise() {
	// gameframe_minimise()
	if (!gameframe_is_natively_minimized()) {
		gameframe_button_reset();
		gameframe_delayed_call_impl(function() {
			gameframe_button_wait_for_movement = true;
			gameframe_button_wait_for_movement_x = window_mouse_get_x();
			gameframe_button_wait_for_movement_y = window_mouse_get_y();
			gameframe_syscommand(61472);
		}, 1, undefined, undefined, undefined, undefined);
	}
}

function gameframe_is_minimized() {
	/// gameframe_is_minimized()->bool
	/// @returns {bool}
	return gameframe_is_natively_minimized();
}

function gameframe_is_minimised() {
	// gameframe_is_minimised()->bool
	return gameframe_is_natively_minimized();
}

function gameframe_maximize() {
	/// gameframe_maximize()
	/// @returns {void}
	if (gameframe_isMaximized_hx || gameframe_isFullscreen_hx || window_get_fullscreen()) exit;
	gameframe_isMaximized_hx = true;
	gameframe_store_rect();
	gameframe_maximize_1();
}

function gameframe_maximise() {
	// gameframe_maximise()
	if (!(gameframe_isMaximized_hx || gameframe_isFullscreen_hx || window_get_fullscreen())) {
		gameframe_isMaximized_hx = true;
		gameframe_store_rect();
		gameframe_maximize_1();
	}
}

function gameframe_is_maximized() {
	/// gameframe_is_maximized()->bool
	/// @returns {bool}
	return gameframe_isMaximized_hx;
}

function gameframe_is_maximised() {
	// gameframe_is_maximised()->bool
	return gameframe_isMaximized_hx;
}

function gameframe_maximize_1() {
	// gameframe_maximize_1()
	var __work = gameframe_tools_mon_get_active()[1/* workspace */];
	if (gameframe_debug) gameframe_log("maximize: ", __work);
	gameframe_tools_rect_set_window_rect(__work);
	gameframe_set_shadow(false);
}

function gameframe_store_rect() {
	// gameframe_store_rect()
	gameframe_tools_rect_get_window_rect(gameframe_restoreRect_hx);
	if (gameframe_debug) gameframe_log("storeRect: ", gameframe_restoreRect_hx);
}

function gameframe_restore(__force) {
	/// gameframe_restore(_force:bool = false)
	/// @param {bool} [_force=false]
	/// @returns {void}
	if (__force == undefined) __force = false;
	if (false) show_debug_message(argument[0]);
	if (window_get_fullscreen()) {
		window_set_fullscreen(false);
		gameframe_delayed_call_impl(function() {
			gameframe_restore()
		}, 1, undefined, undefined, undefined, undefined);
		exit;
	}
	if (!__force && !gameframe_isMaximized_hx && !gameframe_isFullscreen_hx) exit;
	gameframe_isMaximized_hx = false;
	gameframe_isFullscreen_hx = false;
	var __rect = gameframe_restoreRect_hx;
	if (gameframe_debug) gameframe_log("restore: ", __rect);
	gameframe_tools_rect_set_window_rect(__rect);
	gameframe_set_shadow(true);
}

function gameframe_set_fullscreen(_mode) {
	/// gameframe_set_fullscreen(mode:int)
	/// @param {int} mode
	/// @returns {void}
	gameframe_set_fullscreen_1(_mode);
}

function gameframe_get_fullscreen() {
	/// gameframe_get_fullscreen()->int
	/// @returns {int}
	if (window_get_fullscreen()) return 1;
	if (gameframe_isFullscreen_hx) return 2; else return 0;
}

function gameframe_is_fullscreen_window() {
	/// gameframe_is_fullscreen_window()->bool
	/// @returns {bool}
	return !window_get_fullscreen() && gameframe_isFullscreen_hx;
}

function gameframe_set_fullscreen_1(__mode, __wasFullscreen) {
	// gameframe_set_fullscreen_1(_mode:int, _wasFullscreen:bool = false)
	if (__wasFullscreen == undefined) __wasFullscreen = false;
	if (false) show_debug_message(argument[1]);
	if (gameframe_debug) gameframe_log("setFullscreen(mode:", __mode, ", wasfs:", __wasFullscreen, ")");
	if (__mode == 1 || __mode == 2) {
		gameframe_button_reset();
		gameframe_drag_stop();
	}
	switch (__mode) {
		case 1:
			if (window_get_fullscreen()) exit;
			if (gameframe_isFullscreen_hx) {
				gameframe_restore();
				gameframe_delayed_call_impl(function() {
					gameframe_set_fullscreen_1(1)
				}, 1, undefined, undefined, undefined, undefined);
				exit;
			} else gameframe_store_rect();
			window_set_fullscreen(true);
			break;
		case 2:
			if (window_get_fullscreen()) {
				window_set_fullscreen(false);
				gameframe_delayed_call_impl(function() {
					gameframe_set_fullscreen_1(2, true)
				}, 10, undefined, undefined, undefined, undefined);
				exit;
			}
			if (gameframe_isFullscreen_hx) exit;
			gameframe_isFullscreen_hx = true;
			if (!gameframe_isMaximized_hx && !__wasFullscreen) gameframe_store_rect();
			gameframe_tools_rect_set_window_rect(gameframe_tools_mon_get_active()[0/* screen */]);
			gameframe_set_shadow(false);
			break;
		default:
			if (window_get_fullscreen() && gameframe_isFullscreen_hx) {
				window_set_fullscreen(false);
				gameframe_delayed_call_impl(function() {
					gameframe_set_fullscreen_1(0)
				}, 1, undefined, undefined, undefined, undefined);
				exit;
			}
			if (window_get_fullscreen()) {
				gameframe_restore();
			} else if (gameframe_isMaximized_hx) {
				gameframe_isFullscreen_hx = false;
				gameframe_maximize_1();
			} else gameframe_restore();
	}
}

function gameframe_set_window_cursor(_cr1) {
	// gameframe_set_window_cursor(cr:window_cursor)
	gameframe_current_cursor = _cr1;
	if (gameframe_set_cursor) {
		if (window_get_cursor() != _cr1) window_set_cursor(_cr1);
	}
}

function gameframe_get_border_width() {
	// gameframe_get_border_width()->int
	if (gameframe_isMaximized_hx) return 0; else return gameframe_border_width;
}

function gameframe_get_drag_flags() {
	/// gameframe_get_drag_flags()->int
	/// @returns {int}
	return gameframe_drag_flags;
}

#endregion

#region gameframe_caption

function gameframe_caption_get_height() {
	/// gameframe_caption_get_height()->int
	/// @returns {int}
	var _h = (gameframe_isMaximized_hx ? gameframe_caption_height_maximized : gameframe_caption_height_normal);
	if (_h > 0) return (_h | 0);
	return round(-_h * sprite_get_height(gameframe_spr_caption) * gameframe_effective_scale);
}

function gameframe_caption_get_overlap() {
	/// gameframe_caption_get_overlap()->number
	/// @returns {number}
	if (window_get_fullscreen() || gameframe_isFullscreen_hx) return 0.;
	var _h = gameframe_caption_get_height();
	var _rect = application_get_position();
	return max(0, _h - _rect[1]) / ((_rect[2] - _rect[0]) / surface_get_width(application_surface));
}

function gameframe_caption_draw_border_default(__x, __y, __width, __height) {
	// gameframe_caption_draw_border_default(_x:int, _y:int, _width:int, _height:int)
	draw_sprite_stretched_ext(gameframe_spr_border, (window_has_focus() ? 1 : 0), __x, __y, __width, __height, gameframe_blend, gameframe_alpha);
}

function gameframe_caption_draw_caption_rect_default(__x, __y, __width, __height, __buttons_x) {
	// gameframe_caption_draw_caption_rect_default(_x:int, _y:int, _width:int, _height:int, _buttons_x:int)
	draw_sprite_stretched_ext(gameframe_spr_caption, (window_has_focus() ? 1 : 0), __x, __y, __width, __height, gameframe_blend, gameframe_alpha * gameframe_caption_alpha);
}

function gameframe_caption_draw_caption_text_default(__x, __y, __width, __height) {
	// gameframe_caption_draw_caption_text_default(_x:number, _y:number, _width:number, _height:int)
	var _dpiScale = gameframe_effective_scale;
	var __right = __x + __width;
	__x += gameframe_caption_margin * _dpiScale;
	var _icon = gameframe_caption_icon;
	if (_icon != -1) {
		draw_sprite_ext(_icon, -1, (__x + sprite_get_xoffset(_icon) * _dpiScale | 0), __y + ((__height - sprite_get_height(_icon) * _dpiScale) div 2) + sprite_get_yoffset(_icon) * _dpiScale, _dpiScale, _dpiScale, 0, 16777215, gameframe_caption_alpha * gameframe_alpha);
		__x += (sprite_get_width(_icon) + gameframe_caption_icon_margin) * _dpiScale;
	}
	var _text = gameframe_caption_text;
	if (_text == "") exit;
	var __newFont = gameframe_caption_font;
	var __h = draw_get_halign();
	var __v = draw_get_valign();
	var __oldFont;
	if (__newFont != -1) {
		__oldFont = draw_get_font();
		draw_set_font(__newFont);
	} else __oldFont = -1;
	draw_set_halign(gameframe_caption_text_align);
	draw_set_valign(0);
	var __alpha = draw_get_alpha();
	var __textWidth = __right - __x;
	draw_set_alpha((gameframe_alpha * gameframe_caption_alpha));
	draw_text_ext_transformed((__x + ((gameframe_caption_text_align * __textWidth) div 2)), __y + ((__height - string_height_ext(_text, -1, __textWidth) * _dpiScale) div 2), _text, -1, __textWidth, _dpiScale, _dpiScale, 0);
	draw_set_alpha(__alpha);
	if (__newFont != -1) draw_set_font(__oldFont);
	draw_set_halign(__h);
	draw_set_valign(__v);
}

#endregion

#region gameframe_cover

function gameframe_cover_ensure() {
	// gameframe_cover_ensure()
	var __just_changed = gameframe_cover_check_for_success;
	if (__just_changed) gameframe_cover_check_for_success = false;
	var __target_rect;
	if (window_get_fullscreen()) {
		gameframe_cover_can_ignore = false;
		exit;
	} else if (gameframe_isFullscreen_hx) {
		__target_rect = gameframe_tools_mon_get_active()[0/* screen */];
	} else if (gameframe_isMaximized_hx) {
		__target_rect = gameframe_tools_mon_get_active()[1/* workspace */];
	} else {
		gameframe_cover_can_ignore = false;
		exit;
	}
	gameframe_tools_rect_get_window_rect(gameframe_cover_curr_rect);
	if (!gameframe_tools_rect_equals(gameframe_cover_curr_rect, __target_rect)) {
		if (__just_changed) {
			gameframe_cover_can_ignore = true;
			gameframe_tools_rect_set_to(gameframe_cover_ignore_rect, __target_rect);
			if (gameframe_debug) gameframe_log("[cover] Resize failed - ignoring");
			exit;
		}
		if (gameframe_cover_can_ignore && gameframe_tools_rect_equals(__target_rect, gameframe_cover_ignore_rect)) exit;
		if (gameframe_debug) gameframe_log("[cover] Adjusting window rectangle to", __target_rect);
		gameframe_tools_rect_set_window_rect(__target_rect);
		gameframe_cover_check_for_success = true;
	}
}

#endregion

#region gameframe_delayed

function gameframe_delayed_call_impl(_func, _delay, _arg0, _arg1, _arg2, _arg3) {
	// gameframe_delayed_call_impl(func:any, delay:int, arg:any, arg:any, arg:any, arg:any)
	var _item;
	if (ds_stack_empty(gameframe_delayed_pool)) _item = gameframe_delayed_item_create(); else _item = ds_stack_pop(gameframe_delayed_pool);
	_item[@1/* func */] = _func;
	_item[@2/* time */] = gameframe_delayed_frame_index + _delay;
	_item[@3/* arg0 */] = _arg0;
	_item[@4/* arg1 */] = _arg1;
	_item[@5/* arg2 */] = _arg2;
	_item[@6/* arg3 */] = _arg3;
	ds_queue_enqueue(gameframe_delayed_queue, _item);
}

function gameframe_delayed_update() {
	// gameframe_delayed_update()
	gameframe_delayed_frame_index += 1;
	var _f;
	while (!ds_queue_empty(gameframe_delayed_queue)) {
		var _head = ds_queue_head(gameframe_delayed_queue);
		if (_head[2/* time */] > gameframe_delayed_frame_index) break;
		ds_queue_dequeue(gameframe_delayed_queue);
		_f = _head[1/* func */];
		_f(_head[3/* arg0 */], _head[4/* arg1 */], _head[5/* arg2 */], _head[6/* arg3 */]);
		_head[@1/* func */] = undefined;
		_head[@3/* arg0 */] = undefined;
		_head[@4/* arg1 */] = undefined;
		_head[@5/* arg2 */] = undefined;
		_head[@6/* arg3 */] = undefined;
		ds_stack_push(gameframe_delayed_pool, _head);
	}
}

#endregion

#region gameframe_delayed_item

function gameframe_delayed_item_create() {
	// gameframe_delayed_item_create()
	var _this = [mt_gameframe_delayed_item];
	array_copy(_this, 1, mq_gameframe_delayed_item, 1, 6);
	/// @typedef {tuple<any,func:any,time:int,arg0:any,arg1:any,arg2:any,arg3:any>} gameframe_delayed_item
	
	return _this;
}

#endregion

#region gameframe_drag

function gameframe_drag_start(__flags) {
	// gameframe_drag_start(_flags:int)
	gameframe_drag_init = 0;
	gameframe_drag_flags = __flags;
	gameframe_drag_mx = (display_mouse_get_x() | 0);
	gameframe_drag_my = (display_mouse_get_y() | 0);
	gameframe_drag_left = window_get_x();
	gameframe_drag_top = window_get_y();
	gameframe_drag_right = gameframe_drag_left + window_get_width();
	gameframe_drag_bottom = gameframe_drag_top + window_get_height();
}

function gameframe_drag_stop() {
	// gameframe_drag_stop()
	
	if(gameframe_drag_flags == 16) {
		if(display_mouse_get_y() <= gameframe_resize_padding)
			gameframe_maximize();
	}
	
	gameframe_drag_flags = 0;
}

function gameframe_drag_set_rect(_x, _y, _w, _h) {
	// gameframe_drag_set_rect(x:int, y:int, w:int, h:int)
	window_set_rectangle(_x, _y, _w, _h);
}

function gameframe_drag_update() {
	// gameframe_drag_update()
	if (gameframe_drag_flags == 0) exit;
	var __mx = (display_mouse_get_x() | 0);
	var __my = (display_mouse_get_y() | 0);
	switch (gameframe_drag_flags) {
		case 16: 
			if(gameframe_drag_init == 0) {
				var dist = point_distance(gameframe_drag_mx, gameframe_drag_my, __mx, __my);
				if(dist > 8) {
					gameframe_drag_init = 1;
					//gameframe_drag_mx = __mx;
					//gameframe_drag_my = __my;
				}
			} else 
				window_set_position(__mx - (gameframe_drag_mx - gameframe_drag_left), __my - (gameframe_drag_my - gameframe_drag_top)); 
			break;
		case 32:
			if (point_distance(__mx, __my, gameframe_drag_mx, gameframe_drag_my) > 5) {
				var __x;
				var __y = gameframe_drag_my - gameframe_drag_top;
				if (gameframe_drag_mx - gameframe_drag_left < (gameframe_drag_right - gameframe_drag_left) / 2) __x = min(gameframe_drag_mx - gameframe_drag_left, (gameframe_restoreRect_hx[2/* width */] >> 1)); else __x = max(gameframe_restoreRect_hx[2/* width */] + gameframe_drag_mx - gameframe_drag_right, (gameframe_restoreRect_hx[2/* width */] >> 1));
				gameframe_isMaximized_hx = false;
				window_set_rectangle(__mx - __x, __my - __y, gameframe_restoreRect_hx[2/* width */], gameframe_restoreRect_hx[3/* height */]);
				gameframe_drag_start(16);
			}
			break;
		case 1:
			var __x = __mx - (gameframe_drag_mx - gameframe_drag_left);
			window_set_rectangle(__x, gameframe_drag_top, gameframe_drag_right - __x, gameframe_drag_bottom - gameframe_drag_top);
			break;
		case 2:
			var __y = __my - (gameframe_drag_my - gameframe_drag_top);
			window_set_rectangle(gameframe_drag_left, __y, gameframe_drag_right - gameframe_drag_left, gameframe_drag_bottom - __y);
			break;
		case 4: window_set_rectangle(gameframe_drag_left, gameframe_drag_top, gameframe_drag_right - gameframe_drag_left - gameframe_drag_mx + __mx, gameframe_drag_bottom - gameframe_drag_top); break;
		case 8: window_set_rectangle(gameframe_drag_left, gameframe_drag_top, gameframe_drag_right - gameframe_drag_left, gameframe_drag_bottom - gameframe_drag_top - gameframe_drag_my + __my); break;
		case 3:
			var __x = __mx - (gameframe_drag_mx - gameframe_drag_left);
			var __y = __my - (gameframe_drag_my - gameframe_drag_top);
			window_set_rectangle(__x, __y, gameframe_drag_right - __x, gameframe_drag_bottom - __y);
			break;
		case 9:
			var __x = __mx - (gameframe_drag_mx - gameframe_drag_left);
			window_set_rectangle(__x, gameframe_drag_top, gameframe_drag_right - __x, gameframe_drag_bottom - gameframe_drag_top - gameframe_drag_my + __my);
			break;
		case 6:
			var __y = __my - (gameframe_drag_my - gameframe_drag_top);
			window_set_rectangle(gameframe_drag_left, __y, gameframe_drag_right - gameframe_drag_left - gameframe_drag_mx + __mx, gameframe_drag_bottom - __y);
			break;
		case 12: window_set_rectangle(gameframe_drag_left, gameframe_drag_top, gameframe_drag_right - gameframe_drag_left - gameframe_drag_mx + __mx, gameframe_drag_bottom - gameframe_drag_top - gameframe_drag_my + __my); break;
	}
}

#endregion

#region gameframe.tools.keyctl

function gameframe_tools_keyctl_create_key(_keyCode) {
	// gameframe_tools_keyctl_create_key(keyCode:gml_input_KeyCode)->GfKeyboardKey
	return [/* keyCode: */_keyCode, /* down: */false, /* pressed: */false];
}

function gameframe_tools_keyctl_update_key(_key) {
	// gameframe_tools_keyctl_update_key(key:GfKeyboardKey)
	var _down0 = _key[1/* down */];
	var _down1 = keyboard_check_direct(_key[0/* keyCode */]) != 0;
	_key[@2/* pressed */] = !_down0 && _down1;
	_key[@1/* down */] = _down1;
}

function gameframe_tools_keyctl_reset() {
	// gameframe_tools_keyctl_reset()
	var _i = 0;
	for (var __g1 = array_length(gameframe_tools_keyctl_keys); _i < __g1; _i++) {
		//gameframe_tools_keyctl_keys[_i][@1/* down */] = false;
	}
}

function gameframe_tools_keyctl_update() {
	// gameframe_tools_keyctl_update()
	if (!(window_has_focus() && (keyboard_check_direct(91) != 0 || keyboard_check_direct(92) != 0))) {
		gameframe_tools_keyctl_reset();
		exit;
	}
	var _i = 0;
	for (var __g1 = array_length(gameframe_tools_keyctl_keys); _i < __g1; _i++) {
		gameframe_tools_keyctl_update_key(gameframe_tools_keyctl_keys[_i]);
	}
	
	if (gameframe_tools_keyctl_up[2/* pressed */]) {
		if (gameframe_can_resize) gameframe_maximize();
	} else if (gameframe_tools_keyctl_down[2/* pressed */]) {
		if (gameframe_isMaximized_hx) {
			if (gameframe_can_resize) gameframe_restore();
		} else gameframe_minimize();
	}
}

#endregion

#region gameframe_draw

function gameframe_draw() {
	/// gameframe_draw()
	/// @returns {void}
	if (!gameframe_is_ready) exit;
	if (window_get_fullscreen() || gameframe_isFullscreen_hx) exit;
	var _gw = window_get_width();
	var _gh = window_get_height();
	__display_set_gui_maximise_base(browser_width / _gw, browser_height / _gh, _gw % 2 / -2, _gh % 2 / -2);
	var __borderWidth = (gameframe_isMaximized_hx ? 0 : gameframe_border_width);
	var __titlebarHeight = gameframe_caption_get_height();
	var __buttons_x = gameframe_button_get_combined_offset(_gw);
	if (!gameframe_isMaximized_hx) gameframe_caption_draw_border(0, 0, _gw, _gh);
	gameframe_caption_draw_background(__borderWidth, __borderWidth, _gw - __borderWidth * 2, __titlebarHeight, __buttons_x);
	gameframe_caption_draw_text(__borderWidth, __borderWidth, __buttons_x - __borderWidth, __titlebarHeight);
	gameframe_button_draw(__buttons_x, __borderWidth, __titlebarHeight);
	__display_gui_restore();
}

#endregion

#region gameframe_std.Std

function gameframe_std_Std_stringify(_value) {
	// gameframe_std_Std_stringify(value:any)->string
	if (_value == undefined) return "null";
	if (is_string(_value)) return _value;
	var _n, _i, _s;
	if (is_struct(_value)) {
		var _e = _value[$"__enum__"];
		if (_e == undefined) return string(_value);
		var _ects = _e._constructor;
		if (_ects != undefined) {
			_i = _value.__enumIndex__;
			if (_i >= 0 && _i < array_length(_ects)) _s = _ects[_i]; else _s = "?";
		} else {
			_s = instanceof(_value);
			if (string_copy(_s, 1, 3) == "mc_") _s = string_delete(_s, 1, 3);
			_n = string_length(_e.name);
			if (string_copy(_s, 1, _n) == _e.name) _s = string_delete(_s, 1, _n + 1);
		}
		_s += "(";
		var _fields = _value.__enumParams__;
		_n = array_length(_fields);
		for (_i = -1; ++_i < _n; _s += gameframe_std_Std_stringify(_value[$ _fields[_i]])) {
			if (_i > 0) _s += ", ";
		}
		return _s + ")";
	}
	if (is_real(_value)) {
		_s = string_format(_value, 0, 16);
		if (os_browser != browser_not_a_browser) {
			_n = string_length(_s);
			_i = _n;
			while (_i > 0) {
				switch (string_ord_at(_s, _i)) {
					case 48:
						_i--;
						continue;
					case 46: _i--; break;
				}
				break;
			}
		} else {
			_n = string_byte_length(_s);
			_i = _n;
			while (_i > 0) {
				switch (string_byte_at(_s, _i)) {
					case 48:
						_i--;
						continue;
					case 46: _i--; break;
				}
				break;
			}
		}
		return string_copy(_s, 1, _i);
	}
	return string(_value);
}

#endregion

#region gameframe_std.haxe.class

function gameframe_std_haxe_class(_id, _name) constructor {
	// gameframe_std_haxe_class(id:int, name:string)
	static superClass = undefined; /// @is {haxe_class<any>}
	static marker = undefined; /// @is {any}
	static index = undefined; /// @is {int}
	static name = undefined; /// @is {string}
	self.superClass = undefined;
	self.marker = gameframe_std_haxe_type_markerValue;
	self.index = _id;
	self.name = _name;
	static __class__ = "class";
}

#endregion

#region gameframe_tools_mon

function gameframe_tools_mon_get_active() {
	// gameframe_tools_mon_get_active()->tools_GfMonInfo
	var __list = gameframe_tools_mon_get_active_list;
	if (__list == undefined) {
		__list = ds_list_create();
		gameframe_tools_mon_get_active_list = __list;
	}
	var __count = gameframe_get_monitors(__list);
	var __cx1   = window_get_x() + (window_get_width() div 2);
	var __cy1   = window_get_y() + (window_get_height() div 2);
	var _i = 0;
	for (var __g1 = __count; _i < __g1; _i++) {
		var __item = __list[|_i];
		var __mntr = __item[0/* screen */];
		if (__cx1 >= __mntr[0/* x */] && __cy1 >= __mntr[1/* y */] && __cx1 < __mntr[0/* x */] + __mntr[2/* width */] && __cy1 < __mntr[1/* y */] + __mntr[3/* height */]) return __item;
	}
	var __item = __list[|0];
	if (__item == undefined) {
		__item = gameframe_tools_mon_dummy;
		if (__item == undefined) {
			__item = [/* screen: */gameframe_tools_rect__new(0, 0, display_get_width(), display_get_height()), /* workspace: */gameframe_tools_rect__new(0, 0, display_get_width(), display_get_height() - 40), /* flags: */0];
			gameframe_tools_mon_dummy = __item;
		}
		__list[|0] = __item;
	}
	return __item;
}

#endregion

// gameframe:
globalvar gameframe_is_ready; /// @is {bool}
gameframe_is_ready = false;
globalvar gameframe_double_click_time; /// @is {number}
globalvar gameframe_last_title_click_at; /// @is {int}
gameframe_last_title_click_at = -5000;
// gameframe_button:
globalvar gameframe_button_array; /// @is {array<game_frame_button>}
gameframe_button_array = [];
globalvar gameframe_button_fade_time; /// @is {number}
gameframe_button_fade_time = 0.2;
globalvar gameframe_button_wait_for_movement; /// @is {bool}
gameframe_button_wait_for_movement = false;
globalvar gameframe_button_wait_for_movement_x; /// @is {number}
gameframe_button_wait_for_movement_x = 0.;
globalvar gameframe_button_wait_for_movement_y; /// @is {number}
gameframe_button_wait_for_movement_y = 0.;
// gameframe:
globalvar gameframe_debug; /// @is {bool}
gameframe_debug = false;
globalvar gameframe_blend; /// @is {int}
gameframe_blend = 16777215;
globalvar gameframe_alpha; /// @is {number}
gameframe_alpha = 1.0;
globalvar gameframe_can_input; /// @is {bool}
gameframe_can_input = true;
globalvar gameframe_can_resize; /// @is {bool}
gameframe_can_resize = true;
globalvar gameframe_resize_padding; /// @is {int}
gameframe_resize_padding = 6;
globalvar gameframe_border_width; /// @is {int}
gameframe_border_width = 2;
globalvar gameframe_spr_border; /// @is {sprite}
gameframe_spr_border = asset_get_index("spr_gameframe_border");
globalvar gameframe_spr_caption; /// @is {sprite}
gameframe_spr_caption = asset_get_index("spr_gameframe_caption");
globalvar gameframe_spr_buttons; /// @is {sprite}
gameframe_spr_buttons = asset_get_index("spr_gameframe_buttons");
globalvar gameframe_spr_pixel; /// @is {sprite}
gameframe_spr_pixel = asset_get_index("spr_gameframe_pixel");
globalvar gameframe_default_cursor; /// @is {window_cursor}
gameframe_default_cursor = cr_arrow;
globalvar gameframe_set_cursor; /// @is {bool}
gameframe_set_cursor = true;
globalvar gameframe_current_cursor; /// @is {window_cursor}
gameframe_current_cursor = cr_arrow;
globalvar gameframe_dpi_scale; /// @is {number}
gameframe_dpi_scale = 1.;
// gameframe:
globalvar gameframe_effective_scale; /// @is {number}
gameframe_effective_scale = 1.;
globalvar gameframe_has_native_extension; /// @is {bool}
gameframe_has_native_extension = false;
globalvar gameframe_mouse_over_frame; /// @is {bool}
gameframe_mouse_over_frame = false;
globalvar gameframe_isMaximized_hx; /// @is {bool}
gameframe_isMaximized_hx = false;
globalvar gameframe_isFullscreen_hx; /// @is {bool}
gameframe_isFullscreen_hx = false;
globalvar gameframe_restoreRect_hx; /// @is {gameframe_tools_rect}
gameframe_restoreRect_hx = gameframe_tools_rect__new();
// gameframe_caption:
globalvar gameframe_caption_text; /// @is {string}
gameframe_caption_text = window_get_caption();
globalvar gameframe_caption_alpha; /// @is {number}
gameframe_caption_alpha = 1;
globalvar gameframe_caption_font; /// @is {font}
gameframe_caption_font = -1;
globalvar gameframe_caption_text_align; /// @is {gml_gpu_TextAlign}
gameframe_caption_text_align = 0;
globalvar gameframe_caption_icon; /// @is {sprite}
gameframe_caption_icon = -1;
globalvar gameframe_caption_margin; /// @is {int}
gameframe_caption_margin = 6;
globalvar gameframe_caption_icon_margin; /// @is {int}
gameframe_caption_icon_margin = 4;
globalvar gameframe_caption_height_normal; /// @is {number}
gameframe_caption_height_normal = -1;
globalvar gameframe_caption_height_maximized; /// @is {number}
gameframe_caption_height_maximized = -0.66667;
globalvar gameframe_caption_draw_border; /// @is {function<x:int; y:int; width:int; height:int; void>}
gameframe_caption_draw_border = gameframe_caption_draw_border_default;
globalvar gameframe_caption_draw_background; /// @is {function<x:int; y:int; width:int; height:int; buttonsX:int; void>}
gameframe_caption_draw_background = gameframe_caption_draw_caption_rect_default;
globalvar gameframe_caption_draw_text; /// @is {function<x:number; y:number; width:int; height:int; void>}
gameframe_caption_draw_text = gameframe_caption_draw_caption_text_default;
// gameframe_cover:
globalvar gameframe_cover_check_for_success; /// @is {bool}
gameframe_cover_check_for_success = false;
globalvar gameframe_cover_ignore_rect; /// @is {gameframe_tools_rect}
gameframe_cover_ignore_rect = gameframe_tools_rect__new();
globalvar gameframe_cover_can_ignore; /// @is {bool}
gameframe_cover_can_ignore = false;
globalvar gameframe_cover_curr_rect; /// @is {gameframe_tools_rect}
gameframe_cover_curr_rect = gameframe_tools_rect__new();
// gameframe_delayed:
globalvar gameframe_delayed_queue; /// @is {ds_queue<gameframe_delayed_item>}
gameframe_delayed_queue = ds_queue_create();
globalvar gameframe_delayed_pool; /// @is {ds_stack<gameframe_delayed_item>}
gameframe_delayed_pool = ds_stack_create();
globalvar gameframe_delayed_frame_index; /// @is {int}
gameframe_delayed_frame_index = 0;
// gameframe_drag:
globalvar gameframe_drag_flags; /// @is {int}
gameframe_drag_flags = 0;
globalvar gameframe_drag_init; /// @is {int}
gameframe_drag_init = 0;
globalvar gameframe_drag_mx; /// @is {int}
gameframe_drag_mx = 0;
globalvar gameframe_drag_my; /// @is {int}
gameframe_drag_my = 0;
globalvar gameframe_drag_left; /// @is {int}
gameframe_drag_left = 0;
globalvar gameframe_drag_top; /// @is {int}
gameframe_drag_top = 0;
globalvar gameframe_drag_right; /// @is {int}
gameframe_drag_right = 0;
globalvar gameframe_drag_bottom; /// @is {int}
gameframe_drag_bottom = 0;
// gameframe.tools.keyctl:
globalvar gameframe_tools_keyctl_up; /// @is {GfKeyboardKey}
gameframe_tools_keyctl_up = gameframe_tools_keyctl_create_key(38);
globalvar gameframe_tools_keyctl_down; /// @is {GfKeyboardKey}
gameframe_tools_keyctl_down = gameframe_tools_keyctl_create_key(40);
globalvar gameframe_tools_keyctl_keys; /// @is {array<GfKeyboardKey>}
gameframe_tools_keyctl_keys = [gameframe_tools_keyctl_up, gameframe_tools_keyctl_down];
// gameframe_tools_mon:
globalvar gameframe_tools_mon_get_active_list; /// @is {ds_list<tools_GfMonInfo>}
gameframe_tools_mon_get_active_list = undefined;
globalvar gameframe_tools_mon_dummy; /// @is {tools_GfMonInfo}
gameframe_tools_mon_dummy = undefined;


/// @typedef {any} tools_GfRectImpl
/// @typedef {any} gameframe_tools_rect
/// @typedef {any} tools_GfMonInfo
/// @typedef {any} GfKeyboardKey