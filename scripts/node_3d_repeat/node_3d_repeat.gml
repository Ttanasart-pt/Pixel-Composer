function Node_3D_Repeat(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Repeat";
		
	inputs[| 0] = nodeValue("Objects", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone )
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Object Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Duplicate", "Array" ] )
		.rejectArray();
	
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 );
	
	inputs[| 3] = nodeValue("Starting Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Starting Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.d3quarternion);
	
	inputs[| 5] = nodeValue("Starting Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 6] = nodeValue("Shift Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Shift Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.d3quarternion);
	
	inputs[| 8] = nodeValue("Shift Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 9] = nodeValue("Positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setArrayDepth(2);
	
	inputs[| 10] = nodeValue("Rotations", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setArrayDepth(2);
	
	inputs[| 11] = nodeValue("Scales", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setArrayDepth(2);
	
	inputs[| 12] = nodeValue("Use Instance", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
	
	outputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Scene, noone);
	
	input_display_list = [
		["Objects",		false], 0, 3, 4, 5, 
		["Repeat",		false], 1, 2, 
		["Transforms",	false], 9, 10, 11, 
		["Shift",		false], 6, 7, 8, 
	]
	
	static step = function() { #region
		var _mode = getSingleValue(1);
		
		inputs[| 0].setArrayDepth(_mode == 1);
		
		inputs[| 2].setVisible(_mode == 0);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _object = _data[0];
		var _mode   = _data[1];
		var _Spos   = _data[3];
		var _Srot   = _data[4];
		var _Ssca   = _data[5];
		var _Rpos   = _data[6];
		var _Rrot   = _data[7];
		var _Rsca   = _data[8];
		
		var _Apos = _data[ 9];
		var _Arot = _data[10];
		var _Asca = _data[11];
		var _inst = _data[12];
		
		var _scene = new __3dGroup();
		
		if(_mode == 1 && !is_array(_object)) return _scene;
		var _amo = _mode == 1? array_length(_object) : _data[2];
		
		for( var i = 0; i < _amo; i++ ) {
			var _obj = _mode == 1? _object[i] : _object;
			if(!is_struct(_obj)) continue;
			
			//if(!_inst) _obj = _obj.clone(false, true);
			
			var _apos = array_safe_get_fast(_Apos, i);
			var _arot = array_safe_get_fast(_Arot, i);
			var _asca = array_safe_get_fast(_Asca, i);
			
			if(!is_array(_apos) || array_length(_apos) != 3) _apos = [ 0, 0, 0 ];
			if(!is_array(_arot) || array_length(_arot) != 3) _arot = [ 0, 0, 0 ];
			if(!is_array(_asca) || array_length(_asca) != 3) _asca = [ 0, 0, 0 ];
			
			var _subScene = new __3dGroup();
			
			var _sPos = [ _Spos[0] + _apos[0] + _Rpos[0] * i, 
						  _Spos[1] + _apos[1] + _Rpos[1] * i, 
						  _Spos[2] + _apos[2] + _Rpos[2] * i ];
			var _sSca = [ _Ssca[0] + _asca[0] + _Rsca[0] * i, 
						  _Ssca[1] + _asca[1] + _Rsca[1] * i, 
						  _Ssca[2] + _asca[2] + _Rsca[2] * i ];
			
			var _sRot = new BBMOD_Quaternion(_Srot[0], _Srot[1], _Srot[2], _Srot[3]);
			var _rRot = new BBMOD_Quaternion(_Rrot[0], _Rrot[1], _Rrot[2], _Rrot[3]);
			
			var _sRotE = _sRot.ToEuler();
			var _rRotE = _rRot.ToEuler();
			
			var _fRotE = [ _sRotE.x + _arot[0] + _rRotE.x * i, 
						   _sRotE.y + _arot[1] + _rRotE.y * i, 
						   _sRotE.z + _arot[2] + _rRotE.z * i ];
						   
			var _fRot = new BBMOD_Quaternion().FromEuler(_fRotE[0], _fRotE[1], _fRotE[2]);
			
			_subScene.transform.position.set(_sPos);
			_subScene.transform.rotation.set(_fRot.X, _fRot.Y, _fRot.Z, _fRot.W);
			_subScene.transform.scale.set(_sSca);
			
			_subScene.addObject(_obj);
			_scene.addObject(_subScene);
		}
		
		return _scene;
	}
}