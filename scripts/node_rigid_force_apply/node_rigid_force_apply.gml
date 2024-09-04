function Node_Rigid_Force_Apply(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Force";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Scroll("Force type", self,  0, [ "Constant", "Impulse", "Torque", "Explode" ]))
		.rejectArray();
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.rejectArray();
	
	newInput(3, nodeValue_Float("Torque", self, 0))
		.rejectArray();
	
	newInput(4, nodeValue_Int("Apply frame", self, 0, "Frame index to apply force."))
		.rejectArray();
	
	newInput(5, nodeValue_Vec2("Force", self, [ 0.1, 0 ]))
		.rejectArray();
	
	newInput(6, nodeValue_Enum_Button("Scope", self,  0, [ "Global", "Local" ]))
		.rejectArray();
	
	newInput(7, nodeValue_Float("Strength", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.01] })
		.rejectArray();
	
	newInput(8, nodeValue_Float("Range", self, 8))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone));
	
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
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
			
			inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			inputs[5].drawOverlay(hover, active, px, py, _s * attributes.display_scale, _mx, _my, _snx, _sny, 0, 10);
		} else if(_typ == 3) {
			var _rad = getInputData(8);
			
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			draw_circle_prec(px, py, _rad * _s, 1);
			draw_set_alpha(1);
			
			inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			inputs[8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		} else 
			inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {
		var _typ = getInputData(1);
		
		inputs[3].setVisible(_typ == 2);
		inputs[4].setVisible(_typ > 0);
		inputs[5].setVisible(_typ == 0 || _typ == 1);
		inputs[6].setVisible(_typ != 3);
		inputs[7].setVisible(_typ == 3);
		inputs[8].setVisible(_typ == 3);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _obj = getInputData(0);
		outputs[0].setValue(_obj);
		
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
		
		if(!is_array(_obj)) return;
			
		for( var i = 0, n = array_length(_obj); i < n; i++ ) {
			var obj = _obj[i];
			
			if(obj == noone || !instance_exists(obj)) continue;
			if(is_undefined(obj.phy_active)) continue;
				
			with(obj) {
				switch(_typ) {
					case 0 : 
						if(_sco == 0) physics_apply_force(_pos[0], _pos[1], _for[0], _for[1]);
						else          physics_apply_local_force(_pos[0], _pos[1], _for[0], _for[1]);
						break;
						
					case 1 : 
						if(_sco == 0) physics_apply_impulse(_pos[0], _pos[1], _for[0], _for[1]);
						else          physics_apply_local_impulse(_pos[0], _pos[1], _for[0], _for[1]);
						break;
						
					case 2 :
						physics_apply_torque(_tor);
						break;
						
					case 3 : 
						var dis = point_distance(_pos[0], _pos[1], phy_com_x, phy_com_y);
						
						if(dis < _rad) {
							var dir = point_direction(_pos[0], _pos[1], phy_com_x, phy_com_y);
							
							var str = _str * sqr(1 - dis / _rad);
							var fx = lengthdir_x(str, dir);
							var fy = lengthdir_y(str, dir);
							physics_apply_impulse(_pos[0], _pos[1], fx, fy);
						}
						break;
				}
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_rigidSim_force, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}