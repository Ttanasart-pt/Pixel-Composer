global.__winwin_map = ds_map_create();

function winwin(_ptr) constructor {
    __ptr__ = _ptr;
}

function winwin_config() constructor {
    static caption = "Window";
    static kind = winwin_kind_normal;
    static resize = false;
    static show = true;
    static topmost = false;
    static taskbar_button = true; // can only disable for borderless!
    static clickthrough = false;
    static noactivate = false;
    static per_pixel_alpha = false;
    static thread = false;
    static vsync = 0;
    static close_button = 1;
    static owner = undefined;
}

#macro __ww_valid (ww != noone && winwin_exists(ww))

function winwin_get_x_safe(ww) { return __ww_valid? winwin_get_x(ww) : window_get_x(); }
function winwin_get_y_safe(ww) { return __ww_valid? winwin_get_y(ww) : window_get_y(); }

function winwin_get_width_safe(ww)  { return __ww_valid? winwin_get_width(ww)  : window_get_width();  }
function winwin_get_height_safe(ww) { return __ww_valid? winwin_get_height(ww) : window_get_height(); }

function winwin_set_position_safe(ww, _x, _y) { if(__ww_valid) winwin_set_position(ww, _x, _y); }
function winwin_set_size_safe(ww, _w, _h)     { if(__ww_valid) winwin_set_size(ww, _w, _h); }

function winwin_mouse_get_x_safe(ww) { return __ww_valid? winwin_mouse_get_x(ww) : device_mouse_x_to_gui(0); }
function winwin_mouse_get_y_safe(ww) { return __ww_valid? winwin_mouse_get_y(ww) : device_mouse_y_to_gui(0); }

function winwin_mouse_is_over_safe(ww)                      { return __ww_valid? winwin_mouse_is_over(ww)                   : false;                           }
function winwin_mouse_check_button_safe(ww, bb)             { return __ww_valid? winwin_mouse_check_button(ww, bb)          : mouse_check_button(bb);          }
function winwin_mouse_check_button_pressed_safe(ww, bb)     { return __ww_valid? winwin_mouse_check_button_pressed(ww, bb)  : mouse_check_button_pressed(bb);  }
function winwin_mouse_check_button_released_safe(ww, bb)    { return __ww_valid? winwin_mouse_check_button_released(ww, bb) : mouse_check_button_released(bb); }