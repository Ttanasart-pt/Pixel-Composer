function Node_Rigid_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	is_simulation      = true;
	manual_ungroupable = false;
	output_node_type   = Node_Rigid_Render;
	
	worldIndex = undefined;
	worldScale = 100;
	dimension  = [ 1, 1 ];
	
	////- World
	
	newInput(1, nodeValue_Dimension(self));
	newInput(0, nodeValue_Vec2(     "Gravity",           self, [ 0, 10 ]));
	newInput(3, nodeValue_Rotation( "Gravity Direction", self, -90));
	newInput(4, nodeValue_Float(    "Gravity Strength",  self, 10));
	
	////- Simulation
	
	newInput(2, nodeValue_Float( "Simulation Scale", self, 50 ));
	
	// inputs 5
	
	input_display_list = [ 
		["World",      false], 1, 3, 4, 
		["Simulation", false], 2, 
	];
	
	if(NODE_NEW_MANUAL) {
		var _object = nodeBuild("Node_Rigid_Object", x,       y, self);
		var _render = nodeBuild("Node_Rigid_Render", x + 160, y, self);
		
		_render.dummy_input.setFrom(_object.outputs[0])
		
		addNode(_object);
		addNode(_render);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		dimension   = getInputData(1);
		worldScale  = getInputData(2);
		
		var _gra    = getInputData(0);
		var _gradir = getInputData(3);
		var _grastr = getInputData(4);
		
		if(IS_FIRST_FRAME) {
			if(worldIndex != undefined) 
				gmlBox2D_World_Destroy(worldIndex);
				
			worldIndex = gmlBox2D_World_Create();
		}
		
		if(worldIndex == undefined) return;
		
		var gx = lengthdir_x(_grastr, _gradir);
		var gy = lengthdir_y(_grastr, _gradir);
		
		gmlBox2D_World_Set_Gravity(worldIndex, gx, gy);
	}
}