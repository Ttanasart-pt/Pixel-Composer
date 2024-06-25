function readObj_init(_scale = 1, _yneg = false) {
	obj_reading = true;
	obj_read_progress = 0;
	obj_read_prog_sub = 0;
	obj_read_prog_tot = 3;
	obj_raw = noone;
	
	obj_reading_scale = _scale;
	obj_reading_yneg  = _yneg;
	
	_VB  = [];
	_VBT = [];
	_VBN = [];
	mats = [];
	
	matIndex   = [];
	tris       = [];
	mtlPath    = "";
	use_material = false;
	use_normal   = true;
	
	v   = [];
	vt  = [];
	vn  = [];
	f   = [];
	ft  = [];
	fn  = [];
	tri = 0;
}

function readObj_file() {
	var _time = current_time;
	
	while(!file_text_eof(obj_read_file)) { #region reading file
		var l = file_text_readln(obj_read_file);
		l = string_trim(l);
		
		var sep = string_split(l, " ", true);
		if(array_length(sep) == 0) continue;
		
		switch(sep[0]) {
			case "v" :
				if(obj_reading_yneg) {
					array_push(v, [ 
						 real(sep[1]) * obj_reading_scale, 
						 real(sep[3]) * obj_reading_scale,
						-real(sep[2]) * obj_reading_scale, 
					]);
				} else {
					array_push(v, [ 
						real(sep[1]) * obj_reading_scale, 
						real(sep[2]) * obj_reading_scale, 
						real(sep[3]) * obj_reading_scale,
					]);
				}
				break;
				
			case "vt" :
				var _u = real(sep[1]);
				var _v = real(sep[2]);
				
				array_push(vt, [ _u, _v ]);
				break;
				
			case "vn" :
				var _nx = real(sep[1]);
				var _ny = real(sep[2]);
				var _nz = real(sep[3]);
				
				array_push(vn, [ _nx, _ny, _nz ]);
				break;
				
			case "f" :
				var _len = array_length(sep);
				var _f   = array_create(_len - 1);
				var _ft  = array_create(_len - 1);
				var _fn  = array_create(_len - 1);
				
				for( var i = 1; i < _len; i++ ) {
					var _sp    = string_split(sep[i], "/");
					if(array_length(_sp) < 3) continue;
					
					_f[i - 1]  = real(_sp[0]) - 1;
					_ft[i - 1] = real(_sp[1]) - 1;
					_fn[i - 1] = real(_sp[2]) - 1;
					
					use_normal = array_length(_sp) >= 4;
				}
				
				tri += _len - 2;
				array_push(f,  _f ); //get position
				array_push(ft, _ft); //get texture map
				array_push(fn, _fn); //get normal
				break;
				
			case "usemtl" :
				use_material = true;
				var mname = "";
				for( var i = 1; i < array_length(sep); i++ )
					mname += (i == 1? "" : " ") + sep[i];
				mname = string_trim(mname);
				
				array_push_unique(mats, mname);
				array_push(matIndex, array_find(mats, mname));
				
				if(!array_empty(f)) {
					array_push(_VB,  f);
					array_push(_VBT, ft);
					array_push(_VBN, fn);
					array_push(tris, tri);
					f  = [];
					ft = [];
					fn = [];
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
	
	if(!array_empty(f)) {
		array_push(_VB,  f);
		array_push(_VBT, ft);
		array_push(_VBN, fn);
		array_push(tris, tri);
	}
	file_text_close(obj_read_file);
	
	if(use_normal) vn[0] = [ 0, 0, 0 ];
	
	obj_read_progress = 1;
	obj_read_prog_sub = 0;
}

function readObj_cent() {
	#region centralize vertex
		var _v0 = v[0];
		var _bminx = _v0[0];
		var _bminy = _v0[1];
		var _bminz = _v0[2];
		
		var _bmaxx = _v0[0];
		var _bmaxy = _v0[1];
		var _bmaxz = _v0[2];
		
		var cvx = 0;
		var cvy = 0;
		var cvz = 0;
		
		vertex = array_length(v);
		
		for( var i = 0; i < vertex; i++ ) {
			var _v  = v[i];
			var _v0 = _v[0]; 
			var _v1 = _v[1];
			var _v2 = _v[2];
			
			cvx += _v0;
			cvy += _v1;
			cvz += _v2;
			
			_bminx = min(_bminx, _v0);
			_bminy = min(_bminy, _v1);
			_bminz = min(_bminz, _v2);
			
			_bmaxx = max(_bmaxx, _v0);
			_bmaxy = max(_bmaxy, _v1);
			_bmaxz = max(_bmaxz, _v2);
		}
		
		cvx /= vertex;
		cvy /= vertex;
		cvz /= vertex;
		
		obj_size = new __vec3(
			_bmaxx - _bminx,
			_bmaxy - _bminy,
			_bmaxz - _bminz,
		);
		
		for( var i = 0; i < vertex; i++ ) {
			var _v = v[i];
			
			_v[0] = _v[0] - cvx;
			_v[1] = _v[1] - cvy;
			_v[2] = _v[2] - cvz;
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
			
			var _flen = array_length(face);
			var _v    = [];
			
			for(var j = 0; j < _flen; j++) {
				var _f   = face[j];
				var _ft  = facet[j];
				var _fn  = facen[j];
			
				var _vlen = array_length(_f);
				var _pf   = array_create(_vlen);
				var _pft  = array_create(_vlen);
				var _pfn  = array_create(_vlen);
				
				for( var k = 0; k < _vlen; k++ ) {
					_pf[k]  = v[_f[k]];
					_pfn[k] = vn[_fn[k]];
					_pft[k] = vt[_ft[k]];
				}
				
				var _pf0  = _pf[0],  _pf1  = _pf[1],  _pf2  = _pf[2];
				var _pfn0 = _pfn[0], _pfn1 = _pfn[1], _pfn2 = _pfn[2];
				var _pft0 = _pft[0], _pft1 = _pft[1], _pft2 = _pft[2];
				
				// if(_vlen >= 3) {
					vertex_add_pntc(VB, _pf0, _pfn0, _pft0);
					vertex_add_pntc(VB, _pf2, _pfn2, _pft2);
					vertex_add_pntc(VB, _pf1, _pfn1, _pft1);
					
					array_push(_v, new __vertex(_pf0[0], _pf0[1], _pf0[2]).setNormal(_pfn0[0], _pfn0[1]).setUV(_pft0[0], _pft0[1]));
					array_push(_v, new __vertex(_pf2[0], _pf2[1], _pf2[2]).setNormal(_pfn2[0], _pfn2[1]).setUV(_pft2[0], _pft2[1]));
					array_push(_v, new __vertex(_pf1[0], _pf1[1], _pf1[2]).setNormal(_pfn1[0], _pfn1[1]).setUV(_pft1[0], _pft1[1]));
				// } 
				
				if(_vlen >= 4) {
					var _pf3  = _pf[3];
					var _pfn3 = _pfn[3];
					var _pft3 = _pft[3];
					
					vertex_add_pntc(VB, _pf0, _pfn0, _pft0);
					vertex_add_pntc(VB, _pf3, _pfn3, _pft3);
					vertex_add_pntc(VB, _pf2, _pfn2, _pft2);
					
					array_push(_v, new __vertex(_pf0[0], _pf0[1], _pf0[2]).setNormal(_pfn0[0], _pfn0[1]).setUV(_pft0[0], _pft0[1]));
					array_push(_v, new __vertex(_pf3[0], _pf3[1], _pf3[2]).setNormal(_pfn3[0], _pfn3[1]).setUV(_pft3[0], _pft3[1]));
					array_push(_v, new __vertex(_pf2[0], _pf2[1], _pf2[2]).setNormal(_pfn2[0], _pfn2[1]).setUV(_pft2[0], _pft2[1]));
				}
			}
			
			vertex_end(VB);
			
			VBS[i]  = VB;
			V[i]    = _v;
		}
	#endregion
	
	obj_read_progress = 3;
	obj_read_prog_sub = 0;
	
	obj_raw = { 
		vertex: V,
		vertex_count:  vertex,
		vertex_groups: VBS,
		object_counts: _vblen,
		
		use_material:	use_material,
		materials:		mats,
		material_index: matIndex,
		use_normal:		use_normal,
		mtl_path:		mtlPath,
		model_size:		obj_size,
	};
}