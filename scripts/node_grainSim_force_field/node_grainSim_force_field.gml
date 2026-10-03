function Node_GrainSim_Force_Field(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Force Field";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput( 1, nodeValue_Bool( "Active", true ));
	
	////- =Domain
	newInput( 0, nodeValue_Struct(  "Domain"  )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	
	newInput( 2, nodeValue_EScroll( "Type",   0, [ "Stream", "Trigger" ] ));
	newInput( 3, nodeValue_Trigger( "Trigger" ));
	
	////- =Force
	newInput( 4, nodeValue_Surface( "Force Field" ));
	newInput( 5, nodeValue_Float(   "Strength", 4 ));
	// 6
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [ 1, 
		[ "Domain", false ],  0,  2,  3,  
		[ "Force",  false ],  4,  5, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	surfBuff = buffer_create(1, buffer_grow, 1);
	
	static getDimension = function() /*=>*/ {
		var _domain = inputs[0].getValue();
		return is(_domain, GrainSim_Domain)? [_domain.size, _domain.size] : PROJ_SURF;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _active = inputs[ 1].getValue();
			
			var _domain = inputs[ 0].getValue();
			var _type   = inputs[ 2].getValue();
			var _trig   = inputs[ 3].getValue();
			
			var _field  = inputs[ 4].getValue();
			var _stren  = inputs[ 5].getValue();
			
			inputs[ 3].setVisible(_type == 1);
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		outputs[0].setValue(_domain);
		
		if(!_active) return;
		if(_type == 1 && !_trig) return;
		
		var _size = _domain.size;
		temp_surface[0] = surface_verify(temp_surface[0], _size, _size, surface_rgba8unorm);
		surface_set_shader(temp_surface[0]);
			draw_surface_safe(_field, 0, 0);
		surface_reset_shader();
		
		buffer_get_surface(surfBuff, temp_surface[0], 0);
		grainSim_Force_Apply_Surface(_domain.index, _stren * 10000, buffer_get_address(surfBuff));
		
	}

}