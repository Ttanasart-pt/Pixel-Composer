function Node_Fluid_Turbulence(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Turbulence";
	w = 96;
	min_h = 96;
	
	inputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Effect area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, AREA_DEF)
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.10)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.01] });
	
	inputs[| 4] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999) );
	
	inputs[| 5] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Override", "Add" ]);
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Turbulence",	false], 5, 1, 2, 4, 3
	];
	
	outputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = inputs[| 0].getValue(frame);
		var _are = inputs[| 1].getValue(frame);
		var _str = inputs[| 2].getValue(frame);
		var _sca = inputs[| 3].getValue(frame);
		var _sed = inputs[| 4].getValue(frame);
		var _mod = inputs[| 5].getValue(frame);
		
		FLUID_DOMAIN_CHECK
		outputs[| 0].setValue(_dom);
		
		var vSurface = surface_create_size(_dom.sf_velocity);
		
		surface_set_target(vSurface)
			draw_clear_alpha(0., 0.);
			shader_set(sh_fd_turbulence);
			BLEND_OVERRIDE;
			
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "scale"), _sca);
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "seed"), _sed);
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "strength"), _str);
			draw_sprite_stretched(s_fx_pixel, 0, _are[0] - _are[2], _are[1] - _are[3], _are[2] * 2, _are[3] * 2);
			BLEND_NORMAL;
			shader_reset();
		surface_reset_target();
		
		fd_rectangle_set_target(_dom, _mod? FD_TARGET_TYPE.ADD_VELOCITY : FD_TARGET_TYPE.REPLACE_VELOCITY);
		draw_surface_safe(vSurface, 0, 0);
		fd_rectangle_reset_target(_dom);
		
		surface_free(vSurface);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_fluidSim_turbulence, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}