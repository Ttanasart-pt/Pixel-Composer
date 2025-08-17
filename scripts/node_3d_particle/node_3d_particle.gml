function Node_3D_Particle(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Particle";
	update_on_frame = true;
	
	var i = in_mesh;
	newInput(i+ 0, nodeValueSeed());
	
	////- =Spawn
	newInput(i+ 1, nodeValue_Bool(        "Spawn",             true       ));
	newInput(i+ 2, nodeValue_Enum_Scroll( "Spawn Type",        0,         )).setChoices([ "Stream", "Burst", "Trigger" ]);
	newInput(i+ 3, nodeValue_Trigger(     "Spawn Trigger",                ));
	newInput(i+ 4, nodeValue_Int(         "Spawn Delay",       4          )).setTooltip("Frames delay between each particle spawn.");
	newInput(i+ 5, nodeValue_Int(         "Burst Duration",    1          ));
	newInput(i+ 6, nodeValue_Range(       "Spawn Amount",     [2,2], true )).setTooltip("Amount of particle spawn in that frame.");
	newInput(i+ 7, nodeValue_Enum_Scroll( "Spawn Source",      0,         )).setChoices([ "Area", "Path", "Mesh Vertices", "Direct Data" ]);
	newInput(i+ 8, nodeValue_Vec3(        "Spawn Origin",     [0,0,0]     ));
	newInput(i+26, nodeValue_Vec3(        "Spawn Span",       [1,1,1]     ));
	newInput(i+ 9, nodeValue_PathNode(    "Spawn Path"                    ));
	newInput(i+10, nodeValue_Vector(      "Spawn Data"                    )).setArrayDepth(1);
	newInput(i+11, nodeValue_Range(       "Lifespan",         [20,30]     ));
	
	////- =Movement
	newInput(i+12, nodeValue_Vec3_Range(  "Initial Velocity",           [0,0,0,0,0,0] )); 
	newInput(i+13, nodeValue_Vec3_Range(  "Initial Acceleration",       [0,0,0,0,0,0] )); 
	newInput(i+14, nodeValue_Curve(       "Speed Over Time",            CURVE_DEF_11  )).setTooltip("Speed may conflict with physics-based properties.");
	newInput(i+15, nodeValue_Bool(        "Directed From Center",       false         )).setTooltip("Make particle move away from the spawn center.");
	
	////- =Rotation
	newInput(i+16, nodeValue_Vec3_Range(  "Initial Rotation",           [0,0,0,0,0,0] ));
	newInput(i+17, nodeValue_Vec3_Range(  "Rotational Speed",           [0,0,0,0,0,0] ));
	newInput(i+18, nodeValue_Curve(       "Rotational Speed Over Time", CURVE_DEFN_11 ));
	newInput(i+19, nodeValue_Float(       "Snap Rotation",              0             ));
	
	////- =Scale
	newInput(i+20, nodeValue_Vec3_Range(  "Initial Scale",              [1,1,1,1,1,1] ));
	newInput(i+21, nodeValue_Vec3(        "Initial Size",               [1,1,1]       ));
	newInput(i+22, nodeValue_Curve(       "Scale Over Time",            CURVE_DEF_11  ));
	
	////- =Color
	newInput(i+23, nodeValue_Gradient(    "Color Over Lifetime",        new gradientObject(ca_white)  ));
	newInput(i+24, nodeValue_Gradient(    "Random Blend",               new gradientObject(ca_white)  ));
	newInput(i+25, nodeValue_Palette(     "Color by Index",             [ca_white]                    ));
	// i+27
	
	input_display_list = [ i+0, 
		[ "Object",   true ], 0, 
		[ "Spawn",    true ], i+ 1, i+ 2, i+ 3, i+ 4, i+ 5, i+ 6, i+ 7, i+ 8, i+26, i+ 9, i+10, i+11,  
		[ "Movement", true ], i+12, i+13, i+14, i+15, 
		[ "Rotation", true ], i+16, i+17, i+18, i+19, 
		[ "Scale",    true ], i+20, i+21, i+22, 
		[ "Color",    true ], i+23, i+24, i+25, 
	];
	
	////- Node
	
	particleSystem = new __3dObjectParticle();
	pool_size      = 64;
	
	buffer_transform = [ undefined, undefined ];
	buffer_particle  = [ undefined, undefined ];
	
	curve_speed    = undefined;
	curve_rotation = undefined;
	curve_scale    = undefined;
	
	buffer_index   = 0;
	spawn_index    = 0;
	
	static vfxStep = function(_t) {
		var _rbTran = buffer_transform[  buffer_index ]; buffer_to_start(_rbTran);
		var _wbTran = buffer_transform[ !buffer_index ]; buffer_to_start(_wbTran);
		
		var _rbPart = buffer_particle[  buffer_index ];  buffer_to_start(_rbPart);
		var _wbPart = buffer_particle[ !buffer_index ];  buffer_to_start(_wbPart);
		
		buffer_index = !buffer_index;
		var system = particleSystem;
		
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
		
		repeat(pool_size) {
			
			var _px = buffer_read(_rbTran, buffer_f32);
			var _py = buffer_read(_rbTran, buffer_f32);
			var _pz = buffer_read(_rbTran, buffer_f32);
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
			
			var _curr_act = buffer_read(_rbPart, buffer_s32);
			var _spwn_ind = buffer_read(_rbPart, buffer_s32);
			var _life_max = buffer_read(_rbPart, buffer_f32);
			var _life_cur = buffer_read(_rbPart, buffer_f32);
			
			var _cr = buffer_read(_rbPart, buffer_f32); _cr = 1;
			var _cg = buffer_read(_rbPart, buffer_f32); _cg = 1;
			var _cb = buffer_read(_rbPart, buffer_f32); _cb = 1;
			var _ca = buffer_read(_rbPart, buffer_f32); _ca = 1;
			
			if(_curr_act == 0 && _toSpawn) {
				_spwn_ind = spawn_index++;
				random_set_seed(_seed + _spwn_ind * 78);
				
				////- Spawn
				
				switch(_spawn_sour) {
					case 0 : // Area
						_px = _spawn_orig[0] + _spawn_span[0] * random_range(-1, 1);
						_py = _spawn_orig[1] + _spawn_span[1] * random_range(-1, 1);
						_pz = _spawn_orig[2] + _spawn_span[2] * random_range(-1, 1);
						break;
						
					case 1 : // Path
						break;
					
					case 2 : // Vert
						break;
						
					case 3 : // Data
						break;
						
				}
				
				_rx = random_range(_rota_init[0], _rota_init[1]);
				_ry = random_range(_rota_init[2], _rota_init[3]);
				_rz = random_range(_rota_init[4], _rota_init[5]);
				
				_sx = _scal_fact[0] * random_range(_scal_init[0], _scal_init[1]);
				_sy = _scal_fact[1] * random_range(_scal_init[2], _scal_init[3]);
				_sz = _scal_fact[2] * random_range(_scal_init[4], _scal_init[5]);
				
				_life_max = random_range(_lifespan[0], _lifespan[1]);
				_life_cur = 0;
				
				_toSpawn--;
				_curr_act = 1;
				
				// print($"Spawn index {_spwn_ind}, frame {_t}: ", _px, _py, _pz);
				
			} else if(_curr_act) {
				random_set_seed(_seed + _spwn_ind * 78);
				
				var rat = _life_cur / _life_max;
				
				var _vx = random_range(_velo_init[0], _velo_init[1]);
				var _vy = random_range(_velo_init[2], _velo_init[3]);
				var _vz = random_range(_velo_init[4], _velo_init[5]);
				
				var _acx = random_range(_accel[0], _accel[1]);
				var _acy = random_range(_accel[2], _accel[3]);
				var _acz = random_range(_accel[4], _accel[5]);
				
				var _vss = curve_speed.get(rat);
				
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
				
				var _sca = curve_scale.get(rat);
				
				_sx *= _sca;
				_sy *= _sca;
				_sz *= _sca;
				
				_life_cur++;
				if(_life_cur > _life_max) _curr_act = 0;
				
				
				var c0 = _colr_over.eval(rat);
				var c1 = _colr_rand.eval(random(1));
				var c2 = _colr_indx[_spwn_ind % array_length(_colr_indx)];
				
				var cc = colorMultiply(c0, colorMultiply(c1, c2));
				
				_cr = _color_get_r(cc);
				_cg = _color_get_g(cc);
				_cb = _color_get_b(cc);
				_ca = _color_get_a(cc);
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
			
			buffer_write(_wbPart, buffer_s32, _curr_act); // active
			buffer_write(_wbPart, buffer_s32, _spwn_ind); // mesh index
			buffer_write(_wbPart, buffer_f32, _life_max); // life max
			buffer_write(_wbPart, buffer_f32, _life_cur); // life curr
			
			buffer_write(_wbPart, buffer_f32, _cr); // color R
			buffer_write(_wbPart, buffer_f32, _cg); // color G
			buffer_write(_wbPart, buffer_f32, _cb); // color B
			buffer_write(_wbPart, buffer_f32, _ca); // color A
			
			_i++;
		}
		
	}
	
	static processData = function(_output, _data, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject))		return noone;
		if(_obj.VF != global.VF_POS_NORM_TEX_COL)	return noone;
		
		#region data
			var i = in_mesh;
			_seed       = _data[i+ 0];
			
			_spawn      = _data[i+ 1];
			_spawn_type = _data[i+ 2];
			_spawn_trig = _data[i+ 3];
			_spawn_dely = _data[i+ 4];
			_spawn_dura = _data[i+ 5];
			_spawn_amou = _data[i+ 6];
			_spawn_sour = _data[i+ 7];
			_spawn_orig = _data[i+ 8];
			_spawn_span = _data[i+26];
			_spawn_path = _data[i+ 9];
			_spawn_data = _data[i+10];
			_lifespan   = _data[i+11];
			
			_velo_init  = _data[i+12];
			_accel      = _data[i+13];
			_sped_over  = _data[i+14];
			_direct_cen = _data[i+15];
			
			_rota_init  = _data[i+16];
			_rota_sped  = _data[i+17];
			_rota_over  = _data[i+18];
			_rota_snap  = _data[i+19];
			
			_scal_init  = _data[i+20];
			_scal_fact  = _data[i+21];
			_scal_over  = _data[i+22];
			
			_colr_over  = _data[i+23];
			_colr_rand  = _data[i+24];
			_colr_indx  = _data[i+25];
			
			inputs[i+ 3].setVisible(_spawn_type == 2);
			inputs[i+ 4].setVisible(_spawn_type != 2);
			inputs[i+ 5].setVisible(_spawn_type == 1);
			
			inputs[i+26].setVisible(_spawn_sour == 0);
			inputs[i+ 9].setVisible(_spawn_sour == 1);
			inputs[i+10].setVisible(_spawn_sour == 3);
			
			     if(_spawn_type == 0) inputs[i+4].name = "Spawn Delay";
			else if(_spawn_type == 1) inputs[i+4].name = "Spawn Frame";
			
			buffer_transform[0] = buffer_verify(buffer_transform[0], 64 * pool_size);
			buffer_transform[1] = buffer_verify(buffer_transform[1], 64 * pool_size);
			
			buffer_particle[0]  = buffer_verify(buffer_particle[0],  32 * pool_size);
			buffer_particle[1]  = buffer_verify(buffer_particle[1],  32 * pool_size);
			
			_colr_over.cache();
			_colr_rand.cache();
		#endregion
			
		#region base instancer
			var system = particleSystem;
			
			if(IS_FIRST_FRAME) {
				system.instance_amount = pool_size;
				system.render_type     = _obj.render_type;
				system.custom_shader   = _obj.custom_shader;
				system.size            = _obj.size.clone();
				system.materials       = _obj.materials;
				system.material_index  = _obj.material_index;
				system.texture_flip    = _obj.texture_flip;
				system.vertex          = _obj.vertex;
				system.objectTransform = _obj.transform;
				system.objectTransform.applyMatrix();
				
				var _flat_vb = d3d_flattern(_obj);
				
				system.VBM = _flat_vb.VBM;
				system.VF  = _obj.VF;
				system.VB  = [];
				
				for( var i = 0, n = array_length(_flat_vb.VB); i < n; i++ ) {
					system.VB[i] = vertex_buffer_clone(_flat_vb.VB[i], _obj.VF);
					vertex_freeze(system.VB[i]);
				}
				
				buffer_clear(buffer_transform[0]);
				buffer_clear(buffer_transform[1]);
				
				buffer_clear(buffer_particle[0]);
				buffer_clear(buffer_particle[1]);
				
				curve_speed    = new curveMap(_sped_over);
				curve_rotation = new curveMap(_rota_over);
				curve_scale    = new curveMap(_scal_over);
				
				buffer_index   = 0;
				spawn_index    = 0;
			}
			
			if(curve_speed    == undefined) curve_speed    = new curveMap(_sped_over);
			if(curve_rotation == undefined) curve_rotation = new curveMap(_rota_over);
			if(curve_scale    == undefined) curve_scale    = new curveMap(_scal_over);
		#endregion
		
		#region constant buffer
			if(IS_FIRST_FRAME) {
				for( var i = 0; i < TOTAL_FRAMES - 1; i++ ) vfxStep(i);
				spawn_index = 0;
				vfxStep(0);
				
			} else {
				vfxStep(CURRENT_FRAME);
			}
			
			var _wbTran = buffer_transform[ buffer_index ];
			var _wbPart = buffer_particle[ buffer_index ];
			
			system.setBuffer(_wbTran);
			system.setBufferParticle(_wbPart);
		#endregion
		
		return system;
	}
	
	static onCleanUp = function() {
		buffer_delete_safe(buffer_transform[0]);
		buffer_delete_safe(buffer_transform[1]);
		
		buffer_delete_safe(buffer_particle[0]);
		buffer_delete_safe(buffer_particle[1]);
	}
}