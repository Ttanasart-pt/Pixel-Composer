/// @description init
event_inherited();

#region display
	draggable = false;
	destroy_on_click_out = true;
	
	target = noone;
	
	dialog_w = ui(608);
	dialog_h = ui(320);
	
	anchor = ANCHOR.top | ANCHOR.right;
	
	dialog_resizable = true;
	dialog_w_min = ui(200);
	dialog_h_min = ui(120);
	dialog_w_max = ui(640);
	dialog_h_max = ui(480);
#endregion

#region context
	context = global.ASSETS;
	
	function gotoDir(dirName) {
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			var d = global.ASSETS.subDir[| i];
			if(d.name != dirName) continue;
			
			d.open = true;
			setContext(d);
		}
	}
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
#endregion

#region surface
	folderW = ui(180);
	content_w = dialog_w - ui(32) - folderW;
	content_h = dialog_h - ui(32);
	
	function onResize() {
		content_w = dialog_w - ui(32) - folderW;
		content_h = dialog_h - ui(32);
		contentPane.resize(content_w, content_h);
		folderPane.resize(folderW - ui(16), content_h - ui(32));
	}
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var contents = context.content;
		var amo      = ds_list_size(contents);
		var hh = 0;
		var frame = current_time * PREF_MAP[? "collection_preview_speed"] / 8000;
		
		var grid_size = ui(64);
		var img_size  = grid_size - ui(16);
		var grid_space = ui(12);
		var col = max(1, floor(content_w / (grid_size + grid_space)));
		var row = ceil(amo / col);
		var yy  = _y + grid_space;
			
		hh += grid_space;
		
		for(var i = 0; i < row; i++) {
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index < amo) {
					var content = contents[| index];
					var xx   = grid_space + (grid_size + grid_space) * j;
					
					BLEND_OVER
					draw_sprite_stretched(THEME.node_bg, 0, xx, yy, grid_size, grid_size);
					BLEND_NORMAL
						
					if(sHOVER && contentPane.hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grid_size, yy + grid_size)) {
						draw_sprite_stretched_ext(THEME.node_active, 0, xx, yy, grid_size, grid_size, COLORS._main_accent, 1);
						if(mouse_press(mb_left, sFOCUS)) {
							target.onModify(content.path);
							instance_destroy();
						}
					}
					
					var spr = content.getSpr();
					if(sprite_exists(spr)) {
						var sw = sprite_get_width(spr);
						var sh = sprite_get_height(spr);
						var ss = img_size / max(sw, sh);
						var sx = xx + (grid_size - sw * ss) / 2;
						var sy = yy + (grid_size - sh * ss) / 2;
						
						draw_sprite_ext(spr, frame, sx, sy, ss, ss, 0, c_white, 1);
					}
				}
			}
			var hght = grid_size + grid_space;
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
	
	folderPane = new scrollPane(folderW - ui(16), content_h - ui(32), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var hh = 8;
		
		for(var i = 0; i < ds_list_size(global.ASSETS.subDir); i++) {
			var hg = global.ASSETS.subDir[| i].draw(self, ui(8), _y + 8, _m, folderPane.w - ui(16), 
				sHOVER && folderPane.hover, sFOCUS, global.ASSETS);
			hh += hg;
			_y += hg;
		}
		
		return hh + 8;
	});
#endregion