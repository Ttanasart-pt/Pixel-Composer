#region global
	global.FLAG.keyframe_override = true;
	
	enum ANIMATOR_END {
		loop,
		stop
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
		frames_total	= 30;
		current_frame	= 0;
		real_frame		= 0;
		time_since_last_frame = 0;
		
		framerate		= 30;
		is_playing		= false;
		is_rendering	= false;
		frame_progress	= false;
		frame_range		= noone;
		
		is_simulating   = false;
		
		__debug_animator_counter = 0;
		
		playback  = ANIMATOR_END.loop;
		
		static setFrame = function(frame) { #region
			var _c        = current_frame;
			frame         = clamp(frame, 0, frames_total);
			real_frame    = frame;
			current_frame = round(frame);
			
			frame_progress = _c != current_frame;
			
			if(frame_progress) {
				time_since_last_frame = 0;
				RENDER_ALL
			}
		} #endregion
		
		static getFirstFrame = function(range = true) { INLINE return range && frame_range != noone? frame_range[0] - 1 : 0; }
		static getLastFrame  = function(range = true) { INLINE return range && frame_range != noone? frame_range[1] - 1 : frames_total - 1; }
		
		static firstFrame = function(range = true) { INLINE setFrame(getFirstFrame(range)); }
		static lastFrame  = function(range = true) { INLINE setFrame(getLastFrame(range));  }
		
		static isFirstFrame = function() { INLINE return current_frame == getFirstFrame(); }
		static isLastFrame  = function() { INLINE return current_frame == getLastFrame();  }
		
		static resetAnimation = function() { #region
			INLINE
			
			var _key = ds_map_find_first(PROJECT.nodeMap);
			var amo = ds_map_size(PROJECT.nodeMap);
		
			repeat(amo) {
				var _node = PROJECT.nodeMap[? _key];
				_node.resetAnimation();
				_key = ds_map_find_next(PROJECT.nodeMap, _key);	
			}
		} #endregion
		
		static toggle = function() { #region
			INLINE
			
			is_playing			  = !is_playing;
			frame_progress		  = true;
			time_since_last_frame = 0;
		} #endregion
		
		static pause = function() { #region
			INLINE
			
			is_playing			  = false;
			frame_progress		  = true;
			time_since_last_frame = 0;
		} #endregion
		
		static play = function() { #region
			INLINE
			
			if(is_simulating)	setFrame(0);
			else				firstFrame();
			
			is_playing			  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
		} #endregion
		
		static render = function() { #region
			INLINE
			
			if(is_simulating)	setFrame(0);
			else				firstFrame();
			
			is_playing			  = true;
			is_rendering		  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
		} #endregion
		
		static resume = function() { #region
			INLINE
			
			is_playing			  = true;
			frame_progress		  = true;
			time_since_last_frame = 0;
		} #endregion
		
		static stop = function() { #region
			INLINE
			
			firstFrame();
			
			is_playing			  = false;
			time_since_last_frame = 0;
		} #endregion
		
		static step = function() { #region
			INLINE
			
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
			var tslf = time_since_last_frame;
				
			if(time_since_last_frame >= _frTime) {
				var dt = time_since_last_frame - _frTime;
				setFrame(real_frame + 1);
				time_since_last_frame = dt;
				
				var _maxFrame = frame_range != noone? frame_range[1] : frames_total;
				if(current_frame >= _maxFrame) {
					firstFrame();
					
					if(playback == ANIMATOR_END.stop || is_rendering) {
						is_playing   = false;
						is_rendering = false;
						time_since_last_frame = 0;
						
						if(PROGRAM_ARGUMENTS._cmd && !PROGRAM_ARGUMENTS._persist) game_end();
					} 
				}
			
			}
		} #endregion
	}
#endregion