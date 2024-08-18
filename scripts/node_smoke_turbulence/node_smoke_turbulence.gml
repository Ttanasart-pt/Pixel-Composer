function Node_Smoke_Turbulence(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Turbulence";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Effect area", self, DEF_AREA, { useShape : false }));
	
	newInput(2, nodeValue_Float("Strength", self, 0.10))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(3, nodeValue_Float("Scale", self, 4))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.01] });
	
	newInput(4, nodeValue_Float("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[4].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	newInput(5, nodeValue_Enum_Button("Mode", self,  0, [ "Override", "Add" ]));
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Turbulence",	false], 5, 1, 2, 4, 3
	];
	
	outputs[0] = nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		var _are = getInputData(1);
		var _str = getInputData(2);
		var _sca = getInputData(3);
		var _sed = getInputData(4);
		var _mod = getInputData(5);
		
		FLUID_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		var vSurface = surface_create_size(_dom.sf_velocity);
		
		surface_set_target(vSurface)
			draw_clear_alpha(0., 0.);
			shader_set(sh_fd_turbulence);
			BLEND_OVERRIDE;
			
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "scale"),    _sca);
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "seed"),     _sed);
			shader_set_uniform_f(shader_get_uniform(sh_fd_turbulence, "strength"), _str);
			draw_sprite_stretched(s_fx_pixel, 0, _are[0] - _are[2], _are[1] - _are[3], _are[2] * 2, _are[3] * 2);
			BLEND_NORMAL;
			shader_reset();
		surface_reset_target();
		
		fd_rectangle_set_target(_dom, _mod? FD_TARGET_TYPE.ADD_VELOCITY : FD_TARGET_TYPE.REPLACE_VELOCITY);
		draw_surface_safe(vSurface);
		fd_rectangle_reset_target(_dom);
		
		surface_free(vSurface);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_smokeSim_turbulence, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}