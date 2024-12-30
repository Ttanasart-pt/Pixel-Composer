function Node_Smoke_Repulse(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Repulse";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Position", self, [0, 0]));
	
	newInput(2, nodeValue_Float("Radius", self, 8));
	
	newInput(3, nodeValue_Float("Strength", self, 0.10))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(4, nodeValue_Float("Spokes", self, 0));
	
	newInput(5, nodeValue_Rotation("Twist", self, 0));
	
	input_display_list = [ 
		["Domain",	false], 0, 
		["Repulse",	false], 1, 2, 3, 4, 5, 
	];
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone));
	
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pos = getInputData(1);
		var _rad = getInputData(2);
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle_prec(px, py, _rad * _s, true);
		
		inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		var _pos = getInputData(1);
		var _rad = getInputData(2);
		var _str = getInputData(3);
		var _spk = getInputData(4);
		var _spk_r = getInputData(5);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		_rad = max(_rad, 1);
		temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, surface_rgba32float);
		
		surface_set_shader(temp_surface[0], sh_fd_repulse);
			shader_set_f("strength", _str);
			shader_set_f("spokes",   _spk);
			shader_set_f("rotate",   degtorad(_spk_r));
			shader_set_f("radius",   max(_rad /_dom.width, _rad / _dom.height));
			shader_set_f("center",   _pos[0] / _dom.width, _pos[1] / _dom.height);
			draw_empty();
		surface_reset_shader();
		
		_dom.addVelocity(temp_surface[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_smoke_repulse, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}