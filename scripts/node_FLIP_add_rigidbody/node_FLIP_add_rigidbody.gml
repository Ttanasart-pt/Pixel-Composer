function Node_FLIP_Add_Rigidbody(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Add Rigidbody";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Objects", self, JUNCTION_CONNECT.input, VALUE_TYPE.rigid, [] )
		.setVisible(true, true);
	
	input_display_list = [ 0, 
		["Collider",	false], 1, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	obstracle = new FLIP_Obstracle();
	index     = 0;
	toReset   = true;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _objects = getInputData(1);
		if(array_empty(_objects)) return;
		
		var _obj = _objects[0];
		
		if(IS_FIRST_FRAME || toReset) {
			index = FLIP_createObstracle(domain.domain);
			array_push(domain.obstracles, obstracle);
		}
		
		toReset = false;
		
	    if(_obj.type == RIGID_SHAPE.circle) {
			
			var _p = point_rotate(_obj.radius, _obj.radius, 0, 0, _obj.image_angle);
			var px = _obj.phy_position_x + _p[0];
			var py = _obj.phy_position_y + _p[1];
			
			obstracle.x = px;
			obstracle.y = py;
		
			FLIP_setObstracle_circle(domain.domain, index, px, py, _obj.radius);
		} else if(_obj.type == RIGID_SHAPE.box) {
			
			var _p = point_rotate(_obj.width / 2, _obj.height / 2, 0, 0, _obj.image_angle);
			var px = _obj.phy_position_x + _p[0];
			var py = _obj.phy_position_y + _p[1];
			
			obstracle.x = px;
			obstracle.y = py;
			
			FLIP_setObstracle_rectangle(domain.domain, index, px, py, _obj.width, _obj.height);
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox(s_node_fluidSim_add_collider, 0, bbox);
	} #endregion
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}