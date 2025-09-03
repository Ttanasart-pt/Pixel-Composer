function Node_3D_Instancer(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Instancer";
	
	newInput( 9, nodeValueSeed());
	
	////- =Object
	newInput( 0, nodeValue_D3Mesh("Mesh", noone)).setVisible(true, true);
	
	////- =Objects
	newInput(16, nodeValue_Vec3(        "Starting Position", [0,0,0]    ));
	newInput(17, nodeValue_Quaternion(  "Starting Rotation", [0,0,0,1 ] ));
	newInput(18, nodeValue_Vec3(        "Starting Scale",    [1,1,1]    ));
	
	////- =Repeat
	newInput(19, nodeValue_Enum_Scroll( "Pattern",      0, __enum_array_gen([ "Linear", "Grid", "Circular"], s_node_repeat_axis) )).rejectArray();
	newInput( 1, nodeValue_Int(         "Amounts",      1 ));
	newInput(20, nodeValue_IVec3(       "Grid",         [2,2,1] ));
	newInput(21, nodeValue_Float(       "Radius",       1       ));
	newInput(22, nodeValue_Bool(        "Look At Center", false ));
	newInput(23, nodeValue_PathNode(    "Shift Path"            ));
	newInput(24, nodeValue_Bool(        "Follow Path",  false   ));
	
	////- =Transform Data
	newInput(2, nodeValue_Vec3( "Positions", [[0,0,0]] )).setArrayDepth(1);
	newInput(3, nodeValue_Vec3( "Rotations", [[0,0,0]] )).setArrayDepth(1);
	newInput(4, nodeValue_Vec3( "Scales",    [[1,1,1]] )).setArrayDepth(1);
	newInput(5, nodeValue_Vec3( "Normal",    [[0,0,0]] )).setArrayDepth(1);
	
	////- =Shift
	newInput(13, nodeValue_Vec3(       "Shift Position",   [1,0,0]   ));
	newInput(25, nodeValue_Vec3(       "Shift Position Y", [0,1,0]   ));
	newInput(26, nodeValue_Vec3(       "Shift Position Z", [0,0,1]   ));
	newInput(14, nodeValue_Quaternion( "Shift Rotation",   [0,0,0,1] ));
	newInput(15, nodeValue_Vec3(       "Shift Scale",      [0,0,0]   ));
	
	////- =Scatter
	newInput( 6, nodeValue_Vec3_Range( "Position Scatter", array_create(6,0) ));
	newInput( 7, nodeValue_Vec3_Range( "Rotation Scatter", array_create(6,0) ));
	newInput( 8, nodeValue_Vec3_Range( "Scale Scatter",    array_create(6,0) ));
	newInput(10, nodeValue_Bool(       "Scale Uniform",    true              ));
	
	////- =Render
	newInput(12, nodeValue_Palette(  "Colors Per Index", [ca_white] )).setOptions("Select by:", "array_select", [ "Index Loop", "Index Ping-pong", "Random" ], THEME.array_select_type).iconPad();
	newInput(11, nodeValue_Gradient( "Random Colors",    new gradientObject(ca_white) ));
	// 27
	
	b_centeralize = button(function() /*=>*/ {return centralize()}).setText("Centralize");
	
	input_display_list = [ 9, 
		[ "Object",  false ], 0, 16, 17, 18, b_centeralize, 
		[ "Repeat",  false ], 19, 1, 20, 21, 22, 23, 24,
		[ "Transform Data", true ], 2, 3, 4, 5, 
		[ "Shift",   false ], 13, 25, 26, 14, 15, 
		[ "Scatter", false ],  6,  7,  8, 10, 
		[ "Render",  false ], 12, 11, 
	];
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.d3Mesh, noone));
	
	////- Nodes
	
	span     = [0, 0, 0, 0, 0, 0];
	
	static centralize = function() {
		if(span[0] == infinity) return;
		
		var _cx = -(span[0] + span[1]) / 2;
		var _cy = -(span[2] + span[3]) / 2;
		var _cz = -(span[4] + span[5]) / 2;
		
		inputs[16].setValue([_cx, _cy, _cz]);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _obj = _data[0];
		if(!is(_obj, __3dInstance)) return noone;
		
		#region data
			var _seed    = _data[ 9];
			
			var _sta_pos = _data[16];
			var _sta_rot = _data[17];
			var _sta_sca = _data[18];
			
			var _patt    = _data[19];
			var _amo     = _data[ 1];
			var _grid    = _data[20];
			var _radius  = _data[21];
			var _lok_cen = _data[22];
			var _path    = _data[23];
			var _fol_pth = _data[24];
			
			var _poss    = _data[ 2];
			var _rots    = _data[ 3];
			var _scas    = _data[ 4];
			var _nors    = _data[ 5];
			
			var _shf_pos   = _data[13];
			var _shf_pos_y = _data[25];
			var _shf_pos_z = _data[26];
			var _shf_rot   = _data[14];
			var _shf_sca   = _data[15];
			
			var _posh    = _data[ 6];
			var _roth    = _data[ 7];
			var _scah    = _data[ 8];
			var _scauni  = _data[10];
			
			var _cind    = _data[12], _cind_len  = array_length(_cind), _cind_typ = inputs[12].attributes.array_select;
			var _grnd    = _data[11]; _grnd.cache();
			
			inputs[ 1].setVisible(_patt != 1);
			
			inputs[23].setVisible(_patt == 0, _patt == 0);
			inputs[24].setVisible(_patt == 0);
			
			inputs[20].setVisible(_patt == 1);
			inputs[25].setVisible(_patt == 1);
			inputs[26].setVisible(_patt == 1);
			
			inputs[21].setVisible(_patt == 2);
			inputs[22].setVisible(_patt == 2);
		#endregion
			
		#region base instancer
			switch(_patt) {
				case 0 : 
				case 2 : _amo = _amo; break;
				case 1 : _amo = _grid[0] * _grid[1] * _grid[2]; break;
			}
			
			if(_amo <= 0) return noone;
			
			var _res = new __3dObjectInstancer();
			
			_res.instance_amount = _amo;
			_res.objectTransform = _obj.transform;
			_res.objectTransform.applyMatrix();
			
			var _flat_vb = d3d_flattern(_obj);
			_res.VB = _flat_vb.VB;
			_res.materials = _flat_vb.materials;
			
		#endregion
		
		#region data 
			var _Sposx = _sta_pos[0], _Rposx = _shf_pos[0], _RposYx = _shf_pos_y[0], _RposZx = _shf_pos_z[0];
			var _Sposy = _sta_pos[1], _Rposy = _shf_pos[1], _RposYy = _shf_pos_y[1], _RposZy = _shf_pos_z[1];
			var _Sposz = _sta_pos[2], _Rposz = _shf_pos[2], _RposYz = _shf_pos_y[2], _RposZz = _shf_pos_z[2];
			
			var _sRotE = new BBMOD_Quaternion(_sta_rot[0], _sta_rot[1], _sta_rot[2], _sta_rot[3]).ToEuler();
			var _rRotE = new BBMOD_Quaternion(_shf_rot[0], _shf_rot[1], _shf_rot[2], _shf_rot[3]).ToEuler();
				
			var _sRotEx = _sRotE.x, _rRotEx = _rRotE.x;
			var _sRotEy = _sRotE.y, _rRotEy = _rRotE.y;
			var _sRotEz = _sRotE.z, _rRotEz = _rRotE.z;
			
			var _Sscax = _sta_sca[0], _Rscax = _shf_sca[0];
			var _Sscay = _sta_sca[1], _Rscay = _shf_sca[1];
			var _Sscaz = _sta_sca[2], _Rscaz = _shf_sca[2];
			
			var _SCposx0 = _posh[0], _SCposx1 = _posh[1];
			var _SCposy0 = _posh[2], _SCposy1 = _posh[3];
			var _SCposz0 = _posh[4], _SCposz1 = _posh[5];
			
			var _SCrotx0 = degtorad(_roth[0]), _SCrotx1 = degtorad(_roth[1]);
			var _SCroty0 = degtorad(_roth[2]), _SCroty1 = degtorad(_roth[3]);
			var _SCrotz0 = degtorad(_roth[4]), _SCrotz1 = degtorad(_roth[5]);
			
			var _SCscax0 = _scah[0], _SCscax1 = _scah[1];
			var _SCscay0 = _scah[2], _SCscay1 = _scah[3];
			var _SCscaz0 = _scah[4], _SCscaz1 = _scah[5];
			
			var _gridP = _grid[0] * _grid[1];
			var _rt = _amo >= 1? 1 / (_amo - 1) : 0;
			var __p = new __vec3P();
			var _i  = 0;
			
			var _0 = [0,0,0], _1 = [1,1,1];
			
			span = [infinity, -infinity, infinity, -infinity, infinity, -infinity];
		#endregion
		
		#region constant buffer
			
			var _posl = array_length(_poss);
			var _rotl = array_length(_rots);
			var _scal = array_length(_scas);
			var _norl = array_length(_nors);
			
			var batch_count = ceil(_amo / INSTANCE_BATCH_SIZE);
			var batch_id     = 0;
			
			_res.batch_count = batch_count;
			
			repeat(batch_count) {
				var _buffer = buffer_create(1, buffer_grow, 1);
				var _amo_batch = min(INSTANCE_BATCH_SIZE, _amo);
				
				repeat(_amo_batch) {
					random_set_seed(_seed + _i * 78);
					var _rat = _i * _rt;
					
					var _p = array_safe_get_fast(_poss, _i % _posl, _0);
					var _px = _Sposx + random_range(_SCposx0, _SCposx1) + _p[0];
					var _py = _Sposy + random_range(_SCposy0, _SCposy1) + _p[1];
					var _pz = _Sposz + random_range(_SCposz0, _SCposz1) + _p[2];
					
					var _r = array_safe_get_fast(_rots, _i % _rotl, _0);
					var _rx = _sRotEx + _rRotEx * _i + random_range(_SCrotx0, _SCrotx1) + _r[0];
					var _ry = _sRotEy + _rRotEy * _i + random_range(_SCroty0, _SCroty1) + _r[1];
					var _rz = _sRotEz + _rRotEz * _i + random_range(_SCrotz0, _SCrotz1) + _r[2];
					
					var _s = array_safe_get_fast(_scas, _i % _scal, _1);
					var _sx = (_Sscax - 1) + _Rscax * _i + random_range(_SCscax0, _SCscax1) + _s[0];
					var _sy = (_Sscay - 1) + _Rscay * _i + random_range(_SCscay0, _SCscay1) + _s[1];
					var _sz = (_Sscaz - 1) + _Rscaz * _i + random_range(_SCscaz0, _SCscaz1) + _s[2];
					if(_scauni) { _sy = _sx; _sz = _sx; }
					
					var _n  = array_safe_get_fast(_nors, _i % _norl, _0);
					var _nx = _n[0];
					var _ny = _n[1];
					var _nz = _n[2];
					
					switch(_patt) {
						case 0 :
							_px += _Rposx * _i;
							_py += _Rposy * _i;
							_pz += _Rposz * _i;
							
							if(is_path(_path)) {
								__p = _path.getPointRatio(_rat, 0, __p);
								
								_px += __p.x;
								_py += __p.y;
								_pz += __p.z;
								
								if(_fol_pth) {
									__p = _path.getPointRatio(clamp(_rat - _rt/2, 0, 0.999), 0, __p);
									var __px0 = __p.x;
									var __py0 = __p.y;
									var __pz0 = __p.z;
									
									__p = _path.getPointRatio(clamp(_rat + _rt/2, 0, 0.999), 0, __p);
									var __px1 = __p.x;
									var __py1 = __p.y;
									var __pz1 = __p.z;
									
									_nx += __px1 - __px0;
									_ny += __py1 - __py0;
									_nz += __pz1 - __pz0;
								}
								
							}
							break;
						
						case 1 :
							var _gridZ = floor(_i / _gridP);
							var _gridY = floor((_i - _gridZ * _gridP) / _grid[0]);
							var _gridX = (_i - _gridZ * _gridP) % _grid[0];
							
							_px += _Rposx * _gridX + _RposYx * _gridY + _RposZx * _gridZ;
							_py += _Rposy * _gridX + _RposYy * _gridY + _RposZy * _gridZ;
							_pz += _Rposz * _gridX + _RposYz * _gridY + _RposZz * _gridZ;
							break;
						
						case 2 :
							var _aa = 360 / _amo * _i;
							var _ax = lengthdir_x(_radius, _aa);
							var _ay = lengthdir_y(_radius, _aa);
							
							_px += _Rposx * _i + _ax;
							_py += _Rposy * _i + _ay;
							_pz += _Rposz * _i;
							
							if(_lok_cen > 0) {
								_nx += _px - _Sposx;
								_ny += _py - _Sposy;
								_nz += _pz - _Sposz;
							}
							break;
							
					}
					
					var clti  = _i;
					switch(_cind_typ) {
						case 0  : clti = _i % _cind_len;                break;
						case 1  : clti = pingpong_value(_i, _cind_len); break;
						case 2  : clti = irandom(_cind_len - 1);        break;
					}
					
					var _clr_ind = array_safe_get(_cind, clti, ca_white);
					var cc = colorMultiply(_clr_ind, _grnd.evalFast(random(1)));
					
					buffer_write(_buffer, buffer_f32, _px); // pos X
					buffer_write(_buffer, buffer_f32, _py); // pos Y
					buffer_write(_buffer, buffer_f32, _pz); // pos Z
					buffer_write(_buffer, buffer_f32, _color_get_r(cc));
					
					buffer_write(_buffer, buffer_f32, _rx); // rot X 
					buffer_write(_buffer, buffer_f32, _ry); // rot Y 
					buffer_write(_buffer, buffer_f32, _rz); // rot Z
					buffer_write(_buffer, buffer_f32, _color_get_g(cc));
					
					buffer_write(_buffer, buffer_f32, _sx); // sca X 
					buffer_write(_buffer, buffer_f32, _sy); // sca Y 
					buffer_write(_buffer, buffer_f32, _sz); // sca Z
					buffer_write(_buffer, buffer_f32, _color_get_b(cc));
					
					buffer_write(_buffer, buffer_f32, _nx); // norm X
					buffer_write(_buffer, buffer_f32, _ny); // norm Y
					buffer_write(_buffer, buffer_f32, _nz); // norm Z
					buffer_write(_buffer, buffer_f32, 0);
					
					
					span[0] = min(span[0], _px - _Sposx); span[1] = max(span[1], _px - _Sposx);
					span[2] = min(span[2], _py - _Sposy); span[3] = max(span[3], _py - _Sposy);
					span[4] = min(span[4], _pz - _Sposz); span[5] = max(span[5], _pz - _Sposz);
					
					_i++;
				}
				
				_amo -= INSTANCE_BATCH_SIZE;
				_res.setBuffer(_buffer, batch_id, _amo_batch);
				batch_id++;
				
				buffer_delete(_buffer);
			}
		#endregion
		
		return _res;
	}
}