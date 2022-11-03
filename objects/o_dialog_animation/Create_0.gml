/// @description init
event_inherited();

#region data
	anchor = ANCHOR.right | ANCHOR.bottom;
	
	dialog_w = ui(368);
	dialog_h = ui(188);
	
	destroy_on_click_out = true;
#endregion

#region data
	tb_length = new textBox(TEXTBOX_INPUT.number, function(str) {
		ANIMATOR.frames_total = real(str);	
	})
	
	tb_framerate = new textBox(TEXTBOX_INPUT.number, function(str) {
		ANIMATOR.framerate = real(str);	
	})
	
	eb_playback = buttonGroup(["Loop", "Stop"], function(b) {
		ANIMATOR.playback = b;	
	});
#endregion