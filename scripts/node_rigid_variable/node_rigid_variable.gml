function Node_Rigid_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Rigidbody Variable";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	previewable = false;
	node_draw_icon = s_node_rigid_variable;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, noone )
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	outputs[| 0] = nodeValue("Positions", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 1] = nodeValue("Scales", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 2] = nodeValue("Rotations", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	outputs[| 3] = nodeValue("Blends", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, 0 )
		.setVisible(false);
	
	outputs[| 4] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[| 5] = nodeValue("Velocity", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[| 6] = nodeValue("Center of mass", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var objNode = inputs[| 0].getValue();
		outputs[| 0].setValue(objNode);
		if(!variable_struct_exists(objNode, "object")) return;
		var objs = objNode.object;
		
		var _get = [];
		var _val = [];
		
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			_get[i] = false;
			var _in = outputs[| i];
			for( var j = 0; j < ds_list_size(_in.value_to); j++ )
				if(_in.value_to[| j].value_from == _in) _get[i] = true;
			
			_val[i] = [];
			if(_get[i]) _val[i] = array_create(array_length(objs));
		}
		
		for( var i = 0; i < array_length(objs); i++ ) {
			var obj = objs[i];
			if(obj == noone || !instance_exists(obj)) continue;
			if(is_undefined(obj.phy_active)) continue;
			
			if(_get[0]) _val[0][i] = [ obj.x, obj.y ];
			if(_get[1]) _val[1][i] = [ obj.xscale, obj.yscale ];
			if(_get[2]) _val[2][i] = [ obj.phy_rotation ];
			if(_get[3]) _val[3][i] = [ obj.image_blend ];
			if(_get[4]) _val[4][i] = [ obj.image_alpha ];
			if(_get[5]) _val[5][i] = [ obj.phy_linear_velocity_x, obj.phy_linear_velocity_y ];
			if(_get[6]) _val[6][i] = [ obj.phy_com_x, obj.phy_com_y ];
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			if(_get[i]) outputs[| i].setValue(_val[i]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}