function toggleGroupOrder(_data, _onModify = noone) : widget() constructor {
	dataGet  = _data;
	data     = [];
	
	onModify = _onModify;
	
	toggling = undefined;
	
	dragging    = 0;
	dragItem    = undefined;
	dragOrd     = 0;
	dragging_my = 0;
	
	static fetchHeight = function(params) { 
		data = dataGet();
		var hg = line_get_height(params.font, 4);
		return hg * max(1, array_safe_length(data));
	}
		
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _arraySet, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		
		var hg = line_get_height(font, 4);
		h = hg * max(1, array_safe_length(data));
		data = dataGet();
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, h, COLORS._main_icon);
		draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, h, boxColor, .5);	
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h))
			draw_sprite_stretched_add(THEME.textbox, 1, _x, _y, _w, h, boxColor, .3);	
		
		var toggleMap = {};
		for( var i = 0, n = array_length(_arraySet); i < n; i++ )
			toggleMap[$ _arraySet[i]] = 1;
		
		var bs = hg - ui(8);
		updateList = false;
		
		var ty = _y;
		
		var hovI = _m[1] > _y + h - hg / 2? array_length(data) : 0;
    	var hovY = _m[1] > _y + h - hg / 2? _y + h : _y;
    	
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _dat = data[i];
			var _tog = toggleMap[$ _dat] == 1;
			
			var tx = _x;
			var tw = _w;
			var th = hg;
			
			var bx = tx + hg / 2 - bs / 2;
			var by = ty + hg / 2 - bs / 2;
			draw_sprite_stretched_ext(THEME.box_r2, 1, bx, by, bs, bs, COLORS._main_icon, .5);
			if(_tog) draw_sprite_stretched_ext(THEME.box_r2, 0, bx + ui(2), by + ui(2), bs - ui(4), bs - ui(4), COLORS._main_accent);
			
			var bHov = hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + hg, ty + hg);
			if(bHov) {
				draw_sprite_stretched_add(THEME.box_r2, 1, bx, by, bs, bs, COLORS._main_icon, .3);	
				
				if(toggling != undefined && toggling != _tog) {
					toggleMap[$ _dat] = toggling;
					updateList = true;
				}
				
				if(mouse_lpress(active))
					toggling = !_tog;
			}
			
			var lx = tx + hg + ui(4);
			var ly = ty + hg / 2;
			
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text_add(lx, ly, _dat);
			
			if(dragging == 0 || dragItem == _dat) {
				var hx = tx + tw - hg;
				var hy = ty;
				
				var hHov = hover && point_in_rectangle(_m[0], _m[1], hx, hy, hx + hg, hy + hg);
				var cc   = dragging == _dat? COLORS._main_accent : (hHov? COLORS._main_icon_light : COLORS._main_icon);
				var aa   = hHov || dragging == _dat? 1 : .5; 
				draw_sprite_ui_uniform(THEME.hamburger_s, 0, hx + hg / 2, hy + hg / 2, .75, cc, aa);
				
				if(hHov && mouse_lpress(active)) {
					dragging = 1;
					dragItem = _dat;
					
					dragging_my = _m[1];
				}
			}
			
			if(_m[1] > ty && _m[1] <= ty + th && dragging == 2) {
				if(_m[1] < ty + hg / 2) {
					hovI = i;
					hovY = ty;
					
				} else {
					hovI = i + 1;
					hovY = ty + hg;
					
				}
			}
			
			ty += hg;
		}
		
		if(toggling != undefined && mouse_lrelease())
			toggling = undefined;
				
    	if(dragging == 1) {
			array_remove(data, dragItem);
			dragging = 2;
    	}
    	
    	if(dragging == 2) {
    		draw_set_color(COLORS._main_accent);
    		draw_line_round(_x + ui(8), hovY, _x + _w - ui(8), hovY, ui(2));
    		dragOrd = hovI;
    		
    		var tolw = ui(16) + string_width(dragItem);
    		var tolh = ui( 8) + hg;
    		
    		draw_sprite_stretched_ext(THEME.box_r2_clr, 0, _m[0], _m[1], tolw, tolh);
    		draw_set_text(font, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_m[0] + ui(8), _m[1] + ui(4), dragItem);
    		
    		if(mouse_lrelease()) {
    			array_insert(data, hovI, dragItem);
				updateList = true;
    			dragging   = 0;
    		}
    	}
    	
		if(updateList) {
			var arr = [];
			for( var i = 0, n = array_length(data); i < n; i++ )
				if(toggleMap[$ data[i]] == 1) array_push(arr, data[i]);
			onModify(arr, data);
		}
			
		resetFocus();
		return h;
	}
	
}