global.ADDON_WIDGET = ds_map_create();
global.ADDON_ID = ds_map_create();

function addonPanel(_addon, pane, _callFn, _callUIFn = "") : PanelContent() constructor {
	ID = UUID_generate();
	self._addon = _addon;
	self.pane = pane;
	callFn   = _callFn;
	callUIFn = _callUIFn;
	
	title = filename_name_only(_addon.directory);
	__addon_lua_panel_variable(_addon.thread, self);
	
	showHeader = true;
	
	w = pane.w;
	h = pane.h;
	
	function drawGUI() {
		if(callUIFn == "") return;
		if(!_addon.ready) return;
		lua_add_code(_addon.thread, "panelID = '" + string(ID) + "'");
		var runResult = lua_call(_addon.thread, callUIFn);
	}
	
	function onResize() {
		
	}
	
	function drawContent(panel) {
		if(!_addon.ready) return;
		lua_add_code(_addon.thread, "panelID = '" + string(ID) + "'");
		__addon_lua_panel_variable(_addon.thread, self);
		var runResult = lua_call(_addon.thread, callFn);
	}
	
	function onClose() {
		
	}
}