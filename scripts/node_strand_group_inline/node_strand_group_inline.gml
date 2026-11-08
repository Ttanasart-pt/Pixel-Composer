function Node_Strand_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "StrandSim";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	
	is_simulation   = true;
	update_on_frame = true;
	
	if(NODE_NEW_MANUAL) {
		var _create = nodeBuild("Node_Strand_Create", x,       y, self);
		var _render = nodeBuild("Node_Strand_Render", x + 256, y, self);
		
		_render.inputs[1].setFrom(_create.outputs[0]);
		
		addNode(_create);
		addNode(_render);
	}
	
	////- =Gravity
	newInput( 0, nodeValue_Float(    "Strength",   1  ));
	newInput( 1, nodeValue_Rotation( "Direction", -90 ));
	
	input_display_list = [ 
		[ "Gravity", false ], 0, 1, 
	];
	
	gravity_x = 0;
	gravity_y = 0;
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _gra = getInputData(0);
			var _dir = getInputData(1);
		#endregion
	
		gravity_x = lengthdir_x(_gra, _dir);
		gravity_y = lengthdir_y(_gra, _dir);
		
	}
}