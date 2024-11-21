function Node_Smoke_Domain(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Domain";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Surface("Collision", self));
	
	newInput(2, nodeValue_Enum_Button("Material dissipation type", self,  1, [ "Multiply", "Subtract" ]));
	
	newInput(3, nodeValue_Float("Material dissipation", self, 0.02))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	newInput(4, nodeValue_Enum_Button("Velocity dissipation type", self,  1, [ "Multiply", "Subtract" ]));
	
	newInput(5, nodeValue_Float("Velocity dissipation", self, 0.00))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	newInput(6, nodeValue_Vec2("Acceleration", self, [ 0, 0 ]));
	
	newInput(7, nodeValue_Vec2("Material intertia", self, [ 1, -0.2 ]));
	
	newInput(8, nodeValue_Float("Initial pressure", self, 0.75))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Float("Material Maccormack weight", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(10, nodeValue_Float("Velocity Maccormack weight", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Bool("Wrap", self, false));
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone));
	
	newOutput(1, nodeValue_Output("Velocity", self, VALUE_TYPE.surface, noone))
		.setVisible(false);
	
	newOutput(2, nodeValue_Output("Pressure", self, VALUE_TYPE.surface, noone))
		.setVisible(false);
	
	input_display_list = [ 
		["Domain",		false], 0, 11, 1,
		["Properties",	false], 8, 6, 7,
		["Dissipation",	false], 2, 3, 4, 5,
		["Huh?",		 true], 9, 10, 
	];
	
	domain = new smokeSim_Domain(256, 256);
	_dim_old = [0, 0];
	
	static update = function(frame = CURRENT_FRAME) {
		RETURN_ON_REST
		
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
		var wrap	= getInputData(11);
		
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
		
		domain.texture_repeat = wrap;
		
		outputs[0].setValue(domain);
		outputs[1].setValue(domain.sf_velocity);
		outputs[2].setValue(domain.sf_pressure);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}