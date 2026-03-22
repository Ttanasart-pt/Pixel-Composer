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
		
		var xx = x;
		var yy = y;
		var sp = split_spac_frac? split_spac * (axis == 0? w : h) : split_spac;
		var fs = fixSize_frac?    fixSize    * (axis == 0? w : h) : fixSize;
		
		var ww = 0;
		var hh = 0;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var  con  = contents[i];
			var _bbox = con.pbBox.getBBOX(bbox);
			var _bx   = _bbox[0];
			var _by   = _bbox[1];
			var _bw   = _bbox[2] - _bbox[0];
			var _bh   = _bbox[3] - _bbox[1];
			
			if(axis == 0) { _bx = xx; _by = yy; if(expands) _bh = h; if(fixAxis) _bw = fs; }
			if(axis == 1) { _bx = xx; _by = yy; if(expands) _bw = w; if(fixAxis) _bh = fs; }
			
			con.pbBox.fixed_box = [_bx, _by, _bx+_bw, _by+_bh];
			con.setSize(bbox, _rx, _ry);
			
			if(axis == 0) { xx += _bw + sp; ww += _bw + sp; }
			if(axis == 1) { yy += _bh + sp; hh += _bh + sp; }
		}
		
		// ww = max(ww, w);
		// hh = max(hh, h);
		
		// if(axis == 0) pbBox.set_w(ww);
		// if(axis == 1) pbBox.set_h(hh);
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