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
	
	inputs[| 4] = nodeValue("Anchor", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 4].getValue();
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		active &= !inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
		active &= !inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny, THEME.anchor );
	}
	
	static getLineCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	}
	
	static getSegmentCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount() : 0; 
	}
	
	static getPointRatio = function(_rat, ind = 0) {
		var _path = inputs[| 0].getValue();
		var _pos  = inputs[| 1].getValue();
		var _rot  = inputs[| 2].getValue();
		var _sca  = inputs[| 3].getValue();
		var _anc  = inputs[| 4].getValue();
		
		if(is_array(_path)) {
			_path = array_safe_get(_path, ind);
			ind = 0;
		}
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		var _b = struct_has(_path, "getBoundary")? _path.getBoundary() : [0, 0, 0, 0];
		var _p = _path.getPointRatio(_rat, ind);
		
		_p[0] = _anc[0] + (_p[0] - _anc[0]) * _sca[0];
		_p[1] = _anc[1] + (_p[1] - _anc[1]) * _sca[1];
		
		_p = point_rotate(_p[0], _p[1], _anc[0], _anc[1], _rot);
		
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
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_transform, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}