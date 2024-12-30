function Node_Rigid_Activate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Activate Physics";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Object", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Physics activated", self, true))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone));
	
	input_display_list = [
		["Object",		 true],	0,
		["Activate",	false],	1,
	]
	
	static update = function(frame = CURRENT_FRAME) {
		var _obj = getInputData(0);
		outputs[0].setValue(_obj);
		
		RETURN_ON_REST
			
		var _act = getInputData(1);
		
		if(!is_array(_obj)) return;
			
		for( var i = 0, n = array_length(_obj); i < n; i++ ) {
			var obj = _obj[i];
			
			if(obj == noone || !instance_exists(obj)) continue;
			if(is_undefined(obj.phy_active)) continue;
				
			obj.phy_active = _act;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _act = getInputData(1);
		draw_sprite_fit(_act? s_node_rigid_activate : s_node_rigid_deactivate, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}