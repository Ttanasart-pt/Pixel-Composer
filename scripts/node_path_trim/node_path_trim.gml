function Node_Path_Trim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trim Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Slider_Range("Range", self, [ 0, 1 ]));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
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
			var _p = new __vec2P();
			
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
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _path = getInputData(0);
		var _rng  = getInputData(1);
		
		if(is_array(_path)) {
			_path = array_safe_get_fast(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		
		_rat = _rng[0] + _rat * (_rng[1] - _rng[0]);
		
		return _path.getPointRatio(_rat, ind, out);
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
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}