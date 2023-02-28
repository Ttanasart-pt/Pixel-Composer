function Node_Path_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Transform Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static getSegmentCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount() : 0; 
	}
	
	static getPointRatio = function(_rat) {
		var _path = inputs[| 0].getValue();
		var _pos  = inputs[| 1].getValue();
		var _rot  = inputs[| 2].getValue();
		var _sca  = inputs[| 3].getValue();
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		var _b = _path.getBoundary();
		var _p = _path.getPointRatio(_rat);
		
		var cx = (_b[0] + _b[2]) / 2;
		var cy = (_b[1] + _b[1]) / 2;
		
		_p[0] = cx + (_p[0] - cx) * _sca[0];
		_p[1] = cy + (_p[1] - cy) * _sca[1];
		
		_p = point_rotate(_p[0], _p[1], cx, cy, _rot);
		
		_p[0] += _pos[0];
		_p[1] += _pos[1];
		
		return _p;
	}
	
	static getBoundary = function() {
		var _path = inputs[| 0].getValue();
		var _pos  = inputs[| 1].getValue();
		var _rot  = inputs[| 2].getValue();
		var _sca  = inputs[| 3].getValue();
		
		if(_path == noone) return [ 0, 0, 1, 1 ];
		
		var _b = _path.getBoundary();
		
		var cx = (_b[0] + _b[2]) / 2;
		var cy = (_b[1] + _b[1]) / 2;
		
		_b[0] = cx + (_b[0] - cx) * _sca[0];
		_b[1] = cy + (_b[1] - cy) * _sca[1];
		_b[2] = cx + (_b[2] - cx) * _sca[0];
		_b[3] = cy + (_b[3] - cy) * _sca[1];
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_transform, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}