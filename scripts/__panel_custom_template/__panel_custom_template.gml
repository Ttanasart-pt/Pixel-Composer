function Panel_Custom_Template() : Panel_Custom_Element() constructor {
	type = "";
	name = "";
	icon = THEME.panel_icon_element_text;
	
	array_append(editors, [
		[ "Section", false ], 
		// Simple_Editor("Color", new buttonColor( (c) => { color = c; }), () => color, (c) => { color = c; }), 
	]);
	
	////- Draw
	
	static draw = function(panel, _m) {
		
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.text   = text;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		text =   _m[$ "text"]   ?? text;
		
		return self;
	}
}