function Node_Smoke_Domain(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	manual_ungroupable	 = false;
	
	////- =Domain
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface(     "Collision"    ));
	newInput(11, nodeValue_Enum_Scroll( "Boundary",  0, [ "Free", "Wall", "Wrap" ]));
	newInput(12, nodeValue_Float(       "Timestep",  1 ));
	
	////- =Properties
	newInput( 8, nodeValue_Slider( "Initial pressure",   .75     ));
	newInput( 6, nodeValue_Vec2(   "Acceleration",       [0,0]   ));
	newInput( 7, nodeValue_Vec2(   "Material intertia",  [1,-.2] ));
	
	////- =Dissipation
	newInput( 3, nodeValue_Slider( "Material dissipation", 0.02, [ 0, 0.1, 0.01 ] ));
	newInput( 5, nodeValue_Slider( "Velocity dissipation", 0.00, [ 0, 0.1, 0.01 ] ));
	
	////- =Advance
	newInput( 2, nodeValue_Enum_Button( "Material dissipation type",  1, [ "Multiply", "Subtract" ] ));
	newInput( 4, nodeValue_Enum_Button( "Velocity dissipation type",  1, [ "Multiply", "Subtract" ] ));
	newInput( 9, nodeValue_Slider(      "Material Maccormack weight", 1 ));
	newInput(10, nodeValue_Slider(      "Velocity Maccormack weight", 0 ));
	// input 13 
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output( "Domain",   VALUE_TYPE.sdomain, noone ));
	newOutput(1, nodeValue_Output( "Velocity", VALUE_TYPE.surface, noone )).setVisible(false);
	newOutput(2, nodeValue_Output( "Pressure", VALUE_TYPE.surface, noone )).setVisible(false);
	
	input_display_list = [ 
		["Domain",			false], 0, 1, 11, 12, 
		["Properties",		false], 8, 6, 7,
		["Dissipation",		false], 3, 5,
		["Advance Settings", true], 2, 4, 9, 10, 
	];
	
	domain   = new smokeSim_Domain(1, 1);
	_dim_old = [0, 0];
	
	static update = function(frame = CURRENT_FRAME) {
		var _dim	= getInputData( 0);
		var coll	= getInputData( 1);
		var mdisTyp = getInputData( 2);
		var mdis    = getInputData( 3);
		var vdisTyp = getInputData( 4);
		var vdis    = getInputData( 5);
		var acc     = getInputData( 6);
		var matInr  = getInputData( 7);
		var inPress = getInputData( 8);
		var mMac	= getInputData( 9);
		var vMac	= getInputData(10);
		var bound	= getInputData(11);
		var tstp	= getInputData(12);
		
		if(IS_FIRST_FRAME || !is_surface(domain.sf_world)) {
			domain.resetSize(_dim[0], _dim[1]);
			domain.initial_value_pressure  = inPress;
		}
		
		surface_set_target(domain.sf_world);
			draw_clear_alpha($00FFFF, 0);
			draw_surface_stretched_safe(coll, 0, 0, _dim[0], _dim[1]);
		surface_reset_target();
		
		domain.setAcceleration(acc[0], acc[1], matInr[0], matInr[1]);
		domain.setMaterial(mdisTyp, mdis);
		domain.setVelocity(vdisTyp, vdis);
		domain.setMaccormack(vMac, mMac);
		domain.setBoundary(bound);
		domain.time_step = tstp;
		
		outputs[0].setValue(domain);
		outputs[1].setValue(domain.sf_velocity);
		outputs[2].setValue(domain.sf_pressure);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}