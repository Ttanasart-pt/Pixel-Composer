/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	dialog_h = ui(300);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function() {
		PROJECT.previewGrid.show = !PROJECT.previewGrid.show;
	});
	
	cb_snap = new checkBox(function() {
		PROJECT.previewGrid.snap = !PROJECT.previewGrid.snap;
	});
	
	tb_width = new textBox(TEXTBOX_INPUT.number, function(str) {
		PROJECT.previewGrid.width = max(1, real(str));	
	});
	
	tb_height = new textBox(TEXTBOX_INPUT.number, function(str) {
		PROJECT.previewGrid.height = max(1, real(str));	
	});
	
	sl_opacity = new slider(0, 1, .05, function(str) {
		PROJECT.previewGrid.opacity = clamp(real(str), 0, 1);	
	});
	
	cl_color = new buttonColor(function(color) {
		PROJECT.previewGrid.color = color;
	}, self);
#endregion