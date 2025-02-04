function Node_Template(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "";
	
	newInput(0, nodeValue_Surface("", self));
	
	newOutput(0, nodeValue_Output("", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {}
}

/*
#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("", " > Set", KEY_GROUP.numeric, MOD_KEY.none, () => { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("", " > ", "", MOD_KEY.none, () => { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(); });
		addHotkey("", " > Toggle", "", MOD_KEY.none, () => { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion

