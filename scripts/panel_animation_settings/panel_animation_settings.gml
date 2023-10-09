function Panel_Animation_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("animation_settings", "Animation Settings");
	
	w = ui(380);
	
	#region data
		properties = [
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					TOTAL_FRAMES = real(str);	
				}),
				__txtx("anim_length", "Animation length"),
				function() { return TOTAL_FRAMES; }
			],
			[
				new textBox(TEXTBOX_INPUT.number, function(str) {
					PROJECT.animator.framerate = real(str);	
				}),
				__txtx("anim_frame_rate", "Preview frame rate"),
				function() { return PROJECT.animator.framerate; }
			],
			[
				new buttonGroup([__txt("Loop"), __txt("Stop")], function(b) {
					PROJECT.animator.playback = b;	
				}),
				__txtx("anim_on_end", "On end"),
				function() { return PROJECT.animator.playback; }
			]
		];
		
		setHeight();
	#endregion
}