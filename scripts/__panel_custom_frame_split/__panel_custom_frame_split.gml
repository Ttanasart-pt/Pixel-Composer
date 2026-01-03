function Panel_Custom_Frame_Split() : Panel_Custom_Frame() constructor {
	type = "framesplit";
	name = "Split Frame";
	icon = THEME.panel_icon_element_frame_split;
	
	style = 0;
	split_dir  = 0;
	split_amou = .5; split_amou_frac =  true;
	split_spac =  0; split_spac_frac = false;
	
	array_append(editors, [
		[ "Split Frame", false ], 
		new Panel_Custom_Element_Editor("Axis", new scrollBox( [ 
			"Horizontal", 
			"Vertical", 
		], function(t) /*=>*/ { split_dir = t; } ), function() /*=>*/ {return split_dir}, function(t) /*=>*/ { split_dir = t; }), 
		
		new Panel_Custom_Element_Editor("Amount",     textBox_Number( function(v) /*=>*/ { split_amou = v; } ), function() /*=>*/ {return split_amou}, function(v) /*=>*/ { split_amou = v; }), 
		new Panel_Custom_Element_Editor("Fractional", new checkBox( function() /*=>*/ { split_amou_frac = !split_amou_frac; } ), function() /*=>*/ {return split_amou_frac}, function(v) /*=>*/ { split_amou_frac = v; }), 
		
		new Panel_Custom_Element_Editor("Spacing",    textBox_Number( function(v) /*=>*/ { split_spac = v; } ), function() /*=>*/ {return split_spac}, function(v) /*=>*/ { split_spac = v; }), 
		new Panel_Custom_Element_Editor("Fractional", new checkBox( function() /*=>*/ { split_spac_frac = !split_spac_frac; } ), function() /*=>*/ {return split_spac_frac}, function(v) /*=>*/ { split_spac_frac = v; }), 
	]);
	
	static setSize = function(_pBbox, _rx, _ry) {
		pbBox.base_bbox = _pBbox.getBBOX();
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
				     if(split_dir == 0) _w = (split_amou_frac? w * split_amou : split_amou) - spw;
				else if(split_dir == 1) _h = (split_amou_frac? h * split_amou : split_amou) - sph;
				
				contents[i].pbBox.fixed_box = [ _x, _y, _x + _w, _y + _h];
				contents[i].draggable       = false;
				
			} else if(i == 1) {
				if(split_dir == 0) {
					_w = split_amou_frac? w * split_amou : split_amou;
					_x = x + _w + spw;
					_w = w - _w - spw;
					
				} else if(split_dir == 1) {
					_h = split_amou_frac? h * split_amou : split_amou;
					_y = y + _h + sph;
					_h = h - _h - sph;
					
				}
				
				contents[i].pbBox.fixed_box = [ _x, _y, _x + _w, _y + _h];
				contents[i].draggable       = false;
				
			}
			
			contents[i].setSize(pbBox, _rx, _ry);
		}
		
		rx = _rx;
		ry = _ry;
	}
	
	static postBuild = function() {
		contents = [
			new Panel_Custom_Frame(),
			new Panel_Custom_Frame(),
		];
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			contents[i].pbBox.fixed_box = [0,0,1,1];
			contents[i].draggable       = false;
		}
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.split_dir  = split_dir;
		
		_m.split_amou = split_amou; _m.split_amou_frac = split_amou_frac;
		_m.split_spac = split_spac; _m.split_spac_frac = split_spac_frac;
	}
	
	static frameDeserialize = function(_m) {
		split_dir  = _m[$ "split_dir"]  ?? split_dir;
		
		split_amou = _m[$ "split_amou"] ?? split_amou; split_amou_frac = _m[$ "split_amou_frac"] ?? split_amou_frac;
		split_spac = _m[$ "split_spac"] ?? split_spac; split_spac_frac = _m[$ "split_spac_frac"] ?? split_spac_frac;
		return self;
	}
}