/// @description init
event_inherited();

#region data
	dialog_w = ui(368);
	dialog_h = ui(120);
	destroy_on_click_out = true;
#endregion

#region scaler
	scale_to = ANIMATOR.frames_total;
	tb_scale_frame = new textBox(TEXTBOX_INPUT.number, function(to) {
		to = toNumber(to);
		scale_to = to;
	});
	
	b_apply = button(function() {
		var fac = scale_to / ANIMATOR.frames_total;
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			var n = NODE_MAP[? key];
			key = ds_map_find_next(NODE_MAP, key);
			if(!n || !n.active) continue;
			
			for(var i = 0; i < ds_list_size(n.inputs); i++) {
				var in = n.inputs[| i];
				if(!in.is_anim) continue;
				for(var j = 0; j < ds_list_size(in.animator.values); j++) {
					var t = in.animator.values[| j];
					t.time = t.ratio * scale_to;
				}
			}
		}
		ANIMATOR.frames_total = scale_to;
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
#endregion