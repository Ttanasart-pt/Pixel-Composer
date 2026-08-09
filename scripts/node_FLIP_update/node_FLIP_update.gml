function Node_FLIP_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Update";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon();
	setDimension(96, 48);
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain( "Domain"       )).setVisible(true, true);
	newInput( 1, nodeValue_Bool(    "Update", true ));
	
	////- =Timestep
	newInput( 2, nodeValue_Bool(    "Override", false ));
	newInput( 3, nodeValue_Float(   "Timestep", .01   ));
	// 4
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone));
	
	input_display_list = [  0,  1,
		[ "Timestep", false ],  2,  3, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		var domain  = getInputData(0);
		var _active = getInputData(1);
		
		outputs[0].setValue(domain);
		
		if(!instance_exists(domain)) return;
		if(domain.domain == noone)   return;
		
		var _timeover = getInputData(2);
		var _timestep = getInputData(3);
		
		if(_timeover) domain.dt = _timestep;
		
		if(_active && IS_PLAYING) domain.step();
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}