function Panel_Image_Array_Editor(_junction) : PanelContent() constructor {
	title   = __txt("Array Editor");
	padding = 8;
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
	
	function onResize() { sp_content.resize(w - ui(padding + padding), h - ui(padding + padding)); }
	
	sp_content = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
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
		
		var yy			= _y;
		var drag		= -1;
		var inb_hover	= -1;
		
		for( var i = 0; i < row; i++ ) {
			var ch = ith;
			for( var j = 0; j < col; j++ ) {
				var index = i * col + j;
				if(index >= len) break;
				
				var path = data[index];
				var xx   = (itw + pad) * j;
				
				draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, its, its);
				draw_sprite_stretched_add(THEME.ui_panel, 1, xx, yy, its, its, c_white, 0.2);
				
				if(sp_content.hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + its, yy + its)) {
					sp_content.hover_content = true;
					inb_hover = index;
					
					if(dragging == -1 || dragging == index) 
						draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, its, its, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, sp_content.active))
						dragging = index;
				}
				
				var spr = struct_try_get(SPRITE_PATH_MAP, path, noone);
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
				draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(_txtx, _txty, path);
				
				var _pthx = _txtx - ui(8);
				var _pthy = _txty - ui(2);
				var _pthw = itw - its - ui(16) + ui(8);
				var _pthh = _txth;
				
				if(tb_editing == i) {
				    tb_edit.setFocusHover(sp_content.active, sp_content.hover);
				    tb_edit.draw(_pthx, _pthy, _pthw, _pthh, path, _m);
				}
				
				if(sp_content.hover && point_in_rectangle(_m[0], _m[1], _pthx, _pthy, _pthx + _pthw, _pthy + _pthh)) {
				    draw_sprite_stretched_add(THEME.ui_panel, 1, _pthx, _pthy, _pthw, _pthh, COLORS._main_icon, 0.2);
				    
				    if(mouse_press(mb_left, sp_content.active)) {
				        tb_editing = i;
				        tb_edit.activate(path);
				    }
				}
				
				ch = max(ch, ith + ui(8));
			}
			
			yy += ch;
			_h += ch;
		}
		
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
    				menuItem(__txt("Remove"), function() /*=>*/ { array_delete(data, menuOn, 1); apply(); }, THEME.cross)
    			]);
		    }
		}
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		var msx = mx - px;
		var msy = my - py;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
    	sp_content.setFocusHover(pFOCUS, pHOVER);
    	sp_content.draw(px, py, msx, msy);
    	
    	if(pHOVER) {
    	    if(FILE_IS_DROPPING) draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
    	    
    	    if(FILE_DROPPED && !array_empty(FILE_DROPPING)) {
    	        array_append(data, FILE_DROPPING);
    			apply();
            }
    	}
	}
}