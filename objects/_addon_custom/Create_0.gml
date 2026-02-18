/// @description 
event_inherited();

#region init
	alarm[0] = 1;
	
	function init(_directory, _openDialog = true) {
		ID = UUID_generate();
		global.ADDON_ID[? ID] = self;
		
		directory = _directory;
		name      = filename_name_only(directory);
		ready     = false;
		thread    = lua_create();
		__addon_lua_setup(thread, self);
		
		var propPath  = $"{directory}/meta.json";
		context_menus = {};
		panels        = {};
		scripts       = [ "./script.lua" ];
		
		if(file_exists_empty(propPath)) {
			var meta = json_load_struct(propPath);
			if(struct_has(meta, "scripts")) 
				scripts = meta.scripts;
				
			if(struct_has(meta, "panels")) {
				panels = meta.panels;
				
				if(_openDialog) {
					var arr = variable_struct_get_names(panels);
					for( var i = 0, n = array_length(arr); i < n; i++ ) {
						var _key = arr[i];
						var pane = panels[$ _key];
					
						if(struct_has(pane, "main") && pane.main)
							dialogPanelCall(new addonPanel(self, pane));
					}
				}
			}
			
			if(struct_has(meta, "context_menu_callbacks")) {
				context_menus =  meta.context_menu_callbacks;
				
				var arr = variable_struct_get_names(context_menus);
				for( var i = 0, n = array_length(arr); i < n; i++ ) {
					var _call = ds_map_try_get(CONTEXT_MENU_CALLBACK, arr[i], []);
					var _fnk  = context_menus[$ arr[i]];
					var _gen  = new addonContextGenerator(self, _fnk);
					array_push(_call, _gen);
					
					CONTEXT_MENU_CALLBACK[? arr[i]] = _call;
				}
			}
		}
		
		for( var i = 0, n = array_length(scripts); i < n; i++ ) {
			var _scr = scripts[i];
			    _scr = string_replace(_scr, "./", directory + "/");
			
			if(!file_exists_empty(_scr)) {
				noti_warning($"[{name}] Addon error: {_scr} not found.");
				continue;
			}
			
			lua_add_file(thread, _scr);
		}
		
		try { var runResult = lua_call(thread, "init"); }
		catch(e) exception_print(e);
		
		array_push(ANIMATION_PRE,  animationPreStep);
		array_push(ANIMATION_POST, animationPostStep);
	}
	
	function animationPreStep() {
		INLINE
		if(!ready) return;
		
		try { var runResult = lua_call(thread, "animationPreStep"); }
		catch(e) exception_print(e);
	}
	
	function animationPostStep() {
		INLINE
		if(!ready) return;
		
		try { var runResult = lua_call(thread, "animationPostStep"); }
		catch(e) exception_print(e);
	}
	
	function callFunctions(fn) {
		INLINE
		if(!ready) return;
		
		try { lua_call(thread, fn); }
		catch(e) exception_print(e);
	}
#endregion