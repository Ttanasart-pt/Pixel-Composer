function Node_VFX_Spawner_Base(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Spawner";
	update_on_frame = true;
	
	newInput(32, nodeValueSeed());
	
	////- =Sprite
	newInput( 0, nodeValue_Surface("Particle Sprite"));
	
	newInput(22, nodeValue_EScroll(  "Surface Array", 0, [ "Random", "Order", "Animation", "Scale" ]))
		.setTooltip("Whether to select image from an array in order, at random, or treat array as animation.");
	
	newInput(23, nodeValue_Range(    "Animation Speed",      [1,1], { linked : true } ));
	newInput(49, nodeValue_Bool(     "Stretch Animation",    false                    ));
	newInput(26, nodeValue_EButton(  "On Animation End",     ANIM_END_ACTION.loop     )).setChoices([ "Loop", "Ping pong", "Destroy" ]);
	
	////- =Spawn
	newInput(27, nodeValue_Bool(     "Spawn",                true          ));
	newInput(16, nodeValue_EButton(  "Spawn Type",           0             )).setChoices([ "Stream", "Burst", "Trigger" ]);
	newInput(44, nodeValue_Trigger(  "Spawn"                               ));
	newInput( 1, nodeValue_Int(      "Spawn Delay",          4             )).setTooltip("Frames delay between each particle spawn.");
	newInput(51, nodeValue_Int(      "Burst Duration",       1             ));
	newInput( 2, nodeValue_Range(    "Spawn Amount",        [2,2], true    )).setTooltip("Amount of particle spawn in that frame.");
	newInput( 5, nodeValue_Range(    "Lifespan",            [20,30]        ));
	
	////- =Spawn Source
	newInput( 4, nodeValue_EScroll(  "Spawn Source",         0,            )).setChoices([ "Area Inside", "Area Border", "Map", "Path", "Direct Data" ]);
	newInput( 3, nodeValue_Area(     "Spawn Area",           DEF_AREA_REF  )).setHotkey("A").setUnitSimple();
	newInput(30, nodeValue_Surface(  "Distribution Map"                    ));
	newInput(55, nodeValue_PathNode( "Spawn Path"                          ));
	newInput(62, nodeValue_Vector(   "Spawn Data"                          )).setArrayDepth(1);
	newInput(24, nodeValue_EButton(  "Distribution",         1             )).setChoices([ "Uniform", "Random" ]);
	newInput(52, nodeValue_Float(    "Uniform Period",       4             ));
	
	////- =Movement
	newInput(64, nodeValue_EButton(  "Direction Type",              0, [ "Random", "Uniform" ] ));
	newInput( 6, nodeValue_RotRand(  "Initial Direction",          [0,45,135,0,0]     )); 
	newInput(18, nodeValue_Range(    "Speed",                      [1,2]              )).setCurvable(60, CURVE_DEF_11, "Over Lifespan");
	inputs[60].setTooltip("Speed may conflict with physics-based properties.");
	
	newInput(29, nodeValue_Bool(     "Directed From Center",       false              )).setTooltip("Make particle move away from the spawn center.");
	newInput(53, nodeValue_RotRange( "Angle Range",                [0,360]            ));
	newInput(67, nodeValue_Toggle(   "Wrap",                       0, [ "X", "Y" ]    ))
	
	////- =Rotation
	newInput(15, nodeValue_Bool(     "Rotate by Direction",        false              )).setTooltip("Make the particle rotates to follow its movement.");
	newInput( 8, nodeValue_RotRand(  "Initial Rotation",           [0,0,0,0,0]        ));
	newInput( 9, nodeValue_RotRand(  "Rotational Speed",           [0,0,0,0,0]        )).setCurvable(59, CURVE_DEF_11, "Over Lifespan");
	newInput(61, nodeValue_Float(    "Snap Rotation",              0                  ));
	
	////- =Scale
	newInput(10, nodeValue_Vec2_Range( "Scale",        [1,1,1,1], { linked : true }  ));
	newInput(17, nodeValue_Range(      "Size",         [1,1],     { linked : true }  )).setCurvable(11, CURVE_DEF_11, "Over Lifespan");
	
	////- =Color
	newInput(28, nodeValue_Gradient(  "Color on Spawn",         gra_white  ));
	newInput(50, nodeValue_Palette(   "Color by Index",         [ca_white]                    )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(12, nodeValue_Gradient(  "Color Over Lifetime",    gra_white  ));
	newInput(13, nodeValue_Range(     "Alpha",                  [1,1], { linked : true }      )).setCurvable(14, CURVE_DEF_11, "Over Lifespan");
	newInput(56, nodeValue_Surface(   "Sample Surface"                                        ));
	
	////- =Path
	newInput(45, nodeValue_Bool(       "Follow Path",          false                         ));
	newInput(46, nodeValue_PathNode(   "Path"                                                ));
	newInput(66, nodeValue_Vec2_Range( "Path Range",           [0,0,1,1]                     ));
	newInput(47, nodeValue_Curve(      "Path Deviation",       CURVE_DEF_11                  ));
	
	////- =Physics
	newInput(57, nodeValue_Bool(     "Use Physics",            false                         ));
	newInput(54, nodeValue_Range(    "Friction",               [0,0], { linked : true }      ));
	newInput( 7, nodeValue_Range(    "Acceleration",           [0,0], { linked : true }      ));
	newInput(19, nodeValue_Range(    "Gravity",                [0,0], { linked : true }      ));
	newInput(33, nodeValue_Rotation( "Gravity Direction",      -90                           ));
	
	newInput(34, nodeValue_Range(    "Turning",                [0,0], { linked : true }      ));
	newInput(35, nodeValue_Bool(     "Turn Both Directions",   false                         )).setTooltip("Apply randomized 1, -1 multiplier to the turning speed.");
	newInput(36, nodeValue_Float(    "Turn Scale with Speed",  false                         ));
	
	////- =Ground
	newInput(37, nodeValue_Bool(        "Collide Ground",      false                         ));
	newInput(63, nodeValue_EButton( "Ground Offset Type",  0, [ "Relative", "Absolute" ] ));
	newInput(38, nodeValue_Range(       "Ground Offset",       [0,0], { linked : true }      ));
	newInput(39, nodeValue_Slider(      "Bounce Amount",       .5                            ));
	newInput(40, nodeValue_Slider(      "Bounce Friction",     .1                            )).setTooltip("Apply horizontal friction once particle stop bouncing.");
		
	////- =Wiggles
	newInput(58, nodeValue_Bool(     "Use Wiggles",            false ));
	newInput(20, nodeValue_Vec2(     "Direction Wiggle",       [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(41, nodeValue_Vec2(     "Position Wiggle",        [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(42, nodeValue_Vec2(     "Rotation Wiggle",        [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(43, nodeValue_Vec2(     "Scale Wiggle",           [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	
	////- =Unused
	newInput(21, nodeValue_Bool(     "Loop",                   true ));
	newInput(65, nodeValue_Int(      "Pre-Render",             -1   ));
	newInput(25, nodeValue_Int(      "Boundary Data",          []   )).setArrayDepth(1).setVisible(false, true);
	newInput(31, nodeValue_Surface(  "Atlas",                  []   )).setArrayDepth(1);
	newInput(48, nodeValue_Trigger(  "Reset Seed"                   ))
	// inputs 68
	
	array_foreach(inputs, function(inp, i) /*=>*/ { 
		if(i == 6 || i == 8) return; 
		if(inp.type == VALUE_TYPE.gradient) return; 
		
		inp.rejectArray(); 
	}, 1);
	
	input_len = array_length(inputs);
	
	dynaDraw_parameter = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_empty(custom_parameter_names)) return 0;
		
		var _hh =  0;
		
		for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
			var _n = custom_parameter_names[i];
			
			var _wig = custom_parameter_curves_view[$ _n];
			var _dat = attributes.parameter_curves[$ _n];
			if(_wig == undefined || _dat == undefined) continue;
			
			var _txt = string_title(_n) + " Over Lifespan";
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x, _y, _txt);
			
			var _th = string_height(_txt) + ui(8);
			_y  += _th;
			_hh += _th;
			
			_wig.setFocusHover(_focus, _hover);
			var _hg = _wig.drawParam(new widgetParam(_x, _y, _w, 0, _dat, {}, _m, dynaDraw_parameter.rx, dynaDraw_parameter.ry).setFont(f_p2));
			
			_y  += _hg + ui(8);
			_hh += _hg + ui(8);
		}
		
		_hh -= ui(8);
		return _hh;
	});
	
	input_display_list = [ 32, 
		[ "Sprite",       true ],  0, dynaDraw_parameter, 22, 23, 49, 26,
		[ "Spawn",        true ], 27, 16, 44,  1, 51,  2, __inspc(ui(6), true),  5, 
		[ "Spawn Source", true ],  4,  3, 30, 55, 62, 24, 52, 
		[ "Movement",     true ], 64,  6, 18, 60, 29, 53, 67, 
		[ "Rotation",     true ], 15,  8,  9, 59, 61, 
		[ "Scale",        true ], 10, 17, 11, 
		[ "Color",        true ], 28, 50, 12, 13, 14, 56, 
		__inspc(ui(6), true, false, ui(3)), 
		
		[ "Follow path", true, 45 ], 46, 66, 47, 
		[ "Physics",     true, 57 ], 54,  7, 19, 33, 34, 35, 36, 
		[ "Ground",      true, 37 ], 38, 63, 39, 40, 
		[ "Wiggles",     true, 58 ], 20, 41, 42, 43, 
		
	];
	
	////- Nodes
	
	attributes.part_amount = 512;
	array_push(attributeEditors, Node_Attribute( "Maximum particles", function() /*=>*/ {return attributes.part_amount}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("part_amount", v)})} ));
	
	_self = self;
	parts = array_create_ext(attributes.part_amount, function() /*=>*/ {return new __part(_self)});
	
	parts_runner    = 0;
	seed            = 0;
	spawn_index_raw = 0;
	spawn_index     = 0;
	scatter_index   = 0;
	def_surface     = -1;
	surface_cache   = {};
	
	wiggle_maps = {
		wig_psx: new wiggleMap(seed, 1, 1000),
		wig_psy: new wiggleMap(seed, 1, 1000),
		wig_scx: new wiggleMap(seed, 1, 1000),
		wig_scy: new wiggleMap(seed, 1, 1000),
		wig_rot: new wiggleMap(seed, 1, 1000),
		wig_dir: new wiggleMap(seed, 1, 1000),
	};
	
	curve_speed    = noone;
	curve_rotate   = noone;
	curve_scale    = noone;
	curve_alpha    = noone;
	curve_path_div = noone;
	
	custom_parameter_names       = [];
	custom_parameter_curves_view = {};
	custom_parameter_map         = {};
	attributes.parameter_curves  = {};
	
	surfSamp = new Surface_sampler();
	
	////- VFX
	
	static spawn = function(_time = NODE_CURRENT_FRAME, _pos = -1) {
		var _inSurf     	= getInputData( 0);
		var _arr_type   	= getInputData(22);
		var _anim_speed 	= getInputData(23);
		var _anim_stre  	= getInputData(49);
		var _anim_end   	= getInputData(26);
		
		var _spawn_amount	= getInputData( 2);
		var _spawn_area 	= inputs[3].getValue();
		var _distrib    	= getInputData( 4);
		var _dist_map   	= getInputData(30);
		var _dist_path   	= getInputData(55);
		var _dist_data      = getInputData(62);
		var _scatter    	= getInputData(24);
		var _spawn_period   = getInputData(52);
		
		var _life       	= getInputData( 5);
		var _directionType  = getInputData(64);
		var _direction  	= getInputData( 6);
		var _directCenter	= getInputData(29);
		var _directRange	= getInputData(53);
		var _warp           = getInputData(67);
		var _velocity   	= getInputData(18);
		
		var _rotation   	= getInputData( 8);
		var _rotation_speed	= getInputData( 9);
		var _rotation_snap	= getInputData(61);
		var _scale      	= getInputData(10);
		var _size       	= getInputData(17);
		var _follow     	= getInputData(15);
		
		var _color      	= getInputData(12);
		var _blend      	= getInputData(28);
		var _color_idx   	= getInputData(50), _color_idx_len  = array_length(_color_idx), _color_idx_typ = inputs[50].attributes.array_select;
		var _alpha      	= getInputData(13);
		
		//////////////////////////////////////////////////////////////////////////////
		
		var _path       	= getInputData(46);
		var _pathRange      = getInputData(66);
		
		var _use_phy     	= getInputData(57);
		var _accel      	= getInputData( 7);
		var _grav       	= getInputData(19);
		var _gvDir      	= getInputData(33);
		var _turn       	= getInputData(34);
		var _turnBi     	= getInputData(35);
		var _turnSc     	= getInputData(36);
		var _friction     	= getInputData(54);
		
		var _ground         = getInputData(37);
		var _ground_offtyp  = getInputData(63);
		var _ground_offset  = getInputData(38);
		var _ground_bounce  = getInputData(39);
		var _ground_frict   = getInputData(40);
		
		var _use_wig     	= getInputData(58);
		
		//////////////////////////////////////////////////////////////////////////////
		
		var _posDist = [];
		
		if(array_empty(_inSurf)) return;
		
		random_set_seed(seed); seed += 1000;
		var _amo = irandom_range(_spawn_amount[0], _spawn_amount[1]);
		
		if(_distrib == 2) _posDist = get_points_from_dist(_dist_map, _amo, seed);
		if(_distrib == 4) _amo     = array_length(_dist_data);
		
		for( var i = 0; i < _amo; i++ ) {
			parts_runner = clamp(parts_runner, 0, array_length(parts) - 1);
			var part = parts[parts_runner];
			
			part.reset();
			
			var _spr = _inSurf, _index = 0;
			if(is_array(_inSurf)) switch(_arr_type) {
				case 0 : 	
					_index = irandom(array_length(_inSurf) - 1);
					_spr = _inSurf[_index];						
					break;
					
				case 1 : 
					_index = safe_mod(spawn_index, array_length(_inSurf));
					_spr = _inSurf[_index];
					break;
					
				case 2 : case 3 : 
					_spr = _inSurf;
					break;
			}
			
			var xx = 0;
			var yy = 0;
			
			if(_pos == -1) {
				if(is(_spr, SurfaceAtlas)) {
					xx = _spawn_area[0] + _spr.x + _spr.w / 2;
					yy = _spawn_area[1] + _spr.y + _spr.h / 2;
					part.atlas = _spr;
					
				} else if(_distrib < 2) {
					var sp = area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_period);
					xx = sp[0];
					yy = sp[1];
					
				} else if(_distrib == 2) {
					var sp = array_safe_get_fast(_posDist, i);
					if(!is_array(sp)) continue;
						
					xx = _spawn_area[0] + _spawn_area[2] * (sp[0] * 2 - 1.);
					yy = _spawn_area[1] + _spawn_area[3] * (sp[1] * 2 - 1.);
					
				} else if(_distrib == 3) {
					if(_dist_path == noone) continue;
					
					var _pathProg = _scatter == 0? (spawn_index % _spawn_period) / (_spawn_period - 1) : random(1);
					var _p = _dist_path.getPointRatio(_pathProg, 0);
					
					xx = _p.x;
					yy = _p.y;
					
				} else if(_distrib == 4) {
					var _p = _dist_data[i];
					
					xx = _p[0];
					yy = _p[1];
				}
				
			} else {
				xx = _pos[0];
				yy = _pos[1];
			}
				
			var _lif      = irandom_range(_life[0], _life[1]);
				
			var _rot	  = rotation_random_eval(is_array(_rotation[0])? _rotation[i] : _rotation);
			var _rot_spd  = rotation_random_eval(_rotation_speed);
			var _rot_snap = _rotation_snap;
			
			var _dirs     = is_array(_direction[0])? _direction[i] : _direction;
			var _dirr	  = _directionType == 0? rotation_random_eval(_dirs) : rotation_random_eval_uniform(_dirs, i / (_amo - 1));
			if(_directCenter) {
				var _pointDir = point_direction(_spawn_area[0], _spawn_area[1], xx, yy);
				    _pointDir = lerp(_directRange[0], _directRange[1], _pointDir / 360);
				_dirr += _pointDir;
			}
			
			var _velo = random_range(_velocity[0], _velocity[1]);
			var _vx   = lengthdir_x(_velo, _dirr);
			var _vy   = lengthdir_y(_velo, _dirr);
			var _acc  = random_range(_accel[0], _accel[1]);
			var _frc  = random_range(_friction[0], _friction[1]);
			
			var _ss   = random_range(_size[0], _size[1]);
			var _scx  = random_range(_scale[0], _scale[1]) * _ss;
			var _scy  = random_range(_scale[2], _scale[3]) * _ss;
				
			var _alp  = random_range(_alpha[0], _alpha[1]);
			var _bld  = _blend.eval(random(1));
			
			var clti  = spawn_index;
			switch(_color_idx_typ) {
				case 0  : clti = spawn_index % _color_idx_len;                break;
				case 1  : clti = pingpong_value(spawn_index, _color_idx_len); break;
				case 2  : clti = irandom(_color_idx_len - 1);                 break;
			}
			
			var _clr_ind  = array_safe_get(_color_idx, clti, ca_white);
			    _bld      = colorMultiply(_bld, _clr_ind);
			
			if(surfSamp.active) {
				var _samC = surfSamp.getPixel(xx, yy);
					_bld  = colorMultiply(_bld, _samC);
			}
			
			var _path_range = [ random_range(_pathRange[0], _pathRange[1]), random_range(_pathRange[2], _pathRange[3]) ];
			
			part.create(_spr, xx, yy, _lif, _warp & 0b01, _warp & 0b10);
			part.seed = irandom_range(100000, 999999);
			
			part.setSpriteAnimation(random_range(_anim_speed[0], _anim_speed[1]), _anim_stre, _anim_end, _arr_type);
				
			var _trn = random_range(_turn[0], _turn[1]);
			if(_turnBi) _trn *= choose(-1, 1);
			
			var _gravity = random_range(_grav[0], _grav[1]);
			
			part.setTransform( _scx, _scy, curve_scale, _rot, _rot_spd, curve_rotate, _rot_snap, _follow );
			part.setDraw(   _color, _bld, _alp, curve_alpha );
			part.setPath(   _path, _path_range, curve_path_div );
			part.setPhysic( _use_phy, _vx, _vy, curve_speed, _acc, _frc, _gravity, _gvDir, _trn, _turnSc );
			
			var __ground_offset = random_range(_ground_offset[0], _ground_offset[1]);
			part.setGround( _ground, _ground_offtyp, __ground_offset, _ground_bounce, _ground_frict );
			
			part.setWiggle( _use_wig, wiggle_maps );
			
			part.params = custom_parameter_map;
			
			spawn_index = safe_mod(spawn_index + 1, attributes.part_amount);
			onSpawn(_time, part);
			
			parts_runner = safe_mod(parts_runner + 1, attributes.part_amount);
			spawn_index_raw++;
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
			
			if(is(_s, dynaSurf)) {
				surface_cache[$ surfs[i]] = _s;
				continue;
			}
			
			if(surface_exists(surface_cache[$ _s])) 
				continue;
				
			if(is(_s, SurfaceAtlas))
				_s = _s.surface.get();
				
			if(!is_surface(_s)) 
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
		
		spawn_index_raw = 0;
		spawn_index     = 0;
		scatter_index   = 0;
		
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
			var _curve_rot = getInputData(59);
			var _curve_spd = getInputData(60);
		
			curve_scale    = new curveMap(_curve_sca, TOTAL_FRAMES);
			curve_alpha    = new curveMap(_curve_alp, TOTAL_FRAMES);
			curve_path_div = new curveMap(_curve_pth, TOTAL_FRAMES);
			curve_rotate   = new curveMap(_curve_rot, TOTAL_FRAMES);
			curve_speed    = new curveMap(_curve_spd, TOTAL_FRAMES);
			
			for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
				var _n = custom_parameter_names[i];
				if(struct_exists(attributes.parameter_curves, _n))
					custom_parameter_map[$ _n] = new curveMap(attributes.parameter_curves[$ _n], TOTAL_FRAMES);
			}
			
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
	
	static runVFX = function(_time = NODE_CURRENT_FRAME, _render = true) {
		var _spawn_delay    = inputs[ 1].getValue(_time);
		var _spawn_type     = inputs[16].getValue(_time);
		var _spawn_active   = inputs[27].getValue(_time);
		var _spawn_trig     = inputs[44].getValue(_time);
		var _spawn_duration = inputs[51].getValue(_time);
		
		getInputs(_time);
		getSurfaceCache();
		
		if(_spawn_active) {
			var _doSpawn = false;
			switch(_spawn_type) {
				case 0 : _doSpawn = safe_mod(_time, _spawn_delay) == 0;                                 break;
				case 1 : _doSpawn = _time >= _spawn_delay && _time < _spawn_delay + _spawn_duration;    break;
				case 2 : _doSpawn = _spawn_trig;                                                        break;
			}
			
			if(_doSpawn) spawn(_time);
		}
		
		__time = _time;
		array_foreach(parts, function(p) /*=>*/ {return p.step(__time)});
		if(!_render) return;
		
		render(_time);
	}
	
	static onPartCreate  = noone;
	static onPartStep    = noone;
	static onPartDestroy = noone;
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _spr = getInputData(0);
		var _src = getInputData(4);
		
		if(_src == 3) {
			InputDrawOverlay(inputs[55].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
			
		} else if(_src == 4) {
			
			
		} else {
			if(array_empty(_spr)) return;
			if(is_array(_spr)) _spr = _spr[0];
			
			var _flag = is(_spr, SurfaceAtlas)? 0b0001 : 0b0011;
			InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _flag));
		}
		
		if(onDrawOverlay != -1) onDrawOverlay(active, _x, _y, _s, _mx, _my);
		
	}
	 
	static onDrawOverlay = -1;
	
	////- Update
	
	static getDimension = function() /*=>*/ {return DEF_SURF};
	
	static update = function(frame = NODE_CURRENT_FRAME) {
		
		#region visiblity
			var _inSurf = getInputData(0);
			var _dist   = getInputData(4);
			var _spwTyp = getInputData(16);
			var _scatt  = getInputData(24);
			var _turn   = getInputData(34);
			var _usePth = getInputData(45);
			var _direct = getInputData(29);
			
			inputs[24].setVisible(_dist == 0 || _dist == 1 || _dist == 3);
			
			inputs[ 3].setVisible(_dist != 3 && _dist != 4);
			inputs[30].setVisible(_dist == 2, _dist == 2);
			inputs[55].setVisible(_dist == 3, _dist == 3);
			inputs[62].setVisible(_dist == 4, _dist == 4);
			
			inputs[35].setVisible(_turn[0] != 0 && _turn[1] != 0);
			inputs[36].setVisible(_turn[0] != 0 && _turn[1] != 0);
			
			inputs[22].setVisible(false);
			inputs[23].setVisible(false);
			inputs[26].setVisible(false);
			inputs[49].setVisible(false);
			
			inputs[46].setVisible(true, _usePth);
			inputs[51].setVisible(_spwTyp == 1);
			inputs[52].setVisible(_dist != 2 && _scatt == 0);
			inputs[53].setVisible(_direct);
			
			inputs[1].setVisible(_spwTyp < 2);
			     if(_spwTyp == 0) inputs[1].name = "Spawn Delay";
			else if(_spwTyp == 1) inputs[1].name = "Spawn Frame";
			
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
		#endregion
		
		var sampSrf = getInputData(56);
		surfSamp.setSurface(sampSrf);
		
		var _surf = getInputData(0);
		if(is(_surf, dynaDraw)) {
			custom_parameter_names = _surf.parameters;
			
			for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
				var _n = custom_parameter_names[i];
				if(!struct_exists(attributes.parameter_curves, _n))
					attributes.parameter_curves[$ _n] = CURVE_DEF_11;
					
				if(!struct_exists(custom_parameter_curves_view, _n)) {
					var cbox = new curveBox(noone);
					    cbox.param_name  = _n;
					    cbox.param_curve = attributes.parameter_curves;
					    cbox.node        = self;
					    cbox.onModify    = method(cbox, function(c) /*=>*/ { param_curve[$ param_name] = c; node.clearCacheForward(); });
					
					custom_parameter_curves_view[$ _n] = cbox;
				}
			}
		} else 
			custom_parameter_names = [];
		
		var _resetSeed = getInputData(48);
		if(_resetSeed) resetSeed();
	
		checkPartPool();
		onUpdate(frame);
	}
	
	static onUpdate = function(frame = NODE_CURRENT_FRAME) {}
	
	static render = function() {}
	
	////- Serialize
	
	static doSerialize = function(_map) {
		_map.part_base_length = input_len;
	}
	
	static postDeserialize = function() {
		var _tlen = struct_try_get(load_map, "part_base_length", 40);
		for( var i = _tlen; i < input_len; i++ )
			array_insert(load_map.inputs, i, noone);
		
		if(LOADING_VERSION >= 1_18_09_0) return;
		
		var _attr_curv = attributes.parameter_curves;
		var _keys = variable_struct_get_names(_attr_curv);
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _val = _attr_curv[$ _keys[i]];
			
			var _insert = CURVE_PADD - (array_length(_val) % 6);
			repeat(_insert) array_insert(_val, 2, 0);
			
			_attr_curv[$ _keys[i]] = _val;
		}
		
	}
}