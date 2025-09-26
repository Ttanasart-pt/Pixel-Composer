#region global
	globalvar STEAM_WORKSHOP_DATA; STEAM_WORKSHOP_DATA = {};
	STEAM_WORKSHOP_DATA.account   = {};
	
	STEAM_WORKSHOP_DATA.badges_data = {
		developer:            { name: "Developer",            spr: s_badge_developer,            subtitle: "PXC developer",                      rank: 100 }, 
		
		supporter:            { name: "Supporter",            spr: s_badge_supporter,            subtitle: "Patreon supporter",                  rank: 2 }, 
		supporter_5:          { name: "Supporter 5",          spr: s_badge_supporter_5,          subtitle: "Tier 2 Patreon supporter",           rank: 3 }, 
		supporter_10:         { name: "Supporter 10",         spr: s_badge_supporter_10,         subtitle: "Tier 3 Patreon supporter",           rank: 4 }, 
		
		first_time_projector: { name: "First Project",        spr: s_badge_first_time_projector, subtitle: "Upload your first project",          rank: 0 }, 
		project_uploader:     { name: "Content Creator",      spr: s_badge_project_uploader,     subtitle: "Upload 10 projects",                 rank: 1 }, 
		project_creator:      { name: "Contractor",           spr: s_badge_project_creator,      subtitle: "Upload 25 projects",                 rank: 2 }, 
		compositor:           { name: "Compositor",           spr: s_badge_compositor,           subtitle: "Upload 50 projects",                 rank: 3 }, 
		nodemaker:            { name: "Nodemaker",            spr: s_badge_nodemaker,            subtitle: "Upload 100 projects",                rank: 4 }, 
		
		first_time_collector: { name: "First Collection",     spr: s_badge_first_time_collector, subtitle: "Upload your first collection",       rank: 1 }, 
		collection_uploader:  { name: "Collection Uploader",  spr: s_badge_collection_uploader,  subtitle: "Upload 10 collections",              rank: 1 }, 
		collector:            { name: "Collector",            spr: s_badge_collector,            subtitle: "Upload 25 collections",              rank: 2 }, 
		constructor:          { name: "Constructor",          spr: s_badge_constructor,          subtitle: "Upload 50 collections",              rank: 3 }, 
		collectioneer:        { name: "Collectathon",         spr: s_badge_collectioneer,        subtitle: "Upload 100 collections",             rank: 4 }, 
		
		good_works:           { name: "Good Works",           spr: s_badge_good_works,           subtitle: "Gain 10 upvotes in one submission",  rank: 2 }, 
		banger:               { name: "Banger",               spr: s_badge_banger,               subtitle: "Gain 100 upvotes in one submission", rank: 4 }, 
		
		well_liked:           { name: "Well Liked",           spr: s_badge_well_liked,           subtitle: "Gain 25 total upvotes",              rank: 2 }, 
		influencer:           { name: "Influencer",           spr: s_badge_influencer,           subtitle: "Gain 100 total upvotes",             rank: 3 }, 
		nodemaster:           { name: "Talk of the Town",     spr: s_badge_nodemaster,           subtitle: "Gain 500 total upvotes",             rank: 4 }, 
		
		trophy_holder:        { name: "Trophy Holder",        spr: s_badge_trophy_holder,        subtitle: "Won 1 contest",                      rank: 3 }, 
		champion:             { name: "Champion",             spr: s_badge_champion,             subtitle: "Won 10 contests",                    rank: 4 }, 
		
		fly_swatter:          { name: "Fly Swatter",          spr: s_badge_fly_swatter,          subtitle: "Report your first bug",              rank: 1 }, 
		tester:               { name: "Tester",               spr: s_badge_tester,               subtitle: "Report 10 bugs",                     rank: 2 }, 
		debugger:             { name: "Debugger",             spr: s_badge_debugger,             subtitle: "Report 50 bugs",                     rank: 3 }, 
		thank_you:            { name: "Thank You",            spr: s_badge_thank_you,            subtitle: "Report 100 bugs",                    rank: 4 }, 
		
	};
	
	STEAM_WORKSHOP_DATA.badges_groups = {
		supporter:             {
			badges: [ "supporter", "supporter_5", "supporter_10" ],
			key: "supporter",
			min_amo: [ 1, 2, 3,  ], 
		}, 
		submission_project:    {
			badges: [ "first_time_projector", "project_uploader", "project_creator", "compositor", "nodemaker" ],
			key: "submission_project",
			min_amo: [ 1, 10, 20, 50, 100 ], 
		}, 
		submission_collection: {
			badges: [ "first_time_collector", "collection_uploader", "collector", "constructor", "collectioneer", ],
			key: "submission_collection",
			min_amo: [ 1, 10, 20, 50, 100 ], 
		}, 
		max_upvotes:           {
			badges: [ "good_works", "banger" ],
			key: "max_upvotes",
			min_amo: [ 10, 100 ], 
		}, 
		total_upvotes:         {
			badges: [ "well_liked", "influencer", "nodemaster" ],
			key: "total_upvotes",
			min_amo: [ 25, 100, 500 ], 
		}, 
		contest_won:           {
			badges: [ "trophy_holder", "champion" ],
			key: "contest_won",
			min_amo: [ 1, 10 ], 
		}, 
		bug_report:            {
			badges: [ "fly_swatter", "tester", "debugger", "thank_you" ],
			key: "bug_report",
			min_amo: [ 1, 10, 50, 100 ], 
		}, 
	}        
#endregion

function Panel_Steam_Workshop() : PanelContent() constructor {
	title     = "Steam Workshop";
	auto_pin  = true;
	
	ds_map_info = ds_map_create();
	contentPage = 0;
	current_url = "";
	
	PXC_HUB_get_data();
	
	#region dimension
		w       = ui(960);
		h       = ui(640);
		min_w   = ui(640);
		min_h   = ui(480);
		padding = ui(6);
		
		grid_size    = ui(120);
		grid_size_to = ui(120);
	#endregion
	
	#region sorting filter
		sort_type      = 1;
		sort_trend_day = 0;
		match_type     = 0;
		
		own_filter   = true;
		custom_tags  = [];
		tag_filter   = [];
		ver_filter   = [];
		type_filter  = [];
		hold_filter  = 0;
		
		search_string    = "";
		author_search_id = undefined;
		
		type_strings   = [ "Project", "Collection" ];
		sort_types     = __txts([ "Sort by Vote", "Sort by Trending", "Sort by Creation Date" ]);
		sort_days      = [ "D", "W", "M", "Y" ];
		sort_days_tool = __txts([ "Today",  "This Week",  "This Month",  "This Year" ]);
		
		tb_search = textBox_Text(function(s) /*=>*/ { 
			if(page == 0 || item_viewing != undefined)
				navigate({type: 0, page: 1});
			search_string = s; 
			filterFiles(); 
			
		}).setAutoUpdate().setEmpty().setAlign(fa_left).setVAlign(fa_center);
		
		page_goto = undefined;
	#endregion
	
	#region page content
		querying    = false;
		
		item_per_page = 30;
		page       = 0;
		pageTotal  = 1;
		pageIndex  = [];
		
		queryingFiles = 0;
		allFiles     = [];
		displayFiles = [];
		
		fileTrendWeekly = [];
		fileRecents     = [];
		filePopular     = [];
		
		file_dragging  = undefined;
		file_drag_x    = 0;
		file_drag_y    = 0;
		
		hold_tooltip   = false;
	#endregion 
	
	#region page navigation
		current_page = { type: 0, page: 0 };
		history_undo = [];
		history_redo = [];
		
		static navigate = function(_page, _undo = false) {
			if(!_undo) {
				array_push(history_undo, current_page);
				history_redo = [];
			}
			
			current_page = _page;
			
			switch(_page.type) {
				case 0 : 
				case 1 : 
				case 2 : 
				case 3 : 
					contentPage      = _page.type;
					page             = _page.page;
					item_viewing     = _page[$ "item_viewing"]     ?? undefined;
					author_search_id = _page[$ "author_search_id"] ?? undefined;
					
					if(has(_page, "sort_type"      )) sort_type      = _page.sort_type;
					if(has(_page, "sort_trend_day" )) sort_trend_day = _page.sort_trend_day;
					
					if(has(_page, "tag_filter" )) tag_filter  = _page.tag_filter;
					if(has(_page, "ver_filter" )) ver_filter  = _page.ver_filter;
					if(has(_page, "type_filter")) type_filter = _page.type_filter;
					
					if(contentPage == 2) queryAuthorPage();
					queryFiles();
					break;
					
				case "author" :
					var _author = _page.author;
					var _a = STEAM_WORKSHOP_DATA.account[$ _author];
					if(_a == undefined) {
						var _a = new Steam_workshop_profile(_author);
						STEAM_WORKSHOP_DATA.account[$ _author] = _a;
					}
					
					author_search_id = _author; 
					sort_type        = _page[$ "sort_type"]        ?? 1;
					sort_trend_day   = _page[$ "sort_trend_day"]   ?? 0;
					page             = _page[$ "page"]             ?? 0;
					item_viewing     = undefined;
					
					sc_content_author.setScroll(0);
					queryAuthorPage();
					queryFiles();
					break;
					
				case "file"   : 
					item_viewing = _page.file; 
					sc_content_item.setScroll(0);
					break;
					
				case "fileid" : 
					item_viewing = Steam_workshop_get_file(_page.fileid); 
					sc_content_item.setScroll(0);
					break;
			}
		}
		
		static historyBackward = function() {
			if(array_empty(history_undo)) return;
			
			array_push(history_redo, current_page);
			var _page = array_pop(history_undo);
			navigate(_page, true);
		}
		
		static historyForward = function() {
			if(array_empty(history_redo)) return;
			
			array_push(history_undo, current_page);
			var _page = array_pop(history_redo);
			navigate(_page, true);
		}
		
		static pageRefresh = function() {
			var _dir = ROAMING_DIRECTORY + "ugc";
			directory_clear(_dir);
			var _files = struct_get_names(WORKSHOP_FILE_CACHE);
			for( var i = 0, n = array_length(_files); i < n; i++ )
				WORKSHOP_FILE_CACHE[$ _files[i]].refresh();
			
			queryFiles();
		}
		
		function setPage(_page = 1) {
			sc_content.setScroll(0);
			sc_content_home.setScroll(0);
			
			if(_page == 0) queryHomePage();
			
			current_page.page = _page;
			page = _page;
			setPageIndices();
		}
		
		function setPageIndices() {
			pageIndex = [];
			if(contentPage == 0 || contentPage == 2)
				pageIndex[0] = 0;
			if(pageTotal == 0) return;
			
			for( var i = 1; i <= min(3, pageTotal); i++ ) 
				array_push(pageIndex, i);
			
			for( var i = max(1, page - 1); i <= min(page + 1, pageTotal); i++ ) 
				array_push(pageIndex, i);
			
			for( var i = max(1, pageTotal - 3); i <= pageTotal; i++ ) 
				array_push(pageIndex, i);
			
			pageIndex = array_unique(pageIndex);
			array_sort(pageIndex, true);
			
			for( var i = 1, n = array_length(pageIndex); i < n; i++ ) {
				if(pageIndex[i] - pageIndex[i-1] > 1) {
					array_insert(pageIndex, i, -1);
					i++;
				}
			}
		}
	
	#endregion 
	
	#region author
		authorPopular = [];
		authorRecents = [];
		currentAuthor = undefined;
		doViewAuthor  = undefined;
		
		subtitle_length_limit = 128;
		
		tb_author_subtitle_updating = false;
		tb_author_subtitle = textArea_Text(function(s) /*=>*/ { 
			tb_author_subtitle_updating = true;
			var _l = string_length(s);
			if(_l >= subtitle_length_limit) s = string_copy(s, 1, subtitle_length_limit);
			
			var _sdata = json_stringify({ subtitle : s, });
			
			asyncCallGroup("social", FirebaseFirestore($"steam/{STEAM_ID}").Update(_sdata), function(_params, _data) /*=>*/ {
				tb_author_subtitle_updating = false;
				if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
			});
			
			if(currentAuthor == undefined) return;
			currentAuthor.getData().subtitle = s;
			
		}).setFont(f_p2);
		
		profile_offset_to = ui(32);
		profile_offset    = profile_offset_to;
		
		badge_editing  = false;
		badge_dragging = undefined;
		
		link_dragging  = undefined;
		
		menu_add_link_x = 0;
		menu_add_link_y = 0;
		menu_add_link   = [
			menuItem(__txt("Steam Workshop"), function() /*=>*/ {return currentAuthor.addLink("steam")}, THEME.steam_invert_24 ), 
			menuItem(__txt("Twitter"),  function(p) /*=>*/ { 
				textboxCall("", function(t) /*=>*/ {return currentAuthor.addLink("twitter",  t)}, menu_add_link_x, menu_add_link_y).setLabel("@"); 
			}, THEME.twitter  ), 
			
			menuItem(__txt("Bluesky"),  function(p) /*=>*/ { 
				textboxCall("", function(t) /*=>*/ {return currentAuthor.addLink("bluesky",  t)}, menu_add_link_x, menu_add_link_y).setLabel("@"); 
			}, THEME.bluesky  ), 
			
			menuItem(__txt("Mastodon"), function(p) /*=>*/ { 
				textboxCall("", function(t) /*=>*/ {return currentAuthor.addLink("mastodon", t)}, menu_add_link_x, menu_add_link_y).setLabel("@"); 
			}, THEME.mastodon ), 
			
			menuItem(__txt("Youtube"),  function(p) /*=>*/ { 
				textboxCall("", function(t) /*=>*/ {return currentAuthor.addLink("youtube",  t)}, menu_add_link_x, menu_add_link_y).setLabel("@"); 
			}, THEME.youtube  ), 
			
			menuItem(__txt("Link"),     function(p) /*=>*/ { 
				textboxCall("", function(t) /*=>*/ {return currentAuthor.addLink("url",      t)}, menu_add_link_x, menu_add_link_y); 
			}, THEME.link     ), 
			
		];
		
		banner_uploading = false;
		menu_banner_edit = [
			menuItem(__txt("Change Banner") + "...", function() /*=>*/ {return dialogPanelCall(new Steam_workshop_profile_banner_edit(currentAuthor))}), 
			menuItem(__txt("Remove"), function() /*=>*/ {
				currentAuthor.banner = { type: -1 }
				currentAuthor.updateData({ banner: json_stringify(currentAuthor.banner) });
			}, THEME.cross_16), 
		];
		
		profile_uploading = false;
		menu_profile_edit = [
			__txt("Profile image uses data from Steam."), 
			menuItem(__txt("Set Profile Graph"), function() /*=>*/ {
				var _path = get_open_filename_compat("Pixel Composer collection (.pxcc)|*.pxcc", "", "Open", DIRECTORY + "Collections");
				if(!file_exists_empty(_path)) return;
				
				var _str = file_read_all(_path);
				currentAuthor.profile_graph     = _str;
				currentAuthor.profile_graph_str = json_try_parse(_str);
				
				if(currentAuthor.profile_graph_runner) {
					currentAuthor.profile_graph_runner.cleanup();
					currentAuthor.profile_graph_runner = undefined;
				}
				
				currentAuthor.updateData({ profile_graph: currentAuthor.profile_graph });
				
			}), 
			menuItem(__txt("Remove Profile Graph"), function() /*=>*/ {
				currentAuthor.profile_graph     = "";
				currentAuthor.profile_graph_str = undefined;
				
				if(currentAuthor.profile_graph_runner) {
					currentAuthor.profile_graph_runner.cleanup();
					currentAuthor.profile_graph_runner = undefined;
				}
				
				currentAuthor.updateData({ profile_graph: currentAuthor.profile_graph });
			}, THEME.cross_16), 
		];
	#endregion
	
	#region item view 
		item_viewing = undefined;
		
		item_title_editing  = false;
		item_title_updating = false;
		tb_item_title = textBox_Text(function(s) /*=>*/ { 
			if(item_viewing == undefined) return;
			if(item_viewing.title == s) return;
			
			item_viewing.title  = s;
			item_title_updating = true;
			
			var _updateHandle = steam_ugc_start_item_update(STEAM_APP_ID, item_viewing.file_id);
			steam_ugc_set_item_title(_updateHandle, s);
			asyncCallGroup("steam", steam_ugc_submit_item_update(_updateHandle, "Update title"), function(_params, _data) /*=>*/ {
				item_title_updating = false;
				var _result = _data[? "result"];
			
				if(_result != ugc_result_success) {
					var errStr = steam_ugc_get_error(_result);
					noti_status($"UGC update error {_result}: {errStr}");
					querying = false;
					return;
				}
			})
		}).setFont(f_h5).setVAlign(fa_center);
		
		item_description_editing  = false;
		item_description_updating = false;
		tb_item_description = textArea_Text(function(s) /*=>*/ { 
			if(item_viewing == undefined) return;
			if(item_viewing.description == s) return;
			
			item_viewing.description  = s;
			item_description_updating = true;
			
			var _updateHandle = steam_ugc_start_item_update(STEAM_APP_ID, item_viewing.file_id);
			steam_ugc_set_item_description(_updateHandle, s);
			asyncCallGroup("steam", steam_ugc_submit_item_update(_updateHandle, "Update description"), function(_params, _data) /*=>*/ {
				item_description_updating = false;
				var _result = _data[? "result"];
			
				if(_result != ugc_result_success) {
					var errStr = steam_ugc_get_error(_result);
					noti_status($"UGC update error {_result}: {errStr}");
					querying = false;
					return;
				}
			})
		}).setFont(f_p2);
		
		item_tags_updating = false;
		function onSetTag(_tags) {
			if(item_viewing == undefined) return;
			item_tags_updating = true;
			
			var _updateHandle = steam_ugc_start_item_update(STEAM_APP_ID, item_viewing.file_id);
			steam_ugc_set_item_tags(_updateHandle, _tags);
			
			asyncCallGroup("steam", steam_ugc_submit_item_update(_updateHandle, "Update title"), function(_params, _data) /*=>*/ {
				item_tags_updating = false;
				var _result = _data[? "result"];
			
				if(_result != ugc_result_success) {
					var errStr = steam_ugc_get_error(_result);
					noti_status($"UGC update error {_result}: {errStr}");
					querying = false;
					return;
				}
			});
		}
		
		comment_text       = "";
		comment_submitting = false;
		
		tb_comment = textArea_Text(function(s) /*=>*/ { 
			if(item_viewing == undefined) return;
			comment_text = s;
		}).setFont(f_p2);
		
		function submitComment() {
			tb_comment.deactivate();
			
			if(item_viewing == undefined) return;
			if(comment_text == "") return;
			
			comment_submitting = true;
			
			var comment_id = UUID_generate(); 
			var _sdata = json_stringify({
				author_id  : string(STEAM_ID),
				comment_id : comment_id,
				parent_id  : string(item_viewing.file_id),
				content    : comment_text,
				
				creation_time : get_unix_time(), 
			});
			
			asyncCallGroup("social", FirebaseFirestore($"comments/{comment_id}").Update(_sdata), function(_params, _data) /*=>*/ {
				comment_submitting = false;
				
				if (_data[? "status"] != 200) { print($"comment error {_data[? "errorMessage"]}"); return; }
				
				comment_text = "";
				item_viewing.fetchComments();
			});
		}
		
	#endregion
	
	function sortFiles() {
		switch(sort_type) {
			case 0 : array_sort(allFiles, function(a,b) /*=>*/ {return sign(b.getVotesUp() - a.getVotesUp())}); break;
			case 2 : array_sort(allFiles, function(a,b) /*=>*/ {return sign((b[$ "time_created"] ?? 0) - (a[$ "time_created"] ?? 0))}); break;
		}
	}
	
	function filterFiles(_reset = true, _offset = 0) {
		if(_reset) {
			sc_content.setScroll(0);
			displayFiles = [];
			custom_tags  = [];
		}
		
		var _tag_use  = !array_empty(tag_filter);
		var _type_use = !array_empty(type_filter);
		var _ver_use  = !array_empty(ver_filter);
		var _search   = string_lower(search_string);
		
		for( var i = _offset, n = array_length(allFiles); i < n; i++ ) {
			var _file = allFiles[i];
			
			if(contentPage == 2) {
				var _match = STEAM_ID == _file.owner_steam_id;
				if(!_match) continue;
			}
			
			if(_tag_use) {
				var _match = array_overlap(tag_filter, _file.tags);
				if(!_match) continue;
			}
			
			if(_type_use) {
				var _match = array_overlap(type_filter, _file.tags);
				if(!_match) continue;
			}
			
			if(_ver_use) {
				var _match = false;
				for( var j = 0, m = array_length(ver_filter); j < m; j++ ) {
					if(string_starts_with(_file.tag_version, ver_filter[j]))
						_match = true;
				}
				if(!_match) continue;
			}
			
			if(search_string != "") {
				var _match = string_pos(_search, string_lower(_file.title)) != 0;
				if(!_match) continue;
			}
			
			if(author_search_id != undefined) {
				var _match = _file.owner_steam_id == author_search_id;
				if(!_match) continue;
			}
			
			if(!own_filter) {
				var _owned = struct_has(STEAM_SUBS_IDS, _file.file_id);
				if(_owned) continue;
			}
			
			custom_tags = array_union(custom_tags, _file.tags_content);
			array_push(displayFiles, _file);
		}
		
		custom_tags = array_substract(custom_tags, META_TAGS);
		array_sort(custom_tags, true);
		
		displayFiles = array_unique(displayFiles);
		pageTotal    = ceil(array_length(displayFiles) / item_per_page);
		setPageIndices();
	}
	
	function queryAllFiles(_page = 1, _files = allFiles) {
		var _type  = ugc_query_RankedByVote;
		
		switch(sort_type) {
			case 0 : _type = ugc_query_RankedByVote;            break;
			case 1 : _type = ugc_query_RankedByTrend;           break;
			case 2 : _type = ugc_query_RankedByPublicationDate; break;
		}
		
		var _que = steam_ugc_create_query_all(_type, ugc_match_Items, _page);
		steam_ugc_query_set_allow_cached_response(_que, true);
		
		if(sort_type == 1) {
			var _days = 1;
			switch(sort_trend_day) {
				case 0 : _days = 1;   break;
				case 1 : _days = 7;   break;
				case 2 : _days = 30;  break;
				case 3 : _days = 365; break;
			}
			
			steam_ugc_query_set_ranked_by_trend_days(_que, _days);
		}
		
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				sortFiles();
				querying = false;
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			var _page  = _param.page;
			var _files = _param.allFiles;
			
			if(_total_matching == 0 || _num_results == 0) {
				sortFiles();
				filterFiles(_page == 1, (_page - 1) * 50);
				querying = false;
				return;
			}
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				array_push(_files, _item);
			}
			
			if(_num_results != 50)
				querying = false;
			else
				run_in_s(1, function(p,f) /*=>*/ {return queryAllFiles(p,f)}, [_page + 1, _files]);
			
			sortFiles();
			filterFiles(_page == 1, (_page - 1) * 50);
			
		}, { page: _page, allFiles: _files });
	}
	
	function queryFiles() {
		sc_content.setScroll(0);
		allFiles     = [];
		displayFiles = [];
		pageIndex    = [];
		
		switch(contentPage) {
			case 0 :
			case 2 :
				querying = true;
				queryAllFiles();
				break;
				
			case 1 :
				var _l = ds_list_create();
				steam_ugc_get_subscribed_items(_l);
				queryingFiles = 0;
				
				for( var i = 0, n = ds_list_size(_l); i < n; i++ ) {
					var _fid = _l[| i];
					if(struct_has(WORKSHOP_FILE_CACHE, _fid)) {
						var _item = WORKSHOP_FILE_CACHE[$ _fid];
						array_push(allFiles, _item);
						continue;
					}
					
					queryingFiles++;
					
					asyncCallGroup("steam", steam_ugc_request_item_details(_fid, 30), function(_params, _data) /*=>*/ {
						var _result = _data[? "result"];
						queryingFiles--;
						
						if(_result != ugc_result_success) {
							var errStr = steam_ugc_get_error(_result);
							noti_status($"UGC query error {_result}: {errStr}");
							if(queryingFiles == 0 && contentPage == 1) sortFiles();
							return;
						}
						
						var _files = _params.allFiles;
						var _fid   = _data[? "published_file_id"];
						var _item  = new Steam_workshop_item().setMap(_data);
						WORKSHOP_FILE_CACHE[$ _fid] = _item;
						array_push(_files, _item);
						
						if(queryingFiles == 0 && contentPage == 1) sortFiles();
						filterFiles(false, array_length(_files) - 1);
					}, { allFiles });
				}
				
				ds_list_destroy(_l);
				
				if(contentPage == 1) sortFiles();
				filterFiles(true, 0);
				break;
				
			case 3 : 
				querying = true;
				
				asyncCallGroup("social", FirebaseFirestore($"patreon_projects").Read(), function(_params, _data) /*=>*/ {
					querying = false;
					if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
					
					var res  = _data[? "value"];
				    var resJ = json_try_parse(res, undefined);
				    if(resJ == undefined) return;
				    
				    var _files = _params.files;
				    var _keys  = struct_get_names(resJ);
				    
				    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
				    	var _file = _keys[i];
				    	
				    	if(!has(FIREBASE_FILE_CACHE, _file)) {
				    		var _item = new Patreon_project_item(_file);
				    		_item.data = json_try_parse(resJ[$ _file]);
				    		
				    		FIREBASE_FILE_CACHE[$ _file] = _item;
				    	}
				    	
				    	array_push(_files, FIREBASE_FILE_CACHE[$ _file]);
				    }
				    
				    array_sort(_files, function(a,b) /*=>*/ {return sign((b.data[$ "creation_time"] ?? 0) - (a.data[$ "creation_time"] ?? 0))}); 
				    for( var i = 0, n = array_length(_files); i < n; i++ ) 
				    	displayFiles[i] = _files[i];
				}, { files: allFiles });
				break;
		}
	}
	
	function queryAuthorPageNew(_page = 1) {
		var _que = steam_ugc_create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, _page);
		steam_ugc_query_set_allow_cached_response(_que, true);
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			var _aid = contentPage == 2? STEAM_ID : author_search_id;
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				if(_item.owner_steam_id == _aid)
					array_push(authorRecents, _item);
			}
			
			authorRecents = array_unique(authorRecents);
			if(_num_results == 50) queryAuthorPageNew(_param.page + 1);
			
			var _author = STEAM_WORKSHOP_DATA.account[$ _aid];
			if(_author != undefined) _author.setProjects(authorRecents);
			
		}, {page: _page});
	}
	
	function queryAuthorPageVote(_page = 1) {
		var _que = steam_ugc_create_query_all(ugc_query_RankedByVote, ugc_match_Items, _page);
		steam_ugc_query_set_allow_cached_response(_que, true);
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			var _aid = contentPage == 2? STEAM_ID : author_search_id;
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				if(_item.owner_steam_id == _aid)
					array_push(authorPopular, _item);
			}
			
			authorPopular = array_unique(authorPopular);
			if(_num_results == 50) queryAuthorPageNew(_param.page + 1);
			
		}, {page: _page});
	}
	
	function queryAuthorPage() {
		authorPopular   = [];
		authorRecents   = [];
		
		queryAuthorPageNew();
		queryAuthorPageVote();
	} 
	
	function queryHomePage() {
		fileTrendWeekly = [];
		fileRecents     = [];
		filePopular     = [];
		
		querying = true;
		
		var _que = steam_ugc_create_query_all(ugc_query_RankedByTrend, ugc_match_Items, 1);
		steam_ugc_query_set_allow_cached_response(_que, true);
		steam_ugc_query_set_ranked_by_trend_days(_que, 7);
		
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			querying = false;
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				array_push(fileTrendWeekly, _item);
			}
			
		});
		
		var _que = steam_ugc_create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, 1);
		steam_ugc_query_set_allow_cached_response(_que, true);
		
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			querying = false;
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				array_push(fileRecents, _item);
			}
			
		});
		
		var _que = steam_ugc_create_query_all(ugc_query_RankedByVote, ugc_match_Items, 1);
		steam_ugc_query_set_allow_cached_response(_que, true);
		
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			querying = false;
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				array_push(filePopular, _item);
			}
			
		});
	} 
	
	sc_content_author = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _hover = sc_content_author.hover;
		var _focus = sc_content_author.active;
		
		var _yy = _y;
		var _w  = sc_content_author.surface_w;
		var _h  = sc_content_author.surface_h;
		var _hh = 0;
		
		var _rx = x + sc_content_author.x;
		var _ry = y + sc_content_author.y;
		
		var _aid    = contentPage == 0? author_search_id : STEAM_ID;
		var _author = STEAM_WORKSHOP_DATA.account[$ _aid];
		if(_author == undefined) {
			STEAM_WORKSHOP_DATA.account[$ _aid] = new Steam_workshop_profile(_aid);
			return 0; 
		}
		
		var _name   = _author.getName();
		var _data   = _author.getData();
		
		var _myPage = contentPage == 2 && _aid == STEAM_ID;
		if(_myPage) currentAuthor = _author;
		
		#region author data
			_author.submission_count_disp      = lerp_float(_author.submission_count_disp,      _author.submission_count,      5);
			_author.submission_project_disp    = lerp_float(_author.submission_project_disp,    _author.submission_project,    5);
			_author.submission_collection_disp = lerp_float(_author.submission_collection_disp, _author.submission_collection, 5);
			_author.total_upvotes_disp         = lerp_float(_author.total_upvotes_disp,         _author.total_upvotes,         5);
			_author.max_upvotes_disp           = lerp_float(_author.max_upvotes_disp,           _author.max_upvotes,           5);

			var _px = ui(16);
			var _py = ui(16);
			var _ps = ui(128);
			var _ph = _ps + profile_offset;
			var _hhov  = _hover && _m[1] < _y + _ph - ui(16);
			var _bad_w = ui(240);
			
			profile_offset    = lerp_float(profile_offset, profile_offset_to, 5);
			profile_offset_to = ui(32);
		#endregion
		
		#region banner
			var _banner = _author.banner;
			switch(_banner.type) {
				case 0 :
					var _ban_spr = asset_get_index(_banner.sprite);
					if(!sprite_exists(_ban_spr)) _ban_spr = s_workshop_bg_pxc;
					
					shader_set(sh_tile);
						shader_set_2("scale", [ _w / 64, _h / 64 ]);
						draw_sprite_stretched(_ban_spr, 0, 0, 0, _w, _h);
					shader_reset();
					break;
					
				case 1 : draw_clear(_banner.color); break;
				
				case 2 : 
					var _spr = _author.getBanner();
					if(sprite_exists(_spr)) {
						var _sw = sprite_get_width(_spr);
						var _sh = sprite_get_height(_spr);
						
						shader_set(sh_tile);
							shader_set_2("scale", [ _w / _sw, _h / _sh ]);
							draw_sprite_stretched(_spr, 0, 0, 0, _w, _h);
						shader_reset();
					}
					break;
			}
			
			if(_myPage) {
				var _gx = _w - ui(8);
				var _gy = ui(8);
				var _hv = _hhov && point_in_circle(_m[0], _m[1], _gx, _gy, ui(10));
				
				draw_sprite_ui(THEME.gear_16, 0, _gx, _gy, 1, 1, 0, _hv? COLORS._main_icon_light : COLORS._main_icon);
				if(_hv && mouse_lpress(_focus)) menuCall("steam_author_banner_edit", menu_banner_edit);
				
				if(banner_uploading) {
					_gx -= ui(20);
					draw_sprite_ui(THEME.loading_s, 0, _gx, _gy, .65, .65, current_time / 2, COLORS._main_icon, .8);
				}
			}
		#endregion	
			
		#region profile
			_author.drawProfile(_px, _py, _ps, true);
			
			if(_myPage && IS_PATREON) {
				var _gx = _px + _ps - ui(10);
				var _gy = _py + ui(10);
				var _hv = _hhov && point_in_circle(_m[0], _m[1], _gx, _gy, ui(10));
				
				draw_sprite_ui(THEME.gear_16, 0, _gx, _gy, 1, 1, 0, _hv? COLORS._main_icon_light : COLORS._main_icon);
				if(_hv && mouse_lpress(_focus)) menuCall("steam_author_profile_edit", menu_profile_edit);
			}
			
			if(_author.profile_graph_runner) {
				var _gx = _px + _ps - ui(10);
				var _gy = _py + _ps - ui(10);
				var _hv = _hhov && point_in_circle(_m[0], _m[1], _gx, _gy, ui(10));
				
				draw_sprite_ui(THEME.animate_node_go, 0, _gx, _gy, 1, 1, 0, _hv? COLORS._main_icon_light : COLORS._main_icon);
				if(_hv) {
					TOOLTIP = __txt("View Graph...");
					
					if(mouse_lpress(_focus)) {
						var _graph = new Panel_Graph(_author.profile_graph_runner.project).setSize(ui(800), ui(480));
						_graph.title = _name + "'s " + __txt("Profile Graph");
						_graph.applyGlobal = false;
						
						if(_author.profile_graph_runner.io_node != undefined)
							_graph.addContext(_author.profile_graph_runner.io_node);
						dialogPanelCall(_graph);
					}
				}
			}
		#endregion
		
		#region links
			var _links = _author.links;
			
			var _lam = array_length(_links);
			var _amo = _lam;
			if(_myPage) _amo++;
			
			var _ls  = ui(32);
			var _col = _ps / _ls;
			var _row = ceil(_amo / _col);
			
			var _ly = _py + _ps + ui(8);
			
			var _bspr, _btxt, _bcc, _blink;
			var _hoverIndex = undefined;
			
			var _aamo = _amo;
			
			for( var i = 0; i < _row; i++ ) {
				var __col = min(_aamo, _col);
				var _cw = _ls * __col;
				var _cx = _px + _ps / 2 - _cw / 2;
				var _cy = _ly;
				
				for( var j = 0; j < __col; j++ ) {
					var _xx = _cx + j * _ls;
					
					var _indx = i * _col + j;
					var _bspr = THEME.link;
					var _btxt = "";
					
					if(_indx == _lam) { // edit links
						_bspr = THEME.add;
						_btxt = __txt("Add link...");
						_bcc  = [ COLORS._main_value_positive, COLORS._main_value_positive ];
						
					} else {
						var _link = _links[_indx];
						_bcc  = [ COLORS._main_icon, COLORS._main_icon_light ];
						
						switch(_link.type) {
							case "steam" : 
								_bspr  = THEME.steam_invert_24;
								_btxt  = __txt("Steam Workshop") + $" @{_name}";
								_blink = $"https://steamcommunity.com/id/{_name}/myworkshopfiles/?appid=2299510";
								break;
								
							case "twitter" : 
								_bspr  = THEME.twitter;
								_btxt  = __txt("Twitter") + $" @{_link.link}";
								_blink = $"https://x.com/{_link.link}";
								break;
								
							case "bluesky" : 
								_bspr  = THEME.bluesky;
								_btxt  = __txt("Bluesky") + $" @{_link.link}";
								_blink = $"https://bsky.app/profile/{_link.link}";
								break;
								
							case "mastodon" : 
								_bspr  = THEME.mastodon;
								_btxt  = __txt("Mastodon") + $" @{_link.link}";
								_blink = $"https://mastodon.gamedev.place/@{_link.link}";
								break;
								
							case "youtube" : 
								_bspr  = THEME.youtube;
								_btxt  = __txt("Youtube") + $" @{_link.link}";
								_blink = $"https://www.youtube.com/@{_link.link}";
								break;
								
							case "url" : 
								_bspr  = THEME.link;
								_btxt  = _link.link;
								_blink = _link.link;
								break;
								
						}
						
					}
					
					var _icx = _xx + _ls / 2;
					var _icy = _cy + _ls / 2;
					var _ihv = _hhov && point_in_rectangle(_m[0], _m[1], _xx + ui(2), _cy + ui(2), _xx + _ls - ui(2), _cy + _ls - ui(2));
					
					var _cc = _ihv? _bcc[1] : _bcc[0];
					if(link_dragging == _indx) _cc = COLORS._main_accent;
					
					draw_sprite_ui(_bspr, 0, _icx, _icy, 1, 1, 0, _cc);
					
					if(_ihv) {
						TOOLTIP = _btxt;
						if(_myPage) draw_sprite_stretched(THEME.button_hide, 1, _xx, _cy, _ls, _ls, 1, 1, 0, COLORS._main_icon);
					}
					
					if(_indx == _lam) {
						if(_ihv && mouse_lpress(_focus)) {
							menu_add_link_x = _rx + _xx + _ls + ui(4);
							menu_add_link_y = _ry + _cy;
							menuCall("steam_add_link", menu_add_link);
						}
						
					} else if(_myPage) {
						if(_ihv) { 
							_hoverIndex = _indx;
							
							if(mouse_lpress(_focus))
								link_dragging = _indx;
							
							if(mouse_rpress(_focus)) {
								var _menu = [
									menuItem(__txt("Delete Link"), function(_param) /*=>*/ {
										var _links = currentAuthor.links;
										array_delete(_links, _param.index, 1);
										currentAuthor.updateData({ links: json_stringify(_links) });
									}, THEME.cross ).setParam({ index : _indx }), 
								];
								
								if(_link.type != "steam") {
									array_insert(_menu, 0, menuItem(__txt("Edit Link"), function(_link) /*=>*/ {
										textboxCall(_link.link, function(t, _link) /*=>*/ {return currentAuthor.addLink(_link.type, t)})
											.setParam(_link).setLabel("@");
									}).setParam(_link));
								}
								
								menuCall("steam_right_link", _menu);
							}
						}
						
					} else {
						if(_ihv && _blink != "" && mouse_lpress(_focus)) 
							URL_open(_blink);
					}
				}
				
				_aamo -= _col;
				_ly += _ls;
			}
			
			if(link_dragging != undefined) {
				if(_hoverIndex != undefined && _hoverIndex != link_dragging) {
					var _val = _links[link_dragging];
					array_delete(_links, link_dragging, 1);
					array_insert(_links, _hoverIndex, _val);
					
					link_dragging = _hoverIndex;
				}
				
				if(mouse_lrelease()) {
					link_dragging = undefined;
					_author.updateData({ links: json_stringify(_links) });
				}
			}
			
			profile_offset_to = max(profile_offset_to, _ly - _ps + ui(24));
		#endregion
		
		#region username
			draw_set_text(f_h5, fa_left, fa_bottom, COLORS._main_text);
			var _th = line_get_height()
			var _tx = _px + _ps + ui(16);
			var _ty = _py + ui(4) + _th;
			draw_text_add(_tx, _ty, _name);
			
			if(_author.getPatreon()) {
				var _tx1 = _tx + string_width(_name) + ui(4);
				draw_sprite_ui(THEME.patreon_supporter, 0, _tx1, _ty - _th + _ui(12), 1, 1, 0, COLORS._main_icon_dark, 1);
	            draw_sprite_ui(THEME.patreon_supporter, 1, _tx1, _ty - _th + _ui(12), 1, 1, 0, COLORS._main_accent, 1);
			}
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_accent);
			draw_text_add(_tx, _ty - ui(4), $"{round(_author.total_upvotes_disp)} upvotes");
			_ty += line_get_height();
		#endregion
		
		#region subtitle
			var _sub  = _data[$ "subtitle"] ?? "";
			var _subw = _w - _tx - ui(8) - _bad_w - ui(16);
			
			if(_data == 0) {
				draw_sprite_ui(THEME.loading_s, 0, _tx + _subw / 2, _ty + ui(16), .75, .75, current_time / 2, COLORS._main_icon, .8);
				
			} else if(_myPage) {
				var _param = new widgetParam(_tx, _ty, _subw, TEXTBOX_HEIGHT, _sub, {}, _m)
					.setFont(f_p2)
					.setFocusHover(_focus, _hhov, !tb_author_subtitle_updating);
				
				var _wh = tb_author_subtitle.drawParam(_param);
				
				var _csub = tb_author_subtitle.selecting? tb_author_subtitle._input_text : _sub;
				var _l = string_length(_csub);
				
				if(tb_author_subtitle_updating) 
					draw_sprite_ui(THEME.loading_s, 0, _tx + _subw - ui(16), _ty + ui(16), .75, .75, current_time / 2, COLORS._main_icon, .8);
				else {
					var cc = COLORS._main_text_sub;
					     if(_l > subtitle_length_limit)      cc = COLORS._main_value_negative;
					else if(_l > subtitle_length_limit * .8) cc = COLORS._main_text_accent;
					draw_set_text(f_p4, fa_right, fa_top, cc);
					draw_text(_tx + _subw - ui(4), _ty, $"{_l}/{subtitle_length_limit}");
				}
				
				_ty += _wh + ui(8);
				
			} else {
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_ext_add(_tx, _ty, _sub, -1, _subw);
				
				_ty += string_height_ext(_sub, -1, _subw) + ui(8);
			}
			
			var _ty = max(_ty + ui(16), _py + _ps - ui(4));
			draw_set_text(f_p2b, fa_left, fa_bottom, COLORS._main_text);
			var _sub_txt = $"{round(_author.submission_count_disp)} submissions";
			draw_text_add(_tx, _ty, _sub_txt);
			_tx += string_width(_sub_txt) + ui(4);
			
			draw_set_text(f_p2, fa_left, fa_bottom, COLORS._main_icon);
			var _sub_txt = $"{round(_author.submission_project_disp)} projects, {round(_author.submission_collection_disp)} collections";
			draw_text_add(_tx, _ty, _sub_txt);
			
			profile_offset_to = max(profile_offset_to, _ty - _ps + ui(24));
		#endregion
		
		#region badges
			var _badges = _author.badges;
			
			if(badge_editing) {
				var _bds      = ui(32);
				var _bad_h    = ui(24) + array_length(_badges) * (_bds + ui(8)) - ui(8);
				var _badge_x0 = _w - ui(16) - _bad_w;
				var _badge_y0 = _py;
				var _badge_y1 = _badge_y0 + _ps;
				profile_offset_to = max(profile_offset_to, _bad_h - _ps + ui(24));
				
				draw_sprite_stretched_ext(THEME.box_r2_clr, 0, _badge_x0, _badge_y0, _bad_w, _bad_h, c_white, .5);
				draw_sprite_stretched_add(THEME.box_r2_clr, 1, _badge_x0, _badge_y0, _bad_w, _bad_h, c_white, .5);
				
				var _bdx = _badge_x0 + ui(12) + ui(24);
				var _bdy = _badge_y0 + ui(12);
				var _badge_hovering = 0;
				
				for( var i = 0, n = array_length(_badges); i < n; i++ ) {
					var b = _badges[i];
					if(b == undefined) continue;
					
					var hv = _hhov && point_in_rectangle(_m[0], _m[1], _badge_x0, _bdy, _badge_x0 + _bad_w - ui(24), _bdy + _bds + ui(8) - 1);
					var cc = hv? COLORS._main_icon_light : COLORS._main_icon;
					if(badge_dragging == i) cc = COLORS._main_accent;
					
					draw_sprite_ui(THEME.hamburger_s, 0, _bdx - ui(16), _bdy + _bds / 2, 1, 1, 0, cc);
					
					if(sprite_exists(b.spr)) {
						gpu_set_tex_filter(true);
						draw_sprite_stretched(b.spr, 0, _bdx, _bdy, _bds, _bds);
						gpu_set_tex_filter(false);
					}
					
					draw_set_text(f_p1b, fa_left, fa_center, COLORS._main_text);
					draw_text(_bdx + _bds + ui(8), _bdy + _bds / 2, b.name);
					
					if(hv && mouse_lpress(_focus))
						badge_dragging = i;
						
					if(_m[1] > _bdy) _badge_hovering = i;
					
					_bdy += _bds + ui(8);
				}
				
				if(badge_dragging != undefined) {
					if(badge_dragging != _badge_hovering) {
						var _val = _badges[badge_dragging];
						array_delete(_badges, badge_dragging, 1);
						array_insert(_badges, _badge_hovering, _val);
						
						var _kval = _author.badgeK[badge_dragging];
						array_delete(_author.badgeK, badge_dragging, 1);
						array_insert(_author.badgeK, _badge_hovering, _kval);
						
						badge_dragging = _badge_hovering;
					}
					
					if(mouse_lrelease()) badge_dragging = undefined;
				}
				
			} else {
				var _bad_h = ui(128);
				var _badge_x0 = _w - ui(16) - _bad_w;
				var _badge_y0 = _py;
				var _badge_y1 = _badge_y0 + _ps;
				
				var _bds = ui(48);
				var _bdx = _badge_x0 + ui(12);
				var _bdy = _badge_y0 + ui(14);
				
				draw_sprite_stretched_ext(THEME.box_r2_clr, 0, _badge_x0, _badge_y0, _bad_w, _bad_h, c_white, .5);
				draw_sprite_stretched_add(THEME.box_r2_clr, 1, _badge_x0, _badge_y0, _bad_w, _bad_h, c_white, .5);
				
				var b = array_safe_get_fast(_badges, 0);
				if(b != 0) {
					if(sprite_exists(b.spr)) {
						gpu_set_tex_filter(true);
						draw_sprite_stretched(b.spr, 0, _bdx, _bdy, _bds, _bds);
						gpu_set_tex_filter(false);
					}
					
					draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_accent);
					draw_text(_bdx + _bds + ui(8), _bdy, b.name);
					
					draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
					draw_text(_bdx + _bds + ui(8), _bdy + ui(20), b.subtitle);
				}
				
				_bdy += _bds + ui(10);
				var _bds  = ui(40);
				var _bamo = floor((_bad_w - ui(24)) / (_bds + ui(4)));
				var _bdx  = _badge_x0 + ui(12);
				
				for( var i = 1, n = min(array_length(_badges), _bamo + 1); i < n; i++ ) {
					var b = _badges[i];
					if(b == undefined) continue;
					
					if(sprite_exists(b.spr)) {
						gpu_set_tex_filter(true);
						draw_sprite_stretched(b.spr, 0, _bdx, _bdy, _bds, _bds);
						gpu_set_tex_filter(false);
					}
					
					var _hov = _hhov && point_in_rectangle(_m[0], _m[1], _bdx, _bdy, _bdx + _bds, _bdy + _bds);
					if(_hov) TOOLTIP = new tooltip_two_lines(b.name, b.subtitle);
					
					_bdx += _bds + ui(4);
				}
			}
			
			if(_myPage) {
				var _gx = _badge_x0 + _bad_w - ui(14);
				var _gy = _badge_y0 + ui(14);
				var _hv = _hhov && point_in_circle(_m[0], _m[1], _gx, _gy, ui(10));
				
				if(badge_editing) {
					draw_sprite_ui(THEME.accept_16, 0, _gx, _gy, 1, 1, 0, COLORS._main_value_positive);
				} else {
					var  cc = _hv? COLORS._main_icon_light : COLORS._main_icon;
					draw_sprite_ui(THEME.gear_16, 0, _gx, _gy, 1, 1, 0, cc);
				}
				
				if(_hv && mouse_lpress(_focus)) {
					badge_editing = !badge_editing;
					if(!badge_editing) _author.updateBadge();
				}
			}
		#endregion
		
		_y += _ph;
		draw_sprite_stretched_ext(s_workshop_author_bg, 0, 0, _y - ui(32), _w, _h - _y + ui(32), COLORS.panel_bg_clear_inner);
		
		#region content
			var _pd = ui(8);
			var _size_large = grid_size * 2 + ui(4);
			var _size_small = (_size_large - _pd) / 2;
			
			var _th        = line_get_height(f_h5);
			var _authorLen = array_length(_author.pageContent);
			var _action    = undefined;
			
			for( var c = 0; c < _authorLen; c++ ) {
				var _cont = _author.pageContent[c];
					
				var _ty = _y + ui(8);
				var _yc = _ty + _th / 2;
				
				var _title  = "";
				var _target = undefined;
				var _tspr   = THEME.workshop_sort;
				var _tind   = 0;
				
				switch(_cont.type) {
					case "Popular":
						_title  = $"{_name}'s Most Popular Works";
						_target = { type : 0, page : 1, sort_type : 0, sort_trend_day : 1, };
						
						_tspr = THEME.workshop_sort;
						_tind = 0;
						
						_y += _th + ui(20);
						
						var _hix = ui(8);
						var _hiy = _y;
						var _his = _size_large;
						
						var _file_highlight = array_safe_get(authorPopular, 0, undefined);
						if(_file_highlight) _file_highlight.draw(self, _rx, _ry, _hix, _hiy, _hix + _his, _hiy + _his, _m, _hover, _focus);
						
						var _fs = (_his - _pd) / 2;
						var _maxCol = floor((_w - _hix - _his - _pd) / (_fs + _pd));
						
						for( var i = 1, n = min(_maxCol * 2 + 1, array_length(authorPopular)); i < n; i++ ) {
							var _row = (i - 1) % 2;
							var _col = floor((i - 1) / 2);
							
							var _fx = _hix + _his + _pd + _col * (_fs + _pd);
							var _fy = _hiy + _row * (_fs + _pd);
							
							authorPopular[i].draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, false);
						}
						
						_y += _his + ui(56);
						break;
					
					case "Recents":
						_title  = $"{_name}'s Most Recent Works";
						_target = { type : 0, page : 1, sort_type : 2, };
						
						_tspr = THEME.workshop_sort;
						_tind = 2;
						
						var _fs = _size_small;
						var _maxCol = floor((_w - _pd) / (_fs + _pd));
						
						_y += _th + ui(20);
						
						for( var i = 0, n = min(_maxCol, array_length(authorRecents)); i < n; i++ ) {
							var _fx = _pd + i * (_fs + _pd);
							var _fy = _y;
							
							authorRecents[i].draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, true);
						}
						
						_y += _fs + _pd + ui(40);
						break;
					
					case "Tag":
						var _tag = _cont.tag;
						_title   = _tag;
						_target  = { type : 0, page : 1, sort_type : 2, };
						
						switch(_tag) {
							case "Project" :    _tspr = THEME.project; _tind = 0; _target.type_filter = [_tag]; break;
							case "Collection" : _tspr = THEME.group;   _tind = 0; _target.type_filter = [_tag]; break;
							default :           _tspr = THEME.tag_24;  _tind = 0; _target.tag_filter  = [_tag]; break;
						}
						
						var _fs  = _size_small;
						var _maxCol = floor((_w - _pd) / (_fs + _pd));
						
						_y += _th + ui(20);
						
						var _ind = 0;
						for( var i = 0, n = array_length(authorRecents); i < n; i++ ) {
							var _file = authorRecents[i];
							if(!array_exists(_file.tags, _tag)) continue;
							
							var _fx = _pd + _ind * (_fs + _pd);
							var _fy = _y;
							
							_file.draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, true);
							if(++_ind > _maxCol) break;
						}
						
						_y += _fs + _pd + ui(40);
						break;
				}
				
				if(has(_cont, "title")) _title = _cont.title;
				
				var _tx = ui(44);
				draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
				draw_text_add(_tx, _yc, _title);
				draw_sprite_ui(_tspr, _tind, ui(24), _yc, .8, .8, 0, COLORS._main_accent);
				
				if(_myPage) {
					var _tw = string_width(_title);
					var _rx = _tx + _tw + ui(16);
					
					if(buttonInstant_Icon(_rx, _yc, ui(16), _m, _hover, _focus, __txt("Rename"), THEME.rename, 0, .75) == 2) {
						textboxCall(_title, function(t, _cont) /*=>*/ {
							if(t == "") struct_remove_safe(_cont, "title");
							else _cont.title = t;
							currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
						}).setParam(_cont);
					}
					
					var _bx = _w - ui(24);
					var _by = _yc;
					
					var _bc = COLORS._main_value_negative;
					if(buttonInstant_Icon(_bx, _by, _ui(20), _m, _hover, _focus, "Delete", THEME.cross_16, 0, 1, _bc, _bc) == 2)
						_action = { index: c, type: "delete" };
					
					_bx -= ui(32);
					draw_set_color(CDEF.main_dkgrey);
					draw_line_width(_bx + ui(16), _by - ui(8), _bx + ui(16), _by + ui(8), ui(2));
					
					if(c == _authorLen - 1) draw_sprite_ui(THEME.arrow_wire_16, 3, _bx, _by, 1, 1, 0, CDEF.main_dkgrey);
					else if(buttonInstant_Icon(_bx, _by, _ui(20), _m, _hover, _focus, "Move down", THEME.arrow_wire_16, 3) == 2) 
						_action = { index: c, type: "down" };
					_bx -= ui(24);
					
					if(c == 0) draw_sprite_ui(THEME.arrow_wire_16, 1, _bx, _by, 1, 1, 0, CDEF.main_dkgrey);
					else if(buttonInstant_Icon(_bx, _by, _ui(20), _m, _hover, _focus, "Move up", THEME.arrow_wire_16, 1) == 2) 
						_action = { index: c, type: "up" };
					_bx -= ui(24);
					
				} else if(_target != undefined) {
					var _hv = _hover && point_in_rectangle(_m[0], _m[1], _w - ui(80), _yc - _th/2, _w - ui(8), _yc + _th/2);
					var _cc = _hv? COLORS._main_text_accent : COLORS._main_icon;
					draw_set_text(f_p2b, fa_right, fa_center, _cc);
					draw_text_add(_w - ui(24), _yc - ui(1), "View all");
					draw_sprite_ui(THEME.arrow_wire_16, 0, _w - ui(16), _yc, 1, 1, 0, _cc);
					
					if(_hv && mouse_lpress(_focus))
						navigate(_target);
				}
			}
			
			if(_action != undefined) {
				switch(_action.type) {
					case "delete": array_delete(_author.pageContent, _action.index, 1); break;
					
					case "up" :
						var _val = _author.pageContent[_action.index];
						array_delete(_author.pageContent, _action.index, 1);
						array_insert(_author.pageContent, _action.index - 1, _val);
						break;
						
					case "down" :
						var _val = _author.pageContent[_action.index];
						array_delete(_author.pageContent, _action.index, 1);
						array_insert(_author.pageContent, _action.index + 1, _val);
						break;
				}
				
				_action = undefined;
				_author.updateData({pageContent: json_stringify(_author.pageContent)});
			}
			
			if(_myPage) {
				_y += ui(16);
				
				var _aw = ui(160);
				var _ah = ui(28);
				
				draw_set_color_alpha(COLORS._main_value_positive, .5);
				draw_line(     ui(16), _y + _ah/2, _w/2 - _aw/2 - ui(16), _y + _ah/2);
				draw_line(_w - ui(16), _y + _ah/2, _w/2 + _aw/2 + ui(16), _y + _ah/2);
				draw_set_alpha(1);
				
				var _ax = _w / 2 - _aw / 2;
				if(buttonInstantGlass(_hover, _focus, _m[0], _m[1], _ax, _y, _aw, _ah, "Add Section") == 2) {
					menuCall("workshop_author_add", [
						menuItem(__txt("Popular"), function() /*=>*/ {
							array_push(currentAuthor.pageContent, { type: "Popular" });
							currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
						}), 
						menuItem(__txt("Recent"), function() /*=>*/ {
							array_push(currentAuthor.pageContent, { type: "Recents" });
							currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
						}), 
						-1,
						menuItem(__txt("Projects"), function() /*=>*/ {
							array_push(currentAuthor.pageContent, { type: "Tag", tag: "Project", title: $"{currentAuthor.getName()}'s Projects" });
							currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
						}), 
						menuItem(__txt("Collections"), function() /*=>*/ {
							array_push(currentAuthor.pageContent, { type: "Tag", tag: "Collection", title: $"{currentAuthor.getName()}'s Collections" });
							currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
						}), 
						-1, 
						menuItem(__txt("Tag"), function(_dat) /*=>*/ {
							var tags = array_merge(META_TAGS, custom_tags);
							var arr  = array_create(array_length(tags));
							
		                    for( var i = 0, n = array_length(tags); i < n; i++ ) {
		                        var tag = tags[i];
		                        
		                        arr[i] = menuItem(tag, function(tag) /*=>*/ {
		                        	array_push(currentAuthor.pageContent, { type: "Tag", tag: tag, title: tag });
									currentAuthor.updateData({pageContent: json_stringify(currentAuthor.pageContent)});
		                        }, noone, noone, noone, tag);
		                    }
		                    
		                    return submenuCall(_dat, arr, "workshop_author_add_tags");
						}).setIsShelf(), 
					]);
				}
				
				_y += _ah;
			}
			
			_y += ui(32);
		#endregion
		
		return _y - _yy;
	}).setUseDepth();
	
	sc_content_home = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		
		var _hover = sc_content_home.hover;
		var _focus = sc_content_home.active;
		
		var _yy = _y;
		var _w  = sc_content_home.surface_w;
		var _h  = sc_content_home.surface_h;
		var _hh = 0;
		
		var _rx = sc_content_home.x;
		var _ry = sc_content_home.y;
		
		#region trending
			var _ty = _y + ui(8);
			var _th = line_get_height(f_h5);
			var _yc = _ty + _th / 2;
			
			draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
			draw_text_add(ui(40), _yc, "Trending This Week");
			draw_sprite_ui(THEME.workshop_sort, 1, ui(24), _yc, .8, .8, 0, COLORS._main_accent);
			
			var _hv = _hover && point_in_rectangle(_m[0], _m[1], _w - ui(80), _yc - _th/2, _w - ui(8), _yc + _th/2);
			var _cc = _hv? COLORS._main_text_accent : COLORS._main_icon;
			draw_set_text(f_p2b, fa_right, fa_center, _cc);
			draw_text_add(_w - ui(24), _yc - ui(1), "View all");
			draw_sprite_ui(THEME.arrow_wire_16, 0, _w - ui(16), _yc, 1, 1, 0, _cc);
			
			if(_hv && mouse_lpress(_focus)) {
				navigate({ 
					type : 0, 
					page : 1,
					sort_type      : 1, 
					sort_trend_day : 1,
				});
			}
			
			_y += _th + ui(20);
			
			var _hix = ui(8);
			var _hiy = _y;
			var _his = grid_size * 2 + ui(4);
			
			var _file_highlight = array_safe_get(fileTrendWeekly, 0, undefined);
			if(_file_highlight)
				_file_highlight.draw(self, _rx, _ry, _hix, _hiy, _hix + _his, _hiy + _his, _m, _hover, _focus);
			
			var _pd = ui(8);
			var _fs = (_his - _pd) / 2;
			var _maxCol = floor((_w - _hix - _his - _pd) / (_fs + _pd));
			
			for( var i = 1, n = min(_maxCol * 2 + 1, array_length(fileTrendWeekly)); i < n; i++ ) {
				var _row = (i - 1) % 2;
				var _col = floor((i - 1) / 2);
				
				var _fx = _hix + _his + _pd + _col * (_fs + _pd);
				var _fy = _hiy + _row * (_fs + _pd);
				
				var _file = fileTrendWeekly[i];
				
				_file.draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, false);
			}
			
			_y += _his + ui(56);
		#endregion
		
		#region voted
			var _ty = _y + ui(8);
			var _th = line_get_height(f_h5);
			var _yc = _ty + _th / 2;
			var _maxCol = floor((_w - _pd) / (_fs + _pd));
			
			draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
			draw_text_add(ui(40), _yc, "Top Rated");
			draw_sprite_ui(THEME.workshop_sort, 0, ui(24), _yc, .8, .8, 0, COLORS._main_accent);
			
			var _hv = _hover && point_in_rectangle(_m[0], _m[1], _w - ui(80), _yc - _th/2, _w - ui(8), _yc + _th/2);
			var _cc = _hv? COLORS._main_text_accent : COLORS._main_icon;
			draw_set_text(f_p2b, fa_right, fa_center, _cc);
			draw_text_add(_w - ui(24), _yc - ui(1), "View all");
			draw_sprite_ui(THEME.arrow_wire_16, 0, _w - ui(16), _yc, 1, 1, 0, _cc);
			
			if(_hv && mouse_lpress(_focus)) {
				navigate({ 
					type : 0, 
					page : 1,
					sort_type : 0,
				});
			}
			_y += _th + ui(20);
			
			for( var i = 0, n = min(_maxCol, array_length(filePopular)); i < n; i++ ) {
				var _fx = _pd + i * (_fs + _pd);
				var _fy = _y;
				
				var _file = filePopular[i];
				_file.draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, true);
			}
			
			_y += _fs + ui(48);
		#endregion
		
		#region new
			var _ty = _y + ui(8);
			var _th = line_get_height(f_h5);
			var _yc = _ty + _th / 2;
			
			draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
			draw_text_add(ui(40), _yc, "Most Recent");
			draw_sprite_ui(THEME.workshop_sort, 2, ui(24), _yc, .8, .8, 0, COLORS._main_accent);
			
			var _hv = _hover && point_in_rectangle(_m[0], _m[1], _w - ui(80), _yc - _th/2, _w - ui(8), _yc + _th/2);
			var _cc = _hv? COLORS._main_text_accent : COLORS._main_icon;
			draw_set_text(f_p2b, fa_right, fa_center, _cc);
			draw_text_add(_w - ui(24), _yc - ui(1), "View all");
			draw_sprite_ui(THEME.arrow_wire_16, 0, _w - ui(16), _yc, 1, 1, 0, _cc);
			
			if(_hv && mouse_lpress(_focus)) {
				navigate({ 
					type : 0, 
					page : 1,
					sort_type : 2,
				});
				
			}
			_y += _th + ui(20);
			
			for( var i = 0, n = min(_maxCol, array_length(fileRecents)); i < n; i++ ) {
				var _fx = _pd + i * (_fs + _pd);
				var _fy = _y;
				
				var _file = fileRecents[i];
				_file.draw(self, _rx, _ry, _fx, _fy, _fx + _fs, _fy + _fs, _m, _hover, _focus, true);
			}
			
			_y += _fs + ui(48);
		#endregion
		
		_hh = _y - _yy;
		return _hh;
	}).setUseDepth();
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _w    = sc_content.surface_w;
		var _h    = sc_content.surface_h;
		
		var _rx = sc_content.x;
		var _ry = sc_content.y;
		
		if(!querying && array_empty(displayFiles)) {
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_w / 2, _h / 2, "No results");
			return 0;
		}
		
		var _gw   = grid_size;
		var _gh   = _gw;
		var _th   = line_get_height(f_p2b) + ui(4) + line_get_height(f_p4);
		var _marx = ui(4), _mary = ui(4);
		
		var _ind_start = (page - 1) * item_per_page;
		var _ind_end   = min(_ind_start + item_per_page, array_length(displayFiles));
		
		var _itemAmo = _ind_end - _ind_start;
		var _amo = querying? item_per_page : _itemAmo;
		var _col = max(1, floor(_w / _gw));
		var _row = ceil(_amo / _col);
		
		_gw   = _w / _col;
		_marx = ui(4) + (_gw - _gh) / 2;
		
		var _ghh = _gh + ui(6) + _th + ui(4);
		var _hh  = _ghh * _row;
		
		var _scis = gpu_get_scissor();
		
		for( var i = 0; i < _amo; i++ ) {
			var _c = i % _col;
			var _r = floor(i / _col);
			
			var _gx = _gw * _c;
			var _gy = _y + _ghh * _r;
			
			var _x0 = _gx + _marx;
			var _y0 = _gy + _mary;
			var _x1 = _gx + _gw - _marx;
			var _y1 = _gy + _gh - _mary;
			
			var _cw = _x1 - _x0;
			var _ch = _y1 - _y0;
			
			var _draw = _y0 < _h && _gy + _ghh > 0;
			if(!_draw) continue;
			
			if(querying && i >= _itemAmo) {
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y0, _cw, _ch, c_white, sin(current_time / 150 - i * .5) * .2 + .8);
				continue;
			}
			
			var _file = displayFiles[_ind_start + i];
			_file.draw(self, _rx, _ry, _x0, _y0, _x1, _y1, _m, _hover, _focus);
		}
		
		return _hh;
	}).setUseDepth();
	
	sc_content_item = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _hover = sc_content_item.hover;
		var _focus = sc_content_item.active;
		
		var _rx = x + sc_content_item.x;
		var _ry = y + sc_content_item.y;
		
		var _w  = sc_content_item.surface_w;
		var _h  = sc_content_item.surface_h;
		var _ystart = _y;
		
		if(!item_viewing.ready) {
			draw_sprite_ui(THEME.loading, 0, _w/2, _h/2, 1, 1, current_time / 2, COLORS._main_icon, .8);
			return 0;
		}
		
		var _myitem = item_viewing.owner_steam_id == STEAM_ID;
		var _fid    = item_viewing.file_id;
		current_url = $"https://steamcommunity.com/sharedfiles/filedetails/?id={_fid}"
		
		var _hub_stat = item_viewing.getHUBStatus();
		var _hub_data = item_viewing.pxc_hub_data;
		
		if(!item_viewing.comment_fetched && item_viewing.ready)
			item_viewing.fetchComments();
						
		#region detail header
			var _name = item_viewing.title;
			var _auth = item_viewing.author;
		
			var _x0 = ui(16);
			var _y0 = ui(8);
			var _yy = ui(8);
			
			draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
			var _lh = line_get_height();
			
			if(_myitem && item_title_editing) {
				var _lw = max(ui(256), string_width(_name) + ui(16));
				
				var _param = new widgetParam(_x0 - ui(6), _yy - ui(4), _lw + ui(8), _lh + ui(8), _name, {}, _m)
					.setFont(f_h5).setFocusHover(_focus, _hover)
				tb_item_title.drawParam(_param);
				if(item_title_updating)
					draw_sprite_ui(THEME.loading_s, 0, _x0 + _lh - ui(16), _yy + _lh / 2, .75, .75, current_time / 2, COLORS._main_icon, .8);
				
				var _edx = _x0 + _lw + ui(8);
				var _edy = _yy;
				
				var cc = [ COLORS._main_icon, COLORS._main_value_negative ];
				if(buttonInstant(noone, _edx, _edy, _lh, _lh, _m, _hover, _focus, __txt("Cancel"), THEME.cross, 0, cc) == 2) {
					item_title_editing = false;
					tb_item_title.reset();
				}
					
			} else {
				draw_text_add(_x0, _yy, _name);
				
				if(_myitem) {
					var _edx = _x0 + string_width(_name) + ui(8);
					var _edy = _yy;
					
					var cc = [ COLORS._main_icon, COLORS._main_icon_light ];
					if(buttonInstant(noone, _edx, _edy, _lh, _lh, _m, _hover, _focus, __txt("Edit"), THEME.rename, 0, cc) == 2)
						item_title_editing = true;
				}
			}
			
			_yy += line_get_height();
			
			draw_set_text(f_p2, fa_left, fa_top);
			var _author = _auth.getName();
			var _aux = _x0 - ui(4);
			var _auy = _yy - ui(2);
			var _auw = _x0 + string_width(_author) + ui(4);
			var _auh = _yy + line_get_height(f_p2, 4);
			var _hovAuthor = _hover && point_in_rectangle(_m[0], _m[1], _aux, _auy, _auw, _auh);
			draw_set_color(_hovAuthor? COLORS._main_accent : CDEF.main_mdwhite);
			draw_text_add(_x0, _yy, _author);
			
			if(_auth.getPatreon()) {
				var _tx1 = _x0 + string_width(_author) + ui(4);
				draw_sprite_ui(THEME.patreon_supporter, 0, _tx1, _yy + _ui(8), .8, .8, 0, COLORS._main_icon_dark, 1);
	            draw_sprite_ui(THEME.patreon_supporter, 1, _tx1, _yy + _ui(8), .8, .8, 0, COLORS._main_accent, 1);
			}
			
			if(_hovAuthor && mouse_lpress(_focus)) {
				doViewAuthor = item_viewing.owner_steam_id;
			}
			
			_yy += line_get_height() + ui(16);
			
			var _stat = item_viewing.getStatus();
			var _oww = ui(128);
			var _ohh = ui(28);
			
			var _yc = (_y0 + _yy - ui(16)) / 2;
			
			var _ox1 = _w - ui(16);
			var _ox0 = _ox1 - _oww;
			var _oy0 = _yc - _ohh / 2;
			var _oy1 = _oy0 + _ohh;
			
			var _subHov = _hover && point_in_rectangle(_m[0], _m[1], _ox0, _oy0, _ox1, _oy1);
			
			switch(_stat) {
				case 0: // not sub
					var _cc = _subHov? COLORS._main_value_positive : COLORS._main_icon;
					
					draw_sprite_stretched_ext(THEME.button_def, 0, _ox0, _oy0, _oww, _ohh, _cc, 1);
					draw_sprite_stretched_ext(THEME.button_def, 3, _ox0, _oy0, _oww, _ohh, _cc, .6 + _subHov * .25);
					
					draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
					draw_text_add(_ox1 - _oww/2, _yc, __txt("Subscribe"));
					
					if(_subHov && mouse_lpress(_focus))
						UGC_subscribe_item(_fid);
					break;
					
				case 1: // adding
					draw_sprite_stretched_ext(THEME.button_def, 0, _ox0, _oy0, _oww, _ohh, COLORS._main_icon, 1);
					draw_sprite_stretched_ext(THEME.button_def, 3, _ox0, _oy0, _oww, _ohh, COLORS._main_icon, .6 + _subHov * .25);
					
					draw_sprite_ui(THEME.loading_s, 0, _ox0 + _oww / 2, _oy0 + _ohh / 2, .75, .75, current_time / 2, COLORS._main_icon, .8 + _subHov * .2);
					break;
					
				case 2: // subbed
					var _cc = _subHov? COLORS._main_value_negative : COLORS._main_value_positive;
					
					draw_sprite_stretched_ext(THEME.button_def, 0, _ox0, _oy0, _oww, _ohh, _cc, 1);
					draw_sprite_stretched_ext(THEME.button_def, 3, _ox0, _oy0, _oww, _ohh, _cc, .6 + _subHov * .25);
					
					draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
					draw_text_add(_ox1 - _oww/2, _yc, _subHov? __txt("Unsubscribe") : __txt("Subscribed"));
					
					if(_subHov && mouse_lpress(_focus))
						UGC_unsubscribe_item(_fid);
						
					break;
			}
			
			var _bs = _ohh;
			var _bx = _ox0 - ui(8) - _bs;
			var _by = _yc - _bs / 2;
			
			var _txt = __txt("Open in Browser");
			if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, _txt, THEME.globe,,,, ui(8) ) == 2) {
				steam_activate_overlay_browser(current_url);
			}
			_bx -= _bs + ui(4);
			
			var _txt = __txt("Open in Explorer")
			if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, _txt, THEME.folder,,,, ui(8) ) == 2) {
				var _info = steam_ugc_get_item_install_info(_fid, ds_map_info);
					
				if(_info) {
					var _dir = ds_map_info[? "folder"];
					shellOpenExplorer(_dir);
				}
			}
			_bx -= _bs + ui(4);
			
			if(item_viewing.type == FILE_TYPE.project) {
				var _txt = __txt("Load Project");
				if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, _txt, THEME.node_goto,,,, ui(8) ) == 2) {
					var _info = steam_ugc_get_item_install_info(_fid, ds_map_info);
						
					if(_info) {
						var _dir = ds_map_info[? "folder"];
						var _fil = file_find_first(_dir + "/*.pxc", 0); file_find_close();
						var _pat = filename_combine(_dir, _fil);
						
						LOAD_PATH(_pat);
					}
				}
				_bx -= _bs + ui(4);
				
			}
			
			if(item_viewing.type == FILE_TYPE.collection) {
				var _txt = __txt("Load Collection to Current Project");
				if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, _txt, THEME.node_goto,,,, ui(8) ) == 2) {
					var _info = steam_ugc_get_item_install_info(_fid, ds_map_info);
						
					if(_info) {
						var _dir = ds_map_info[? "folder"];
						var _fil = file_find_first(_dir + "/*.pxcc", 0); file_find_close();
						var _pat = filename_combine(_dir, _fil);
						
						APPEND(_pat);
					}
				}
				_bx -= _bs + ui(4);
				
			}
		#endregion
		
		#region thumbnail
			var _prev = item_viewing.getPreviewSprite();
			
			var _ths = ui(200);
			var _thx = ui(16);
			var _thy = _yy;
		
			item_viewing.drawThumbnail(_rx, _ry, _thx, _thy, _ths, _ths, 1);
		#endregion
		
		#region actions
			var _vx = _thx;
			var _vy = _thy + _ths + ui(8);
			var _vw = _ths;
			var _bh = ui(28);
			
			if(_hub_stat == 0) {
				draw_sprite_stretched_ext(THEME.button_def, 0, _vx, _vy, _vw, _bh, COLORS._main_icon_light, 1);
				draw_sprite_ui(THEME.loading_s, 0, _vx + _vw/2, _vy + _bh/2, .75, .75, current_time / 2, COLORS._main_icon, .8);
				
			} else if(_hub_stat == 1) {
				var _ax = _vx;
				
				var _currVote = -4;
				if(USER_DATA != undefined) 
					_currVote = USER_DATA.getVoteData(string(item_viewing.file_id));
				
				if(USER_DATA == undefined) {
					draw_sprite_stretched_ext(THEME.button_def, 0, _vx, _vy, _vw, _bh, COLORS._main_icon_light, 1);
					draw_sprite_stretched_ext(THEME.button_def, 3, _vx, _vy, _vw, _bh, COLORS._main_icon, .6);
					
					draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
					draw_text_add(_vx + _vw/2, _vy + _bh/2, __txt("Can't fetch user data."));
					
				} else if(_currVote == -4) {
					draw_sprite_ui(THEME.loading_s, 0, _vx + _vw/2, _vy + _bh/2, .75, .75, current_time / 2, COLORS._main_icon, .8);
					
				} else {
					var _aw = _ths - ui(36+4);
					
					var _hv = _hover && point_in_rectangle(_m[0], _m[1], _ax, _vy, _ax + _aw, _vy + _bh);
					if(_currVote == 1) {
						var _cc = COLORS._main_value_positive;
						draw_sprite_stretched_ext(THEME.box_r2, 0, _ax, _vy, _aw, _bh, _cc, .75 + .1 * _hv);
						draw_sprite_stretched_ext(THEME.box_r2, 1, _ax, _vy, _aw, _bh, _cc, 1);
						BLEND_ADD
						draw_sprite_ui(THEME.vote_up, 0, _ax + _aw/2, _vy + _bh/2, .65, .65, 0, _cc);
						BLEND_NORMAL
						
					} else {
						var _cc = _currVote == 0? COLORS._main_value_positive : COLORS._main_icon;
						draw_sprite_stretched_ext(THEME.box_r2, 0, _ax, _vy, _aw, _bh, _cc, .25);
						draw_sprite_stretched_ext(THEME.box_r2, 1, _ax, _vy, _aw, _bh, _cc, .6 + _hv * .25);
						draw_sprite_ui(THEME.vote_up, 0, _ax + _aw/2, _vy + _bh/2, .65, .65, 0, _cc);
					}
					if(_hv && mouse_lpress(_focus)) item_viewing.HUBVote(1);
						
					_ax += _aw + ui(4);
					_aw  = ui(36);
					var _hv = _hover && point_in_rectangle(_m[0], _m[1], _ax, _vy, _ax + _aw, _vy + _bh);
					if(_currVote == -1) {
						var _cc = COLORS._main_value_negative;
						draw_sprite_stretched_ext(THEME.box_r2, 0, _ax, _vy, _aw, _bh, _cc, .75 + .1 * _hv);
						draw_sprite_stretched_ext(THEME.box_r2, 1, _ax, _vy, _aw, _bh, _cc, 1);
						BLEND_ADD
						draw_sprite_ui(THEME.vote_down, 0, _ax + _aw/2, _vy + _bh/2, .65, .65, 0, _cc);
						BLEND_NORMAL
						
					} else {
						var _cc = _currVote == 0? COLORS._main_value_negative : COLORS._main_icon;
						draw_sprite_stretched_ext(THEME.box_r2, 0, _ax, _vy, _aw, _bh, _cc, .25);
						draw_sprite_stretched_ext(THEME.box_r2, 1, _ax, _vy, _aw, _bh, _cc, .6 + _hv * .25);
						draw_sprite_ui(THEME.vote_down, 0, _ax + _aw/2, _vy + _bh/2, .65, .65, 0, _cc);
					}
					if(_hv && mouse_lpress(_focus)) item_viewing.HUBVote(-1);
				}
				
			} else if(_myitem && _hub_stat == -1) {
				var _hov = _hover && point_in_rectangle(_m[0], _m[1], _vx, _vy, _vx + _vw, _vy + _bh);
				
				draw_sprite_stretched_ext(THEME.button_def, 0, _vx, _vy, _vw, _bh, COLORS._main_icon_light, 1);
				draw_sprite_stretched_ext(THEME.button_def, 3, _vx, _vy, _vw, _bh, COLORS._main_icon, .6 + _hov * .25);
				
				draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
				draw_text_add(_vx + _vw/2, _vy + _bh/2, __txt("Link to PXC hub"));
				
				if(_hov) {
					TOOLTIP = __txtx("pxc_hub_upload_des", "Linking submission to PXC hub will allows for in-software rating and comment (Data separated from Steam Workshop).")
					if(mouse_lpress(_focus)) item_viewing.linkHUB();
				}
				
			} else {
				draw_sprite_stretched_ext(THEME.button_def, 0, _vx, _vy, _vw, _bh, COLORS._main_icon_light, 1);
				draw_sprite_stretched_ext(THEME.button_def, 3, _vx, _vy, _vw, _bh, COLORS._main_icon, .6);
				
				draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
				draw_text_add(_vx + _vw/2, _vy + _bh/2, __txt("Not linked to PXC hub"));
				
			}
			
			_vy += _bh + ui(16);
		#endregion
		
		#region scores
			#region total score
				var _v_up    = item_viewing.getVotesUp();
				var _v_down  = item_viewing.getVotesDown();
				var _v_total = _v_up + _v_down;
				var _vh = ui(4);
				
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
				draw_text_add(_vx + _vw / 2, _vy, "Total Score");
				
				_vy += ui(20);
				
				if(_v_total == 0) {
					draw_set_color(COLORS._main_icon);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
				} else {
					var _v_rat = _v_up / _v_total;
					
					draw_set_color(COLORS._main_value_negative);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
					draw_set_color(COLORS._main_value_positive);
					draw_rectangle(_vx, _vy, _vx + _vw * _v_rat, _vy + _vh, false);
				}
				
				_vy += _vh + ui(4);
				
				var _vty = _vy - ui(20);
				draw_sprite_ui(THEME.vote_up, 0, _vx + ui(8), _vty, .5, .5, 0, COLORS._main_value_positive);
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(_vx + ui(20), _vty, _v_up);
				
				draw_sprite_ui(THEME.vote_down, 0, _vx + _vw - ui(8), _vty, .5, .5, 0, COLORS._main_value_negative);
				draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text);
				draw_text_add(_vx + _vw - ui(20), _vty, _v_down);
				
				_vy += ui(16);
			#endregion
			
			#region hub score
			if(_hub_stat == 1) {
				var _v_up    = _hub_data.votes_up;
				var _v_down  = _hub_data.votes_down;
				var _v_total = _v_up + _v_down;
				var _vh = ui(2);
				
				draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(_vx + _vw / 2, _vy, "PXC hub Score");
				
				_vy += ui(18);
				
				if(_v_total == 0) {
					draw_set_color(COLORS._main_icon);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
				} else {
					var _v_rat = _v_up / _v_total;
					
					draw_set_color(COLORS._main_value_negative);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
					draw_set_color(COLORS._main_value_positive);
					draw_rectangle(_vx, _vy, _vx + _vw * _v_rat, _vy + _vh, false);
				}
				
				_vy += _vh + ui(4);
				
				var _vty = _vy - ui(18);
				draw_sprite_ui(THEME.vote_up, 0, _vx + ui(8), _vty, .5, .5, 0, COLORS._main_value_positive);
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(_vx + ui(20), _vty, _v_up);
				
				draw_sprite_ui(THEME.vote_down, 0, _vx + _vw - ui(8), _vty, .5, .5, 0, COLORS._main_value_negative);
				draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
				draw_text_add(_vx + _vw - ui(20), _vty, _v_down);
				
				_vy += ui(8);
			}
			#endregion
			
			#region steam score
				var _v_up    = item_viewing.votes_up;
				var _v_down  = item_viewing.votes_down;
				var _v_total = _v_up + _v_down;
				var _vh = ui(2);
				
				draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(_vx + _vw / 2, _vy, "Steam Score");
				
				_vy += ui(18);
				
				if(_v_total == 0) {
					draw_set_color(COLORS._main_icon);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
				} else {
					var _v_rat = _v_up / _v_total;
					
					draw_set_color(COLORS._main_value_negative);
					draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
					
					draw_set_color(COLORS._main_value_positive);
					draw_rectangle(_vx, _vy, _vx + _vw * _v_rat, _vy + _vh, false);
				}
				
				_vy += _vh + ui(4);
				
				var _vty = _vy - ui(18);
				draw_sprite_ui(THEME.vote_up, 0, _vx + ui(8), _vty, .5, .5, 0, COLORS._main_value_positive);
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(_vx + ui(20), _vty, _v_up);
				
				draw_sprite_ui(THEME.vote_down, 0, _vx + _vw - ui(8), _vty, .5, .5, 0, COLORS._main_value_negative);
				draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text);
				draw_text_add(_vx + _vw - ui(20), _vty, _v_down);
				
				_vy += ui(8);
			#endregion
		#endregion
		
		#region detail
			var _time_create = item_viewing.time_created_s;
			var _time_create = item_viewing.time_created_s;
			var _type = item_viewing.tag_type;
			var _vers = item_viewing.tag_version;
			var _desc = item_viewing.description;
			var _tags = item_viewing.tags;
			
			var _dsx = _thx + _ths + ui(16);
			var _dsy = _y + _yy;
			var _dsw = _w - ui(16) - _dsx;
			var _sp  = _dsw/4;
			
			var _scis = gpu_get_scissor();
			gpu_set_scissor(_dsx, _yy, _dsw, _h);
			
			_hover = _hover && point_in_rectangle(_m[0], _m[1], _dsx, _yy, _dsx + _dsw, _yy + _h);
			
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_dsx + _sp*0, _dsy, __txt("Type"));
			draw_text_add(_dsx + _sp*1, _dsy, __txt("Version"));
			draw_text_add(_dsx + _sp*2, _dsy, __txt("Created on"));
			
			draw_set_text(f_p2b, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_dsx + _sp*0, _dsy + ui(16), _type);
			draw_text_add(_dsx + _sp*1, _dsy + ui(16), _vers);
			draw_text_add(_dsx + _sp*2, _dsy + ui(16), _time_create);
			
			_dsy += ui(16 + 24)
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			var _tx = _dsx;
			var _ty = _dsy;
			var _x1 = _w - ui(16);
			var _lh = line_get_height() + ui(6);
			
			var _n = array_length(_tags);
			var _a = _n + _myitem;
			
			for( var i = 0; i < _a; i++ ) {
				var _tag = i == _n? "+" : _tags[i];
				if(_tag == _vers || _tag == _type) continue;
				
				var _tw = string_width(_tag) + ui(16);
				if(_tx + _tw + ui(4) > _x1) {
					_tx   = _dsx;
					_ty  += _lh + ui(4);
				}
				
				var _hov = _hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _tw, _ty + _lh);
				
				if(i == _n) {
					draw_sprite_ui(THEME.gear_16, 0, _tx + _tw/2, _ty + _lh/2, 1, 1, 0, _hov? COLORS._main_value_positive : COLORS._main_icon);
					
					if(_hov) {
						if(mouse_lpress(_focus)) {
							with(dialogCall(o_dialog_arrayBox, _rx + _tx, _ry + _ty + _lh + ui(4))) {
								data     = META_TAGS;
								arraySet = other.item_viewing.tags;
								dialog_w = ui(200);
								font     = f_p2;
								mode     = 0;
								addable  = true;
								
								onClose  = other.onSetTag;
							}
						}
					}
					
					if(item_tags_updating)
						draw_sprite_ui(THEME.loading_s, 0, _tx + _tw + ui(4) + _tw/2, _ty + _lh/2, .75, .75, current_time / 2, COLORS._main_icon, .8);
					
				} else {
					draw_sprite_stretched(THEME.box_r2_clr, 0, _tx, _ty, _tw, _lh);
					if(_hov) draw_sprite_stretched(THEME.box_r2_clr, 1, _tx, _ty, _tw, _lh);
					draw_text(_tx + ui(8), _ty + _lh / 2, _tag);
				}
				
				_tx += _tw + ui(4);
				_dsy = max(_dsy, _ty + _lh + ui(4));
			}
			
			_dsy += ui(4);
			draw_set_color(COLORS._main_text_sub);
			draw_line(_dsx, _dsy, _dsx + _dsw, _dsy);
			
			_dsy += ui(10);
			if(_myitem) {
				var _param = new widgetParam(_dsx, _dsy, _dsw, ui(128), _desc, {}, _m)
					.setFont(f_p2).setFocusHover(_focus, _hover)
				var _wh = tb_item_description.drawParam(_param);
				if(item_description_updating)
					draw_sprite_ui(THEME.loading_s, 0, _dsx + _dsw - ui(16), _dsy + ui(16), .75, .75, current_time / 2, COLORS._main_icon, .8);
				
				_dsy += _wh + ui(8);
				
			} else {
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
				draw_text_ext_add(_dsx, _dsy, _desc, -1, _dsw);
				
				_dsy += string_height_ext(_desc, -1, _dsw) + ui(32);
			}
			
			draw_set_color(COLORS._main_text_sub);
			draw_line(_dsx, _dsy, _dsx + _dsw, _dsy);
			
			gpu_set_scissor(_scis);
		#endregion
		
		#region comments
			_dsy += ui(8);
			
			var _comment_enabled = true;
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_dsx, _dsy, __txt("Comments"));
			
			if(_myitem && _hub_stat == 1) {
				_comment_enabled = _hub_data[$ "enable_comment"] ?? true;
				var _chs = ui(20);
				var _chx = _dsx + _dsw - _chs;
				var _chy = _dsy;
				var _hov = _hover && point_in_rectangle(_m[0], _m[1], _chx, _chy, _chx + _chs, _chy + _chs);
				
				draw_set_text(f_p2, fa_right, fa_center, COLORS._main_icon);
				draw_text_add(_dsx + _dsw - ui(24 + 4), _chy + _chs / 2, __txt("Enable comments"));
				
				draw_sprite_stretched(THEME.checkbox_def, _hov, _chx, _chy, _chs, _chs);
				if(_comment_enabled)
					draw_sprite_stretched_ext(THEME.checkbox_def, 2, _chx, _chy, _chs, _chs, COLORS._main_accent);
				
				if(_hov && mouse_lpress(_focus)) {
					_hub_data[$ "enable_comment"] = !_comment_enabled;
					item_viewing.updateHUB({ enable_comment: !_comment_enabled });
				}
			}
			
			_dsy += ui(28);
			
			if(_hub_stat != 1) {
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(_dsx + _dsw / 2, _dsy + ui(32), __txt("Link to PCX hub to enable comments."));
				
			} else if(!_comment_enabled) {
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(_dsx + _dsw / 2, _dsy + ui(32), __txt("Comment disabled"));
				
			} else {
				var _cps = ui(40);
				
				#region make comment
					var _cpx = _dsx;
					var _cpy = _dsy;
					
					if(sprite_exists(STEAM_AVATAR)) draw_sprite_stretched(STEAM_AVATAR, 0, _cpx, _cpy, _cps, _cps);
					draw_sprite_stretched_add(THEME.box_r2, 1, _cpx, _cpy, _cps, _cps, c_white, .35);
					
					var _cmx = _cpx + _cps + ui(8);
					var _cmy = _cpy;
					var _cmw = _w - ui(16) - _cmx;
					
					var _bs = ui(24);
					var _bx = _cmx + _cmw - ui(8) - _bs;
					var _by = _cmy + tb_comment.display_h - ui(8) - _bs;
					var _hov = point_in_rectangle(_m[0], _m[1], _bx, _by, _bx + _bs, _by + _bs);
					
					var _param = new widgetParam(_cmx, _cmy, _cmw, ui(80), comment_text, {}, _m)
						.setFont(f_p2).setFocusHover(_focus && !_hov, _hover, !comment_submitting);
					var _wh = tb_comment.drawParam(_param);
					_cpy += _wh + ui(8);
					
					if(key_press(vk_enter, MOD_KEY.ctrl)) submitComment();
					
					if(comment_submitting)
						draw_sprite_ui(THEME.loading_s, 0, _bx + _bs/2, _by + _bs/2, .75, .75, current_time / 2, COLORS._main_icon, .8);
						
					else if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, "", THEME.send, 0, COLORS._main_value_positive, 1, ui(6)) == 2)
						submitComment();
						
					_dsy = _cpy + ui(8);
				#endregion
				
				if(item_viewing.comment_fetching) {
					var _dcx = (_dsx + _w - ui(16)) / 2;
					draw_sprite_ui(THEME.loading_s, 0, _dcx, _dsy + ui(16), .75, .75, current_time / 2, COLORS._main_icon, .8);
					
				} else {
					var _comments = item_viewing.comments;
					var _toDel = undefined;
					
					for( var i = 0, n = array_length(_comments); i < n; i++ ) {
						var _com = _comments[i];
						
						var _author_id     = _com.author_id;
						var _comment_id    = _com.comment_id;
						var _parent_id     = _com.parent_id;
						var _content       = _com.content;
						var _creation_time = _com.creation_time;
						
						var _cpx = _dsx;
						var _cpy = _dsy;
						
						var _cauth        = Steam_workshop_profile_get(_author_id);
						var _auth_name    = _cauth.getName();
						var _auth_profile = _cauth.getAvatar();
						
						if(sprite_exists(_auth_profile)) draw_sprite_stretched(_auth_profile, 0, _cpx, _cpy, _cps, _cps);
						draw_sprite_stretched_add(THEME.box_r2, 1, _cpx, _cpy, _cps, _cps, c_white, .35);
						var pry = _cpy + _cps + ui(4);
						
						var _cmx = _cpx + _cps + ui(8);
						var _cmy = _cpy;
						var _cmw = _w - ui(16) - _cmx;
						
						draw_set_text(f_p2, fa_left, fa_bottom);
						var _sw = string_width(_auth_name);
						var _sh = line_get_height();
						_cmy += _sh;
						
						var _hv = _hover && point_in_rectangle(_m[0], _m[1], _cmx, _cmy - _sh, _cmx + _sw, _cmy);
						draw_set_color(_hv? COLORS._main_text_accent : COLORS._main_icon);
						draw_text_add(_cmx, _cmy, _auth_name);
						
						if(_hv && mouse_lpress(_focus))
							doViewAuthor = _author_id;
						
						if(_cauth.getPatreon()) {
							var _tx1 = _cmx + _sw + ui(4);
							draw_sprite_ui(THEME.patreon_supporter, 0, _tx1, _cmy - _ui(28), .65, .65, 0, COLORS._main_icon_dark, 1);
				            draw_sprite_ui(THEME.patreon_supporter, 1, _tx1, _cmy - _ui(28), .65, .65, 0, COLORS._main_accent, 1);
						}
					
						var _time = unix_time_get_string(_creation_time);
						var _x1   = _cmx + _cmw;
						
						if(_myitem) {
							var _bs = ui(16);
							var _bx = _x1;
							var _by = _cmy - _sh/2 - _bs/2 + ui(2);
							
							_bx -= _bs;
							if(buttonInstant_Pad(THEME.button_hide, _bx, _by, _bs, _bs, _m, _hover, _focus, "Delete", THEME.cross_16, 0, 
								COLORS._main_value_negative) == 2) 
								_toDel = _com;
								
							_x1 = _bx - ui(8);
						}
						
						draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text_sub);
						draw_text_add(_x1, _cmy, _time);
						
						_cmy += ui(4);
						
						draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
						draw_text_ext_add(_cmx, _cmy, _content, -1, _cmw);
						var _sh = string_height_ext(_content, -1, _cmw);
						_cmy += _sh + ui(8);
						
						_dsy = max(pry, _cmy) + ui(8);
						_com.display_height = _dsy - ui(8) - _cpy;
					}
					
					if(_toDel != undefined)
						item_viewing.deleteComment(_toDel);
				}

			}
		#endregion
		
		_y = _dsy;
		return _y - _ystart;
	}).setUseDepth();
	
	sc_filter = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _hover = sc_filter.hover;
		var _focus = sc_filter.active;
		
		var _w = sc_filter.surface_w;
		var _h = sc_filter.surface_h;
		
		var ww = _w - ui(20);
		var hh = 0;
		
		var x0 = ui(10);
		var y0 = _y;
		
		var mx = _m[0];
		var my = _m[1];
		
		if(hold_filter != 0 && mouse_lrelease()) {
			hold_filter = 0;
			filterFiles();
		}
		
		#region sort
			var bx = x0;
			var by = y0;
			var bw = ww / array_length(sort_types);
			var bh = ui(24)
			
			for( var i = 0, n = array_length(sort_types); i < n; i++ ) {
				var hv = _hover && point_in_rectangle(_m[0], _m[1], bx, by, bx + bw, by + bh);
				if(hv) TOOLTIP = sort_types[i];
				
				if(sort_type != i) {
					var cc = hv? COLORS._main_icon_light : COLORS._main_icon;
					draw_sprite_ui(THEME.workshop_sort, i, bx + bw/2, by + bh/2, .75, .75, 0, cc, 1);
					
					if(hv && mouse_lpress(_focus)) {
						sort_type = i; 
						queryFiles();
					}
					
				} else 
					draw_sprite_ui(THEME.workshop_sort, i, bx + bw/2, by + bh/2, .75, .75, 0, COLORS._main_accent, 1);
				
				bx += bw;
			}
			
			y0 += ui(24 + 4);
			
			draw_set_color(COLORS._main_icon_dark);
			draw_line_width(x0, y0, _w - ui(10), y0, ui(2));
			y0 += ui(4);
			
			if(sort_type == 1) {
				
				var bx = x0;
				var by = y0;
				var bw = ww / array_length(sort_days);
				var bh = ui(24)
			
				for( var i = 0, n = array_length(sort_days); i < n; i++ ) {
					var hv = _hover && point_in_rectangle(_m[0], _m[1], bx, by, bx + bw, by + bh);
					if(hv) TOOLTIP = sort_days_tool[i];
					
					var cc = COLORS._main_accent;
					
					if(sort_trend_day != i) {
						cc = hv? COLORS._main_icon_light : COLORS._main_icon;
						
						if(hv && mouse_lpress(_focus)) {
							sort_trend_day = i;
							queryFiles();
						}
					} 
					
					draw_set_text(f_sdf, fa_center, fa_center, cc);
					draw_text_add(bx + bw/2, by + bh/2, sort_days[i], .35);
					
					bx += bw;
				}
				
				y0 += ui(24 + 4);
				
				draw_set_color(COLORS._main_icon_dark);
				draw_line_width(x0, y0, _w - ui(10), y0, ui(2));
				y0 += ui(4);
			}
			
		#endregion
		
		#region own
			y0 += ui(8);
			
			if(contentPage == 0) {
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = own_filter;
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(mouse_lpress(_focus)) {
						own_filter = !own_filter;
						filterFiles();
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), "Subscribed");
				y0 += ui(22);
			}
		#endregion
		
		#region type
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Type");
			y0 += ui(24);
			
			for (var i = 0, n = array_length(type_strings); i < n; i++) {
				var tg = type_strings[i];
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(type_filter, tg);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(type_filter, tg);
						else if(hold_filter == -1 && !hs) array_push(type_filter, tg);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(type_filter, tg);
						else   array_push(type_filter, tg);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), tg);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		#region tags
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Tags");
			y0 += ui(24);
			
			var _mamo = array_length(META_TAGS);
			var _tamo = _mamo + array_length(custom_tags);
			
			for (var i = 0; i < _tamo; i++) {
				var tg = i < _mamo? META_TAGS[i] : custom_tags[i - _mamo];
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(tag_filter, tg);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(tag_filter, tg);
						else if(hold_filter == -1 && !hs) array_push(tag_filter, tg);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(tag_filter, tg);
						else   array_push(tag_filter, tg);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), tg);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		#region version
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Versions");
			y0 += ui(24);
			
			for (var i = 0, n = array_length(VERSIONS); i < n; i++) {
				var vv = VERSIONS[i];
				var vs = $"1.{vv}";
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(ver_filter, vs);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(ver_filter, vs);
						else if(hold_filter == -1 && !hs) array_push(ver_filter, vs);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(ver_filter, vs);
						else   array_push(ver_filter, vs);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), vs);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		return y0 - _y;
	});
	sc_filter.show_scroll = false;
	
	function drawContent(panel) {
		if(MOUSE_MOVED) hold_tooltip = false;
		
		var _filt_width  = ui(160);
		var _sort_height = ui(32);
		var _page_height = ui(24);
		
		#region actions
			var _ax = padding;
			var _ay = padding;
			var _aw = _filt_width - ui(4);
			var _ah = _sort_height - ui(4);
		
			draw_sprite_stretched(THEME.ui_panel_bg, 1, _ax, _ay, _aw, _ah);
			
			var bx = _ax + ui(4);
			var by = _ay + ui(2);
			var bs = ui(24);
			
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Open in Browser"), THEME.steam, 0, [COLORS._main_icon_light, c_white]) == 2)
				steam_activate_overlay_browser(current_url);
			bx += bs + ui(4);
			current_url = "https://steamcommunity.com/app/2299510/workshop/";
			
			var bc = contentPage == 0? COLORS._main_accent : [COLORS._main_icon, COLORS._main_icon_light];
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Workshop"), THEME.globe, 0, bc, 1, .75) == 2)
				navigate({ type: 0, page: 0 });
			bx += bs;
			
			var bc = contentPage == 1? COLORS._main_accent : [COLORS._main_icon, COLORS._main_icon_light];
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Downloaded"), THEME.download, 0, bc, 1, .7) == 2)
				navigate({ type: 1, page: 1, sort_type: 2 });
			bx += bs;
			
			var bc = contentPage == 2? COLORS._main_accent : [COLORS._main_icon, COLORS._main_icon_light];
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Your Page"), THEME.steam_creator, 0, bc, 1, .8) == 2)
				navigate({ type: 2, page: 0 });
			bx += bs;
			
			if(IS_PATREON) {
				bc = contentPage == 3? COLORS._main_accent : [COLORS._main_icon, COLORS._main_icon_light];
				if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Patreon Contents"), THEME.patreon_supporter, 1, bc, 1, 1) == 2)
					navigate({ type: 3, page: 1 });
				bx += bs;
			}
			
			//////////////////////////////////////////////////////////////////////////
			
			var bx = padding + _filt_width + ui(4);
			var by = _ay + ui(2);
			var bs = ui(24);
			var bc = [COLORS._main_icon, COLORS._main_icon_light];
			
			if(array_empty(history_undo)) draw_sprite_ui(THEME.arrow_wire_16, 2, bx + bs/2, by + bs/2, 1, 1, 0, COLORS._main_icon_dark);
			else if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Previous Page"), THEME.arrow_wire_16, 2, bc) == 2)
				historyBackward();
			
			bx += bs + ui(4);
			
			if(array_empty(history_redo)) draw_sprite_ui(THEME.arrow_wire_16, 0, bx + bs/2, by + bs/2, 1, 1, 0, COLORS._main_icon_dark);
			else if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Next Page"), THEME.arrow_wire_16, 0, bc) == 2)
				historyForward();
			
			bx += bs + ui(4);
			
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Refresh"), THEME.refresh_16, 0, bc) == 2) 
				pageRefresh();
			bx += bs + ui(4);
			
			draw_set_color(COLORS._main_icon_dark);
			draw_line_width(bx, by, bx, by + bs, ui(2));
			bx += ui(8);
			
			if(contentPage == 2 && page > 0 && currentAuthor != undefined) {
				var bw = ui(144);
				if(buttonInstantGlass(pHOVER, pFOCUS, mx, my, bx, by, bw, bs, __txt("Link all to PXC hub")) == 2) {
					for( var i = 0, n = array_length(currentAuthor.projects); i < n; i++ ) 
						currentAuthor.projects[i].updateHUB();
					PXC_HUB_get_data();
				}
				
				bx += bw + ui(4);
			}
			
		#endregion
		
		#region content
			if(item_viewing != undefined) _page_height = 0;
				
			var px = padding + _filt_width;
			var py = padding + _sort_height;
			var pw = w - padding * 2 - _filt_width;
			var ph = h - padding * 2 - _sort_height;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, pw, ph);
			
			var _sc = sc_content;
			if(page == 0) {
				_sc = sc_content_home;
				
				if(author_search_id != undefined)
					_sc = sc_content_author;
					
				if(contentPage == 2)
					_sc = sc_content_author;
			}
			
			if(item_viewing != undefined)
				_sc = sc_content_item;
			
			_sc.verify(pw - ui(16), ph - _page_height - ui(16));
			_sc.setFocusHover(pFOCUS, pHOVER);
			_sc.drawOffset(px + ui(8), py + ui(8), mx, my);
			
			sc_filter.verify(_filt_width, ph - ui(16));
			sc_filter.setFocusHover(pFOCUS, pHOVER);
			sc_filter.drawOffset(padding, py + ui(8), mx, my);
			
			if(pHOVER && key_mod_press(CTRL) && MOUSE_WHEEL != 0) {
				if(MOUSE_WHEEL > 0) grid_size_to = clamp(grid_size_to + ui(8), ui(32), ui(240));
				if(MOUSE_WHEEL < 0) grid_size_to = clamp(grid_size_to - ui(8), ui(32), ui(240));
			}
			
			grid_size = lerp_float(grid_size, grid_size_to, 5);
			
		#endregion
			
		#region search
			var ww = ui(200);
			var hh = _sort_height - padding;
			
			var x0 = px + pw - ww;
			var y0 = padding;
			var yc = y0 + hh / 2;
			
			var _param = new widgetParam(x0, y0, ww, hh, search_string, {}, [mx, my], x, y)
				.setFocusHover(pFOCUS, pHOVER)
				.setFont(f_p2);
				
			tb_search.setBoxColor(search_string == ""? c_white : COLORS._main_accent).drawParam(_param);
			
			if(search_string == "")
				draw_sprite_ui(THEME.search, 0, x0 + ui(16), yc, 1, 1, 0, COLORS._main_icon);
			else {
				var _cx  = x0 + ww - ui(16);
				var _hov = pHOVER && point_in_circle(mx, my, _cx, yc, hh / 2);
				
				draw_sprite_ui(THEME.cross_16, 0, _cx, yc, 1, 1, 0, _hov? COLORS._main_icon_light : COLORS._main_icon);
				
				if(_hov && mouse_lpress(pFOCUS)) {
					tb_search.deactivate();
					search_string = ""; 
					filterFiles();	
				}
			}
			
			if(author_search_id != undefined) {
				var _aut  = STEAM_WORKSHOP_DATA.account[$ author_search_id];
				var _name = _aut.getName();
				
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
				var tw   = string_width(_name) + ui(12 + 16);
				var tx   = x0 - ui(6) - tw;
				var _cx  = tx + ui(12);
				var _hov = pHOVER && point_in_circle(mx, my, _cx, yc, hh / 2);
				
				draw_sprite_stretched_ext(THEME.button_def, 0, tx, y0, tw, hh, COLORS._main_value_positive);
				draw_sprite_stretched_add(THEME.button_def, 3, tx, y0, tw, hh, COLORS._main_value_positive, .25);
				draw_text_add(tx + ui(16 + 6), yc, _name);
				
				draw_sprite_ui(THEME.cross_12, 0, _cx, yc, 1, 1, 0, _hov? COLORS._main_icon_light : COLORS._main_icon);
				
				if(_hov && mouse_lpress(pFOCUS)) {
					author_search_id = undefined; 
					filterFiles();	
				}
			}
		#endregion
		
		#region page
			if(item_viewing == undefined) {
				var _ps = ui(24);
				var _py = py + ph - _page_height / 2 - ui(4);
				var _page_l  = array_length(pageIndex);
				var _page_xc = px + pw / 2;
				var _page_x0 = _page_xc - (_page_l - 1) / 2 * _ps;
				var _pageSet = noone;
				
				if(page_goto != undefined) {
					var _goto_page = KEYBOARD_NUMBER;
					if(key_press(vk_enter)) {
						_pageSet  = clamp(round(_goto_page), 0, pageTotal);
						page_goto = undefined;
						
					} else if(key_press(vk_escape)) {
						page_goto = undefined;
						
					} else if(mouse_lpress()) {
						page_goto = undefined;
						
					}
				}
				
				for( var i = 0; i < _page_l; i++ ) {
					var _page = pageIndex[i];
					var _px = _page_x0 + i * _ps;
					
					if(page_goto == i) {
						draw_sprite_stretched_add(THEME.box_r2, 1, _px - _ps/2, _py - _ps/2, _ps, _ps, COLORS._main_accent, 1);
						draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
						draw_text_add(_px, _py, KEYBOARD_NUMBER ?? "");
						continue;
					}
					
					var _hv = pHOVER && point_in_rectangle(mx, my, _px - _ps/2 + 1, _py - _ps/2, _px + _ps/2 - 1, _py + _ps/2);
					var  cc = COLORS._main_text_sub;
					var _pc = _page == page;
					
					if(_page == -1) {
						if(_hv) {
							cc = COLORS._main_text;
							if(mouse_lpress(pFOCUS)) {
								page_goto = i;
								KEYBOARD_RESET
							}
						}
						
						draw_set_text(f_p2b, fa_center, fa_center, cc);
						draw_text_add(_px, _py, "...");
						continue;
						
					} else if(_page == 0) {
						if(_hv) {
							cc = COLORS._main_text;
							if(mouse_lpress(pFOCUS))
								_pageSet = 0;
						}
						
						if(_pc) {
							cc = COLORS._main_accent;
						}
						
						draw_sprite_ui(THEME.home, 0, _px, _py, .8, .8, 0, cc);
						continue;
					}
					
					if(_pc) cc = COLORS._main_accent;
					if(_hv && !_pc) {
						cc = COLORS._main_text;
						
						if(mouse_lpress(pFOCUS))
							_pageSet = _page;
					}
					
					draw_set_text(f_p2b, fa_center, fa_center, cc);
					draw_text_add(_px, _py, _page);
					
				}
				
				if(pFOCUS) {
					if(key_press(vk_left))  _pageSet = max(page - 1, 1);
					if(key_press(vk_right)) _pageSet = min(page + 1, pageTotal);
				}
				
				if(_pageSet != noone) setPage(_pageSet);
					
				if(page > 0) {
					var _itemCounts = array_length(displayFiles);
					var _str = $"{_itemCounts} items";
					
					draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text_sub);
					draw_text_add(px + pw - ui(8), _py, _str);
				}
			}
			
		#endregion
		
		if(doViewAuthor != undefined) {
			navigate({ type: "author", author: doViewAuthor });
			doViewAuthor = undefined;
		}
		
		if(file_dragging != undefined) {
			var _dist = point_distance(file_drag_x, file_drag_y, mouse_mx, mouse_my);
			if(_dist > ui(16)) {
				file_dragging.dragStart();
				file_dragging = undefined;
			}
			
			if(mouse_lrelease()) {
				if(file_dragging != undefined && is(file_dragging, Steam_workshop_item))
					navigate({ type: "file", file: file_dragging });
				file_dragging = undefined;
			}
		}
	}
	
	queryHomePage();
	queryFiles();
	
}