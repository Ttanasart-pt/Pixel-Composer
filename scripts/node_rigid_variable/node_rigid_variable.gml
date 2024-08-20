function Node_Rigid_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rigidbody Variable";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	node_draw_icon = s_node_rigid_variable;
	
	manual_ungroupable	 = false;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone ))
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	outputs[0] = nodeValue_Output("Positions", self, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[1] = nodeValue_Output("Scales", self, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[2] = nodeValue_Output("Rotations", self, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[3] = nodeValue_Output("Blends", self, VALUE_TYPE.color, 0 )
		.setVisible(false);
	
	outputs[4] = nodeValue_Output("Alpha", self, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[5] = nodeValue_Output("Velocity", self, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[6] = nodeValue_Output("Center of mass", self, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[7] = nodeValue_Output("Velocity magnitude", self, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	static update = function(frame = CURRENT_FRAME) {
		var objs = getInputData(0);
		outputs[0].setValue(objs);
		
		var _get = [];
		var _val = [];
		
		for( var i = 0; i < array_length(outputs); i++ ) {
			_get[i] = outputs[i].visible;
			_val[i] = [];
			if(_get[i]) _val[i] = array_create(array_length(objs));
		}
		
		for( var i = 0, n = array_length(objs); i < n; i++ ) {
			var obj = objs[i];
			if(obj == noone || !instance_exists(obj)) continue;
			if(is_undefined(obj.phy_active)) continue;
			
			if(_get[0]) _val[0][i] = [ obj.x, obj.y ];
			if(_get[1]) _val[1][i] = [ obj.xscale, obj.yscale ];
			if(_get[2]) _val[2][i] = obj.image_angle;
			if(_get[3]) _val[3][i] = obj.image_blend;
			if(_get[4]) _val[4][i] = obj.image_alpha;
			if(_get[5]) _val[5][i] = [ obj.phy_linear_velocity_x, obj.phy_linear_velocity_y ];
			if(_get[6]) _val[6][i] = [ obj.phy_com_x, obj.phy_com_y ];
			if(_get[7]) _val[7][i] = point_distance(0, 0, obj.phy_linear_velocity_x, obj.phy_linear_velocity_y);
		}
		
		for( var i = 0; i < array_length(outputs); i++ )
			if(_get[i]) outputs[i].setValue(_val[i]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}