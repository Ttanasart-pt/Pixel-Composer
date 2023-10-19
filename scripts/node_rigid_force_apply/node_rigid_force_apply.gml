function Node_Rigid_Force_Apply(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Apply Force";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	w = 96;
	min_h = 96;
	
	inputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Force type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Constant", "Impulse", "Torque", "Explode" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Torque", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.rejectArray();
	
	inputs[| 4] = nodeValue("Apply frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Frame index to apply force.")
		.rejectArray();
	
	inputs[| 5] = nodeValue("Force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.1, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 6] = nodeValue("Scope", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Global", "Local" ])
		.rejectArray();
	
	inputs[| 7] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.01] })
		.rejectArray();
	
	inputs[| 8] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8)
		.rejectArray();
		
	outputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.output, VALUE_TYPE.rigid, noone);
	
	input_display_list = [
		["Object",	 true],	0,
		["Force",	false],	1, 6, 4, 2, 3, 5, 8, 7, 
	]
	
	array_push(attributeEditors, "Display");
	
	attributes.show_objects = true;
	array_push(attributeEditors, ["Show objects", function() { return attributes.show_objects; }, 
		new checkBox(function() { 
			attributes.show_objects = !attributes.show_objects;
		})]);
	
	attributes.display_scale = 512;
	array_push(attributeEditors, ["Display scale", function() { return attributes.display_scale; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.display_scale = val;
		})]);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(attributes.show_objects) 
		for( var i = 0, n = ds_list_size(group.nodes); i < n; i++ ) {
			var _node = group.nodes[| i];
			if(!is_instanceof(_node, Node_Rigid_Object)) continue;
			var _hov = _node.drawOverlayPreview(active, _x, _y, _s, _mx, _my, _snx, _sny);
			active &= !_hov;
		}
		
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
			
		if(_typ == 0 || _typ == 1) {
			var _for = getInputData(5);
			
			var fx = px + _for[0] * attributes.display_scale * _s;
			var fy = py + _for[1] * attributes.display_scale * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_line_width2(px, py, fx, fy, 8, 2);
			draw_set_alpha(1);
			
			inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
			inputs[| 5].drawOverlay(active, px, py, _s * attributes.display_scale, _mx, _my, _snx, _sny, THEME.anchor, 10);
		} else if(_typ == 3) {
			var _rad = getInputData(8);
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_circle_prec(px, py, _rad * _s, 1);
			draw_set_alpha(1);
			
			inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
			inputs[| 8].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny, 0, 1, THEME.anchor_scale_hori);
		} else 
			inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {
		var _typ = getInputData(1);
		
		inputs[| 3].setVisible(_typ == 2);
		inputs[| 4].setVisible(_typ > 0);
		inputs[| 5].setVisible(_typ == 0 || _typ == 1);
		inputs[| 6].setVisible(_typ != 3);
		inputs[| 7].setVisible(_typ == 3);
		inputs[| 8].setVisible(_typ == 3);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _obj = getInputData(0);
		outputs[| 0].setValue(_obj);
		
		RETURN_ON_REST
			
		var _typ = getInputData(1);
		
		var _pos = getInputData(2);
		var _tor = getInputData(3);
		var _frm = getInputData(4);
		var _for = getInputData(5);
		var _sco = getInputData(6);
		var _str = getInputData(7);
		var _rad = getInputData(8);
		
		if((_typ > 0) && CURRENT_FRAME != _frm)
			return;
		
		if(!is_array(_obj)) _obj = [ _obj ];
			
		for( var i = 0, n = array_length(_obj); i < n; i++ ) {
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
					else if(_typ == 3) {
						var dir = point_direction(_pos[0], _pos[1], phy_com_x, phy_com_y);
						var dis = point_distance(_pos[0], _pos[1], phy_com_x, phy_com_y);
						
						if(dis < _rad) {
							var str = _str * sqr(1 - dis / _rad);
							var fx = lengthdir_x(str, dir);
							var fy = lengthdir_y(str, dir);
							physics_apply_impulse(_pos[0], _pos[1], fx, fy);
						}
					}
				}
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigidSim_force, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}