#region samples
	globalvar SAMPLE_PROJECTS;
	SAMPLE_PROJECTS = ds_list_create();
#endregion

function LOAD_FOLDER(list, folder) {
	var path = directory_get_current_working() + folder;
	var file = file_find_first(path + "/*", fa_directory);
	while(file != "") {
		if(filename_ext(file) == ".json" || filename_ext(file) == ".pxc") {
			var full_path = path + "\\" + file;
			var f = new FileObject(string_replace(filename_name(file), filename_ext(file), ""), full_path);
			var icon_path = string_replace(full_path, filename_ext(full_path), ".png");
				
			if(file_exists(icon_path)) {
				f.spr = sprite_add(icon_path, 0, false, false, 0, 0);
				sprite_set_offset(f.spr, sprite_get_width(f.spr) / 2, sprite_get_height(f.spr) / 2);
			}
			
			f.tag = folder;
			
			ds_list_add(list, f);
		}
		file = file_find_next();
	}
	file_find_close();
}

function LOAD_SAMPLE() {
	ds_list_clear(SAMPLE_PROJECTS);
	
//	LOAD_FOLDER(SAMPLE_PROJECTS, "Getting started");
//	LOAD_FOLDER(SAMPLE_PROJECTS, "Sample Projects");
}