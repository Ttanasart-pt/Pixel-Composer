function MTLmaterial(name) constructor {
	self.name = name;
	self.refc = 0;
	self.diff = 0;
	self.spec = 0;
	
	self.refc_path = "";
	self.diff_path = "";
	self.spec_path = "";
}

function readMtl(path) {
	if(!file_exists(path)) return [];
	
	var mat = [];
	var cur_mat = noone;
	
	var file = file_text_open_read(path);
	while(!file_text_eof(file)) {
		var l = file_text_readln(file);
		l = string_replace_all(l, "\n", "");
		
		var sep = string_splice(l, " ");
		if(array_length(sep) == 0 || sep[0] == "") continue;
		
		switch(sep[0]) {
			case "newmtl" :
				cur_mat = new MTLmaterial(sep[1]);
				array_push(mat, cur_mat);
				break;
			case "Ka" : cur_mat.refc = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			case "Kd" : cur_mat.diff = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			case "Ks" : cur_mat.spec = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			case "map_Ka":	cur_mat.refc_path = filename_dir(path) + "/" + sep[1];	break;
			case "map_Kd":	cur_mat.diff_path = filename_dir(path) + "/" + sep[1];	break;
			case "map_Ks":	cur_mat.spec_path = filename_dir(path) + "/" + sep[1];	break;
		}
	}
	
	return mat;
}