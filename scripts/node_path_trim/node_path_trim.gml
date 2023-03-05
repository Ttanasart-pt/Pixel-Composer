function Node_Path_Trim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Trim Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [ 0, 1, 0.01 ]);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static getSegmentCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getSegmentCount")? _path.getSegmentCount() : 0; 
	}
	
	static getPointRatio = function(_rat) {
		var _path = inputs[| 0].getValue();
		var _rng  = inputs[| 1].getValue();
		
		if(!is_struct(_path) || !struct_has(_path, "getPointRatio"))
			return [ 0, 0 ];
		
		_rat = _rng[0] + _rat * (_rng[1] - _rng[0]);
		var _p  = _path.getPointRatio(_rat);
		
		return _p;
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}