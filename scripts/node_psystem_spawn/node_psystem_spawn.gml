function Node_pSystem_Spawn(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spawn";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_spawn;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput(13, nodeValueSeed());
	
	////- =Spawn
	newInput( 0, nodeValue_Enum_Scroll( "Spawn Type", 0, [ "Stream", "Burst", "Trigger" ] ));
	newInput( 1, nodeValue_Trigger(     "Spawn Trigger",                ));
	newInput( 2, nodeValue_Int(         "Spawn Delay",       4          )).setTooltip("Frames delay between each particle spawn.");
	newInput( 3, nodeValue_Int(         "Burst Duration",    1          ));
	newInput( 4, nodeValue_Range(       "Spawn Amount",     [2,2], true )).setTooltip("Amount of particle spawn in that frame.");
	newInput( 5, nodeValue_Range(       "Lifespan",         [20,30]     ));
	
	////- =Source
	newInput( 6, nodeValue_Enum_Scroll( "Type",         0, [ "Area", "Border", "Path", "Mesh", "Map", "Data" ] ));
	newInput( 7, nodeValue_Enum_Scroll( "Shape",        0, [ "Rectangle", "Ellipse" ] ));
	newInput(25, nodeValue_Enum_Scroll( "Border Shape", 0, [ "Rectangle", "Ellipse", "Line" ] ));
	newInput(23, nodeValue_Enum_Scroll( "Distribution", 0, [ "Random", "Uniform Burst", "Uniform Period" ] ));
	newInput(28, nodeValue_Int(         "Period",       4 ));
	newInput(29, nodeValue_Slider(      "Shift",        0 ));
	newInput( 8, nodeValue_Area(        "Area", DEF_AREA_REF, { useShape : false } )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput(26, nodeValue_Vec2(        "Line Start", [0,0] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput(27, nodeValue_Vec2(        "Line End",   [1,1] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 9, nodeValue_PathNode(    "Path"       ));
	newInput(10, nodeValue_Mesh(        "Mesh"       ));
	newInput(11, nodeValue_Surface(     "Spawn Map"  ));
	newInput(12, nodeValue_Vector(      "Spawn Data" )).setArrayDepth(1);
	
	////- =Transform
	newInput(24, nodeValue_Range(           "Inherit Velocity", [0,0], true               ));
	newInput(19, nodeValue_Rotation_Random( "Direction",        [0,45,135,0,0]            ));
	newInput(20, nodeValue_Range(           "Velocity",         [0,0], true               ));
	newInput(14, nodeValue_Rotation_Random( "Rotation",         ROTATION_RANDOM_DEF_0_360 ));
	newInput(15, nodeValue_Vec2_Range(      "Scale",            [1,1,1,1], true           ));
	
	////- =Render
	newInput(16, nodeValue_Gradient( "Base Color",     gra_white  ));
	newInput(17, nodeValue_Palette(  "Color by Index", [ca_white] )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(18, nodeValue_Range(    "Alpha",          [1,1], { linked : true } ));
	
	////- =Events
	newInput(21, nodeValue_Range(   "Step Period", [1,1], true )).setCurvable(22, CURVE_DEF_11, "Over Lifespan");
	// input 29
	
	newOutput(0, nodeValue_Output("Particles",  VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output("On Spawn",   VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(2, nodeValue_Output("On Step",    VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(3, nodeValue_Output("On Destroy", VALUE_TYPE.trigger,  false )).setVisible(false);
	
	input_display_list = [ 13, 
		[ "Spawn",     false ], 0, 1, 2, 3, 4, 5, 
		[ "Source",    false ], 6, 7, 25, 23, 28, 29, 8, 26, 27, 9, 10, 11, 12, 
		[ "Transform", false ], 24, 19, 20, 14, 15, 
		[ "Render",    false ], 16, 18, 
		[ "Events",    false ], 21, 22, 
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
	
	__p = new __vec2P();
	cache_grad = undefined;
	point_dist_cache = [];
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		if(!is(partPool, pSystem_Particles)) return;
		
		partPool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
		var _sh_type = getInputData(6);
		var _sh_area = getInputData(8);
		
		var _area_x = _x + _sh_area[AREA_INDEX.center_x] * _s;
		var _area_y = _y + _sh_area[AREA_INDEX.center_y] * _s;
		var _area_w = _sh_area[AREA_INDEX.half_w] * _s;
		var _area_h = _sh_area[AREA_INDEX.half_h] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(32);
						
		switch(_sh_type) {
			case 0 : 
				var _sh_shap = getInputData(7);
				if(_sh_shap == 1) draw_ellipse(_area_x - _area_w, _area_y - _area_h, _area_x + _area_w, _area_y + _area_h, true);
				InputDrawOverlay(inputs[8].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)); 
				break;
				
			case 1 :
				var _sh_bord = getInputData(25);
				switch(_sh_bord) {
					case 0 : 
					case 1 : 
						if(_sh_bord == 1) draw_ellipse(_area_x - _area_w, _area_y - _area_h, _area_x + _area_w, _area_y + _area_h, true);
						InputDrawOverlay(inputs[8].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny)); 
						break;
					
					case 2 : 
						var _sh_lin0 = getInputData(26);
						var _sh_lin1 = getInputData(27);
						
						var _lx0 = _x + _sh_lin0[0] * _s;
						var _ly0 = _y + _sh_lin0[1] * _s;
						var _lx1 = _x + _sh_lin1[0] * _s;
						var _ly1 = _y + _sh_lin1[1] * _s;
						
						draw_line(_lx0, _ly0, _lx1, _ly1);
						
						InputDrawOverlay(inputs[26].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
						InputDrawOverlay(inputs[27].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
						break;
				}
		}
	}
	
	static step = function() {}
	
	static spawn = function(_frame = CURRENT_FRAME, _ox = 0, _oy = 0, _ovx = undefined, _ovy = undefined) {
		if(!is(partPool, pSystem_Particles)) return;
		
		var _seed    = getInputData(13);
		
		var _sp_amou = getInputData( 4);
		var _sp_life = getInputData( 5);
		
		var _sh_type = getInputData( 6);
		var _sh_shap = getInputData( 7);
		var _sh_bord = getInputData(25);
		var _sh_dist = getInputData(23);
		var _sh_perd = getInputData(28);
		var _sh_shft = getInputData(29);
		var _sh_area = getInputData( 8);
		var _sh_lin0 = getInputData(26);
		var _sh_lin1 = getInputData(27);
		
		var _sh_path = getInputData( 9);
		var _sh_mesh = getInputData(10);
		var _sh_mapp = getInputData(11);
		var _sh_data = getInputData(12);
		
		var _ih_velo = getInputData(24), _inherit_velo = _ovx != undefined && _ovy != undefined;
		var _in_dirr = getInputData(19);
		var _in_velo = getInputData(20);
		var _in_rota = getInputData(14);
		var _in_size = getInputData(15);
		
		var _in_grad = getInputData(16);
		var _in_colr = getInputData(17), _in_colr_len  = array_length(_in_colr), _in_colr_typ = inputs[17].attributes.array_select;
		var _in_alph = getInputData(18);
		
		var _partBuff = partPool.buffer;
		
		random_set_seed(_seed + _frame);
		var _spawn_amount = irandom_range(_sp_amou[0], _sp_amou[1]);
		
		var _sh_area_x = _sh_area[AREA_INDEX.center_x];
		var _sh_area_y = _sh_area[AREA_INDEX.center_y];
		var _sh_area_w = _sh_area[AREA_INDEX.half_w];
		var _sh_area_h = _sh_area[AREA_INDEX.half_h];
		
		if(_sh_type == 2 && !is_path(_sh_path))            return;
		if(_sh_type == 3 && !is(_sh_mesh, Mesh))           return;
		if(_sh_type == 4 && !is_surface(_sh_mapp))         return;
		if(_sh_type == 5 && array_get_depth(_sh_data) < 2) return;
		
		var _sp_indx = 0;
		
		repeat(_spawn_amount) {
			random_set_seed(_seed + spawn_index * 128);
			
			var _px = 0, _py = 0;
			var _sx = random_range(_in_size[0], _in_size[1]);
			var _sy = random_range(_in_size[2], _in_size[3]);
			var _rot = rotation_random_eval(_in_rota);
			
			var _lif    = 0;
			var _lifMax = irandom_range(_sp_life[0], _sp_life[1]);
			
			var _spRat = _sh_dist == 2? (spawn_index % _sh_perd) / max(1, _sh_perd) : _sp_indx / max(1, _spawn_amount);
			    _spRat = frac(_spRat + _sh_shft);
			
			switch(_sh_type) {
				case 0 : // area
					switch(_sh_shap) {
						case 0 : // rectangle
							_px = random_range(_sh_area_x - _sh_area_w, _sh_area_x + _sh_area_w);
							_py = random_range(_sh_area_y - _sh_area_h, _sh_area_y + _sh_area_h);
							break;
						
						case 1 : // ellipse
							var _t = random(360);
							var _r = sqrt(random(1));
							
							_px = _sh_area_x + _r * _sh_area_w * dcos(_t);
							_py = _sh_area_y + _r * _sh_area_h * dsin(_t);
							break;
					}
					break;
				
				case 1 : // border
					switch(_sh_bord) {
						case 0 : // rectangle
							var _circ = (_sh_area_w * 2 + _sh_area_h * 2) * 2;
							var _pos  = _sh_dist == 0? random(_circ) : _circ * _spRat;
							
							if (_pos < _sh_area_w * 2) {
								_px = _sh_area_x - _sh_area_w + _pos;
								_py = _sh_area_y - _sh_area_h;
								
							} else if (_pos < _sh_area_w * 2 + _sh_area_h * 2) {
								_px = _sh_area_x + _sh_area_w;
								_py = _sh_area_y - _sh_area_h + (_pos - _sh_area_w * 2);
								
							} else if (_pos < _sh_area_w * 4 + _sh_area_h * 2) {
								_px = _sh_area_x + _sh_area_w - (_pos - (_sh_area_w * 2 + _sh_area_h * 2));
								_py = _sh_area_y + _sh_area_h;
								
							} else {
								_px = _sh_area_x - _sh_area_w;
								_py = _sh_area_y + _sh_area_h - (_pos - (_sh_area_w * 4 + _sh_area_h * 2));
							}
							break;
						
						case 1 : // ellipse
							var _t = _sh_dist == 0? random(360) : 360 * _spRat;
			
							_px = _sh_area_x + _sh_area_w * dcos(_t);
							_py = _sh_area_y + _sh_area_h * dsin(_t);
							break;
							
						case 2 : // line
							var _t = _sh_dist == 0? random(1) : _spRat;
							
							_px = lerp(_sh_lin0[0], _sh_lin1[0], _t);
							_py = lerp(_sh_lin0[1], _sh_lin1[1], _t);
							break;
					}
					break;
				
				case 2 : // path
					__p = _sh_path.getPointRatio(random(1), 0, __p);
					
					_px = __p.x;
					_py = __p.y;
					break;
					
				case 3 : // mesh
					var _p = _sh_mesh.getRandomPoint();
					
					_px = _p.x;
					_py = _p.y;
					break;
					
				case 4 : // map
					var _dat = point_dist_cache[spawn_index];
					
					_px = _dat[0];
					_py = _dat[1];
					break;
					
				case 5 : // data
					var _dat = _sh_data[spawn_index];
					
					_px = _dat[0];
					_py = _dat[1];
					break;
			}
			
			_px += _ox;
			_py += _oy;
			
			var _dirr_curr = rotation_random_eval(_in_dirr);
			var _velo_curr = random_range(_in_velo[0], _in_velo[1]);
			
			var _vx = lengthdir_x(_velo_curr, _dirr_curr);
			var _vy = lengthdir_y(_velo_curr, _dirr_curr);
			
			if(_inherit_velo) {
				var _inh_vel = random_range(_ih_velo[0], _ih_velo[1]);
				_vx += _ovx * _inh_vel;
				_vy += _ovy * _inh_vel;
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
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64, _sx     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64, _sy     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rot,    buffer_f64, _rot    );
			
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
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64, _px     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64, _py     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64, _vx     );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64, _vy     );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dflag, buffer_u16,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposx, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposy, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dscax, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dscay, buffer_f64,  0       );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.drot,  buffer_f64,  0       );
			
			partPool.cursor    = (partPool.cursor + 1) % partPool.poolSize;
			partPool.maxCursor = max(partPool.maxCursor, partPool.cursor);
			spawn_index++;
			_sp_indx++;
			
			buffer_write(spawnTrig, buffer_f64, _px);
			buffer_write(spawnTrig, buffer_f64, _py);
			buffer_write(spawnTrig, buffer_f64,   0);
			
			buffer_write(spawnTrig, buffer_f64, _vx);
			buffer_write(spawnTrig, buffer_f64, _vy);
			buffer_write(spawnTrig, buffer_f64,   0);
			spawnCount++;
		}
	}
	
	static partStep = function() {
		if(!is(partPool, pSystem_Particles)) return;
		
		var _partBuff = partPool.buffer;
		var _partAmo  = partPool.maxCursor;
		var _off = 0;
		
		var _seed = getInputData(13);
		var _step = getInputData(21), _step_curved = inputs[21].attributes.curved && curve_step != undefined;
		var _alph = getInputData(18);
		
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
			
			var _vx  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var _bldsA  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsa,  buffer_u8   );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			if(_lif >= _lifMax) {
				_act = false;
				
				var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				if(bool(_dfg & 0b100)) {
					var _dpx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposx, buffer_f64  );
					var _dpy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposy, buffer_f64  );
					
					buffer_write(destroyTrig, buffer_f64, _dpx);
					buffer_write(destroyTrig, buffer_f64, _dpy);
					buffer_write(destroyTrig, buffer_f64,    0);
					
				} else {
					buffer_write(destroyTrig, buffer_f64, _px);
					buffer_write(destroyTrig, buffer_f64, _py);
					buffer_write(destroyTrig, buffer_f64,   0);
				}
			
				buffer_write(destroyTrig, buffer_f64, _vx);
				buffer_write(destroyTrig, buffer_f64, _vy);
				buffer_write(destroyTrig, buffer_f64,   0);
				
				destroyCount++;
				buffer_write_at(_partBuff, _start + PSYSTEM_OFF.active, buffer_bool, _act);
				
				continue;
			}
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64,  _px + _vx);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64,  _py + _vy);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64,  _px);
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64,  _py);
			 
			var _step_mod = _step_curved? curve_step.get(rat) : 1;
			var _step_cur = round(random_range(_step[0], _step[1]) * _step_mod);
			
			if(_step_cur == 0 || _lif % _step_cur == 0) {
				buffer_write(stepTrig, buffer_f64, _px);
				buffer_write(stepTrig, buffer_f64, _py);
				buffer_write(stepTrig, buffer_f64,   0);
				
				buffer_write(stepTrig, buffer_f64, _vx);
				buffer_write(stepTrig, buffer_f64, _vy);
				buffer_write(stepTrig, buffer_f64,   0);
				
				stepCount++;
			}
		}
		
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!is(partPool, pSystem_Particles)) reset();
		
		#region data
			var _sp_type = getInputData( 0);
			var _sp_trig = getInputData( 1);
			var _sp_dely = getInputData( 2);
			var _sp_dura = getInputData( 3);
			
			var _sh_type = getInputData( 6);
			var _sh_bord = getInputData(25);
			var _sh_dist = getInputData(23);
			var _seed    = getInputData(13);
			var _do_spawn = false;
			
			random_set_seed(_seed + _frame);
			
			inputs[ 1].setVisible(_sp_type == 2, _sp_type == 2);
			inputs[ 2].setVisible(_sp_type != 2);
			inputs[ 3].setVisible(_sp_type == 1);
			
			inputs[ 7].setVisible(_sh_type == 0);
			inputs[25].setVisible(_sh_type == 1);
			inputs[23].setVisible(_sh_type == 1);
			inputs[28].setVisible(_sh_type == 1 && _sh_dist == 2);
			inputs[29].setVisible(_sh_type == 1 && _sh_dist != 0);
			inputs[ 8].setVisible(_sh_type == 0 || (_sh_type == 1 && _sh_bord != 2));
			inputs[26].setVisible(_sh_type == 1 && _sh_bord == 2);
			inputs[27].setVisible(_sh_type == 1 && _sh_bord == 2);
			inputs[ 9].setVisible(_sh_type == 2, _sh_type == 2);
			inputs[10].setVisible(_sh_type == 3);
			inputs[11].setVisible(_sh_type == 4, _sh_type == 4);
			inputs[12].setVisible(_sh_type == 5);
			
			inputs[24].setVisible(_sp_type == 2);
			
			buffer_seek(spawnTrig,   buffer_seek_start, 4);
			buffer_seek(stepTrig,    buffer_seek_start, 4);
			buffer_seek(destroyTrig, buffer_seek_start, 4);
			
			spawnCount   = 0;
			stepCount    = 0;
			destroyCount = 0;
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
					
					var _vx  = buffer_read(_sp_trig, buffer_f64);
					var _vy  = buffer_read(_sp_trig, buffer_f64);
					
					spawn(_frame, _px, _py, _vx, _vy);
				}
				
			} else spawn(_frame);
			
		} else {
			switch(_sp_type) {
				case 0 : _do_spawn = safe_mod(_frame, _sp_dely) == 0; break;
				case 1 : _do_spawn = _frame >= _sp_dely && _frame < _sp_dely + _sp_dura; break;
			}
			
			if(_do_spawn) {
				spawn(_frame)
			}
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
		
		cache_grad = getInputData(16);
		cache_grad.cache();
		
		var _sh_type = getInputData( 6);
		var _seed    = getInputData(13);
		var _sh_mapp = getInputData(11);
		if(_sh_type == 4) point_dist_cache = get_points_from_dist(_sh_mapp, 1024, _seed);
		
		spawnTrig   = buffer_verify(spawnTrig,   4 + attributes.poolSize * global.pSystem_trig_length);
		stepTrig    = buffer_verify(stepTrig,    4 + attributes.poolSize * global.pSystem_trig_length);
		destroyTrig = buffer_verify(destroyTrig, 4 + attributes.poolSize * global.pSystem_trig_length);
		
		curve_step = new curveMap(getInputData(22));
	}
	
	static cleanUp = function() {
		if(is(partPool, pSystem_Particles))
			partPool.free();
	}
}
