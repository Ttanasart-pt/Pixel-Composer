function Panel_Animation_Scaler() : Panel_Linear_Setting() constructor {
	title = __txtx("anim_scale_title", "Animation scaler");
	
	w = ui(380);
	scale_to = PROJECT.animator.frames_total;
	
	#region data
		properties = [
			[
				new textBox(TEXTBOX_INPUT.number, function(to) {
					to = toNumber(to);
					scale_to = to;
				}), 
				__txtx("anim_scale_target_frame_length", "Target frame length"),
				function() { return scale_to; },
			]
		];
		
		setHeight();
		h += ui(36);
		
		b_apply = button(function() { scale(); })
					.setIcon(THEME.accept_16, 0, COLORS._main_icon_dark);
	#endregion
	
	static scale = function() {
		var fac = scale_to / PROJECT.animator.frames_total;
		var key = ds_map_find_first(PROJECT.nodeMap);
		repeat(ds_map_size(PROJECT.nodeMap)) {
			var _node = PROJECT.nodeMap[? key];
			key = ds_map_find_next(PROJECT.nodeMap, key);
			if(!_node || !_node.active) continue;
			
			for(var i = 0; i < ds_list_size(_node.inputs); i++) {
				var in = _node.inputs[| i];
				if(!in.is_anim) continue;
				for(var j = 0; j < ds_list_size(in.animator.values); j++) {
					var t = in.animator.values[| j];
					t.time = t.ratio * scale_to;
				}
			}
		}
		PROJECT.animator.frames_total = scale_to;
		close();
	}
	
	function drawContent(panel) { 
		drawSettings(panel); 
		
		var bs = ui(28);
		var bx = w - ui(8) - bs;
		var by = h - ui(8) - bs;
		
		b_apply.setFocusHover(pFOCUS, pHOVER);
		b_apply.register();
		b_apply.draw(bx, by, bs, bs, [ mx, my ], THEME.button_lime);
	}
}