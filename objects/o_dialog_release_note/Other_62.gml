/// @description init
var _id     = ds_map_find_value(async_load, "id");
var _status = ds_map_find_value(async_load, "status");

if (_id == note_get) {
    if (_status == 0) {
        note = ds_map_find_value(async_load, "result");
		alarm[0] = 1;
	}
	
} else if (_id == dl_get) {
	if (_status == 0) {
        var res = ds_map_find_value(async_load, "result");
		dls = json_try_parse(res, []);
		
		for( var i = 0, n = array_length(dls); i < n; i++ ) {
			var _v = dls[i].version;
			
			dls[i].status            = 0;
			dls[i].download_path     = "";
			
			dls[i].size_total      = 0;
			dls[i].size_downloaded = 0;
			
			if(struct_has(PREFERENCES.versions, _v)) {
				var _path =  PREFERENCES.versions[$ _v];
				
				if(file_exists(_path)) {
					dls[i].status          = 2;
					dls[i].download_path   = _path;
					dls[i].size_total      = file_size(_path);
				}
			}
		}
		
		PREF_SAVE();
	}
	
} else if ( struct_has(downloading, _id)) {
	var dl = downloading[$ _id];
	
	if(_status == 0) {
		dl.status = 2;
		PREFERENCES.versions[$ dl.version] = dl.download_path;
		PREF_SAVE();
		
	} else if(_status == 1) {
		dl.size_total      = ds_map_find_value(async_load, "contentLength");
		dl.size_downloaded = ds_map_find_value(async_load, "sizeDownloaded");
		
	}
}