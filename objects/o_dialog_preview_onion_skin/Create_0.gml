/// @description init
event_inherited();

#region data
	dialog_w = ui(400);
	dialog_h = ui(300);
	
	destroy_on_click_out = true;
#endregion

#region data
	cb_enable = new checkBox(function() {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled;
	});
	
	cb_top = new checkBox(function() {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.on_top = !PROJECT.onion_skin.on_top;
	});
	
	tb_step = new textBox(TEXTBOX_INPUT.number, function(str) {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.step = max(1, round(real(str)));	
	});
	
	cl_color_pre = new buttonColor(function(color) {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.color[0] = color;
	}, self);
	
	cl_color_post = new buttonColor(function(color) {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.color[1] = color;
	}, self);
	
	sl_opacity = new slider(0, 1, .05, function(str) {
		var _node = PANEL_PREVIEW.getNodePreview();
		PROJECT.onion_skin.alpha = clamp(real(str), 0, 1);
	});
#endregion