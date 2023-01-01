#region anomation class
	function AnimationManager() constructor {
		frames_total = 30;
		current_frame = 0;
		real_frame = 0;
		time_since_last_frame = 0;
		framerate = 30;
		is_playing = false;
		frame_progress = false;
		
		rendering = false;
		playback = ANIMATOR_END.loop;
		
		static setFrame = function(frame) {
			var _c = current_frame;
			frame = clamp(frame, 0, frames_total - 1);
			real_frame = frame;
			current_frame = round(frame);
			
			if(_c != current_frame)
				frame_progress = true;
		}
	}
#endregion

#region object
	enum ANIMATOR_END {
		loop,
		stop
	}
	
	globalvar ANIMATOR;
	ANIMATOR = new AnimationManager();
#endregion