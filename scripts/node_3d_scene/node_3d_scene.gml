function Node_3D_Scene(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name = "3D Scene";
	
	outputs[| 0] = nodeValue("Scene", self, JUNCTION_CONNECT.output, VALUE_TYPE.d3Scene, noone);
	
	object_lists = [];
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Object", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Mesh, noone )
			.setVisible(true, true);
		
		return inputs[| index];
	} setDynamicInput(1, true, VALUE_TYPE.d3Mesh);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _scene = new __3dGroup();
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _obj = _data[i];
			if(is_instanceof(_obj, __3dObject) || is_instanceof(_obj, __3dGroup)) 
				_scene.addObject(_obj);
		}
		
		return _scene;
	} #endregion
}