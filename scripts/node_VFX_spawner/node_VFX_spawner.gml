function Node_VFX_Spawner(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	
	inputs[| 0] = nodeValue(0, "Particle sprite", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.setDisplay(noone, "particles");
	
	inputs[| 1] = nodeValue(1, "Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	inputs[| 2] = nodeValue(2, "Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	inputs[| 3] = nodeValue(3, "Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 1].getValue(); });
	
	inputs[| 4] = nodeValue(4, "Spawn distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Area", "Border" ]);
	
	inputs[| 5] = nodeValue(5, "Lifespan", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 20, 30 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 6] = nodeValue(6, "Spawn direction", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 45, 135 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	inputs[| 7] = nodeValue(7, "Acceleration", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 8] = nodeValue(8, "Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
		
	inputs[| 9] = nodeValue(9, "Rotational speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 10] = nodeValue(10, "Spawn scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	inputs[| 11] = nodeValue(11, "Scaling speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 12] = nodeValue(12, "Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	inputs[| 13] = nodeValue(13, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	inputs[| 14] = nodeValue(14, "Alpha over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [1, 1, 1, 1]);
	
	inputs[| 15] = nodeValue(15, "Rotate by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 16] = nodeValue(16, "Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ]);
	
	inputs[| 17] = nodeValue(17, "Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 18] = nodeValue(18, "Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 2] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 19] = nodeValue(19, "Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	inputs[| 20] = nodeValue(20, "Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  0 );
	
	inputs[| 21] = nodeValue(21, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 22] = nodeValue(22, "Surface array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Order", "Animation" ])
		.setVisible(false);
	
	inputs[| 23] = nodeValue(23, "Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setVisible(false);
	
	inputs[| 24] = nodeValue(24, "Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random", "Data" ]);
	
	inputs[| 25] = nodeValue(25, "Boundary data", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setVisible(false, true);
	
	inputs[| 26] = nodeValue(26, "On animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, ANIM_END_ACTION.loop)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Loop", "Ping pong", "Destroy" ])
		.setVisible(false);
	
	input_display_list = [
		["Sprite",	   false],	0, 22, 23, 26,
		["Spawn",		true],	16, 1, 2, 3, 4, 24, 25, 5,
		["Movement",	true],	6, 18, 7,
		["Physics",		true],	19, 20,
		["Rotation",	true],	15, 8, 9, 
		["Scale",		true],	10, 17, 11, 
		["Color",		true],	12, 13, 14, 
		["Render",		true],	21
	];
	
	parts = ds_list_create();
	outputs[| 0] = nodeValue(0, "Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, parts );
	
	seed_origin = irandom(9999999);
	seed = seed_origin;
	spawn_index = 0;
	def_surface = -1;
	
	for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
		ds_list_add(parts, new __part());
		
	static spawn = function(_time = ANIMATOR.current_frame) {
		random_set_seed(seed++);
		
		var _inSurf = inputs[| 0].getValue(_time);
		
		if(_inSurf == 0) {
			if(def_surface == -1 || !surface_exists(def_surface)) { 
				def_surface = PIXEL_SURFACE;
				surface_set_target(def_surface);
				draw_clear(c_white);
				surface_reset_target();
			}
			_inSurf = def_surface;	
		}
		
		var _spawn_amount	= inputs[| 2].getValue(_time);
		var _amo = _spawn_amount;
		
		var _spawn_area		= inputs[| 3].getValue(_time);
		var _distrib		= inputs[| 4].getValue(_time);
		var _scatter		= inputs[| 24].getValue(_time);
		
		var _life			= inputs[| 5].getValue(_time);
		var _direction		= inputs[| 6].getValue(_time);
		var _velocity		= inputs[| 18].getValue(_time);
		
		var _accel			= inputs[| 7].getValue(_time);
		var _grav			= inputs[| 19].getValue(_time);
		var _wigg			= inputs[| 20].getValue(_time);
		
		var _follow			= inputs[| 15].getValue(_time);
		var _rotation		= inputs[| 8].getValue(_time);
		var _rotation_speed	= inputs[| 9].getValue(_time);
		var _scale			= inputs[| 10].getValue(_time);
		var _size 			= inputs[| 17].getValue(_time);
		var _scale_speed	= inputs[| 11].getValue(_time);
		
		var _color	= inputs[| 12].getValue(_time);
		var _alpha	= inputs[| 13].getValue(_time);
		var _fade	= inputs[| 14].getValue(_time);
		
		var _arr_type	= inputs[| 22].getValue(_time);
		var _anim_speed	= inputs[| 23].getValue(_time);
		var _anim_end	= inputs[| 26].getValue(_time);
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
			if(!parts[| i].active) {
				var _spr = _inSurf, _index = 0;
				if(is_array(_inSurf)) {
					if(_arr_type == 0) {
						_index = irandom(array_length(_inSurf) - 1);
						_spr = _inSurf[_index];						
					} else if(_arr_type == 1) {
						_index = safe_mod(spawn_index, array_length(_inSurf));
						_spr = _inSurf[_index];
					} else if(_arr_type == 2)
						_spr = _inSurf;
				}
				var xx = 0;
				var yy = 0;
				
				if(_scatter == 2) {
					var _b_data = inputs[| 25].getValue(_time);
					if(!is_array(_b_data) || array_length(_b_data) <= 0) return;
					var _b = _b_data[safe_mod(_index, array_length(_b_data))];
					if(!is_array(_b) || array_length(_b) != 4) return;
					
					xx = array_safe_get(_spawn_area, 0) - array_safe_get(_spawn_area, 2);
					yy = array_safe_get(_spawn_area, 1) - array_safe_get(_spawn_area, 3);
					
					parts[| i].boundary_data = _b;
				} else {
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_amount);
					xx = sp[0];
					yy = sp[1];
					
					parts[| i].boundary_data = -1;
				}
				
				var _lif = random_range(_life[0], _life[1]);
				
				var _rot	 = random_range(_rotation[0], _rotation[1]);
				var _rot_spd = random_range(_rotation_speed[0], _rotation_speed[1]);
				
				var _dirr	= random_range(_direction[0], _direction[1]);
				
				var _velo	= random_range(_velocity[0], _velocity[1]);
				var _vx		= lengthdir_x(_velo, _dirr);
				var _vy		= lengthdir_y(_velo, _dirr);
				var _acc	= random_range(_accel[0], _accel[1]);
				
				var _ss  = random_range(_size[0], _size[1]);
				var _scx = random_range(_scale[0], _scale[1]) * _ss;
				var _scy = random_range(_scale[2], _scale[3]) * _ss;
				
				var _alp = random_range(_alpha[0], _alpha[1]);
				
				parts[| i].create(_spr, xx, yy, _lif);
				parts[| i].anim_speed = _anim_speed;
				parts[| i].anim_end = _anim_end;
				
				parts[| i].setPhysic(_vx, _vy, _acc, _grav, _wigg);
				parts[| i].setTransform(_scx, _scy, _scale_speed[0], _scale_speed[1], _rot, _rot_spd, _follow);
				parts[| i].setDraw(_color, _alp, _fade);
				spawn_index = safe_mod(spawn_index + 1, PREF_MAP[? "part_max_amount"]);
				
				if(--_amo <= 0)
					return;
			}
		}
	}
	
	function reset() {
		spawn_index = 0;
		for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++) {
			parts[| i].kill();
		}
		render();
		seed = seed_origin;
		
		var _loop	= inputs[| 21].getValue();
		if(!_loop) return;
		
		for(var i = 0; i < ANIMATOR.frames_total; i++)
			runFrame(i);
		
		seed = seed_origin;
	}
	
	function checkPartPool() {
		var _part_amo = PREF_MAP[? "part_max_amount"];
		var _curr_amo = ds_list_size(parts);
		
		if(_part_amo > _curr_amo) {
			repeat(_part_amo - _curr_amo)
				ds_list_add(parts, new __part());
		} else if(_part_amo < _curr_amo) {
			repeat(_curr_amo - _part_amo)
				ds_list_delete(parts, 0);
		}
	}
	
	static runFrame = function(_time = ANIMATOR.current_frame) {
		var _spawn_delay = inputs[| 1].getValue(_time);
		var _spawn_type = inputs[| 16].getValue(_time);
		
		switch(_spawn_type) {
			case 0 :
				if(safe_mod(_time, _spawn_delay) == 0)
					spawn(_time);
				break;
			case 1 :
				if(_time == _spawn_delay)
					spawn(_time);
				break;
		}
			
		for(var i = 0; i < ds_list_size(parts); i++)
			parts[| i].step();
		triggerRender();
		render(_time);
	}
	
	static step = function() {
		var _inSurf = inputs[| 0].getValue();
		var _scatt  = inputs[| 24].getValue();
		var _loop	= inputs[| 21].getValue();
		
		inputs[| 22].setVisible(false);
		inputs[| 23].setVisible(false);
		inputs[| 25].setVisible(_scatt == 2);
		
		if(is_array(_inSurf)) {
			inputs[| 22].setVisible(true);
			var _type = inputs[| 22].getValue();
			if(_type == 2) {
				inputs[| 23].setVisible(true);
				inputs[| 26].setVisible(true);
			}
		}
		
		checkPartPool();
		var _spawn_type = inputs[| 16].getValue();
		if(_spawn_type == 0)	inputs[| 1].name = "Spawn delay";
		else					inputs[| 1].name = "Spawn frame";
		
		onStep();
	}
	
	static onStep = function() {
		if(!ANIMATOR.frame_progress) return;
		if(!ANIMATOR.is_playing) return;
		
		if(ANIMATOR.current_frame == 0)
			reset();
		runFrame(ANIMATOR.current_frame);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my);
		if(onDrawOverlay != -1)
			onDrawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static onDrawOverlay = -1;
	
	static update = function() {}
	static render = function() {}
}