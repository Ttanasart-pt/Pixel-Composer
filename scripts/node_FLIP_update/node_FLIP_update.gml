function Node_FLIP_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Update";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	inputs[0] = nodeValue_Fdomain("Domain", self, noone)
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Bool("Update", self, true);
	
	inputs[2] = nodeValue_Bool("Override timestep", self, false);
	
	inputs[3] = nodeValue_Float("Timestep", self, 0.01);
	
	input_display_list = [ 0, 1,
		["Timestep", false], 2, 3, 
	];
	
	outputs[0] = nodeValue_Output("Domain", self, VALUE_TYPE.fdomain, noone);
	
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
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _active = getInputData(1);
		
		draw_sprite_fit(_active? s_node_fluidSim_update : s_node_fluidSim_update_paused, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}