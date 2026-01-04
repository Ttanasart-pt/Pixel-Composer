function Panel_Custom_Frame_Grid(_data) : Panel_Custom_Frame(_data) constructor {
	type = "framegrid";
	name = "Grid Frame";
	icon = THEME.panel_icon_element_frame_grid;
	
	grid = [2,2];
	split_spac = [0,0]; split_spac_frac = false;
	
	array_append(editors, [
		[ "Grid", false ], 
		Simple_Editor("Grid",       new vectorBox( 2, function(v,i) /*=>*/ { grid[i] = v; } ), function() /*=>*/ {return grid}, function(t) /*=>*/ { grid = t; }), 
		Simple_Editor("Spacing",    new vectorBox( 2, function(v,i) /*=>*/ { split_spac[i] = v; } ), function() /*=>*/ {return split_spac}, function(v) /*=>*/ { split_spac = v; }), 
		Simple_Editor("Fractional", new checkBox( function() /*=>*/ { split_spac_frac = !split_spac_frac; } ), function() /*=>*/ {return split_spac_frac}, function(v) /*=>*/ { split_spac_frac = v; }), 
	]);
	
	static setSize = function(_pBbox, _rx, _ry) {
		rx = _rx;
		ry = _ry;
		
		pbBox.setBase(_pBbox);
		bbox = pbBox.getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		var spx = split_spac_frac? w * split_spac[0] : split_spac[0];
		var spy = split_spac_frac? h * split_spac[1] : split_spac[1];
		
		var gw = (w + spx) / grid[0];
		var gh = (h + spy) / grid[1];
		
		var gsw = gw - spx;
		var gsh = gh - spy;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var ind  = i % (grid[0] * grid[1]);
			var col  = ind % grid[0];
			var row  = floor(ind / grid[0]);
			
			contents[i].pbBox.fixed_box = [ 
				x + gw * col,
				y + gh * row,
				x + gw * col + gsw,
				y + gh * row + gsh,
			];
			contents[i].draggable       = false;
			contents[i].setSize(bbox, _rx, _ry);
		}
	}
	
	static postBuild = function() {
		contents = [
			new Panel_Custom_Frame(data),
			new Panel_Custom_Frame(data),
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
		_m.grid = grid;
		_m.split_spac = split_spac; _m.split_spac_frac = split_spac_frac;
	}
	
	static frameDeserialize = function(_m) {
		grid = _m[$ "grid"]  ?? grid;
		split_spac = _m[$ "split_spac"] ?? split_spac; split_spac_frac = _m[$ "split_spac_frac"] ?? split_spac_frac;
		return self;
	}
}