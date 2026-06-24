function Node_Particle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Particle";
	update_on_frame = true;
	use_cache = CACHE_USE.manual;
	// setCacheAuto();
	
	newInput(32, nodeValueSeed());
	
	////- =Output
	newInput(71, nodeValue_Dimension());
	newInput(74, nodeValue_Surface( "Background" ));
	
	////- =Sprite
	newInput( 0, nodeValue_Surface( "Particle Sprite" ));
	
	newInput(22, nodeValue_EScroll( "Surface Array", 0, [ "Random", "Order", "Animation", "Scale" ]))
		.setTooltip("Whether to select image from an array in order, at random, or treat array as animation.");
	
	newInput(23, nodeValue_Range(   "Animation Speed",   [1,1], { linked : true } ));
	newInput(49, nodeValue_Bool(    "Stretch Animation", false                    ));
	newInput(26, nodeValue_EButton( "On Animation End",  ANIM_END_ACTION.loop     )).setChoices([ "Loop", "Ping pong", "Destroy" ]);
	
	////- =Spawn
	newInput(27, nodeValue_Bool(    "Spawn",            true          ));
	newInput(16, nodeValue_EButton( "Spawn Type",       0             )).setChoices([ "Stream", "Burst", "Trigger" ]);
	newInput(44, nodeValue_Trigger( "Spawn"                           ));
	newInput( 1, nodeValue_Int(     "Spawn Delay",      4             )).setTooltip("Frames delay between each particle spawn.");
	newInput(51, nodeValue_Int(     "Burst Duration",   1             ));
	newInput( 2, nodeValue_Range(   "Spawn Amount",    [2,2], true    )).setTooltip("Amount of particle spawn in that frame.");
	
		////- =/Lifespan
	newInput( 5, nodeValue_Range(   "Lifespan",        [20,30]        ));
	
		////- =/Source
	newInput( 4, nodeValue_EScroll( "Spawn Source",     0,            )).setChoices([ "Area Inside", "Area Border", "Map", "Path", "Direct Data" ]);
	newInput( 3, nodeValue_Area(    "Spawn Area",       DEF_AREA_REF  )).setHotkey("A").setUnitSimple();
	newInput(30, nodeValue_Surface( "Distribution Map"                ));
	newInput(55, nodeValue_Path(    "Spawn Path"                      ));
	newInput(62, nodeValue_Vector(  "Spawn Data"                      )).setArrayDepth(1).setTooltip("Array of vec2 points to spawn particles at.");
	newInput(24, nodeValue_EButton( "Distribution",     1             )).setChoices([ "Uniform", "Random", "Poisson" ]);
	newInput(79, nodeValue_Float(   "Distance",         8            )).setValidator(VV_min(0));
	newInput(52, nodeValue_Float(   "Uniform Period",   4             ));
	
	////- =Movement
	newInput(18, nodeValue_Range(   "Speed",                [1,2]              )).setCurvable(60, CURVE_DEF_11, "Over Lifespan");
	inputs[60].setTooltip("Speed Curve may conflict with physics-based properties.");
	
		////- =/Direction
	newInput(64, nodeValue_EButton(  "Direction Type",        0, [ "Random", "Uniform" ] ));
	newInput( 6, nodeValue_RotRand(  "Initial Direction",    [0,45,135,0,0]     )); 
	
	newInput(29, nodeValue_Bool(     "Directed From Center", false              )).setTooltip("Make particle move away from the spawn center.");
	newInput(53, nodeValue_RotRange( "Angle Range",          [0,360]            ));
	
		////- =/Wrap
	newInput(67, nodeValue_Toggle(   "Wrap",                  0, [ "X", "Y" ]   ))
	
	////- =Rotation
	newInput( 8, nodeValue_RotRand(  "Initial Rotation",     [0,0,0,0,0]        ));
	newInput(15, nodeValue_Bool(     "Rotate by Direction",   false             )).setTooltip("Make the particle rotates to follow its movement.");
	
		////- =/Animated
	newInput(68, nodeValue_EScroll(  "Rotation Type",         0, [ "Speed", "Fix Relative", "Fix Angle" ] )).setTooltip("Rotation method:\n\t- Speed: Add rotation angle per frame.\n\t- Fix Relative: Lerp to angle ralative to orignal angle.\n\t- Fix target: Lerp to fix angle.");
	newInput( 9, nodeValue_RotRand(  "Rotational Speed",     [0,0,0,0,0]        )).setCurvable(59, CURVE_DEF_11, "Over Lifespan");
	newInput(69, nodeValue_RotRand(  "Target Angle",         [0,0,0,0,0]        )).setCurvable(70, CURVE_DEF_01, "Over Lifespan");
	
		////- =/Snap
	newInput(61, nodeValue_Float(     "Snap Rotation",         0                 ));
	
	////- =Scale
	newInput(10, nodeValue_Range2(    "Scale",        [1,1,1,1], { linked : true }   ));
	newInput(17, nodeValue_Range(     "Size",         [1,1],     { linked : true }   )).setCurvable(11, CURVE_DEF_11, "Over Lifespan");
	
	////- =Color
	newInput(28, nodeValue_Gradient(  "Color on Spawn",      gra_white                ));
	newInput(50, nodeValue_Palette(   "Color by Index",      [ca_white]               )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(12, nodeValue_Gradient(  "Color over Lifetime", gra_white                ));
	newInput(13, nodeValue_Range(     "Alpha",               [1,1], { linked : true } )).setCurvable(14, CURVE_DEF_11, "Over Lifespan");
		
		////- =/Sampler
	newInput(56, nodeValue_Surface(   "Sample Surface" ));
	
	////- =Render
	newInput(77, nodeValue_Bool(    "Render",         true  ));
	newInput(75, nodeValue_EButton( "Render Type",    PARTICLE_RENDER_TYPE.surface , [ "Surface", "Line" ] ));
	newInput(76, nodeValue_Int(     "Line Life",      4     ));
	newInput(21, nodeValue_Bool(    "Loop",           true  ));
	newInput(72, nodeValue_Bool(    "Round Position", true, "Round position to the closest integer value to avoid jittering." ));
	newInput(73, nodeValue_EScroll( "Blend Mode",     0, [ "Normal", "Alpha", "Additive", "Maximum" ] ));
	newInput(78, nodeValue_Bool(    "Sort Y",         false ));
	
	////- =Follow Path
	newInput(45, nodeValue_Bool(    "Follow Path",   false        ));
	newInput(46, nodeValue_Path(    "Path"                        ));
	newInput(66, nodeValue_Range2(  "Range",         [0,0,1,1]    ));
	newInput(80, nodeValue_Range(   "Range Shift",   [0,0]        ));
	newInput(81, nodeValue_Curve(   "Path Speed",    CURVE_DEF_01 ));
	newInput(47, nodeValue_Curve(   "Deviation",     CURVE_DEF_11 ));
	
	////- =Physics
	newInput(57, nodeValue_Bool(     "Use Physics",  false                     ));
	newInput(54, nodeValue_Range(    "Friction",     [0,0], { linked : true }  ));
	newInput( 7, nodeValue_Range(    "Acceleration", [0,0], { linked : true }  ));
	
		////- =/Gravity
	newInput(19, nodeValue_Range(    "Gravity",                [0,0], { linked : true }  ));
	newInput(33, nodeValue_Rotation( "Gravity Direction",      -90                       ));
	
		////- =/Turning
	newInput(34, nodeValue_Range(    "Turning",                [0,0], { linked : true }  ));
	newInput(35, nodeValue_Bool(     "Turn Both Directions",   false                     )).setTooltip("Apply randomized 1, -1 multiplier to the turning speed.");
	newInput(36, nodeValue_Float(    "Turn Scale with Speed",  false                     ));
	
	////- =Ground
	newInput(37, nodeValue_Bool(    "Collide Ground",      false                         ));
	newInput(63, nodeValue_EButton( "Ground Offset Type",  0, [ "Relative", "Absolute" ] ));
	newInput(38, nodeValue_Range(   "Ground Offset",       [0,0], { linked : true }      ));
	
		////- =/Bounce
	newInput(39, nodeValue_Slider(  "Bounce Amount",       .5                            ));
	newInput(40, nodeValue_Slider(  "Bounce Friction",     .1                            )).setTooltip("Apply horizontal friction once particle stop bouncing.");
		
	////- =Wiggles
	var wParam = { label: [ "Amplitude", "Period" ], linkable: false, per_line: true };
	newInput(58, nodeValue_Bool( "Use Wiggles", false         ));
	newInput(20, nodeValue_Vec2( "Direction",   [0,0], wParam )).setInternalName("direction_wiggle");
	newInput(41, nodeValue_Vec2( "Position",    [0,0], wParam )).setInternalName("position_wiggle");
	newInput(42, nodeValue_Vec2( "Rotation",    [0,0], wParam )).setInternalName("rotation_wiggle");
	newInput(43, nodeValue_Vec2( "Scale",       [0,0], wParam )).setInternalName("scale_wiggle");
	
	////- =Unused
	newInput(65, nodeValue_Int(      "Pre-Render",    -1   ));
	newInput(25, nodeValue_Int(      "Boundary Data", []   )).setArrayDepth(1).setVisible(false, true);
	newInput(31, nodeValue_Surface(  "Atlas",         []   )).setArrayDepth(1);
	newInput(48, nodeValue_Trigger(  "Reset Seed"          ))
	//input 82
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface,  noone ));
	newOutput( 1, nodeValue_Output( "Data",        VALUE_TYPE.particle, []    ));
	
	array_foreach(inputs, function(inp, i) /*=>*/ { 
		if(i == 6 || i == 8) return; 
		if(inp.type == VALUE_TYPE.gradient) return; 
		
		inp.rejectArray(); 
	}, 1);
	
	dynaDraw_parameter = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_empty(custom_parameter_names)) return 0;
		
		var _hh = 0;
		
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
			var _hg = _wig.drawParam(new widgetParam(_x, _y, _w, 0, _dat, undefined, _m, dynaDraw_parameter.rx, dynaDraw_parameter.ry).setFont(f_p2));
			
			_y  += _hg + ui(8);
			_hh += _hg + ui(8);
		}
		
		_hh -= ui(8);
		return _hh;
	});
	
	input_display_list = [ 32, 
		[ "Output",          true ], 71, 74, 
		[ "Sprite",          true ],  0, dynaDraw_parameter, 22, 23, 49, 26,
		[ "Spawn",           true ], 
			[ "/Spawning",  false ], 27, 16, 44,  1, 51,  2,
			[ "/Lifespan",  false ],  5, 
			[ "/Source",    false ],  4,  3, 30, 55, 62, 24, 79, 52, 
			
		[ "Movement",        true ], 18, 60, 
			[ "/Direction", false ], 64,  6, 29, 53, 
			[ "/Wrap",       true ], 67, 
			
		[ "Rotation",        true ],  8, 15, 
			[ "/Animated",  false ], 68,  9, 59, 69, 70, 
			[ "/Snap",       true ], 61, 
			
		[ "Scale",           true ], 10, 17, 11, 
		[ "Color",           true ], 28, 50, 12, 13, 14, 
			[ "/Sampler",    true ], 56, 
		
		[ "Render",      true, 77 ], 75, 76, 21, 72, 73, 78, 
		
		__inspc(ui(6), true, false, ui(3)), 
		
		[ "Follow Path",  true, 45 ], 46, 66, 80, 81, 47, 
		[ "Physics",      true, 57 ], 54,  7, 
			[ "/Gravity", false    ], 19, 33, 
			[ "/Turning", false    ], 34, 35, 36, 
		[ "Ground",       true, 37 ], 38, 63, 
			[ "/Bounce",  false    ], 39, 40, 
		[ "Wiggles",      true, 58 ], 20, 41, 42, 43, 
		
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation(false, true);
	
	#region Attributes
		attributes.cache = true;
		
		attributes.part_amount = 512;
		array_push(attributeEditors, Node_Attribute( "Maximum Particles", function() /*=>*/ {return attributes.part_amount}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("part_amount", v)})} ));
	#endregion
	
	#region Particles
		_self = self;
		parts = array_create_ext(attributes.part_amount, function() /*=>*/ {return new __part(_self)});
		
		parts_runner    = 0;
		seed            = 0;
		spawn_total     = 0;
		spawn_index     = 0;
		scatter_index   = 0;
		def_surface     = -1;
		
		surface_cache   = {};
		surface_wcache  = {};
		surface_hcache  = {};
		
		curr_dimension   = [0,0];
		render_frame     = 0;
		
		__p = [0,0];
	#endregion
	
	#region Cached wiggle, curves, parameter, sampler
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
		curve_rotateF  = noone;
		curve_scale    = noone;
		curve_alpha    = noone;
		curve_path_spd = noone;
		curve_path_div = noone;
		dist_map_cache = [];
		
		poisson_cache      = [];
		poisson_cache_amo  = 0;
		
		custom_parameter_names       = [];
		custom_parameter_curves_view = {};
		custom_parameter_map         = {};
		attributes.parameter_curves  = {};
		
		surfSamp = new Surface_sampler();
	#endregion
	
	////- Draw Overlay
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _spr = getInputData(0);
		var _src = getInputData(4);
		
		if(_src == 3) {
			drawOverlayInput(inputs[55].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
			
		} else if(_src == 4) {
			
			
		} else {
			if(array_empty(_spr)) return;
			if(is_array(_spr)) _spr = _spr[0];
			
			var _flag = is(_spr, SurfaceAtlas)? 0b0001 : 0b0011;
			drawOverlayInput(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _flag));
		}
		
	}
	
	////- VFX
	
	static getSurfaceCache = function() {
		var surfs = inputs_data[0];
		
		if(array_empty(surfs)) return;
		if(!is_array(surfs)) surfs = [ surfs ];
		surfs = array_spread(surfs);
		
		for( var i = 0, n = array_length(surfs); i < n; i++ ) {
			var _s = surfs[i];
			
			if(is(_s, dynaSurf)) {
				surface_cache[$  surfs[i]] = _s;
				surface_wcache[$ surfs[i]] = surface_get_width_safe(_s);
				surface_hcache[$ surfs[i]] = surface_get_height_safe(_s);
				continue;
			}
			
			if(is(_s, SurfaceAtlas))
				_s = _s.surface.get();
			
			if(!surface_exists(_s)) continue;
			
			var sw = surface_get_width_safe(_s);
			var sh = surface_get_height_safe(_s);
			surface_wcache[$ surfs[i]] = sw;
			surface_hcache[$ surfs[i]] = sh;
			surface_cache[$  surfs[i]] = surface_verify(surface_cache[$  surfs[i]], sw, sh);
			
			surface_set_target(surface_cache[$  surfs[i]]);
				DRAW_CLEAR
				BLEND_OVERRIDE
				draw_surface(_s, 0, 0);
				BLEND_NORMAL
			surface_reset_target();
		}
	}
	
	static spawn = function(_time = NODE_CURRENT_FRAME, _pos = -1) {
		#region data
			var _inSurf     	= inputs_data[ 0];
			var _arr_type   	= inputs_data[22];
			var _anim_speed 	= inputs_data[23];
			var _anim_stre  	= inputs_data[49];
			var _anim_end   	= inputs_data[26];
			
			var _spawn_amount	= inputs_data[ 2];
			var _life       	= inputs_data[ 5];
			
			var _distrib    	= inputs_data[ 4];
			var _spawn_area 	= inputs_data[ 3];
			var _dist_map   	= inputs_data[30];
			var _dist_path   	= inputs_data[55];
			var _dist_data      = inputs_data[62];
			var _scatter    	= inputs_data[24];
			var _spawn_period   = inputs_data[52];
			
			var _velocity   	= inputs_data[18];
			var _directionType  = inputs_data[64];
			var _direction  	= inputs_data[ 6];
			var _directCenter	= inputs_data[29];
			var _directRange	= inputs_data[53];
			var _warp           = inputs_data[67];
			
			var _rotation       = inputs_data[ 8];
			var _follow         = inputs_data[15];
			var _rotation_type  = inputs_data[68];
			var _rotation_speed = inputs_data[ 9];
			var _rotation_targ  = inputs_data[69];
			var _rotation_snap  = inputs_data[61];
			
			var _scale      	= inputs_data[10];
			var _size       	= inputs_data[17];
			
			var _blend      	= inputs_data[28];
			var _color_idx   	= inputs_data[50], _color_idx_len  = array_length(_color_idx), _color_idx_typ = inputs[50].attributes.array_select;
			var _color      	= inputs_data[12]; _color.cache();
			var _alpha      	= inputs_data[13];
		
		//////////////////////////////////////////////////////////////////////////////
		
			var _path       	= inputs_data[46];
			var _pathRange      = inputs_data[66];
			var _pathRangeShf   = inputs_data[80];
			
			var _use_phy     	= inputs_data[57];
			var _accel      	= inputs_data[ 7];
			var _grav       	= inputs_data[19];
			var _gvDir      	= inputs_data[33];
			var _turn       	= inputs_data[34];
			var _turnBi     	= inputs_data[35];
			var _turnSc     	= inputs_data[36];
			var _friction     	= inputs_data[54];
			
			var _ground         = inputs_data[37];
			var _ground_offtyp  = inputs_data[63];
			var _ground_offset  = inputs_data[38];
			var _ground_bounce  = inputs_data[39];
			var _ground_frict   = inputs_data[40];
			
			var _use_wig     	= inputs_data[58];
		#endregion
		
		if(array_empty(_inSurf)) return;
		
		random_set_seed(seed); seed += 1000;
		
		var _posDist = undefined;
		var _amo = irandom_range(_spawn_amount[0], _spawn_amount[1]);
		
		if(_distrib == 2) {
			dist_map_cache = get_points_from_dist(_dist_map, _amo, seed, 8, dist_map_cache);
			_posDist       = dist_map_cache;
		}
		
		if(_distrib == 4) {
			var _len = array_length(_dist_data);
			var _dep = array_get_depth(_dist_data);
			if(_dep != 2) return;
			_amo = min(_amo, _len);
		}
		
		for( var i = 0; i < _amo; i++ ) {
			parts_runner = clamp(parts_runner, 0, array_length(parts) - 1);
			var part = parts[parts_runner].reset();
			
			#region Sprites
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
						
					case 2 : 
					case 3 : 
						_spr = _inSurf;
						break;
				}
			#endregion
			
			#region Position
				var xx = 0;
				var yy = 0;
				
				if(_pos == -1) {
					if(is(_spr, SurfaceAtlas)) {
						xx = _spawn_area[0] + _spr.x + _spr.w / 2;
						yy = _spawn_area[1] + _spr.y + _spr.h / 2;
						part.atlas = _spr;
						
					} else if(_distrib < 2) {
						if(_distrib == 0 && _scatter == 2 && poisson_cache_amo > 0) {
							var _poiPos = poisson_cache[irandom(poisson_cache_amo - 1)];
							xx = _poiPos[0];
							yy = _poiPos[1];
							
						} else {
							area_get_random_point(_spawn_area, _distrib, _scatter, spawn_index, _spawn_period, undefined, __p);
							xx = __p[0];
							yy = __p[1];
						}
						
					} else if(_distrib == 2) {
						var sp = array_safe_get_fast(_posDist, i);
						if(array_invalid(sp) || sp[0] == undefined) continue;
							
						xx = _spawn_area[0] + _spawn_area[2] * (sp[0] * 2 - 1.);
						yy = _spawn_area[1] + _spawn_area[3] * (sp[1] * 2 - 1.);
						
					} else if(_distrib == 3) {
						if(_dist_path == noone) continue;
						
						var _pathProg = _scatter == 0? (spawn_index % _spawn_period) / (_spawn_period - 1) : random(1);
						var _p = _dist_path.getPointRatio(_pathProg, 0);
						
						xx = _p.x;
						yy = _p.y;
						
					} else if(_distrib == 4) {
						var _i = _scatter == 0? safe_mod(spawn_total, _len) : irandom(_len - 1);
						var _p = _dist_data[_i];
						
						xx = _p[0]; 
						yy = _p[1];
					}
					
				} else {
					xx = _pos[0];
					yy = _pos[1];
				}
			#endregion
			
			var _lif = irandom_range(_life[0], _life[1]);
			part.create(_spr, xx, yy, _lif, _warp & 0b01, _warp & 0b10);
			part.seed = irandom_range(100000, 999999);
			part.setSpriteAnimation(random_range(_anim_speed[0], _anim_speed[1]), _anim_stre, _anim_end, _arr_type);
			part.params = custom_parameter_map;
			
			#region Rotation
				var _rot = rotation_random_eval_fast(is_array(_rotation[0])? _rotation[i] : _rotation);
				
				switch(_rotation_type) {
					case 0 : 
						var _rot_spd  = rotation_random_eval_fast(_rotation_speed);
						part.setRotation(  _rot, _rot_spd, curve_rotate, _rotation_snap, _follow ); 
						break;
					
					case 1 : 
						var _rot_tar = rotation_random_eval_fast(_rotation_targ);
						part.setRotationTarget( _rot, _rot + _rot_tar, curve_rotateF, _rotation_snap ); 
						break;
						
					case 2 : 
						var _rot_tar = rotation_random_eval_fast(_rotation_targ);
						part.setRotationTarget( _rot, _rot_tar, curve_rotateF, _rotation_snap ); 
						break;
				}
			#endregion
			
			#region Scale
				var _ss   = random_range(_size[0], _size[1]);
				var _scx  = random_range(_scale[0], _scale[1]) * _ss;
				var _scy  = random_range(_scale[2], _scale[3]) * _ss;
					
				part.setTransform( _scx, _scy, curve_scale );
			#endregion
			
			#region Draw
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
				
				part.setDraw( _color, _bld, _alp, curve_alpha );
			#endregion
			
			#region Follow Path
				var _path_range_shift = random_range(_pathRangeShf[0], _pathRangeShf[1]);
				var _path_range = [ 
					random_range(_pathRange[0], _pathRange[1]) + _path_range_shift, 
					random_range(_pathRange[2], _pathRange[3]) + _path_range_shift 
				];
				
				part.setPath( _path, _path_range, curve_path_spd, curve_path_div );
			#endregion
			
			#region Physics
				var _dirs = is_array(_direction[0])? _direction[i] : _direction;
				var _dirr = _directionType == 0? rotation_random_eval_fast(_dirs) : rotation_random_eval_uniform(_dirs, i / (_amo - 1));
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
				
				var _gravity = random_range(_grav[0], _grav[1]);
				var _trn = random_range(_turn[0], _turn[1]) * (_turnBi? choose(-1, 1) : 1);
				
				part.setPhysic( _use_phy, _vx, _vy, curve_speed, _acc, _frc, _gravity, _gvDir, _trn, _turnSc );
			#endregion
			
			#region Ground
				var __ground_offset = random_range(_ground_offset[0], _ground_offset[1]);
				part.setGround( _ground, _ground_offtyp, __ground_offset, _ground_bounce, _ground_frict );
			#endregion
			
			#region Wiggle
				part.setWiggle( _use_wig, wiggle_maps );
			#endregion
			
			spawn_index  = safe_mod(spawn_index + 1, attributes.part_amount);
			parts_runner = safe_mod(parts_runner + 1, attributes.part_amount);
			spawn_total++;
		}
	}
	
	static runVFX = function(_time = NODE_CURRENT_FRAME) {
		for( var i = 0, n = array_length(inputs); i < n; i++ )
			if(inputs[i].isAnimated()) inputs_data[i] = inputs[i].getValue(_time);
		
		var _spawn_delay    = inputs_data[ 1];
		var _spawn_type     = inputs_data[16];
		var _spawn_active   = inputs_data[27];
		var _spawn_trig     = inputs_data[44];
		var _spawn_duration = inputs_data[51];
		
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
		array_foreach(parts, function(p,i) /*=>*/ { 
			if(p.active) p.step(__time); 
			p.trailLife++; 
		});
	}
	
	function render(_time = CURRENT_FRAME) {
		var _dim   = inputs[71].getValue(_time);
		var _exact = inputs[72].getValue(_time);
		var _blend = inputs[73].getValue(_time);
		var _bg    = inputs[74].getValue(_time);
		
		var _type  = inputs[75].getValue(_time);
		var _llife = inputs[76].getValue(_time);
		
		var _sortY = inputs[78].getValue(_time);
		
		if(is_surface(_bg)) _dim = surface_get_dimension(_bg);
		var _outSurf = surface_create_valid(_dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, _type == PARTICLE_RENDER_TYPE.surface? sh_sample : noone);
			shader_set_interpolation(noone, _dim);
			draw_surface_safe(_bg);
			
			switch(_blend) {
				case PARTICLE_BLEND_MODE.normal:   BLEND_NORMAL break;
				case PARTICLE_BLEND_MODE.alpha:    BLEND_ALPHA  break;
				case PARTICLE_BLEND_MODE.additive: BLEND_ADD    break;
				case PARTICLE_BLEND_MODE.maximum:  BLEND_MAX    break;
				case PARTICLE_BLEND_MODE.minimum:  
					draw_clear_alpha(c_white, 0.);
					draw_surface_safe(_bg);
					BLEND_MIN   
					break;
			}
			
			__llife = _llife;
			__exact = _exact;
			__dimw  = _dim[0];
			__dimh  = _dim[1];
			
			if(_sortY) array_sort(parts, function(a1, a2) /*=>*/ {return sign(a1.y - a2.y)});
			
			switch(_type) {
				case PARTICLE_RENDER_TYPE.surface : 
					shader_set_interpolation(_outSurf);
					array_foreach(parts, function(p,i) /*=>*/ { if(p.active) p.draw(__exact, __dimw, __dimh); return true; });
					break;
					
				case PARTICLE_RENDER_TYPE.line : 
					array_foreach(parts, function(p,i) /*=>*/ { p.line_draw = __llife; p.drawLine(__exact, __dimw, __dimh); return true; });
					break;
			}
			
		surface_reset_shader();	
		
		outputs[0].setValue(_outSurf);
		if(attributes.cache) cacheCurrentFrame(_outSurf, _time);
	}
	
	function reset() {
		getInputs(0);
		
		var keys = variable_struct_get_names(surface_cache);
		for( var i = 0, n = array_length(keys); i < n; i++ )
			surface_free_safe(surface_cache[$ keys[i]]);
		surface_cache  = {};
		surface_wcache = {};
		surface_hcache = {};
		getSurfaceCache();
		
		spawn_total   = 0;
		spawn_index   = 0;
		scatter_index = 0;
		
		for(var i = 0; i < array_length(parts); i++) {
			if(!parts[i].active) continue;
			parts[i].kill(false);
		}
		
		#region ----- precomputes -----
			seed = getInputData(32);
			
			var _spawn_area = getInputData( 3);
			var _scatt      = getInputData(24);
			var poisDist    = getInputData(79);
			if(_scatt == 2) {
				random_set_seed(seed);
				poisson_cache     = area_get_random_point_poisson_c(_spawn_area, poisDist, seed);
				// poisson_cache     = array_shuffle(poisson_cache);
				poisson_cache_amo = array_length(poisson_cache);
			}
			
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
			
			var _curve_psp = getInputData(81);
			var _curve_pth = getInputData(47);
			
			var _curve_rot = getInputData(59);
			var _curve_rtF = getInputData(70);
			var _curve_spd = getInputData(60);
		
			curve_scale    = new curveMap(_curve_sca, TOTAL_FRAMES);
			curve_alpha    = new curveMap(_curve_alp, TOTAL_FRAMES);
			
			curve_path_spd = new curveMap(_curve_psp, TOTAL_FRAMES);
			curve_path_div = new curveMap(_curve_pth, TOTAL_FRAMES);
			
			curve_rotate   = new curveMap(_curve_rot, TOTAL_FRAMES);
			curve_rotateF  = new curveMap(_curve_rtF, TOTAL_FRAMES);
			curve_speed    = new curveMap(_curve_spd, TOTAL_FRAMES);
			
			for( var i = 0, n = array_length(custom_parameter_names); i < n; i++ ) {
				var _n = custom_parameter_names[i];
				if(struct_exists(attributes.parameter_curves, _n))
					custom_parameter_map[$ _n] = new curveMap(attributes.parameter_curves[$ _n], TOTAL_FRAMES);
			}
			
		#endregion
	}
	
	////- Update
	
	static onClearCache = function() { render_frame = 0; }
	
	static update = function(frame = NODE_CURRENT_FRAME) {
		if(attributes.cache) {
			var _cache = getCacheFrame(frame);
			if(is_surface(_cache)) { outputs[0].setValue(_cache); return; }
		}
		
		#region Visiblity
			var _inSurf = getInputData( 0);
			
			var _dist   = getInputData( 4);
			var _spwTyp = getInputData(16);
			var _scatt  = getInputData(24);
			
			var _direct = getInputData(29);
			var _rotTyp = getInputData(68);
			
			var _usePth = getInputData(45);
			var _turn   = getInputData(34);
			
			var _typ     = getInputData(75);
			
			inputs[24].setVisible(_dist == 0 || _dist == 1 || _dist == 3 || _dist == 4);
			
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
			
			inputs[ 9].setVisible(_rotTyp == 0);
			inputs[69].setVisible(_rotTyp != 0);
			
			inputs[79].setVisible(_scatt == 2);
			
			inputs[1].setVisible(_spwTyp < 2);
			     if(_spwTyp == 0) inputs[1].name = "Spawn Delay";
			else if(_spwTyp == 1) inputs[1].name = "Spawn Frame";
			
			inputs[44].setVisible(_spwTyp == 2);
			
			inputs[76].setVisible(_typ == PARTICLE_RENDER_TYPE.line);
			
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
		
		#region Parameter
			var sampSrf = getInputData(56);
			surfSamp.setSurface(sampSrf);
			
			if(is(_inSurf, dynaDraw)) {
				custom_parameter_names = _inSurf.parameters;
				
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
			
			var _part_amo = attributes.part_amount;
			var _curr_amo = array_length(parts);
			
			if(_part_amo > _curr_amo) {
				repeat(_part_amo - _curr_amo)
					array_push(parts, new __part(self));
					
			} else if(_part_amo < _curr_amo)
				array_resize(parts, _part_amo);
		#endregion
		
		#region Render
			outputs[1].setValue(parts);
			var _loop = getInputData(21);
			var _rend = getInputData(77);
			
			if(frame == 0) render_frame = 0;
			
			while(render_frame <= frame) {
				if(render_frame == 0) {
					reset(); 
					
					if(_loop) {
						var _prer = getInputData(65);
						var _type = getInputData(75);
						
						if(_prer == -1) _prer = TOTAL_FRAMES;
						for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES; i++)
							runVFX(i);
						
						seed = getInputData(32);
					}
					
					render_frame = 0;
				}
				
				runVFX(render_frame);
				if(_rend) render(render_frame);
				render_frame++;
			}
		#endregion
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		var _len = array_length(load_map.inputs);
		
		if(_len > 67) {
			var _inp_wrap = load_map.inputs[67];
			if(has(_inp_wrap, "raw_value") && is_array(_inp_wrap.raw_value.d))
				_inp_wrap.raw_value.d = 0;
		}
		
		if(_len > 71) {
			var _inp_dim = load_map.inputs[71];
			if(has(_inp_dim, "raw_value") && !is_array(_inp_dim.raw_value.d))
				_inp_dim.raw_value.d = [1,1];
		}
		
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