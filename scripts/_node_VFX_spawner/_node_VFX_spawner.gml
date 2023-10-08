function Node_VFX_Spawner_Base(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Particle sprite", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0 );
	
	inputs[| 1] = nodeValue("Spawn delay", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4, "Frames delay between each particle spawn." )
		.rejectArray();
	
	inputs[| 2] = nodeValue("Spawn amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 2, 2 ], "Amount of particle spawn in that frame." )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 3] = nodeValue("Spawn area", self,   JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ] )
		.setDisplay(VALUE_DISPLAY.area);
	
	inputs[| 4] = nodeValue("Spawn distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Border", "Map" ] );
	
	inputs[| 5] = nodeValue("Lifespan", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 20, 30 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 6] = nodeValue("Spawn direction", self,  JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 45, 135, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random); 
	
	inputs[| 7] = nodeValue("Acceleration", self,  JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 8] = nodeValue("Orientation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
		
	inputs[| 9] = nodeValue("Rotational speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 10] = nodeValue("Spawn scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector_range, { linked : true });
	
	inputs[| 11] = nodeValue("Scale over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11 );
	
	inputs[| 12] = nodeValue("Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 13] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 14] = nodeValue("Alpha over time", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 15] = nodeValue("Rotate by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make the particle rotates to follow its movement.");
	
	inputs[| 16] = nodeValue("Spawn type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Stream", "Burst", "Trigger" ]);
	
	inputs[| 17] = nodeValue("Spawn size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 18] = nodeValue("Spawn velocity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 2 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 19] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true })
		.rejectArray();
	
	inputs[| 20] = nodeValue("Direction wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector, { label: [ "Amplitude", "Period" ], linkable: false, per_line: true })
		.rejectArray();
	
	inputs[| 21] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
		.rejectArray();
	
	inputs[| 22] = nodeValue("Surface array", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Whether to select image from an array in order, at random, or treat array as animation." )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Order", "Animation" ])
		.setVisible(false);
	
	inputs[| 23] = nodeValue("Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true })
		.rejectArray()
		.setVisible(false);
	
	inputs[| 24] = nodeValue("Scatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Random" ]);
	
	inputs[| 25] = nodeValue("Boundary data", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setVisible(false, true);
	
	inputs[| 26] = nodeValue("On animation end", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, ANIM_END_ACTION.loop)
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Loop", "Ping pong", "Destroy" ])
		.setVisible(false);
		
	inputs[| 27] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true)
		.rejectArray();
	
	inputs[| 28] = nodeValue("Random blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
		
	inputs[| 29] = nodeValue("Directed from center", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Make particle move away from the spawn center.")
		.rejectArray();
	
	inputs[| 30] = nodeValue("Distribution map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray()
	
	inputs[| 31] = nodeValue("Atlas", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface,  [] )
		.setArrayDepth(1)
		.rejectArray();
	
	inputs[| 32] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom_range(100000, 999999))
		.rejectArray();
	
	inputs[| 33] = nodeValue("Gravity direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -90 )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 34] = nodeValue("Turning", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 35] = nodeValue("Turn both directions", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Apply randomized 1, -1 multiplier to the turning speed." )
		.rejectArray();
	
	inputs[| 36] = nodeValue("Turn scale with speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.rejectArray();
	
	inputs[| 37] = nodeValue("Collide ground", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.rejectArray();
	
	inputs[| 38] = nodeValue("Ground offset", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.rejectArray();
	
	inputs[| 39] = nodeValue("Bounce amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 40] = nodeValue("Bounce friction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1, "Apply horizontal friction once particle stop bouncing." )
		.rejectArray()
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 41] = nodeValue("Position wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector, { label: [ "Amplitude", "Period" ], linkable: false, per_line: true })
		.rejectArray();
		
	inputs[| 42] = nodeValue("Rotation wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector, { label: [ "Amplitude", "Period" ], linkable: false, per_line: true })
		.rejectArray();
		
	inputs[| 43] = nodeValue("Scale wiggle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float,  [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector, { label: [ "Amplitude", "Period" ], linkable: false, per_line: true })
		.rejectArray();
		
	triggerSpawn = function() { inputs[| 44].setAnim(true); inputs[| 44].setValue(true); };
	inputs[| 44] = nodeValue("Spawn", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger,  false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger", onClick: triggerSpawn, output: true })
		.rejectArray();
	
	input_len = ds_list_size(inputs);
	
	input_display_list = [ 32,
		["Sprite",	   false],	0, 22, 23, 26,
		["Spawn",		true],	27, 16, 44, 1, 2, 3, 4, 30, 24, 5,
		["Movement",	true],	29, 6, 18,
		["Physics",		true],	7, 19, 33, 34, 35, 36, 
		["Ground",		true],	37, 38, 39, 40, 
		["Rotation",	true],	15, 8, 9, 
		["Scale",		true],	10, 17, 11, 
		["Wiggles",		true],	20, 41, 42, 43, 
		["Color",		true],	12, 28, 13, 14, 
		["Render",		true],	21
	];
	
	attributes.part_amount = 512;
	array_push(attributeEditors, ["Maximum particles", function() { return attributes.part_amount; },
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.part_amount = val; }) ]);
	
	parts = array_create(attributes.part_amount);
	parts_runner = 0;
	
	seed = 0;
	spawn_index   = 0;
	scatter_index = 0;
	def_surface   = -1;
	
	current_data  = [];
	surface_cache = {};
	
	wiggle_maps = {
		wig_psx: new wiggleMap(seed, 1, 1000),
		wig_psy: new wiggleMap(seed, 1, 1000),
		wig_scx: new wiggleMap(seed, 1, 1000),
		wig_scy: new wiggleMap(seed, 1, 1000),
		wig_rot: new wiggleMap(seed, 1, 1000),
		wig_dir: new wiggleMap(seed, 1, 1000),
	};
	
	curve_scale = noone;
	curve_alpha = noone;
	
	for( var i = 0; i < attributes.part_amount; i++ )
		parts[i] = new __part(self);
		
	static spawn = function(_time = PROJECT.animator.current_frame, _pos = -1) { #region
		var _inSurf = current_data[ 0];
		
		var _spawn_amount	= current_data[ 2];
		
		var _spawn_area	= current_data[ 3];
		var _distrib	= current_data[ 4];
		var _dist_map	= current_data[30];
		var _scatter	= current_data[24];
		
		var _life			= current_data[ 5];
		var _direction		= current_data[ 6];
		var _directCenter	= current_data[29];
		var _velocity		= current_data[18];
		
		var _accel	= current_data[ 7];
		var _grav	= current_data[19];
		var _gvDir	= current_data[33];
		var _turn	= current_data[34];
		var _turnBi	= current_data[35];
		var _turnSc	= current_data[36];
		
		var _follow			= current_data[15];
		var _rotation		= current_data[ 8];
		var _rotation_speed	= current_data[ 9];
		var _scale			= current_data[10];
		var _size 			= current_data[17];
		
		var _color	= current_data[12];
		var _blend	= current_data[28];
		var _alpha	= current_data[13];
		
		var _arr_type	= current_data[22];
		var _anim_speed	= current_data[23];
		var _anim_end	= current_data[26];
		
		var _ground			= current_data[37];
		var _ground_offset	= current_data[38];
		var _ground_bounce	= current_data[39];
		var _ground_frict   = current_data[40];
		
		if(_rotation[1] < _rotation[0]) _rotation[1] += 360;
		
		var _posDist = [];
		
		random_set_seed(seed); 
		var _amo = irandom_range(_spawn_amount[0], _spawn_amount[1]);
		if(_distrib == 2) _posDist = get_points_from_dist(_dist_map, _amo, seed);
		
		//print($"Frame {_time}: Spawning {_amo} particles, seed {seed}, {irandom(99999999)}");
		for( var i = 0; i < _amo; i++ ) {
			seed += 100;
			random_set_seed(seed); 
			
			parts_runner = clamp(parts_runner, 0, array_length(parts) - 1);
			var part = parts[parts_runner];
			
			part.reset();
			
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
				if(is_instanceof(_spr, SurfaceAtlas)) {
					xx = _spawn_area[0] + _spr.x + _spr.w / 2;
					yy = _spawn_area[1] + _spr.y + _spr.h / 2;
					part.atlas = _spr;
				} else if(_distrib < 2) {
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _amo, seed);
					xx = sp[0];
					yy = sp[1];
				} else if(_distrib == 2) {
					var sp = array_safe_get(_posDist, i);
					if(!is_array(sp)) continue;
						
					xx = _spawn_area[0] + _spawn_area[2] * (sp[0] * 2 - 1.);
					yy = _spawn_area[1] + _spawn_area[3] * (sp[1] * 2 - 1.);
				}
			} else {
				xx = _pos[0];
				yy = _pos[1];
			}
				
			var _lif = irandom_range(_life[0], _life[1]);
				
			var _rot	 = angle_random_eval(_rotation);
			var _rot_spd = random_range(_rotation_speed[0], _rotation_speed[1]);
			
			var _dirr	= _directCenter? point_direction(_spawn_area[0], _spawn_area[1], xx, yy) : angle_random_eval(_direction);
			
			var _velo	= random_range(_velocity[0], _velocity[1]);
			var _vx		= lengthdir_x(_velo, _dirr);
			var _vy		= lengthdir_y(_velo, _dirr);
			var _acc	= random_range(_accel[0], _accel[1]);
			
			var _ss  = random_range(_size[0], _size[1]);
			var _scx = random_range(_scale[0], _scale[1]) * _ss;
			var _scy = random_range(_scale[2], _scale[3]) * _ss;
				
			var _alp = random_range(_alpha[0], _alpha[1]);
			var _bld = _blend.eval(random(1));
			
			part.seed = irandom_range(100000, 999999);
			part.create(_spr, xx, yy, _lif);
			part.anim_speed = random_range(_anim_speed[0], _anim_speed[1]);
			part.anim_end   = _anim_end;
				
			var _trn = random_range(_turn[0], _turn[1]);
			if(_turnBi) _trn *= choose(-1, 1);
			
			var _gravity = random_range(_grav[0], _grav[1]);
			
			part.setPhysic(_vx, _vy, _acc, _gravity, _gvDir, _trn, _turnSc);
			part.setWiggle(wiggle_maps);
			part.setGround(_ground, _ground_offset, _ground_bounce, _ground_frict);
			part.setTransform(_scx, _scy, curve_scale, _rot, _rot_spd, _follow);
			part.setDraw(_color, _bld, _alp, curve_alpha);
			spawn_index = safe_mod(spawn_index + 1, attributes.part_amount);
			onSpawn(_time, part);
			
			parts_runner = safe_mod(parts_runner + 1, attributes.part_amount);
		}
	} #endregion
	
	static onSpawn = function(_time, part) {}
	
	static updateParticleForward = function() {}
	
	function reset() { #region
		spawn_index = 0;
		scatter_index = 0;
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].kill();
		}
		
		render();
		seed = getInputData(32);
		
		var _wigg_pos = getInputData(41);
		var _wigg_rot = getInputData(42);
		var _wigg_sca = getInputData(43);
		var _wigg_dir = getInputData(20);
		
		wiggle_maps.wig_psx.check(_wigg_pos[0], _wigg_pos[1], seed + 10);
		wiggle_maps.wig_psy.check(_wigg_pos[0], _wigg_pos[1], seed + 20);
		wiggle_maps.wig_rot.check(_wigg_rot[0], _wigg_rot[1], seed + 30);
		wiggle_maps.wig_scx.check(_wigg_sca[0], _wigg_sca[1], seed + 40);
		wiggle_maps.wig_scy.check(_wigg_sca[0], _wigg_sca[1], seed + 50);
		wiggle_maps.wig_dir.check(_wigg_dir[0], _wigg_dir[1], seed + 60);
		
		var _curve_sca = getInputData(11);
		var _curve_alp = getInputData(14);
		
		curve_scale = new curveMap(_curve_sca, PROJECT.animator.frames_total);
		curve_alpha = new curveMap(_curve_alp, PROJECT.animator.frames_total);
		
		var keys = variable_struct_get_names(surface_cache);
		for( var i = 0, n = array_length(keys); i < n; i++ )
			surface_free_safe(surface_cache[$ keys[i]]);
		surface_cache = {};
		
		var _loop = getInputData(21);
		if(!_loop) return;
		
		for(var i = 0; i < PROJECT.animator.frames_total; i++) {
			runVFX(i, false);
			updateParticleForward();
		}
		
		seed = getInputData(32);
	} #endregion
	
	function checkPartPool() { #region
		var _part_amo = attributes.part_amount;
		var _curr_amo = array_length(parts);
		
		if(_part_amo > _curr_amo) {
			repeat(_part_amo - _curr_amo)
				array_push(parts, new __part(self));
		} else if(_part_amo < _curr_amo) {
			array_resize(parts, _part_amo);
		}
	} #endregion
	
	static runVFX = function(_time = PROJECT.animator.current_frame, _render = true) { #region
		var _spawn_delay  = inputs[| 1].getValue(_time);
		var _spawn_type   = inputs[| 16].getValue(_time);
		var _spawn_active = inputs[| 27].getValue(_time);
		var _spawn_trig   = inputs[| 44].getValue(_time);
		
		//print($"{_time} : {_spawn_trig} | {ds_list_to_array(inputs[| 44].animator.values)}");
		
		for( var i = 0; i < ds_list_size(inputs); i++ )
			current_data[i] = inputs[| i].getValue(_time);
		
		var surfs = current_data[0];
		
		if(!is_array(current_data[0])) surfs = [ surfs ];
		if(!array_empty(current_data[0])) {
			if(is_array(current_data[0]))
				surfs = array_spread(surfs);
			for( var i = 0, n = array_length(surfs); i < n; i++ ) {
				if(is_surface(surface_cache[$ surfs[i]])) continue;
				surface_cache[$ surfs[i]] = surface_clone(surfs[i]);
			}
		}
		
		//print(surface_cache);
		
		if(_spawn_active) {
			switch(_spawn_type) {
				case 0 : if(safe_mod(_time, _spawn_delay) == 0) spawn(_time); break;
				case 1 : if(_time == _spawn_delay)				spawn(_time); break;
				case 2 : if(_spawn_trig)						spawn(_time); break;
			}
		}
			
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].step();
		}
			
		if(!_render) return;
		
		render(_time);
	} #endregion
	
	static onStep = function() {}
	
	static step = function() { #region
		var _inSurf = getInputData(0);
		var _dist   = getInputData(4);
		var _scatt  = getInputData(24);
		var _dirAng = getInputData(29);
		var _turn   = getInputData(34);
		var _colGnd = getInputData(37);
		var _spwTyp = getInputData(16);
		
		inputs[|  6].setVisible(!_dirAng);
		
		inputs[| 24].setVisible(_dist < 2);
		
		inputs[| 30].setVisible(_dist == 2, _dist == 2);
		
		inputs[| 35].setVisible(_turn[0] != 0 && _turn[1] != 0);
		inputs[| 36].setVisible(_turn[0] != 0 && _turn[1] != 0);
		
		inputs[| 38].setVisible(_colGnd);
		inputs[| 39].setVisible(_colGnd);
		inputs[| 40].setVisible(_colGnd);
		
		inputs[| 22].setVisible(false);
		inputs[| 23].setVisible(false);
		inputs[| 26].setVisible(false);
		
		inputs[| 1].setVisible(_spwTyp < 2);
		if(_spwTyp == 0)		inputs[| 1].name = "Spawn delay";
		else if(_spwTyp == 1)	inputs[| 1].name = "Spawn frame";
		
		inputs[| 44].setVisible(_spwTyp == 2);
		
		if(is_array(_inSurf)) {
			inputs[| 22].setVisible(true);
			var _type = getInputData(22);
			if(_type == 2) {
				inputs[| 23].setVisible(true);
				inputs[| 26].setVisible(true);
			}
		}
		
		onStep();
	} #endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _spr  = getInputData(0);
		if(is_array(_spr)) _spr = _spr[0];
		var _flag = is_instanceof(_spr, SurfaceAtlas)? 0b0001 : 0b0011;
		
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
		if(onDrawOverlay != -1)
			onDrawOverlay(active, _x, _y, _s, _mx, _my);
	} #endregion
	
	static onDrawOverlay = -1;
	
	static update = function(frame = PROJECT.animator.current_frame) { #region
		checkPartPool();
		onUpdate();
	} #endregion
	
	static onUpdate = function() {}
	
	static render = function() {}
	
	static onPartCreate = function(part) {}
	static onPartStep = function(part) {}
	static onPartDestroy = function(part) {}
	
	static doSerialize = function(_map) { #region
		_map.part_base_length = input_len;
	} #endregion
	
	static postDeserialize = function() { #region
		var _tlen = struct_try_get(load_map, "part_base_length", 40);
		
		for( var i = _tlen; i < input_len; i++ )
			array_insert(load_map.inputs, i, noone);
	} #endregion
}