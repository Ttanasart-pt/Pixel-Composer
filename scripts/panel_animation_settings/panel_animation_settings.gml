function Panel_Animation_Setting() : Panel_Linear_Setting() constructor {
	title = __txt("animation_settings", "Animation Settings");
	w = ui(380);

	hotkey_play   = find_hotkey("", "Play/Pause");
	hotkey_resume = find_hotkey("", "Resume");
	
	prop_anim_length = new __Panel_Linear_Setting_Item(
		__txt("anim_length", "Animation length"),
		textBox_Number(function(str) /*=>*/ { PROJECT.animator.frames_total = round(real(str)); }),
		function( ) /*=>*/   {return PROJECT.animator.frames_total},
		function(v) /*=>*/ { PROJECT.animator.frames_total = v; },
		PREFERENCES.project_animation_duration,
		noone,
		"project_animation_duration",
	);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Show Frames Preview"),
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
		
		prop_anim_length,
		
		new __Panel_Linear_Setting_Item(
			__txt("anim_frame_rate", "Preview frame rate"),
			textBox_Number(function(str) /*=>*/ { PROJECT.animator.framerate = real(str); }),
			function( ) /*=>*/   {return PROJECT.animator.framerate},
			function(v) /*=>*/ { PROJECT.animator.framerate = v; },
			PREFERENCES.project_animation_framerate,
			noone,
			"project_animation_framerate",
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("anim_on_end", "On end"),
			new buttonGroup(__txts([ "Loop", "Stop", "Ping Pong"]), function(b) /*=>*/ { PROJECT.animator.playback = b; }),
			function( ) /*=>*/   {return PROJECT.animator.playback},
			function(v) /*=>*/ { PROJECT.animator.playback = v; },
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Quantize on Scale"),
			new checkBox(function() /*=>*/ { PREFERENCES.panel_animation_quan_scale = !PREFERENCES.panel_animation_quan_scale; }),
			function( ) /*=>*/   {return PREFERENCES.panel_animation_quan_scale},
			function(v) /*=>*/ { PREFERENCES.panel_animation_quan_scale = v; },
			false,
			noone,
			"panel_animation_quan_scale", 
		),
		
		-1,
		
		new __Panel_Linear_Setting_Item(
			__txt("Spacebar Action"),
			new buttonGroup( [ "Stop", "Resume", "..." ], 
				function(i) /*=>*/ {
					switch(i) {
						case 0 : hotkey_play.set(vk_space, MOD_KEY.none);
							     hotkey_resume.set(vk_space, MOD_KEY.shift); break;
						
						case 1 : hotkey_play.set(vk_space, MOD_KEY.shift);
							     hotkey_resume.set(vk_space, MOD_KEY.none);  break;
					}
					PREF_SAVE();
				}),
					
			function() /*=>*/ {
				if(hotkey_play.getKeyName()   == "Space") return 0;
				if(hotkey_resume.getKeyName() == "Space") return 1;
				return 2;
			},
		),
		
	];
	
	setHeight();
	
	static onDraw = function() {
		prop_anim_length.active = !GLOBAL_IS_PLAYING;
	}
	
}