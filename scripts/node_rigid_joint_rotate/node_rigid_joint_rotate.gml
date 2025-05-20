function Node_Rigid_Joint_Rotate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Rotate Joint";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	manual_ungroupable	 = false;
	setDimension(96, 48);
	
	worldIndex = undefined;
	worldScale = 100;
	
	newInput(0, nodeValue( "Object A", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	newInput(1, nodeValue( "Object B", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	
	////- Joint
	
	newInput(2, nodeValue_Vec2(  "Offset",         self, [ 0, 0 ]));
	newInput(3, nodeValue_Float( "Max Force",      self, 100 ));
	newInput(4, nodeValue_Float( "Max Torque",     self, 100 ));
	newInput(5, nodeValue_Float( "Breaking Force", self, 0 )).setTooltip("Amount of force to break the joint, zero for unbreakable.");
	
	// inputs 6
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone));
	
	input_display_list = [ 0, 1, 
		["Joint", false], 2, 3, 4, 5, 
	]
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _o1 = getInputData(0);
		var _o2 = getInputData(1);
		
		var _offset   = getInputData(2);
		var _maxForce = getInputData(3);
		var _maxTorue = getInputData(4);
		var _break    = getInputData(5);
		
		if(array_safe_length(_o1) != 1 || array_safe_length(_o2) != 1) return;
		
		var _p1 = _o1[0].objId;
		var _p2 = _o2[0].objId;
		
		if(IS_FIRST_FRAME) {
			var _ox = _offset[0] / worldScale;
			var _oy = _offset[1] / worldScale;
			
			gmlBox2D_Joint_Motor(worldIndex, _p1, _p2, _ox, _oy, _maxForce, _maxTorue, _break);
		}
		
		outputs[0].setValue([_o1[0], _o2[0]]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_rigid_joint_rotate, 0, bbox);
	}
}