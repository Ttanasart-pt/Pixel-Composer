function Node_FLIP_Apply_Velocity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Velocity";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Fdomain("Domain"))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ] ))
		.setUnitRef(function(index) { return getDimension(); });
	
	newInput(2, nodeValue_Slider("Radius", 4, [1, 16, 0.1] ));
	
	newInput(3, nodeValue_Vec2("Velocity", [ 0, 0 ] ));
	
	newInput(4, nodeValue_Enum_Scroll("Shape",  0 , [ new scrollItem("Circle", s_node_shape_circle, 0), new scrollItem("Rectangle", s_node_shape_rectangle, 0) ]));
		
	newInput(5, nodeValue_Vec2("Size", [ 4, 4 ] ));
		
	input_display_list = [ 0, 
		["Velocity",	false], 4, 1, 2, 5, 3, 
	]
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	static getDimension = function() { 
		var domain = getInputData(0);
		if(!instance_exists(domain)) return [ 1, 1 ];
		
		return [ domain.width, domain.height ];
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _velo  = getInputData(3);
		var _shp   = getInputData(4);
		var _siz   = getInputData(5);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _vx = _px + _velo[0] * _s;
		var _vy = _py + _velo[1] * _s;
		
		var _r = _rad * _s;
		var _w = _siz[0] * _s;
		var _h = _siz[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		     if(_shp == 0) draw_circle_prec(_px, _py, _r, true, 32);
		else if(_shp == 1) draw_rectangle(_px - _w, _py - _h, _px + _w, _py + _h, true);
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_line_width2(_px, _py, _vx, _vy, 6, 2);
		draw_set_alpha(1);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {
		var _shp = getInputData(4);
		
		inputs[2].setVisible(_shp == 0);
		inputs[5].setVisible(_shp == 1);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _velo  = getInputData(3);
		var _shp   = getInputData(4);
		var _siz   = getInputData(5);
		
		     if(_shp == 0) FLIP_applyVelocity_circle(domain.domain, _posit[0], _posit[1], _rad, _velo[0], _velo[1]);
		else if(_shp == 1) FLIP_applyVelocity_rectangle(domain.domain, _posit[0] - _siz[0], _posit[1] - _siz[1], _siz[0] * 2, _siz[1] * 2, _velo[0], _velo[1]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_flip_apply_velocity, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}