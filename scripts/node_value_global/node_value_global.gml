function nodeValue_Global(_name) { return new NodeValue_Global(_name, self ); }
function NodeValue_Global(_name, _node) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, 0) constructor {
	editor = new variable_editor(self);
	
	static dragValue = function() /*=>*/ { DRAGGING = { type: "Globalvar", data: name }; }
}