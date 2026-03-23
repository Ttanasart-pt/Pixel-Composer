function Panel_Custom_Frame_Stack(_data) : Panel_Custom_Frame(_data) constructor {
	type = "framestack";
	name = "Stack Frame";
	icon = THEME.panel_icon_element_frame_stack;
	
	axis       = 1;
	expands    = false;
	
	split_spac =  0; split_spac_frac = false;
	
	fixAxis    = false;
	fixSize    = 40; fixSize_frac    = false;
	
	array_append(editors, [
		[ "Stack", false ], 
		Simple_Editor("Axis",       new buttonGroup(["X","Y"], function(i) /*=>*/ { axis = i; } ), function() /*=>*/ {return axis}, function(t) /*=>*/ { axis = t; }), 
		Simple_Editor("Spacing",    textBox_Number(function(v) /*=>*/ { split_spac = v; } )
			.setSideButton(button(function() /*=>*/ { split_spac_frac = !split_spac_frac; }).setIcon(THEME.unit_ref, function() /*=>*/ {return split_spac_frac}).iconPad()), 
			function() /*=>*/ {return split_spac}, function(v) /*=>*/ { split_spac = v; }), 
		
		[ "Content", false ], 
		Simple_Editor("Expands",    new checkBox(function() /*=>*/ { expands = !expands; } ), function() /*=>*/ {return expands}, function(t) /*=>*/ { expands = t; }), 
		Simple_Editor("Fix Axis",   new checkBox(function() /*=>*/ { fixAxis = !fixAxis; } ), function() /*=>*/ {return fixAxis}, function(t) /*=>*/ { fixAxis = t; }),
		Simple_Editor("Fix Size",   textBox_Number(function(v) /*=>*/ { fixSize = v; } )
			.setSideButton(button(function() /*=>*/ { fixSize_frac = !fixSize_frac; }).setIcon(THEME.unit_ref, function() /*=>*/ {return fixSize_frac}).iconPad()), 
			function() /*=>*/ {return fixSize}, function(v) /*=>*/ { fixSize = v; }), 
		
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
		
		var sp = split_spac_frac? split_spac * (axis == 0? w : h) : split_spac;
		var fs = fixSize_frac?    fixSize    * (axis == 0? w : h) : fixSize;
		
		var xx = x, yy = y;
		var ww = 0, hh = 0;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			var bw  = con.pbBox.anchor_w_fract? w * con.pbBox.anchor_w : con.pbBox.anchor_w;
			var bh  = con.pbBox.anchor_h_fract? h * con.pbBox.anchor_h : con.pbBox.anchor_h;
			
			if(axis == 0) { 
				if(expands) bh = h;  
				if(fixAxis) bw = fs; 
			}
			
			if(axis == 1) { 
				if(expands) bw = w;  
				if(fixAxis) bh = fs; 
			}
			
			con.pbBox.fixed_box = [xx, yy, xx + bw, yy + bh];
			con.setSize(bbox, _rx, _ry);
			
			if(axis == 0) { xx += bw + sp; ww += bw + sp; }
			if(axis == 1) { yy += bh + sp; hh += bh + sp; }
		}
		
		if(axis == 0) w = max(ww, w);
		if(axis == 1) h = max(hh, h);
		
		// updateParentSize();
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.axis       = axis;
		_m.expands    = expands;
		_m.split_spac = split_spac; _m.split_spac_frac = split_spac_frac;
		
		_m.fixAxis    = fixAxis;
		_m.fixSize    = fixSize;    _m.fixSize_frac    = fixSize_frac;
	}
	
	static frameDeserialize = function(_m) {
		axis       = _m[$ "axis"]       ?? axis;
		expands    = _m[$ "expands"]    ?? expands;
		split_spac = _m[$ "split_spac"] ?? split_spac; split_spac_frac = _m[$ "split_spac_frac"] ?? split_spac_frac;
		
		fixAxis    = _m[$ "fixAxis"]    ?? fixAxis;
		fixSize    = _m[$ "fixSize"]    ?? fixSize; fixSize_frac = _m[$ "fixSize_frac"] ?? fixSize_frac;
		
		return self;
	}
}