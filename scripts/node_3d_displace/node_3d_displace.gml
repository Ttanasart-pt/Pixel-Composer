function Node_3D_Displace(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Displace Vertex";
	
	newInput(in_mesh + 0, nodeValue_D3Material("Displace Texture", new __d3dMaterial()))
		.setVisible(true, true);
	
	newInput(in_mesh + 1, nodeValue_Float("Height", .1));
	
	newInput(in_mesh + 2, nodeValue_Float("Subobjects", -1));
	
	newInput(in_mesh + 3, nodeValue_Bool("Recalculate normal", true));
	
	input_display_list = [ 
		["Mesh",     false], 0, in_mesh + 2, 
		["Displace", false], in_mesh + 0, in_mesh + 1, in_mesh + 3
	];
	
	static processData = function(_output, _data, _array_index = 0) { 
		var _obj = _data[0];
		var _tex = _data[in_mesh + 0];
		var _hei = _data[in_mesh + 1];
		var _trg = _data[in_mesh + 2];
		var _nrm = _data[in_mesh + 3];
		
		if(!is_instanceof(_obj, __3dObject))    return noone;
		if(!is_instanceof(_tex, __d3dMaterial)) return noone;
		
		var _tsc  = _tex.texScale;
		var _tif  = _tex.texShift;
		var _surf = _tex.surface;
		
		if(!is_surface(_surf)) return _obj;
		
		var dim  = surface_get_dimension(_tex.surface);
		var _sw  = dim[0] - 1;
		var _sh  = dim[1] - 1;
		
		var buf  = buffer_from_surface(_tex.surface, false);
		var _res = _obj.clone();
		
		var _vlen = array_length(_res.vertex);
		var _tarr = _trg == -1? array_create_ext(_vlen, function(i) /*=>*/ {return i}) : [ clamp(_trg, 0, _vlen - 1) ];
		
		for( var i = 0, n = array_length(_tarr); i < n; i++ ) {
			var _vi = _tarr[i];
			var _vt = _res.vertex[_vi];
			
			for( var j = 0, m = array_length(_vt); j < m; j++ ) {
				var _v  = _vt[j];
				var _vu = frac(clamp(_v.u, 0, 0.9999) * _tsc[0] + _tif[0]);
				var _vv = frac(clamp(_v.v, 0, 0.9999) * _tsc[1] + _tif[1]);
				
				if(_vu < 0) _vu = 1 + _vu;
				if(_vv < 0) _vv = 1 + _vv;
				
				_vu = round(_vu * _sw);
				_vv = round(_vv * _sh);
				
				var _samp = buffer_getPixel(buf, dim[0], dim[1], _vu, _vv);
				var _hh   = _hei * _color_get_light(_samp);
				
				_v.x += _v.nx * _hh;
				_v.y += _v.ny * _hh;
				_v.z += _v.nz * _hh;
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
		buffer_delete(buf);
		
		return _res;
	}	
}