function KeyboardDisplayLayout_Key(_key, _vk, _x, _y, _w = 1, _h = 1) constructor {
    key = _key;
    vk  = _vk;
    x   = _x;
    y   = _y;
    w   = _w;
    h   = _h;
}

function KeyboardDisplay() constructor {
    __key = function(_key, _vk, _x, _y, _w = 1, _h = 1) /*=>*/ { return new KeyboardDisplayLayout_Key(_key, _vk, _x, _y, _w, _h); }
    
    keys = [
        __key(   "Esc",           -1,   0,   0),
        __key(    "F1",        vk_f1,   2,   0),
        __key(    "F2",        vk_f2,   3,   0),
        __key(    "F3",        vk_f3,   4,   0),
        __key(    "F4",        vk_f4,   5,   0),
        __key(    "F5",        vk_f5,   6.5, 0),
        __key(    "F6",        vk_f6,   7.5, 0),
        __key(    "F7",        vk_f7,   8.5, 0),
        __key(    "F8",        vk_f8,   9.5, 0),
        __key(    "F9",        vk_f9,  11,   0),
        __key(   "F10",       vk_f10,  12,   0),
        __key(   "F11",       vk_f11,  13,   0),
        __key(   "F12",       vk_f12,  14,   0), //15
            
        __key(     "`",          192,   0,   1.1),
        __key(     "1",     ord("1"),   1,   1.1),
        __key(     "2",     ord("2"),   2,   1.1),
        __key(     "3",     ord("3"),   3,   1.1),
        __key(     "4",     ord("4"),   4,   1.1),
        __key(     "5",     ord("5"),   5,   1.1),
        __key(     "6",     ord("6"),   6,   1.1),
        __key(     "7",     ord("7"),   7,   1.1),
        __key(     "8",     ord("8"),   8,   1.1),
        __key(     "9",     ord("9"),   9,   1.1),
        __key(     "0",     ord("0"),  10,   1.1),
        __key(     "-",          189,  11,   1.1),
        __key(     "=",          187,  12,   1.1),
        __key(   "bsp", vk_backspace,  13,   1.1, 2), //15
         
        __key(   "Tab",       vk_tab,   0,   2.1, 1.5),
        __key(     "Q",     ord("Q"),   1.5, 2.1),
        __key(     "W",     ord("W"),   2.5, 2.1),
        __key(     "E",     ord("E"),   3.5, 2.1),
        __key(     "R",     ord("R"),   4.5, 2.1),
        __key(     "T",     ord("T"),   5.5, 2.1),
        __key(     "Y",     ord("Y"),   6.5, 2.1),
        __key(     "U",     ord("U"),   7.5, 2.1),
        __key(     "I",     ord("I"),   8.5, 2.1),
        __key(     "O",     ord("O"),   9.5, 2.1),
        __key(     "P",     ord("P"),  10.5, 2.1),
        __key(     "[",          219,  11.5, 2.1),
        __key(     "]",          221,  12.5, 2.1),
        __key(    "\\",          220,  13.5, 2.1, 1.5),
         
        __key(  "Caps",           -1,   0,   3.1, 2),
        __key(     "A",     ord("A"),   2,   3.1),
        __key(     "S",     ord("S"),   3,   3.1),
        __key(     "D",     ord("D"),   4,   3.1),
        __key(     "F",     ord("F"),   5,   3.1),
        __key(     "G",     ord("G"),   6,   3.1),
        __key(     "H",     ord("H"),   7,   3.1),
        __key(     "J",     ord("J"),   8,   3.1),
        __key(     "K",     ord("K"),   9,   3.1),
        __key(     "L",     ord("L"),  10,   3.1),
        __key(     ";",          186,  11,   3.1),
        __key(     "'",          222,  12,   3.1),
        __key( "Enter",           -1,  13,   3.1, 2),
         
        __key( "Shift",     vk_shift,   0,   4.1, 2.5),
        __key(     "Z",     ord("Z"),   2.5, 4.1),
        __key(     "X",     ord("X"),   3.5, 4.1),
        __key(     "C",     ord("C"),   4.5, 4.1),
        __key(     "V",     ord("V"),   5.5, 4.1),
        __key(     "B",     ord("B"),   6.5, 4.1),
        __key(     "N",     ord("N"),   7.5, 4.1),
        __key(     "M",     ord("M"),   8.5, 4.1),
        __key(     ",",          188,   9.5, 4.1),
        __key(     ".",          190,  10.5, 4.1),
        __key(     "/",          191,  11.5, 4.1),
        __key( "Shift",     vk_shift,  12.5, 4.1, 2.5),
         
        __key(  "Ctrl",   vk_control,     0,   5.1),
        __key(   "Win",           -1,     1,   5.1),
        __key(   "Alt",       vk_alt,     2,   5.1),
        __key(      "",     vk_space,     3,   5.1, 8),
        __key(   "Alt",       vk_alt,    11,   5.1),
        __key(   "Win",           -1,    12,   5.1),
        __key(    "Fn",           -1,    13,   5.1),
        __key(  "Ctrl",   vk_control,    14,   5.1),
        
        //////////////////////////////////////////////////////
        
        __key(    "Ins",   vk_insert,    15.1, 1.1),
        __key(   "Home",     vk_home,    16.1, 1.1),
        __key(   "PgUp",   vk_pageup,    17.1, 1.1),
        
        __key(    "Del",   vk_delete,    15.1, 2.1),
        __key(    "End",      vk_end,    16.1, 2.1),
        __key(   "PgDn", vk_pagedown,    17.1, 2.1),
         
        __key(     "Up",       vk_up,    16.1, 4.1),
        __key(   "Left",     vk_left,    15.1, 5.1),
        __key(   "Down",     vk_down,    16.1, 5.1),
        __key(  "Right",    vk_right,    17.1, 5.1),
        
        //////////////////////////////////////////////////////
        
        __key(    "Num",          -1,     18.2, 1.1),
        __key(      "/",   vk_divide,     19.2, 1.1),
        __key(      "*", vk_multiply,     20.2, 1.1),
        __key(      "-", vk_subtract,     21.2, 1.1),
         
        __key(      "7",  vk_numpad7,     18.2, 2.1),
        __key(      "8",  vk_numpad8,     19.2, 2.1),
        __key(      "9",  vk_numpad9,     20.2, 2.1),
        __key(      "+",      vk_add,     21.2, 2.1, 1, 2),
         
        __key(      "4",  vk_numpad4,     18.2, 3.1),
        __key(      "5",  vk_numpad5,     19.2, 3.1),
        __key(      "6",  vk_numpad6,     20.2, 3.1),
         
        __key(      "1",  vk_numpad1,     18.2, 4.1),
        __key(      "2",  vk_numpad2,     19.2, 4.1),
        __key(      "3",  vk_numpad3,     20.2, 4.1),
        __key(  "Enter",          -1,     21.2, 4.1, 1, 2),
         
        __key(      "0",  vk_numpad0,     18.2, 5.1, 2),
        __key(      ".",  vk_decimal,     20.2, 5.1),
        
    ];
    
    width  = 22.2;
    height = 6.1;
}