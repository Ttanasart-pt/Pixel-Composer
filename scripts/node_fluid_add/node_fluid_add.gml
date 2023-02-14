function Node_Fluid_Add(_x, _y, _group = -1) : Node_Fluid(_x, _y, _group) constructor {
	name  = "Add Fluid";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w = 96;
	min_h = 96;
	
	inputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Fluid brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 4] = nodeValue("Inherit velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01 ]);
	
	inputs[| 5] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	input_display_list = [ 
		["Domain",	false], 0, 
		["Fluid",	false], 3, 1, 5, 2, 4,
	];
	
	outputs[| 0] = nodeValue("Fluid Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _mat = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		
		if(is_surface(_mat)) {
			var sw = surface_get_width(_mat) * _s;
			var sh = surface_get_height(_mat) * _s;
			var mx = _x + _pos[0] * _s - sw / 2;
			var my = _y + _pos[1] * _s - sh / 2;
			
			draw_surface_ext(_mat, mx, my, _s, _s, 0, c_white, 0.5);
		}
		
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	_prevPos = noone;
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _dom = inputs[| 0].getValue(frame);
		var _mat = inputs[| 1].getValue(frame);
		var _pos = inputs[| 2].getValue(frame);
		var _act = inputs[| 3].getValue(frame);
		var _inh = inputs[| 4].getValue(frame);
		var _den = inputs[| 5].getValue(frame);
		
		if(_dom == noone || !instance_exists(_dom)) return;
		outputs[| 0].setValue(_dom);
		
		if(!_act) return;
		if(!is_surface(_mat)) return;
		
		var sw = surface_get_width(_mat);
		var sh = surface_get_height(_mat);
		
		if(_prevPos != noone && _inh != 0) {
			var dx = _pos[0] - _prevPos[0];
			var dy = _pos[1] - _prevPos[1];
			
			fd_rectangle_add_velocity_surface(_dom, _mat, _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, dx * _inh, dy * _inh);
		}
		
		fd_rectangle_add_material_surface(_dom, _mat, _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, c_white, _den);
		
		_prevPos[0] = _pos[0];
		_prevPos[1] = _pos[1];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = inputs[| 1].getValue();
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}