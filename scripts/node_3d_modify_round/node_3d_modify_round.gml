function Node_3D_Round_Vertex(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Discretize vertex";
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _obj = _data[0];
		if(!is_instanceof(_obj, __3dObject)) return noone;
		
		var _res = new __3dObject();
		
		_res.vertex = array_create(array_length(_obj.vertex));
		for( var i = 0, n = array_length(_obj.vertex); i < n; i++ ) {
			_res.vertex[i] = array_create(array_length(_obj.vertex[i]));
			
			for( var j = 0, m = array_length(_obj.vertex[i]); j < m; j++ ) {
				var _v = _obj.vertex[i][j].clone();
				//_v.x = value_snap(_v.x, 0);
				//_v.y = value_snap(_v.y, 0);
				//_v.z = value_snap(_v.z, 0);
				
				_res.vertex[i][j] = _v;
			}
		}
		
		_res.object_counts  = _obj.object_counts;
		_res.transform      = _obj.transform.clone();
		_res.size           = _obj.size.clone();
		_res.materials      = array_clone(_obj.materials);
		_res.material_index = array_clone(_obj.material_index);
		_res.texture_flip   = _obj.texture_flip;
		_res.build();
		
		return _res;
	}
	
}