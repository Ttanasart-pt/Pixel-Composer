function Node_FLIP_Repel(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Repel";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	setDrawIcon(s_node_flip_repel);
	
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	newInput(1, nodeValue_Vec2(   "Position", [ 0, 0 ] )).setHotkey("G").setUnitSimple();
	newInput(2, nodeValue_Float(  "Radius",     4      ));
	newInput(3, nodeValue_Slider( "Strength",   4, [ 0, 16, 0.1 ] ));
	// input 4
		
	input_display_list = [ 0, 
		["Repel",	false], 1, 2, 3, 
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
		
		FLIP_repel(domain.domain, _posit[0], _posit[1], _rad, _str * 8);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}