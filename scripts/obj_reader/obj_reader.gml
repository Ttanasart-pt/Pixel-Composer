function readObj(path) {
	var _VB  = [];
	var _VBT = [];
	var mats = [];
	var v  = ds_list_create();
	var vt = ds_list_create();
	var f  = ds_list_create();
	var ft = ds_list_create();
	
	if(!file_exists(path)) return noone;
	
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
				ds_list_add(vt, [ toNumber(sep[1]), toNumber(sep[2]) ]);
				break;
			case "f" :
				var f1 = string_splice(sep[1], "/");
				var f2 = string_splice(sep[2], "/");
				var f3 = string_splice(sep[3], "/");
				
				ds_list_add(f,  [f1[0], f2[0], f3[0]]);
				ds_list_add(ft, [f1[1], f2[1], f3[1]]);
				break;
			case "usemtl" :
				array_push(mats, sep[1]);
				if(!ds_list_empty(f)) {
					array_push(_VB,  f);
					array_push(_VBT, ft);
					f  = ds_list_create();
					ft = ds_list_create();
				}
				break;
		}
	}
	if(!ds_list_empty(f)) {
		array_push(_VB,  f);
		array_push(_VBT, ft);
	}
	file_text_close(file);
	
	var VBS = [];
	for(var i = 0; i < array_length(_VB); i++)  {
		var VB = vertex_create_buffer();
		vertex_begin(VB, FORMAT_PT);
		var face  = _VB[i];
		var facet = _VBT[i];
	
		for(var j = 0; j < ds_list_size(face); j++) {
			var _f   = face[| j];
			var _f1  = v[| _f[0] - 1];
			var _f2  = v[| _f[1] - 1];
			var _f3  = v[| _f[2] - 1];
		
			var _ft  = facet[| j];
			var _ft1 = vt[| _ft[0] - 1];
			var _ft2 = vt[| _ft[1] - 1];
			var _ft3 = vt[| _ft[2] - 1];
		
			vertex_add_pt(VB, _f1, _ft1 );
			vertex_add_pt(VB, _f2, _ft2 );
			vertex_add_pt(VB, _f3, _ft3 );
		}
		vertex_end(VB);
		vertex_freeze(VB);
		
		array_push(VBS, VB);
		
		ds_list_destroy(face);
		ds_list_destroy(facet);
	}
	
	ds_list_destroy(v);
	ds_list_destroy(vt);
	
	return [ VBS, mats ];
}