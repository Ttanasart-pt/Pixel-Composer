function Panel_Animation_View_Setting() : Panel_Linear_Setting() constructor {
	title = __txt("animation_view_settings", "Animation View Settings");
	w = ui(380);
	
	properties = [
		new __Panel_Linear_Setting_Item(
			__txt("Show Node Name"),
			new checkBox(function() /*=>*/ { PANEL_ANIMATION.show_nodes = !PANEL_ANIMATION.show_nodes; }),
			function( ) /*=>*/   {return PANEL_ANIMATION.show_nodes},
			function(v) /*=>*/ { PANEL_ANIMATION.show_nodes = v; },
		),
		
		new __Panel_Linear_Setting_Item(
			__txt("Name Display Type"),
			new scrollBox( [
	            __txt("panel_animation_name_full", "Full name"),
	            __txt("panel_animation_name_type", "Node type"),
	            __txt("panel_animation_name_only", "Node name"),
	        ], function(i) /*=>*/ { PANEL_ANIMATION.node_name_type = i; }),
			function( ) /*=>*/   {return PANEL_ANIMATION.node_name_type},
			function(v) /*=>*/ { PANEL_ANIMATION.node_name_type = v; },
		),
		
		-1, 
		
		new __Panel_Linear_Setting_Item(
			__txt("Keyframe Scale"),
			slider(0, 1, .01, function(v) /*=>*/ { PANEL_ANIMATION.keyframe_draw_scale = v; }),
			function( ) /*=>*/   {return PANEL_ANIMATION.keyframe_draw_scale},
			function(v) /*=>*/ { PANEL_ANIMATION.keyframe_draw_scale = v; },
		),
		
	];
	
	setHeight();
	
	static onDraw = function() {
		
	}
	
}