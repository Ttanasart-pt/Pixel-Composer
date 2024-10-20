function Node_3D_Subdivide(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "3D Subdivide";
	
	newInput(in_mesh + 0, nodeValue_Float("Subobjects", self, -1));
	
	newInput(in_mesh + 1, nodeValue_Int("Level", self, 1));
	
	input_display_list = [ 
		["Mesh",      false], 0, in_mesh + 0, 
		["Subdivide", false], in_mesh + 1, 
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _obj = _data[0];
		var _trg = _data[in_mesh + 0];
		var _sub = _data[in_mesh + 1];
		
		if(!is_instanceof(_obj, __3dObject)) return noone;
		
		var _res = _obj.clone();
		
		var _vlen = array_length(_res.vertex);
		var _tarr = _trg == -1? array_create_ext(_vlen, function(i) /*=>*/ {return i}) : [ clamp(_trg, 0, _vlen - 1) ];
		
		if(_sub > 8) noti_warning("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		
		repeat(_sub)
		for( var i = 0, n = array_length(_tarr); i < n; i++ ) {
			var _vi  = _tarr[i];
			var _vt  = _res.vertex[_vi];
			var _svt = array_create(array_length(_vt) * 4);
			var _ind = 0;
			
			for( var j = 0, m = array_length(_vt); j < m; j += 3 ) {
				var _v0 = _vt[j + 0];
				var _v1 = _vt[j + 1];
				var _v2 = _vt[j + 2];
				
				var _v01 = new __vertex().set((_v0.x  + _v1.x)  / 2, (_v0.y  + _v1.y)  / 2, (_v0.z  + _v1.z)  / 2, 
											  (_v0.nx + _v1.nx) / 2, (_v0.ny + _v1.ny) / 2, (_v0.nz + _v1.nz) / 2, 
											  (_v0.u  + _v1.u)  / 2, (_v0.v  + _v1.v)  / 2);
				
				var _v02 = new __vertex().set((_v0.x  + _v2.x)  / 2, (_v0.y  + _v2.y)  / 2, (_v0.z  + _v2.z)  / 2, 
											  (_v0.nx + _v2.nx) / 2, (_v0.ny + _v2.ny) / 2, (_v0.nz + _v2.nz) / 2, 
											  (_v0.u  + _v2.u)  / 2, (_v0.v  + _v2.v)  / 2);
				
				var _v12 = new __vertex().set((_v2.x  + _v1.x)  / 2, (_v2.y  + _v1.y)  / 2, (_v2.z  + _v1.z)  / 2, 
											  (_v2.nx + _v1.nx) / 2, (_v2.ny + _v1.ny) / 2, (_v2.nz + _v1.nz) / 2, 
											  (_v2.u  + _v1.u)  / 2, (_v2.v  + _v1.v)  / 2);
				
				_svt[_ind++] = _v0;
				_svt[_ind++] = _v01;
				_svt[_ind++] = _v02;
				
				_svt[_ind++] = _v01;
				_svt[_ind++] = _v1;
				_svt[_ind++] = _v12;
				
				_svt[_ind++] = _v02;
				_svt[_ind++] = _v12;
				_svt[_ind++] = _v2;
				
				_svt[_ind++] = _v01;
				_svt[_ind++] = _v12;
				_svt[_ind++] = _v02;
				
			}
			
			_res.vertex[_vi] = _svt;
		}
		
		_res.VB = _res.build();
		
		return _res;
	}	
}