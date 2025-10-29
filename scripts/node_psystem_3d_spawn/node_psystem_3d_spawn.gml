#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_pSystem_3D_Spawn", "Move Origin", "G");
	});
	
#endregion

function Node_pSystem_3D_Spawn(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Spawn";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	update_on_frame = true;
	node_draw_icon  = s_node_psystem_3d_spawn;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	spawn_gizmo = noone;
	spawn_gizmo_box    = new __3dGizmoBox(     1, c_white, .75 );
	spawn_gizmo_sphere = new __3dGizmoSphere(  1, c_white, .75 );
	spawn_gizmo_circle = new __3dGizmoCircleZ( 1, c_white, .75 );
	
	newInput(6, nodeValueSeed());
	
	////- =Spawn
	newInput( 0, nodeValue_Enum_Scroll( "Spawn Type", 0, [ "Stream", "Burst", "Trigger" ] ));
	newInput( 1, nodeValue_Trigger(     "Spawn Trigger",                ));
	newInput( 2, nodeValue_Int(         "Spawn Delay",       4          )).setTooltip("Frames delay between each particle spawn.");
	newInput( 3, nodeValue_Int(         "Burst Duration",    1          ));
	newInput( 4, nodeValue_Range(       "Spawn Amount",     [2,2], true )).setTooltip("Amount of particle spawn in that frame.");
	newInput( 5, nodeValue_Range(       "Lifespan",         [20,30]     ));
	
	////- =Source
	newInput( 7, nodeValue_Enum_Scroll( "Type",      0,         )).setChoices([ "Shape", "Path", "Mesh Vertices", "Direct Data" ]);
	newInput( 8, nodeValue_Enum_Scroll( "Shape",     0,         )).setChoices(__enum_array_gen([ "Box", "Sphere", "Circle" ], s_node_particle_3d_spawn_shape));
	newInput( 9, nodeValue_Vec3(        "Origin",   [0,0,0]     ));
	newInput(10, nodeValue_Vec3(        "Span",     [1,1,1]     ));
	newInput(11, nodeValue_Quaternion(  "Rotation", [0,0,0,1]   ));
	newInput(12, nodeValue_PathNode(    "Path"                  ));
	newInput(13, nodeValue_D3Mesh(      "Mesh"                  ));
	newInput(14, nodeValue_Vector(      "Data"                  )).setArrayDepth(1);
	
	////- =Transform
	newInput(15, nodeValue_Range(      "Inherit Velocity", [0,0], true   ));
	newInput(16, nodeValue_Vec3_Range( "Velocity",         [0,0,0,0,0,0] ));
	newInput(24, nodeValue_Range(       "Follow Spawn Shape",   [0,0], true   ));
	newInput(17, nodeValue_Vec3_Range( "Rotation",         [0,0,0,0,0,0] ));
	newInput(18, nodeValue_Vec3_Range( "Scale",            [1,1,1,1,1,1] ));
	
	////- =Render
	newInput(19, nodeValue_Gradient( "Base Color",     gra_white  ));
	newInput(20, nodeValue_Palette(  "Color by Index", [ca_white] )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(21, nodeValue_Range(    "Alpha",          [1,1], { linked : true } ));
	
	////- =Events
	newInput(22, nodeValue_Range(   "Step Period", [1,1], true )).setCurvable(23, CURVE_DEF_11, "Over Lifespan");
	// input 25
	
	newOutput(0, nodeValue_Output("Particles",  VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output("On Spawn",   VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(2, nodeValue_Output("On Step",    VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(3, nodeValue_Output("On Destroy", VALUE_TYPE.trigger,  false )).setVisible(false);
	
	input_display_list = [ 6, 
		[ "Spawn",     false ], 0, 1, 2, 3, 4, 5, 
		[ "Source",    false ], 7, 8, 9, 10, 11, 12, 13, 14, 
		[ "Transform", false ], 15, 16, 24, 17, 18, 
		[ "Render",    false ], 19, 20, 21, 
		[ "Events",    false ], 22, 23, 
	];
	
	////- Nodes
	
	partPool    = undefined;
	spawn_index = 0;
	spawn_trigger_loop_frame = undefined;
	
	attributes.poolSize = 1024;
	array_push(attributeEditors, [ "Pool Size", function() /*=>*/ {return attributes.poolSize}, textBox_Number(function(v) /*=>*/ {return setAttribute("poolSize", v)}) ]);
	
	curve_step = undefined;
	
	spawnTrig   = undefined; spawnCount   = 0;
	stepTrig    = undefined; stepCount    = 0;
	destroyTrig = undefined; destroyCount = 0;
	
	__path_temp = new __vec3P();
	__vec3_temp = new __vec3();
	cache_grad = undefined;
	point_dist_cache = [];
	
	static step = function() {}
	
	////- Tools
	
	tool_attribute.context = 0;
	tool_ori_obj = new d3d_transform_tool_position(self);
	tool_ori     = new NodeTool( "Move Origin", THEME.tools_3d_transform, "Node_pSystem_3D_Spawn" ).setToolObject(tool_ori_obj);
	tools = [ tool_ori ];
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) { 
		var _ori = new __vec3(inputs[9].getValue(,,, true));
		
		if(isUsingTool("Move Origin")) tool_ori_obj.drawOverlay3D(9, noone, _ori, active, _mx, _my, _snx, _sny, _params);
	} 
	
	////- Update
	
	static spawn = function(_frame = CURRENT_FRAME, _ox = 0, _oy = 0, _oz = 0, _ovx = undefined, _ovy = undefined, _ovz = undefined) {
		if(!is(partPool, pSystem_Particles)) return;
		
		var _seed    = getInputData( 6);
		
		var _sp_amou = getInputData( 4);
		var _sp_life = getInputData( 5);
		
		var _sh_type = getInputData( 7);
		var _sh_shap = getInputData( 8);
		var _sh_orig = getInputData( 9);
		var _sh_span = getInputData(10);
		var _sh_rota = getInputData(11);
		
		var _sh_path = getInputData(12);
		var _sh_mesh = getInputData(13);
		var _sh_data = getInputData(14);
		
		var _ih_velo = getInputData(15), _inherit_velo = _ovx != undefined && _ovy != undefined && _ovz != undefined;
		var _in_velo = getInputData(16);
		var _sh_velo = getInputData(24);
		var _in_rota = getInputData(17);
		var _in_size = getInputData(18);
		
		var _in_grad = getInputData(19);
		var _in_colr = getInputData(20), _in_colr_len  = array_length(_in_colr), _in_colr_typ = inputs[20].attributes.array_select;
		var _in_alph = getInputData(21);
		
		var _partBuff = partPool.buffer;
		
		random_set_seed(_seed + _frame);
		var _spawn_amount = irandom_range(_sp_amou[0], _sp_amou[1]);
		
		if(_sh_type == 1 && !is_path(_sh_path))            return;
		if(_sh_type == 2 && !is(_sh_mesh, __3dObject))     return;
		if(_sh_type == 3 && array_get_depth(_sh_data) < 2) return;
		
		var _sp_indx = 0;
		
		repeat(_spawn_amount) {
			random_set_seed(_seed + spawn_index * 128);
			
			var _px = 0, _py = 0, _pz = 0;
			var _sx = random_range(_in_size[0], _in_size[1]);
			var _sy = random_range(_in_size[2], _in_size[3]);
			var _sz = random_range(_in_size[4], _in_size[5]);
			
			var _rx = random_range(_in_rota[0], _in_rota[1]);
			var _ry = random_range(_in_rota[2], _in_rota[3]);
			var _rz = random_range(_in_rota[4], _in_rota[5]);
			
			var _lif    = 0;
			var _lifMax = irandom_range(_sp_life[0], _sp_life[1]);
			
			var _vx = random_range(_in_velo[0], _in_velo[1]);
			var _vy = random_range(_in_velo[2], _in_velo[3]);
			var _vz = random_range(_in_velo[4], _in_velo[5]);
			
			var _vv = random_range(_sh_velo[0], _sh_velo[1]);
				
			switch(_sh_type) {
				case 0 : // Shape
				
					_px = _sh_orig[0];
					_py = _sh_orig[1];
					_pz = _sh_orig[2];
					
					switch(_sh_shap) {
						case 0 : 
							__vec3_temp.x = _sh_span[0] * random_range(-1, 1);
							__vec3_temp.y = _sh_span[1] * random_range(-1, 1);
							__vec3_temp.z = _sh_span[2] * random_range(-1, 1);
							
							var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
							
							_px += __v[0];
							_py += __v[1];
							_pz += __v[2];
							
							if(_vv != 0) {
								var _snx = _px - _sh_orig[0];
								var _sny = _py - _sh_orig[1];
								var _snz = _pz - _sh_orig[2];
								
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
							
							__vec3_temp.x = _sh_span[0] * r * dsin(phi) * dcos(theta);
							__vec3_temp.y = _sh_span[1] * r * dsin(phi) * dsin(theta);
							__vec3_temp.z = _sh_span[2] * r * dcos(phi);
							
							var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
							
							_px += __v[0] * 2;
							_py += __v[1] * 2;
							_pz += __v[2] * 2;
							
							if(_vv != 0) {
								var _snx = _px - _sh_orig[0];
								var _sny = _py - _sh_orig[1];
								var _snz = _pz - _sh_orig[2];
								
								var _nn = sqrt(_snx * _snx + _sny * _sny + _snz * _snz);
								
								_vx += _snx / _nn * _vv;
								_vy += _sny / _nn * _vv;
								_vz += _snz / _nn * _vv;
							}
							break;
							
						case 2 : 
							var theta = random(360);
							
							__vec3_temp.x = _sh_span[0] * dcos(theta);
							__vec3_temp.y = _sh_span[1] * dsin(theta);
							__vec3_temp.z = 0;
							
							var __v = matrix_multiply_vec3(_spawn_rota_m, __vec3_temp, 1);
							
							_px += __v[0];
							_py += __v[1];
							_pz += __v[2];
							
							if(_vv != 0) {
								__vec3_temp.x = _px - _sh_orig[0];
								__vec3_temp.y = _py - _sh_orig[1];
								__vec3_temp.z = _pz - _sh_orig[2];
								
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
					if(!is_path(_sh_path)) return;
					
					var _path_prog = random(1);
					_sh_path.getPointRatio(_path_prog, 0, __path_temp);
					
					_px = __path_temp.x;// + _sh_span[0] * random_range(-1, 1);
					_py = __path_temp.y;// + _sh_span[1] * random_range(-1, 1);
					_pz = __path_temp.z;// + _sh_span[2] * random_range(-1, 1);
					break;
				
				case 2 : // Vert
					if(array_empty(_sh_mesh.vertex)) return;
					
					var _vi = irandom(array_length(_sh_mesh.vertex) - 1);
					var _vs = _sh_mesh.vertex[_vi];
					var _vi = irandom(array_length(_vs) - 1);
					
					var _v = _vs[_vi];
					
					_px = _v.x;// + _sh_span[0] * random_range(-1, 1);
					_py = _v.y;// + _sh_span[1] * random_range(-1, 1);
					_pz = _v.z;// + _sh_span[2] * random_range(-1, 1);
					break;
					
				case 3 : // Data
					if(array_empty(_sh_data)) return;
					var _spwn_data = _sh_data[irandom(array_length(_sh_data) - 1)];
					
					_px = _spwn_data[0];// + _sh_span[0] * random_range(-1, 1);
					_py = _spwn_data[1];// + _sh_span[1] * random_range(-1, 1);
					_pz = _spwn_data[2];// + _sh_span[2] * random_range(-1, 1);
					break;
					
			}
				
			_px += _ox;
			_py += _oy;
			_pz += _oz;
			
			if(_inherit_velo) {
				var _inh_vel = random_range(_ih_velo[0], _ih_velo[1]);
				_vx += _ovx * _inh_vel;
				_vy += _ovy * _inh_vel;
				_vz += _ovz * _inh_vel;
			}
			
			var _surf = noone;
			var _blnd = cache_grad.eval(random(1));
			
			var clti  = spawn_index;
			switch(_in_colr_typ) {
				case 0  : clti = spawn_index % _in_colr_len;                break;
				case 1  : clti = pingpong_value(spawn_index, _in_colr_len); break;
				case 2  : clti = irandom(_in_colr_len - 1);                 break;
			}
			
			var _clri = array_safe_get(_in_colr, clti, ca_white);
			    _blnd = colorMultiply(_blnd, _clri);
			
			var _bldR = color_get_red(_blnd);
			var _bldG = color_get_green(_blnd);
			var _bldB = color_get_blue(_blnd);
			var _bldA = random_range(_in_alph[0], _in_alph[1]) * 255;
			
			var _start = partPool.cursor * global.pSystem_data_length;
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool, true );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32,  spawn_index );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64, _px     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64, _py     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64, _pz     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64, _sx     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64, _sy     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scaz,   buffer_f64, _sz     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotx,    buffer_f64, _rx    );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotx,    buffer_f64, _ry    );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotx,    buffer_f64, _rz    );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64, _lif    );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64, _lifMax );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.surf,   buffer_f64, _surf   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8,  _bldR   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8,  _bldG   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8,  _bldB   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8,  _bldA   );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnsr,  buffer_u8,  _bldR   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnsg,  buffer_u8,  _bldG   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnsb,  buffer_u8,  _bldB   );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.blnsa,  buffer_u8,  _bldA   );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.possx,  buffer_f64, _px     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.possy,  buffer_f64, _py     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.possz,  buffer_f64, _pz     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64, _px     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64, _py     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.pospz,  buffer_f64, _pz     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64, _vx     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64, _vy     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64, _vz     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dflag, buffer_u16,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposx, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposy, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposz, buffer_f64,  0       );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dscax, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dscay, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dscaz, buffer_f64,  0       );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.drotx, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.droty, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.drotz, buffer_f64,  0       );
			
			partPool.cursor    = (partPool.cursor + 1) % partPool.poolSize;
			partPool.maxCursor = max(partPool.maxCursor, partPool.cursor);
			spawn_index++;
			_sp_indx++;
			
			buffer_write(spawnTrig, buffer_f64, _px);
			buffer_write(spawnTrig, buffer_f64, _py);
			buffer_write(spawnTrig, buffer_f64, _pz);
			
			buffer_write(spawnTrig, buffer_f64, _vx);
			buffer_write(spawnTrig, buffer_f64, _vy);
			buffer_write(spawnTrig, buffer_f64, _vz);
			spawnCount++;
		}
	}
	
	static partStep = function() {
		if(!is(partPool, pSystem_Particles)) return;
		
		var _partBuff = partPool.buffer;
		var _partAmo  = partPool.maxCursor;
		var _off = 0;
		
		var _seed = getInputData( 6);
		var _step = getInputData(22), _step_curved = inputs[22].attributes.curved && curve_step != undefined;
		var _alph = getInputData(21);
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			_lif++;
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.life,   buffer_f64,  _lif);
			if(!_act) continue;
			
			var _px  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _pz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _vx  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var _bldsA  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsa,  buffer_u8   );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			if(_lif >= _lifMax) {
				_act = false;
				
				var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				if(bool(_dfg & 0b100)) {
					var _dpx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposx, buffer_f64  );
					var _dpy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposy, buffer_f64  );
					var _dpz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposz, buffer_f64  );
					
					buffer_write(destroyTrig, buffer_f64, _dpx);
					buffer_write(destroyTrig, buffer_f64, _dpy);
					buffer_write(destroyTrig, buffer_f64, _dpz);
					
				} else {
					buffer_write(destroyTrig, buffer_f64, _px);
					buffer_write(destroyTrig, buffer_f64, _py);
					buffer_write(destroyTrig, buffer_f64, _pz);
				}
			
				buffer_write(destroyTrig, buffer_f64, _vx);
				buffer_write(destroyTrig, buffer_f64, _vy);
				buffer_write(destroyTrig, buffer_f64, _vz);
				
				destroyCount++;
				buffer_write_at(_partBuff, _start + PSYSTEM_OFF.active, buffer_bool, _act);
				
				continue;
			}
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64,  _px + _vx);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64,  _py + _vy);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64,  _pz + _vz);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64,  _px);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64,  _py);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.pospz,  buffer_f64,  _pz);
			 
			var _step_mod = _step_curved? curve_step.get(rat) : 1;
			var _step_cur = round(random_range(_step[0], _step[1]) * _step_mod);
			
			if(_step_cur == 0 || _lif % _step_cur == 0) {
				buffer_write(stepTrig, buffer_f64, _px);
				buffer_write(stepTrig, buffer_f64, _py);
				buffer_write(stepTrig, buffer_f64, _pz);
				
				buffer_write(stepTrig, buffer_f64, _vx);
				buffer_write(stepTrig, buffer_f64, _vy);
				buffer_write(stepTrig, buffer_f64, _vz);
				
				stepCount++;
			}
		}
		
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		if(!is(partPool, pSystem_Particles)) reset();
		
		#region data
			var _seed = _data[ 6];
			
			var _sp_type = _data[ 0];
			var _sp_trig = _data[ 1];
			var _sp_dely = _data[ 2];
			var _sp_dura = _data[ 3];
			
			var _sh_type  = _data[ 7];
			var _sh_shap  = _data[ 8];
			var _sh_orig  = _data[ 9];
			var _sh_span  = _data[10];
			var _sh_rota  = _data[11];
			var _do_spawn = false;
			
			random_set_seed(_seed + _frame);
			
			inputs[ 1].setVisible(_sp_type == 2, _sp_type == 2);
			inputs[ 2].setVisible(_sp_type != 2);
			inputs[ 3].setVisible(_sp_type == 1);
			inputs[15].setVisible(_sp_type == 2);
			
			inputs[ 8].setVisible(_sh_type == 0);
			inputs[ 9].setVisible(_sh_type == 0);
			inputs[10].setVisible(_sh_type == 0);
			inputs[11].setVisible(_sh_type == 0);
			inputs[12].setVisible(_sh_type == 1, _sh_type == 1);
			inputs[13].setVisible(_sh_type == 2, _sh_type == 2);
			inputs[14].setVisible(_sh_type == 3, _sh_type == 3);
			
			buffer_seek(spawnTrig,   buffer_seek_start, 4);
			buffer_seek(stepTrig,    buffer_seek_start, 4);
			buffer_seek(destroyTrig, buffer_seek_start, 4);
			
			spawnCount   = 0;
			stepCount    = 0;
			destroyCount = 0;
			
			_spawn_rota_q = new BBMOD_Quaternion(_sh_rota[0], _sh_rota[1], _sh_rota[2], _sh_rota[3]);
			_spawn_rota_m = _spawn_rota_q.ToMatrix();
			
		#endregion	
		
		#region preview
			spawn_gizmo = noone;
			tools       = [];
			
			if(_sh_type == 0) {
				tools = [ tool_ori ];
				switch(_sh_shap) {
					case 0 : spawn_gizmo = spawn_gizmo_box;     break;
					case 1 : spawn_gizmo = spawn_gizmo_sphere;  break;
					case 2 : spawn_gizmo = spawn_gizmo_circle;  break;
				}
				
			} 
			
			if(spawn_gizmo != noone) {
				spawn_gizmo.transform.position.set( _sh_orig );
				spawn_gizmo.transform.scale.set(    _sh_span );
				spawn_gizmo.transform.rotation.set( _sh_rota[0], _sh_rota[1], _sh_rota[2], _sh_rota[3] );
				spawn_gizmo.transform.applyMatrix();
			}
		#endregion
		
		partStep();
		
		if(_sp_type == 2 && _sp_trig) {
			if(typeof(_sp_trig) == "ref") { 
				buffer_to_start(_sp_trig)
				var _siz = buffer_read(_sp_trig, buffer_u32);
				
				if(_siz) {
					if(inline_context.prerendering && spawn_trigger_loop_frame == undefined)
						spawn_trigger_loop_frame = _frame;
					
					if(!inline_context.prerendering && _frame == spawn_trigger_loop_frame)
						spawn_index = 0;
				}
					
				repeat(_siz) {
					var _px  = buffer_read(_sp_trig, buffer_f64);
					var _py  = buffer_read(_sp_trig, buffer_f64);
					var _pz  = buffer_read(_sp_trig, buffer_f64);
					
					var _vx  = buffer_read(_sp_trig, buffer_f64);
					var _vy  = buffer_read(_sp_trig, buffer_f64);
					var _vz  = buffer_read(_sp_trig, buffer_f64);
					
					spawn(_frame, _px, _py, _pz, _vx, _vy, _vz);
				}
				
			} else spawn(_frame);
			
		} else {
			switch(_sp_type) {
				case 0 : _do_spawn = safe_mod(_frame, _sp_dely) == 0; break;
				case 1 : _do_spawn = _frame >= _sp_dely && _frame < _sp_dely + _sp_dura; break;
			}
			
			if(_do_spawn) spawn(_frame);
		}
		
		buffer_write_at(spawnTrig,   0, buffer_u32, spawnCount);
		buffer_write_at(stepTrig,    0, buffer_u32, stepCount);
		buffer_write_at(destroyTrig, 0, buffer_u32, destroyCount);
		
		outputs[0].setValue(partPool);
		
		outputs[1].setValue(spawnTrig);
		outputs[2].setValue(stepTrig);
		outputs[3].setValue(destroyTrig);
	}
	
	static resetSeed = function() {
		spawn_index = 0;
	}
	
	static reset = function() {
		if(is(partPool, pSystem_Particles))
			partPool.free();
		
		partPool = new pSystem_Particles();
		partPool.init(attributes.poolSize);
		
		spawn_index = 0;
		spawn_trigger_loop_frame = undefined;
		
		cache_grad = getInputData(19);
		cache_grad.cache();
		
		spawnTrig   = buffer_verify(spawnTrig,   4 + attributes.poolSize * global.pSystem_trig_length);
		stepTrig    = buffer_verify(stepTrig,    4 + attributes.poolSize * global.pSystem_trig_length);
		destroyTrig = buffer_verify(destroyTrig, 4 + attributes.poolSize * global.pSystem_trig_length);
		
		curve_step = new curveMap(getInputData(23));
	}
	
	////- Draw
	
	static getPreviewObject        = function() /*=>*/ {return noone};
	static getPreviewObjects       = function() /*=>*/ {return [ spawn_gizmo ]};
	static getPreviewObjectOutline = function() /*=>*/ {return [ spawn_gizmo ]};
	
	static cleanUp = function() {
		if(is(partPool, pSystem_Particles))
			partPool.free();
	}
}
