function Node_FLIP_Vortex(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Vortex";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	inputs[0] = nodeValue_Fdomain("Domain", self, noone )
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Vector("Position", self, [ 0, 0 ] )
		.setUnitRef(function(index) { return getDimension(); });
	
	inputs[2] = nodeValue_Float("Radius", self, 4 );
	
	inputs[3] = nodeValue_Float("Strength", self, 4 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -8, 8, 0.01 ] });
	
	inputs[4] = nodeValue_Float("Attraction", self, 0 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -8, 8, 0.01 ] });
		
	input_display_list = [ 0, 
		["Vertex",	false], 1, 2, 3, 4, 
	]
	
	outputs[0] = nodeValue_Output("Domain", self, VALUE_TYPE.fdomain, noone );
	
	static getDimension = function() { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return [ 1, 1 ];
		
		return [ domain.width, domain.height ];
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _r = _rad * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_prec(_px, _py, _r, true, 32);
		
		if(inputs[1].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) { hover = false; active = false; }
		
	} #endregion
	
	static step = function() { #region
		
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _str   = getInputData(3);
		var _attr  = getInputData(4);
		
		FLIP_Vortex(domain.domain, _posit[0], _posit[1], _rad, _str, _attr);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_vortex, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}