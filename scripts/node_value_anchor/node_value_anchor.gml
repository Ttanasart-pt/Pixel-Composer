function nodeValue_Anchor(_name = "Anchor", _value = [ .5, .5 ]) { 
    var _inp = nodeValue_Vec2(_name, _value);
        _inp.setDisplay(VALUE_DISPLAY.vector, { side_button : new buttonAnchor(_inp) })
    return _inp;
}