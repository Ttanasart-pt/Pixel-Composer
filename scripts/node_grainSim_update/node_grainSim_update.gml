function Node_GrainSim_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Update";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	////- =Domain
	newInput( 0, nodeValue_Struct( "Domain" )).setCustomData(global.GRAINSIM_JUNC);
	
	////- =Update
	newInput( 1, nodeValue_Int( "Iteration", 16 ));
	// 2
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [
		[ "Domain", false ],  0, 
		[ "Update", false ],  1, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _domain = inputs[ 0].getValue();
			var _itr    = inputs[ 1].getValue();
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		if(IS_PLAYING) grainSim_step(_domain.index, _itr);
		
		outputs[0].setValue(_domain);
	}

}