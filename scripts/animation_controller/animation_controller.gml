#region global
	global.FLAG.keyframe_override = true;
	
	enum ANIMATOR_END {
		loop,
		stop
	}
	
	#macro ANIMATION_STATIC !(PROJECT.animator.is_playing || PROJECT.animator.frame_progress)
	#macro IS_PLAYING    PROJECT.animator.is_playing
	#macro CURRENT_FRAME PROJECT.animator.current_frame
	#macro TOTAL_FRAMES  PROJECT.animator.frames_total
	#macro RENDERING     PROJECT.animator.rendering
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
		play_freeze		= 0;
		
		rendering = [];
		playback  = ANIMATOR_END.loop;
		
		static setFrame = function(frame, resetTime = true) {
			//if(frame == 0) resetAnimation();
			
			var _c = current_frame;
			frame = clamp(frame, 0, frames_total);
			real_frame = frame;
			current_frame = round(frame);
			
			if(current_frame == frames_total) {
				if(array_length(rendering)) {
					is_playing = false;
					setFrame(0);
				} else if(playback == ANIMATOR_END.stop)
					is_playing = false;
				else
					setFrame(0);
			}
			
			if(_c != current_frame) {
				frame_progress = true;
				if(resetTime)
					time_since_last_frame = 0;
				RENDER_ALL
			} else 
				frame_progress = false;
		}
		
		static resetAnimation = function() {
			var _key = ds_map_find_first(PROJECT.nodeMap);
			var amo = ds_map_size(PROJECT.nodeMap);
		
			repeat(amo) {
				var _node = PROJECT.nodeMap[? _key];
				_node.resetAnimation();
				_key = ds_map_find_next(PROJECT.nodeMap, _key);	
			}
		}
		
		static render = function() {
			setFrame(0);
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		}
		
		static toggle = function() {
			is_playing = !is_playing;
			frame_progress = true;
			time_since_last_frame = 0;
		}
		
		static pause = function() {
			is_playing = false;
			frame_progress = true;
			time_since_last_frame = 0;
		}
		
		static play = function() {
			setFrame(0);
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		}
		
		static resume = function() {
			is_playing = true;
			frame_progress = true;
			time_since_last_frame = 0;
		}
		
		static stop = function() {
			setFrame(0);
			is_playing = false;
			time_since_last_frame = 0;
		}
		
		static step = function() {
			if(is_playing && play_freeze == 0) {
				time_since_last_frame += framerate * (delta_time / 1000000);
				
				if(time_since_last_frame >= 1) {
					setFrame(real_frame + 1, false);
					time_since_last_frame -= 1;
				}
			} else {
				frame_progress = false;
				//setFrame(real_frame);
				time_since_last_frame = 0;
			}
	
			play_freeze = max(0, play_freeze - 1);
		}
	}
#endregion