/// @description init
event_inherited();

#region data
	dialog_w = ui(368);
	dialog_h = ui(120);
	destroy_on_click_out = true;
#endregion

#region scaler
	scale_to = PROJECT.animator.frames_total;
	tb_scale_frame = new textBox(TEXTBOX_INPUT.number, function(to) {
		to = toNumber(to);
		scale_to = to;
	});
	
	b_apply = button(function() {
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
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion