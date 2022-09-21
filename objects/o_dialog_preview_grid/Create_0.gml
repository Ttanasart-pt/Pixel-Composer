/// @description init
event_inherited();

#region data
	dialog_w = 280;
	dialog_h = 188;
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function(str) {
		PANEL_PREVIEW.grid_show = !PANEL_PREVIEW.grid_show;
	})
	
	tb_width = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_width = max(1, real(str));	
	})
	
	tb_height = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_height = max(1, real(str));	
	})
#endregion