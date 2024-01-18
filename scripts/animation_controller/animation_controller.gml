#region global
	global.FLAG.keyframe_override = true;
	
	enum ANIMATOR_END {
		loop,
		stop
	}
	
	#macro ANIMATION_STATIC !(PROJECT.animator.is_playing || PROJECT.animator.frame_progress)
	#macro IS_PLAYING    PROJECT.animator.is_playing
	#macro CURRENT_FRAME PROJECT.animator.current_frame
	#macro LAST_FRAME    (CURRENT_FRAME == TOTAL_FRAMES - 1)
	#macro TOTAL_FRAMES  PROJECT.animator.frames_total
	#macro RENDERING     PROJECT.animator.rendering
	#macro FRAME_RANGE   PROJECT.animator.frame_range
	#macro IS_RENDERING  array_length(PROJECT.animator.rendering)
#endregion

#region animation class
	function AnimationManager() constructor {
		frames_total	= 30;
		current_frame	= 0;
		real_frame		= 0;
		time_since_last_frame = 0;
		
		framerate		= 30;
		is_playing		= false;
		frame_progress	= false;
		render_stop     = false;
		
		frame_range		= noone;
		
		__debug_animator_counter = 0;
		
		rendering = [];
		playback  = ANIMATOR_END.loop;
		
		static setFrame = function(frame, resetTime = true) { #region
			var _c        = current_frame;
			frame         = clamp(frame, 0, frames_total);
			real_frame    = frame;
			current_frame = round(frame);
			
			if(current_frame == frames_total) {
				if(render_stop) {
					is_playing = false;
					setFrame(0, resetTime);
					render_stop = false;
				} else if(playback == ANIMATOR_END.stop) {
					is_playing = false;
				} else {
					setFrame(0, resetTime);
				}
			}
			
			if(_c != current_frame) {
				frame_progress = true;
				if(resetTime)
					time_since_last_frame = 0;
				RENDER_ALL
			} else 
				frame_progress = false;
				
			if(array_length(rendering)) render_stop = true;
		} #endregion
		
		static resetAnimation = function() { #region
			var _key = ds_map_find_first(PROJECT.nodeMap);
			var amo = ds_map_size(PROJECT.nodeMap);
		
			repeat(amo) {
				var _node = PROJECT.nodeMap[? _key];
				_node.resetAnimation();
				_key = ds_map_find_next(PROJECT.nodeMap, _key);	
			}
		} #endregion
		
		static render = function() { #region
			setFrame(0);
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		} #endregion
		
		static toggle = function() { #region
			is_playing = !is_playing;
			frame_progress = true;
			time_since_last_frame = 0;
		} #endregion
		
		static pause = function() { #region
			is_playing = false;
			frame_progress = true;
			time_since_last_frame = 0;
		} #endregion
		
		static play = function() { #region
			setFrame(0);
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		} #endregion
		
		static resume = function() { #region
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		} #endregion
		
		static stop = function() { #region
			setFrame(0);
			is_playing = false;
			time_since_last_frame = 0;
		} #endregion
		
		static step = function() { #region
			if(!is_playing) return;
			
			var _frTime = 1 / framerate;
			time_since_last_frame += delta_time / 1_000_000;
			var tslf = time_since_last_frame;
				
			if(time_since_last_frame >= _frTime) {
				setFrame(real_frame + 1, false);
				time_since_last_frame -= _frTime;
					
				//var _t = get_timer();
				//print($"Frame progress {current_frame} delay {(_t - __debug_animator_counter) / 1000}");
				//__debug_animator_counter = _t;
			}
			
			//print($"    > TSLF: {tslf} > {_frTime} > {time_since_last_frame}");
		} #endregion
	}
#endregion