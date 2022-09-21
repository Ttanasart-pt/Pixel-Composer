/// @description init
event_inherited();

#region data
	dialog_w = 368;
	dialog_h = 120;
	destroy_on_click_out = true;
#endregion

#region scaler
	scale_to = ANIMATOR.frames_total;
	tb_scale_frame = new textBox(TEXTBOX_INPUT.number, function(to) {
		to = toNumber(to);
		scale_to = to;
	});
#endregion