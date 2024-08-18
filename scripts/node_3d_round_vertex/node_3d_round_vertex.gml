function Node_3D_Round_Vertex(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Discretize vertex";
	
	newInput(in_mesh + 0, nodeValue_Float("Step", self, 0.1))
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _obj = _data[0];
		var _stp = _data[in_mesh + 0];
		
		if(!is_instanceof(_obj, __3dObject)) return noone;
		
		var _res = _obj.clone(false);
		
		_res.vertex = array_create(array_length(_obj.vertex));
		for( var i = 0, n = array_length(_obj.vertex); i < n; i++ ) {
			_res.vertex[i] = array_create(array_length(_obj.vertex[i]));
			
			for( var j = 0, m = array_length(_obj.vertex[i]); j < m; j++ ) {
				var _v = _obj.vertex[i][j].clone();
				_v.x = value_snap(_v.x, _stp);
				_v.y = value_snap(_v.y, _stp);
				_v.z = value_snap(_v.z, _stp);
				
				_res.vertex[i][j] = _v;
			}
		}
		
		_res.VB = _res.build();
		
		return _res;
	}	
}