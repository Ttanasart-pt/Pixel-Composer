function Node_Smoke_Update(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Update Fluid";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	setDimension(96, 96);
	setDrawIcon(s_node_smoke_update);
	
	manual_ungroupable	 = false;
	
	////- =Domain
	newInput( 0, nodeValue_Sdomain());
	
	////- =Update
	newActiveInput(1);
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	input_display_list = [
		[ "Domain", false ], 0,
		[ "Update", false ], 1,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		if(!PROJECT.animator.is_playing) return;
		
		var _dom = inputs[0].getValue(frame);
		var _act = inputs[1].getValue(frame);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		setDrawIcon(_act? s_node_smoke_update : s_node_smoke_update_paused);
		if(_act) _dom.update();
	}
}