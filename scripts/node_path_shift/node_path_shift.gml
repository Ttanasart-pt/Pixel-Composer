function Node_Path_Shift(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shift Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path"));
	
	newInput(1, nodeValue_Float("Distance", 0));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	cached_pos = ds_map_create();
	
	curr_path  = noone;
	curr_shift = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(curr_path && struct_has(curr_path, "drawOverlay")) 
			curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_icon);
		
		var _amo = getLineCount();
		var _p   = new __vec2P();
		
		for( var i = 0; i < _amo; i++ ) {
			var _len = getLength(_amo);
			var _stp = 1 / clamp(_len * _s, 1, 64);
			var ox, oy, nx, ny;
			
			for( var j = 0; j < 1; j += _stp ) {
				_p = getPointRatio(j, i, _p);
				nx = _x + _p.x * _s;
				ny = _y + _p.y * _s;
				
				if(j > 0) draw_line_width(ox, oy, nx, ny, 3);
				
				ox = nx;
				oy = ny;
			}
		}
	}
	
	static getLineCount    = function(       ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()       : 1};
	static getSegmentCount = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(ind) : 0};
	static getLength       = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(ind)       : 0};
	static getAccuLength   = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(ind)   : []};
	static getBoundary     = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(ind)     : new BoundingBox( 0, 0, 1, 1 )};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{string_format(_rat, 0, 6)},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		if(!is_path(curr_path)) return out;
		
		var _p0 = curr_path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999), ind);
		var _p  = curr_path.getPointRatio(_rat, ind);
		var _p1 = curr_path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999), ind);
		
		var dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y) + 90;
		
		out.x += _p.x + lengthdir_x(curr_shift, dir);
		out.y += _p.y + lengthdir_y(curr_shift, dir);
		out.weight = _p.weight;
		
		cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() {
		curr_path  = getInputData(0);
		curr_shift = getInputData(1);
		
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_shift, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}