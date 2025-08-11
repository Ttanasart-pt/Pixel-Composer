function Node_3D_Repeat(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Repeat";
		
	////- =Objects
	newInput( 0, nodeValue_D3Mesh(      "Objects",           noone      )).setArrayDepth(1).setVisible(true, true);
	newInput( 3, nodeValue_Vec3(        "Starting Position", [0,0,0]    ));
	newInput( 4, nodeValue_Quaternion(  "Starting Rotation", [0,0,0,1 ] ));
	newInput( 5, nodeValue_Vec3(        "Starting Scale",    [1,1,1]    ));
	
	////- =Repeat
	newInput( 1, nodeValue_Enum_Button( "Object Data",  0 , [ "Single", "Array" ] )).rejectArray();
	newInput(13, nodeValue_Enum_Scroll( "Pattern",      0 , __enum_array_gen([ "Linear", "Grid", "Circular"], s_node_repeat_axis) )).rejectArray();
	newInput( 2, nodeValue_Int(         "Amount",       2       ));
	newInput(14, nodeValue_IVec3(       "Grid",         [2,2,1] ));
	newInput(17, nodeValue_Float(       "Radius",       1       ));
	
	////- =Transform
	newInput( 9, nodeValue_Vec3( "Positions", [0,0,0] )).setArrayDepth(1);
	newInput(10, nodeValue_Vec3( "Rotations", [0,0,0] )).setArrayDepth(1);
	newInput(11, nodeValue_Vec3( "Scales",    [0,0,0] )).setArrayDepth(1);
	
	////- =Shift
	newInput( 6, nodeValue_Vec3(       "Shift Position",   [1,0,0]   ));
	newInput(15, nodeValue_Vec3(       "Shift Position Y", [0,1,0]   ));
	newInput(16, nodeValue_Vec3(       "Shift Position Z", [0,0,1]   ));
	newInput( 7, nodeValue_Quaternion( "Shift Rotation",   [0,0,0,1] ));
	newInput( 8, nodeValue_Vec3(       "Shift Scale",      [0,0,0]   ));
	/* UNUSED */ newInput(12, nodeValue_Bool( "Use Instance", true ))
	// input 18
	
	newOutput(0, nodeValue_Output("Scene", VALUE_TYPE.d3Scene, noone));
	
	input_display_list = [
		["Objects",    false], 0, 3, 4, 5, 
		["Repeat",     false], 1, 13, 2, 14, 17, 
		["Transforms",  true], 9, 10, 11, 
		["Shift",      false], 6, 15, 16, 7, 8, 
	]
	
	////- Nodes
	
	static preGetInputs = function() {
		var _mode = getSingleValue(1);
		inputs[0].setArrayDepth(_mode == 1);
	}
	
	static processData = function(_output, _data, _array_index = 0) {
		#region data
			var _objs = _data[0];
			var _Spos = _data[3];
			var _Srot = _data[4];
			var _Ssca = _data[5];
			
			var _mode = _data[ 1];
			var _patt = _data[13];
			var _aamo = _data[ 2];
			var _grid = _data[14];
			var _radR = _data[17];
			
			var _Apos = _data[ 9];
			var _Arot = _data[10];
			var _Asca = _data[11];
			
			var _Rpos  = _data[ 6];
			var _RposY = _data[15];
			var _RposZ = _data[16];
			var _Rrot  = _data[ 7];
			var _Rsca  = _data[ 8];
			
			inputs[ 2].setVisible(_patt != 1);
			
			inputs[14].setVisible(_patt == 1);
			inputs[15].setVisible(_patt == 1);
			inputs[16].setVisible(_patt == 1);
			
			inputs[17].setVisible(_patt == 2);
		#endregion
		
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
		
		for( var i = 0; i < _amo; i++ ) {
			var _obj = _mode == 1? _objs[i] : _objs;
			if(!is(_obj, __3dInstance)) continue;
			
			var _subScene = new __3dTransformed(_obj); 
			
			var _gridZ = floor(i / _gridP);
			var _gridY = floor((i - _gridZ * _gridP) / _grid[0]);
			var _gridX = (i - _gridZ * _gridP) % _grid[0];
			
			//// Position
			switch(_patt) {
				case 0 :
					var _sPosX = _Sposx + _Rposx * i;
					var _sPosY = _Sposy + _Rposy * i;
					var _sPosZ = _Sposz + _Rposz * i;
					break;
				
				case 1 :
					var _sPosX = _Sposx + _Rposx * _gridX + _RposYx * _gridY + _RposZx * _gridZ;
					var _sPosY = _Sposy + _Rposy * _gridX + _RposYy * _gridY + _RposZy * _gridZ;
					var _sPosZ = _Sposz + _Rposz * _gridX + _RposYz * _gridY + _RposZz * _gridZ;
					break;
				
				case 2 :
					var _aa = 360 / _amo * i;
					var _ax = lengthdir_x(_radR, _aa);
					var _ay = lengthdir_y(_radR, _aa);
					
					var _sPosX = _Sposx + _Rposx * i + _ax;
					var _sPosY = _Sposy + _Rposy * i + _ay;
					var _sPosZ = _Sposz + _Rposz * i;
					break;
					
			}
			
			//// Rotation
			var _fRotEx = _sRotEx + _rRotEx * i;
			var _fRotEy = _sRotEy + _rRotEy * i;
			var _fRotEz = _sRotEz + _rRotEz * i;
			
			//// Scale
			var _sScaX = _Sscax + _Rscax * i;
			var _sScaY = _Sscay + _Rscay * i;
			var _sScaZ = _Sscaz + _Rscaz * i;
			
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
		}
		
		return _scene;
	}
}