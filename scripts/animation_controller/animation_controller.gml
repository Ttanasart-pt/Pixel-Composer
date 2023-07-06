#region global
	global.FLAG.keyframe_override = true;
	
	enum ANIMATOR_END {
		loop,
		stop
	}
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
		
		rendering = false;
		playback = ANIMATOR_END.loop;
		
		static setFrame = function(frame) {
			//if(frame == 0) resetAnimation();
			
			var _c = current_frame;
			frame = clamp(frame, 0, frames_total);
			real_frame = frame;
			current_frame = round(frame);
			
			if(current_frame == frames_total) {
				if(rendering) {
					is_playing = false;
					rendering = false;
					
					setFrame(0);
				} else if(playback == ANIMATOR_END.stop)
					is_playing = false;
				else
					setFrame(0);
			}
			
			if(_c != current_frame) {
				frame_progress = true;
				time_since_last_frame = 0;
				UPDATE |= RENDER_TYPE.full;
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
			setFrame(-1);
			is_playing = true;
			rendering  = true;
			frame_progress = true;
		}
		
		static toggle = function() {
			is_playing = !is_playing;
			frame_progress = true;
		}
		
		static pause = function() {
			is_playing = false;
			frame_progress = true;
		}
		
		static play = function() {
			is_playing = true;
			frame_progress = true;
		}
		
		static resume = function() {
			is_playing = true;
			frame_progress = true;
		}
		
		static stop = function() {
			is_playing = false;
			setFrame(0);
		}
	}
#endregion