#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_3D_Particle", "Move Origin", "G");
	});
	
#endregion

function Node_3D_Particle(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Particle";
	update_on_frame = true;
	
	spawn_gizmo = noone;
	spawn_gizmo_box    = new __3dGizmoBox(     1, c_white, .75 );
	spawn_gizmo_sphere = new __3dGizmoSphere(  1, c_white, .75 );
	spawn_gizmo_circle = new __3dGizmoCircleZ( 1, c_white, .75 );
	
	newInput( 1, nodeValueSeed());
	
	////- =Object
	newInput( 0, nodeValue_D3Mesh("Mesh", noone)).setVisible(true, true);
	
	////- =Spawn
	newInput( 2, nodeValue_Bool(        "Spawn",             true       ));
	newInput( 3, nodeValue_Enum_Scroll( "Spawn Type",        0,         )).setChoices([ "Stream", "Burst", "Trigger" ]);
	newInput( 4, nodeValue_Trigger(     "Spawn Trigger",                ));
	newInput( 5, nodeValue_Int(         "Spawn Delay",       4          )).setTooltip("Frames delay between each particle spawn.");
	newInput( 6, nodeValue_Int(         "Burst Duration",    1          ));
	newInput( 7, nodeValue_Range(       "Spawn Amount",     [2,2], true )).setTooltip("Amount of particle spawn in that frame.");
	newInput(12, nodeValue_Range(       "Lifespan",         [20,30]     ));
	
	////- =Spawn Source
	newInput( 8, nodeValue_Enum_Scroll( "Spawn Source",      0,         )).setChoices([ "Shape", "Path", "Mesh Vertices", "Direct Data" ]);
	newInput(30, nodeValue_Enum_Scroll( "Spawn Shape",       0,         )).setChoices(__enum_array_gen([ "Box", "Sphere", "Circle" ], s_node_particle_3d_spawn_shape));
	newInput( 9, nodeValue_Vec3(        "Spawn Origin",     [0,0,0]     ));
	newInput(27, nodeValue_Vec3(        "Spawn Span",       [1,1,1]     ));
	newInput(57, nodeValue_Quaternion(  "Spawn Rotation",   [0,0,0,1]   ));
	newInput(10, nodeValue_PathNode(    "Spawn Path"                    ));
	newInput(29, nodeValue_D3Mesh(      "Spawn Mesh"                    ));
	newInput(11, nodeValue_Vector(      "Spawn Data"                    )).setArrayDepth(1);
	
	////- =Movement
	newInput(13, nodeValue_Vec3_Range(  "Velocity",             [0,0,0,0,0,0] )).setCurvable(15, CURVE_DEF_11, "Over Lifespan"); 
	newInput(14, nodeValue_Vec3_Range(  "Acceleration",         [0,0,0,0,0,0] )); 
	newInput(16, nodeValue_Range(       "Follow Spawn Shape",   [0,0], true   ));
	
	////- =Rotation
	newInput(17, nodeValue_Vec3_Range(  "Rotation",             [0,0,0,0,0,0] ));
	newInput(18, nodeValue_Vec3_Range(  "Rotational Speed",     [0,0,0,0,0,0] )).setCurvable(19, CURVE_DEF_11, "Over Lifespan"); 
	newInput(20, nodeValue_Float(       "Snap Rotation",        0             ));
	newInput(54, nodeValue_Bool(        "Follow Velocity",      false         ));
	
	////- =Scale
	newInput(21, nodeValue_Vec3_Range(  "Scale",                [1,1,1,1,1,1] ));
	newInput(22, nodeValue_Range(       "Size",                 [1,1], true   )).setCurvable(23, CURVE_DEF_11, "Over Lifespan"); 
	
	////- =Color
	newInput(24, nodeValue_Gradient(    "Color Over Lifetime",  gra_white  ));
	newInput(25, nodeValue_Gradient(    "Random Blend",         gra_white  ));
	newInput(26, nodeValue_Palette(     "Color by Index",       [ca_white]                    )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(55, nodeValue_Range(       "Alpha",                [1,1], true                   )).setCurvable(53, CURVE_DEF_11, "Over Lifespan"); 
	
	////- =Render
	newInput(28, nodeValue_Enum_Scroll( "Blend Mode",     0, [ "Normal", "Alpha", "Additive", "Maximum" ]));
	newInput(32, nodeValue_Bool(        "Billboard",      false ));
	newInput(31, nodeValue_Bool(        "Loop",           true  ));
	newInput(58, nodeValue_Int(         "Pre-Render",     -1  ));
	newInput(33, nodeValue_Bool(        "Transparent",    false ));
	
	////- =Path
	newInput(34, nodeValue_Bool(       "Follow Path",            false                         ));
	newInput(35, nodeValue_PathNode(   "Path"                                                  ));
	newInput(56, nodeValue_Vec2_Range( "Path Range",             [0,0,1,1]                     ));
	newInput(36, nodeValue_Curve(      "Path Deviation",         CURVE_DEF_11                  ));
	
	////- =Physics
	newInput(37, nodeValue_Bool(     "Use Physics",            false                         ));
	newInput(38, nodeValue_Range(    "Gravity",                [0,0], { linked : true }      ));
	newInput(39, nodeValue_Rotation( "Gravity Direction",      -90                           ));
	
	newInput(40, nodeValue_Range(    "Turning",                [0,0], { linked : true }      ));
	newInput(41, nodeValue_Bool(     "Turn Both Directions",   false                         )).setTooltip("Apply randomized 1, -1 multiplier to the turning speed.");
	newInput(42, nodeValue_Float(    "Turn Scale with Speed",  false                         ));
	
	////- =Ground
	newInput(43, nodeValue_Bool(        "Collide Ground",      false                         ));
	newInput(44, nodeValue_Enum_Button( "Ground Offset Type",  1, [ "Relative", "Absolute" ] ));
	newInput(45, nodeValue_Range(       "Ground Offset",       [0,0], { linked : true }      ));
	newInput(46, nodeValue_Slider(      "Bounce Amount",       .5                            ));
	newInput(47, nodeValue_Slider(      "Bounce Friction",     .1                            )).setTooltip("Apply horizontal friction once particle stop bouncing.");
		
	////- =Wiggles
	newInput(48, nodeValue_Bool(     "Use Wiggles",            false ));
	newInput(49, nodeValue_Vec2(     "Direction Wiggle",       [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(50, nodeValue_Vec2(     "Position Wiggle",        [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(51, nodeValue_Vec2(     "Rotation Wiggle",        [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	newInput(52, nodeValue_Vec2(     "Scale Wiggle",           [0,0], { label: [ "Amplitude", "Period" ], linkable: false, per_line: true } ));
	
	// 59
	
	input_display_list = [ 1, 
		[ "Object",       true ],  0, 
		[ "Spawn",        true ],  2,  3,  4,  5,  6,  7, __inspc(ui(6), true), 12,  
		[ "Spawn Source", true ],  8,  30, 9, 27, 57, 10, 29, 11, 
		[ "Movement",     true ], 13, 15, 14, 16, 
		[ "Rotation",     true ], 17, 18, 19, 54, 
		[ "Scale",        true ], 21, 22, 23, 
		[ "Color",        true ], 24, 25, 26, 55, 53, 
		[ "Render",       true ], 28, 32, 31, 58, 33, 
		__inspc(ui(6), true, false, ui(3)), 
		
		["Follow path", true, 34], 35, 56, 36, 
		["Physics",		true, 37], 38, 39,
		["Ground",		true, 43], 44, 45, 46, 47, 
		// ["Wiggles",		true, 48], 49, 50, 51, 52, 
	];
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	////- Tools
	
	tool_attribute.context = 0;
	tool_ori_obj = new d3d_transform_tool_position(self);
	tool_ori     = new NodeTool( "Move Origin", THEME.tools_3d_transform, "Node_3D_Particle" ).setToolObject(tool_ori_obj);
	tools = [ tool_ori ];
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) { 
		var _ori = new __vec3(inputs[9].getValue(,,, true));
		
		if(isUsingTool("Move Origin")) tool_ori_obj.drawOverlay3D(9, noone, _ori, active, _mx, _my, _snx, _sny, _params);
	} 
	
	////- Node
	
	particleSystem = new __3dObjectParticle();
	pool_size      = INSTANCE_BATCH_SIZE;
	
	buffer_transform = [ undefined, undefined ];
	buffer_particle  = [ undefined, undefined ];
	buffer_particle2 = [ undefined, undefined ];
	
	curve_speed    = undefined;
	curve_rotation = undefined;
	curve_scale    = undefined;
	curve_alpha    = undefined;
	curve_path     = undefined;
	
	wig_psx = new wiggleMap(0, 1, 1000);
	wig_psy = new wiggleMap(0, 1, 1000);
	wig_scx = new wiggleMap(0, 1, 1000);
	wig_scy = new wiggleMap(0, 1, 1000);
	wig_rot = new wiggleMap(0, 1, 1000);
	wig_dir = new wiggleMap(0, 1, 1000);
	
	buffer_index   = 0;
	spawn_index    = 0;
	max_buffer_id  = 0;
	
	__path_temp    = new __vec3P();
	__vec3_temp    = new __vec3();
	__next_update_frame = 0;
	
	prerendering = false;
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _obj = _data[0];
		
		#region data
			_seed       = _data[ 1];
			
			_spawn      = _data[ 2];
			_spawn_type = _data[ 3];
			_spawn_trig = _data[ 4];
			_spawn_dely = _data[ 5];
			_spawn_dura = _data[ 6];
			_spawn_amou = _data[ 7];
			_lifespan   = _data[12];
			
			_spawn_sour = _data[ 8];
			_spawn_shap = _data[30];
			_spawn_orig = _data[ 9];
			_spawn_span = _data[27];
			_spawn_rota = _data[57];
			_spawn_path = _data[10];
			_spawn_mesh = _data[29];
			_spawn_data = _data[11];
			
			_velo_init  = _data[13];
			_accel      = _data[14];
			_sped_over  = _data[15];
			_velo_shape = _data[16];
			
			_rota_init  = _data[17];
			_rota_sped  = _data[18];
			_rota_over  = _data[19];
			_rota_snap  = _data[20];
			_rota_foll  = _data[54];
			
			_scal_init  = _data[21];
			_scal_fact  = _data[22];
			_scal_over  = _data[23];
			
			_colr_over  = _data[24];
			_colr_rand  = _data[25];
			_colr_indx  = _data[26]; _colr_indx_len  = array_length(_colr_indx); _colr_indx_typ = inputs[26].attributes.array_select;
			_alph_init  = _data[55];
			_alph_over  = _data[53];
			
			_blnd_mode  = _data[28];
			_billboard  = _data[32];
			_loop       = _data[31];
			_pre_rend   = _data[58]; if(_pre_rend == -1) _pre_rend = TOTAL_FRAMES;
			_transpar   = _data[33];
			
			_fpath_use  = _data[34];
			_fpath_path = _data[35]; 
			_fpath_rang = _data[56]; 
			_fpath_dev  = _data[36];
			
			_phys_use   = _data[37];
			_grav       = _data[38];
			_grav_dirr  = _data[39];
			_turn       = _data[40];
			_turn_both  = _data[41];
			_turn_sped  = _data[42];
			
			_grnd_use   = _data[43];
			_grnd_offt  = _data[44];
			_grnd_off   = _data[45];
			_grnd_boun  = _data[46];
			_grnd_fric  = _data[47];
			
			_wigg_use   = _data[48];
			_wigg_pos   = _data[49];
			_wigg_rot   = _data[50];
			_wigg_sca   = _data[51];
			_wigg_dir   = _data[52];
			
			inputs[ 4].setVisible(_spawn_type == 2);
			inputs[ 5].setVisible(_spawn_type != 2);
			inputs[ 6].setVisible(_spawn_type == 1);
			inputs[16].setVisible(_spawn_type == 0);
			
			inputs[30].setVisible(_spawn_sour == 0);
			inputs[10].setVisible(_spawn_sour == 1, _spawn_sour == 1);
			inputs[29].setVisible(_spawn_sour == 2, _spawn_sour == 2);
			inputs[11].setVisible(_spawn_sour == 3);
			
			inputs[35].setVisible(_fpath_use, _fpath_use);
			
			inputs[58].setVisible(_loop);
			if(!is_path(_fpath_path)) _fpath_use = false;
			
			     if(_spawn_type == 0) inputs[5].name = "Spawn Delay";
			else if(_spawn_type == 1) inputs[5].name = "Spawn Frame";
			
			buffer_transform[0]  = buffer_verify(buffer_transform[0], 64 * pool_size);
			buffer_transform[1]  = buffer_verify(buffer_transform[1], 64 * pool_size);
			
			buffer_particle[0]   = buffer_verify(buffer_particle[0],  64 * pool_size);
			buffer_particle[1]   = buffer_verify(buffer_particle[1],  64 * pool_size);
			
			buffer_particle2[0]  = buffer_verify(buffer_particle2[0], 16 * pool_size);
			buffer_particle2[1]  = buffer_verify(buffer_particle2[1], 16 * pool_size);
			
			_spawn_rota_q = new BBMOD_Quaternion(_spawn_rota[0], _spawn_rota[1], _spawn_rota[2], _spawn_rota[3]);
			_spawn_rota_m = _spawn_rota_q.ToMatrix();
			
			_colr_over.cache();
			_colr_rand.cache();
			
			if(IS_FIRST_FRAME || curve_speed    == undefined) curve_speed    = new curveMap(_sped_over);
			if(IS_FIRST_FRAME || curve_rotation == undefined) curve_rotation = new curveMap(_rota_over);
			if(IS_FIRST_FRAME || curve_scale    == undefined) curve_scale    = new curveMap(_scal_over);
			if(IS_FIRST_FRAME || curve_alpha    == undefined) curve_alpha    = new curveMap(_alph_over);
			if(IS_FIRST_FRAME || curve_path     == undefined) curve_path     = new curveMap(_fpath_dev);
			
			// wig_psx.check(_wigg_pos[0], _wigg_pos[1], _seed + 10);
			// wig_psy.check(_wigg_pos[0], _wigg_pos[1], _seed + 20);
			// wig_rot.check(_wigg_rot[0], _wigg_rot[1], _seed + 30);
			// wig_scx.check(_wigg_sca[0], _wigg_sca[1], _seed + 40);
			// wig_scy.check(_wigg_sca[0], _wigg_sca[1], _seed + 50);
			// wig_dir.check(_wigg_dir[0], _wigg_dir[1], _seed + 60);
			
		#endregion
		
		if(!is(_obj, __3dInstance)) return noone;
		
		#region base instancer
			var system = particleSystem;
			
			if(IS_FIRST_FRAME) {
				system.instance_amount = pool_size;
				system.transparent     = _transpar;
				
				system.objectTransform = _obj.transform;
				system.objectTransform.applyMatrix();
				
				var _flat_vb = d3d_flattern(_obj);
				system.VB = _flat_vb.VB;
				system.materials = _flat_vb.materials;
				
				buffer_clear(buffer_transform[0]);
				buffer_clear(buffer_transform[1]);
				
				buffer_clear(buffer_particle[0]);
				buffer_clear(buffer_particle[1]);
				
				buffer_clear(buffer_particle2[0]);
				buffer_clear(buffer_particle2[1]);
				
				buffer_index   = 0;
				spawn_index    = 0;
				max_buffer_id  = 0;
			}
			
		#endregion
		
		#region constant buffer
			if(IS_FIRST_FRAME) {
				if(_loop) {
					prerendering = true;
					for( var i = TOTAL_FRAMES - _pre_rend; i < TOTAL_FRAMES; i++ ) vfxStep(i);
					prerendering = false;
					spawn_index  = 0;
				}
				
				__next_update_frame = CURRENT_FRAME;
			} 
			
			if(__next_update_frame == CURRENT_FRAME) {	
				__next_update_frame = CURRENT_FRAME + 1;
				vfxStep(CURRENT_FRAME);
			}
			
			var _wbTran  = buffer_transform[ buffer_index ];
			var _wbPart  = buffer_particle[  buffer_index ];
			
			system.batch_count = 1;
			system.setBuffer(         _wbTran, 0, max_buffer_id );
			system.setBufferParticle( _wbPart, 0, max_buffer_id );
			
			switch(_blnd_mode) {
				case 0 : system.blend_mode = BLEND.normal;  break;
				case 1 : system.blend_mode = BLEND.alpha;   break;
				case 2 : system.blend_mode = BLEND.add;     break;
				case 3 : system.blend_mode = BLEND.maximum; break;
			}
			
		#endregion
		
		#region preview
			spawn_gizmo = noone;
			tools       = [];
			
			if(_spawn_sour == 0) {
				tools = [ tool_ori ];
				switch(_spawn_shap) {
					case 0 : spawn_gizmo = spawn_gizmo_box;     break;
					case 1 : spawn_gizmo = spawn_gizmo_sphere;  break;
					case 2 : spawn_gizmo = spawn_gizmo_circle;  break;
				}
				
			} 
			
			if(spawn_gizmo != noone) {
				spawn_gizmo.transform.position.set( _spawn_orig );
				spawn_gizmo.transform.scale.set(    _spawn_span );
				spawn_gizmo.transform.rotation.set( _spawn_rota[0], _spawn_rota[1], _spawn_rota[2], _spawn_rota[3] );
				spawn_gizmo.transform.applyMatrix();
			}
		#endregion
		
		return system;
	}
	
	static vfxStep = function(_t) {
		#region data
			var _rbTran = buffer_transform[  buffer_index ]; buffer_to_start(_rbTran);
			var _wbTran = buffer_transform[ !buffer_index ]; buffer_to_start(_wbTran);
			
			var _rbPart = buffer_particle[  buffer_index ];  buffer_to_start(_rbPart);
			var _wbPart = buffer_particle[ !buffer_index ];  buffer_to_start(_wbPart);
			
			var _rbPart2 = buffer_particle2[  buffer_index ];  buffer_to_start(_rbPart2);
			var _wbPart2 = buffer_particle2[ !buffer_index ];  buffer_to_start(_wbPart2);
			
			buffer_index = !buffer_index;
			var system   = particleSystem;
			
			var _i = 0;
			var _toSpawn = 0;
			var _doSpawn = false;
			
			if(_spawn) {
				var _doSpawn = false;
				switch(_spawn_type) {
					case 0 : _doSpawn = safe_mod(_t, _spawn_dely) == 0;                      break;
					case 1 : _doSpawn = _t >= _spawn_dely && _t < _spawn_dely + _spawn_dura; break;
					case 2 : _doSpawn = _spawn_trig;                                         break;
				}
				
			}
			
			random_set_seed(_seed + _t);
			if(_doSpawn) _toSpawn = irandom_range(_spawn_amou[0], _spawn_amou[1]);
		#endregion
		
		var rep = min(pool_size, max_buffer_id + _toSpawn + 1);
		
		repeat(rep) {
			
			var _px = buffer_read(_rbTran, buffer_f32), _plx = _px;
			var _py = buffer_read(_rbTran, buffer_f32), _ply = _py;
			var _pz = buffer_read(_rbTran, buffer_f32), _plz = _pz;
			          buffer_read(_rbTran, buffer_f32);
			
			var _rx = buffer_read(_rbTran, buffer_f32);
			var _ry = buffer_read(_rbTran, buffer_f32);
			var _rz = buffer_read(_rbTran, buffer_f32);
			          buffer_read(_rbTran, buffer_f32);
			
			var _sx = buffer_read(_rbTran, buffer_f32);
			var _sy = buffer_read(_rbTran, buffer_f32);
			var _sz = buffer_read(_rbTran, buffer_f32);
			          buffer_read(_rbTran, buffer_f32);
			
			var _nx = buffer_read(_rbTran, buffer_f32);
			var _ny = buffer_read(_rbTran, buffer_f32);
			var _nz = buffer_read(_rbTran, buffer_f32);
			          buffer_read(_rbTran, buffer_f32);
			
			var _curr_act = buffer_read(_rbPart, buffer_f32);
			var _spwn_ind = buffer_read(_rbPart, buffer_f32);
			var _life_max = buffer_read(_rbPart, buffer_f32);
			var _life_cur = buffer_read(_rbPart, buffer_f32);
			
			var _flag = buffer_read(_rbPart, buffer_f32);
			            buffer_read(_rbPart, buffer_f32);
			            buffer_read(_rbPart, buffer_f32);
			            buffer_read(_rbPart, buffer_f32);
			
			var _cr = buffer_read(_rbPart, buffer_f32); _cr = 1;
			var _cg = buffer_read(_rbPart, buffer_f32); _cg = 1;
			var _cb = buffer_read(_rbPart, buffer_f32); _cb = 1;
			var _ca = buffer_read(_rbPart, buffer_f32); _ca = 1;
			
			var _vx = buffer_read(_rbPart, buffer_f32);
			var _vy = buffer_read(_rbPart, buffer_f32);
			var _vz = buffer_read(_rbPart, buffer_f32);
			          buffer_read(_rbPart, buffer_f32);
			
			var _psx = buffer_read(_rbPart2, buffer_f32);
			var _psy = buffer_read(_rbPart2, buffer_f32);
			var _psz = buffer_read(_rbPart2, buffer_f32);
			           buffer_read(_rbPart2, buffer_f32);
			
			if(_curr_act == 0 && _toSpawn) {
				_spwn_ind = spawn_index++;
				random_set_seed(_seed + _spwn_ind * 78);
				
				////- Spawn
				
				_vx = random_range(_velo_init[0], _velo_init[1]);
				_vy = random_range(_velo_init[2], _velo_init[3]);
				_vz = random_range(_velo_init[4], _velo_init[5]);
				
				var _vv = random_range(_velo_shape[0], _velo_shape[1]);
				
				switch(_spawn_sour) {
					case 0 : // Shape
						
						_px = _spawn_orig[0];
						_py = _spawn_orig[1];
						_pz = _spawn_orig[2];
						
						switch(_spawn_shap) {
							case 0 : 
								__vec3_temp.x = _spawn_span[0] * random_range(-1, 1);
								__vec3_temp.y = _spawn_span[1] * random_range(-1, 1);
								__vec3_temp.z = _spawn_span[2] * random_range(-1, 1);
								
								var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
								
								_px += __v[0];
								_py += __v[1];
								_pz += __v[2];
								
								if(_vv != 0) {
									var _snx = _px - _spawn_orig[0];
									var _sny = _py - _spawn_orig[1];
									var _snz = _pz - _spawn_orig[2];
									
									var _nn = sqrt(_snx * _snx + _sny * _sny + _snz * _snz);
									
									_vx += _snx / _nn * _vv;
									_vy += _sny / _nn * _vv;
									_vz += _snz / _nn * _vv;
								}
								break;
								
							case 1 : 
								var theta = random(360);
							    var phi   = random(180);
							    var r     = random(1);
								
								__vec3_temp.x = _spawn_span[0] * r * dsin(phi) * dcos(theta);
								__vec3_temp.y = _spawn_span[1] * r * dsin(phi) * dsin(theta);
								__vec3_temp.z = _spawn_span[2] * r * dcos(phi);
								
								var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
								
								_px += __v[0];
								_py += __v[1];
								_pz += __v[2];
								
								if(_vv != 0) {
									var _snx = _px - _spawn_orig[0];
									var _sny = _py - _spawn_orig[1];
									var _snz = _pz - _spawn_orig[2];
									
									var _nn = sqrt(_snx * _snx + _sny * _sny + _snz * _snz);
									
									_vx += _snx / _nn * _vv;
									_vy += _sny / _nn * _vv;
									_vz += _snz / _nn * _vv;
								}
								break;
								
							case 2 : 
								var theta = random(360);
								
								__vec3_temp.x = _spawn_span[0] * dcos(theta);
								__vec3_temp.y = _spawn_span[1] * dsin(theta);
								__vec3_temp.z = 0;
								
								var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
								
								_px += __v[0];
								_py += __v[1];
								_pz += __v[2];
								
								if(_vv != 0) {
									__vec3_temp.x = _px - _spawn_orig[0];
									__vec3_temp.y = _py - _spawn_orig[1];
									__vec3_temp.z = _pz - _spawn_orig[2];
									
									var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
									var _nn = sqrt(__v[0] * __v[0] + __v[1] * __v[1] + __v[2] * __v[2]);
									
									_vx += __v[0] / _nn * _vv;
									_vy += __v[1] / _nn * _vv;
									_vz += __v[2] / _nn * _vv;
								}
								break;
								
						}
						
						break;
						
					case 1 : // Path
						if(!is_path(_spawn_path)) return;
						
						var _path_prog = random(1);
						_spawn_path.getPointRatio(_path_prog, 0, __path_temp);
						
						_px = __path_temp.x + _spawn_span[0] * random_range(-1, 1);
						_py = __path_temp.y + _spawn_span[1] * random_range(-1, 1);
						_pz = __path_temp.z + _spawn_span[2] * random_range(-1, 1);
						break;
					
					case 2 : // Vert
						if(!is(_spawn_mesh, __3dObject))    return;
						if(array_empty(_spawn_mesh.vertex)) return;
						
						var _vi = irandom(array_length(_spawn_mesh.vertex) - 1);
						var _vs = _spawn_mesh.vertex[_vi];
						var _vi = irandom(array_length(_vs) - 1);
						
						var _v = _vs[_vi];
						
						_px = _v.x + _spawn_span[0] * random_range(-1, 1);
						_py = _v.y + _spawn_span[1] * random_range(-1, 1);
						_pz = _v.z + _spawn_span[2] * random_range(-1, 1);
						break;
						
					case 3 : // Data
						if(array_empty(_spawn_data)) return;
						var _spwn_data = _spawn_data[irandom(array_length(_spawn_data) - 1)];
						
						_px = _spwn_data[0] + _spawn_span[0] * random_range(-1, 1);
						_py = _spwn_data[1] + _spawn_span[1] * random_range(-1, 1);
						_pz = _spwn_data[2] + _spawn_span[2] * random_range(-1, 1);
						break;
						
				}
				
				_rx = random_range(_rota_init[0], _rota_init[1]);
				_ry = random_range(_rota_init[2], _rota_init[3]);
				_rz = random_range(_rota_init[4], _rota_init[5]);
				
				_psx = _px;
				_psy = _py;
				_psz = _pz;

				_life_max = random_range(_lifespan[0], _lifespan[1]);
				_life_cur = 0;
				
				_flag = _flag | (_billboard * 0b0001);
				
				_toSpawn--;
				_curr_act = 1;
				max_buffer_id = max(max_buffer_id, _i);
			} 
			
			if(_curr_act) {
				random_set_seed(_seed + _spwn_ind * 78);
				
				var rat = _life_cur / _life_max;
				
				var _acx = random_range(_accel[0], _accel[1]);
				var _acy = random_range(_accel[2], _accel[3]);
				var _acz = random_range(_accel[4], _accel[5]);
				
				var _vss = curve_speed.get(rat);
				
				_vx += (_acx * _life_cur) * _vss;
				_vy += (_acy * _life_cur) * _vss;
				_vz += (_acz * _life_cur) * _vss;
				
				if(_fpath_use) {
					var _rang0 = random_range(_fpath_rang[0], _fpath_rang[1]);
					var _rang1 = random_range(_fpath_rang[2], _fpath_rang[3]);
					var _prat  = lerp(_rang0, _rang1, rat);
					
					__path_temp.z = 0;
					_fpath_path.getPointRatio(clamp(_prat, 0, .999), 0, __path_temp);
					
					var _pdiv = curve_path.get(_prat);
					var _ptx  = __path_temp.x + _psx * _pdiv;
					var _pty  = __path_temp.y + _psy * _pdiv;
					var _ptz  = __path_temp.z + _psz * _pdiv;
						
					_vx = _ptx - _px;
					_vy = _pty - _py;
					_vz = _ptz - _pz;
				}
				
				if(_phys_use) {
					_vz -= random_range(_grav[0], _grav[1]);
					// _turn
					// _turn_both
					// _turn_sped
				}
				
				if(_grnd_use) {
					var _grn_z = random_range(_grnd_off[0], _grnd_off[1]);
					
					if(_pz + _vz < _grn_z) {
						_pz = _grn_z;
						_vz = -_vz * _grnd_boun;
						
						if(abs(_vz) < 0.1) {
							_vx *= _grnd_fric;
							_vy *= _grnd_fric;
						}
					}
					
				}
				
				// if(_wigg_use) {
					// _wigg_pos
					// _wigg_rot
					// _wigg_sca
					// _wigg_dir
				// }
				
				_px += _vx * _vss;
				_py += _vy * _vss;
				_pz += _vz * _vss;
				
				var _rvx = random_range(_rota_sped[0], _rota_sped[1]);
				var _rvy = random_range(_rota_sped[2], _rota_sped[3]);
				var _rvz = random_range(_rota_sped[4], _rota_sped[5]);
				
				var _rss = curve_rotation.get(rat);
				
				_rx += _rvx * _rss;
				_ry += _rvy * _rss;
				_rz += _rvz * _rss;
				
				var _sca = curve_scale.get(rat) * random_range(_scal_fact[0], _scal_fact[1]);
				
				_sx = random_range(_scal_init[0], _scal_init[1]) * _sca;
				_sy = random_range(_scal_init[2], _scal_init[3]) * _sca;
				_sz = random_range(_scal_init[4], _scal_init[5]) * _sca;
				
				if(_rota_foll && _life_cur > 0) {
					_nx = _vx;
					_ny = _vy;
					_nz = _vz;
				}
				
				_life_cur++;
				if(_life_cur > _life_max) _curr_act = 0;
				
				var c0 = _colr_over.eval(rat);
				var c1 = _colr_rand.eval(random(1));
				
				var clti  = _spwn_ind;
				switch(_colr_indx_typ) {
					case 0  : clti = _spwn_ind % _colr_indx_len;                break;
					case 1  : clti = pingpong_value(_spwn_ind, _colr_indx_len); break;
					case 2  : clti = irandom(_colr_indx_len - 1);               break;
				}
				
				var c2   = array_safe_get(_colr_indx, clti, ca_white);
				var cc   = colorMultiply(c0, colorMultiply(c1, c2));
				var _alp = random_range(_alph_init[0], _alph_init[1]) * curve_alpha.get(rat); 
				
				_cr = _color_get_r(cc);
				_cg = _color_get_g(cc);
				_cb = _color_get_b(cc);
				_ca = _color_get_a(cc) * _alp;
			}
			
			buffer_write(_wbTran, buffer_f32, _px); // pos X
			buffer_write(_wbTran, buffer_f32, _py); // pos Y
			buffer_write(_wbTran, buffer_f32, _pz); // pos Z
			buffer_write(_wbTran, buffer_f32, 0);
			
			buffer_write(_wbTran, buffer_f32, _rx); // rot X 
			buffer_write(_wbTran, buffer_f32, _ry); // rot Y 
			buffer_write(_wbTran, buffer_f32, _rz); // rot Z
			buffer_write(_wbTran, buffer_f32, 0);
			
			buffer_write(_wbTran, buffer_f32, _sx); // sca X 
			buffer_write(_wbTran, buffer_f32, _sy); // sca Y 
			buffer_write(_wbTran, buffer_f32, _sz); // sca Z
			buffer_write(_wbTran, buffer_f32, 0);
			
			buffer_write(_wbTran, buffer_f32, _nx); // norm X
			buffer_write(_wbTran, buffer_f32, _ny); // norm Y
			buffer_write(_wbTran, buffer_f32, _nz); // norm Z
			buffer_write(_wbTran, buffer_f32, 0);
			
			buffer_write(_wbPart, buffer_f32, _curr_act); // active
			buffer_write(_wbPart, buffer_f32, _spwn_ind); // particle index
			buffer_write(_wbPart, buffer_f32, _life_max); // life max
			buffer_write(_wbPart, buffer_f32, _life_cur); // life curr
			
			buffer_write(_wbPart, buffer_f32, _flag); // render flag
			buffer_write(_wbPart, buffer_f32, 0); // 
			buffer_write(_wbPart, buffer_f32, 0); // 
			buffer_write(_wbPart, buffer_f32, 0); // 
			
			buffer_write(_wbPart, buffer_f32, _cr); // color R
			buffer_write(_wbPart, buffer_f32, _cg); // color G
			buffer_write(_wbPart, buffer_f32, _cb); // color B
			buffer_write(_wbPart, buffer_f32, _ca); // color A
			
			buffer_write(_wbPart, buffer_f32, _vx); // velocity X
			buffer_write(_wbPart, buffer_f32, _vy); // velocity Y
			buffer_write(_wbPart, buffer_f32, _vz); // velocity Z
			buffer_write(_wbPart, buffer_f32, 0);
			
			buffer_write(_wbPart2, buffer_f32, _psx); // start position X
			buffer_write(_wbPart2, buffer_f32, _psy); // start position Y
			buffer_write(_wbPart2, buffer_f32, _psz); // start position Z
			buffer_write(_wbPart2, buffer_f32, 0);
			
			_i++;
		}
	}
	
	////- Draw
	
	static getPreviewObject        = function() /*=>*/ {return particleSystem};
	static getPreviewObjects       = function() /*=>*/ {return [ particleSystem, spawn_gizmo ]};
	static getPreviewObjectOutline = function() /*=>*/ {return isUsingTool("Move Origin")? [ spawn_gizmo ] : [ particleSystem ]};
	
	static onCleanUp = function() {
		buffer_delete_safe(buffer_transform[0]);
		buffer_delete_safe(buffer_transform[1]);
		
		buffer_delete_safe(buffer_particle[0]);
		buffer_delete_safe(buffer_particle[1]);
		
		buffer_delete_safe(buffer_particle2[0]);
		buffer_delete_safe(buffer_particle2[1]);
	}
}