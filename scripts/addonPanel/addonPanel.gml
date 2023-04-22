function addonPanel(directory) : PanelContent() constructor {
	thread = lua_create();
	lua_error_handler = _lua_error;
	__addon_lua_setup(thread);
	
	self.directory = directory;
	
	title = filename_name_only(directory);
	showHeader = true;
	
	var propPath = directory + "\\meta.json";
	if(file_exists(propPath)) {
		var meta = json_load_struct(propPath);
		w = meta[$ "w"];
		h = meta[$ "h"];
	}
	
	icon = THEME.addon;
	var iconPath = directory + "\\icon.png";
	if(file_exists(iconPath)) {
		icon = sprite_add(iconPath, 0, false, false, 0, 0);
		sprite_set_offset(icon, sprite_get_width(icon) / 2, sprite_get_height(icon) / 2);
	}
	
	scriptPath = directory + "\\script.lua";
	if(!file_exists(scriptPath)) {
		noti_warning(title + " Addon error: script.lua not found.");
		return self;
	}
	
	static init = function() {
		lua_add_file(thread, scriptPath);
		var runResult = lua_call(thread, "init");
	}
	init();
	
	function stepBegin() {
		var runResult = lua_call(thread, "step");
	}
	
	function drawGUI() {
		var runResult = lua_call(thread, "drawUI");
	}
	
	//
	
	function onResize() {
		
	}
	
	function drawContent(panel) {
		var runResult = lua_call(thread, "draw");
	}
	
	//
	
	static cleanUp = function() {
		lua_state_destroy(thread);
	}
}