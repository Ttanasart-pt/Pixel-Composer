/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = ui(240);
	padding = 8;
	title_height = 32;
	
	destroy_on_click_out = false;
	dialog_resizable = true;
	dialog_w_min = ui(64);
	dialog_h_min = ui(64);
	dialog_w_max = ui(1000);
	dialog_h_max = ui(1000);
	
	node_target = noone;
	preview_channel = 0;
	
	title_show = 0;
	
	scale = 0;
	panx  = 0;
	pany  = 0;
	
	panning = false;
	pan_mx = 0;
	pan_my = 0;
	pan_sx = 0;
	pan_sy = 0;
#endregion

#region data
	function surfaceCheck() {
		content_surface = surface_verify(content_surface, dialog_w - ui(padding + padding), dialog_h - ui(padding + padding));
	}
	
	function reset() {
		scale = 0;
		panx = 0;
		pany = 0;
	}
	function changeChannel(index) {
		var channel = index - array_length(menu);
		for( var i = 0; i < ds_list_size(node_target.outputs); i++ ) {
			var o = node_target.outputs[| i];
			if(o.type != VALUE_TYPE.surface) continue;
			if(channel-- == 0) {
				preview_channel = i;
				return;
			}
		}
	}
	
	content_surface = noone;
	surfaceCheck();
	
	menu = [
		menuItem(__txtx("reset_view", "Reset view"), function() { reset(); }), 
		-1,
		menuItem(__txtx("preview_win_inspect", "Inspect"), function() { PANEL_GRAPH.node_focus = node_target; }), 
		menuItem(__txtx("panel_graph_send_to_preview", "Send to preview"), function() { PANEL_PREVIEW.setNodePreview(node_target); }), 
		-1,
	]
#endregion