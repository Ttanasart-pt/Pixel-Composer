function readObj_init() {
	obj_reading = true;
	obj_read_progress = 0;
	obj_read_prog_sub = 0;
	obj_read_prog_tot = 3;
	obj_raw = noone;
	
	_VB  = [];
	_VBT = [];
	_VBN = [];
	mats = [];
	matIndex = [];
	tris = [];
	mtlPath = "";
	use_normal = true;
	v  = ds_list_create();
	vt = ds_list_create();
	vn = ds_list_create();
	f  = ds_list_create();
	ft = ds_list_create();
	fn = ds_list_create();
	tri = 0;
}

function readObj_file() {
	var _time = current_time;
	
	while(!file_text_eof(obj_read_file)) { #region reading file
		var l = file_text_readln(obj_read_file);
		l = string_trim(l);
		
		var sep = string_split(l, " ");
		if(array_length(sep) == 0) continue;
		
		switch(sep[0]) {
			case "v" :
				ds_list_add(v, [ toNumber(sep[1]), toNumber(sep[2]), toNumber(sep[3]) ]);
				break;
			case "vt" :
				var _u = toNumber(sep[1]);
				var _v = toNumber(sep[2]);
				
				ds_list_add(vt, [ _u, _v ]);
				break;
			case "vn" :
				var _nx = toNumber(sep[1]);
				var _ny = toNumber(sep[2]);
				var _nz = toNumber(sep[3]);
				//var _di = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
				
				//_nx /= _di;
				//_ny /= _di;
				//_nz /= _di;
				
				ds_list_add(vn, [ _nx, _ny, _nz ]);
				break;
			case "f" :
				var _len = array_length(sep);
				var _f   = array_create(_len - 1);
				var _ft  = array_create(_len - 1);
				var _fn  = array_create(_len - 1);
				
				for( var i = 1; i < _len; i++ ) {
					var _sp    = string_split(sep[i], "/");
					if(array_length(_sp) < 2) continue;
					
					_f[i - 1]  = toNumber(_sp[0]);
					_ft[i - 1] = toNumber(_sp[1]);
					_fn[i - 1] = toNumber(_sp[2]);
					
					if(array_length(_sp) < 3) use_normal = false;
				}
				
				tri += _len - 2;
				ds_list_add(f,  _f ); //get position
				ds_list_add(ft, _ft); //get texture map
				ds_list_add(fn, _fn); //get normal
				break;
			case "usemtl" :
				var mname = "";
				for( var i = 1; i < array_length(sep); i++ )
					mname += (i == 1? "" : " ") + sep[i];
				mname = string_trim(mname);
				
				array_push_unique(mats, mname);
				array_push(matIndex, array_find(mats, mname));
				
				if(!ds_list_empty(f)) {
					array_push(_VB,  f);
					array_push(_VBT, ft);
					array_push(_VBN, fn);
					array_push(tris, tri);
					f  = ds_list_create();
					ft = ds_list_create();
					fn = ds_list_create();
				}
				
				tri = 0;
				break;
			case "mtllib" :
				mtlPath = "";
				for( var i = 1; i < array_length(sep); i++ )
					mtlPath += (i == 1? "" : " ") + sep[i];
				mtlPath = string_trim(mtlPath);
				break;
			case "o" :
				//print("Reading vertex group: " + sep[1])
				break;
		}
		
		if(current_time - _time > 30) return;
	} #endregion
	
	if(!ds_list_empty(f)) {
		array_push(_VB,  f);
		array_push(_VBT, ft);
		array_push(_VBN, fn);
		array_push(tris, tri);
	}
	file_text_close(obj_read_file);
	
	if(use_normal) vn[| 0] = [ 0, 0, 0 ];
	
	obj_read_progress = 1;
	obj_read_prog_sub = 0;
	
	//var txt = "OBJ summary";
	//txt += $"\n\tVerticies : {ds_list_size(v)}";
	//txt += $"\n\tTexture Verticies : {ds_list_size(vt)}";
	//txt += $"\n\tNormal Verticies : {ds_list_size(vn)}";
	//txt += $"\n\tVertex groups : {array_length(_VB)}";
	//txt += $"\n\tTriangles : {tris}";
	//print(txt);	
}

function readObj_cent() {
	#region centralize vertex
		_bmin = v[| 0];
		_bmax = v[| 0];
		cv = [0, 0, 0];
		vertex = ds_list_size(v);
		
		for( var i = 0; i < vertex; i++ ) {
			var _v = v[| i];
			cv[0] += _v[0];
			cv[1] += _v[1];
			cv[2] += _v[2];
			
			_bmin = [
				min(_bmin[0], _v[0]),
				min(_bmin[1], _v[1]),
				min(_bmin[2], _v[2]),
			];
			_bmax = [
				max(_bmax[0], _v[0]),
				max(_bmax[1], _v[1]),
				max(_bmax[2], _v[2]),
			];
		}
		
		cv[0] /= vertex;
		cv[1] /= vertex;
		cv[2] /= vertex;
		
		obj_size = new __vec3(
			_bmax[0] - _bmin[0],
			_bmax[1] - _bmin[1],
			_bmax[2] - _bmin[2],
		);
		
		var sc   = 1;
		//var span = max(abs(_size.x), abs(_size.y), abs(_size.z));
		//if(span > 10) sc = span / 10;
		
		for( var i = 0, n = ds_list_size(v); i < n; i++ ) {
			v[| i][0] = (v[| i][0] - cv[0]) / sc;
			v[| i][1] = (v[| i][1] - cv[1]) / sc;
			v[| i][2] = (v[| i][2] - cv[2]) / sc;
		}
	#endregion
	
	obj_read_progress = 2;
	obj_read_prog_sub = 0;
}

function readObj_buff() {
	#region vertex buffer creation
		var _vblen = array_length(_VB);
		var VBS    = array_create(_vblen);
		var V      = array_create(_vblen);
		
		for(var i = 0; i < _vblen; i++)  {
			var VB = vertex_create_buffer();
			vertex_begin(VB, global.VF_POS_NORM_TEX_COL);
			var face  = _VB[i];
			var facet = _VBT[i];
			var facen = _VBN[i];
			
			var _flen = ds_list_size(face);
			var _v    = ds_list_create();
			
			for(var j = 0; j < _flen; j++) {
				var _f   = face[| j];
				var _ft  = facet[| j];
				var _fn  = facen[| j];
			
				var _vlen = array_length(_f);
				var _pf   = array_create(_vlen);
				var _pft  = array_create(_vlen);
				var _pfn  = array_create(_vlen);
				
				for( var k = 0; k < _vlen; k++ ) {
					var _vPindex = _f[k]  - 1;
					_pf[k] = v[| _vPindex];
					
					var _vNindex = _fn[k] - 1;
					_pfn[k] = vn[| _vNindex];
					
					var _vTindex = _ft[k] - 1;
					_pft[k] = vt[| _vTindex];
				}
				
				if(_vlen >= 3) {
					vertex_add_pntc(VB, _pf[0], _pfn[0], _pft[0]);
					vertex_add_pntc(VB, _pf[2], _pfn[2], _pft[2]);
					vertex_add_pntc(VB, _pf[1], _pfn[1], _pft[1]);
					
					ds_list_add(_v, new __vertex(_pf[0][0], _pf[0][1], _pf[0][2]).setNormal(_pfn[0][0], _pfn[0][1]).setUV(_pft[0][0], _pft[0][1]));
					ds_list_add(_v, new __vertex(_pf[2][0], _pf[2][1], _pf[2][2]).setNormal(_pfn[2][0], _pfn[2][1]).setUV(_pft[2][0], _pft[2][1]));
					ds_list_add(_v, new __vertex(_pf[1][0], _pf[1][1], _pf[1][2]).setNormal(_pfn[1][0], _pfn[1][1]).setUV(_pft[1][0], _pft[1][1]));
				} 
				
				if(_vlen >= 4) {
					vertex_add_pntc(VB, _pf[0], _pfn[0], _pft[0]);
					vertex_add_pntc(VB, _pf[3], _pfn[3], _pft[3]);
					vertex_add_pntc(VB, _pf[2], _pfn[2], _pft[2]);
					
					ds_list_add(_v, new __vertex(_pf[0][0], _pf[0][1], _pf[0][2]).setNormal(_pfn[0][0], _pfn[0][1]).setUV(_pft[0][0], _pft[0][1]));
					ds_list_add(_v, new __vertex(_pf[3][0], _pf[3][1], _pf[3][2]).setNormal(_pfn[3][0], _pfn[3][1]).setUV(_pft[3][0], _pft[3][1]));
					ds_list_add(_v, new __vertex(_pf[2][0], _pf[2][1], _pf[2][2]).setNormal(_pfn[2][0], _pfn[2][1]).setUV(_pft[2][0], _pft[2][1]));
				}
			}
			
			vertex_end(VB);
			vertex_freeze(VB);
		
			VBS[i]  = VB;
			V[i]    = ds_list_to_array(_v);
			ds_list_destroy(_v);
		}
	#endregion
	
	#region clean
		array_foreach(_VB,  function(val, ind) { ds_list_destroy(val); });
		array_foreach(_VBT, function(val, ind) { ds_list_destroy(val); });
		array_foreach(_VBN, function(val, ind) { ds_list_destroy(val); });
		
		ds_list_destroy(v);
		ds_list_destroy(vn);
		ds_list_destroy(vt);
	#endregion
	
	obj_read_progress = 3;
	obj_read_prog_sub = 0;
	
	obj_raw = { 
		vertex: V,
		vertex_count:  vertex,
		vertex_groups: VBS,
		object_counts: _vblen,
		
		materials:		mats,
		material_index: matIndex,
		use_normal:		use_normal,
		mtl_path:		mtlPath,
		model_size:		obj_size,
	};
}