function IO_Redirect(_data) constructor {
	uuid = UUID_generate();
	name = "Redir";
	data = _data;
	data.io_redirect_map[$ uuid] = self;
	
	type      = CONNECT_TYPE.input;
	junctions = [];
	
	input     = new JuncLister(data, "input", CONNECT_TYPE.output);
	tb_rename = textBox_Text(function(t) /*=>*/ { name = t; });
	
	static getDisplayName = function() /*=>*/ {return name};
	
	static getJunction = function(_depth = 0) {
		if(_depth > 16) {
			noti_warning($"Too many redirect.")
			return undefined;
		}
		
		var _jun = input.getJunction(_depth + 1);
		var _ind = 0;
		
		if(_jun) _ind = _jun.getValue();
		
		var _dir = array_safe_get(junctions, _ind, noone);
		if(_dir == noone) return undefined;
		
		return _dir.getJunction(_depth + 1);
	}
	
	////- Draw
	
	prop_h = 0;
	static drawProp = function(_x, _y, _w, _m, _hov, _foc, _rx, _ry) {
		var _h = ui(8);
		var hg = ui(20);
		
		if(prop_h) draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, prop_h, COLORS.node_composite_bg_blend, 1);
		_x += ui(4);
		_y += ui(4);
		_w -= ui(8);
		
		var bs = THEME.button_hide;
		var bw = ui(24);
		var bh = hg;
		var bx = _x;
		var by = _y;
		var spr = type == CONNECT_TYPE.input? THEME.panel_icon_element_node_input : THEME.panel_icon_element_node_output;
		if(buttonInstant_Pad(bs, bx, by, bw, bh, _m, _hov, _foc, "", spr, 0, c_white, 1, ui(6)) == 2) {
			type = !type;
			junctions = [];
		}
		
		var wdx = _x + bw + ui(4);
		var wdy = _y;
		var wdw = _w - ui(24 + 4 + 4) - bw;
		var wdh = hg;
		var _param = new widgetParam(wdx, wdy, wdw, wdh, name, {}, _m, _rx, _ry).setFont(f_p3).setHide(2);
		tb_rename.setFocusHover(_foc, _hov);
		tb_rename.drawParam(_param);
		
		var bw = ui(24);
		var bh = hg;
		var bx = _x + _w - bw;
		var by = _y;
		if(buttonInstant_Pad(bs, bx, by, bw, bh, _m, _hov, _foc, "", THEME.add_16, 0, COLORS._main_value_positive, 1, ui(6)) == 2)
			array_push(junctions, new JuncLister(data, "junc"));
		
		_y += hg + ui(4);
		_h += hg + ui(4);
		
		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
		draw_text_add(_x + ui(4 + 24), _y + hg / 2, "input");
		
		var wdx = _x + ui(4 + 48);
		var wdy = _y;
		var wdw = _w - ui(4 + 48 + 4) - bw - ui(4);
		var wdh = hg;
		var hh = input.draw(wdx, wdy, wdw, wdh, _m, _foc, _hov, _rx, _ry);
		
		_y += hg + ui(4);
		_h += hg + ui(4);
		
		var toDel = undefined;
		for( var i = 0, n = array_length(junctions); i < n; i++ ) {
			var _j = junctions[i];
			_j.name = $"{i}";
			_j.type = type;
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(4 + 24), _y + hg / 2, _j.name);
			
			var wdx = _x + ui(4 + 48);
			var wdy = _y;
			var wdw = _w - ui(4 + 48 + 4) - bw - ui(4);
			var wdh = hg;
			
			var hh = _j.draw(wdx, wdy, wdw, wdh, _m, _foc, _hov, _rx, _ry);
			
			var bx = _x + _w - bw - ui(4);
			var by = _y;
			if(buttonInstant_Pad(bs, bx, by, bw, bh, _m, _hov, _foc, "", THEME.cross_16, 0, COLORS._main_value_negative, 1, ui(6)) == 2)
				toDel = i;
				
			_y += hh + ui(4);
			_h += hh + ui(4);
		}
		
		if(toDel != undefined) array_delete(junctions, toDel, 1);
		
		prop_h = _h;
		return _h;
	}
	
	////- Serialize
	
	static serialize = function() {
		var _m  = {};
		_m.uuid = uuid;
		_m.type = type;
		_m.junc = array_map(junctions, function(j,i) /*=>*/ {return j.serialize()});
		_m.inpt = input.serialize();
		
		return _m;
	}
	
	static deserialize = function(_m) { 
		uuid = _m.uuid;
		type = _m.type;
		
		junctions = array_map(_m.junc, function(j,i) /*=>*/ {return new JuncLister(data, "").deserialize(j)});
		input.deserialize(_m.inpt);
		
		data.io_redirect_map[$ uuid] = self;
		return self;
	}
}