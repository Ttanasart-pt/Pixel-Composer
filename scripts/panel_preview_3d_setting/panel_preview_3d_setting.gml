function Panel_Preview_3D_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_3d_settings", "3D Preview Settings");
	
	w = ui(380);
	preview_panel = panel;
	
	#region data
		properties_default = [
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
			[
				new vectorBox(2, function(index, value) { 
					if(index == 0)		preview_panel.d3_view_camera.view_near = value;
					else if(index == 1) preview_panel.d3_view_camera.view_far = value;
				}),
				__txt("View Plane"),
				function() { return [ preview_panel.d3_view_camera.view_near, preview_panel.d3_view_camera.view_far ] },
			],
			[
				new checkBox(function() { 
					preview_panel.d3_scene.gammaCorrection = !preview_panel.d3_scene.gammaCorrection; }),
				__txt("Gamma Correct"),
				function() { return preview_panel.d3_scene.gammaCorrection },
			],
			[
				new checkBox(function() { 
					preview_panel.d3_scene.show_normal = !preview_panel.d3_scene.show_normal; }),
				__txt("Normal"),
				function() { return preview_panel.d3_scene.show_normal },
			],
		]
		
		var scene_camera = [
			[ "Currently using camera node settings", THEME.noti_icon_warning, 1, COLORS._main_accent ],
		];
		
		properties_camera = array_append(scene_camera, properties_default);
		properties = preview_panel.d3_scene_preview == preview_panel.d3_scene? properties_default : properties_camera;
		
		setHeight();
	#endregion
	
	function drawContent(panel) { 
		drawSettings(panel); 
	}
}