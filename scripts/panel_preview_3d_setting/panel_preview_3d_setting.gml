function Panel_Preview_3D_Setting() : Panel_Linear_Setting() constructor {
	title   = __txtx("preview_3d_settings", "3D Preview Settings");
	preview = PANEL_PREVIEW;
	scene   = PANEL_PREVIEW.d3_scene;
	
	properties_default = [
		["Wireframe", false],
		new __Panel_Linear_Setting_Item( __txt("Wireframe"),
			new checkBox(function() /*=>*/ { scene.show_wireframe = !scene.show_wireframe; }),
			function(   ) /*=>*/   {return scene.show_wireframe},
			function(val) /*=>*/ { scene.show_wireframe = val; },
			false,
		),
		new __Panel_Linear_Setting_Item( __txt("Wireframe Thickness"),
			textBox_Number(function(v) /*=>*/ { scene.wireframe_width = v; }),
			function(   ) /*=>*/   {return scene.wireframe_width},
			function(val) /*=>*/ { scene.wireframe_width = val; },
			1,
		),
		new __Panel_Linear_Setting_Item( __txt("Wireframe Color"),
			new buttonColor(function(c) /*=>*/ { scene.wireframe_color = c; }),
			function(   ) /*=>*/   {return scene.wireframe_color},
			function(val) /*=>*/ { scene.wireframe_color = val; },
			cola(c_black, 1),
		),
		
		["Passes", false],
		new __Panel_Linear_Setting_Item( __txt("Preview Pass"),
			new scrollBox([ "Rendered", "Normal", "Depth" ], function(index) /*=>*/ { preview.d3_preview_channel = index; }),
			function(   ) /*=>*/   {return preview.d3_preview_channel},
			function(val) /*=>*/ { preview.d3_preview_channel = val; },
			0,
		),
		
		["Lighting", false],
		new __Panel_Linear_Setting_Item( __txt("Preview Light"),
			new checkBox(function() /*=>*/ { preview.d3_scene_light_enabled = !preview.d3_scene_light_enabled; }),
			function(   ) /*=>*/   {return preview.d3_scene_light_enabled},
			function(val) /*=>*/ { preview.d3_scene_light_enabled = val; },
			true,
		),
		new __Panel_Linear_Setting_Item( __txt("Light Direction"),
			new rotator(function(val) /*=>*/ { 
				preview.d3_scene_light0_ha = val;
	            preview.d3_scene_light0.transform.setPolar(preview.d3_scene_light0_ha, preview.d3_scene_light0_va, 4);
	            
	            preview.d3_scene_light1_ha = val + 180;
	            preview.d3_scene_light1.transform.setPolar(preview.d3_scene_light1_ha, preview.d3_scene_light1_va, 4);
			}),
			function(   ) /*=>*/ {return preview.d3_scene_light0_ha},
			function(val) /*=>*/ { 
				preview.d3_scene_light0_ha = val;
	            preview.d3_scene_light0.transform.setPolar(preview.d3_scene_light0_ha, preview.d3_scene_light0_va, 4);
	            
	            preview.d3_scene_light1_ha = val + 180;
	            preview.d3_scene_light1.transform.setPolar(preview.d3_scene_light1_ha, preview.d3_scene_light1_va, 4);
			},
			45,
		),
		new __Panel_Linear_Setting_Item( __txt("Ambient Color"),
			new buttonColor(function(col) /*=>*/ { scene.lightAmbient = col; }).hideAlpha(),
			function(   ) /*=>*/   {return scene.lightAmbient},
			function(val) /*=>*/ { scene.lightAmbient = val; },
			$404040,
		),
		new __Panel_Linear_Setting_Item( __txt("Light Intensity"),
			slider(0, 1, 0.01, function(val) /*=>*/ { 
				preview.d3_scene_light0.intensity = val; 
				preview.d3_scene_light1.intensity = val; 
			}),
			function(   ) /*=>*/   {return preview.d3_scene_light0.intensity},
			function(val) /*=>*/ { preview.d3_scene_light0.intensity = val; },
			1,
		),
		
		["Render", false],
		new __Panel_Linear_Setting_Item( __txt("Shader"),
			new scrollBox([ "Phong", "PBR" ], function(val) /*=>*/ { scene.shader = val; }),
			function(   ) /*=>*/   {return scene.shader},
			function(val) /*=>*/ { scene.shader = val; },
			0,
		),
		new __Panel_Linear_Setting_Item( __txt("Shadow"),
			new checkBox(function() /*=>*/ { preview.d3_scene_light0.shadow_active = !preview.d3_scene_light0.shadow_active; }),
			function(   ) /*=>*/   {return preview.d3_scene_light0.shadow_active},
			function(val) /*=>*/ { preview.d3_scene_light0.shadow_active = val; },
			false,
		),
		new __Panel_Linear_Setting_Item( __txt("View Plane"),
			new vectorBox(2, function(value, index) /*=>*/ { 
				if(index == 0)		preview.d3_camera.view_near = value;
				else if(index == 1) preview.d3_camera.view_far = value;
			}),
			function(   ) /*=>*/ {return [ preview.d3_camera.view_near, preview.d3_camera.view_far ]},
			function(val) /*=>*/ { preview.d3_camera.view_near = val[0]; preview.d3_camera.view_far = val[1] },
			[ 0.01, 50 ],
		),
		new __Panel_Linear_Setting_Item( __txt("Face Culling"),
			new scrollBox([ "None", "CW", "CCW" ], function(val) /*=>*/ { scene.cull_mode = val; }),
			function(   ) /*=>*/   {return scene.cull_mode},
			function(val) /*=>*/ { scene.cull_mode = val; },
			2,
		),
		new __Panel_Linear_Setting_Item( __txt("Gamma Correct"),
			new checkBox(function() /*=>*/ { scene.gammaCorrection = !scene.gammaCorrection; }),
			function(   ) /*=>*/   {return scene.gammaCorrection},
			function(val) /*=>*/ { scene.gammaCorrection = val; },
			true,
		),
		
		new __Panel_Linear_Setting_Item( __txt("Normal"),
			new checkBox(function() /*=>*/ { scene.show_normal = !scene.show_normal; }),
			function(   ) /*=>*/   {return scene.show_normal},
			function(val) /*=>*/ { scene.show_normal = val; },
			false,
		),
	]
	
	properties_camera = array_append([
		new __Panel_Linear_Setting_Label( "Currently using camera node settings", THEME.noti_icon_warning, 1, COLORS._main_accent ),
	], properties_default);
	
	properties = preview.d3_scene_preview == scene? properties_default : properties_camera;
	
	setHeight();
}