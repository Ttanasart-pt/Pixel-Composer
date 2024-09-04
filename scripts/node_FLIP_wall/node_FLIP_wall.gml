function Node_FLIP_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Fdomain("Domain", self, noone ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Area", self, DEF_AREA , { useShape : false }));
	
	input_display_list = [ 0, 
		["Collider",	false], 1
	]
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.fdomain, noone ));
	
	obstracle = new FLIP_Obstracle();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[1].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		var _area  = getInputData(1);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		FLIP_setSolid_rectangle(domain.domain, _area[0], _area[1], _area[2], _area[3]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_fluidSim_wall, 0, bbox);
	}
}