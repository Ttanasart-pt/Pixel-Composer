function Panel_Image_Array_Editor(_junction) : PanelContent() constructor {
	title   = __txt("Array Editor");
	target  = _junction;
	data    = target.getValue();
	
	w = ui(400);
	h = ui(640);
	
	menuOn   = -1;
	dragging = -1;
	drag_spr = -1;
	sortAsc  = true;
	
	tb_editing = -1;
	tb_edit  = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ {
	    if(tb_editing == -1) return;
	    if(!target) return;
	    
	    data[@ tb_editing] = str;
	    target.node.triggerRender();
	});
	
	tb_edit.font = f_p3;
	tb_edit.onDeactivate = function() { tb_editing = -1; }
	
	function apply() { target.setValue(data); target.node.triggerRender(); }
	
	function rearrange(oldindex, newindex) {
		if(oldindex == newindex) return;
		
		var val = data[oldindex];
		array_delete(data, oldindex, 1);
		array_insert(data, newindex, val);
		
		apply();
	}
	
	function sortByName() {
		if(!target) return 0;
		
		array_sort(data, bool(sortAsc));
		sortAsc = !sortAsc;
		
		apply();
	}
	
	function onResize() { sp_content.resize(w - padding * 2, h - padding * 2); }
	
	sp_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		if(!target) return 0;
		
		draw_clear_alpha(CDEF.main_mdblack, 1);
		
		var _h = ui(8);
		
		var itw = ui(320);
		var ith = ui(64);
		var its = ui(64);
		var pad = ui(16);
		
		var len = array_length(data);
		var col = max(1, floor((sp_content.surface_w - pad) / (itw + pad)));
		var row = ceil(len / col);
		
		itw = (sp_content.surface_w - pad) / col - pad;
		
		var hover = sp_content.hover;
		var focus = sp_content.active;
		
		var yy			= _y;
		var drag		= -1;
		var inb_hover	= -1;
		var scr = gpu_get_scissor();
		
		for( var i = 0; i < row; i++ ) {
			var ch = ith;
			for( var j = 0; j < col; j++ ) {
				var index = i * col + j;
				if(index >= len) break;
				
				var path = data[index];
				var xx   = (itw + pad) * j;
				
				draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, its, its);
				draw_sprite_stretched_add(THEME.ui_panel, 1, xx, yy, its, its, c_white, 0.2);
				
				if(hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + its, yy + its)) {
					sp_content.hover_content = true;
					inb_hover = index;
					
					if(dragging == -1 || dragging == index) 
						draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, its, its, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, focus))
						dragging = index;
				}
				
				var rpath = path_get(path);
				var spr   = struct_try_get(SPRITE_PATH_MAP, rpath, noone);
				if(spr == noone || !sprite_exists(spr)) 
					spr = s_texture_default;
				
				var spr_w = sprite_get_width(spr);
				var spr_h = sprite_get_height(spr);
				var spr_s = min((its - ui(16)) / spr_w, (its - ui(16)) / spr_h);
				var spr_x = xx + its / 2 - spr_w * spr_s / 2;
				var spr_y = yy + its / 2 - spr_h * spr_s / 2;
				
				var aa = dragging == -1? 1 : (dragging == index? 1 : 0.5);
				draw_sprite_ext(spr, 0, spr_x, spr_y, spr_s, spr_s, 0, c_white, aa);
				
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
				var name  = filename_name_only(path);
				var txt_h = string_height_ext(name, -1, itw);
				var _txtx = xx + its + ui(16);
				var _txty = yy + ui(4);
				
				draw_text_ext_add(_txtx, _txty, name, -1, itw);
				
				var _txth = line_get_height(f_p3, 4);
				var _txty = yy + its - _txth;
				
				var _pthx = _txtx - ui(8);
				var _pthy = _txty - ui(2);
				var _pthw = itw - its - ui(16) + ui(8);
				var _pthh = _txth;
				
				gpu_set_scissor(_pthx, _pthy, _pthw - ui(8), _pthh);
				draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(_txtx, _txty, path);
				gpu_set_scissor(scr);
				
				if(tb_editing == i) {
				    tb_edit.setFocusHover(focus, hover);
				    tb_edit.draw(_pthx, _pthy, _pthw, _pthh, path, _m);
				}
				
				if(hover && point_in_rectangle(_m[0], _m[1], _pthx, _pthy, _pthx + _pthw, _pthy + _pthh)) {
				    draw_sprite_stretched_add(THEME.ui_panel, 1, _pthx, _pthy, _pthw, _pthh, COLORS._main_icon, 0.2);
				    
				    if(mouse_press(mb_left, focus)) {
				        tb_editing = i;
				        tb_edit.activate(path);
				    }
				}
				
				ch = max(ch, ith + ui(8));
			}
			
			yy += ch;
			_h += ch;
		}
		
		gpu_set_scissor(scr);
		
		if(dragging != -1) {
			if(inb_hover != -1) {
				rearrange(dragging, inb_hover);
				dragging = inb_hover;
			}
			
			if(mouse_release(mb_left))
				dragging = -1;
		}
		
		if(mouse_press(mb_right, sp_content.active)) {
		    menuOn = inb_hover;
		    
		    if(inb_hover == -1) {
		        menuCall("image_array_edit_menu_empty", [
    				menuItem(__txt("Add") + "...", function() /*=>*/ { 
    				    var path = get_open_filenames_compat("image|*.png;*.jpg", "");
                		if(path == "") return;
                		
            			var paths = string_splice(path, "\n");
            			array_append(data, paths);
            			apply();
    				}, THEME.add),
    				menuItem(__txt("Sort"), function() /*=>*/ { sortByName(); }, THEME.text)
    			]);
		    } else {
		        menuCall("image_array_edit_menu", [
    				menuItem(__txt("Copy to Project"), function() /*=>*/ { 
    					var project = PROJECT;
						if(project.path == "") {
							noti_warning("Save the current project first.")
							return;
						}
						
						var _pth = data[menuOn];
						if(!file_exists(_pth)) return;
						
						var _nam = filename_name(_pth);
						var _dir = filename_dir(project.path);
						
						var _newpath = _dir + "/" + _nam;
						file_copy(_pth, _newpath);
						data[menuOn] = "./" + _nam;
						apply();
						
    				}, THEME.copy_20),
    				menuItem(__txt("Remove"), function() /*=>*/ { array_delete(data, menuOn, 1); apply(); }, THEME.cross),
    			]);
		    }
		}
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var tamo = 2;
		var ptw  = ui(24 + 2) * tamo - ui(2) + ui(12);
		var pth  = ui(24 + 6);
		
		draw_sprite_stretched(THEME.ui_panel_bg,   1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_content.setToolRect(ptw, pth);
    	sp_content.setFocusHover(pFOCUS, pHOVER);
    	sp_content.drawOffset(px, py, mx, my);
    	
		draw_sprite_stretched(THEME.ui_panel_tool, 0, px + pw + ui(8) - ptw, py - ui(8), ptw, pth);
		
		var bs = ui(24);
		var bx = px + pw + ui(8) - bs;
		var by = py - ui(8);
		
		var bc = COLORS._main_value_positive;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, "Add...", THEME.add, 0, bc, 1, .75) == 2) {
			var path = get_open_filenames_compat("image|*.png;*.jpg", "");
    		if(path == "") return;
    		
			var paths = string_splice(path, "\n");
			array_append(data, paths);
			apply();
		}
		
		bx -= bs + ui(2);
		
		var bc = COLORS._main_icon;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, "Sort by Name", THEME.text, 0, bc, 1, .75) == 2) {
			sortByName();
		}
		
    	if(pHOVER) {
    	    if(FILE_IS_DROPPING) draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
    	    
    	    if(FILE_DROPPED && !array_empty(FILE_DROPPING)) {
    	        array_append(data, FILE_DROPPING);
    			apply();
            }
    	}
	}
}