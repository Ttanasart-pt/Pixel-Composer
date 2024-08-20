function Node_Rigid_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rigidbody Override";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	node_draw_icon = s_node_rigid_override;
	
	manual_ungroupable	 = false;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Vec2("Positions", self, [0, 0] ));
	
	newInput(2, nodeValue_Vec2("Scales", self, [0, 0] ));
	
	newInput(3, nodeValue_Float("Rotations", self, 0 ));
	
	newInput(4, nodeValue_Color("Blends", self, 0 ));
	
	newInput(5, nodeValue_Float("Alpha", self, 0 ));
	
	newInput(6, nodeValue_Vec2("Velocity", self, [0, 0] ));
		
	outputs[0] = nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone );
	
	static update = function(frame = CURRENT_FRAME) {
		var objs = getInputData(0);
		outputs[0].setValue(objs);
		
		var _pos = getInputData(1);
		var _sca = getInputData(2);
		var _rot = getInputData(3);
		var _col = getInputData(4);
		var _alp = getInputData(5);
		var _vel = getInputData(6);
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(obj == noone || !instance_exists(obj)) continue;
			if(is_undefined(obj.phy_active)) continue;
			
			if(is_array(_pos) && array_length(_pos)) {
				if(is_array(_pos[0])) {
					obj.x = _pos[i][0];
					obj.y = _pos[i][1];
				} else {
					obj.x = _pos[0];
					obj.y = _pos[1];
				}
			}
			
			if(is_array(_sca) && array_length(_sca)) {
				if(is_array(_sca[0])) {
					obj.xscale = _sca[i][0];
					obj.yscale = _sca[i][1];
				} else {
					obj.xscale = _sca[0];
					obj.yscale = _sca[1];
				}
			}
			
			if(is_array(_rot) && array_length(_rot) > i)
				obj.image_angle = _rot[i];
			
			if(is_array(_col) && array_length(_col) > i)
				obj.image_blend = _col[i];
			
			if(is_array(_alp) && array_length(_alp) > i)
				obj.image_alpha = _alp[i];
			
			if(is_array(_vel) && array_length(_vel) > i && is_array(_vel[i])) {
				obj.phy_linear_velocity_x = _vel[i][0];
				obj.phy_linear_velocity_y = _vel[i][1];
			}
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}