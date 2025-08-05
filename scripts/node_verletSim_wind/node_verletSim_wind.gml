function Node_VerletSim_Wind(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wind";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDimension(96, 48);
	
	newActiveInput(7);
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Wind
	newInput(1, nodeValue_Vec2(     "Center",      [.5,.5] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Rotation( "Direction",     0     )).setHotkey("R");
	newInput(3, nodeValue_Float(    "Width",         8     ));
	newInput(4, nodeValue_Float(    "Falloff",       4     ));
	newInput(5, nodeValue_Curve(    "Falloff Curve", CURVE_DEF_01 ));
	newInput(6, nodeValue_Float(    "Strength",      1     ));
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 7, 0, 
		[ "Wind", false ], 1, 2, 3, 4, 5, 6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		var _inf_wori = getInputData(1);
		var _inf_wrot = getInputData(2);
		var _inf_wwid = getInputData(3) * _s;
		var _inf_fall = getInputData(4) * _s;
		
		var _ox = _x + _inf_wori[0] * _s;
		var _oy = _y + _inf_wori[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _ox, _oy, _s, _mx, _my, _snx, _sny));
		
		var _ox0 = _ox + lengthdir_x(_inf_wwid, _inf_wrot - 90);
		var _oy0 = _oy + lengthdir_y(_inf_wwid, _inf_wrot - 90);
		var _ox1 = _ox + lengthdir_x(_inf_wwid, _inf_wrot + 90);
		var _oy1 = _oy + lengthdir_y(_inf_wwid, _inf_wrot + 90);
		
		var _dx = lengthdir_x(9999, _inf_wrot);
		var _dy = lengthdir_y(9999, _inf_wrot);
		
		draw_set_color(COLORS._main_accent);
		draw_line(_ox0 - _dx, _oy0 - _dy, _ox0 + _dx, _oy0 + _dy);
		draw_line(_ox1 - _dx, _oy1 - _dy, _ox1 + _dx, _oy1 + _dy);
		
		var _odx = lengthdir_x(_inf_fall, _inf_wrot + 90);
		var _ody = lengthdir_y(_inf_fall, _inf_wrot + 90);
		
		draw_set_alpha(.5);
		draw_line_dashed(_ox0 - _odx - _dx, _oy0 - _ody - _dy, _ox0 - _odx + _dx, _oy0 - _ody + _dy);
		draw_line_dashed(_ox1 + _odx - _dx, _oy1 + _ody - _dy, _ox1 + _odx + _dx, _oy1 + _ody + _dy);
		draw_set_alpha(1);
		
		return w_hovering;
	}
	
	static update = function() {
		var _active = getInputData(7);
		var _mesh   = getInputData(0);
		outputs[0].setValue(_mesh);
		
		var _center   = getInputData(1);
		var _direct   = getInputData(2);
		var _width    = getInputData(3);
		var _fall_dis = getInputData(4);
		var _fall_cur = getInputData(5);
		var _stren    = getInputData(6);
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var vx = lengthdir_x(_stren, _direct) / 10;
		var vy = lengthdir_y(_stren, _direct) / 10;
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p  = _mesh.points[i];
			if(!is(p, __vec2) || p.pin) continue;
			
			var _dir = point_direction(_center[0], _center[1], p.x, p.y);
			var _dis = point_distance(_center[0], _center[1], p.x, p.y);
			var _ang = abs(angle_difference(_dir, _direct));
			var _dst = abs(_dis * dsin(_ang));
			
			var str = 1 - (_dst - (_width / 2 - _fall_dis)) / (_fall_dis * 2);
			    str = eval_curve_x(_fall_cur, clamp(str, 0., 1.));
			
			p.x += str * vx;
			p.y += str * vy;
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_wind, 0, bbox);
	}
}
