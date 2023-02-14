function readObj(path, flipUV = false) {
	if(!file_exists(path)) return noone;
	
	var _VB  = [];
	var _VBT = [];
	var _VBN = [];
	var mats = [];
	var matIndex = [];
	var mtlPath = "";
	var use_normal = true;
	var v  = [];
	var vt = [];
	var vn = [];
	var f  = [];
	var ft = [];
	var fn = [];
	var face = 0;
	
	var file = file_text_open_read(path);
	while(!file_text_eof(file)) {
		var l = file_text_readln(file);
		l = string_replace_all(l, "\n", "");
		
		var sep = string_splice(l, " ");
		if(array_length(sep) == 0 || sep[0] == "") continue;
		
		switch(sep[0]) {
			case "v" :
				array_push(v, [ toNumber(sep[1]), toNumber(sep[2]), toNumber(sep[3]) ]);
				break;
			case "vt" :
				if(flipUV) 
					array_push(vt, [ toNumber(sep[1]), 1 - toNumber(sep[2]) ]);
				else 
					array_push(vt, [ toNumber(sep[1]), toNumber(sep[2]) ]);
				break;
			case "vn" :
				array_push(vn, [ toNumber(sep[1]), toNumber(sep[2]), toNumber(sep[3]) ]);
				break;
			case "f" :
				var _f  = [];
				var _ft = [];
				var _fn = [];
				
				for( var i = 1; i < array_length(sep); i++ ) {
					var _sp = string_splice(sep[i], "/");
					_f[i - 1]  = toNumber(array_safe_get(_sp, 0));
					_ft[i - 1] = toNumber(array_safe_get(_sp, 1));
					_fn[i - 1] = toNumber(array_safe_get(_sp, 2));
					
					if(array_length(_sp) < 3) use_normal = false;
				}
				
				face++;
				array_push(f,  _f ); //get position
				array_push(ft, _ft); //get texture map
				array_push(fn, _fn); //get normal
				break;
			case "usemtl" :
				var mname = "";
				for( var i = 1; i < array_length(sep); i++ )
					mname += (i == 1? "" : " ") + sep[i];
				mname = string_trim(mname);
				
				array_push_unique(mats, mname);
				array_push(matIndex, array_find(mats, mname));
				
				if(array_length(f)) {
					array_push(_VB,  f);
					array_push(_VBT, ft);
					array_push(_VBN, fn);
					f  = [];
					ft = [];
					fn = [];
				}
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
	}
	if(array_length(f)) {
		array_push(_VB,  f);
		array_push(_VBT, ft);
		array_push(_VBN, fn);
	}
	file_text_close(file);
	
	var txt = "OBJ summary";
	txt += "\n\tVerticies : " + string(array_length(v));
	txt += "\n\tTexture Verticies : " + string(array_length(vt));
	txt += "\n\tNormal Verticies : " + string(array_length(vn));
	txt += "\n\tFaces : " + string(face);
	txt += "\n\tVertex groups : " + string(array_length(_VB));
	print(txt);
	
	#region centralize vertex
		var cv = [0, 0, 0];
		var vertex = array_length(v);
		for( var i = 0; i < vertex; i++ ) {
			var _v = v[i];
			cv[0] += _v[0];
			cv[1] += _v[1];
			cv[2] += _v[2];
		}
		
		cv[0] /= vertex;
		cv[1] /= vertex;
		cv[2] /= vertex;
		
		for( var i = 0; i < array_length(v); i++ ) {
			v[i][0] -= cv[0];
			v[i][1] -= cv[1];
			v[i][2] -= cv[2];
		}
	#endregion
	
	var VBS = [];
	
	for(var i = 0; i < array_length(_VB); i++)  {
		var VB = vertex_create_buffer();
		vertex_begin(VB, FORMAT_PNT);
		var face  = _VB[i];
		var facet = _VBT[i];
		var facen = _VBN[i];
		
		for(var j = 0; j < array_length(face); j++) {
			var _f   = face[j];
			var _ft  = facet[j];
			var _fn  = facen[j];
			
			var _pf  = [];
			var _pft = [];
			var _pfn = [];
			
			for( var k = 0; k < array_length(_f); k++ ) {
				var _f1  = v[_f[k] - 1];
				var _ft1 = vt[_ft[k] - 1];
				var _fn1 = _fn[k]? vn[_fn[k] - 1] : [0, 0, 0];
				
				array_push( _pf,  _f1);
				array_push(_pft, _ft1);
				array_push(_pfn, _fn1);
			}
			
			if(array_length(_f) >= 3) {
				vertex_add_pnt(VB, _pf[0], _pfn[0], _pft[0]);
				vertex_add_pnt(VB, _pf[1], _pfn[1], _pft[1]);
				vertex_add_pnt(VB, _pf[2], _pfn[2], _pft[2]);
			} 
			
			if(array_length(_f) >= 4) {
				vertex_add_pnt(VB, _pf[0], _pfn[0], _pft[0]);
				vertex_add_pnt(VB, _pf[2], _pfn[2], _pft[2]);
				vertex_add_pnt(VB, _pf[3], _pfn[3], _pft[3]);
			}
		}
		vertex_end(VB);
		vertex_freeze(VB);
		
		array_push(VBS, VB);
	}
	
	return { 
		vertex_groups:	VBS,
		materials:		mats,
		material_index: matIndex,
		use_normal:		use_normal,
		mtl_path:		mtlPath,
	};
}