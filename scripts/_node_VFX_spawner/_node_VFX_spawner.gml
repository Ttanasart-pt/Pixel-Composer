function Node_VFX_Spawner_Base(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	
	inputs[| 0] = nodeValue(0, "Particle sprite", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.setDisplay(noone, "particles");
	
	inputs[| 1] = nodeValue(1, "Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4, "Frames delay between each particle spawn.");
	
	inputs[| 2] = nodeValue(2, "Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2, "Amount of particle spawn in that frame.");
	
	inputs[| 3] = nodeValue(3, "Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
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
	
	inputs[| 11] = nodeValue(11, "Scale over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 12] = nodeValue(12, "Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 13] = nodeValue(13, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 14] = nodeValue(14, "Alpha over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 15] = nodeValue(15, "Rotate by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make the particle rotates to follow its movement.");
	
	inputs[| 16] = nodeValue(16, "Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ]);
	
	inputs[| 17] = nodeValue(17, "Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 18] = nodeValue(18, "Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 2] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 19] = nodeValue(19, "Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 20] = nodeValue(20, "Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  0 );
	
	inputs[| 21] = nodeValue(21, "Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 22] = nodeValue(22, "Surface array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Whether to select image from an array in order, at random, or treat array as animation." )
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
		
	inputs[| 27] = nodeValue(27, "Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 28] = nodeValue(28, "Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
		
	inputs[| 29] = nodeValue(29, "Directed from center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make particle move away from the spawn center.");
		
	input_len = ds_list_size(inputs);
	
	input_display_list = [
		["Sprite",	   false],	0, 22, 23, 26,
		["Spawn",		true],	27, 16, 1, 2, 3, 4, 24, 25, 5,
		["Movement",	true],	29, 6, 18, 7,
		["Physics",		true],	19, 20,
		["Rotation",	true],	15, 8, 9, 
		["Scale",		true],	10, 17, 11, 
		["Color",		true],	12, 28, 13, 14, 
		["Render",		true],	21
	];
	
	parts = array_create(PREF_MAP[? "part_max_amount"]);
	parts_runner = 0;
	
	seed_origin = irandom(9999999);
	seed = seed_origin;
	spawn_index = 0;
	scatter_index = 0;
	def_surface = -1;
	
	current_data = [];
	
	for(var i = 0; i < PREF_MAP[? "part_max_amount"]; i++)
		parts[i] = new __part(self);
		
	static spawn = function(_time = ANIMATOR.current_frame, _pos = -1) {
		var _inSurf = current_data[0];
		
		if(_inSurf == 0) {
			if(def_surface == -1 || !surface_exists(def_surface)) { 
				def_surface = PIXEL_SURFACE;
				surface_set_target(def_surface);
				draw_clear(c_white);
				surface_reset_target();
			}
			_inSurf = def_surface;	
		}
		
		var _spawn_amount	= current_data[ 2];
		var _amo = _spawn_amount;
		
		var _spawn_area		= current_data[ 3];
		var _distrib		= current_data[ 4];
		var _scatter		= current_data[24];
		
		var _life			= current_data[ 5];
		var _direction		= current_data[ 6];
		var _directCenter	= current_data[29];
		var _velocity		= current_data[18];
		
		var _accel			= current_data[ 7];
		var _grav			= current_data[19];
		var _wigg			= current_data[20];
		
		var _follow			= current_data[15];
		var _rotation		= current_data[ 8];
		var _rotation_speed	= current_data[ 9];
		var _scale			= current_data[10];
		var _size 			= current_data[17];
		var _scale_time		= current_data[11];
		
		var _color	= current_data[12];
		var _blend	= current_data[28];
		var _bldTyp	= inputs[| 28].getExtraData();
		var _alpha	= current_data[13];
		var _fade	= current_data[14];
		
		var _arr_type	= current_data[22];
		var _anim_speed	= current_data[23];
		var _anim_end	= current_data[26];
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		repeat(_amo) {
			random_set_seed(seed++);
			parts_runner = clamp(parts_runner, 0, array_length(parts) - 1);
			var part = parts[parts_runner];
			
			var _spr = _inSurf, _index = 0;
			if(is_array(_inSurf)) {
				if(_arr_type == 0) {
					_index = irandom(array_length(_inSurf) - 1);
					_spr = _inSurf[_index];						
				} else if(_arr_type == 1) {
					_index = safe_mod(spawn_index, array_length(_inSurf));
					_spr = _inSurf[_index];
				} else if(_arr_type == 2) {
					_spr = _inSurf;
				}
			}
			var xx = 0;
			var yy = 0;
			
			if(_pos == -1) {
				if(_scatter == 2) {
					var _b_data = current_data[25];
					if(!is_array(_b_data) || array_length(_b_data) <= 0) return;
					var _b = _b_data[safe_mod(_index, array_length(_b_data))];
					if(!is_array(_b) || array_length(_b) != 4) return;
					
					xx = array_safe_get(_spawn_area, 0) - array_safe_get(_spawn_area, 2);
					yy = array_safe_get(_spawn_area, 1) - array_safe_get(_spawn_area, 3);
					
					part.boundary_data = _b;
				} else {
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_amount, seed);
					xx = sp[0];
					yy = sp[1];
					
					part.boundary_data = -1;
				}
			} else {
				xx = _pos[0];
				yy = _pos[1];
			}
				
			var _lif = irandom_range(_life[0], _life[1]);
				
			var _rot	 = random_range(_rotation[0], _rotation[1]);
			var _rot_spd = random_range(_rotation_speed[0], _rotation_speed[1]);
			
			var _dirr	= _directCenter? point_direction(_spawn_area[0], _spawn_area[1], xx, yy) : random_range(_direction[0], _direction[1]);
			
			var _velo	= random_range(_velocity[0], _velocity[1]);
			var _vx		= lengthdir_x(_velo, _dirr);
			var _vy		= lengthdir_y(_velo, _dirr);
			var _acc	= random_range(_accel[0], _accel[1]);
			
			var _ss  = random_range(_size[0], _size[1]);
			var _scx = random_range(_scale[0], _scale[1]) * _ss;
			var _scy = random_range(_scale[2], _scale[3]) * _ss;
				
			var _alp = random_range(_alpha[0], _alpha[1]);
			var _bld = gradient_eval(_blend, random(1), ds_list_get(_bldTyp, 0));
			
			part.seed = irandom(99999);
			part.create(_spr, xx, yy, _lif);
			part.anim_speed = _anim_speed;
			part.anim_end = _anim_end;
				
			part.setPhysic(_vx, _vy, _acc, _grav, _wigg);
			part.setTransform(_scx, _scy, _scale_time, _rot, _rot_spd, _follow);
			part.setDraw(_color, _bld, _alp, _fade);
			spawn_index = safe_mod(spawn_index + 1, PREF_MAP[? "part_max_amount"]);
			onSpawn(_time, part);
			
			parts_runner = safe_mod((parts_runner + 1), PREF_MAP[? "part_max_amount"]);
		}
	}
	
	static onSpawn = function(_time, part) {}
	
	static updateParticleForward = function(_render = true) {}
	
	function reset() {
		spawn_index = 0;
		scatter_index = 0;
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].kill();
		}
		
		render();
		seed = seed_origin;
		
		var _loop	= inputs[| 21].getValue();
		if(!_loop) return;
		
		for(var i = 0; i < ANIMATOR.frames_total; i++) {
			runVFX(i, false);
			updateParticleForward(false);
		}
		
		seed = seed_origin;
	}
	
	function checkPartPool() {
		var _part_amo = PREF_MAP[? "part_max_amount"];
		var _curr_amo = array_length(parts);
		
		if(_part_amo > _curr_amo) {
			repeat(_part_amo - _curr_amo)
				array_push(parts, new __part(self));
		} else if(_part_amo < _curr_amo) {
			array_resize(parts, _part_amo);
		}
	}
	
	static runVFX = function(_time = ANIMATOR.current_frame, _render = true) {
		var _spawn_delay  = inputs[| 1].getValue(_time);
		var _spawn_type   = inputs[| 16].getValue(_time);
		var _spawn_active = inputs[| 27].getValue(_time);
		
		for( var i = 0; i < ds_list_size(inputs); i++ )
			current_data[i] = inputs[| i].getValue(_time);
		
		if(_spawn_active) {
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
		}
			
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].step();
		}
			
		if(!_render) return;
		
		triggerRender();
		render(_time);
	}
	
	static step = function() {
		var _inSurf = inputs[| 0].getValue();
		var _scatt  = inputs[| 24].getValue();
		var _dirAng = inputs[| 29].getValue();
		
		inputs[|  6].setVisible(!_dirAng);
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
		runVFX(ANIMATOR.current_frame);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(onDrawOverlay != -1)
			onDrawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static onDrawOverlay = -1;
	
	static update = function() {}
	static render = function() {}
	
	static onPartCreate = function(part) {}
	static onPartStep = function(part) {}
	static onPartDestroy = function(part) {}
}