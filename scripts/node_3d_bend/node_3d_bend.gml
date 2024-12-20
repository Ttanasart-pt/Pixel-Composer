function Node_3D_Bend(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Bend Mesh";
	
	var i = in_mesh;
	newInput(i+0, nodeValue_Enum_Button("Axis", self, 0, [ "X", "Y", "Z"]));
	
	newInput(i+1, nodeValue_Float("Radius", self, 1));
	
	newInput(i+2, nodeValue_Float("Amount", self, 1));
	
	newInput(i+3, nodeValue_Vec3("Origin", self, [ 0, 0, 0 ]));
	
	newInput(i+4, nodeValue_Bool("Recalculate normal", self, true));
	
	input_display_list = [ 
		["Mesh", false], 0, 
		["Bend", false], i+0, i+3, i+1, i+2, i+4, 
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _obj = _data[0];
		var _axs = _data[in_mesh + 0];
		var _rad = _data[in_mesh + 1];
		var _amo = _data[in_mesh + 2];
		var _ori = _data[in_mesh + 3];
		var _nrm = _data[in_mesh + 4];
		
		if(!is_instanceof(_obj, __3dObject))    return noone;
		
		var _res  = _obj.clone();
		var _vlen = array_length(_res.vertex);
		var _tarr = array_create_ext(_vlen, function(i) /*=>*/ {return i});
		
		for( var i = 0, n = array_length(_tarr); i < n; i++ ) {
			var _vi = _tarr[i];
			var _vt = _res.vertex[_vi];
			
			for( var j = 0, m = array_length(_vt); j < m; j++ ) {
				var _v  = _vt[j];
				
				_v.x += 1;
				_v.y += 1;
				_v.z += 1;
			}
			
			if(_nrm)
			for( var j = 0, m = array_length(_vt); j < m; j += 3 ) {
				var _v0 = _vt[j + 0];
				var _v1 = _vt[j + 1];
				var _v2 = _vt[j + 2];
				
				var _nres = d3_cross_product_element(_v1.x - _v0.x, _v1.y - _v0.y, _v1.z - _v0.z, 
												     _v0.x - _v2.x, _v0.y - _v2.y, _v0.z - _v2.z);
				
				var _nnl = sqrt(_nres[0] * _nres[0] + _nres[1] * _nres[1] + _nres[2] * _nres[2]);
				_nres[0] /= _nnl;
				_nres[1] /= _nnl;
				_nres[2] /= _nnl;
				
				_v0.nx = _nres[0]; _v0.ny = _nres[1]; _v0.nz = _nres[2];
				_v1.nx = _nres[0]; _v1.ny = _nres[1]; _v1.nz = _nres[2];
				_v2.nx = _nres[0]; _v2.ny = _nres[1]; _v2.nz = _nres[2];
			}
		}
		
		_res.VB = _res.build();
		return _res;
	}	
}