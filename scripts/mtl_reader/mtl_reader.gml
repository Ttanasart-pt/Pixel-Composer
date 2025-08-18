function MTLmaterial(name) constructor {
	self.name = name;
	self.refc = 0;
	self.diff = c_white;
	self.spec = 0;
	
	self.refc_path = "";
	self.diff_path = "";
	self.spec_path = "";
}

function str_strip_nr(str) {
	str = string_replace_all(str, "\n", "");
	str = string_replace_all(str, "\r", "");
	str = string_replace_all(str, "\\", "/");
	return str;
}

function readMtl(path) {
	if(!file_exists_empty(path)) return [];
	
	var mat = [];
	var cur_mat = noone;
	
	var file = file_text_open_read(path);
	while(!file_text_eof(file)) {
		var l = file_text_readln(file);
		l = string_trim(l);
		
		var sep = string_splice(l, " ");
		var pth = "";
		if(array_length(sep) == 0 || sep[0] == "") continue;
		
		if(array_length(sep) > 1) {
			pth = string_trim_start(l, [sep[0]]);
			pth = string_trim(pth);
			pth = str_strip_nr(pth);
		}
		
		switch(sep[0]) {
			case "newmtl" :
				cur_mat = new MTLmaterial(str_strip_nr(sep[1]));
				array_push(mat, cur_mat);
				break;
				
			case "Ka" :		cur_mat.refc = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			case "Kd" :		cur_mat.diff = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			case "Ks" :		cur_mat.spec = colorFromRGBArray([sep[1], sep[2], sep[3]]); break;
			
			case "map_Ka":	cur_mat.refc_path = pth;  break;
			case "map_Kd":	cur_mat.diff_path = pth;  break;
			case "map_Ks":	cur_mat.spec_path = pth;  break;
		}
	}
	
	file_text_close(file);
	
	return mat;
}