function Panel_Preview_3D_SDF_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_3d_settings", "3D SDF Preview Settings");
	preview = PANEL_PREVIEW;
	scene   = PANEL_PREVIEW.d3_scene;
	
	properties_default = [
		new __Panel_Linear_Setting_Item(
			__txt("View Plane"),
			new vectorBox(2, function(value, index) /*=>*/ { 
				if(index == 0)		preview.d3_camera.view_near = value;
				else if(index == 1) preview.d3_camera.view_far = value;
			}),
			function()    /*=>*/ {return [ preview.d3_camera.view_near, preview.d3_camera.view_far ]},
			function(val) /*=>*/ { preview.d3_camera.view_near = val[0]; preview.d3_camera.view_far = val[1] },
			[ 0.01, 50 ],
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Draw BG"),
			new checkBox(function() /*=>*/ { preview.d3_drawBG = !preview.d3_drawBG; }),
			function()    /*=>*/   {return preview.d3_drawBG},
			function(val) /*=>*/ { preview.d3_drawBG = val; },
			false,
		),
	]
	
	properties = properties_default;
	setHeight();
}