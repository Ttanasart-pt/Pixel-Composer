function Node_3D_Set_Material(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Set Material";
	
	inputs[| in_mesh + 0] = nodeValue("Materials", self, JUNCTION_CONNECT.input, VALUE_TYPE.d3Material, noone)
		.setVisible(true, true)
		.setArrayDepth(1);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _obj = _data[0];
		var _mat = _data[in_mesh + 0];
		
		if(!is_instanceof(_obj, __3dObject)) return noone;
		if(!is_array(_mat)) _mat = [ _mat ];
		
		var _res = _obj.clone(false);
		
		if(array_length(_mat) != array_length(_obj.materials))
			array_resize(_mat, array_length(_obj.materials));
			
		_res.vertex = _obj.vertex;
		_res.VB     = _obj.VB;
		_res.materials = _mat;
		
		return _res;
	}
}