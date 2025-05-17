function Node_Rigid_Joint_Fix(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Fix Joint";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	manual_ungroupable	 = false;
	setDimension(96, 96);
	
	worldIndex = undefined;
	worldScale = 100;
	
	newInput(0, nodeValue( "Object A", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	newInput(1, nodeValue( "Object B", self, CONNECT_TYPE.input, VALUE_TYPE.rigid, noone)).setVisible(true, true);
	
	////- Joint
	
	newInput(2, nodeValue_Bool(   "Custom Anchor",  self, false)).setTooltip("Use custom anchor point. Off to use center of mass.");
	newInput(3, nodeValue_Vec2(   "Anchor",         self, [ 0, 0 ])).setTooltip("Anchor point in world scope.");
	newInput(4, nodeValue_Float(  "Stiffness",      self, 10 ));
	newInput(5, nodeValue_Slider( "Damping",        self, .5 ));
	newInput(6, nodeValue_Float(  "Breaking Force", self, 0 )).setTooltip("Amount of force to break the joint, zero for unbreakable.");
	
	newOutput(0, nodeValue_Output("Object", self, VALUE_TYPE.rigid, noone));
	
	input_display_list = [ 0, 1, 
		["Joint", false], 2, 3, 4, 5, 6, 
	]
	
	static update = function(frame = CURRENT_FRAME) {
		worldIndex = struct_try_get(inline_context, "worldIndex", undefined);
		worldScale = struct_try_get(inline_context, "worldScale", 100);
		if(worldIndex == undefined) return;
		
		var _o1 = getInputData(0);
		var _o2 = getInputData(1);
		
		var _custAnc = getInputData(2);
		var _anchor  = getInputData(3);
		var _stiff   = getInputData(4);
		var _damping = getInputData(5);
		var _break   = getInputData(6);
		
		inputs[3].setVisible(_custAnc);
		
		if(array_safe_length(_o1) != 1 || array_safe_length(_o2) != 1) return;
		
		var _p1 = _o1[0].objId;
		var _p2 = _o2[0].objId;
		var _ax = _custAnc? _anchor[0] / worldScale : -9999;
		var _ay = _custAnc? _anchor[1] / worldScale : -9999;
		
		gmlBox2D_Joint_Weld(worldIndex, _p1, _p2, _ax, _ay, _stiff, _damping, _break);
		
		outputs[0].setValue([_o1[0], _o2[0]]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_rigid_joint_fix, 0, bbox);
	}
}