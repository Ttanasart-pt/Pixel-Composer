global.ADDON_WIDGET = ds_map_create();
global.ADDON_ID = ds_map_create();

function addonPanel(_addon, pane) : PanelContent() constructor {
	ID = UUID_generate();
	self._addon = _addon;
	self.pane   = pane;
	
	drawFn   = struct_has(pane, "drawFn")?	 pane.drawFn   : "";
	drawUIFn = struct_has(pane, "drawUIFn")? pane.drawUIFn : "";
	closeFn  = struct_has(pane, "closeFn")?	 pane.closeFn  : "";
	
	title = filename_name_only(_addon.directory);
	__addon_lua_panel_variable(_addon.thread, self);
	
	showHeader = true;
	
	w = pane.w;
	h = pane.h;
	
	function drawGUI() {
		if(drawUIFn == "") return;
		if(!_addon.ready) return;
		lua_add_code(_addon.thread, "panelID = '" + string(ID) + "'");
		var runResult = lua_call(_addon.thread, drawUIFn);
	}
	
	function onResize() {
		
	}
	
	function drawContent(panel) {
		if(drawFn == "") return;
		if(!_addon.ready) return;
		lua_add_code(_addon.thread, "panelID = '" + string(ID) + "'");
		__addon_lua_panel_variable(_addon.thread, self);
		var runResult = lua_call(_addon.thread, drawFn);
	}
	
	static onClose = function() {
		if(closeFn == "") return;
		if(!_addon.ready) return;
		var runResult = lua_call(_addon.thread, closeFn);
	}
}