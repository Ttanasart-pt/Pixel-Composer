function Panel_Animation_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("animation_settings", "Animation Settings");
	w = ui(380);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txtx("anim_length", "Animation length"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PROJECT.animator.frames_total = round(real(str)); }),
			function( ) /*=>*/   {return PROJECT.animator.frames_total},
			function(v) /*=>*/ { PROJECT.animator.frames_total = v; },
			PREFERENCES.project_animation_duration,
			noone,
			"project_animation_duration",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("anim_frame_rate", "Preview frame rate"),
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PROJECT.animator.framerate = real(str); }),
			function( ) /*=>*/   {return PROJECT.animator.framerate},
			function(v) /*=>*/ { PROJECT.animator.framerate = v; },
			PREFERENCES.project_animation_framerate,
			noone,
			"project_animation_framerate",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("anim_on_end", "On end"),
			new buttonGroup(__txts([ "Loop", "Stop", "Ping Pong"]), function(b) /*=>*/ { PROJECT.animator.playback = b; }),
			function( ) /*=>*/   {return PROJECT.animator.playback},
			function(v) /*=>*/ { PROJECT.animator.playback = v; },
		),
	];
	
	setHeight();
}