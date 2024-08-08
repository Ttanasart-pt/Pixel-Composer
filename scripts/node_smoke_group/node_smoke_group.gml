#macro FLUID_DOMAIN_CHECK if(!instance_exists(_dom) && is_instanceof(group, Node_Smoke_Group)) _dom = group.domain; if(_dom == noone || !instance_exists(_dom)) return;

function Node_Smoke_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "SmokeSim";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	ungroupable     = false;
	update_on_frame = true;
	
	manual_ungroupable	 = false;
	
	outputNode = noone;
	
	inputs[0] = nodeValue_Dimension(self);
	
	inputs[1] = nodeValue_Surface("Collision", self);
	
	inputs[2] = nodeValue_Enum_Button("Material dissipation type", self,  1, [ "Multiply", "Subtract" ]);
	
	inputs[3] = nodeValue_Float("Material dissipation", self, 0.02)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	inputs[4] = nodeValue_Enum_Button("Velocity dissipation type", self,  1, [ "Multiply", "Subtract" ]);
	
	inputs[5] = nodeValue_Float("Velocity dissipation", self, 0.00)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	inputs[6] = nodeValue_Vector("Acceleration", self, [ 0, 0 ]);
	
	inputs[7] = nodeValue_Vector("Material intertia", self, [ 1, -0.2 ]);
	
	inputs[8] = nodeValue_Float("Initial pressure", self, 0.75)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[9] = nodeValue_Float("Material Maccormack weight", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[10] = nodeValue_Float("Velocity Maccormack weight", self, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[11] = nodeValue_Bool("Wrap", self, false);
	
	input_display_list_def = [ 
		["Domain",		false], 0, 11, 1,
		["Properties",	false], 8, 6, 7,
		["Dissipation",	false], 2, 3, 4, 5,
		["Huh?",		 true], 9, 10, 
		["Inputs",		false], 
	];
	
	custom_input_index = array_length(inputs);
	
	domain = fd_rectangle_create(PROJECT.attributes.surface_dimension[0], PROJECT.attributes.surface_dimension[1]);
	
	if(NODE_NEW_MANUAL) {
		var _render = nodeBuild("Node_Smoke_Render_Output",  128, -32, self);
	}
	
	static update = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(node.cacheExist()) node.cachedPropagate();
		}
		
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
			fd_rectangle_clear(domain);
			fd_rectangle_destroy(domain);
			domain = fd_rectangle_create(_dim[0], _dim[1]);
			
			fd_rectangle_set_visualization_shader(domain, FD_VISUALIZATION_SHADER.COLORIZE);
			fd_rectangle_set_material_type(domain, FD_MATERIAL_TYPE.A_16);
			fd_rectangle_set_velocity_time_step(domain, 1);
			fd_rectangle_set_material_time_step(domain, 1);
			
	        fd_rectangle_set_pressure_iteration_type(domain, -2);
			fd_rectangle_set_initial_value_pressure(domain, inPress);
		}
		
		surface_set_target(domain.sf_world);
			draw_clear_alpha($00FFFF, 0);
			if(is_surface(coll)) draw_surface_stretched_safe(coll, 0, 0, _dim[0], _dim[1]);
		surface_reset_target();
		
		fd_rectangle_set_material_dissipation_type(domain, mdisTyp);
		fd_rectangle_set_material_dissipation_value(domain, mdis);
		
		fd_rectangle_set_velocity_dissipation_type(domain, vdisTyp);
		fd_rectangle_set_velocity_dissipation_value(domain, vdis);
			
		fd_rectangle_set_acceleration(domain, acc[0], acc[1], matInr[0], matInr[1]);
		
		fd_rectangle_set_velocity_maccormack_weight(domain, vMac);
	    fd_rectangle_set_material_maccormack_weight(domain, mMac);
		
		fd_rectangle_set_repeat(domain, wrap);
	}
	
	static getAnimationCacheExist = function(frame) { 
		if(outputNode == noone) return false;
		return outputNode.cacheExist(frame); 
	}
}