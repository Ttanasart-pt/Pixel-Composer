function Panel_Animation_View_Setting() : Panel_Linear_Setting() constructor {
	title = __txt("animation_view_settings", "Animation View Settings");
	w = ui(380);
	
	project = PROJECT;
	animDis = PROJECT.animationDisplay;
	
	properties = [
		
		new __Panel_Linear_Setting_Item(
			__txt("View Context"),
			new scrollBox( [
	            __txt("All"),
	            __txt("Current and Children"),
	            __txt("Current Only"),
	            __txt("Selection Only"),
	        ], function(i) /*=>*/ { animDis.view_context = i; }),
			function( ) /*=>*/   {return animDis.view_context},
			function(v) /*=>*/ { animDis.view_context = v; },
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Show Node Name"),
			new checkBox(function() /*=>*/ { animDis.show_nodes = !animDis.show_nodes; }),
			function( ) /*=>*/   {return animDis.show_nodes},
			function(v) /*=>*/ { animDis.show_nodes = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Name Display Type"),
			new scrollBox( [
	            __txt("panel_animation_name_full", "Full name"),
	            __txt("panel_animation_name_type", "Node type"),
	            __txt("panel_animation_name_only", "Node name"),
	        ], function(i) /*=>*/ { animDis.node_name_type = i; }),
			function( ) /*=>*/   {return animDis.node_name_type},
			function(v) /*=>*/ { animDis.node_name_type = v; },
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Keyframe Scale"),
			slider(0, 1, .01, function(v) /*=>*/ { animDis.keyframe_draw_scale = v; }),
			function( ) /*=>*/   {return animDis.keyframe_draw_scale},
			function(v) /*=>*/ { animDis.keyframe_draw_scale = v; },
		),
		
	];
	
	setHeight();
	
	static onDraw = function() {
		
	}
	
}