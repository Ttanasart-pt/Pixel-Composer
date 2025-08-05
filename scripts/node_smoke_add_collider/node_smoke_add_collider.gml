function Node_Smoke_Add_Collider(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Add Collider";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	manual_ungroupable	 = false;
	
	////- =Domain
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone)).setVisible(true, true);
	
	////- =Collider
	newInput(1, nodeValue_Surface( "Collider" ));
	newInput(2, nodeValue_Area(    "Area", DEF_AREA, { useShape : false } ));
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Collider",	false], 1, 2,
	];
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _mat = getInputData(1);
		var _area = getInputData(2);
		
		if(is_surface(_mat)) {
			var x0 = _x + (_area[0] - _area[2]) * _s;
			var y0 = _y + (_area[1] - _area[3]) * _s;
			var x1 = _x + (_area[0] + _area[2]) * _s;
			var y1 = _y + (_area[1] + _area[3]) * _s;
			
			draw_surface_stretched_ext(_mat, x0, y0, x1 - x0, y1 - y0, c_white, 0.5);
		}
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom  = getInputData(0);
		var _mat  = getInputData(1);
		var _area = getInputData(2);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		if(!is_surface(_mat)) return;
		if(!is_surface(_dom.sf_world)) return;
		
		surface_set_target(_dom.sf_world);
			draw_surface_stretched_safe(_mat, _area[0] - _area[2], _area[1] - _area[3], _area[2] * 2, _area[3] * 2);
		surface_reset_target();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}