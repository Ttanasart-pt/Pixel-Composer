#region globals
	globalvar PXC_HUB_DATA;        PXC_HUB_DATA        = undefined;
	globalvar WORKSHOP_FILE_CACHE; WORKSHOP_FILE_CACHE = {};
	
	function PXC_HUB_get_data() {
		asyncCallGroup("social", FirebaseFirestore($"workshops").Query(), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) {
		    	var _errorMessage = _data[? "errorMessage"];
		    	noti_warning(_errorMessage);
		    	return;
		    }
		    
		    var res  = _data[? "value"];
		    var resJ = json_try_parse(res, undefined);
		    
		    PXC_HUB_DATA = resJ;
		});
	}
#endregion

function Steam_workshop_item() constructor {
	ready = false;
	
	static fetchId = function(_fid) {
		file_id = _fid;
		
		asyncCallGroup("steam", steam_ugc_request_item_details(_fid, 30), function(_params, _data) /*=>*/ {
			var _result = _data[? "result"];
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			setMap(_data);
		});

		return self;
	}
	
	static setMap = function(_qData) {
		ready = true;
		
		title               = _qData[? "title"];
		description         = _qData[? "description"]; description = string_trim(description);
		time_created        = _qData[? "time_created"]  ?? 0; time_created_s  = unix_time_to_string(time_created);
		time_uploaded       = _qData[? "time_uploaded"] ?? 0; time_uploaded_s = unix_time_to_string(time_uploaded);
		
		creator_app_id      = _qData[? "creator_app_id"];
		consume_app_id      = _qData[? "consumer_app_id"];
		owner_steam_id      = _qData[? "steam_id_owner"];
		owner_account_id    = _qData[? "account_id_owner"];
		
		visibility          = _qData[? "visibility"];
		banned              = _qData[? "banned"];
		accepted            = _qData[? "accepted_for_use"];
		
		tags                = _qData[? "tags"];
		handle_file         = int64(_qData[? "handle_file"]);
		handle_preview_file = int64(_qData[? "handle_preview_file"]);
		
		file_id             = int64(_qData[? "published_file_id"]);
		file_type           = _qData[? "file_type"];
		
		filename            = _qData[? "filename"];
		filesize            = _qData[? "file_size"];
		preview_file_size   = _qData[? "preview_file_size"];
		url                 = _qData[? "url"];
		
		votes_up            = _qData[? "votes_up"]   ?? 0;
		votes_down          = _qData[? "votes_down"] ?? 0;
		vote_score          = _qData[? "score"]      ?? 0;
		
		author = STEAM_WORKSHOP_DATA.account[$ owner_steam_id];
		if(author == undefined) {
			author = new Steam_workshop_profile(owner_steam_id);
			STEAM_WORKSHOP_DATA.account[$ owner_steam_id] = author;
		}
	
		type = FILE_TYPE.assets;
		tag_type    = "";
		tag_version = "";
		
		for( var i = 0, n = array_length(tags); i < n; i++ ) {
			var _tag = tags[i];
			if(string_starts_with(_tag, "1."))
				tag_version = _tag;
				
			if(_tag == "Project")    { tag_type = _tag; type = FILE_TYPE.project; }
			if(_tag == "Collection") { tag_type = _tag; type = FILE_TYPE.collection; }
		}
		
		preview_path   = $"ugc\\{file_id}.png"
		preview_fpath  = ROAMING_DIRECTORY + preview_path;
		
		return self;
	}
	
	#region previews
		preview_sprite = undefined;
		
		static fetchPreviewSprite = function() {
			if(file_exists_empty(preview_fpath)) {
				preview_sprite = sprite_add(preview_fpath);
				return;
			}
			
			directory_verify(filename_dir(preview_fpath));
			
			preview_sprite = -1;
			asyncCallGroup("steam", steam_ugc_download(handle_preview_file, preview_path), function(_params, _data) /*=>*/ {
				var _result = _data[? "result"];
				var _type   = _data[? "event_type"];
				preview_sprite = -2;
			
				if(_result != ugc_result_success) {
					var errStr = steam_ugc_get_error(_result);
					noti_status($"UGC get thumbnail error {_result}: {errStr}");
					return;
				}
				
				if(file_exists_empty(preview_fpath))
					preview_sprite = sprite_add(preview_fpath);
				else 
					noti_status($"UGC get thumbnail error: File not found {preview_fpath}");
			});
		}
		static getPreviewSprite   = function() {
			if(preview_sprite == undefined) 
				fetchPreviewSprite();
			return preview_sprite;
		}
		
		static drawThumbnail = function(_rx, _ry, _x, _y, _w, _h, _i) {
			var _spr = getPreviewSprite();
			
			if(!sprite_exists(_spr)) return;
			
			gpu_set_stencil_enable(true);
			
			draw_clear_stencil(0);
			gpu_set_stencil_pass(stencilop_replace);
			
			gpu_set_stencil_compare(cmpfunc_greater, 128);
			draw_roundrect_ext(_x, _y, _x + _w - 1, _y + _h - 1, ui(5), ui(5), false);
			
			gpu_set_stencil_compare(cmpfunc_less, 64);
			draw_sprite_stretched(_spr, 0, _x, _y, _w, _h);
			
			gpu_set_stencil_enable(false);
		} 
	#endregion
		
	static getStatus = function() {
		if(struct_has(STEAM_SUBS_IDS, file_id))    return 2;
		if(struct_has(STEAM_SUBSCRIBING, file_id)) return 1;
		return 0;
	}
	
	static getVotesUp   = function() { return votes_up   + struct_try_get(pxc_hub_data, "votes_up");   }
	static getVotesDown = function() { return votes_down + struct_try_get(pxc_hub_data, "votes_down"); }
	
	////- Comments
	
	comments = [];
	comment_fetched  = false;
	comment_fetching = false;
	
	static fetchComments = function() {
		comment_fetching = true;
		comment_fetched  = true;
		
		asyncCallGroup("social", FirebaseFirestore($"comments").Where("parent_id", "==", string(file_id)).Query(), function(_params, _data) /*=>*/ {
			comment_fetching = false;
			if (_data[? "status"] != 200) { print($"Fetch comment error {_data[? "errorMessage"]}"); return; }
		
		    var res  = _data[? "value"];
		    var resJ = json_try_parse(res, undefined);
		    if(resJ == undefined) return;
		    
		    var _keyy = struct_get_names(resJ);
		    comments  = array_create(array_length(_keyy));
		    
		    for( var i = 0, n = array_length(_keyy); i < n; i++ ) {
		    	comments[i] = resJ[$ _keyy[i]];
		    	comments[i].document = _keyy[i];
		    }
		    
			array_sort(comments, function(a,b) /*=>*/ {return sign(b.creation_time - a.creation_time)});
			
			if(pxc_hub_data != undefined) {
				var _hub_comment_count = pxc_hub_data[$ "comment_count"] ?? 0;
				var _comment_count     = array_length(comments);
				pxc_hub_data[$ "comment_count"] = _comment_count;
				
				if(_hub_comment_count != _comment_count) 
					updateHUB({ comment_count: _comment_count });
			}
		});
	}
	
	static deleteComment = function(_comment) {
		var _cid = _comment.document;
		
		asyncCallGroup("social", FirebaseFirestore($"comments/{_cid}").Delete(), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print($"Delete comment error {_data[? "errorMessage"]}"); return; }
		});
		
		array_remove(comments, _comment);
		
		if(pxc_hub_data != undefined) {
			pxc_hub_data[$ "comment_count"] = array_length(comments);
			updateHUB({ comment_count: array_length(comments) });
		}
	}
	
	////- Draw
	
	static draw = function(_panel, _rx, _ry, _x0, _y0, _x1, _y1, _m, _hover, _focus, _title = true) {
		var _th = line_get_height(f_p2b) + ui(4) + line_get_height(f_p4);
		var _cw = _x1 - _x0;
		var _ch = _y1 - _y0;
		
		var _fid  = file_id;
		var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1);
		var _spr  = getPreviewSprite();
		var _own  = struct_has(STEAM_SUBS_IDS, _fid);
		var _addi = struct_has(STEAM_SUBSCRIBING, _fid);
		
		var _xc = (_x0 + _x1) / 2;
		var _yc = (_y0 + _y1) / 2;
		
		if(_spr == -1) {
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y0, _cw, _ch, c_white, 1);
			draw_sprite_ui(THEME.loading, 0, _xc, _yc, 1, 1, current_time / 2, COLORS._main_icon, 1);
			
		} else 
			drawThumbnail(_rx, _ry, _x0, _y0, _cw, _ch, 0);
		if(_hov) draw_sprite_stretched_add(THEME.box_r5, 1, _x0, _y0, _cw, _ch, c_white, .5);
		
		#region badges
			var _ox = _x0 + ui(14);
			var _oy = _y1 - ui(14);
			var _subHov = _hover && point_in_rectangle(_m[0], _m[1], _ox - ui(8), _oy - ui(8), _ox + ui(8), _oy + ui(8));
			if(_subHov) _hov = false;
			
			if(_own) {
				if(_subHov) {
					draw_sprite_ui(THEME.cross_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_value_negative, 1);
					TOOLTIP = __txt("Unsubscribe");
					
					if(mouse_lpress(_focus))
						UGC_unsubscribe_item(_fid);
					
				} else 
					draw_sprite_ui(THEME.accept_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_icon, .8);
				
			} else if(_addi) {
				draw_sprite_ui(THEME.loading_s, 0, _ox, _oy, .75, .75, current_time / 2, COLORS._main_icon, .8);
				
			} else {
				draw_sprite_ui(THEME.add_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_value_positive, .8 + _subHov * .2);
				if(_subHov) {
					TOOLTIP = __txt("Subscribe");
					
					if(mouse_lpress(_focus))
						UGC_subscribe_item(_fid);
				}
			}
			
			var _hubStat = getHUBStatus();
			
			if(_hubStat) {
				_ox += ui(20);
				var _subHov = _hover && point_in_rectangle(_m[0], _m[1], _ox - ui(8), _oy - ui(8), _ox + ui(8), _oy + ui(8));
				if(_subHov) {
					_hov = false;
					TOOLTIP = "PXC hub connected";
				}
				
				draw_sprite_ui(THEME.pxc_hub, 0, _ox, _oy, 1, 1, 0, COLORS._main_accent, .8 + _subHov * .2);
			}
		#endregion
			
		if(_hov) {
			if(!_panel.hold_tooltip) TOOLTIP = self;
			
			if(mouse_rpress(_focus)) {
				menuCall("steam_workshop_item", [
					menuItem(__txt("Open in browser"), function(_fid) /*=>*/ {
						steam_activate_overlay_browser($"https://steamcommunity.com/sharedfiles/filedetails/?id={_fid}")
					}, THEME.globe).setParam(_fid)
				]);
				
				_panel.hold_tooltip = true;
			}
			
			if(_own) {
				if(mouse_lpress(_focus)) {
					_panel.file_dragging  = self;
					_panel.file_drag_x    = mouse_mx;
					_panel.file_drag_y    = mouse_my;
				}
				
				if(DOUBLE_CLICK && type == FILE_TYPE.project) {
					var _map  = ds_map_create();
					var _info = steam_ugc_get_item_install_info(_fid, _map);
						
					if(_info) {
						var _dir = _map[? "folder"];
						var _fil = file_find_first(_dir + "/*.pxc", 0); file_find_close();
						var _pat = filename_combine(_dir, _fil);
						
						LOAD_PATH(_pat, true);
					}
					
					ds_map_destroy(_map);
				}
			}
		}
		
		if(_title) {
			var _vote_up   = getVotesUp();
			var _vote_down = getVotesDown();
			var _vote_totl = _vote_up + _vote_down;
			
			var _vy = _y1 + ui(4);
			var _vx = _x0;
			var _vw = _cw;
			var _vh = ui(2);
			
			if(_vote_totl == 0) {
				draw_set_color(COLORS._main_icon);
				draw_set_alpha(.5);
				draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
				draw_set_alpha(1);
				
			} else {
				var _vote_rat = _vote_up / _vote_totl;
				
				draw_set_color(COLORS._main_value_negative);
				draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
				
				draw_set_color(COLORS._main_value_positive);
				draw_rectangle(_vx, _vy, _vx + _vw * _vote_rat, _vy + _vh, false);
			}
			
			var _ty = _vy + ui(6);
			
			var _scis = gpu_get_scissor();
			gpu_set_scissor(_x0, _ty, _cw, _th);
			draw_set_color(COLORS.panel_bg_clear_inner);
			draw_rectangle(_x0, _ty, _x1, _ty + _th, false);
			
			draw_set_text(f_p2b, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x0, _ty, title);
			_ty += line_get_height(f_p2b);
			
			var _hovAuthor = _hover && point_in_rectangle(_m[0], _m[1], _x0, _ty - ui(2), _x1, _ty + line_get_height(f_p4, 4));
			var _author    = author.getName();
			
			var cc = _hovAuthor? COLORS._main_accent : CDEF.main_mdwhite;
			draw_set_text(f_p4, fa_left, fa_top, cc);
			draw_text_add(_x0, _ty, _author);
			gpu_set_scissor(_scis);
			
			if(author.getPatreon()) {
				var _tx1 = _x0 + string_width(_author) + ui(4);
				draw_sprite_ui(THEME.patreon_supporter, 0, _tx1, _ty + _ui(8), .65, .65, 0, COLORS._main_icon_dark, 1);
	            draw_sprite_ui(THEME.patreon_supporter, 1, _tx1, _ty + _ui(8), .65, .65, 0, COLORS._main_accent, 1);
			}
			
			if(_hovAuthor && mouse_lpress(_focus))
				_panel.doViewAuthor = owner_steam_id;
		}
	}
	
	static drawTooltip = function() {
		var _pd = ui(10);
		var ww  = ui(320);
		var dw  = ww;
		var hh  = 0;
		
		var _aut = author.getName();
		
		draw_set_font(f_h5);
		hh += string_height_ext(title, -1, ww) - ui(4);
		dw  = max(dw, string_width_ext(title, -1, ww));
		
		draw_set_font(f_p2);
		hh += string_height_ext(_aut, -1, ww);
		dw  = max(dw, string_width_ext(_aut, -1, ww));
		
		if(description != "") {
			draw_set_font(f_p2);
			hh += string_height_ext(description, -1, ww);
			dw  = max(dw, string_width_ext(description, -1, ww));
		}
		
		if(array_length(tags)) {
			draw_set_font(f_p2);
			hh += ui(8);
			var tx = 0;
			var lh = line_get_height(f_p2, ui(4));
			var th = lh;
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var _ww = string_width(tags[i]) + ui(16);
				
				if(tx + _ww + ui(2) > ww - ui(16)) {
					tx = 0;
					th += lh + ui(2);
				}
				tx += _ww + ui(2);
			}
			
			hh += th;
		}
		
		////////////////////////////////////////////////////////////
		
		var mx = min(mouse_mxs + _pd, WIN_W - (dw + _pd * 2));
		var my = min(mouse_mys + _pd, WIN_H - (hh + _pd * 2));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, dw + _pd * 2, hh + _pd * 2);
		draw_sprite_stretched(THEME.textbox, 0, mx, my, dw + _pd * 2, hh + _pd * 2);
		
		////////////////////////////////////////////////////////////
		
		var tx = mx + _pd;
		var ty = my + ui(8);
		
		draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
		draw_text_ext(tx, ty, title, -1, ww);
		ty += string_height_ext(title, -1, ww) - ui(4);
		
		#region votes
			var cx = mx + _pd + dw - ui(8);
			var cy = my + ui(24);
			
			var _vote_down = getVotesDown();
			draw_sprite_ui(THEME.vote_down, 0, cx, cy, .5, .5, 0, COLORS._main_value_negative);
			cx -= ui(10);
			
			draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
			draw_text(cx, cy - ui(2), _vote_down);
			cx -= string_width(_vote_down) + ui(4);
			
			cx -= ui(12);
			var _vote_up = getVotesUp();
			draw_sprite_ui(THEME.vote_up, 0, cx, cy, .5, .5, 0, COLORS._main_value_positive);
			cx -= ui(10);
			
			draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
			draw_text(cx, cy - ui(2), _vote_up);
			cx -= string_width(_vote_up) + ui(4);
			
			var _comments = pxc_hub_data == undefined? 0 : pxc_hub_data.comment_count;
			if(_comments) {
				cx -= ui(12);
				draw_sprite_ui(THEME.message_24, 0, cx, cy, .6, .6, 0, COLORS._main_icon);
				cx -= ui(10);
				
				draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
				draw_text(cx, cy - ui(2), _comments);
			}
		#endregion
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_ext(tx, ty, _aut, -1, ww);
		ty += string_height_ext(_aut, -1, ww);
		
		if(description != "") {
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
			draw_text_ext(tx, ty, description, -1, ww);
			ty += string_height_ext(description, -1, ww);
		}
		
		if(array_length(tags)) {
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			ty += ui(8);
			var tx = 0;
			var hh = line_get_height(f_p2, ui(4));
			
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var _ww = string_width(tags[i]) + ui(16);
				if(tx + _ww + ui(2) > ww - ui(16)) {
					tx = 0;
					ty += hh + ui(2);
				}
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, mx + ui(8) + tx, ty, _ww, hh, COLORS._main_icon, 1);
				draw_text(mx + ui(8) + tx + ui(8), ty + hh / 2, tags[i]);
				
				tx += _ww + ui(2);
			}
		}
		
	}
	
	////- PXC Hub
	
	pxc_hub_link = undefined;
	pxc_hub_data = undefined;
	
	static getHUBStatus = function() {
		if(PXC_HUB_DATA == undefined) pxc_hub_link = 0;
		else pxc_hub_link = struct_has(PXC_HUB_DATA, string(file_id))? 1 : -1;
			
		if(pxc_hub_link == 1) {
			pxc_hub_data = PXC_HUB_DATA[$ string(file_id)];
			pxc_hub_data.votes_up      = real(pxc_hub_data[$ "votes_up"]      ?? 0);
			pxc_hub_data.votes_down    = real(pxc_hub_data[$ "votes_down"]    ?? 0);
			pxc_hub_data.comment_count = real(pxc_hub_data[$ "comment_count"] ?? 0);
		}
		
		return pxc_hub_link;
	}
	
	static linkHUB = function() {
		if(pxc_hub_link == 1) return;
		
		pxc_hub_link = 0;
		pxc_hub_data = {
			file_id:   string(file_id),
			votes_down: 0,
			votes_up:   0,
			
			enable_comment: true, 
		};
		
		PXC_HUB_DATA[$ string(file_id)] = pxc_hub_data;
		var _sdata = json_stringify(pxc_hub_data);
		
		asyncCallGroup("social", FirebaseFirestore($"workshops/{file_id}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
			
			pxc_hub_link = 1;
		});
	}
	
	static HUBVote = function(_vote) {
		if(USER_DATA == undefined) return;
		
		var _fid = string(file_id);
		
		var currVote = USER_DATA.voteData[$ _fid];
		     if(currVote ==  1) { pxc_hub_data.votes_up--;   }
		else if(currVote == -1) { pxc_hub_data.votes_down--; }	
		
		if(currVote == _vote) {
			USER_DATA.voteData[$ _fid] = 0;
			
		} else {
			     if(_vote ==  1) { pxc_hub_data.votes_up++;     }
			else if(_vote == -1) { pxc_hub_data.votes_down++;   }
			
			USER_DATA.voteData[$ _fid] = _vote;
		}
		
		USER_DATA.update();
		
		var _vote_id = md5_string_unicode($"{_fid},{STEAM_ID}");
		var _sdata = json_stringify({
			post_id:   _fid,
			user_id:   string(STEAM_ID), 
			vote_type: USER_DATA.voteData[$ _fid],
		});
		
		asyncCallGroup("social", FirebaseFirestore($"votes/{_vote_id}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
		});
		
		var _sdata = json_stringify({
			votes_up:   pxc_hub_data.votes_up,
			votes_down: pxc_hub_data.votes_down,
		});
		
		asyncCallGroup("social", FirebaseFirestore($"workshops/{_fid}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
		});
	} 
	
	static updateHUB = function(_data) {
		var _sdata = json_stringify(_data);
		
		asyncCallGroup("social", FirebaseFirestore($"workshops/{string(file_id)}").Update(_sdata), function(_params, _data) /*=>*/ {
			if (_data[? "status"] != 200) { print($"update user data error {_data[? "errorMessage"]}"); return; }
		});
	}
	
	////- Actions
	
	static refresh = function() {
		if(sprite_exists(preview_sprite)) sprite_delete(preview_sprite);
		preview_sprite = undefined;
	}
	
	static toString = function() /*=>*/ {return $"{title}: {vote_score}"};
	
}

function HUB_link_file_id(_fid) {
	_fid = string(_fid);
	
	var pxc_hub_data = {
		file_id:   _fid,
		votes_down: 0,
		votes_up:   0,
	};
	
	var _sdata = json_stringify(pxc_hub_data);
	
	asyncCallGroup("social", FirebaseFirestore($"workshops/{_fid}").Update(_sdata), function(_params, _data) /*=>*/ {
		if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
	});
}

function Steam_workshop_get_file(_fid) {
	if(struct_has(WORKSHOP_FILE_CACHE, _fid))
		return WORKSHOP_FILE_CACHE[$ _fid];
	
	var _item = new Steam_workshop_item().fetchId(_fid);
	WORKSHOP_FILE_CACHE[$ _fid] = _item;
	return _item;
}