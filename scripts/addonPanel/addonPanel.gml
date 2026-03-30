global.ADDON_WIDGET = ds_map_create();
global.ADDON_ID = ds_map_create();

function addonPanel(_addon, _pane) : PanelContent() constructor {
	ID = UUID_generate();
	target = _addon;
	pane   = _pane;
	title  = filename_name_only(target.directory);
	
	w = ui(pane.w);
	h = ui(pane.h);
	showHeader = true;
	
	drawFn   = struct_has(pane, "drawFn")?	 pane.drawFn   : "";
	drawUIFn = struct_has(pane, "drawUIFn")? pane.drawUIFn : "";
	closeFn  = struct_has(pane, "closeFn")?	 pane.closeFn  : "";
	
	try { __addon_lua_panel_variable(target.thread, self); } 
	catch(e) exception_print(e);
	
	function drawGUI() {
		if(drawUIFn == "") return;
		if(!target.ready)  return;
		
		try {
			lua_add_code(target.thread, $"panelID = '{ID}'");
			var runResult = lua_call(target.thread, drawUIFn);
		} catch(e) exception_print(e);
	}
	
	function onResize() {
		
	}
	
	function drawContent(panel) {
		if(drawFn == "")  return;
		if(!target.ready) return;
		
		try {
			lua_add_code(target.thread, $"panelID = '{ID}'");
			__addon_lua_panel_variable(target.thread, self);
			var runResult = lua_call(target.thread, drawFn);
		} catch(e) exception_print(e);
	}
	
	static onClose = function() {
		if(closeFn == "") return;
		if(!target.ready) return;
		
		try {
			var runResult = lua_call(target.thread, closeFn);
		} catch(e) exception_print(e);
	}
}