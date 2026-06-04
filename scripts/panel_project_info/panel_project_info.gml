function Panel_Project_Info() : PanelContent() constructor {
	project = PROJECT;
	title   = "Project Info";
	w = ui(320);
	h = ui(480);
	
	static bs = function(b) /*=>*/ {return b? "True" : "False"};
	
	dataList = [
		"Project",
		[ "Name",        filename_name_only(project.path)                                                 ],
		[ "Author",      project.meta.author                                                              ],
		[ "Use Steam",   bs(project.meta.author_steam_id != 0)                                            ],
		-1,
		[ "Version",     project.version                                                                  ],
		[ "Nightly",     bs(project.is_nightly)                                                           ],
		[ "Read-Only",   bs(project.readonly)                                                             ],
		[ "Safe Mode",   bs(project.safeMode)                                                             ],
		-1,
		[ "Usage Time",  function() /*=>*/ {return string_time_format(project.usage_timer)}                                    ],
		
		-1,
		"Animation",
		[ "Total Frames", project.animator.frames_total                                                   ],
		[ "Framerate",    project.animator.framerate                                                      ],
		[ "Play Speed",   project.animator.play_speed                                                     ],
		[ "Use Range",    bs(project.animator.useRange())                                                 ],
		[ "Region Count", array_length(project.animationRegions)                                          ],
		[ "Marker Count", array_length(project.timelineMarkers)                                           ],
		[ "Slideshow",    bs(project.useSlideShow)                                                        ],
		
		-1,
		"File",
		[ "File Size",   string_byte_format(file_exists_empty(project.path)? file_size(project.path) : 0) ],
		[ "Node Counts", array_length(project.allNodes)                                                   ],
		[ "Load Layout", bs(project.load_layout)                                                          ],
		[ "Favourited",  array_length(project.favoritedValues)                                            ],
		[ "Panels",      array_length(project.customPanels)                                               ],
		
	];
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h  = ui(8);
		var yy = _y + ui(8);
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		var hg = line_get_height(f_p2, 4);
		var hl = 1;
		
		for( var i = 0, n = array_length(dataList); i < n; i++ ) {
			var _data = dataList[i];
			
			if(_data == -1) {
				hl = true;
				yy += hg;
				_h += hg;
				continue;
			}
			
			if(is_string(_data)) {
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(ww / 2, yy, _data);
				
				hl = true;
				yy += hg;
				_h += hg;
				continue;
			}
			
			if(hl) draw_sprite_stretched_add(THEME.box_r2, 0, 0, yy, ww, hg, c_white, .05);
			
			var _topic = __txt(_data[0]);
			var _cont  = _data[1];
			if(is_method(_cont)) _cont = _cont();
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(ui(8), yy, _topic);
			
			draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text);
			draw_text_add(ww - ui(8), yy, _cont);
			
			hl = !hl;
			yy += hg;
			_h += hg;
		}
		
		return _h + ui(32);
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_content.verify(pw, ph);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(px, py, mx - px, my - py);
		
	}
}