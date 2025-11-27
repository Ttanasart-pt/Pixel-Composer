function Panel_Animation_Setting() : Panel_Linear_Setting() constructor {
	title = __txtx("animation_settings", "Animation Settings");
	w = ui(380);
	
	properties = [
		
		new __Panel_Linear_Setting_Item(
			__txt("Show Frames"),
			new checkBox(function() /*=>*/ { PANEL_ANIMATION.timeline_frame = !PANEL_ANIMATION.timeline_frame; }),
			function( ) /*=>*/   {return PANEL_ANIMATION.timeline_frame},
			function(v) /*=>*/ { PANEL_ANIMATION.timeline_frame = v; },
			PREFERENCES.panel_animation_frame,
			noone,
			"panel_animation_frame", 
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Frame Separator"),
			textBox_Number(function(str) /*=>*/ { PANEL_ANIMATION.timeline_sep_base = max(1, round(real(str))); }),
			function( ) /*=>*/   {return PANEL_ANIMATION.timeline_sep_base},
			function(v) /*=>*/ { PANEL_ANIMATION.timeline_sep_base = v; },
			PREFERENCES.panel_animation_separate,
			noone,
			"panel_animation_separate",
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txtx("anim_length", "Animation length"),
			textBox_Number(function(str) /*=>*/ { PROJECT.animator.frames_total = round(real(str)); }),
			function( ) /*=>*/   {return PROJECT.animator.frames_total},
			function(v) /*=>*/ { PROJECT.animator.frames_total = v; },
			PREFERENCES.project_animation_duration,
			noone,
			"project_animation_duration",
		),
		
		new __Panel_Linear_Setting_Item(
			__txtx("anim_frame_rate", "Preview frame rate"),
			textBox_Number(function(str) /*=>*/ { PROJECT.animator.framerate = real(str); }),
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