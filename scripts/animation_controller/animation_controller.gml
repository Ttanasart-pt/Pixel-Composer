#region global
	enum ANIMATOR_END {
		loop,
		stop,
		pingpong,
	}
	
	#macro GLOBAL_IS_PLAYING     PROJECT.animator.is_playing
	#macro GLOBAL_IS_RENDERING   PROJECT.animator.is_rendering
	#macro GLOBAL_CURRENT_FRAME  PROJECT.animator.current_frame
	
	#macro GLOBAL_TOTAL_FRAMES       PROJECT.animator.frames_total
	#macro GLOBAL_FRAME_RANGE_START  PROJECT.animator.frame_range_start
	#macro GLOBAL_FRAME_RANGE_END    PROJECT.animator.frame_range_end
	
	#macro GLOBAL_FIRST_FRAME    PROJECT.animator.getFirstFrame()
	#macro GLOBAL_LAST_FRAME     PROJECT.animator.getLastFrame()
	
	#macro GLOBAL_IS_FIRST_FRAME PROJECT.animator.isFirstFrame()
	#macro GLOBAL_IS_LAST_FRAME  PROJECT.animator.isLastFrame()
	
	#macro NODE_CURRENT_FRAME    node.project.animator.current_frame
	#macro NODE_TOTAL_FRAMES     node.project.animator.frames_total
	
	#macro IS_PLAYING            project.animator.is_playing
	#macro IS_FRAME_PROGRESS     project.animator.frame_progress
	#macro IS_RENDERING          project.animator.is_rendering
	#macro CURRENT_FRAME         project.animator.current_frame
	
	#macro TOTAL_FRAMES          project.animator.frames_total
	
	#macro FIRST_FRAME           project.animator.getFirstFrame()
	#macro LAST_FRAME            project.animator.getLastFrame()
	
	#macro IS_FIRST_FRAME        project.animator.isFirstFrame()
	#macro IS_LAST_FRAME         project.animator.isLastFrame()
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
		
		frame_range_start = undefined;
		frame_range_end   = undefined;
		
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
		
		static getFirstFrame = function(r=true) /*=>*/ {return r && frame_range_start? frame_range_start - 1 : 0};
		static getLastFrame  = function(r=true) /*=>*/ {return r && frame_range_end?   frame_range_end   - 1 : frames_total - 1};
		
		static firstFrame    = function(r=true) /*=>*/ {return setFrame(getFirstFrame(r))};
		static lastFrame     = function(r=true) /*=>*/ {return setFrame(getLastFrame(r))};
		
		static isFirstFrame  = function() /*=>*/ {return current_frame == getFirstFrame()};
		static isLastFrame   = function() /*=>*/ {return current_frame == getLastFrame()};
		
		static animationStart = function() /*=>*/ {return array_foreach(PROJECT.allNodes, function(n) /*=>*/ {return n.onAnimationStart()})};
		
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
			
			animationStart();
			is_playing			  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
			play_direction        = 1;
			
			RENDER_ALL
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
			if(frame_range_start || frame_range_end) {
				var fr0 = frame_range_start ?? 0;
				var fr1 = frame_range_end   ?? frames_total;
				
				if(fr0 == fr1) {
					frame_range_start = undefined;
					frame_range_end   = undefined;
					
				} else {
					frame_range_start = max(min(fr0, fr1), 0);
					frame_range_end   = min(max(fr0, fr1), frames_total);
				}
			}
			
			if(!is_playing) return;
			
			var _frTime = 1 / framerate;
			time_since_last_frame += delta_time / 1_000_000;
				
			if(time_since_last_frame < _frTime) return;
			
			var dt = time_since_last_frame - _frTime;
			setFrame(real_frame + play_direction);
			time_since_last_frame = dt;
			
			var _maxFrame = frame_range_end ?? frames_total;
			
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