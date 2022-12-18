function readObj(path) {
	if(!file_exists(path)) return noone;
	
	var _VB  = [];
	var _VBT = [];
	var _VBN = [];
	var mats = [];
	var matIndex = [];
	var use_normal = true;
	var v  = ds_list_create();
	var vt = ds_list_create();
	var vn = ds_list_create();
	var f  = ds_list_create();
	var ft = ds_list_create();
	var fn = ds_list_create();
	
	var file = file_text_open_read(path);
	while(!file_text_eof(file)) {
		var l = file_text_readln(file);
		l = string_replace_all(l, "\n", "");
		
		var sep = string_splice(l, " ");
		if(array_length(sep) == 0 || sep[0] == "") continue;
		
		switch(sep[0]) {
			case "v" :
				ds_list_add(v, [ toNumber(sep[1]), toNumber(sep[2]), toNumber(sep[3]) ]);
				break;
			case "vt" :
				ds_list_add(vt, [ 1 + toNumber(sep[1]), -toNumber(sep[2]) ]);
				break;
			case "vn" :
				ds_list_add(vn, [ toNumber(sep[1]), toNumber(sep[2]), toNumber(sep[3]) ]);
				break;
			case "f" :
				var f1 = string_splice(sep[1], "/");
				var f2 = string_splice(sep[2], "/");
				var f3 = string_splice(sep[3], "/");
				
				ds_list_add(f,  [f1[0], f2[0], f3[0]]);
				ds_list_add(ft, [f1[1], f2[1], f3[1]]);
				if(array_length(f1) > 2)	ds_list_add(fn, [f1[2], f2[2], f3[2]]);
				else {
					ds_list_add(fn, [0, 0, 0]);
					use_normal = false;
				}
				break;
			case "usemtl" :
				array_push_unique(mats, sep[1]);
				array_push(matIndex, array_find(mats, sep[1]));
				if(!ds_list_empty(f)) {
					array_push(_VB,  f);
					array_push(_VBT, ft);
					array_push(_VBN, fn);
					f  = ds_list_create();
					ft = ds_list_create();
					fn = ds_list_create();
				}
				break;
		}
	}
	if(!ds_list_empty(f)) {
		array_push(_VB,  f);
		array_push(_VBT, ft);
		array_push(_VBN, fn);
	}
	file_text_close(file);
	
	#region centralize vertex
		var cv = [0, 0, 0];
		var vertex = ds_list_size(v);
		for( var i = 0; i < vertex; i++ ) {
			var _v = v[| i];
			cv[0] += _v[0];
			cv[1] += _v[1];
			cv[2] += _v[2];
		}
		
		cv[0] /= vertex;
		cv[1] /= vertex;
		cv[2] /= vertex;
		
		for( var i = 0; i < ds_list_size(v); i++ ) {
			v[| i][0] -= cv[0];
			v[| i][1] -= cv[1];
			v[| i][2] -= cv[2];
		}
	#endregion
	
	var VBS = [];
	for(var i = 0; i < array_length(_VB); i++)  {
		var VB = vertex_create_buffer();
		vertex_begin(VB, FORMAT_PNT);
		var face  = _VB[i];
		var facet = _VBT[i];
		var facen = _VBN[i];
		
		for(var j = 0; j < ds_list_size(face); j++) {
			var _f   = face[| j];
			var _f1  = v[| _f[0] - 1];
			var _f2  = v[| _f[1] - 1];
			var _f3  = v[| _f[2] - 1];
		
			var _ft  = facet[| j];
			var _ft1 = vt[| _ft[0] - 1];
			var _ft2 = vt[| _ft[1] - 1];
			var _ft3 = vt[| _ft[2] - 1];
		
			var _fn  = facen[| j];
			var _fn1 = _fn[0]? vn[| _fn[0] - 1] : [0, 0, 0];
			var _fn2 = _fn[1]? vn[| _fn[1] - 1] : [0, 0, 0];
			var _fn3 = _fn[2]? vn[| _fn[2] - 1] : [0, 0, 0];
			
			vertex_add_pnt(VB, _f1, _fn1, _ft1 );
			vertex_add_pnt(VB, _f2, _fn2, _ft2 );
			vertex_add_pnt(VB, _f3, _fn3, _ft3 );
		}
		vertex_end(VB);
		vertex_freeze(VB);
		
		array_push(VBS, VB);
		
		ds_list_destroy(face);
		ds_list_destroy(facet);
	}
	
	ds_list_destroy(v);
	ds_list_destroy(vt);
	ds_list_destroy(vn);
	ds_list_destroy(f);
	ds_list_destroy(ft);
	ds_list_destroy(fn);
	
	return [ VBS, mats, matIndex, use_normal ];
}