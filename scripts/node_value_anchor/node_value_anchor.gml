function nodeValue_Anchor(_name, _node, _value = [ .5, .5 ]) { 
    var _in = nodeValue_Vec2(_name, _node, _value);
	_in.setDisplay(VALUE_DISPLAY.vector, { side_button : new buttonAnchor(_in) });
	return _in;
}