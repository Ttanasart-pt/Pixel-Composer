function Node_Smoke_Turbulence(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Turbulence";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Effect area", DEF_AREA, { useShape : false }));
	
	newInput(2, nodeValue_Float("Strength", 0.10))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(3, nodeValue_Float("Scale", 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.01] });
	
	newInput(4, nodeValueSeed(self));
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Turbulence",	false], 1, 2, 4, 3
	];
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		var _are = getInputData(1);
		var _str = getInputData(2);
		var _sca = getInputData(3);
		var _sed = getInputData(4);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		temp_surface[0] = surface_verify(temp_surface[0], _dom.width, _dom.height, surface_rgba32float);
		
		surface_set_target(temp_surface[0])
			draw_clear_alpha(0., 0.);
			shader_set(sh_fd_turbulence);
			BLEND_OVERRIDE
			
			shader_set_f("scale",    _sca);
			shader_set_f("seed",     _sed);
			shader_set_f("strength", _str);
			draw_sprite_stretched(s_fx_pixel, 0, _are[0] - _are[2], _are[1] - _are[3], _are[2] * 2, _are[3] * 2);
			BLEND_NORMAL
			shader_reset();
		surface_reset_target();
		
		_dom.addVelocity(temp_surface[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_smoke_turbulence, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}