#region anomation class
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
				if(playback == ANIMATOR_END.stop || rendering) {
					is_playing = false;
					rendering = false;
				} else
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
			var _key = ds_map_find_first(NODE_MAP);
			var amo = ds_map_size(NODE_MAP);
		
			repeat(amo) {
				var _node = NODE_MAP[? _key];
				_node.resetAnimation();
				_key = ds_map_find_next(NODE_MAP, _key);	
			}
		}
		
		static render = function() {
			setFrame(-1);
			is_playing = true;
			rendering  = true;
			frame_progress = true;
		}
		
		static pause = function() {
			ANIMATOR.is_playing = false;
			ANIMATOR.frame_progress = true;
		}
		
		static resume = function() {
			ANIMATOR.is_playing = true;
			ANIMATOR.frame_progress = true;
		}
		
		static stop = function() {
			is_playing = false;
			setFrame(0);
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