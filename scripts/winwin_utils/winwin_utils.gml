global.__winwin_map = ds_map_create();
global.winwin_all   = [];

function winwin_config() constructor {
    static caption         = "Window";
    static kind            = winwin_kind_normal;
    static resize          = false;
    static show            = true;
    static topmost         = false;
    static taskbar_button  = true; // can only disable for borderless!
    static clickthrough    = false;
    static noactivate      = false;
    static per_pixel_alpha = false;
    static thread          = false;
    static vsync           = 0;
    static close_button    = 1;
    static owner           = undefined;
}

#macro __ww_valid (OS == os_windows && ww != noone && winwin_exists(ww))

function winwin_create_ext(_x, _y, _w, _h, _conf) {
    var window = winwin_create(_x, _y, _w, _h, _conf);
	array_push(global.winwin_all, window);
	
	return window;
}

function winwin_destroy_ext(ww) {
    if(__ww_valid) winwin_destroy(_ww);
	array_remove(global.winwin_all, window);
}

function winwin_set_position_safe(ww, _x, _y)               { if(__ww_valid) winwin_set_position(ww, _x, _y);                                                   }
function winwin_set_size_safe(ww, _w, _h)                   { if(__ww_valid) winwin_set_size(ww, _w, _h);                                                       }

function winwin_get_x_safe(ww)                              { return __ww_valid? winwin_get_x(ww)                           : window_get_x();                   }
function winwin_get_y_safe(ww)                              { return __ww_valid? winwin_get_y(ww)                           : window_get_y();                   }

function winwin_get_width_safe(ww)                          { return __ww_valid? winwin_get_width(ww)                       : window_get_width();               }
function winwin_get_height_safe(ww)                         { return __ww_valid? winwin_get_height(ww)                      : window_get_height();              }

function winwin_mouse_get_x_safe(ww)                        { return __ww_valid? winwin_mouse_get_x(ww)                     : device_mouse_x_to_gui(0);         }
function winwin_mouse_get_y_safe(ww)                        { return __ww_valid? winwin_mouse_get_y(ww)                     : device_mouse_y_to_gui(0);         }

function winwin_mouse_is_over_safe(ww)                      { return __ww_valid? winwin_mouse_is_over(ww)                   : false;                            }
function winwin_mouse_check_button_safe(ww, bb)             { return __ww_valid? winwin_mouse_check_button(ww, bb)          : mouse_check_button(bb);           }
function winwin_mouse_check_button_pressed_safe(ww, bb)     { return __ww_valid? winwin_mouse_check_button_pressed(ww, bb)  : mouse_check_button_pressed(bb);   }
function winwin_mouse_check_button_released_safe(ww, bb)    { return __ww_valid? winwin_mouse_check_button_released(ww, bb) : mouse_check_button_released(bb);  }

function winwin_keyboard_check_safe(ww, key)                { return __ww_valid? winwin_keyboard_check(ww, key)             : keyboard_check(key);              }
function winwin_keyboard_check_pressed_safe(ww, key)        { return __ww_valid? winwin_keyboard_check_pressed(ww, key)     : keyboard_check_pressed(key);      }
function winwin_keyboard_check_released_safe(ww, key)       { return __ww_valid? winwin_keyboard_check_released(ww, key)    : keyboard_check_released(key);     }