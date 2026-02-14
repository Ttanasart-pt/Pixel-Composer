function Node_Path_Shift(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shift Path";
	setDimension(96, 48);
	setDrawIcon(s_node_path_shift);
	
	////- =Path
	newInput( 0, nodeValue_PathNode( "Path" ));
	newInput( 2, nodeValue_Range(    "Range", [0,1] ));
	
	////- =Shift
	newInput(1, nodeValue_Float("Distance", 0)).setHotkey("D");
	// 3
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 
		[ "Path",  false ], 0, 2, 
		[ "Shift", false ], 1, 
	];
	
	////- Nodes
	
	cached_pos = ds_map_create();
	
	curr_path  = noone;
	curr_range = [0, 1];
	curr_shift = noone;
	p  = new __vec2P();
	p0 = new __vec2P();
	p1 = new __vec2P();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var hovering = false;
		
		if(has(curr_path, "drawOverlay")) {
			var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
			hovering = hovering || hv;
		}
		
		PathDrawOverlay(self, _x, _y, _s);
		InputDrawOverlay(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return hovering;
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
		
		p = curr_path.getPointRatio(_rat, ind, p);
		var dir = 0;
		
		if(_rat < curr_range[0] || _rat > curr_range[1]) {
			out.x = p.x;
			out.y = p.y;
			out.weight = p.weight;
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		if(has(curr_path, "getPointTangent")) {
			dir = curr_path.getPointTangent(_rat, ind) + 90;
			
		} else {
			p0 = curr_path.getPointRatio(clamp(_rat - .001, 0, .999), ind, p0);
			p1 = curr_path.getPointRatio(clamp(_rat + .001, 0, .999), ind, p1);
			
			dir = point_direction(p0.x, p0.y, p1.x, p1.y) + 90;
		}
		
		out.x += p.x + lengthdir_x(curr_shift, dir);
		out.y += p.y + lengthdir_y(curr_shift, dir);
		out.weight = p.weight;
		
		cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	////- Update
	
	static update = function() {
		curr_path  = getInputData(0);
		curr_range = getInputData(2);
		
		curr_shift = getInputData(1);
		
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	}
	
}