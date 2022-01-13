/// @description init
event_inherited();

#region data
	dialog_w = 368;
	dialog_h = 144;
	
	destroy_on_click_out = true;
#endregion

#region data
	tb_width = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_width = max(1, real(str));	
	})
	
	tb_height = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_height = max(1, real(str));	
	})
#endregion