#macro SMOKE_DOMAIN_CHECK if(!is(_dom, smokeSim_Domain) && is_instanceof(group, Node_Smoke_Group)) _dom = group.domain; if(!is(_dom, smokeSim_Domain)) return;

function Node_Smoke_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "SmokeSim";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	ungroupable     = false;
	update_on_frame = true;
	
	manual_ungroupable	 = false;
	
	outputNode = noone;
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Surface("Collision"));
	
	newInput(2, nodeValue_Enum_Button("Material dissipation type",  1, [ "Multiply", "Subtract" ]));
	
	newInput(3, nodeValue_Float("Material dissipation", 0.02))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	newInput(4, nodeValue_Enum_Button("Velocity dissipation type",  1, [ "Multiply", "Subtract" ]));
	
	newInput(5, nodeValue_Float("Velocity dissipation", 0.00))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 0.1, 0.01 ] });
	
	newInput(6, nodeValue_Vec2("Acceleration", [ 0, 0 ]));
	
	newInput(7, nodeValue_Vec2("Material intertia", [ 1, -0.2 ]));
	
	newInput(8, nodeValue_Float("Initial pressure", 0.75))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Float("Material Maccormack weight", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(10, nodeValue_Float("Velocity Maccormack weight", 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Bool("Wrap", false));
	
	input_display_list_def = [ 
		["Domain",		false], 0, 11, 1,
		["Properties",	false], 8, 6, 7,
		["Dissipation",	false], 2, 3, 4, 5,
		["Huh?",		 true], 9, 10, 
		["Inputs",		false], 
	];
	
	custom_input_index = array_length(inputs);
	
	domain = new smokeSim_Domain(PROJECT.attributes.surface_dimension[0], PROJECT.attributes.surface_dimension[1]);
	
	if(NODE_NEW_MANUAL) {
		nodeBuild("Node_Smoke_Render_Output",  128, -32, self);
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
	}
	
	static getAnimationCacheExist = function(frame) { 
		if(outputNode == noone) return false;
		return outputNode.cacheExist(frame); 
	}
}