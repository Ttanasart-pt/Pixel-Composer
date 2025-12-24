function Node_3D_Repeat(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Repeat";
		
	newInput(21, nodeValueSeed());
	
	////- =Objects
	newInput( 0, nodeValue_D3Mesh(      "Objects",           noone      )).setArrayDepth(1).setVisible(true, true);
	newInput( 3, nodeValue_Vec3(        "Starting Position", [0,0,0]    ));
	newInput( 4, nodeValue_Quaternion(  "Starting Rotation", [0,0,0,1 ] ));
	newInput( 5, nodeValue_Vec3(        "Starting Scale",    [1,1,1]    ));
	
	////- =Repeat
	newInput( 1, nodeValue_Enum_Button( "Object Type",  0, [ "Single", "Array" ] )).rejectArray();
	newInput(13, nodeValue_Enum_Scroll( "Pattern",      0, __enum_array_gen([ "Linear", "Grid", "Circular"], s_node_repeat_axis) )).rejectArray();
	newInput( 2, nodeValue_Int(         "Amount",       2       ));
	newInput(14, nodeValue_IVec3(       "Grid",         [2,2,1] ));
	newInput(17, nodeValue_Float(       "Radius",       1       ));
	newInput(19, nodeValue_Slider(      "Look At Center",0      ));
	newInput(18, nodeValue_PathNode(    "Shift Path"            ));
	newInput(20, nodeValue_Slider(      "Follow Path",  0       ));
	
	////- =Transform
	newInput( 9, nodeValue_Vec3( "Positions", [] )).setArrayDepth(1);
	newInput(10, nodeValue_Vec3( "Rotations", [] )).setArrayDepth(1);
	newInput(11, nodeValue_Vec3( "Scales",    [] )).setArrayDepth(1);
	
	////- =Shift
	newInput( 6, nodeValue_Vec3(       "Shift Position",   [1,0,0]   ));
	newInput(15, nodeValue_Vec3(       "Shift Position Y", [0,1,0]   ));
	newInput(16, nodeValue_Vec3(       "Shift Position Z", [0,0,1]   ));
	newInput( 7, nodeValue_Quaternion( "Shift Rotation",   [0,0,0,1] ));
	newInput( 8, nodeValue_Vec3(       "Shift Scale",      [0,0,0]   ));
	/* UNUSED */ newInput(12, nodeValue_Bool( "Use Instance", true ))
	
	////- =Scatter
	newInput(22, nodeValue_Vec3_Range( "Position Scatter", array_create(6,0) ));
	newInput(23, nodeValue_Vec3_Range( "Rotation Scatter", array_create(6,0) ));
	newInput(24, nodeValue_Vec3_Range( "Scale Scatter",    array_create(6,0) ));
	newInput(25, nodeValue_Bool(       "Scale Uniform",    true              ));
	
	// input 26
	
	newOutput(0, nodeValue_Output("Scene", VALUE_TYPE.d3Scene, noone));
	
	b_centeralize = button(function() /*=>*/ {return centralize()}).setText("Centralize");
	
	input_display_list = [ 21, 
		["Objects",    false], 0, 3, 4, 5, b_centeralize, 
		["Repeat",     false], 1, 13, 2, 14, 17, 19, 18, 20, 
		["Transforms Data", true], 9, 10, 11, 
		["Shift",      false], 6, 15, 16, 7, 8, 
		["Scatter",    false], 22, 23, 24, 25, 
	]
	
	////- Nodes
	
	vectorUp = new __vec3(0, 0, 1);
	qRotateZ = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
	span     = [0, 0, 0, 0, 0, 0];
	
	static centralize = function() {
		if(span[0] == infinity) return;
		
		var _cx = -(span[0] + span[1]) / 2;
		var _cy = -(span[2] + span[3]) / 2;
		var _cz = -(span[4] + span[5]) / 2;
		
		inputs[3].setValue([_cx, _cy, _cz]);
	}
	
	static preGetInputs = function() {
		var _mode = getInputSingle(1);
		inputs[0].setArrayDepth(_mode == 1);
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region input
			var _seed = _data[21];
			
			var _objs = _data[0];
			var _Spos = _data[3];
			var _Srot = _data[4];
			var _Ssca = _data[5];
			
			var _mode = _data[ 1];
			var _patt = _data[13];
			var _aamo = _data[ 2];
			var _grid = _data[14];
			var _radR = _data[17];
			var _radL = _data[19];
			var _ppth = _data[18];
			var _rpth = _data[20];
			
			var _Apos = _data[ 9];
			var _Arot = _data[10];
			var _Asca = _data[11];
			
			var _Rpos    = _data[ 6];
			var _RposY   = _data[15];
			var _RposZ   = _data[16];
			
			var _Rrot   = _data[ 7];
			var _Rsca   = _data[ 8];
			
			var _posh   = _data[22];
			var _roth   = _data[23];
			var _scah   = _data[24];
			var _scauni = _data[25];
			
			inputs[ 2].setVisible(_patt != 1);
			
			inputs[18].setVisible(_patt == 0, _patt == 0);
			inputs[20].setVisible(_patt == 0);
			
			inputs[14].setVisible(_patt == 1);
			inputs[15].setVisible(_patt == 1);
			inputs[16].setVisible(_patt == 1);
			
			inputs[17].setVisible(_patt == 2);
			inputs[19].setVisible(_patt == 2);
		#endregion
		
		#region data
			var _scene = new __3dGroup();
			var _amo   = 1;
			
			var _upos = array_get_depth(_Apos) == 2, _apos;
			var _urot = array_get_depth(_Arot) == 2, _arot;
			var _usca = array_get_depth(_Asca) == 2, _asca;
			
			var _Sposx = _Spos[0], _Rposx = _Rpos[0], _RposYx = _RposY[0], _RposZx = _RposZ[0];
			var _Sposy = _Spos[1], _Rposy = _Rpos[1], _RposYy = _RposY[1], _RposZy = _RposZ[1];
			var _Sposz = _Spos[2], _Rposz = _Rpos[2], _RposYz = _RposY[2], _RposZz = _RposZ[2];
			
			var _sRotE = new BBMOD_Quaternion(_Srot[0], _Srot[1], _Srot[2], _Srot[3]).ToEuler();
			var _rRotE = new BBMOD_Quaternion(_Rrot[0], _Rrot[1], _Rrot[2], _Rrot[3]).ToEuler();
				
			var _sRotEx = _sRotE.x, _rRotEx = _rRotE.x;
			var _sRotEy = _sRotE.y, _rRotEy = _rRotE.y;
			var _sRotEz = _sRotE.z, _rRotEz = _rRotE.z;
			
			var _Sscax = _Ssca[0], _Rscax = _Rsca[0];
			var _Sscay = _Ssca[1], _Rscay = _Rsca[1];
			var _Sscaz = _Ssca[2], _Rscaz = _Rsca[2];
			
			var _SCposx0 = _posh[0], _SCposx1 = _posh[1];
			var _SCposy0 = _posh[2], _SCposy1 = _posh[3];
			var _SCposz0 = _posh[4], _SCposz1 = _posh[5];
			
			var _SCrotx0 = degtorad(_roth[0]), _SCrotx1 = degtorad(_roth[1]);
			var _SCroty0 = degtorad(_roth[2]), _SCroty1 = degtorad(_roth[3]);
			var _SCrotz0 = degtorad(_roth[4]), _SCrotz1 = degtorad(_roth[5]);
			
			var _SCscax0 = _scah[0], _SCscax1 = _scah[1];
			var _SCscay0 = _scah[2], _SCscay1 = _scah[3];
			var _SCscaz0 = _scah[4], _SCscaz1 = _scah[5];
			
			if(_mode == 1) {
				if(!is_array(_objs)) return _scene;
				_amo = array_length(_objs);
				
			} else {
				switch(_patt) {
					case 0 : 
					case 2 : _amo = _aamo; break;
					case 1 : _amo = _grid[0] * _grid[1] * _grid[2]; break;
				}
			}
			
			var _gridP = _grid[0] * _grid[1];
			var __p = new __vec3P();
			var _rt = _amo >= 1? 1 / (_amo - 1) : 0;
			
			span = [infinity, -infinity, infinity, -infinity, infinity, -infinity];
		#endregion
		
		var _i = 0;
		repeat(_amo) {
			var i = _i++;
			random_set_seed(_seed + _i * 78);
			
			var _obj = _mode == 1? _objs[i] : _objs;
			if(!is(_obj, __3dInstance)) continue;
			
			var _subScene = new __3dTransformed(_obj); 
			
			var _rat   = i * _rt;
			var _gridZ = floor(i / _gridP);
			var _gridY = floor((i - _gridZ * _gridP) / _grid[0]);
			var _gridX = (i - _gridZ * _gridP) % _grid[0];
			
			var _sPosX = _Sposx + random_range(_SCposx0, _SCposx1);
			var _sPosY = _Sposy + random_range(_SCposy0, _SCposy1);
			var _sPosZ = _Sposz + random_range(_SCposz0, _SCposz1);
			
			var _fRotEx = _sRotEx + _rRotEx * i + random_range(_SCrotx0, _SCrotx1);
			var _fRotEy = _sRotEy + _rRotEy * i + random_range(_SCroty0, _SCroty1);
			var _fRotEz = _sRotEz + _rRotEz * i + random_range(_SCrotz0, _SCrotz1);
			
			switch(_patt) {
				case 0 :
					_sPosX += _Rposx * i;
					_sPosY += _Rposy * i;
					_sPosZ += _Rposz * i;
					
					if(is_path(_ppth)) {
						__p = _ppth.getPointRatio(_rat, 0, __p);
						
						_sPosX += __p.x;
						_sPosY += __p.y;
						_sPosZ += __p.z;
						
						if(_rpth > 0) {
							__p = _ppth.getPointRatio(clamp(_rat - _rt/2, 0, 0.999), 0, __p);
							var __px0 = __p.x;
							var __py0 = __p.y;
							var __pz0 = __p.z;
							
							__p = _ppth.getPointRatio(clamp(_rat + _rt/2, 0, 0.999), 0, __p);
							var __px1 = __p.x;
							var __py1 = __p.y;
							var __pz1 = __p.z;
							
							var __rdx = __px1 - __px0;
							var __rdy = __py1 - __py0;
							var __rdz = __pz1 - __pz0;
							
							var _for  = new __vec3(__rdy, __rdx, __rdz)._normalize();
							if(!_for.isZero()) {
								var _look = new BBMOD_Quaternion().FromLookRotation(_for, vectorUp).Mul(qRotateZ).ToEuler(true);
								
								_fRotEx += _look[0] * _rpth;
								_fRotEy += _look[1] * _rpth;
								_fRotEz += _look[2] * _rpth;
							}
						}
						
					}
					break;
				
				case 1 :
					_sPosX += _Rposx * _gridX + _RposYx * _gridY + _RposZx * _gridZ;
					_sPosY += _Rposy * _gridX + _RposYy * _gridY + _RposZy * _gridZ;
					_sPosZ += _Rposz * _gridX + _RposYz * _gridY + _RposZz * _gridZ;
					break;
				
				case 2 :
					var _aa = 360 / _amo * i;
					var _ax = lengthdir_x(_radR, _aa);
					var _ay = lengthdir_y(_radR, _aa);
					
					_sPosX += _Rposx * i + _ax;
					_sPosY += _Rposy * i + _ay;
					_sPosZ += _Rposz * i;
					
					if(_radL > 0) _fRotEz += _aa * _radL;
					break;
					
			}
			
			//// Scale
			var _sScaX = _Sscax + _Rscax * i + random_range(_SCscax0, _SCscax1);
			var _sScaY = _Sscay + _Rscay * i + random_range(_SCscay0, _SCscay1);
			var _sScaZ = _Sscaz + _Rscaz * i + random_range(_SCscaz0, _SCscaz1);
			if(_scauni) { _sScaY = _sScaX; _sScaZ = _sScaX; }
			
			//// Apply
			if(_upos) { 
				_apos   = array_safe_get_fast(_Apos, i);
				_sPosX += _apos[0]; _sPosY += _apos[1]; _sPosZ += _apos[2];
			}
			_subScene.transform.position.set(_sPosX, _sPosY, _sPosZ);
			
			if(_urot) {
				_arot    = array_safe_get_fast(_Arot, i);
				_fRotEx += _arot[0]; _fRotEy += _arot[1]; _fRotEz += _arot[2];
			}
						   
			var _fRot = new BBMOD_Quaternion().FromEuler(_fRotEx, _fRotEy, _fRotEz);
			_subScene.transform.rotation.set(_fRot.X, _fRot.Y, _fRot.Z, _fRot.W);
			
			if(_usca) {
				_asca   = array_safe_get_fast(_Asca, i);
				_sScaX += _asca[0]; _sScaY += _asca[1]; _sScaZ += _asca[2];
			}
			_subScene.transform.scale.set(_sScaX, _sScaY, _sScaZ);
			
			_subScene.transform.applyMatrix();
			_scene.addObject(_subScene);
			
			span[0] = min(span[0], _sPosX - _Sposx); span[1] = max(span[1], _sPosX - _Sposx);
			span[2] = min(span[2], _sPosY - _Sposy); span[3] = max(span[3], _sPosY - _Sposy);
			span[4] = min(span[4], _sPosZ - _Sposz); span[5] = max(span[5], _sPosZ - _Sposz);
			
		}
		
		return _scene;
	}
}