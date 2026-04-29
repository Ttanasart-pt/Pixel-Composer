function Panel_System_Info() : PanelContent() constructor {
	title = "System Info";
	w = ui(360);
	h = ui(400);
	
	osInfo = os_get_info();
	cpuVen = cpu_vendor();
	
	data = [
		[ "PXC Version:",       $"{VERSION_STRING} ({VERSION})"     ],
		[ "Operating system:",  $"{os_type_sting()} ({os_version})" ],
		[ "Architecture:",      $"{os_architecture()}"              ],
		[ "Product name:",      $"{os_product_name()}"              ],
		-1, 
		[ "CPU:",               $"{cpu_processor()}"                ],
		[ "CPU cores:",         $"{cpu_core_count()}/{cpu_processor_count()} cores" ],
		-1, 
		[ "RAM total:",         $"{memory_totalram(true)}"          ],
		[ "RAM used:",          $"{memory_usedram(true)}"           ],
		[ "RAM free:",          $"{memory_freeram(true)}"           ],
		-1, 
		[ "GPU:",               $"{gpu_renderer()}"                 ],
		-1,
		[ "VRAM:",              $"{memory_totalvram(true)}"         ],
	];
	
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h  = 0;
		var yy = _y;
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
		var lh = line_get_height(f_p3, 2);
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _d = data[i];
			
			if(_d == -1) { 
				yy += ui(4); 
				draw_set_color(COLORS.panel_separator);
				draw_line_round(ui(4), yy, ww - ui(4), yy, ui(2));
				yy += ui(4); 
				_h += ui(8); 
				continue; 
			}
			
			var _title = _d[0];
			var tx = ui(4);
			
			draw_set_color(COLORS._main_text_sub);
			draw_text_add(tx, yy, _title);
			tx += string_width(_title) + ui(8);
			
			var _cont  = _d[1];
			draw_set_color(COLORS._main_text);
			draw_text_add(tx, yy, _cont);
			
			yy += lh;
			_h += lh;
		}
		
		return _h;
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