function Node_Path_Map_Area(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Remap Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Area", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [16, 16, 16, 16])
		.setDisplay(VALUE_DISPLAY.area);
	inputs[| 1].editWidget.adjust_shape = false;
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
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
		
		var _path = getInputData(0);
		var _area = getInputData(1);
		
		if(is_array(_path)) {
			_path = array_safe_get(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return out;
		
		var _b = _path.getBoundary();
		var _p = _path.getPointRatio(_rat, ind);
		
		out.x = (_area[AREA_INDEX.center_x] - _area[AREA_INDEX.half_w]) + (_p.x - _b.minx) / _b.width  * _area[AREA_INDEX.half_w] * 2;
		out.y = (_area[AREA_INDEX.center_y] - _area[AREA_INDEX.half_h]) + (_p.y - _b.miny) / _b.height * _area[AREA_INDEX.half_h] * 2;
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static getBoundary = function() {
		var _area = getInputData(1);
		return new BoundingBox( _area[AREA_INDEX.center_x] - _area[AREA_INDEX.half_w], 
								_area[AREA_INDEX.center_y] - _area[AREA_INDEX.half_h], 
								_area[AREA_INDEX.center_x] + _area[AREA_INDEX.half_w], 
								_area[AREA_INDEX.center_y] + _area[AREA_INDEX.half_h] );
	}
	
	static update = function() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_map, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}