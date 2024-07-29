function Panel_Animation_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("animation_settings", "Animation Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txtx("anim_length", "Animation length"),
				new textBox(TEXTBOX_INPUT.number, function(str) { TOTAL_FRAMES = real(str);	}),
				function() { return TOTAL_FRAMES; }
			),
			new __Panel_Linear_Setting_Item(
				__txtx("anim_frame_rate", "Preview frame rate"),
				new textBox(TEXTBOX_INPUT.number, function(str) { PROJECT.animator.framerate = real(str); }),
				function() { return PROJECT.animator.framerate; }
			),
			new __Panel_Linear_Setting_Item(
				__txtx("anim_on_end", "On end"),
				new buttonGroup([ __txt("Loop"), __txt("Stop"), __txt("Ping Pong")], function(b) { PROJECT.animator.playback = b; }),
				function() { return PROJECT.animator.playback; }
			),
		];
		
		setHeight();
	#endregion
}