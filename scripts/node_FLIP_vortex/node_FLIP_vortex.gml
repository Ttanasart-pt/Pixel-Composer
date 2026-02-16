function Node_FLIP_Vortex(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Vortex";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	setDrawIcon(s_node_flip_vortex);
	
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	newInput(1, nodeValue_Vec2(   "Position", [ 0, 0 ] )).setHotkey("G").setUnitSimple();
	newInput(2, nodeValue_Float(  "Radius",     4      ));
	newInput(3, nodeValue_Slider( "Strength",   4, [ -8, 8, 0.01 ] ));
	newInput(4, nodeValue_Slider( "Attraction", 0, [ -8, 8, 0.01 ] ));
	// input 5
		
	input_display_list = [ 0, 
		["Vertex",	false], 1, 2, 3, 4, 
	]
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	static getDimension = function() {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return [ 1, 1 ];
		
		return [ domain.width, domain.height ];
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _r = _rad * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_prec(_px, _py, _r, true, 32);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static step = function() {
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _str   = getInputData(3);
		var _attr  = getInputData(4);
		
		FLIP_vortex(domain.domain, _posit[0], _posit[1], _rad, _str, _attr);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}