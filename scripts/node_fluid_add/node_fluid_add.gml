function Node_Fluid_Add(_x, _y, _group = noone) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Add Emitter";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Fluid brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 4] = nodeValue("Inherit velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 5] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Expand velocity mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 7] = nodeValue("Velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		["Domain",	 false], 0, 
		["Fluid",	 false], 3, 1, 5, 2,
		["Velocity", false], 7, 4, 6, 
	];
	
	_prevPos = noone;
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	temp_surface = [ surface_create(1, 1) ];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _mat = getInputData(1);
		var _pos = getInputData(2);
		
		if(is_surface(_mat)) {
			var sw = surface_get_width_safe(_mat) * _s;
			var sh = surface_get_height_safe(_mat) * _s;
			var mx = _x + _pos[0] * _s - sw / 2;
			var my = _y + _pos[1] * _s - sh / 2;
			
			draw_surface_ext_safe(_mat, mx, my, _s, _s, 0, c_white, 0.5);
		}
		
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) {
		var _dom = inputs[| 0].getValue(frame);
		var _mat = inputs[| 1].getValue(frame);
		var _pos = inputs[| 2].getValue(frame);
		var _act = inputs[| 3].getValue(frame);
		var _inh = inputs[| 4].getValue(frame);
		var _den = inputs[| 5].getValue(frame);
		var _msk = inputs[| 6].getValue(frame);
		var _vel = inputs[| 7].getValue(frame);
		
		FLUID_DOMAIN_CHECK
		outputs[| 0].setValue(_dom);
		
		if(!_act) return;
		if(!is_surface(_mat)) return;
		
		var sw = surface_get_width_safe(_mat);
		var sh = surface_get_height_safe(_mat);
		
		var dx = _vel[0];
		var dy = _vel[1];
		
		if(_prevPos != noone && _inh != 0) {
			dx += (_pos[0] - _prevPos[0]) * _inh;
			dy += (_pos[1] - _prevPos[1]) * _inh;
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		surface_set_shader(temp_surface[0], sh_fluid_bleach);
			draw_surface_safe(_mat);
		surface_reset_shader();
			
		if(dx != 0 || dy != 0) {
			if(_msk == 0) 
				fd_rectangle_add_velocity_surface(_dom, temp_surface[0], _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, dx, dy);
			else {
				var _vw = sw + max(0, _msk * 2);
				var _vh = sh + max(0, _msk * 2);
			
				var _vmask = surface_create(_vw, _vh);
				surface_set_shader(_vmask,,, BLEND.over);
					draw_surface_safe(temp_surface[0], max(0, _msk), max(0, _msk));
				surface_reset_shader();
				
				var vel_mask = surface_create(_vw, _vh);
				surface_set_shader(vel_mask, sh_mask_expand);
					shader_set_f("dimension", _vw, _vh);
					shader_set_f("amount", _msk);
					draw_surface_safe(_vmask);
				surface_reset_shader();
				
				fd_rectangle_add_velocity_surface(_dom, vel_mask, _pos[0] - _vw / 2, _pos[1] - _vh / 2, 1, 1, dx, dy);
				
				surface_free(_vmask);
				surface_free(vel_mask);
			}
		}
		
		fd_rectangle_add_material_surface(_dom, temp_surface[0], _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, c_white, _den);
		
		_prevPos[0] = _pos[0];
		_prevPos[1] = _pos[1];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}