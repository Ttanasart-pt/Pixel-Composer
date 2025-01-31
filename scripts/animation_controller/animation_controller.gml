#region global
	enum ANIMATOR_END {
		loop,
		stop,
		pingpong,
	}
	
	#macro ANIMATION_STATIC !(PROJECT.animator.is_playing || PROJECT.animator.frame_progress)
	#macro IS_PLAYING    PROJECT.animator.is_playing
	#macro IS_RENDERING  PROJECT.animator.is_rendering
	#macro CURRENT_FRAME PROJECT.animator.current_frame
	
	#macro TOTAL_FRAMES  PROJECT.animator.frames_total
	#macro FRAME_RANGE   PROJECT.animator.frame_range
	
	#macro FIRST_FRAME   PROJECT.animator.getFirstFrame()
	#macro LAST_FRAME    PROJECT.animator.getLastFrame()
	
	#macro IS_FIRST_FRAME PROJECT.animator.isFirstFrame()
	#macro IS_LAST_FRAME  PROJECT.animator.isLastFrame()
#endregion

#region animation class
	function AnimationManager() constructor {
		frames_total	= PREFERENCES.project_animation_duration;
		current_frame	= 0;
		real_frame		= 0;
		time_since_last_frame = 0;
		
		framerate		= PREFERENCES.project_animation_framerate;
		is_playing		= false;
		is_rendering	= false;
		frame_progress	= false;
		frame_range		= noone;
		
		play_direction  = 1;
		is_simulating   = false;
		
		__debug_animator_counter = 0;
		
		playback  = ANIMATOR_END.loop;
		
		static setFrame = function(_frame, _round = true) {
			var _c        = current_frame;
			// _frame        = clamp(_frame, 0, frames_total);
			real_frame    = _frame;
			current_frame = _round? round(_frame) : _frame;
			
			frame_progress = _c != current_frame;
			
			if(frame_progress) {
				time_since_last_frame = 0;
				RENDER_ALL
			}
		}
		
		static getFirstFrame = function(range = true) { return range && frame_range != noone? frame_range[0] - 1 : 0; }
		static getLastFrame  = function(range = true) { return range && frame_range != noone? frame_range[1] - 1 : frames_total - 1; }
		
		static firstFrame = function(range = true) { setFrame(getFirstFrame(range)); }
		static lastFrame  = function(range = true) { setFrame(getLastFrame(range));  }
		
		static isFirstFrame = function() { return current_frame == getFirstFrame(); }
		static isLastFrame  = function() { return current_frame == getLastFrame();  }
		
		static resetAnimation = function() {
			array_foreach(PROJECT.allNodes, function(node) { node.resetAnimation(); });
		}
		
		static toggle = function() {
			is_playing			  = !is_playing;
			frame_progress		  = true;
			time_since_last_frame = 0;
		}
		
		static pause = function() {
			is_playing			  = false;
			frame_progress		  = true;
			time_since_last_frame = 0;
		}
		
		static play = function() {
			if(is_simulating)	setFrame(0);
			else				firstFrame();
			
			is_playing			  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
			play_direction        = 1;
		}
		
		static render = function() {
			if(is_simulating)	setFrame(0);
			else				firstFrame();
			
			is_playing			  = true;
			is_rendering		  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
		}
		
		static resume = function() {
			is_playing			  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
		}
		
		static stop = function() {
			firstFrame();
			
			is_playing			  = false;
			time_since_last_frame = 0;
		}
		
		static step = function() {
			if(frame_range != noone) {
				var _fr0 = min(frame_range[0], frame_range[1]);
				var _fr1 = max(frame_range[0], frame_range[1]);
				
				if(_fr0 == _fr1) {
					frame_range = noone;
				} else {
					frame_range[0] = max(_fr0, 0);
					frame_range[1] = min(_fr1, frames_total);
				}
			}
			
			if(!is_playing) return;
			
			var _frTime = 1 / framerate;
			time_since_last_frame += delta_time / 1_000_000;
				
			if(time_since_last_frame < _frTime) return;
			
			var dt = time_since_last_frame - _frTime;
			setFrame(real_frame + play_direction);
			time_since_last_frame = dt;
			
			var _maxFrame = frame_range != noone? frame_range[1] : frames_total;
			
			if(current_frame >= _maxFrame) {
				firstFrame();
				
				if(playback == ANIMATOR_END.stop || is_rendering) {
					is_playing   = false;
					is_rendering = false;
					time_since_last_frame = 0;
					
				} else if(playback == ANIMATOR_END.pingpong) {
					setFrame(max(0, frames_total - 2));
					play_direction = -1;
				}
				
			} else if(current_frame <= 0) {
				if(playback == ANIMATOR_END.pingpong)
					play_direction = 1;
			}
		}
	}
#endregion