function Node_Rigid_Force_Apply(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Apply Force";
	w = 96;
	min_h = 96;
	
	inputs[| 0] = nodeValue(0, "Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.object, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Force type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Constant", "Impulse", "Torque" ]);
	
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Torque", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "Apply frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Frame index to apply force.");
	
	inputs[| 5] = nodeValue(5, "Force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue(6, "Scope", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Global", "Local" ]);
		
	outputs[| 0] = nodeValue(0, "Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, noone);
	
	input_display_list = [
		["Object",	 true],	0,
		["Force",	false],	1, 6, 4, 2, 3, 5
	]
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _typ = inputs[| 1].getValue();
		
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {
		var _typ = inputs[| 1].getValue();
		
		inputs[| 3].setVisible(_typ == 2);
		inputs[| 4].setVisible(_typ == 1 || _typ == 2);
		inputs[| 5].setVisible(_typ == 0 || _typ == 1);
	}
	
	static update = function() {
		var _obj = inputs[| 0].getValue();
		outputs[| 0].setValue(_obj);
		
		if(!ANIMATOR.is_playing)
			return;
			
		var _typ = inputs[| 1].getValue();
		
		var _pos = inputs[| 2].getValue();
		var _tor = inputs[| 3].getValue();
		var _frm = inputs[| 4].getValue();
		var _for = inputs[| 5].getValue();
		var _sco = inputs[| 6].getValue();
		
		if((_typ == 1 || _typ == 2) && ANIMATOR.current_frame != _frm)
			return;
		
		if(!is_array(_obj)) _obj = [ _obj ];
			
		for( var i = 0; i < array_length(_obj); i++ ) {
			var _o = _obj[i].object;
			if(!is_array(_o)) _o = [ _o ];
			
			for( var j = 0; j < array_length(_o); j++ ) {
				var obj = _o[j];
				if(obj == noone || !instance_exists(obj)) continue;
				if(is_undefined(obj.phy_active)) continue;
				
				with(obj) {
					if(_typ == 0 && _sco == 0)
						physics_apply_force(_pos[0], _pos[1], _for[0], _for[1]);
					else if(_typ == 0 && _sco == 1)
						physics_apply_local_force(_pos[0], _pos[1], _for[0], _for[1]);
					else if(_typ == 1 && _sco == 0)
						physics_apply_impulse(_pos[0], _pos[1], _for[0], _for[1]);
					else if(_typ == 1 && _sco == 1)
						physics_apply_local_impulse(_pos[0], _pos[1], _for[0], _for[1]);
					else if(_typ == 2)
						physics_apply_torque(_tor);
				}
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigidSim_force, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}