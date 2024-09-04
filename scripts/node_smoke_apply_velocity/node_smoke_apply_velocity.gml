function Node_Smoke_Apply_Velocity(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Apply Velocity";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Surface("Brush", self));
	
	newInput(2, nodeValue_Vec2("Position", self, [0, 0]));
	
	newInput(3, nodeValue_Vec2("Velocity", self, [0, 0]));
	
	newInput(4, nodeValue_Bool("Active", self, true));
	
	input_display_list = [ 
		["Domain",		false], 0, 
		["Velocity",	false], 4, 1, 2, 3
	];
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _mat = getInputData(1);
		var _pos = getInputData(2);
		
		if(is_surface(_mat)) {
			var sw = surface_get_width_safe(_mat) * _s;
			var sh = surface_get_height_safe(_mat) * _s;
			var mx = _x + _pos[0] * _s - sw / 2;
			var my = _y + _pos[1] * _s - sh / 2;
			
			draw_surface_ext_safe(_mat, mx, my, _s, _s, 0, c_white, 0.5);
		}
		
		inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = getInputData(0);
		var _mat = getInputData(1);
		var _pos = getInputData(2);
		var _vel = getInputData(3);
		var _act = getInputData(4);
		
		FLUID_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		if(!_act) return;
		if(!is_surface(_mat)) return;
		
		var sw = surface_get_width_safe(_mat);
		var sh = surface_get_height_safe(_mat);
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		surface_set_shader(temp_surface[0], sh_fluid_bleach);
			draw_surface_safe(_mat);
		surface_reset_shader();
		
        fd_rectangle_add_velocity_surface(_dom, temp_surface[0], _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, _vel[0], _vel[1]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}