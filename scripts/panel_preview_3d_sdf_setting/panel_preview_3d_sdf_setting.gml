function Panel_Preview_3D_SDF_Setting(panel) : Panel_Linear_Setting() constructor {
	title = __txtx("preview_3d_settings", "3D SDF Preview Settings");
	
	w = ui(380);
	preview_panel = panel;
	
	properties_default = [
		new __Panel_Linear_Setting_Item(
			__txt("View Plane"),
			new vectorBox(2, function(value, index) /*=>*/ { 
				if(index == 0)		preview_panel.d3_view_camera.view_near = value;
				else if(index == 1) preview_panel.d3_view_camera.view_far = value;
			}),
			function(   ) /*=>*/ {return [ preview_panel.d3_view_camera.view_near, preview_panel.d3_view_camera.view_far ]},
			function(val) /*=>*/ { preview_panel.d3_view_camera.view_near = val[0]; preview_panel.d3_view_camera.view_far = val[1] },
			[ 0.01, 50 ],
		),
		new __Panel_Linear_Setting_Item(
			__txt("Draw BG"),
			new checkBox(function() /*=>*/ { preview_panel.d3_drawBG = !preview_panel.d3_drawBG; }),
			function(   ) /*=>*/   {return preview_panel.d3_drawBG},
			function(val) /*=>*/ { preview_panel.d3_drawBG = val; },
			false,
		),
	]
	
	properties = properties_default;
	setHeight();
}