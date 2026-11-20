function toggleGroupOrder(_arraySet, _data, _onModify = noone) : widget() constructor {
	arraySet = _arraySet;
	data     = _data;
	onModify = _onModify;
	
	toggling = undefined;
	dragging = undefined;
	
	toggleMap = {};
	
	static fetchHeight = function(params) { 
		var hg = line_get_height(params.font, 4);
		return hg * max(1, array_safe_length(data));
	}
		
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		
		var hg = line_get_height(font, 4);
		h = hg * max(1, array_safe_length(data));
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, h);
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h))
			draw_sprite_stretched_ext(THEME.textbox, 1, _x, _y, _w, h, boxColor, 1);	
		
		var toggleMap = {};
		for( var i = 0, n = array_length(arraySet); i < n; i++ )
			toggleMap[$ arraySet[i]] = 1;
		
		var bs = hg - ui(8);
		updateList = false;
		
		for( var i = 0, n = array_length(data); i < n; i++ ) {
			var _dat = data[i];
			var _tog = toggleMap[$ _dat] == 1;
			
			var tx = _x;
			var ty = _y + hg * i;
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
			
			if(dragging == undefined || dragging == _dat) {
				var hx = tx + tw - hg;
				var hy = ty;
				
				var hHov = hover && point_in_rectangle(_m[0], _m[1], hx, hy, hx + hg, hy + hg);
				var cc   = dragging == _dat? COLORS._main_accent : (hHov? COLORS._main_icon_light : COLORS._main_icon);
				var aa   = hHov || dragging == _dat? 1 : .5; 
				draw_sprite_ui_uniform(THEME.hamburger_s, 0, hx + hg / 2, hy + hg / 2, .75, cc, aa);
				
				if(hHov && mouse_lpress(active)) dragging = _dat;
			}
		}
		
		
		if(toggling != undefined) {
			if(mouse_lrelease()) {
				toggling = undefined;
			}
		}
			
		if(dragging != undefined) {
			if(mouse_lrelease()) {
				dragging = undefined;
			}
		}
		
		if(updateList) {
			var arr = [];
			for( var i = 0, n = array_length(data); i < n; i++ )
				if(toggleMap[$ data[i]] == 1) array_push(arr, data[i]);
				
			onModify(arr);
		}
			
		resetFocus();
		return h;
	}
	
}