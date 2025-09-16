#region global
	function Steam_workshop_profile_get(_aid) {
		var _a = STEAM_WORKSHOP_DATA.account[$ _aid];
		if(_a) return _a;
		
		var _a = new Steam_workshop_profile(_aid);
		STEAM_WORKSHOP_DATA.account[$ _aid] = _a;
		return _a;
	}
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
	
	banner = { type: 0 }
	banner_path = $"{TEMPDIR}{_sid}_banner.png";
	banner_spr  = undefined;
	
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
	    		banner = data.banner;
    		
	    	if(struct_has(data, "pageContent")) 
	    		pageContent = json_try_parse(data[$ "pageContent"], pageContent);
	    		
			total_upvotes = data[$ "total_upvotes"] ?? 0;
			max_upvotes   = data[$ "max_upvotes"]   ?? 0;
	    	
	    	checkBadge();
	    	updateBadge();
		});
		
		return data;
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
