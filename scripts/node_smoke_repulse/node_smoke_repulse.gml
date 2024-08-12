function Node_Smoke_Repulse(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Repulse";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	inputs[0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.sdomain, noone)
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Vec2("Position", self, [0, 0]);
	
	inputs[2] = nodeValue_Float("Radius", self, 8);
	
	inputs[3] = nodeValue_Float("Strength", self, 0.10)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	inputs[4] = nodeValue_Enum_Button("Mode", self,  0, [ "Override", "Add" ]);
	
	input_display_list = [ 
		["Domain",	false], 0, 
		["Repulse",	false], 4, 1, 2, 3
	];
	
	outputs[0] = nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone);
	
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
		var _mod = getInputData(4);
		
		FLUID_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		_rad = max(_rad, 1);
		var vSurface = surface_create_size(_dom.sf_velocity);
		
		surface_set_target(vSurface)
			draw_clear_alpha(0., 0.);
			shader_set(sh_fd_repulse);
			BLEND_OVERRIDE;
		
			shader_set_f("strength", _str);
			draw_sprite_stretched(s_fx_pixel, 0, _pos[0] - _rad, _pos[1] - _rad, _rad * 2, _rad * 2);
			BLEND_NORMAL;
			shader_reset();
		surface_reset_target();
		
		with(_dom) {
			fd_rectangle_set_target(id, _mod? FD_TARGET_TYPE.ADD_VELOCITY : FD_TARGET_TYPE.REPLACE_VELOCITY);
			draw_surface_safe(vSurface);
			fd_rectangle_reset_target(id);
		}
		
		surface_free(vSurface);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_fit(s_node_smokeSim_repulse, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}