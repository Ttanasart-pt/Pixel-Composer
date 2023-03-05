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
	
	static getSegmentCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount() : 0; 
	}
	
	static getPointRatio = function(_rat) {
		var _path = inputs[| 0].getValue();
		var _area = inputs[| 1].getValue();
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		var _b = _path.getBoundary();
		var _p = _path.getPointRatio(_rat);
		
		_p[0] = (_area[0] - _area[2]) + (_p[0] - _b[0]) / (_b[2] - _b[0]) * _area[2] * 2;
		_p[1] = (_area[1] - _area[3]) + (_p[1] - _b[1]) / (_b[3] - _b[1]) * _area[3] * 2;
		
		return _p;
	}
	
	static getBoundary = function() {
		var _area = inputs[| 1].getValue();
		return [ _area[0] - _area[2], _area[1] - _area[3], _area[0] + _area[2], _area[1] + _area[3] ];
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_map, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}