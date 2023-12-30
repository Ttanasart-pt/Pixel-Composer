function Node_FLIP_Apply_Velocity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Velocity";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 )	
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 3] = nodeValue("Velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 0, 
		["Velocity",	false], 1, 2, 3, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _velo  = getInputData(3);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _vx = _px + _velo[0] * _s;
		var _vy = _py + _velo[1] * _s;
			
		if(inputs[| 2].drawOverlay(active, _px, _py, _s, _mx, _my, _snx, _sny, 0, 1, THEME.anchor_scale_hori)) active = false;
			
		draw_set_color(COLORS._main_accent);
		draw_circle(_px, _py, _rad * _s, true);
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_line_width2(_px, _py, _vx, _vy, 6, 2);
		draw_set_alpha(1);
		
		if(inputs[| 1].drawOverlay(active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 3].drawOverlay(active, _px, _py, _s, _mx, _my, _snx, _sny)) active = false;
		
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _velo  = getInputData(3);
		
		FLIP_applyVelocity_circle(domain.domain, _posit[0], _posit[1], _rad, _velo[0], _velo[1]);
	}
}