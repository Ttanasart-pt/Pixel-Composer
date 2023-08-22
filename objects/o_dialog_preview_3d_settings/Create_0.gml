/// @description init
event_inherited();

#region data
	dialog_w = ui(320);
	
	destroy_on_click_out = true;
	preview_panel = noone;
#endregion

#region data
	properties = [
		[
			new checkBox(function() { preview_panel.d3_scene_light_enabled = !preview_panel.d3_scene_light_enabled; }),
			__txt("Preview Light"),
			function() { return preview_panel.d3_scene_light_enabled },
		],
		[
			new buttonColor(function(col) { 
				preview_panel.d3_scene.lightAmbient = col; }),
			__txt("Ambient Color"),
			function() { return preview_panel.d3_scene.lightAmbient },
		],
		[
			new slider(0, 1, 0.01, function(val) { 
				preview_panel.d3_scene_light0.intensity = val; 
				preview_panel.d3_scene_light1.intensity = val; 
			}),
			__txt("Light Intensity"),
			function() { return preview_panel.d3_scene_light0.intensity },
		],
		[
			new checkBox(function() { 
				preview_panel.d3_scene_light0.shadow_active = !preview_panel.d3_scene_light0.shadow_active; }),
			__txt("Shadow"),
			function() { return preview_panel.d3_scene_light0.shadow_active },
		],
	]
	
	dialog_h = ui(60 + 40 * array_length(properties));
#endregion