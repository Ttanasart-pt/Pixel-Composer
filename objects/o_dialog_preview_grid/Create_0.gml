/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(300);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function() {
		PANEL_PREVIEW.grid_show = !PANEL_PREVIEW.grid_show;
	});
	
	cb_snap = new checkBox(function() {
		PANEL_PREVIEW.grid_snap = !PANEL_PREVIEW.grid_snap;
	});
	
	tb_width = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_width = max(1, real(str));	
	});
	
	tb_height = new textBox(TEXTBOX_INPUT.number, function(str) {
		PANEL_PREVIEW.grid_height = max(1, real(str));	
	});
	
	sl_opacity = new slider(0, 1, .05, function(str) {
		PANEL_PREVIEW.grid_opacity = clamp(real(str), 0, 1);	
	});
	
	cl_color = buttonColor(function(color) {
		PANEL_PREVIEW.grid_color = color;
	});
#endregion