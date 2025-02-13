#region assets
	global.ASSET_MAP   = ds_map_create();
	global.ASSET_CACHE = ds_map_create();
	
	function __initAssets() {
		ds_map_clear(global.ASSET_MAP);
		
		var root = DIRECTORY + "Assets";
		directory_verify(root);
		
		if(check_version($"{root}/version"))
			zip_unzip("data/Assets.zip", root);
		
		if(array_empty(PREFERENCES.path_assets)) {
			global.ASSETS = __initAssetsFolder(root);
			
		} else {
			global.ASSETS = new DirectoryObject("");
			global.ASSETS.name = "Assets";
			
			ds_list_add(global.ASSETS.subDir, __initAssetsFolder(root));
			for( var i = 0, n = array_length(PREFERENCES.path_assets); i < n; i++ ) 
				ds_list_add(global.ASSETS.subDir, __initAssetsFolder(PREFERENCES.path_assets[i]));
		}
		
		__init_dynaDraw();
	}
	
	function __initAssetsFolder(_dir) {
	
		var _folder = new DirectoryObject(_dir);
		    _folder.scan([".png"]);
		    _folder.open = true;
		
		var st = ds_stack_create();
		ds_stack_push(st, _folder);
		
		while(!ds_stack_empty(st)) {
			var _st = ds_stack_pop(st);
			
			for( var i = 0; i < ds_list_size(_st.content); i++ ) {
				var _f = _st.content[| i];
				global.ASSET_MAP[? _f.path] = _f;
			}
			
			for( var i = 0; i < ds_list_size(_st.subDir); i++ ) {
				ds_stack_push(st, _st.subDir[| i]);
			}
		}
		
		ds_stack_destroy(st);
		
		return _folder;
	}
	
	function get_asset(key) {
		if(struct_has(DYNADRAW_SHAPE_MAP, key))   return DYNADRAW_SHAPE_MAP[$ key];
		if(!ds_map_exists(global.ASSET_MAP, key)) return noone;
		
		if(ds_map_exists(global.ASSET_CACHE, key)) {
			var s = global.ASSET_CACHE[? key];
			var valid = true;
			if(is_array(s)) {
				for( var i = 0, n = array_length(s); i < n; i++ )
					valid &= is_surface(s[i]);
			} else 
				valid = is_surface(s);
			if(valid) return s;
		}
		
		var spr = global.ASSET_MAP[? key].getSpr();
		global.ASSET_CACHE[? key] = surface_create_from_sprite(spr);
		
		return global.ASSET_CACHE[? key];
	}
#endregion