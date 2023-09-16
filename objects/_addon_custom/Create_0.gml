/// @description 
event_inherited();

#region init
	alarm[0] = 1;
	
	function init(directory, _openDialog = true) {
		ID = UUID_generate();
		global.ADDON_ID[? ID] = self;
		ready = false;
		name = filename_name_only(directory);
		
		thread = lua_create();
		__addon_lua_setup(thread, self);
		
		self.directory = directory;
	
		var propPath = directory + "\\meta.json";
		context_menus = {};
		panels = {};
	
		if(file_exists(propPath)) {
			var meta = json_load_struct(propPath);
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
					var _generator = new addonContextGenerator(self, _fnk);
					array_push(_call, _generator);
					
					CONTEXT_MENU_CALLBACK[? arr[i]] = _call;
				}
			}
		}
		
		scriptPath = directory + "\\script.lua";
		if(!file_exists(scriptPath)) {
			noti_warning(title + " Addon error: script.lua not found.");
			return self;
		}
	
		lua_add_file(thread, scriptPath);
		var runResult = lua_call(thread, "init");
		
		array_push(ANIMATION_PRE,  animationPreStep);
		array_push(ANIMATION_POST, animationPostStep);
	}
	
	function animationPreStep() {
		if(!ready) return;
		var runResult = lua_call(thread, "animationPreStep");
	}
	
	function animationPostStep() {
		if(!ready) return;
		var runResult = lua_call(thread, "animationPostStep");
	}
	
	function callFunctions(fn) {
		lua_call(thread, fn);
	}
#endregion