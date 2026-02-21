#region classes
	function md_block() constructor { 
		pad = 0;
		txt = "";
		
		lineH     = 0;
		lineColor = undefined;
		
		x = 0;
		y = 0;
		
		static setPad   = function(p) /*=>*/ { pad       = p; return self; }
		static setBG    = function(c) /*=>*/ { lineColor = c; return self; }
	}
	
	function md_block_text(_txt) : md_block() constructor { 
		txt = _txt;
		sym = undefined;
		
		scale = 1;
		font  = f_p2;
		color = COLORS._main_text;
		
		static parse  = function( ) /*=>*/ { sym = markdown_parse_line(txt); }
		
        /// @desc setFont
        /// @param {any} f font
        /// @returns {Struct.md_block_text}
		static setFont  = function(f) /*=>*/ { font      = f; return self; }
        
		/// @desc setColor
        /// @param {any} c color
        /// @returns {Struct.md_block_text}
		static setColor = function(c) /*=>*/ { color     = c; return self; }
	}
	
	function md_ln()     : md_block_text("")   constructor { font = f_p2; }
	function md_h1(_txt) : md_block_text(_txt) constructor {  }
	function md_h2(_txt) : md_block_text(_txt) constructor {  }
	function md_h3(_txt) : md_block_text(_txt) constructor {  }
	function md_h4(_txt) : md_block_text(_txt) constructor {  }
	function md_li(_txt) : md_block_text(_txt) constructor { font = f_p2; color = COLORS._main_text; }
	function md_p (_txt) : md_block_text(_txt) constructor { font = f_p2; color = COLORS._main_text; }
	
	function md_line_x(_width)  : md_block() constructor { width  = _width;  }
	function md_line_y(_height) : md_block() constructor { height = _height; }
	function md_line_s(_spr)    : md_block() constructor { spr    = struct_try_get(THEME, _spr); }
	
	function mb_group_start(_name) : md_block() constructor { name  = _name;  }
	function mb_group_end(_group)  : md_block() constructor { group = _group; }
	
#endregion

function markdown_parse_line(line) {
	var _splits = string_split(line, " ");
	var _symbol = [];
	var symStck = ds_stack_create();
	
	for( var i = 0, n = array_length(_splits); i < n; i++ ) {
		var _spl = _splits[i];
		
		if(string_starts_with(_spl, "<") && string_ends_with(_spl, ">")) {
			_spl = string_copy(_spl, 2, string_length(_spl) - 2);
			var _type = string_char_at(_spl, 1);
			var _val  = string_copy(_spl, 2, string_length(_spl) - 1);
			
			switch(_type) {
				case "x" : _symbol[i] = new md_line_x(real(_val)); break;
				case "y" : _symbol[i] = new md_line_y(real(_val)); break;
				case "s" : _symbol[i] = new md_line_s(_val);       break;
			}
			
			continue;
		}
		
		if(string_starts_with(_spl, "[")) {
			_spl = string_copy(_spl, 2, string_length(_spl) - 1);
			ds_stack_push(symStck, "[");
		}
		
		if(string_starts_with(_spl, "`")) {
			_spl = string_copy(_spl, 2, string_length(_spl) - 1);
			ds_stack_push(symStck, "`");
		}
		
		var _s = new md_p(_spl);
		
		switch(ds_stack_top(symStck)) {
			case "[" : 
				if(string_ends_with(_spl, "]")) {
					_spl   = string_copy(_spl, 1, string_length(_spl) - 1);
					_s.txt = _spl;
					
					ds_stack_pop(symStck);
				}
				
				_s.setFont(f_p2b).setColor(COLORS._main_text_accent);
				break;
				
			case "`" :
				if(string_ends_with(_spl, "`")) {
					_spl   = string_copy(_spl, 1, string_length(_spl) - 1);
					_s.txt = _spl;
					
					ds_stack_pop(symStck);
				}
				
				_s.setFont(f_p3).setColor(CDEF.main_mdwhite);
				break;
		}
		
		_symbol[i] = _s;
	}
	
	ds_stack_destroy(symStck);
	
	return _symbol;
}

function markdown_parse(md) {
	static symbols = [ " ", "#", "-" ];
	
	var _lines = string_split(md, "\n");
	var  lines = [];
	var  group = ds_stack_create();
	
	for( var i = 0, n = array_length(_lines); i < n; i++ ) {
		var line = _lines[i];
		var trim = string_trim(line);
		    trim = string_replace_all(trim, "**", ""); // Remove bold because that's no support for it anyway
		
		if(string_starts_with(trim, "{") && string_ends_with(trim, "}")) {
			var _gName = string_copy(trim, 2, string_length(trim) - 2);
			if(!ds_stack_empty(group) && _gName == ds_stack_top(group).name) {
				var _grp = ds_stack_pop(group);
				array_push(lines, new mb_group_end(_grp));
				
			} else {
				var _grp = new mb_group_start(_gName);
				array_push(lines, _grp);
				ds_stack_push(group, _grp);
			}
			continue;
		}
		
		string_replace_all(line, "\t", " ");
		
		var lraw   = string_trim_start(trim, symbols);
		var mdLine = undefined;
		
		     if(trim == "") mdLine = new md_ln();
		else if(string_starts_with(trim, "####")) mdLine = new md_h4(lraw);
		else if(string_starts_with(trim, "###"))  mdLine = new md_h3(lraw);
		else if(string_starts_with(trim, "##"))   mdLine = new md_h2(lraw);
		else if(string_starts_with(trim, "#"))    mdLine = new md_h1(lraw);
		else if(string_starts_with(trim, "-")) {
			var _pad = ui(28) + string_count_start(line, " ") * ui(10);
			mdLine = new md_li(lraw).setPad(_pad);
			
		} else mdLine = new md_p(lraw);
		
		mdLine.parse();
		if(mdLine != undefined) array_push(lines, mdLine);
	}
	
	ds_stack_destroy(group);
	return lines;
}

function markdown_draw_symbols(symbols, xx, yy, ww) {
	var lineX = xx;
	var lineW = 0;
	var lineH = 0;
	var hh    = 0;
	
	var _x = lineX;
	var _y = yy;
	
	for( var i = 0, n = array_length(symbols); i < n; i++ ) {
		var _symb = symbols[i];
		
		if(is(_symb, md_block_text)) {
			var _word = _symb.txt;
			if(i) _word = " " + _word;
			
			draw_set_text(_symb.font, fa_left, fa_bottom, _symb.color);
			var _w = string_width(_word);
			var _h = string_height(_word);
			
			if(lineW + _w > ww) {
				_x  = lineX;
				_y += lineH;
				hh += lineH;
				
				lineW = 0;
				lineH = 0;
				
				_word = _symb.txt;
				_w    = string_width(_word);
			}
			
			draw_text(_x, _y + line_get_height(f_p2), _word);
			
			_x    += _w;
			lineW += _w;
			lineH  = max(lineH, _h);
			
		} else if(is(_symb, md_line_x)) {
			_x = lineX + ui(_symb.width);
		
		} else if(is(_symb, md_line_y)) {
			_y += ui(_symb.height);
			
		} else if(is(_symb, md_line_s)) {
			var _spr = _symb.spr;
			
			if(sprite_exists(_spr)) {
				var _ss = .75;
				var _sw = sprite_get_width(_spr)  * _ss;
				var _sh = sprite_get_height(_spr) * _ss;
				
				gpu_set_tex_filter(true);
				draw_sprite_ext(_spr, 0, _x + _sw / 2, _y + lineH / 2, _ss, _ss, 0, COLORS._main_icon);
				gpu_set_tex_filter(false);
				
				_x    += _sw;
				lineW += _sw;
			}
			 
			
		}
	}
	
	hh += lineH;
	return hh;
}

function markdown_draw(lines, xx, yy, ww) {
	var hh  = 0;
	var prv = undefined;
	
	for( var i = 0, n = array_length(lines); i < n; i++ ) {
		var line = lines[i];
		var text = line.txt;
		var padd = line.pad;
		var linH = 0;
		var hg   = 0;
		
		line.x = 0;
		line.y = hh;
		
		switch(instanceof(line)) {
			case "md_h1" : 
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_sub);
				hg  = (!!i) * ui(16);
				draw_text_line(xx, yy + hg, text, -1, ww);
				hg += string_height_ext(text, -1, ww) + ui(4);
				break;
				
			case "md_h2" : 
				draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_sub);
				var _h = string_height_ext(text, -1, ww);
				hg = (!!i) * ui(16);
				draw_sprite_stretched_ext(THEME.box_r5_clr, 1, xx, yy + hg - ui(4), ww, _h + ui(8), COLORS._main_icon, 1);
				draw_text_line(xx + ui(16), yy + hg, text, -1, ww);
				hg += string_height_ext(text, -1, ww) + ui(8);
				break;
				
			case "md_h3" : 
				draw_set_text(f_p2b, fa_left, fa_top, COLORS._main_text_sub);
				hg += (!!i) * ui(8);
				draw_text_line(xx + ui(24), yy + hg, text, -1, ww);
				hg += string_height_ext(text, -1, ww) + ui(8);
				break;
				
			case "md_h4" : 
				
				break;
				
			case "md_li" : 
				draw_sprite_ui_uniform(THEME.text_bullet, 0, xx + padd - ui(8), yy + ui(12), 1, COLORS._main_icon);
				hg = markdown_draw_symbols(line.sym, xx + padd, yy, ww - padd) + ui(2);
				break;
				
			case "md_p"  : 
				hg = markdown_draw_symbols(line.sym, xx + padd, yy, ww - padd) + ui(2);
				break;
				
			case "md_ln" :
				if(instanceof(prv) != "md_ln")
					hg = line_get_height(line.font);
				break;
				
			case "mb_group_start" : 
				if(line.lineH != 0)
				switch(line.name) {
					case "g" : 
						draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, xx, yy + ui(4) - ui(8), ww, line.lineH + ui(16), CDEF.main_mdwhite);  
						draw_sprite_stretched_ext(THEME.ui_panel,    1, xx, yy + ui(4) - ui(8), ww, line.lineH + ui(16), #090915);  
						break;
						
					case "d" : 
						draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, xx + ui(10), yy + ui(4), ww - ui(20), line.lineH, CDEF.main_ltgrey); 
						break;
				}
				
				line.lineH = hh;
				hg = ui(4);
				break;
				
			case "mb_group_end" : 
				line.group.lineH = hh - line.group.lineH;
				hg = ui(4);
				break;
				
		}
		
		yy += hg;
		hh += hg;
		
		prv = line;
	}

	return hh;
}