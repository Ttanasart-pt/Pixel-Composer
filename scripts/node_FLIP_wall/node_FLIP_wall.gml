function Node_FLIP_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_AREA )
		.setDisplay(VALUE_DISPLAY.area);
	
	input_display_list = [ 0, 
		["Collider",	false], 1
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	obstracle = new FLIP_Obstracle();
	index     = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(inputs[| 1].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _area = getInputData(1);
		
		FLIP_setSolid_rectangle(domain.domain, index, _area[0], _area[1], _area[2], _area[3]);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_wall, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}