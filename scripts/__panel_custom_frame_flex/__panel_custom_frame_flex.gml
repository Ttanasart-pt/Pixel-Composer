function Panel_Custom_Frame_Flex(_data) : Panel_Custom_Frame(_data) constructor {
	type = "frameflex";
	name = "Flex Frame";
	icon = THEME.panel_icon_element_frame_flex;
	
	axis         = 0;
	expands      = false;
	expands_size = 32;    expands_size_frac = false;
	split_spac   = 8;     split_spac_frac   = false;
	expandSpace  = false;
	
	array_append(editors, [
		[ "Flex", false ], 
		Simple_Editor("Axis",    new buttonGroup(["X","Y"], function(i) /*=>*/ { axis = i; } ), function() /*=>*/ {return axis}, function(t) /*=>*/ { axis = t; }), 
		Simple_Editor("Spacing", textBox_Number(function(v) /*=>*/ { split_spac = v; } )
			.setSideButton(button(function() /*=>*/ { split_spac_frac = !split_spac_frac; }).setIcon(THEME.unit_ref, function() /*=>*/ {return split_spac_frac}).iconPad()), 
			function() /*=>*/ {return split_spac}, function(v) /*=>*/ { split_spac = v; }), 
		Simple_Editor("Expand Axis", new scrollBox([ "None", "Space", "Content" ], function(s) /*=>*/ { expandSpace = s; } ), function() /*=>*/ {return expandSpace}, function(t) /*=>*/ { expandSpace = t; }), 
		
		[ "Content", false ], 
		Simple_Editor("Fix Content Size", new checkBox(function() /*=>*/ { expands = !expands; } ), function() /*=>*/ {return expands}, function(t) /*=>*/ { expands = t; }), 
		Simple_Editor("Fix Size", textBox_Number(function(v) /*=>*/ { expands_size = v; } )
			.setSideButton(button(function() /*=>*/ { expands_size_frac = !expands_size_frac; }).setIcon(THEME.unit_ref, function() /*=>*/ {return expands_size_frac}).iconPad()), 
			function() /*=>*/ {return expands_size}, function(v) /*=>*/ { expands_size = v; }), 
		
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
		
		var sp = split_spac_frac?   split_spac   * (axis == 0? w : h) : split_spac;
		var ex = expands_size_frac? expands_size * (axis == 0? h : w) : expands_size;
		var ls = sp;
		
		var xx = x, yy = y;
		var ww = 0, hh = 0;
		var line = 0;
		var row  = [];
		var col  = [];
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			var bw  = con.pbBox.anchor_w_fract? w * con.pbBox.anchor_w : con.pbBox.anchor_w;
			var bh  = con.pbBox.anchor_h_fract? h * con.pbBox.anchor_h : con.pbBox.anchor_h;
			
			if(expands) {
				if(axis == 0) bh = ex;
				if(axis == 1) bw = ex;  
			}
			
			if(axis == 0) { 
				if(line > 0 && ww + bw > w) {
					xx   = x;
					ww   = 0;
					
					yy  += line + ls;
					hh  += line + ls;
					line = bh;
					array_push(row, col);
					col  = [con];
					
				} else {
					line = max(line, bh);
					array_push(col, con);
				}
			}
			
			if(axis == 1) { 
				if(line > 0 && hh + bh > h) {
					yy   = y;
					hh   = 0;
					
					xx  += line + ls;
					ww  += line + ls;
					line = bw;
					array_push(row, col);
					col  = [con];
					
				} else {
					line = max(line, bw);
					array_push(col, con);
				}
			}
			
			con.pbBox.fixed_box    = [xx, yy, xx + bw, yy + bh];
			con.pbBox.fixed_width  = bw;
			con.pbBox.fixed_height = bh;
			
			if(axis == 0) { xx += bw + sp; ww += bw + sp; }
			if(axis == 1) { yy += bh + sp; hh += bh + sp; }
		}
		array_push(row, col);
		
		if(expandSpace == 1)
		for( var i = 0, n = array_length(row); i < n; i++ ) {
			var rowCon  = row[i];
			var conArea = 0;
			var conAmo  = array_length(rowCon);
			if(conAmo <= 1) continue;
			
			for( var j = 0, m = conAmo; j < m; j++ ) {
				if(axis == 0) conArea += rowCon[j].pbBox.fixed_width;
				if(axis == 1) conArea += rowCon[j].pbBox.fixed_height;
			}
			
			var expSp = (w - conArea) / (conAmo - 1);
			var rowX = rowCon[0].pbBox.fixed_box[0];
			var rowY = rowCon[0].pbBox.fixed_box[1];
			
			for( var j = 0, m = conAmo; j < m; j++ ) {
				var pb = rowCon[j].pbBox;
				
				pb.fixed_box[0] = rowX;
				pb.fixed_box[1] = rowY;
				pb.fixed_box[2] = rowX + pb.fixed_width;
				pb.fixed_box[3] = rowY + pb.fixed_height;
				
				if(axis == 0) rowX += pb.fixed_width  + expSp;
				if(axis == 1) rowY += pb.fixed_height + expSp;
			}
		}
		
		if(expandSpace == 2)
		for( var i = 0, n = array_length(row); i < n; i++ ) {
			var rowCon  = row[i];
			var conArea = 0;
			var conAmo  = array_length(rowCon);
			if(conAmo <= 0) continue;
			
			for( var j = 0, m = conAmo; j < m; j++ ) {
				if(axis == 0) conArea += rowCon[j].pbBox.fixed_width;
				if(axis == 1) conArea += rowCon[j].pbBox.fixed_height;
			}
			
			var scal = (w - sp * (conAmo - 1)) / conArea;
			var rowX = rowCon[0].pbBox.fixed_box[0];
			var rowY = rowCon[0].pbBox.fixed_box[1];
			
			for( var j = 0, m = conAmo; j < m; j++ ) {
				var pb = rowCon[j].pbBox;
				
				var pw = pb.fixed_width;
				var ph = pb.fixed_height;
				
				if(axis == 0) pw = round(pw * scal);
				if(axis == 1) ph = round(ph * scal);
				
				pb.fixed_box[0] = rowX;
				pb.fixed_box[1] = rowY;
				pb.fixed_box[2] = rowX + pw;
				pb.fixed_box[3] = rowY + ph;
				
				if(axis == 0) rowX += pw + sp;
				if(axis == 1) rowY += ph + sp;
			}
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].setSize(bbox, _rx, _ry);
		
		if(axis == 0) h = max(hh, h);
		if(axis == 1) w = max(ww, w);
		
		// updateParentSize();
	}
	
	////- Serialize
	
	static frameSerialize = function(_m) {
		_m.axis         = axis;
		_m.expands      = expands;
		_m.expandSpace  = expandSpace;
		_m.split_spac   = split_spac;   _m.split_spac_frac   = split_spac_frac;
		_m.expands_size = expands_size; _m.expands_size_frac = expands_size_frac;
	}
	
	static frameDeserialize = function(_m) {
		axis         = _m[$ "axis"]         ?? axis;
		expands      = _m[$ "expands"]      ?? expands;
		expandSpace  = _m[$ "expandSpace"]  ?? expandSpace;
		split_spac   = _m[$ "split_spac"]   ?? split_spac;   split_spac_frac   = _m[$ "split_spac_frac"]   ?? split_spac_frac;
		expands_size = _m[$ "expands_size"] ?? expands_size; expands_size_frac = _m[$ "expands_size_frac"] ?? expands_size_frac;
		return self;
	}
}