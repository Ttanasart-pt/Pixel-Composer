function panel_toolbar_icon(_name, _sprite, _index, _tooltip, _onCilck, _onRClick = 0, _onWUp = 0, _onWDown = 0) constructor {
    name     = _name;
    sprite   = _sprite;
    index    = _index;
    tooltip  = _tooltip;
    onCilck  = _onCilck;
    onRClick = _onRClick;
    onWUp    = _onWUp;
    onWDown  = _onWDown;
    
    hotkey   = noone;
    
    static setHotkey  = function(c,n) /*=>*/ { hotkey = find_hotkey(c,n); return self; }
    static setWheelFn = function(u,d) /*=>*/ { onWUp = u; onWDown = d;    return self; }
}