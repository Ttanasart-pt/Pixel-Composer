function Node_Smoke_Update(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Update Fluid";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	setDimension(96, 48);
	setDrawIcon(s_node_smoke_update);
	
	manual_ungroupable	 = false;
	
	newActiveInput(1);
	
	////- =Domain
	newInput( 0, nodeValue_Sdomain());
	
	////- =Update
	newInput( 2, nodeValue_Int(  "Update Step",        1     ));
	newInput( 3, nodeValue_Bool( "Subdivide Timestep", false ));
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	input_display_list = [ 1,
		[ "Domain", false ], 0,
		[ "Update", false ], 2, 3, 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			if(!PROJECT.animator.is_playing) return;
			
			var _dom = inputs[0].getValue(frame);
			var _act = inputs[1].getValue(frame);
			
			var _stp = inputs[2].getValue(frame);
			var _sub = inputs[3].getValue(frame);
		#endregion
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		setDrawIcon(_act? s_node_smoke_update : s_node_smoke_update_paused);
		if(!_act || _stp <= 0) return;
		
		var _ts = _dom.time_step;
		if(_sub) _dom.time_step = _ts / _stp;
		
		repeat(_stp) _dom.update();
		
		_dom.time_step = _ts;
	}
}