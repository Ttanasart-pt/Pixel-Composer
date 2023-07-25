function Node_VFX_Spawner_Base(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Particle sprite", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4, "Frames delay between each particle spawn.");
	
	inputs[| 2] = nodeValue("Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2, "Amount of particle spawn in that frame.");
	
	inputs[| 3] = nodeValue("Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 4] = nodeValue("Spawn distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map", "Direct Data" ]);
	
	inputs[| 5] = nodeValue("Lifespan", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 20, 30 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 6] = nodeValue("Spawn direction", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 45, 135 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 7] = nodeValue("Acceleration", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 8] = nodeValue("Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0])
		.setDisplay(VALUE_DISPLAY.rotation_range);
		
	inputs[| 9] = nodeValue("Rotational speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 10] = nodeValue("Spawn scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range);
	
	inputs[| 11] = nodeValue("Scale over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 12] = nodeValue("Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 13] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 14] = nodeValue("Alpha over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 15] = nodeValue("Rotate by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make the particle rotates to follow its movement.");
	
	inputs[| 16] = nodeValue("Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst" ]);
	
	inputs[| 17] = nodeValue("Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 18] = nodeValue("Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 2] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 19] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 20] = nodeValue("Wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  0 );
	
	inputs[| 21] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 22] = nodeValue("Surface array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Whether to select image from an array in order, at random, or treat array as animation." )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Order", "Animation" ])
		.setVisible(false);
	
	inputs[| 23] = nodeValue("Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setVisible(false);
	
	inputs[| 24] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random", "Data" ]);
	
	inputs[| 25] = nodeValue("Boundary data", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setVisible(false, true);
	
	inputs[| 26] = nodeValue("On animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, ANIM_END_ACTION.loop)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Loop", "Ping pong", "Destroy" ])
		.setVisible(false);
		
	inputs[| 27] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 28] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
		
	inputs[| 29] = nodeValue("Directed from center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make particle move away from the spawn center.");
	
	inputs[| 30] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
	
	inputs[| 31] = nodeValue("Distribution data", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 32] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom_range(100000, 999999))
	
	inputs[| 33] = nodeValue("Gravity direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -90 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 34] = nodeValue("Turning", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 35] = nodeValue("Turn both directions", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply randomized 1, -1 multiplier to the turning speed." );
	
	inputs[| 36] = nodeValue("Turn scale with speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 37] = nodeValue("Collide ground", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 38] = nodeValue("Ground offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 39] = nodeValue("Bounce amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
		
	input_len = ds_list_size(inputs);
	
	input_display_list = [ 32,
		["Sprite",	   false],	0, 22, 23, 26,
		["Spawn",		true],	27, 16, 1, 2, 3, 4, 30, 31, 24, 25, 5,
		["Movement",	true],	29, 6, 18,
		["Physics",		true],	7, 19, 33, 20, 34, 35, 36, 
		["Ground",		true],	37, 38, 39, 
		["Rotation",	true],	15, 8, 9, 
		["Scale",		true],	10, 17, 11, 
		["Color",		true],	12, 28, 13, 14, 
		["Render",		true],	21
	];
	
	attributes.part_amount = 512;
	array_push(attributeEditors, ["Maximum particles", function() { return attributes.part_amount; },
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.part_amount = val; }) ]);
	
	parts = array_create(attributes.part_amount);
	parts_runner = 0;
	
	seed = 0;
	spawn_index = 0;
	scatter_index = 0;
	def_surface = -1;
	
	current_data = [];
	
	for(var i = 0; i < attributes.part_amount; i++)
		parts[i] = new __part(self);
		
	static spawn = function(_time = PROJECT.animator.current_frame, _pos = -1) {
		var _inSurf = current_data[0];
		
		if(_inSurf == 0) {
			if(!is_surface(def_surface)) 
				return;
			_inSurf = def_surface;	
		}
		
		var _spawn_amount	= current_data[ 2];
		var _amo = _spawn_amount;
		
		var _spawn_area	= current_data[ 3];
		var _distrib	= current_data[ 4];
		var _dist_map	= current_data[30];
		var _dist_data	= current_data[31];
		var _scatter	= current_data[24];
		
		var _life			= current_data[ 5];
		var _direction		= current_data[ 6];
		var _directCenter	= current_data[29];
		var _velocity		= current_data[18];
		
		var _accel	= current_data[ 7];
		var _grav	= current_data[19];
		var _gvDir	= current_data[33];
		var _wigg	= current_data[20];
		var _turn	= current_data[34];
		var _turnBi	= current_data[35];
		var _turnSc	= current_data[36];
		
		var _follow			= current_data[15];
		var _rotation		= current_data[ 8];
		var _rotation_speed	= current_data[ 9];
		var _scale			= current_data[10];
		var _size 			= current_data[17];
		var _scale_time		= current_data[11];
		
		var _color	= current_data[12];
		var _blend	= current_data[28];
		var _alpha	= current_data[13];
		var _fade	= current_data[14];
		
		var _arr_type	= current_data[22];
		var _anim_speed	= current_data[23];
		var _anim_end	= current_data[26];
		
		var _ground			= current_data[37];
		var _ground_offset	= current_data[38];
		var _ground_bounce	= current_data[39];
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		var _posDist = [];
		if(_distrib == 2)
			_posDist = get_points_from_dist(_dist_map, _amo, seed);
		
		for( var i = 0; i < _amo; i++ ) {
			random_set_seed(seed); 
			seed += 100;
			
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
					if(_distrib < 2) {
						var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_amount, seed);
						xx = sp[0];
						yy = sp[1];
					
						part.boundary_data = -1;
					} else if(_distrib == 2) {
						var sp = array_safe_get(_posDist, i);
						if(!is_array(sp)) continue;
						
						xx = _spawn_area[0] + _spawn_area[2] * (sp[0] * 2 - 1.);
						yy = _spawn_area[1] + _spawn_area[3] * (sp[1] * 2 - 1.);
					} else if(_distrib == 3) {
						sp = array_safe_get(_dist_data, spawn_index);
						if(!is_array(sp)) continue;
				
						_x = sp[0];
						_y = sp[1];
					}
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
			var _bld = _blend.eval(random(1));
			
			part.seed = irandom(99999);
			part.create(_spr, xx, yy, _lif);
			part.anim_speed = _anim_speed;
			part.anim_end = _anim_end;
				
			var _trn = random_range(_turn[0], _turn[1]);
			if(_turnBi) _trn *= choose(-1, 1);
			
			part.setPhysic(_vx, _vy, _acc, _grav, _gvDir, _wigg, _trn, _turnSc);
			part.setGround(_ground, _ground_offset, _ground_bounce);
			part.setTransform(_scx, _scy, _scale_time, _rot, _rot_spd, _follow);
			part.setDraw(_color, _bld, _alp, _fade);
			spawn_index = safe_mod(spawn_index + 1, attributes.part_amount);
			onSpawn(_time, part);
			
			parts_runner = safe_mod(parts_runner + 1, attributes.part_amount);
		}
	}
	
	static onSpawn = function(_time, part) {}
	
	static updateParticleForward = function() {}
	
	function reset() {
		spawn_index = 0;
		scatter_index = 0;
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].kill();
		}
		
		render();
		seed = inputs[| 32].getValue();
		
		var _loop	= inputs[| 21].getValue();
		if(!_loop) return;
		
		for(var i = 0; i < PROJECT.animator.frames_total; i++) {
			runVFX(i, false);
			updateParticleForward();
		}
		
		seed = inputs[| 32].getValue();
	}
	
	function checkPartPool() {
		var _part_amo = attributes.part_amount;
		var _curr_amo = array_length(parts);
		
		if(_part_amo > _curr_amo) {
			repeat(_part_amo - _curr_amo)
				array_push(parts, new __part(self));
		} else if(_part_amo < _curr_amo) {
			array_resize(parts, _part_amo);
		}
	}
	
	static runVFX = function(_time = PROJECT.animator.current_frame, _render = true) {
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
	
	static step = function() {}
	
	static inspectorStep = function() {
		var _inSurf = inputs[|  0].getValue();
		var _dist   = inputs[|  4].getValue();
		var _scatt  = inputs[| 24].getValue();
		var _dirAng = inputs[| 29].getValue();
		
		inputs[|  6].setVisible(!_dirAng);
		inputs[| 22].setVisible(false);
		inputs[| 23].setVisible(false);
		inputs[| 26].setVisible(false);
		inputs[| 25].setVisible(_scatt == 2);
		inputs[| 30].setVisible(_dist == 2, _dist == 2);
		inputs[| 31].setVisible(_dist == 3, _dist == 3);
		
		if(is_array(_inSurf)) {
			inputs[| 22].setVisible(true);
			var _type = inputs[| 22].getValue();
			if(_type == 2) {
				inputs[| 23].setVisible(true);
				inputs[| 26].setVisible(true);
			}
		}
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(onDrawOverlay != -1)
			onDrawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static onDrawOverlay = -1;
	
	static update = function(frame = PROJECT.animator.current_frame) {
		checkPartPool();
		var _spawn_type = inputs[| 16].getValue();
		if(_spawn_type == 0)	inputs[| 1].name = "Spawn delay";
		else					inputs[| 1].name = "Spawn frame";
		
		onUpdate();
	}
	
	static onUpdate = function() {}
	
	static render = function() {}
	
	static onPartCreate = function(part) {}
	static onPartStep = function(part) {}
	static onPartDestroy = function(part) {}
	
	static postDeserialize = function() {
		if(PROJECT.version < SAVE_VERSION) {
			for( var i = 37; i <= 39; i++ )
				array_insert(load_map.inputs, i, noone);
		}
	}
}