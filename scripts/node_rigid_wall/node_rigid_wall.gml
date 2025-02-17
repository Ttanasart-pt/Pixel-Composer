function Node_Rigid_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	object = [];
	
	newInput(0, nodeValue_Toggle("Sides", self, 0b0010, { data : [ "T", "B", "L", "R" ] }));
		
	newInput(1, nodeValue_Float("Contact Friction", self, 0.2));
		
	newInput(2, nodeValue_Dimension(self));
	
	newInput(3, nodeValue_Int("Collision Group", self, 1));
		
	input_display_list = [ 3, 0, 
		["Physics",	false],	1 
	];
	
	static drawOverlayPreview = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		return drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!is(inline_context, Node_Rigid_Group_Inline)) return;
		var _dim  = inline_context.dimension;
		var _sids = getInputData(0);
		
		draw_set_color(COLORS._main_accent);
		
		var x0 = _x, x1 = _x + _dim[0] * _s;
		var y0 = _y, y1 = _y + _dim[1] * _s;
		
		if(_sids & 0b0001) draw_line_round(x0, y0, x1, y0, 4);
		if(_sids & 0b0010) draw_line_round(x0, y1, x1, y1, 4);
		if(_sids & 0b0100) draw_line_round(x0, y0, x0, y1, 4);
		if(_sids & 0b1000) draw_line_round(x1, y0, x1, y1, 4);
		
	}
	
	static spawn = function(side = 0) {
		if(!is(inline_context, Node_Rigid_Group_Inline)) return;
		var _dim = inline_context.dimension;
		
		var _frc = getInputData(1);
		var _col = getInputData(3);
		
		var _dw = _dim[0] / 2;
		var _dh = _dim[1] / 2;
		var _x = 0, _y = 0, _w = 1, _h = 1;
		
		switch(side) {
			case 0 : //Top	
				_x = _dw;           _y = -50;
				_w = _dw;           _h =  50;
				break;
				
			case 1 : //Bottom	
				_x = _dw;           _y = _dim[1] + 50;
				_w = _dw;           _h = 50;
				break;
				
			case 2 : //Left
				_x = -50;           _y = _dh;
				_w =  50;           _h = _dh;
				break;
				
			case 3 : //Rgiht
				_x = _dim[0] + 50;  _y = _dh;
				_w = 50;            _h = _dh;
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
	}
	
	static update = function() {
		if(IS_FIRST_FRAME) reset();
	}
	
	static reset = function() {
		for( var i = 0, n = array_length(object); i < n; i++ )
			if(instance_exists(object[i])) instance_destroy(object[i]);
		
		object = [];
		
		var _sids = getInputData(0);
		
		for( var i = 0; i < 4; i++ )
			if(_sids & (1 << i)) array_push(object, spawn(i));
	}
	
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