function Panel_Release_Note() : PanelContent() constructor {
	title = "Release note";
	w     = ui(800);
	h     = ui(560);
	auto_pin = true;
	
	#region data
		page_width = DEMO? 0 : ui(132);
		pages      = [ "Release note", "Downloads" ];
		page       = 0;
		
		content_w = w - padding - page_width;
		content_h = h - padding * 2;
	#endregion
	
	#region note
		note_pre = "https://gist.githubusercontent.com/Ttanasart-pt/f21a140906a60c6e12c99ebfecec1645/raw/";
		note_dir = "https://raw.githubusercontent.com/Ttanasart-pt/Pixel-Composer/refs/heads/main/releases/"
		note_get = http_get(note_dir + RELEASE_STRING + ".md");
		note     = "";
		noteMd   = [];
		
		note_issues_get = 0;
		note_issues     = "";
		note_issuesMd   = [];
		
		if(OS == os_linux) 
			note_issues_get = http_get(note_dir + "Linux Known issues.md");
		
		sp_note = new scrollPane(content_w, content_h, function(_y, _m) {
			draw_clear_alpha(COLORS.dialog_splash_badge, 1);
			
			var xx = ui(8);
			var yy = ui(8) + _y;
			var ww = sp_note.surface_w - ui(16);
			var hh = 0;
			
			gpu_set_colorwriteenable(1,1,1,0);
			
			if(note_issues != "") {
				var _h = markdown_draw(note_issuesMd, xx, yy, ww);
				hh += _h + ui(16);
				yy += _h + ui(16);
			}
			
			var _h = markdown_draw(noteMd, xx, yy, ww);
			hh += _h;
			
			gpu_set_colorwriteenable(1,1,1,1);
			
			return hh + ui(64);
		})
	#endregion
	
	#region downloads
		dl_get = undefined;
		
		if(!DEMO) {
			dl_get       = http_get(DOWNLOAD_LINKS);
			dls          = [];
			downloading  = {};
			dl_selecting = noone;
			
			section_list     = [];
			section_collapse = {};
			
			function toggleDownload(dl) {
				var verObj = dl;
				var link   = "";
				var fname  = "";
				
				if(is_array(dl)) {
					verObj = array_safe_get( dl, 0, undefined );
					link   = array_safe_get( dl, 1, "" );
					fname  = array_safe_get( dl, 2, "" );
					
				} else if(is_struct(dl))
					link   = dl.link;
				
				if(!is_struct(verObj)) return;
				
				if(fname == "")
					fname = $"PixelComposer {verObj.version}.zip";
				
				var _path = get_save_filename_ext("Any", fname, "", "Download location");
				var _dir  = filename_dir(_path);
				
				if(_dir != "") {
					verObj.status        = 1;
					verObj.download_path = _path;
					
					var _get = http_get_file(link, _path);
					downloading[$ _get] = verObj;
				}
			}
			
			sp_dl = new scrollPane(content_w, content_h, function(_y, _m) {
				draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
				
				var sw = sp_dl.surface_w;
				var ww = sw - ui(16);
				
	    		var group_labels = [];
	    		var currSec      = undefined;
	    		
	    		var sectColl = false;
	    		var sectH    = ui(24);
	    		var lbh      = sectH + ui(8 + 4);
	    		
				var xx = ui(8);
				var yy = ui(8) + _y;
				
	    		var _hover = pHOVER && _m[1] > lbh;
	    		var _focus = pFOCUS;
	    		
	    		#region section bg
	    			var len = array_length(section_list);
	    			for( var i = 0, n = array_length(section_list); i < n; i++ ) {
	    				var lb = section_list[i];
	    				var _name = lb.text;
	    				var _key  = lb.key;
	    				var _lbh  = lb.y1 - lb.y;
	    				
	    				var _coll = struct_try_get(section_collapse, _key, 0);
	    				
	    				var scx = 0;
	    				var scy = lb.y;
	    				var scw = sw;
	    				var sch = sectH;
	    				
	    				if(!_coll) draw_sprite_stretched_add(THEME.box_r5, 0, scx, scy, scw, _lbh, COLORS.panel_bg_clear, .2);
	    			}
	    		#endregion
	    		
				for( var i = 0, n = array_length(dls); i < n; i++ ) {
					var dl = dls[i];
					
					if(is_string(dl)) {
						if(currSec) { 
	    					var _coll = struct_try_get(section_collapse, currSec.key, 0);
	    					if(!_coll) yy += ui(10);
	    					else       yy += ui(4);
	    				}
	    				
	    				sectColl  = struct_try_get(section_collapse, dl, 0);
	    				currSec   = { y: yy, text: dl, key: dl, y1: yy };
	    				array_push(group_labels, currSec);
	    				
	    				yy += sectH + ui(!sectColl * 6 + 2);
	    				continue;
					}
					
	    			if(sectColl) continue;
	    			
	    			var vers = dl.version;
					var type = dl.type;
					
					if(dl.status == 2 && !file_exists(dl.download_path))
						dl.status = 0;
					
					var hh   = ui(28);
					var hov  = _hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh);
					
					var oss  = has(dl, "links");
					var osL  = oss && has(dl.links, "linux");
					var osM  = oss && has(dl.links, "mac");
					
					var hv_os   = 0;
					var hv_link = dl.link;
					switch(OS) {
						case os_linux :   if(osL) hv_os = 1; break;
						case os_macosx :  if(osM) hv_os = 2; break;
					}
					
					var tx = xx + ui(16);
					var ty = yy + ui(4);
					
					switch(type) {
						case "stable" : draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_accent); break;
						case "beta"   : draw_set_text(f_p2,  fa_left, fa_top, COLORS._main_text);        break;
						case "alpha"  : draw_set_text(f_p3,  fa_left, fa_top, COLORS._main_text);        break;
					}
					
					draw_text(tx, yy + ui(4), vers);
					
					tx = ui(112);
					ty += string_height(vers) / 2;
					
					if(hov && point_in_circle(_m[0], _m[1], tx, ty, ui(12))) { 
						setTOOLTIP("Download for Windows");
						hv_link = dl.link;
						hv_os   = 0; 
					}
					
					if(osL && hov && point_in_circle(_m[0], _m[1], tx + ui(24 * 1), ty, ui(12))) { 
						setTOOLTIP("Download for Linux");
						hv_link = dl.links.linux;
						hv_os   = 1; 
					}
					
					if(osM && hov && point_in_circle(_m[0], _m[1], tx + ui(24 * 2), ty, ui(12))) { 
						setTOOLTIP("Download for Mac OS");
						hv_link = dl.links.mac;
						hv_os   = 2; 
					}
					
					var _cc = (hov && hv_os == 0)? COLORS._main_icon_light : COLORS._main_icon;
					draw_sprite_ui_uniform(THEME.icon_os_windows, 0, tx, ty, .6, _cc, .75 + (hov && hv_os == 0) * .25);
					tx += ui(24);
						
					if(osL) {
						var _cc = (hov && hv_os == 1)? COLORS._main_icon_light : COLORS._main_icon;
						draw_sprite_ui_uniform(THEME.icon_os_linux, 0, tx, ty, .6, _cc, .75 + (hov && hv_os == 1) * .25);
						tx += ui(24);
					}
					
					if(osM) {
						var _cc = (hov && hv_os == 2)? COLORS._main_icon_light : COLORS._main_icon;
						draw_sprite_ui_uniform(THEME.icon_os_mac, 0, tx, ty, .6, _cc, .75 + (hov && hv_os == 2) * .25);
						tx += ui(24);
					}
					
					if(hov) {
						draw_sprite_stretched_ext(THEME.box_r2, 0, ui(4), yy, sw - ui(8), hh, COLORS._main_icon, .1);
						
						if(dl.status == 0) {
							
							if(mouse_lpress(_focus)) {
								switch(hv_os) {
									case  1 : toggleDownload([dl, dl.links.linux, $"PixelComposer {vers}.AppImage"]); break;
									case  2 : toggleDownload([dl, dl.links.mac,   $""]); break;
									default : toggleDownload(dl);
								}
								
							}
							
							if(mouse_rpress(_focus)) {
								var _menu = [
									menuItem("Open URL", function(p) /*=>*/ {return url_open(p)}).setParam(hv_link),
									-1,
								]
								
								array_append(_menu, dl.dMenu);
								menuCall("", _menu);
							}
						
						} else if(dl.status == 2) {
							if(mouse_lpress(_focus)) 
								shellOpenExplorer(filename_dir(dl.download_path));
							
							if(mouse_rpress(_focus)) {
								dl_selecting = dl;
								var _menu = [
									menuItem("Open Folder", function() /*=>*/ {return shellOpenExplorer(filename_dir(dl_selecting.download_path))}),
									menuItem("Delete File", function() /*=>*/ {
										file_delete(dl_selecting.download_path);
										dl_selecting.download_path = "";
										dl_selecting.status = 0;
									}),
									menuItem("Open URL", function(p) /*=>*/ {return url_open(p)}).setParam(hv_link), 
									-1,
								];
								
								array_append(_menu, dl.dMenu);
								menuCall("", _menu);
							}
							
						} else if(dl.status == -1) {
							if(mouse_lpress(_focus)) 
								url_open(hv_link);
							
						}
					}
					
					if(dl.status == 1) {
						var _bw  = ww - ui(172 + 80 + 8);
						var _bh  = ui(12);
						
						var _bx  = xx + ui(172);
						var _by  = yy + hh / 2 - _bh / 2;
						var _prg = dl.size_total == 0? 0 : dl.size_downloaded / dl.size_total;
						
						draw_sprite_stretched(THEME.progress_bar, 0, _bx, _by, _bw,      _bh);
						draw_sprite_stretched(THEME.progress_bar, 1, _bx, _by, _bw*_prg, _bh);
						
					} else if(dl.status == 2) {
						draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
						
						var _scis = gpu_get_scissor();
						gpu_set_scissor(xx, yy, ww - ui(80), hh);
						draw_text_add(xx + ui(172), yy + ui(6), dl.download_path);
						gpu_set_scissor(_scis);
						
					} else if(dl.status == -1) {
						draw_set_text(f_p3, fa_left, fa_top, COLORS._main_value_negative);
						
						var _scis = gpu_get_scissor();
						gpu_set_scissor(xx, yy, ww - ui(16), hh);
						draw_text_add(xx + ui(172), yy + ui(6), $"HTTP get error {dl.statusMsg} : open the download link in browser.");
						gpu_set_scissor(_scis);
					}
					
					if(dl.status) {
						draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
						draw_text(xx + ww - ui(8), yy + ui(6), string_byte_format(dl.size_total));
						
					}
					
	    			if(currSec) currSec.y1 = max(currSec.y1, yy + hh + ui(6));
					yy += hh + ui(2);
				}
				
	    		#region section label
	    			var len = array_length(group_labels);
	    			if(len) {
	    				draw_set_color(COLORS.panel_bg_clear_inner);
	    				draw_rectangle(0, 0, sw, lbh, false);
	    			}
	    			
	    			var _cAll = 0;
	    			var scs = gpu_get_scissor();
	    			
	    			for( var i = 0; i < len; i++ ) {
	    				var lb = group_labels[i];
	    				var _name = lb.text;
	    				var _key  = lb.key;
	    				
	    				var _coll = struct_try_get(section_collapse, _key, 0);
	    				var _yy   = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
	    				var _hv   = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _yy, sw, _yy + sectH);
	    				var _lbh  = lb.y1 - _yy;
	    				
	    				var scx = 0;
	    				var scy = _yy;
	    				var scw = sw;
	    				var sch = sectH;
	    				
	    				if(_coll) {
	    					draw_sprite_stretched_ext(THEME.section_separator, 0, scx, scy, scw, _coll? sch : _lbh, COLORS.section_bg);
	    				} else {
	    					gpu_set_scissor(scx, 0, scw, lbh+1);
	    					draw_sprite_stretched_add(THEME.box_r5, 0, scx, scy, scw, _lbh, COLORS.panel_bg_clear, .2);
	    					gpu_set_scissor(scs);
		    				
		            		var hovCnt = pHOVER && point_in_rectangle(_m[0], _m[1], scx, scy, scx + scw, scy + _lbh);
		            		if(hovCnt) draw_sprite_stretched_add(THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover, .4);
	    				}
	            		
	                	if(!_coll) draw_sprite_stretched_ext( THEME.section_separator, 2, scx, scy, scw, sch, COLORS.section_selected  );
	                	if(_hv) {
	                		draw_sprite_stretched_ext( THEME.section_separator, 3, scx, scy, scw,  sch, COLORS.section_hover, .2 );
	                		draw_sprite_stretched_ext( THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover     );
	                	}
	    				
	    				if(_hv && pFOCUS) {
	                    	if(DOUBLE_CLICK) {
	                    		_cAll = _coll? -1 : 1;
	                    		
	                    	} else if(mouse_lpress()) {
	                        	if(_coll) struct_set(section_collapse, _key, 0);
	                        	else      struct_set(section_collapse, _key, 1);
	                        }
	                    }
	                    
	    				draw_sprite_ui(THEME.arrow, _coll? 0 : 3, ui(16), _yy + sectH / 2, 1, 1, 0, COLORS._main_text_sub, 1);    
	    				
	    				draw_set_text(f_p2, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
	    				draw_text_add(ui(28), _yy + sectH / 2, _name);
	    			}
	    			
	    				 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) struct_set(section_collapse, group_labels[i].key, 0); } 
	    			else if(_cAll == -1) { for( var i = 0; i < len; i++ ) struct_set(section_collapse, group_labels[i].key, 1); }
	    			
	    			section_list = group_labels;
	    		#endregion
	    		
				return yy + ui(64) - _y;
			})
		}
	#endregion
	
	static asyncCallback = function(async_load) {
		var _id     = ds_map_find_value(async_load, "id");
		var _status = ds_map_find_value(async_load, "status");
		
		if (_id == note_get) {
		    if (_status == 0) {
		        note   = ds_map_find_value(async_load, "result");
		        noteMd = markdown_parse(note);
				alarm[0] = 1;
			}
			
		} else if (_id == note_issues_get) {
		    if (_status == 0) {
		        note_issues   = ds_map_find_value(async_load, "result");
		        note_issuesMd = markdown_parse(note_issues);
				alarm[0] = 1;
			}
			
		} else if (_id == dl_get) {
			if (_status == 0) {
		        var res = ds_map_find_value(async_load, "result");
				dls = json_try_parse(res, []);
				
				for( var i = 0, n = array_length(dls); i < n; i++ ) {
					var  d = dls[i];
					var _v = d.version;
					
					d.status            = 0;
					d.statusMsg         = "";
					d.download_path     = "";
					
					d.size_total      = 0;
					d.size_downloaded = 0;
					
					if(struct_has(PREFERENCES.versions, _v)) {
						var _path =  PREFERENCES.versions[$ _v];
						
						if(file_exists(_path)) {
							d.status          = 2;
							d.download_path   = _path;
							d.size_total      = file_size(_path);
						}
					}
					
					var oss  = struct_has(d, "links");
					if(oss) {
						var _ls = d.links;
						_menu = [ menuItem("Download for Windows", function(p) /*=>*/ {return toggleDownload(p)}).setParam([d, _ls.windows, ""]) ];
						if(struct_has(_ls, "linux")) 
							array_push(_menu, menuItem("Download for Linux",  function(p) /*=>*/ {return toggleDownload(p)})
								.setParam([d, _ls.linux, $"PixelComposer {_v}.AppImage"]));
							
						if(struct_has(_ls, "mac"))   
							array_push(_menu, menuItem("Download for Mac OS", function(p) /*=>*/ {return toggleDownload(p)})
								.setParam([d, _ls.mac, $""]));
						
					} else
						_menu = [ menuItem("Download", function(p) /*=>*/ {return toggleDownload(p).setParam(d)}) ];
						
					d.dMenu = _menu;
				}
				
				var prevLab = "";
				for( var i = 0; i < array_length(dls); i++ ) {
					var dl   = dls[i];
					if(!is_struct(dl)) continue;
					if(dl.type != "stable") continue;
					
					var stxt = dl.version;
					var splt = string_split(stxt, ".");
					
					var vmaj = array_safe_get(splt, 1, "0");
					var slab = $"1.{vmaj}";
					
					if(prevLab != slab) {
						array_insert(dls, i, slab);
						prevLab = slab;
						i++;
					}
				}
				
				if(!array_empty(dls) && !is_string(dls)) array_insert(dls, 0, "wip");
			}
			
		} else if (struct_has(downloading, _id)) {
			var dl = downloading[$ _id];
			
			if(ds_map_exists(async_load, "http_status")) {
				var _http_status   = ds_map_find_value(async_load, "http_status");
				dl.statusMsg = _http_status;
			}
			
			if(_status == 0) {
				if(dl.size_downloaded < 10000) {
					dl.status = -1;
					
				} else {
					dl.status = 2;
					PREFERENCES.versions[$ dl.version] = dl.download_path;
					PREF_SAVE();
				}
				
			} else if(_status == 1) {
				dl.size_total      = ds_map_find_value(async_load, "contentLength");
				dl.size_downloaded = ds_map_find_value(async_load, "sizeDownloaded");
				
			} else 
				noti_warning($"HTTP get error {_status}");
		}
	}
	
	function drawContent(panel) {
	    draw_clear_alpha(COLORS.panel_bg_clear, 1);
	    
		var _x = ui(16);
		var _y = ui(16);
		var hg = line_get_height(f_p1, 8);
		
		draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
		
		if(!DEMO)
		for( var i = 0, n = array_length(pages); i < n; i++ ) {
			draw_set_font(f_p0b);
			var r  = __txt(pages[i]);
			var rw = string_width(r);
			
			var px = _x - ui(8);
			var py = _y - ui(4);
			var pw = page_width - ui(16);
			var ph = hg;
			
			if(pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph - 1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, px, py, pw, ph, CDEF.main_white, 1);
				
				if(i != page && mouse_lpress(pFOCUS))
					page = i;
			}
		
			draw_set_font(i == page? f_p1b : f_p1);
			draw_set_color(i == page? COLORS._main_text : COLORS._main_text_sub);
			draw_text(_x, _y, r);
			
			if(i == 1 && NEW_VERSION) {
				var _x1 = _x + string_width(r);
				var _y1 = _y + ui(3);
				draw_sprite_ui(THEME.circle_16, 0, _x1, _y1, .4, .4, 0, COLORS._main_value_positive);
			}
				
			_y += hg;
		}
		
		var _px = page_width + ui(8);
		var _py = padding;
		var _pw = w - padding - page_width;
		var _ph = h - padding - padding;
		
		content_w = _pw;
		content_h = _ph;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _px - ui(8), _py - ui(8), _pw + ui(16), _ph + ui(16));
		
		if(page == 0) {
			sp_note.setFocusHover(pFOCUS, pHOVER);
			sp_note.verify(content_w, content_h);
			sp_note.drawOffset(_px, _py, mx, my);
			
		} else if(page == 1) {
			sp_dl.setFocusHover(pFOCUS, pHOVER);
			sp_dl.verify(content_w, content_h);
			sp_dl.drawOffset(_px, _py, mx, my);
			
		}
	    
	}
}