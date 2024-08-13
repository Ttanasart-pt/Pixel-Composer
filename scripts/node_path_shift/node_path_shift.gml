function Node_Path_Shift(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shift Path";
	setDimension(96, 48);;
	
	inputs[0] = nodeValue_PathNode("Path", self, noone)
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Float("Distance", self, 0);
	
	outputs[0] = nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self);
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_icon);
		
		var _amo = getLineCount();
		for( var i = 0; i < _amo; i++ ) {
			var _len = getLength(_amo);
			var _stp = 1 / clamp(_len * _s, 1, 64);
			var ox, oy, nx, ny;
			var _p = new __vec2();
			
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
	
	static getLineCount = function() {
		var _path = getInputData(0);
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	}
	
	static getSegmentCount = function(ind = 0) {
		var _path = getInputData(0);
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount(ind) : 0; 
	}
	
	static getLength = function(ind = 0) {
		var _path = getInputData(0);
		return struct_has(_path, "getLength")? _path.getLength(ind) : 0; 
	}
	
	static getAccuLength = function(ind = 0) {
		var _path = getInputData(0);
		return struct_has(_path, "getAccuLength")? _path.getAccuLength(ind) : []; 
	}
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_rat},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _path = getInputData(0);
		var _shf  = getInputData(1);
		
		if(is_array(_path)) {
			_path = array_safe_get_fast(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		
		var _p0 = _path.getPointRatio(clamp(_rat - 0.001, 0, 0.999999), ind);
		var _p  = _path.getPointRatio(_rat, ind);
		var _p1 = _path.getPointRatio(clamp(_rat + 0.001, 0, 0.999999), ind);
		
		var dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y) + 90;
		
		out.x += _p.x + lengthdir_x(_shf, dir);
		out.y += _p.y + lengthdir_y(_shf, dir);
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static getBoundary = function(ind = 0) {
		var _path = getInputData(0);
		return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
	}
	
	static update = function() {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_shift, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}