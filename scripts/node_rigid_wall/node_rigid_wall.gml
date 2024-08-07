function Node_Rigid_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	object = [];
	
	inputs[| 0] = nodeValue("Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b0010)
		.setDisplay(VALUE_DISPLAY.toggle, { data : [ "T", "B", "L", "R" ] });
		
	inputs[| 1] = nodeValue("Contact Friction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
		
	inputs[| 2] = nodeValue_Dimension(self);
	
	inputs[| 3] = nodeValue("Collision Group", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
		
	input_display_list = [ 3, 0, 2, 
		["Physics",	false],	1 
	];
	
	static drawOverlayPreview = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		return drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _dim = getInputData(2);
		
		var _x0 = _x;
		var _y0 = _y;
		var _x1 = _x0 + _dim[0] * _s;
		var _y1 = _y0 + _dim[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle(_x0, _y0, _x1, _y1, true);
		
		return inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static spawn = function(side = 0) { #region
		var _frc = getInputData(1);
		var _dim = getInputData(2);
		var _col = getInputData(3);
		
		var _dw = _dim[0] / 2;
		var _dh = _dim[1] / 2;
		var _x = 0, _y = 0, _w = 1, _h = 1;
		
		switch(side) {
			case 0 : //Top	
				_x = _dw; 
				_y = -50;
				_w = _dw; 
				_h = 50;
				break;
				
			case 1 : //Bottom	
				_x = _dw; 
				_y = _dim[1] + 50;
				_w = _dw; 
				_h = 50;
				break;
				
			case 2 : //Left
				_x = -50; 
				_y = _dh;
				_w = 50; 
				_h = _dh;
				break;
				
			case 3 : //Rgiht
				_x = _dim[0] + 50; 
				_y = _dh;
				_w = 50; 
				_h = _dh;
				break;
		}
		
		var obj = instance_create(_x, _y, oRigidbody);
		
		var _fix = physics_fixture_create();
		physics_fixture_set_box_shape(_fix, _w, _h);
		physics_fixture_set_kinematic(_fix);
		physics_fixture_set_friction(_fix, _frc);
		physics_fixture_set_collision_group(_fix, _col);
		
		array_push(obj.fixture, physics_fixture_bind(_fix, obj));
		
		return obj;
	} #endregion
	
	static update = function() { #region
		if(IS_FIRST_FRAME) reset();
	} #endregion
	
	static reset = function() { #region
		for( var i = 0, n = array_length(object); i < n; i++ ) {
			if(instance_exists(object[i]))
				instance_destroy(object[i]);
		}
		
		object = [];
		
		var _sids = getInputData(0);
		
		for( var i = 0; i < 4; i++ )
			if(_sids & (1 << i)) array_push(object, spawn(i));
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox  = drawGetBbox(xx, yy, _s);
		var _sids = getInputData(0);
		var spr   = s_rigid_walls;
		
		var ss = min(bbox.w / sprite_get_width(spr), bbox.h / sprite_get_height(spr));
		
		draw_sprite_ext(spr, 0, bbox.xc, bbox.yc, ss, ss, 0, c_white, 1);
		
		if(_sids & (1 << 0)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss, 180, c_white, 1);
		if(_sids & (1 << 1)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss,   0, c_white, 1);
		if(_sids & (1 << 2)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss, 270, c_white, 1);
		if(_sids & (1 << 3)) draw_sprite_ext(spr, 1, bbox.xc, bbox.yc, ss, ss,  90, c_white, 1);
	}
}