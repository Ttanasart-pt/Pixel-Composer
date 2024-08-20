function Node_VFX_Spawner_Base(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	update_on_frame = true;
	
	newInput(0, nodeValue_Surface("Particle sprite", self));
	
	newInput(1, nodeValue_Int("Spawn delay", self, 4, "Frames delay between each particle spawn." ));
	
	newInput(2, nodeValue_Range("Spawn amount", self, [ 2, 2 ] , { linked : true }))
		.setTooltip("Amount of particle spawn in that frame.");
	
	newInput(3, nodeValue_Area("Spawn area", self, DEF_AREA ));
	
	newInput(4, nodeValue_Enum_Scroll("Spawn distribution", self, 0, [ "Area", "Border", "Map" ] ));
	
	newInput(5, nodeValue_Range("Lifespan", self, [ 20, 30 ] ));
	
	newInput(6, nodeValue_Rotation_Random("Spawn direction", self, [ 0, 45, 135, 0, 0 ] )); 
	
	newInput(7, nodeValue_Range("Acceleration", self, [ 0, 0 ] , { linked : true }));
	
	newInput(8, nodeValue_Rotation_Random("Orientation", self, [ 0, 0, 0, 0, 0 ] ));
		
	newInput(9, nodeValue_Range("Rotational speed", self, [ 0, 0 ] , { linked : true }));
	
	newInput(10, nodeValue_Vec2_Range("Spawn scale", self, [ 1, 1, 1, 1 ] , { linked : true }));
	
	newInput(11, nodeValue("Scale over time", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(12, nodeValue_Gradient("Color over lifetime", self, new gradientObject(cola(c_white))));
	
	newInput(13, nodeValue_Range("Alpha", self, [ 1, 1 ], { linked : true }));
	
	newInput(14, nodeValue("Alpha over time", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11));
	
	newInput(15, nodeValue_Bool("Rotate by direction", self, false, "Make the particle rotates to follow its movement."));
	
	newInput(16, nodeValue_Enum_Button("Spawn type", self,  0, [ "Stream", "Burst", "Trigger" ]));
	
	newInput(17, nodeValue_Range("Spawn size", self, [ 1, 1 ] , { linked : true }));
	
	newInput(18, nodeValue_Range("Spawn velocity", self, [ 1, 2 ] ));
	
	newInput(19, nodeValue_Range("Gravity", self, [ 0, 0 ] , { linked : true }));
	
	newInput(20, nodeValue_Vec2("Direction wiggle", self, [ 0, 0 ] , { label: [ "Amplitude", "Period" ], linkable: false, per_line: true }));
	
	newInput(21, nodeValue_Bool("Loop", self, true ));
	
	newInput(22, nodeValue_Enum_Scroll("Surface array", self, 0, [ "Random", "Order", "Animation", "Scale" ]))
		.setTooltip("Whether to select image from an array in order, at random, or treat array as animation.")
		.setVisible(false);
	
	newInput(23, nodeValue_Range("Animation speed", self, [ 1, 1 ] , { linked : true }))
		.setVisible(false);
	
	newInput(24, nodeValue_Enum_Button("Scatter", self,  1, [ "Uniform", "Random" ]));
	
	newInput(25, nodeValue_Int("Boundary data", self, []))
		.setArrayDepth(1)
		.setVisible(false, true);
	
	newInput(26, nodeValue_Enum_Button("On animation end", self,  ANIM_END_ACTION.loop, [ "Loop", "Ping pong", "Destroy" ]))
		.setVisible(false);
		
	newInput(27, nodeValue_Bool("Spawn", self, true));
	
	newInput(28, nodeValue_Gradient("Random blend", self, new gradientObject(cola(c_white))));
		
	newInput(29, nodeValue_Bool("Directed from center", self, false, "Make particle move away from the spawn center."));
	
	newInput(30, nodeValue_Surface("Distribution map", self))
	
	newInput(31, nodeValue_Surface("Atlas", self,  []))
		.setArrayDepth(1);
	
	newInput(32, nodeValue_Float("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[32].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	newInput(33, nodeValue_Rotation("Gravity direction", self, -90));
	
	newInput(34, nodeValue_Range("Turning", self, [ 0, 0 ] , { linked : true }));
	
	newInput(35, nodeValue_Bool("Turn both directions", self, false, "Apply randomized 1, -1 multiplier to the turning speed." ));
	
	newInput(36, nodeValue_Float("Turn scale with speed", self, false ));
	
	newInput(37, nodeValue_Bool("Collide ground", self, false ));
	
	newInput(38, nodeValue_Float("Ground offset", self, 0 ));
	
	newInput(39, nodeValue_Float("Bounce amount", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(40, nodeValue_Float("Bounce friction", self, 0.1, "Apply horizontal friction once particle stop bouncing." ))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(41, nodeValue_Vec2("Position wiggle", self, [ 0, 0 ] , { label: [ "Amplitude", "Period" ], linkable: false, per_line: true }));
		
	newInput(42, nodeValue_Vec2("Rotation wiggle", self, [ 0, 0 ] , { label: [ "Amplitude", "Period" ], linkable: false, per_line: true }));
		
	newInput(43, nodeValue_Vec2("Scale wiggle", self, [ 0, 0 ] , { label: [ "Amplitude", "Period" ], linkable: false, per_line: true }));
		
	newInput(44, nodeValue_Trigger("Spawn", self,  false ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger" });
	
	newInput(45, nodeValue_Bool("Follow Path", self, false ));
	
	newInput(46, nodeValue_PathNode("Path", self, noone ));
	
	newInput(47, nodeValue("Path Deviation", self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_11 ));
	
	newInput(48, nodeValue_Trigger("Reset Seed", self, false ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger" })
	
	newInput(49, nodeValue_Bool("Stretch Animation", self, false ));
	
	for (var i = 2, n = array_length(inputs); i < n; i++)
		inputs[i].rejectArray();
	
	input_len = array_length(inputs);
	
	input_display_list = [ 32, 48, 
		["Sprite",	   false],	0, 22, 23, 49, 26,
		["Spawn",		true],	27, 16, 44, 1, 2, 3, 4, 30, 24, 5,
		["Movement",	true],	29, 6, 18,
		["Follow path", true, 45], 46, 47, 
		["Physics",		true],	7, 19, 33, 34, 35, 36, 
		["Ground",		true, 37], 38, 39, 40, 
		["Rotation",	true],	15, 8, 9, 
		["Scale",		true],	10, 17, 11, 
		["Wiggles",		true],	20, 41, 42, 43, 
		["Color",		true],	12, 28, 13, 14, 
		["Render",		true],	21, 
	];
	
	attributes.part_amount = 512;
	array_push(attributeEditors, ["Maximum particles", function() { return attributes.part_amount; },
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.part_amount = val; }) ]);
	
	parts        = array_create(attributes.part_amount);
	parts_runner = 0;
	
	seed          = 0;
	spawn_index   = 0;
	scatter_index = 0;
	def_surface   = -1;
	
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
	curve_path_div = noone;
	
	for( var i = 0; i < attributes.part_amount; i++ )
		parts[i] = new __part(self);
		
	static spawn = function(_time = CURRENT_FRAME, _pos = -1) {
		var _inSurf     	= getInputData( 0);
		
		var _spawn_amount	= getInputData( 2);
		
		var _spawn_area 	= getInputData( 3);
		var _distrib    	= getInputData( 4);
		var _dist_map   	= getInputData(30);
		var _scatter    	= getInputData(24);
		
		var _life       	= getInputData( 5);
		var _direction  	= getInputData( 6);
		var _directCenter	= getInputData(29);
		var _velocity   	= getInputData(18);
		
		var _accel      	= getInputData( 7);
		var _grav       	= getInputData(19);
		var _gvDir      	= getInputData(33);
		var _turn       	= getInputData(34);
		var _turnBi     	= getInputData(35);
		var _turnSc     	= getInputData(36);
		
		var _follow     	= getInputData(15);
		var _rotation   	= getInputData( 8);
		var _rotation_speed	= getInputData( 9);
		var _scale      	= getInputData(10);
		var _size       	= getInputData(17);
		
		var _color      	= getInputData(12);
		var _blend      	= getInputData(28);
		var _alpha      	= getInputData(13);
		
		var _arr_type   	= getInputData(22);
		var _anim_speed 	= getInputData(23);
		var _anim_stre  	= getInputData(49);
		var _anim_end   	= getInputData(26);
		
		var _ground     	= getInputData(37);
		var _ground_offset	= getInputData(38);
		var _ground_bounce	= getInputData(39);
		var _ground_frict	= getInputData(40);
		
		var _path       	= getInputData(46);
		
		var _posDist = [];
		
		if(array_empty(_inSurf)) return;
		
		random_set_seed(seed); seed++;
		var _amo = irandom_range(_spawn_amount[0], _spawn_amount[1]);
		if(_distrib == 2) _posDist = get_points_from_dist(_dist_map, _amo, seed);
		
		for( var i = 0; i < _amo; i++ ) {
			parts_runner = clamp(parts_runner, 0, array_length(parts) - 1);
			var part = parts[parts_runner];
			
			part.reset();
			
			var _spr = _inSurf, _index = 0;
			if(is_array(_inSurf)) {
				switch(_arr_type) {
					case 0 : 	
						_index = irandom(array_length(_inSurf) - 1);
						_spr = _inSurf[_index];						
						break;
					case 1 : 
						_index = safe_mod(spawn_index, array_length(_inSurf));
						_spr = _inSurf[_index];
						break;
					case 2 : 
					case 3 : 
						_spr = _inSurf;
						break;
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
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _amo);
					xx = sp[0];
					yy = sp[1];
				} else if(_distrib == 2) {
					var sp = array_safe_get_fast(_posDist, i);
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
			part.anim_stre  = _anim_stre;
			part.anim_end   = _anim_end;
			part.arr_type   = _arr_type;
				
			var _trn = random_range(_turn[0], _turn[1]);
			if(_turnBi) _trn *= choose(-1, 1);
			
			var _gravity = random_range(_grav[0], _grav[1]);
			
			part.setPhysic(_vx, _vy, _acc, _gravity, _gvDir, _trn, _turnSc);
			part.setWiggle(wiggle_maps);
			part.setGround(_ground, _ground_offset, _ground_bounce, _ground_frict);
			part.setTransform(_scx, _scy, curve_scale, _rot, _rot_spd, _follow);
			part.setDraw(_color, _bld, _alp, curve_alpha);
			part.setPath(_path, curve_path_div);
			
			spawn_index = safe_mod(spawn_index + 1, attributes.part_amount);
			onSpawn(_time, part);
			
			parts_runner = safe_mod(parts_runner + 1, attributes.part_amount);
		}
	}
	
	static onSpawn = function(_time, part) {}
	
	static updateParticleForward = function() {}
	
	static getSurfaceCache = function() {
		var surfs = getInputData(0);
		
		if(array_empty(surfs)) return;
		if(!is_array(surfs)) surfs = [ surfs ];
		surfs = array_spread(surfs);
		
		for( var i = 0, n = array_length(surfs); i < n; i++ ) {
			var _s = surfs[i];
			
			if(surface_exists(surface_cache[$ _s])) 
				continue;
				
			if(is_instanceof(_s, SurfaceAtlas))
				_s = _s.surface.get();
				
			if(!surface_exists(_s))
				continue;
			
			surface_cache[$ surfs[i]] = surface_clone(_s);
		}
	}
	
	function reset() {
		getInputs(0);
		
		var keys = variable_struct_get_names(surface_cache);
		for( var i = 0, n = array_length(keys); i < n; i++ )
			surface_free_safe(surface_cache[$ keys[i]]);
		surface_cache = {};
		getSurfaceCache();
		
		spawn_index   = 0;
		scatter_index = 0;
		
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].kill(false);
		}
		
		#region ----- precomputes -----
			resetSeed();
			
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
			var _curve_pth = getInputData(47);
		
			curve_scale    = new curveMap(_curve_sca, TOTAL_FRAMES);
			curve_alpha    = new curveMap(_curve_alp, TOTAL_FRAMES);
			curve_path_div = new curveMap(_curve_pth, TOTAL_FRAMES);
		#endregion
		
		render();
	}
	
	static resetSeed = function() {
		seed = getInputData(32);
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
	
	static runVFX = function(_time = CURRENT_FRAME, _render = true) {
		var _spawn_delay  = inputs[1].getValue(_time);
		var _spawn_type   = inputs[16].getValue(_time);
		var _spawn_active = inputs[27].getValue(_time);
		var _spawn_trig   = inputs[44].getValue(_time);

		getInputs(_time);
		getSurfaceCache();
		
		if(_spawn_active) {
			switch(_spawn_type) {
				case 0 : if(safe_mod(_time, _spawn_delay) == 0) spawn(_time); break;
				case 1 : if(_time == _spawn_delay)				spawn(_time); break;
				case 2 : if(_spawn_trig)						spawn(_time); break;
			}
		}
		
		//print($"\n===== Running VFX {_time} =====")
		//var activeParts = 0;
		for(var i = 0; i < array_length(parts); i++) {
			//activeParts++;
			parts[i].step(_time);
		}
		
		//print($"Run VFX frame {_time} seed {seed}");
		//print($"[{display_name}] Running VFX frame {_time}: {activeParts} active particles.");
			
		if(!_render) return;
		
		render(_time);
	}
	
	static onStep = function() {}
	
	static step = function() {
		var _inSurf = getInputData(0);
		var _dist   = getInputData(4);
		var _scatt  = getInputData(24);
		var _dirAng = getInputData(29);
		var _turn   = getInputData(34);
		var _spwTyp = getInputData(16);
		var _usePth = getInputData(45);
		
		inputs[ 6].setVisible(!_dirAng);
		
		inputs[24].setVisible(_dist < 2);
		
		inputs[30].setVisible(_dist == 2, _dist == 2);
		
		inputs[35].setVisible(_turn[0] != 0 && _turn[1] != 0);
		inputs[36].setVisible(_turn[0] != 0 && _turn[1] != 0);
		
		inputs[22].setVisible(false);
		inputs[23].setVisible(false);
		inputs[26].setVisible(false);
		inputs[49].setVisible(false);
		
		inputs[46].setVisible(true, _usePth);
		
		inputs[1].setVisible(_spwTyp < 2);
		if(_spwTyp == 0)		inputs[1].name = "Spawn delay";
		else if(_spwTyp == 1)	inputs[1].name = "Spawn frame";
		
		inputs[44].setVisible(_spwTyp == 2);
		
		if(is_array(_inSurf)) {
			inputs[22].setVisible(true);
			var _type = getInputData(22);
			if(_type == 2) {
				inputs[23].setVisible(true);
				inputs[26].setVisible(true);
				inputs[49].setVisible(true);
			}
		}
		
		onStep();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _spr  = getInputData(0);
		if(array_empty(_spr)) return;
		if(is_array(_spr))
			_spr = _spr[0];
		
		var _flag = is_instanceof(_spr, SurfaceAtlas)? 0b0001 : 0b0011;
		
		inputs[3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
		if(onDrawOverlay != -1)
			onDrawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static onDrawOverlay = -1;
	
	static update = function(frame = CURRENT_FRAME) {
		var _resetSeed = getInputData(48);
		if(_resetSeed) resetSeed();
	
		checkPartPool();
		onUpdate(frame);
	}
	
	static onUpdate = function(frame = CURRENT_FRAME) {}
	
	static render = function() {}
	
	static onPartCreate  = noone;
	static onPartStep    = noone;
	static onPartDestroy = noone;
	
	static doSerialize = function(_map) {
		_map.part_base_length = input_len;
	}
	
	static postDeserialize = function() {
		var _tlen = struct_try_get(load_map, "part_base_length", 40);
		
		for( var i = _tlen; i < input_len; i++ )
			array_insert(load_map.inputs, i, noone);
	}
}