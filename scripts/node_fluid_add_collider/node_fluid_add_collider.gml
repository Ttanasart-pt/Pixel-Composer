function Node_Fluid_Add_Collider(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Add Collider";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	inputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Collider", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 4, 4, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Collider",	false], 1, 2,
	];
	
	outputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _mat = inputs[| 1].getValue();
		var _area = inputs[| 2].getValue();
		
		if(is_surface(_mat)) {
			var x0 = _x + (_area[0] - _area[2]) * _s;
			var y0 = _y + (_area[1] - _area[3]) * _s;
			var x1 = _x + (_area[0] + _area[2]) * _s;
			var y1 = _y + (_area[1] + _area[3]) * _s;
			
			draw_surface_stretched_ext(_mat, x0, y0, x1 - x0, y1 - y0, c_white, 0.5);
		}
		
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _dom  = inputs[| 0].getValue(frame);
		var _mat  = inputs[| 1].getValue(frame);
		var _area = inputs[| 2].getValue(frame);
		if(_dom == noone || !instance_exists(_dom)) return;
		
		outputs[| 0].setValue(_dom);
		if(!is_surface(_mat)) return;
		if(!is_surface(_dom.sf_world)) return;
		
		surface_set_target(_dom.sf_world);
			draw_surface_stretched_safe(_mat, _area[0] - _area[2], _area[1] - _area[3], _area[2] * 2, _area[3] * 2);
		surface_reset_target();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = inputs[| 1].getValue();
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}