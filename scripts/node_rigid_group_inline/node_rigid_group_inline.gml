function Node_Rigid_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	is_simulation      = true;
	manual_ungroupable = false;
	
	input_node_types   = [ Node_Rigid_Object, Node_Rigid_Path_Collider, Node_Rigid_Fracture ];
	output_node_types  = [ Node_Rigid_Render, Node_Rigid_Render_ID, Node_Rigid_Object_Get_Collision ];
	
	worldIndex = undefined;
	worldScale = 100;
	dimension  = [ 1, 1 ];
	objects    = [];
	
	////- =World
	newInput(1, nodeValue_Dimension());
	newInput(0, nodeValue_Vec2(     "Gravity",           [0,10] ));
	newInput(3, nodeValue_Rotation( "Gravity Direction", -90    ));
	newInput(4, nodeValue_Float(    "Gravity Strength",   10    ));
	
	////- =Simulation
	newInput(2, nodeValue_Float( "Simulation Scale", 50   ));
	newInput(5, nodeValue_Bool(  "Sleepable",        true ));
	newInput(6, nodeValue_Bool(  "Continuous",       true ));
	
	////- =Wall
	newInput( 7, nodeValue_Bool(   "Use Wall",       false ));
	newInput( 8, nodeValue_Toggle( "Walls",          0b0010, { data : [ "T", "B", "L", "R" ] } ));
	newInput( 9, nodeValue_Float(  "Wall Friction",   .2   ));
	newInput(10, nodeValue_Slider( "Wall Bounciness", .2   ));
	// inputs 11
	
	input_display_list = [ 
		[ "World",      false ],  1,  3,  4, 
		[ "Simulation", false ],  2,  5,  6, 
		[ "Wall",    false, 7 ],  8,  9, 10, 
	];
	
	////- Nodes
	
	if(NODE_NEW_MANUAL) {
		var _object = nodeBuild("Node_Rigid_Object", x,       y, self);
		var _render = nodeBuild("Node_Rigid_Render", x + 160, y, self);
		
		_render.dummy_input.setFrom(_object.outputs[0])
		
		addNode(_object);
		addNode(_render);
	}
	
	static spawnWall = function(side = 0) {
		if(worldIndex == undefined) return undefined;
		
		var _dim = dimension;
		var _frc = getInputData( 9);
		var _res = getInputData(10);
		
		var ww = _dim[0] / worldScale;
		var hh = _dim[1] / worldScale;
		
		gmlBox2D_Object_Create_Begin(worldIndex, 0, 0, false);
		
		switch(side) {
			case 0 : gmlBox2D_Object_Create_Shape_Segment(  0,  0, ww,  0 ); break;
			case 1 : gmlBox2D_Object_Create_Shape_Segment(  0, hh, ww, hh ); break;
			case 2 : gmlBox2D_Object_Create_Shape_Segment(  0,  0,  0, hh ); break;
			case 3 : gmlBox2D_Object_Create_Shape_Segment( ww,  0, ww, hh ); break;
		}
		
		var objId  = gmlBox2D_Object_Create_Complete();
		var boxObj = new __Box2DObject(objId);
		
		gmlBox2D_Object_Set_Body_Type( objId,    0);
		gmlBox2D_Shape_Set_Friction(   objId, _frc);
		gmlBox2D_Shape_Set_Restitution(objId, _res);
		
		return boxObj;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		dimension   = getInputData(1);
		worldScale  = getInputData(2);
		
		var _gra    = getInputData(0);
		var _gradir = getInputData(3);
		var _grastr = getInputData(4);
		var _sleep  = getInputData(5);
		var _conti  = getInputData(6);
		
		if(IS_FIRST_FRAME) {
			if(worldIndex != undefined) 
				gmlBox2D_World_Destroy(worldIndex);
				
			worldIndex = gmlBox2D_World_Create();
			
			var _useWall = getInputData(7);
			
			if(_useWall) {
				objects = [];
				
				var _walls = getInputData(8);
				for( var i = 0; i < 4; i++ ) if(_walls & (1 << i)) array_push(objects, spawnWall(i));
			}
		}
		
		if(worldIndex == undefined) return;
		
		var gx = lengthdir_x(_grastr, _gradir);
		var gy = lengthdir_y(_grastr, _gradir);
		
		gmlBox2D_World_Set_Gravity(    worldIndex, gx, gy);
		gmlBox2D_World_Set_Sleeping(   worldIndex, _sleep);
		gmlBox2D_World_Set_Continuous( worldIndex, _conti);
	}
}