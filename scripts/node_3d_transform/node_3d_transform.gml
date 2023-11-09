function Node_3D_Transform_Scene(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "Transform Scene";
	
	inputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Scene, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(2);
	
	inputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(2);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setArrayDepth(2);
		
	inputs[| 4] = nodeValue("Positioning type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Override" ]);
		
	inputs[| 5] = nodeValue("Rotating type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Override" ]);
	
	inputs[| 6] = nodeValue("Scaling type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Multiplicative", "Override" ]);
	
	outputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Scene, noone);
	
	input_display_list = [ 0,
		["Transform", false], 1, 2, 3,
		["Settings",   true], 4, 5, 6,
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _scn = _data[0];
		if(!is_instanceof(_scn, __3dGroup)) return noone;
		
		var _nscn = _scn.clone(false);
		
		_temp_data = _data;
		array_foreach(_nscn.objects, function(_object, _index) {
			
			var _pos = array_safe_get(_temp_data[1], _index, 0);
			if(is_array(_pos)) {
				if(_temp_data[4] == 0) {
					_object.transform.position.x += _pos[0];
					_object.transform.position.y += _pos[1];
					_object.transform.position.z += _pos[2];
				} else if(_temp_data[4] == 1) {
					_object.transform.position.x  = _pos[0];
					_object.transform.position.y  = _pos[1];
					_object.transform.position.z  = _pos[2];
				}
			}
			
			var _rot = array_safe_get(_temp_data[2], _index, 0);
			if(is_array(_rot)) {
				var _rotQ = new BBMOD_Quaternion().FromEuler(_rot[0], _rot[1], _rot[2]);
				
				if(_temp_data[5] == 0)
					_object.transform.rotation = _object.transform.rotation.Mul(_rotQ);
				else if(_temp_data[5] == 1)
					_object.transform.rotation = _rotQ;
			}
			
			var _sca = array_safe_get(_temp_data[3], _index, 0);
			if(is_array(_sca)) {
				if(_temp_data[6] == 0) {
					_object.transform.scale.x += _sca[0];
					_object.transform.scale.y += _sca[1];
					_object.transform.scale.z += _sca[2];
				} else if(_temp_data[6] == 1) {
					_object.transform.scale.x *= _sca[0];
					_object.transform.scale.y *= _sca[1];
					_object.transform.scale.z *= _sca[2];
				} else if(_temp_data[6] == 2) {
					_object.transform.scale.x  = _sca[0];
					_object.transform.scale.y  = _sca[1];
					_object.transform.scale.z  = _sca[2];
				}
			}
		});
		
		return _nscn;
	} #endregion
	
	static getPreviewObject = function() { #region
		var _obj = outputs[| 0].getValue();
		if(is_array(_obj)) _obj = array_safe_get(_obj, preview_index, noone);
		
		return _obj;
	} #endregion
	
}