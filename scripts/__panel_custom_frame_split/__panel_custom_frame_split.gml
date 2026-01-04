function Panel_Custom_Frame_Split(_data) : Panel_Custom_Frame(_data) constructor {
	type = "framesplit";
	name = "Split Frame";
	icon = THEME.panel_icon_element_frame_split;
	
	style      = 0;
	split_dir  = 0;
	split_amou = .5; split_amou_frac =  true;
	split_spac =  0; split_spac_frac = false;
	
	adjustable  = false;
	adjustRange = [0,1];
	adjusting   = false;
	adjust_ss   = 0;
	adjust_mm   = 0;
	
	adjust_area = [0,0,1,1,1,1];
	
	array_append(editors, [
		[ "Split Frame", false ], 
		Simple_Editor("Axis", new scrollBox( [ 
			"Horizontal", 
			"Vertical", 
		], function(t) /*=>*/ { split_dir = t; } ), function() /*=>*/ {return split_dir}, function(t) /*=>*/ { split_dir = t; }), 
		
		Simple_Editor("Amount",     textBox_Number( function(v) /*=>*/ { split_amou = v; } ), function() /*=>*/ {return split_amou}, function(v) /*=>*/ { split_amou = v; }), 
		Simple_Editor("Fractional", new checkBox( function() /*=>*/ { split_amou_frac = !split_amou_frac; } ), function() /*=>*/ {return split_amou_frac}, function(v) /*=>*/ { split_amou_frac = v; }), 
		
		Simple_Editor("Spacing",    textBox_Number( function(v) /*=>*/ { split_spac = v; } ), function() /*=>*/ {return split_spac}, function(v) /*=>*/ { split_spac = v; }), 
		Simple_Editor("Fractional", new checkBox( function() /*=>*/ { split_spac_frac = !split_spac_frac; } ), function() /*=>*/ {return split_spac_frac}, function(v) /*=>*/ { split_spac_frac = v; }), 
		
		[ "Adjustable", false ], 
		Simple_Editor("Adjustable",   new checkBox( function() /*=>*/ { adjustable = !adjustable; } ), function() /*=>*/ {return adjustable}, function(v) /*=>*/ { adjustable = v; }), 
		Simple_Editor("Adjust Range", new rangeBox( function(v,i) /*=>*/ { adjustRange[i] = v; } ), function() /*=>*/ {return adjustRange}, function(v) /*=>*/ { adjustRange = v; }), 
	]);
	
	static setSize = function(_pBbox, _rx, _ry) {
		pbBox.setBase(_pBbox);
		bbox = pbBox.getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		var spw = (split_spac_frac? split_spac * w : split_spac) / 2;
		var sph = (split_spac_frac? split_spac * h : split_spac) / 2;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var _x = x, _y = y;
			var _w = w, _h = h;
			
			if(i == 0) {
			    if(split_dir == 0) {
			     	_w = (split_amou_frac? w * split_amou : split_amou) - spw;
			     	
					adjust_area[0] = _x + _w;
					adjust_area[1] = _y;
					
				} else if(split_dir == 1) {
					_h = (split_amou_frac? h * split_amou : split_amou) - sph;
					
					adjust_area[0] = _x;
					adjust_area[1] = _y + _h;
					
				}
				
				contents[i].pbBox.fixed_box = [ _x, _y, _x + _w, _y + _h];
				contents[i].draggable       = false;
				
			} else if(i == 1) {
				if(split_dir == 0) {
					_w = split_amou_frac? w * split_amou : split_amou;
					_x = x + _w + spw;
					_w = w - _w - spw;
					
					adjust_area[2] = _x;
					adjust_area[3] = _y + _h;
					
				} else if(split_dir == 1) {
					_h = split_amou_frac? h * split_amou : split_amou;
					_y = y + _h + sph;
					_h = h - _h - sph;
					
					adjust_area[2] = _x + _w;
					adjust_area[3] = _y;
					
				}
				
				contents[i].pbBox.fixed_box = [ _x, _y, _x + _w, _y + _h];
				contents[i].draggable       = false;
				
			}
			
			contents[i].setSize(bbox, _rx, _ry);
		}
		
		adjust_area[4] = adjust_area[2] - adjust_area[0];
		adjust_area[5] = adjust_area[3] - adjust_area[1];
		
		rx = _rx;
		ry = _ry;
	}
	
	static drawFrame = function(panel, _m) {
		if(!adjustable) return;
		
		var _hov = panel._hovering_frame == self;
		    _hov = _hov && point_in_rectangle(_m[0], _m[1], adjust_area[0], adjust_area[1], adjust_area[2], adjust_area[3]);
		  
		if(adjusting) draw_sprite_stretched_add(THEME.box_r2, 0, adjust_area[0], adjust_area[1], adjust_area[4], adjust_area[5], COLORS._main_icon, .4);
		else if(_hov) draw_sprite_stretched_add(THEME.box_r2, 0, adjust_area[0], adjust_area[1], adjust_area[4], adjust_area[5], COLORS._main_icon, .2);
		
		if(_hov) {
			if(mouse_lpress(focus)) {
				adjusting   = true;
				
				if(split_dir == 0) {
					adjust_ss   = split_amou_frac? w * split_amou : split_amou;
					adjust_mm   = _m[0];
					
				} else if(split_dir == 1) {
					adjust_ss   = split_amou_frac? h * split_amou : split_amou;
					adjust_mm   = _m[1];
				}
			}
		}
		
		if(adjusting) {
			if(split_dir == 0) {
				var dx = adjust_ss + (_m[0] - adjust_mm);
				    dx = clamp(dx, adjustRange[0] * w, adjustRange[1] * w);
				
				split_amou = split_amou_frac? dx / w : dx;
				
			} else if(split_dir == 1) {
				var dy = adjust_ss + (_m[1] - adjust_mm);
				    dy = clamp(dy, adjustRange[0] * h, adjustRange[1] * h);
				
				split_amou = split_amou_frac? dy / h : dy;
			}
			
			if(mouse_lrelease())
				adjusting = false;
		}
	}
	
	static postBuild = function() {
		contents = [
			new Panel_Custom_Frame(data),
			new Panel_Custom_Frame(data),
		];
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			contents[i].parent          = self;
			contents[i].pbBox.fixed_box = [0,0,1,1];
			contents[i].draggable       = false;
		}
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.split_dir  = split_dir;
		
		_m.split_amou = split_amou; _m.split_amou_frac = split_amou_frac;
		_m.split_spac = split_spac; _m.split_spac_frac = split_spac_frac;
		
		_m.adjustable = adjustable; 
	}
	
	static frameDeserialize = function(_m) {
		split_dir  = _m[$ "split_dir"]  ?? split_dir;
		
		split_amou = _m[$ "split_amou"] ?? split_amou; split_amou_frac = _m[$ "split_amou_frac"] ?? split_amou_frac;
		split_spac = _m[$ "split_spac"] ?? split_spac; split_spac_frac = _m[$ "split_spac_frac"] ?? split_spac_frac;
		
		adjustable = _m[$ "adjustable"]  ?? adjustable;
		return self;
	}
}