function winwin(_ptr) constructor {
    __ptr__ = _ptr;
}
function winwin_config() constructor {
    static caption         = "Window";                static setCaption = function(v) /*=>*/ { caption = v; return self; }
    static kind            = winwin_kind_borderless;  static setKind    = function(v) /*=>*/ { kind    = v; return self; }
    static resize          = true;                    static setResize  = function(v) /*=>*/ { resize  = v; return self; }
    static show            = true;                    static setShow    = function(v) /*=>*/ { show    = v; return self; }
    static topmost         = false;                   static setTopmost = function(v) /*=>*/ { topmost = v; return self; }
    // can only disable for borderless!
    static taskbar_button  = false;
    static clickthrough    = false;
    static noactivate      = false;
    static per_pixel_alpha = true;
    static thread          = false;
    static vsync           = 1;
    static close_button    = 0;
    static owner           = WINWIN_CURRENT == undefined? winwin_main : WINWIN_CURRENT;
}

// https://github.com/YoYoGames/GameMaker-Bugs/issues/10141
function winwin_buffer_write_string_u32(_buf, _string) {
    if(_string == "") return;
    with ({ _buf: _buf }) string_foreach(_string, function(_char, _pos) /*=>*/ {
        buffer_write(_buf, buffer_u32, ord(_char));
    });
}

function is_winwin(_window) { return _window && winwin_exists(_window); }