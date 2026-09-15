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
			PREFERENCES.project_animationDisplay.view_context,
			noone,
			"project_animationDisplay.view_context"
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Show Node Name"),
			new checkBox(function() /*=>*/ { animDis.show_nodes = !animDis.show_nodes; }),
			function( ) /*=>*/   {return animDis.show_nodes},
			function(v) /*=>*/ { animDis.show_nodes = v; },
			PREFERENCES.project_animationDisplay.show_nodes,
			noone,
			"project_animationDisplay.show_nodes"
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
			PREFERENCES.project_animationDisplay.node_name_type,
			noone,
			"project_animationDisplay.node_name_type"
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Active Region"),
			new checkBox(function() /*=>*/ { animDis.active_region = !animDis.active_region; }),
			function( ) /*=>*/   {return animDis.active_region},
			function(v) /*=>*/ { animDis.active_region = v; },
			PREFERENCES.project_animationDisplay.active_region,
			noone,
			"project_animationDisplay.active_region"
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Keyframe Scale"),
			slider(0, 1, .01, function(v) /*=>*/ { animDis.keyframe_draw_scale = v; }),
			function( ) /*=>*/   {return animDis.keyframe_draw_scale},
			function(v) /*=>*/ { animDis.keyframe_draw_scale = v; },
			PREFERENCES.project_animationDisplay.keyframe_draw_scale,
			noone,
			"project_animationDisplay.keyframe_draw_scale"
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Ease Line Scale"),
			textBox_Number(function(v) /*=>*/ { animDis.ease_draw_scale = v; }), 
			function( ) /*=>*/   {return animDis.ease_draw_scale},
			function(v) /*=>*/ { animDis.ease_draw_scale = v; },
			PREFERENCES.project_animationDisplay.ease_draw_scale,
			noone,
			"project_animationDisplay.ease_draw_scale"
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Status Line"),
			new checkBox(function() /*=>*/ { animDis.stat_line = !animDis.stat_line; }),
			function( ) /*=>*/   {return animDis.stat_line},
			function(v) /*=>*/ { animDis.stat_line = v; },
			PREFERENCES.project_animationDisplay.stat_line,
			noone,
			"project_animationDisplay.stat_line"
		),
		
	];
	
	setHeight();
	
	static onDraw = function() {
		
	}
	
}