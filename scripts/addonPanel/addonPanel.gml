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
	
	function init() {
		lua_add_file(thread, scriptPath);
		var runResult = lua_call(thread, "init");
		
		array_push(ANIMATION_PRE,  animationPreStep);
		array_push(ANIMATION_POST, animationPostStep);
	}
	init();
	
	function stepBegin() {
		__addon_lua_panel_variable(thread, self);
		
		var runResult = lua_call(thread, "step");
	}
	
	function animationPreStep() {
		var runResult = lua_call(thread, "animationPreStep");
	}
	
	function animationPostStep() {
		var runResult = lua_call(thread, "animationPostStep");
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
	
	function cleanUp() {
		array_remove(ANIMATION_PRE,  animationPreStep);
		array_remove(ANIMATION_POST, animationPostStep);
	}
}