#region global
	function Steam_workshop_profile_get(_aid) {
		var _a = STEAM_WORKSHOP_DATA.account[$ _aid];
		if(_a) return _a;
		
		var _a = new Steam_workshop_profile(_aid);
		STEAM_WORKSHOP_DATA.account[$ _aid] = _a;
		return _a;
	}
	
	globalvar AUTHOR_BANNER; AUTHOR_BANNER = [
		"s_workshop_bg_check",
		"s_workshop_bg_check_dark",
		"s_workshop_bg_donut",
		"s_workshop_bg_donut_dark",
		"s_workshop_bg_dot",
		"s_workshop_bg_dot_dark",
		"s_workshop_bg_grid",
		"s_workshop_bg_grid_dark",
		"s_workshop_bg_node",
		"s_workshop_bg_node_dark",
		"s_workshop_bg_pxc",
		"s_workshop_bg_pxc_dark",
		"s_workshop_bg_round_block",
		"s_workshop_bg_round_block_dark",
		"s_workshop_bg_star",
		"s_workshop_bg_star_dark",
		"s_workshop_bg_strip",
		"s_workshop_bg_strip_dark",
		"s_workshop_bg_strip_d",
		"s_workshop_bg_strip_d_dark",
		"s_workshop_bg_strip_s",
		"s_workshop_bg_strip_s_dark",
		"s_workshop_bg_zigzag",
		"s_workshop_bg_zigzag_dark",
	];
#endregion	

function Steam_workshop_profile(_sid) constructor {
	account_steam_id = _sid;
	
	data   = undefined;
	name   = undefined;
	avatar = undefined;
	badges = [];
	badgeK = [];
	links  = [];
	
	projects = [];
	
	banner      = { type: 0, sprite: 0 };
	banner_path = $"{TEMPDIR}{_sid}_banner.png";
	banner_spr  = undefined;
	
	profile_graph          = undefined;
	profile_graph_str      = undefined;
	profile_graph_runner   = undefined;
	profile_graph_surfaces = [-1,-1];
	
	is_patreon  = undefined;
	pageContent = [ { type: "Popular"}, { type: "Recents"} ];
	
	submission_count      = 0; submission_count_disp      = 0;
	submission_project    = 0; submission_project_disp    = 0;
	submission_collection = 0; submission_collection_disp = 0;
	total_upvotes         = 0; total_upvotes_disp         = 0;
	max_upvotes           = 0; max_upvotes_disp           = 0;
	
	////- Data
	
	static getName = function() {
		if(name != undefined) return name;
		
		name = "";
		asyncCallGroup("steam", steam_get_user_persona_name(int64(account_steam_id)), function(_params, _data) /*=>*/ { 
			name = ds_map_try_get(_data, "persona_name", undefined);
		});
		
	} getName();
	
	static getAvatar = function() {
		if(avatar != undefined) return avatar;
		
		var _ava = steam_get_user_avatar(int64(account_steam_id), steam_user_avatar_size_large);
		
		if(_ava > 0) {
			var _l_dims    = steam_image_get_size(_ava);
		    var _buff_size = _l_dims[0] * _l_dims[1] * 4;
		    var _l_cols    = buffer_create(_buff_size, buffer_fixed, 1);
			var _l_ok      = steam_image_get_rgba(_ava, _l_cols, _buff_size);
		
		    if(_l_ok) {
			    var _l_surf = surface_create(_l_dims[0], _l_dims[1]);
			    buffer_set_surface(_l_cols, _l_surf, 0);
			    
				avatar = sprite_create_from_surface(_l_surf, 0, 0, _l_dims[0], _l_dims[1], false, false, 0, 0);
				surface_free(_l_surf);
		    }
		    
		    buffer_delete(_l_cols);
		}
		
	}
	
	static getBanner = function() {
		if(banner_spr != undefined) return banner_spr;
		if(banner.type != 2)        return banner_spr;
		
		banner_spr = -1;
		var _url = banner.url;
		
		asyncCallGroup("http", http_get_file(_url, banner_path), function(_params, _data) /*=>*/ {
			var _status = _data[? "status"];
	    	if (_status == 0) return;
	    	
	    	if(!file_exists_empty(banner_path)) return;
	    	banner_spr = sprite_add(banner_path);
		});
	}
	
	static getPatreon = function() {
		if(is_patreon == undefined) getData();
		return is_patreon;
	}
	
	static getData = function() {
		if(data != undefined) return data;
		
		data = 0;
		is_patreon = false;
	    
		asyncCallGroup("social", FirebaseFirestore($"steam").Where("steamid", "==", string(account_steam_id)).Query(), function(_params, _data) /*=>*/ {
			data = -1;
			if (_data[? "status"] != 200) { noti_warning(_data[? "errorMessage"]); return; }
		    
		    var res  = _data[? "value"];
		    var resJ = json_try_parse(res, undefined);
		    if(resJ == undefined) return;
		    
		    var resA = struct_try_get(resJ, string(account_steam_id));
		    if(!is_struct(resA)) return;
		    
	    	data = resA;
	    	is_patreon  = bool(struct_try_get(resA, "active", false));
	    	data.badges = json_try_parse(data[$ "badges"], []);
	    	links       = json_try_parse(data[$ "links"],  []);
	    	
	    	if(struct_has(data, "banner")) 
	    		banner = json_try_parse(data[$ "banner"], banner);
    		
	    	if(struct_has(data, "profile_graph")) {
	    		profile_graph     = data.profile_graph;
	    		profile_graph_str = json_try_parse(profile_graph, -1);
	    	}
    		
	    	if(struct_has(data, "pageContent")) 
	    		pageContent = json_try_parse(data[$ "pageContent"], pageContent);
	    		
			total_upvotes = data[$ "total_upvotes"] ?? 0;
			max_upvotes   = data[$ "max_upvotes"]   ?? 0;
	    	
	    	checkBadge();
	    	updateBadge();
		});
		
		return data;
	}
	
	static drawProfileSimple = function(_px, _py, _ps) {
		var _ava = getAvatar();
		
		gpu_set_stencil_enable(true);
		
		draw_clear_stencil(0);
		gpu_set_stencil_pass(stencilop_replace);
		
		gpu_set_stencil_compare(cmpfunc_greater, 128);
		draw_set_color_alpha(CDEF.main_dkblack);
		draw_roundrect_ext(_px, _py, _px + _ps - 1, _py + _ps - 1, ui(8), ui(8), false);
		
		gpu_set_stencil_compare(cmpfunc_less, 64);
			
		draw_sprite_stretched(_ava, 0, _px, _py, _ps, _ps);
		
		gpu_set_stencil_enable(false);
		
		draw_set_color_alpha(COLORS._main_icon, .5);
		draw_roundrect_ext(_px, _py, _px + _ps - 1, _py + _ps - 1, ui(8), ui(8), true);
		draw_set_alpha(1);
		
	}
	
	static drawProfile = function(_px, _py, _ps, _update = false) {
		var _ava = getAvatar();
		if(!sprite_exists(_ava)) return undefined;
		
		if(!is_struct(profile_graph_str)) {
			drawProfileSimple(_px, _py, _ps);
			return undefined;
		}
		
		if(profile_graph_runner == undefined) {
			var _title = getName() + "'s " + __txt("Profile Graph");
			profile_graph_runner = new Runner().appendMap(profile_graph_str).fetchIO();
			profile_graph_runner.project.path = _title;
		}
		
		if(!profile_graph_runner.processable()) {
			drawProfileSimple(_px, _py, _ps);
			return undefined;
		}
		
		if(!surface_exists(profile_graph_surfaces[0])) {
			profile_graph_surfaces[0] = surface_verify(profile_graph_surfaces[0], _ps, _ps);
			
			surface_set_shader(profile_graph_surfaces[0]);
				draw_sprite_stretched(_ava, 0, 0, 0, _ps, _ps);
			surface_reset_shader();
		}
		
		if(!surface_exists(profile_graph_surfaces[1]) || _update) {
			
			var _animm = profile_graph_runner.project.animator;
			var _anLen = _animm.frames_total;
			var _anSpd = _animm.framerate;
			var _frame = floor(current_time / 1000 * _anSpd) % _anLen;
			var _surf  = profile_graph_runner.process(profile_graph_surfaces[0], _frame);
			
			var _sw = min(_ps * 2, surface_get_width_safe(_surf));
			var _sh = min(_ps * 2, surface_get_height_safe(_surf));
			
			profile_graph_surfaces[1] = surface_verify(profile_graph_surfaces[1], _sw, _sh);
			
			surface_set_shader(profile_graph_surfaces[1]);
				draw_surface_safe(_surf);
			surface_reset_shader();
			
		}
		
		var _sw = surface_get_width_safe(profile_graph_surfaces[1]);
		var _sh = surface_get_height_safe(profile_graph_surfaces[1]);
		var _cx = _px + _ps/2 - _sw/2;
		var _cy = _py + _ps/2 - _sh/2;
		
		draw_surface_safe(profile_graph_surfaces[1], _cx, _cy);
	}
	
	static setProjects = function(_list) {
		projects = [];
		submission_count      = 0; submission_count_disp      = 0;
		submission_project    = 0; submission_project_disp    = 0;
		submission_collection = 0; submission_collection_disp = 0;
		
		for( var i = 0, n = array_length(_list); i < n; i++ ) {
			var _f = _list[i];
			projects[i] = _f;
			submission_count++;
			
			if(_f.type == FILE_TYPE.project)    submission_project++;
			if(_f.type == FILE_TYPE.collection) submission_collection++;
		}
		
		checkBadge();
		checkUpvotes();
	}
	
	static checkUpvotes = function() {
		var _complete      = true;
		var _total_upvotes = 0;
		var _max_upvotes   = 0;
		
		for( var i = 0, n = array_length(projects); i < n; i++ ) {
			var _f = projects[i];
			var _s = _f.getHUBStatus();
			if(_s == 0) { _complete = false; break; }
			
			_total_upvotes += _f.getVotesUp();
			_max_upvotes    = max(_max_upvotes, _f.getVotesUp());
		}
		
		if(_complete) {
			total_upvotes = _total_upvotes;
			max_upvotes   = _max_upvotes;	
			
			updateData({ total_upvotes, max_upvotes });
			return;
		}
		
		run_in_s(10, function() /*=>*/ {return checkUpvotes()});
	}
	
	static addLink = function(_type, _link = "") {
		array_push(links, {
			type: _type,
			link: _link,
		})
		
		updateData({ links: json_stringify(links) });
	}
	
	static updateData = function(_data) {
		var _sdata = json_stringify(_data);
		
		asyncCallGroup("social", FirebaseFirestore($"steam/{account_steam_id}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
		});
	}
	
	////- Badges
	
	static badge_get_index_group = function(_group) {
		for( var i = 0, n = array_length(_group); i < n; i++ ) {
			var _i = array_get_index(badgeK, _group[i]);
			if(_i != -1) return _i;
		}
		
		return array_length(badgeK);
	}
	
	static badge_group_check = function(_group) {
		var _bLevels = _group.badges;
		var _index   = badge_get_index_group(_bLevels);
		var _currLv  = _index < array_length(badgeK)? array_get_index(_bLevels, badgeK[_index]) : -1;
		var _nextLv  = -1;
		
		var _bkey = _group.key;
		var _bval = self[$ _bkey] ?? 0;
		
		for( var i = array_length(_group.min_amo) - 1; i >= 0; i-- ) {
			if(_bval >= _group.min_amo[i]) {
				_nextLv = i;
				break;
			}
		}
		
		if(_nextLv > _currLv) badgeK[_index] = _bLevels[_nextLv];
	}
	
	static checkBadge = function() {
		if(data == undefined) getData();
		
		badgeK = is_struct(data)? array_clone(data.badges) : [];
		
		badge_group_check(STEAM_WORKSHOP_DATA.badges_groups.supporter);
		badge_group_check(STEAM_WORKSHOP_DATA.badges_groups.submission_project);
		badge_group_check(STEAM_WORKSHOP_DATA.badges_groups.submission_collection);
		badge_group_check(STEAM_WORKSHOP_DATA.badges_groups.max_upvotes);
		badge_group_check(STEAM_WORKSHOP_DATA.badges_groups.total_upvotes);
		
		badges = array_map(badgeK, function(b) /*=>*/ {return STEAM_WORKSHOP_DATA.badges_data[$ b]});
	}
	
	static updateBadge = function() {
		if(!is_struct(data)) return;
		if(array_equals(data.badges, badgeK)) return;
		
		var _sdata = json_stringify({ badges : json_stringify(badgeK) });
		asyncCallGroup("social", FirebaseFirestore($"steam/{account_steam_id}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
		});
	}

	////- Actions
	
}

function Steam_workshop_profile_banner_edit(_author) : PanelContent() constructor {
	title     = "Change Banner";
	auto_pin  = true;
	author    = _author;
	
	w = ui(596);
	h = ui(320);
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _yy = _y;
		var _w  = sc_content.surface_w;
		var _h  = sc_content.surface_h;
		var _hh = 0;
		
		_y += ui(12);
		draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
		draw_text_add(ui(8), _y, __txt("PXC Sprites"));
		_y += line_get_height() + ui(12);
		
		var _sx = ui(8);
		var _ss = ui(64);
		
		var _banner = author.banner;
		
		for( var i = 0, n = array_length(AUTHOR_BANNER); i < n; i++ ) {
			var _nam = AUTHOR_BANNER[i];
			var _spr = asset_get_index(_nam);
			
			if(i) {
				_sx += _ss + ui(4);
				if(_sx + _ss > _w - ui(8)) {
					_sx = ui(8);
					_y += _ss + ui(4);
				}
			}
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _sx, _y, _sx + _ss, _y + _ss);
			var _cc  = COLORS._main_icon;
			var _aa  = .5 + _hov * .5;
			
			if(_banner.type == 0 && _banner.sprite == _nam) {
				_cc = COLORS._main_accent;
				_aa = 1;
			}
			
			draw_sprite_stretched(_spr, 0, _sx, _y, _ss, _ss);
			draw_sprite_stretched_ext(THEME.box_r2, 1, _sx, _y, _ss, _ss, _cc, _aa);
			
			if(_hov && mouse_lpress(_focus)) {
				author.banner = { type: 0, sprite: _nam };
				author.updateData({ banner: json_stringify(author.banner) });
			}
		}
		
		_y += _ss + ui(16);
		 
		return _y - _yy;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.verify(pw, ph);
		sc_content.draw(px, py, mx - px, my - py);
	}
}