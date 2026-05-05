globalvar THEME_DEF; THEME_DEF        = true;
globalvar USE_TEXTUREGROUP; USE_TEXTUREGROUP = false; 
globalvar SPRITE_FALLBACK; SPRITE_FALLBACK  = "default"; 
globalvar SPRITES; 
globalvar THEME; 

function sprite_drawer(_spr) constructor {
	spr = _spr;
	w = sprite_get_width(spr);
	h = sprite_get_height(spr);
	
	static draw      = function(_x, _y, scale, color, alpha) {}
	static drawScale = function(_x, _y, scale, color, alpha) {}
}

function sprite_drawer_white(_spr, _col = c_white) : sprite_drawer(_spr) constructor {
	col = _col;
	
	static draw = function(_x, _y, scale, color, alpha) {
		draw_sprite_ui_uniform(spr, 0, _x, _y, scale, color, alpha);
		draw_sprite_ui_uniform(spr, 1, _x, _y, scale, col,   alpha);
	}
	
	static drawScale = function(_x, _y, scale, color, alpha) {
		__draw_sprite_ext(spr, 0, _x, _y, scale, scale, 0, color, alpha);
		__draw_sprite_ext(spr, 1, _x, _y, scale, scale, 0, col,   alpha);
	}
}

function __initTheme() {
	var root = DIRECTORY + "Themes";
	var t    = get_timer();
	
	directory_verify(root);
	if(check_version($"{root}/version")) {
		zip_unzip($"{working_directory}pack/themes.zip", root);	
		printDebug($"  - Unzip theme  | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	}
	
	loadColor(PREFERENCES.theme);			printDebug($"  - Load color   | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	loadGraphic(PREFERENCES.theme);			printDebug($"  - Load graphic | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	loadNodeIcons();
}

function _sprite_path(rel, theme) {
	return $"{DIRECTORY}Themes/{theme}/graphics/{string_replace_all(rel, "./", "")}"; 
}

function _sprite_load_from_struct(str, theme, key) {
	var path = filename_os(_sprite_path(str.path, theme));
	var numb = struct_try_get(str, "s", 1);
	var sx   = struct_try_get(str, "x", 0) * THEME_SCALE;
	var sy   = struct_try_get(str, "y", 0) * THEME_SCALE;
	
	if(!file_exists_empty(path)) { 
		path = filename_os(_sprite_path(str.path, SPRITE_FALLBACK));
		// log_message("THEME", $"Load sprite {str.path} failed: using fallback [{path}]."); 
		
		if(!file_exists_empty(path)) { 
			log_message("THEME", $"Load sprite {str.path} failed: Path not exists [{path}]."); 
			return 0;
		}
	}
	
	var s = sprite_add(path, numb, false, true, sx, sy);
	if( s < 0) { log_message("THEME", $"Load sprite {path} failed: Cannot read file."); return 0; }
	
	if(!struct_has(str, "slice")) return s;
	
	var slice = sprite_nineslice_create();	
	slice.enabled = true;
	
	var _sw = sprite_get_width(s);
	var _sh = sprite_get_height(s);
	
	if(is_array(str.slice)) {
		slice.left    = str.slice[0] > 0? str.slice[0] : _sw / 2 + str.slice[0];
		slice.right   = str.slice[1] > 0? str.slice[1] : _sw / 2 + str.slice[1];
		slice.top     = str.slice[2] > 0? str.slice[2] : _sh / 2 + str.slice[2];
		slice.bottom  = str.slice[3] > 0? str.slice[3] : _sh / 2 + str.slice[3];
		
	} else if(is_real(str.slice)) {
		var _sl = str.slice > 0? str.slice : _sw / 2 + str.slice;
		slice.left    = _sl;
		slice.right   = _sl;
		slice.top     = _sl;
		slice.bottom  = _sl;
		
	}
	
	if(struct_has(str, "slicemode"))
		slice.tilemode = array_create(5, str.slicemode);
	
	sprite_set_nineslice(s, slice);
	
	return s; 
}

function loadGraphic(theme = "default") {
	SPRITES = {};
	THEME   = {};
	
	var _metaP = $"{DIRECTORY}Themes/{theme}/meta.json";
	
	if(!file_exists_empty(_metaP))
		noti_warning("Init Theme: meta.json not found");
	else {
		var _meta = json_load_struct(_metaP);
		if(_meta[$ "version"] < VERSION)
			noti_warning($"Init Theme: Loading theme made for older version [{_meta[$ "version"]} < {VERSION}].");
			
		SPRITE_FALLBACK  = _meta[$ "fallback"] ?? "default"; 
	}
	
	var pathF  = _sprite_path("./graphics.json", SPRITE_FALLBACK);
	var path   = _sprite_path("./graphics.json", theme);
	
	printDebug($"  - Loading theme {theme}");
	
	var packPath = $"{DIRECTORY}Themes/{theme}/packed";
	var packed   = !PREFERENCES.theme_load_unpack && file_exists($"{packPath}/struct.json");
	    packed   = false;
	
	USE_TEXTUREGROUP = packed;
	
	if(packed) {
		var  pTex = $"{packPath}/texture.png";
		var  pStr = $"{packPath}/struct.json";
		var _data = json_load_struct(pStr);
		
		texturegroup_add("UI", pTex, _data);
		texturegroup_load("UI");
		
		var graphics = variable_struct_get_names(_data.sprites);
		for( var i = 0, n = array_length(graphics); i < n; i++ ) {
			key = graphics[i];
			
			THEME[$ key]   = asset_get_index(key);
			SPRITES[$ key] = THEME[$ key];
		}
		
	} else {
		var sprDef   = json_load_struct(pathF);
		var sprStr   = json_load_struct(path);
		var graphics = variable_struct_get_names(sprDef);
		
		for( var i = 0, n = array_length(graphics); i < n; i++ ) {
			var key = graphics[i];
			var str = sprStr[$ key] ?? sprDef[$ key];
			
			THEME[$ key]   = _sprite_load_from_struct(str, theme, key);
			SPRITES[$ key] = THEME[$ key];
		}
	}
	
	THEME.dPath_open                = new sprite_drawer_white(THEME.path_open,    CDEF.blue);
	THEME.dPath_open_20             = new sprite_drawer_white(THEME.path_open_20, CDEF.blue);
	
	THEME.dFile_save                = new sprite_drawer_white(THEME.file_save);
	THEME.dFile_load                = new sprite_drawer_white(THEME.file_load);
	
	THEME.dGradient_keys_blend      = new sprite_drawer_white(THEME.gradient_keys_blend);
	THEME.dGradient_keys_distribute = new sprite_drawer_white(THEME.gradient_keys_distribute);
	THEME.dGradient_keys_reverse    = new sprite_drawer_white(THEME.gradient_keys_reverse);
	
	THEME.dFolder_add               = new sprite_drawer_white(THEME.folder_add, COLORS._main_value_positive);
	THEME.dCache_clear              = new sprite_drawer_white(THEME.cache_remove, COLORS._main_value_negative);
	
}

function __test_generate_theme() {
	var _txt = "function Theme() constructor {\n";
	var _spr = struct_get_names(THEME);
	
	for( var i = 0, n = array_length(_spr); i < n; i++ )
		_txt += $"\t{_spr[i]} = noone;\n";
	_txt += "}";
	
	clipboard_set_text(_txt);
}

function __test_update_theme() {
	var _p = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/Themes/default/meta.json"
	var _d = json_load_struct(_p);
	_d.version = BUILD_NUMBER;
	json_save_struct(_p, _d, true);
	
	var _p = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/Themes/default HQ/meta.json"
	var _d = json_load_struct(_p);
	_d.version = BUILD_NUMBER;
	json_save_struct(_p, _d, true);
	
	noti_status($"Update theme to version {VERSION_STRING}.", noone, COLORS._main_value_positive);
	
	var upPath = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/update_theme.py";
	shell_execute("py", upPath);
	
	return 0;
}

function __generate_texturegroup_dir(_f) {
	var _packedDir = $"{_f}/packed";
	directory_clear(_packedDir);
	
	var _ss = 1024 * THEME_SCALE;
	
	var _sprites = {};
	var _surface = surface_create(_ss, _ss);
	
	var _xx = 0;
	var _yy = 0;
	var _lh = 0;
	
	var _keys = struct_get_names(SPRITES);
	array_sort(_keys, function(a,b) /*=>*/ {return sprite_get_height(SPRITES[$ b]) - sprite_get_height(SPRITES[$ a])});
	
	surface_set_shader(_surface);
	
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _key = _keys[i];
			var _spr = SPRITES[$ _key];
			
			var _sn = sprite_get_number(_spr);
			var _sw = sprite_get_width(_spr);
			var _sh = sprite_get_height(_spr);
			
			var _ox = sprite_get_xoffset(_spr);
			var _oy = sprite_get_yoffset(_spr);
			
			var _ni = sprite_get_nineslice(_spr);
			
			var _fram = [];
			var _data = {
				width  : _sw,
				height : _sh, 
				
				xoffset: _ox,
				yoffset: _oy,
			};
			
			if(_ni.enabled) {
				_data.nineslice = {
					left   : _ni.left,
					right  : _ni.right,
					top    : _ni.top,
					bottom : _ni.bottom,
					
					tilemode_left   : _ni.tilemode[0], 
					tilemode_right  : _ni.tilemode[1], 
					tilemode_top    : _ni.tilemode[2], 
					tilemode_bottom : _ni.tilemode[3], 
					tilemode_centre : _ni.tilemode[4]
				};
			}
			
			var _ind = 0;
			repeat(_sn) {
				if(_xx + _sw > _ss) {
					_xx  = 0;
					_yy += _lh;
					
					_lh = 0;
				}
				
				draw_sprite(_spr, _ind, _xx + _ox, _yy + _oy);
				_fram[_ind] = { x: _xx, y: _yy };
				
				_ind++;
				_xx += _sw;
				_lh = max(_lh, _sh);
			}
			
			_data.frames = _fram;
			_sprites[$ _key] = _data;
		}
		
	surface_reset_shader();
	
	var _struct = { sprites: _sprites };
	
	json_save_struct($"{_packedDir}/struct.json", _struct);
	surface_save(_surface, $"{_packedDir}/texture.png");
	surface_free(_surface);
}

function __generate_texturegroup() {
	__generate_texturegroup_dir($"D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/Themes/{PREFERENCES.theme}");
	__test_update_theme();
}

function loadNodeIcons() {
	var root = DIRECTORY + "NodeIcons";
	var t    = get_timer();
	
	directory_verify(root);
	if(check_version($"{root}/version")) {
		zip_unzip($"{working_directory}pack/node_icons.zip", root);	
		printDebug($"  - Unzip node icons  | complete in {(get_timer()-t)/1000}ms");    t = get_timer();
	}
	
}

///// CMD 

function __initThemeEmpty() {
	THEME = {
	    icon_24 : 0,
	    icon_24_grey : 0,
	    icon_64 : 0,
	    forum_grey : 0,
	    
	    ui_panel_bg_cover : 0,
	    fade_up : 0,
	    box_r2 : 0,
	    box_r2_clr : 0,
	    box_r5 : 0,
	    box_r5_clr : 0,
	    section_separator : 0,
	    corner_r4 : 0,
	
	    ac_constant : 0,
	    ac_function : 0,
	    ac_node : 0,
	    accept_16 : 0,
	    accept : 0,
	    accept_32 : 0,
	    accept_inv_16 : 0,
	    accept_b : 0,
	    add_16 : 0,
	    add_20 : 0,
	    add : 0,
	    add_32 : 0,
	    add_16_select : 0,
	    add_b : 0,
	    add_inv_16 : 0,
	    add_node : 0,
	    add_node_search_high : 0,
	    addon_icon : 0,
	    addon_setting : 0,
	    animate_clock : 0,
	    animate_node_go : 0,
	    animate_prop_go : 0,
	    animation_setting : 0,
	    animation_stretch : 0,
	    animation_timing : 0,
	    array_select_type : 0,
	    arrow_back_32 : 0,
	    arrow : 0,
	    arrow_24 : 0,
	    arrow_wire_16 : 0,
	    arrow4_24 : 0,
	    bone : 0,
	    button_path_icon : 0,
	    button_path_not_found_icon : 0,
	    cache_group : 0,
	    cache : 0,
	    cache_remove : 0,
	    canvas_20 : 0,
	    chat : 0,
	    checkbox_on_start : 0,
	    circle_16 : 0,
	    circle_32 : 0,
	    circle_hotkey : 0,
	    circle : 0,
	    circle_toggle_8 : 0,
	    code_show_auto : 0,
	    code_show_line : 0,
	    code_syntax_highlight : 0,
	    color_picker_dropper : 0,
	    color_selector_view : 0,
	    color_selector_slide : 0,
	    color_selector_range : 0,
	    color_wheel : 0,
	    copy_20 : 0,
	    copy : 0,
	    cross : 0,
	    cross_12 : 0,
	    cross_16 : 0,
	    cross_inv_16 : 0,
	    cursor_select : 0,
	    cursor_video : 0,
	    curvable : 0,
	    d3d_preview_settings : 0,
	    d3d_snap_settings : 0,
	    driver : 0,
	    discord : 0,
	    display_palette : 0,
	    dynadraw : 0,
	    download : 0,
	    download_inv_16 : 0,
	    duplicate : 0,
	    explorer : 0,
	    favorite : 0,
	    feedback_24 : 0,
	    feedback : 0,
	    file : 0,
	    file_save : 0,
	    file_load : 0,
	    fill : 0,
	    filter : 0,
	    filter_animation : 0,
	    filter_type : 0,
	    flip_h : 0,
	    flip_v : 0,
	    flip_d : 0,
	    fluid_sim : 0,
	    folder_16 : 0,
	    folder_add : 0,
	    folder_content : 0,
	    folder : 0,
	    folder_sel : 0,
	    frame_range : 0,
	    gif_loop_type : 0,
	    gear : 0,
	    gear_16 : 0,
	    generate_layers : 0,
	    globe : 0,
	    grad_blend : 0,
	    gradient_keys_blend : 0,
	    gradient_keys_distribute : 0,
	    gradient_keys_reverse : 0,
	    group_s : 0,
	    group : 0,
	    group_linked_s : 0,
	    hamburger_s : 0,
	    hamburger : 0,
	    heart : 0,
	    home : 0,
	    icon_3d_anchor : 0,
	    icon_active_split : 0,
	    icon_canvas : 0,
	    icon_canvas_24 : 0,
	    icon_center_canvas : 0,
	    icon_cmd_enter : 0,
	    icon_curve_connection : 0,
	    icon_curve_connection_setting : 0,
	    icon_delete : 0,
	    icon_delete_24 : 0,
	    icon_default : 0,
	    icon_font : 0,
	    icon_gizmo : 0,
	    icon_grid_setting : 0,
	    icon_visible_setting : 0,
	    icon_minimap : 0,
	    icon_preview_export : 0,
	    icon_preview_mode : 0,
	    icon_random : 0,
	    icon_reset_when_preview : 0,
	    icon_save_all : 0,
	    icon_splash_show_on_start : 0,
	    icon_split_view : 0,
	    icon_tile_view : 0,
	    icon_toggle : 0,
	    icon_visibility : 0,
	    image_20 : 0,
	    info : 0,
	    info_light : 0,
	    inspector_view : 0,
	    junc_visible : 0,
	    junction_bypass : 0,
	    keyframe_override : 0,
	    libraries : 0,
	    loading_s : 0,
	    loading : 0,
	    lock_12 : 0,
	    lock : 0,
	    loop_24 : 0,
	    loop : 0,
	    magnet : 0,
	    mappable_parameter : 0,
	    marker : 0,
	    marker_add : 0,
	    marker_remove : 0,
	    marker_goto : 0,
	    message_16_grey_bubble : 0,
	    message_16_grey : 0,
	    message_16 : 0,
	    message_24 : 0,
	    minus_16 : 0,
	    minus : 0,
	    minus_32 : 0,
	    minus_b : 0,
	    minus_inv_16 : 0,
	    mk_tree_leaf_unit : 0,
	    mk_tree_curve_length : 0,
	    mk_tree_curve_branch : 0,
	    mk_tree_curve_whorled : 0,
	    mkTree : 0,
	    mkTree_leaf : 0,
	    new_file : 0,
	    new_line_shift : 0,
	    node : 0,
	    node_drop : 0,
	    node_dropper : 0,
	    node_goto_16 : 0,
	    node_goto : 0,
	    node_goto_thin : 0,
	    node_name_type : 0,
	    node_processor_icon : 0,
	    node_pxc : 0,
	    node_resize : 0,
	    node_selector : 0,
	    node_sel_from : 0,
	    node_sel_to : 0,
	    node_sel_conn : 0,
	    node_sel_invert : 0,
	    node_sel_sib : 0,
	    node_sel_cache : 0,
	    node_sel_orphan : 0,
	    node_sel_anim : 0,
	    node_sel_render_none : 0,
	    node_use_expression : 0,
	    node_use_project : 0,
	    noti_icon_error : 0,
	    noti_icon_file_load : 0,
	    noti_icon_file_save : 0,
	    noti_icon_log : 0,
	    noti_icon_tick : 0,
	    noti_icon_warning : 0,
	    mesh : 0,
	    onion_skin : 0,
	    panel_animation_icon : 0,
	    panel_graph_icon : 0,
	    panel_inspector_icon : 0,
	    panel_preview_icon : 0,
	    paste_20 : 0,
	    paste : 0,
	    path_open_20 : 0,
	    path_open : 0,
	    path_edit : 0,
	    patreon_supporter : 0,
	    patreon : 0,
	    pixel_diag : 0,
	    pen_pressure : 0,
	    pin : 0,
	    pixel_builder : 0,
	    play_action : 0,
	    play_all : 0,
	    play_sound : 0,
	    preset : 0,
	    preview_3d_axis_empty : 0,
	    preview_3d_axis_plane : 0,
	    project : 0,
	    redo : 0,
	    refresh_16 : 0,
	    refresh_20 : 0,
	    refresh_icon : 0,
	    reset_16 : 0,
	    rename : 0,
	    reverse : 0,
	    rigidSim : 0,
	    rotator_random_mode : 0,
	    save_auto : 0,
	    save : 0,
	    scissor : 0,
	    scroll_box_arrow : 0,
	    search : 0,
	    search_24 : 0,
	    send : 0,
	    sequence_control : 0,
	    smoke_sim : 0,
	    sort_16 : 0,
	    sort : 0,
	    sort_v : 0,
	    stamp_16 : 0,
	    stamp : 0,
	    splash_thumbnail : 0,
	    star : 0,
	    steam_creator : 0,
	    strandSim : 0,
	    tab_exit : 0,
	    tag : 0,
	    tag_24 : 0,
	    text_bullet : 0,
	    text_popup : 0,
	    tileset : 0,
	    text : 0,
	    timeline_hide : 0,
	    timeline_hide_24 : 0,
	    timeline_graph : 0,
	    timeline_graph_range_auto : 0,
	    trophy : 0,
	    tunnel : 0,
	    tunnel_panel : 0,
	    tunnel_create : 0,
	    undo : 0,
	    unit_angle : 0,
	    unit_audio : 0,
	    unit_ref : 0,
	    unit_fps : 0,
	    value_link : 0,
	    value_range : 0,
	    vct : 0,
	    verletSim : 0,
	    vfx : 0,
	    video : 0,
	    view_group : 0,
	    view_mode : 0,
	    scrollbox_direction : 0,
	    shader_alpha : 0,
	    swap_hori : 0,
	    swap_vert : 0,
	    view_pan : 0,
	    view_zoom : 0,
	    visible_12 : 0,
	    vote_down : 0,
	    vote_up : 0,
	    visible : 0,
	    wiki : 0,
	    window_exit_icon : 0,
	    window_pan_icon : 0,
	    window_fullscreen_icon : 0,
	    window_maximize_icon : 0,
	    window_minimize_icon : 0,
	    workshop_add : 0,
	    workshop_collection : 0,
	    workshop_no_file : 0,
	    workshop_project : 0,
	    workshop_patreon : 0,
	    workshop_update : 0,
	    workshop_upload : 0,
	    workshop_sort : 0,
	    icon_os_windows : 0,
	    icon_os_linux : 0,
	    icon_os_mac : 0,
	
	    apreset_01 : 0,
	    apreset_10 : 0,
	    apreset_down : 0,
	    apreset_up : 0,
	    apreset_left : 0,
	    apreset_right : 0,
	
	    pxc_hub : 0,
	    steam : 0,
	    steam_invert_24 : 0,
	    link : 0,
	    bluesky : 0,
	    mastodon : 0,
	    twitter : 0,
	    youtube : 0,
	
	    tool_size : 0,
	    tool_threshold : 0,
	    tool_bg : 0,
	    tool_fill_type : 0,
	    tool_scale : 0,
	    tool_intensity : 0,
	    tool_poster : 0,
	    
	    prop_position : 0,
	    prop_rotation : 0,
	    prop_scale : 0,
	    prop_radius : 0,
	    prop_radius_inner : 0,
	    prop_star_inner : 0,
	    prop_segment : 0,
	    prop_level : 0,
	
	    inspector_area_type : 0,
	    inspector_fill_type : 0,
	    inspector_area : 0,
	    inspector_surface_halign : 0,
	    inspector_surface_valign : 0,
	    inspector_text_halign : 0,
	    inspector_text_valign : 0,
	    prop_anchor : 0,
	    prop_gradient : 0,
	    prop_keyframe : 0,
	    prop_on_end : 0,
	    prop_selecting : 0,
	
	    node_coor_pin : 0,
	    node_draw_area : 0,
	    node_draw_path : 0,
	
	    node_action_create : 0,
	    node_action_manager : 0,
	
	    node_junction_add : 0,
	    node_junction_inspector : 0,
	    node_junction_inspector_button : 0,
	    node_junction_matrix : 0,
	    node_junction_mktree : 0,
	    node_junction_mktree_leaves : 0,
	    node_junction_surface_ext : 0,
	    node_junction_surface_map : 0,
	
	    node_junctions_single : 0,
	    node_junctions_bg : 0,
	    node_junctions_outline : 0,
	    node_junctions_outline_hover : 0,
	    node_junction_selecting : 0,
	    node_display_type : 0,
	
	    node_junction_group_bg : 0,
	    node_bg : 0,
	    node_frame_bg : 0,
	    node_deprecated_badge : 0,
	    node_glow_border : 0,
	    node_junction_name_bg : 0,
	    node_new_badge : 0,
	    node_resize_corner : 0,
	    node_state : 0,
	    node_trigger_icon : 0,
	    junc_aseprite : 0,
	    junc_krita : 0,
	
	    node_websocket_receive : 0,
	    node_websocket_send : 0,
	
	    dialog : 0,
	    dialog_menu : 0,
	    panel_tab_align : 0,
	    tool_side : 0,
	    toolbar : 0,
	    ui_panel : 0,
	    ui_panel_bg : 0,
	    ui_panel_bg_header : 0,
	    ui_panel_tool : 0,
	    ui_panel_tab : 0,
	    ui_panel_tab_v : 0,
	    ui_selection_range_hori : 0,
	    ui_selection_range_sim_hori : 0,
	    ui_selection : 0,
	    ui_panel_selection : 0,
	    
	    panel_icon_element_frame : 0,
	    panel_icon_element_frame_grid : 0,
	    panel_icon_element_frame_flex : 0,
	    panel_icon_element_frame_scroll : 0,
	    panel_icon_element_frame_split : 0,
	    panel_icon_element_frame_stack : 0,
	    panel_icon_element_frame_tab : 0,
	
	    panel_icon_element_button : 0,
	    panel_icon_element_choices : 0,
	    panel_icon_element_color : 0,
	    panel_icon_element_knob : 0,
	    panel_icon_element_slider : 0,
	    panel_icon_element_text : 0,
	    panel_icon_element_textbox : 0,
	    panel_icon_element_textarea : 0,
	    panel_icon_element_globalvar : 0,
	    panel_icon_element_node_input : 0,
	    panel_icon_element_node_output : 0,
	
	    ui_scrollbar : 0,
	    color_picker_sample : 0,
	    color_picker_box : 0,
	    palette_mask : 0,
	    palette_mask_outline : 0,
	    palette_selecting : 0,
	    key_display : 0,
	    add_node_bg : 0,
	    
	    color_3d : 0,
	    color_3d_selected : 0,
	    anchor_arrow : 0,
	    anchor_bone_stick : 0,
	    anchor_rotate : 0,
	    anchor_scale_hori : 0,
	    anchor_scale : 0,
	    anchor_selector : 0,
	    anchor : 0,
	    cursor_add : 0,
	    cursor_move : 0,
	    cursor_remove : 0,
	    cursor_scale_diag : 0,
	    cursor_path_anchor : 0,
	    cursor_path_anchor_detach : 0,
	    cursor_path_anchor_unmirror : 0,
	    preview_bone_IK : 0,
	    bone_move : 0,
	    bone_rotate : 0,
	    bone_scale : 0,
	    preview_channels : 0,
	    preview_bg_black : 0,
	    preview_bg_white : 0,
	    preview_bg_transparent : 0,
	
	    timeline_color : 0,
	    timeline_ease : 0,
	    timeline_key_ease : 0,
	    timeline_key_empty : 0,
	    timeline_keyframe_selecting : 0,
	    timeline_keyframe : 0,
	    timeline_keyframes_content : 0,
	    timeline_marker : 0,
	    timeline_onion_skin : 0,
	    timeline_frame_box : 0,
	
	    curve_presets : 0,
	    curve_type : 0,
	    inspector_channel : 0,
	    inspector_checkbox : 0,
	    inspector_corner : 0,
	    obj_angle : 0,
	    obj_auto_align : 0,
	    obj_auto_organize : 0,
	    obj_direction : 0,
	    obj_distribute_h : 0,
	    obj_distribute_v : 0,
	    obj_draw_line : 0,
	    obj_hemicircle : 0,
	    object_halign : 0,
	    object_valign : 0,
	    object_align_center : 0,
	    stroke_position : 0,
	    stroke_profile : 0,
	    inspector_pb_line : 0,
	
	    area_tool : 0,
	    bone_tool_add : 0,
	    bone_tool_add_control : 0,
	    bone_tool_detach : 0,
	    bone_tool_IK : 0,
	    bone_tool_move : 0,
	    bone_tool_pose : 0,
	    bone_tool_remove : 0,
	    bone_tool_scale : 0,
	    bone_tool_mirror : 0,
	    canvas_dither : 0,
	    canvas_draw_layer : 0,
	    canvas_iso_angle : 0,
	    canvas_fill_type : 0,
	    canvas_flip : 0,
	    canvas_flip_h : 0,
	    canvas_flip_v : 0,
	    canvas_mirror_diag : 0,
	    canvas_mirror : 0,
	    canvas_resize : 0,
	    canvas_rotate : 0,
	    canvas_rotate_ccw : 0,
	    canvas_rotate_cw : 0,
	    canvas_tool_curve_icon : 0,
	    canvas_tools_bucket : 0,
	    canvas_tools_gradient : 0,
	    canvas_tools_pattern : 0,
	    canvas_tools_ellip_fill : 0,
	    canvas_tools_ellip : 0,
	    canvas_tools_iso_cube_fill : 0,
	    canvas_tools_iso_cube_wire : 0,
	    canvas_tools_iso_cube : 0,
	    canvas_tools_eraser : 0,
	    canvas_tools_extrude : 0,
	    canvas_tools_freeform_selection : 0,
	    canvas_tools_freeform : 0,
	    canvas_tools_inset : 0,
	    canvas_tools_magic_selection : 0,
	    canvas_tools_corner : 0,
	    canvas_tools_node : 0,
	    canvas_tools_extract : 0,
	    canvas_tools_outline : 0,
	    canvas_tools_pencil : 0,
	    canvas_tools_pencil_surface : 0,
	    canvas_tools_rect_fill : 0,
	    canvas_tools_rect : 0,
	    canvas_tools_selection_brush : 0,
	    canvas_tools_selection_circle : 0,
	    canvas_tools_selection_rectangle : 0,
	    canvas_tools_skew : 0,
	    control_add : 0,
	    control_subtract : 0,
	    control_pin : 0,
	    crop_fit_height : 0,
	    crop_fit_width : 0,
	    crop_tool : 0,
	    mesh_tool_delete : 0,
	    mesh_tool_edit : 0,
	    path_tools_add : 0,
	    path_tools_arc : 0,
	    path_tools_anchor : 0,
	    path_tools_line : 0,
	    path_tools_line_curve : 0,
	    path_tools_circle : 0,
	    path_tools_circle_mid_point : 0,
	    path_tools_draw : 0,
	    path_tools_polygon : 0,
	    path_tools_rectangle : 0,
	    path_tools_transform : 0,
	    path_tools_weight_edit : 0,
	    strand_comb : 0,
	    strand_cut : 0,
	    strand_grab : 0,
	    strand_push : 0,
	    strand_stretch : 0,
	    text_tools_edit : 0,
	    tool_color : 0,
	    toolbar_check : 0,
	    tools_1d_move : 0,
	    tools_2d_move : 0,
	    tools_2d_rotate : 0,
	    tools_2d_scale : 0,
	    tools_3d_rotate : 0,
	    tools_3d_scale : 0,
	    tools_3d_side : 0,
	    tools_3d_transform_object : 0,
	    tools_3d_transform : 0,
	    tools_canvas_channel : 0,
	
	    button_def : 0,
	    button_hide_fill : 0,
	    button_hide_left : 0,
	    button_hide_middle : 0,
	    button_hide_right : 0,
	    button_hide : 0,
	    button_left : 0,
	    button_lime : 0,
	    button_middle : 0,
	    button_right : 0,
	    button_backdroup : 0,
	    checkbox_active : 0,
	    checkbox_def : 0,
	    progress_bar : 0,
	    textbox_code : 0,
	    textbox_header : 0,
	    textbox : 0,
	    textbox_arrow : 0,
	    widget_selecting : 0,
	    
	    dPath_open : 0,
		dPath_open_20 : 0,
		dFile_save : 0,
		dFile_load : 0,
		dGradient_keys_blend : 0,
		dGradient_keys_distribute : 0,
		dGradient_keys_reverse : 0,
		dFolder_add : 0,
		dCache_clear : 0,
	}
}
