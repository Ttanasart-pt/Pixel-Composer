function Node_3D_Displace(_x, _y, _group = noone) : Node_3D_Modifier(_x, _y, _group) constructor {
	name = "Displace vertex";
	
	newInput(in_mesh + 0, nodeValue_D3Material("Displace Texture", self, new __d3dMaterial()))
	
	newInput(in_mesh + 1, nodeValue_Float("Height", self, .1))
	
	newInput(in_mesh + 2, nodeValue_Float("Subobjects", self, -1))
	
	input_display_list = [ 
		["Mesh",     false], 0, in_mesh + 2, 
		["Displace", false], in_mesh + 0, in_mesh + 1,
	];
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _obj = _data[0];
		var _tex = _data[in_mesh + 0];
		var _hei = _data[in_mesh + 1];
		var _trg = _data[in_mesh + 2];
		
		if(!is_instanceof(_obj, __3dObject))    return noone;
		if(!is_instanceof(_tex, __d3dMaterial)) return noone;
		
		var _tsc = _tex.texScale;
		var _tif = _tex.texShift;
		
		var dim  = surface_get_dimension(_tex.surface);
		var _sw  = dim[0] - 1;
		var _sh  = dim[1] - 1;
		
		var buf  = buffer_from_surface(_tex.surface, false);
		var _res = _obj.clone();
		
		var _vlen = array_length(_res.vertex);
		var _tarr = _trg == -1? array_create_ext(_vlen, function(i) /*=>*/ {return i}) : [ clamp(_trg, 0, _vlen - 1) ];
		
		for( var i = 0, n = array_length(_tarr); i < n; i++ ) {
			var _vi = _tarr[i];
			
			for( var j = 0, m = array_length(_res.vertex[_vi]); j < m; j++ ) {
				var _v  = _res.vertex[_vi][j];
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
		}
		
		_res.VB = _res.build();
		buffer_delete(buf);
		
		return _res;
	}	
}