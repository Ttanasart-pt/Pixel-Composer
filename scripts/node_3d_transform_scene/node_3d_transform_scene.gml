function Node_3D_Transform_Scene(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "Transform Scene";
	
	newInput(0, nodeValue_D3Scene("Scene", noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Position", []))
		.setArrayDepth(2);
	
	newInput(2, nodeValue_Float("Rotation", []))
		.setArrayDepth(2);
	
	newInput(3, nodeValue_Float("Scale", []))
		.setArrayDepth(2);
		
	newInput(4, nodeValue_Enum_Scroll("Positioning type", 0, [ "Additive", "Override" ]));
		
	newInput(5, nodeValue_Enum_Scroll("Rotating type", 0, [ "Additive", "Override" ]));
	
	newInput(6, nodeValue_Enum_Scroll("Scaling type", 0, [ "Additive", "Multiplicative", "Override" ]));
	
	newOutput(0, nodeValue_Output("Scene", VALUE_TYPE.d3Scene, noone));
	
	input_display_list = [ 0,
		["Transform", false], 1, 2, 3,
		["Settings",   true], 4, 5, 6,
	];
	
	static processData = function(_output, _data, _array_index = 0) {
		var _scn = _data[0];
		if(!is_instanceof(_scn, __3dGroup)) return noone;
		
		var _nscn = _scn.clone(false);
		
		_temp_data = _data;
		array_foreach(_nscn.objects, function(_object, _index) {
			
			var _pos = array_safe_get_fast(_temp_data[1], _index, 0);
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
			
			var _rot = array_safe_get_fast(_temp_data[2], _index, 0);
			if(is_array(_rot)) {
				var _rotQ = new BBMOD_Quaternion().FromEuler(_rot[0], _rot[1], _rot[2]);
				
				if(_temp_data[5] == 0)
					_object.transform.rotation = _object.transform.rotation.Mul(_rotQ);
				else if(_temp_data[5] == 1)
					_object.transform.rotation = _rotQ;
			}
			
			var _sca = array_safe_get_fast(_temp_data[3], _index, 0);
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
	}
	
	static getPreviewObject = function() {
		var _obj = outputs[0].getValue();
		if(is_array(_obj)) _obj = array_safe_get_fast(_obj, preview_index, noone);
		
		return _obj;
	}
	
}