function ThemeColorDef() constructor {
	main_dkblack = #191925;
	main_mdblack = #1e1e2c;
	main_black   = #272736;
	main_dkgrey  = #3b3b4e;
	main_dark    = #505066;
	main_grey    = #6d6d81;
	main_ltgrey  = #7e7e8f;
	main_mdwhite = #9f9fb5;
	main_white   = #d6d6e8;
	main_bg      = #1c1c23;

	blue         = #27aae1;
	cyan         = #88ffe9;
	yellow       = #ffe478;
	orange       = #ff9166;
	red          = #eb004b;
	pink         = #eb00b7;
	purple       = #9200d4;
	lime         = #8fde5d;
	pgreen       = #50eb17;
	pblue        = #3d43f5;

	black        = #000000;
	dkgrey       = #202020;
	smoke        = #6d6e71;
	white        = #ffffff;
}

function ThemeColor() constructor {
	bg                                  = CDEF.main_bg;

    _main_accent                        = CDEF.orange;
    _main_text                          = CDEF.white;
    _main_text_inner                    = CDEF.main_white;
    _main_text_accent                   = CDEF.orange;
    _main_text_accent_inner             = CDEF.orange;
    _main_text_on_accent                = CDEF.main_black;
    _main_text_sub                      = CDEF.main_grey;
    _main_text_sub_inner                = CDEF.main_grey;
    _main_icon                          = CDEF.main_ltgrey;
    _main_icon_on_inner                 = CDEF.main_white;
    _main_icon_light                    = CDEF.main_white;
    _main_icon_dark                     = CDEF.main_mdblack;
    _main_value_positive                = CDEF.lime;
    _main_value_negative                = CDEF.red;

    lua_highlight_keyword               = CDEF.orange;
    lua_highlight_bracklet              = CDEF.cyan;
    lua_highlight_function              = CDEF.lime;
    lua_highlight_number                = CDEF.yellow;
    lua_highlight_string                = CDEF.blue;
    lua_highlight_comment               = CDEF.main_ltgrey;
    
    collection_folder_empty             = CDEF.main_dkgrey;
    collection_folder_nonempty          = CDEF.main_ltgrey;
    collection_tree_line                = CDEF.main_dkgrey;
    collection_path_current_bg          = CDEF.main_grey;
    
    assetbox_current_bg                 = CDEF.main_ltgrey;
    
    dialog_array_edit_divider           = CDEF.main_dkgrey;
    dialog_array_edit_bg                = CDEF.main_dkgrey;
    dialog_splash_badge                 = CDEF.main_mdblack;
    dialog_about_bg                     = CDEF.main_grey;
    dialog_preference_prop_bg           = CDEF.main_white;
    dialog_add_node_collection          = merge_color(CDEF.white, CDEF.orange, 0.5);
    dialog_add_node_replace_mode        = CDEF.cyan;
    dialog_palette_divider              = CDEF.main_grey;
    dialog_notification_bg_hover        = CDEF.main_ltgrey;
    dialog_notification_bg              = CDEF.main_grey;
    dialog_notification_icon_bg         = CDEF.main_white;
    dialog_menubox_highlight            = CDEF.main_white;
    dialog_lua_ref_bg_args              = CDEF.main_ltgrey;
    dialog_lua_ref_bg_hover             = merge_color(CDEF.main_white, CDEF.main_ltgrey, 0.5);
    dialog_lua_ref_bg                   = CDEF.main_white;
    
    add_node_blend_action               = CDEF.lime;
    add_node_blend_generic              = CDEF.yellow;

    node_composite_bg                   = CDEF.main_dkgrey;
    node_composite_bg_blend             = CDEF.main_white;
    node_composite_separator            = CDEF.main_black;
    node_composite_overlay_border       = CDEF.main_grey;
    node_display_text_frame_fill        = CDEF.main_grey;
    node_display_text_frame_outline     = CDEF.main_dkblack;
    node_level_outline                  = CDEF.main_dkgrey;
    node_level_shade                    = CDEF.main_black;
    node_overlay_gizmo_inactive         = CDEF.white;
    node_blend_default                  = CDEF.main_ltgrey;
    node_blend_tunnel                   = merge_color(CDEF.red, CDEF.main_black, 0.7 );
    node_blend_number                   = CDEF.cyan;
    node_blend_input                    = merge_color(CDEF.white, CDEF.lime, 0.5);
    node_blend_loop                     = CDEF.cyan;
    node_blend_vfx                      = CDEF.lime;
    node_blend_feedback                 = CDEF.pink;
    node_blend_collection               = CDEF.yellow;
    node_blend_simulation               = CDEF.cyan;
    node_blend_fluid                    = CDEF.main_dark;
    node_blend_smoke                    = CDEF.smoke;
    node_blend_canvas                   = merge_color(CDEF.white, CDEF.orange, 0.5);
    node_blend_strand                   = CDEF.orange;
    node_blend_vct                      = CDEF.white;
    node_blend_dynaSurf                 = CDEF.red;
    node_path_overlay_control_line      = CDEF.main_grey;
    node_wiggler_frame                  = CDEF.main_grey;
    node_border_file_drop               = CDEF.cyan;
    node_border_context                 = CDEF.yellow;

    scrollbar_bg                        = CDEF.main_dkblack;
    scrollbar_idle                      = CDEF.main_grey;
    scrollbar_hover                     = CDEF.main_mdwhite;
    scrollbar_active                    = CDEF.main_white;

    panel_animation_frame_divider       = CDEF.main_black;
    panel_animation_keyframe_ease_line  = CDEF.main_dkgrey;
    panel_animation_loop_line           = CDEF.lime;
    panel_animation_key_tool_unselected = CDEF.main_grey;
    panel_animation_keyframe_selected   = CDEF.main_white;
    panel_animation_keyframe_unselected = CDEF.main_ltgrey;
    panel_animation_keyframe_hide       = CDEF.main_grey;
    panel_animation_node_bg             = CDEF.main_grey;
    panel_animation_node_outline        = CDEF.main_black;
    panel_animation_dope_bg_hover       = merge_color(CDEF.main_black, CDEF.main_mdblack, 0.5 );
    panel_animation_dope_bg             = CDEF.main_black;
    panel_animation_dope_key_bg_hover   = CDEF.main_mdblack;
    panel_animation_dope_key_bg         = CDEF.main_black;
    panel_animation_graph_bg            = CDEF.main_dkblack;
    panel_animation_graph_select        = CDEF.main_mdblack;
    panel_animation_graph_line          = CDEF.main_grey;
    panel_animation_end_line            = CDEF.main_ltgrey;
    panel_animation_preview_frame       = CDEF.main_dkgrey;
    panel_animation_timeline_blend      = CDEF.main_ltgrey;
    panel_animation_timeline_top        = merge_color(CDEF.black, CDEF.main_dkblack, 0.5);
    panel_animation_range               = CDEF.lime;
    panel_animation_range_sim           = CDEF.cyan;

    panel_animation_dope_blend_default  = merge_color(CDEF.blue, CDEF.main_dkblack, 0.5);
    panel_animation_dope_blend          = CDEF.main_dkblack;
	
    panel_bg_clear_inner                = CDEF.main_mdblack;
    panel_bg_clear                      = CDEF.main_black;
    panel_select_border					= CDEF.main_grey;
    panel_frame                         = CDEF.main_dkgrey;
    panel_prop_bg                       = CDEF.main_ltgrey;
    panel_tab                           = CDEF.white;
    panel_tab_hover                     = CDEF.white;
    panel_tab_inactive                  = CDEF.white;
    panel_tab_text                      = CDEF.main_dkblack;
    panel_tab_icon                      = CDEF.main_dkblack;
    panel_separator                     = CDEF.main_dkgrey;

    panel_graph_minimap_outline         = CDEF.main_dkgrey;
    panel_graph_node_dimension          = CDEF.main_grey;
    panel_graph_minimap_focus           = CDEF.main_ltgrey;

    panel_inspector_key_separator       = CDEF.main_dkgrey;
    panel_inspector_group_hover         = CDEF.main_white;
    panel_inspector_group_bg            = merge_color(CDEF.main_white, CDEF.main_ltgrey, 0.5);
    panel_inspector_output_label        = CDEF.black;
    
    panel_preview_grid                  = CDEF.main_grey;
    panel_preview_surface_outline       = CDEF.main_grey;
    panel_preview_split_line            = CDEF.main_grey;
    panel_preview_tool_button           = CDEF.main_white;
    panel_preview_tool_separator        = CDEF.main_dkgrey;
    panel_preview_transparent           = merge_color(CDEF.main_dkgrey, CDEF.main_black, 0.65);

    panel_3d_bg                         = CDEF.main_dkblack;

    panel_toolbar_outline               = CDEF.main_dkgrey;
    panel_toolbar_separator             = CDEF.main_dkblack;
    
    widget_curve_line                   = CDEF.main_ltgrey;
    widget_curve_outline                = CDEF.main_grey;
    widget_rotator_range                = CDEF.main_dkgrey;
    widget_rotator_range_hover          = CDEF.main_grey;
    widget_rotator_guide                = CDEF.main_grey;
    widget_surface_frame                = CDEF.main_dkgrey;
    widget_text_highlight               = CDEF.main_dkgrey;
    widget_slider_step                  = CDEF.main_dkgrey;

    widget_text_dec_d                   = CDEF.cyan;
    widget_text_dec_n                   = CDEF.lime;
    widget_text_dec_e                   = CDEF.orange;
    widget_text_dec_f                   = CDEF.pink;
    widget_text_dec_i                   = CDEF.yellow;
	
    axis      = [CDEF.red, CDEF.pgreen, CDEF.pblue, CDEF.yellow, CDEF.pink, CDEF.purple];
    histogram = [CDEF.red, CDEF.lime, CDEF.cyan, CDEF.white];
    heat      = [CDEF.red, CDEF.yellow, CDEF.lime];
    speed     = [CDEF.red, CDEF.orange, CDEF.lime];
    labels    = [CDEF.white, CDEF.main_grey, CDEF.blue, CDEF.cyan, CDEF.yellow, CDEF.orange, CDEF.red, CDEF.pink, CDEF.purple, CDEF.lime];
}

function ThemeValue() constructor {
	highlight_corner_radius    =  8;
    selection_corner_radius    =  6;
    
    panel_padding              =  2;
    panel_margin               =  2;
    panel_corner_radius        =  8;
    panel_notification_padding =  0;
    panel_tab_extend           =  2;

    minimap_corner_radius      =  2;
    slider_type                =  "stem";
    font_aa                    =  true;
}