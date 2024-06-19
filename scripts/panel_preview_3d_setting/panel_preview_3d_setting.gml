function Panel_Preview_3D_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_3d_settings", "3D Preview Settings");
	
	w = ui(380);
	preview_panel = panel;
	
	#region data
		properties_default = [
			new __Panel_Linear_Setting_Item(
				__txt("Preview Light"),
				new checkBox(function() { preview_panel.d3_scene_light_enabled = !preview_panel.d3_scene_light_enabled; }),
				function() { return preview_panel.d3_scene_light_enabled },
				function(val) { preview_panel.d3_scene_light_enabled = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Ambient Color"),
				new buttonColor(function(col) { preview_panel.d3_scene.lightAmbient = col; }),
				function() { return preview_panel.d3_scene.lightAmbient },
				function(val) { preview_panel.d3_scene.lightAmbient = val; },
				$404040,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Light Intensity"),
				slider(0, 1, 0.01, function(val) { 
					preview_panel.d3_scene_light0.intensity = val; 
					preview_panel.d3_scene_light1.intensity = val; 
				}),
				function() { return preview_panel.d3_scene_light0.intensity },
				function(val) { preview_panel.d3_scene_light0.intensity = val; },
				1,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Shadow"),
				new checkBox(function() { preview_panel.d3_scene_light0.shadow_active = !preview_panel.d3_scene_light0.shadow_active; }),
				function() { return preview_panel.d3_scene_light0.shadow_active },
				function(val) { preview_panel.d3_scene_light0.shadow_active = val; },
				false,
			),
			new __Panel_Linear_Setting_Item(
				__txt("View Plane"),
				new vectorBox(2, function(value, index) { 
					if(index == 0)		preview_panel.d3_view_camera.view_near = value;
					else if(index == 1) preview_panel.d3_view_camera.view_far = value;
				}),
				function() { return [ preview_panel.d3_view_camera.view_near, preview_panel.d3_view_camera.view_far ] },
				function(val) { preview_panel.d3_view_camera.view_near = val[0]; preview_panel.d3_view_camera.view_far = val[1] },
				[ 0.01, 50 ],
			),
			new __Panel_Linear_Setting_Item(
				__txt("Gamma Correct"),
				new checkBox(function() { preview_panel.d3_scene.gammaCorrection = !preview_panel.d3_scene.gammaCorrection; }),
				function() { return preview_panel.d3_scene.gammaCorrection },
				function(val) { preview_panel.d3_scene.gammaCorrection = val; },
				true,
			),
			new __Panel_Linear_Setting_Item(
				__txt("Normal"),
				new checkBox(function() { preview_panel.d3_scene.show_normal = !preview_panel.d3_scene.show_normal; }),
				function() { return preview_panel.d3_scene.show_normal },
				function(val) { preview_panel.d3_scene.show_normal = val; },
				false,
			),
		]
		
		var scene_camera = [
			new __Panel_Linear_Setting_Label( "Currently using camera node settings", THEME.noti_icon_warning, 1, COLORS._main_accent ),
		];
		
		properties_camera = array_append(scene_camera, properties_default);
		properties = preview_panel.d3_scene_preview == preview_panel.d3_scene? properties_default : properties_camera;
		
		setHeight();
	#endregion
	
	function drawContent(panel) { 
		drawSettings(panel); 
	}
}