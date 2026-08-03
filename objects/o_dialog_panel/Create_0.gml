/// @description 
event_inherited();

#region panel
	dialog_w             = ui(640);
	dialog_h             = ui(480);
	padding              = ui(4);
	title_height         = ui(24);
	dialog_resizable     = true;
	destroy_on_click_out = true;
	destroy_on_escape    = true;
	
	panel_toRefresh = false;
	panel   = new Panel(noone, x, y, dialog_w, dialog_h).setDialog(self);
	content = undefined;
#endregion
	
function setContent(_content) {
	var _cnt   = undefined;
	var _dia_w = 0;
	var _dia_h = 0;
	
	if(is(_content, PanelContent)) {
		_dia_w = _content.w;
		_dia_h = _content.h;
		
		panel.setContent(_content);
		_cnt = panel.getContent();
		
	} else if(typeof(_content) == "struct") {
		_dia_w = min(ui(_content.pref_w), WIN_W);
		_dia_h = min(ui(_content.pref_h), WIN_H);
		panel.verify(_dia_w, _dia_h);
		
		_cnt = __loadPanelStruct(panel, _content);
		if(!is(_cnt, PanelContent)) 
			_cnt = panel.getContent();
	}
	
	if(!is(_cnt, PanelContent)) {
		instance_destroy();
		return;
	}
	
	title       = _cnt.title;
	content     = _cnt;
	context_str = _cnt.context_str;
	
	if(has(_cnt, "title_height"))
		title_height = _cnt.title_height;
	
	dialog_w         = _dia_w +  padding * 2;
	dialog_h         = _dia_h + (padding * 2 + title_height);
	dialog_w_min     = _cnt.min_w;
	dialog_h_min     = _cnt.min_h;
	dialog_resizable = _cnt.resizable;
	
	_dialog_w = dialog_w;
	_dialog_h = dialog_h;
	
	if(_cnt.auto_pin) {
		destroy_on_click_out = false;
		destroy_on_escape    = false;
	}
	
	panel_toRefresh = true;
}

#region draw
	function onDrag(dx, dy) {  if(!is_winwin(window)) panel.move(dx, dy); }
	
	function dragStart() {
		dialog_dragging = true;
		dialog_drag_sx  = dialog_x;
		dialog_drag_sy  = dialog_y;
		dialog_drag_mx  = mouse_rx;
		dialog_drag_my  = mouse_ry;
	}
#endregion

function forceResize(_cont) {
	// dialog_h = _cont.h + (padding * 2 + title_height);
}

onCheckMouse = function() /*=>*/ {
	if(is_winwin(window)) WINWIN_CURRENT = window;
	panel.checkMouse();
	panel.postCheckMouse();
	if(is_winwin(window)) WINWIN_CURRENT = undefined;
}

onCheckFocus = function() /*=>*/ {return panel.checkFocus()};

function checkClosable() {
	var _cnt = panel.getContent();
	return is(_cnt, PanelContent)? _cnt.checkClosable() : true;
}

function onDestroy() { panel.onClose();    }
function remove()    { instance_destroy(); }