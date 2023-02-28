function Node_Path_Blend(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Blend Path";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Path 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Path 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ])
		.rejectArray();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static getSegmentCount = function() { 
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getSegmentCount");
		var p2 = _path2 != noone && struct_has(_path2, "getSegmentCount");
		
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getSegmentCount();
		if(!p1 &&  p2) return _path2.getSegmentCount();
		
		return max(_path1.getSegmentCount(), _path2.getSegmentCount());
	}
	
	static getPointRatio = function(_rat) {
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return [ 0, 0 ];
		if( p1 && !p2) return _path1.getPointRatio(_rat);
		if(!p1 &&  p2) return _path2.getPointRatio(_rat);
		
		var _p1 = _path1.getPointRatio(_rat);
		var _p2 = _path2.getPointRatio(_rat);
		var r = [];
		
		r[0] = lerp(array_safe_get(_p1, 0), array_safe_get(_p2, 0), _lerp);
		r[1] = lerp(array_safe_get(_p1, 1), array_safe_get(_p2, 1), _lerp);
		
		return r;
	}
	
	static getBoundary = function() {
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return [ 0, 0, 1, 1 ];
		if( p1 && !p2) return _path1.getBoundary();
		if(!p1 &&  p2) return _path2.getBoundary();
		
		var _p1 = _path1.getBoundary();
		var _p2 = _path2.getBoundary();
		
		return [ lerp(_p1[0], _p2[0], _lerp),
				 lerp(_p1[1], _p2[1], _lerp),
				 lerp(_p1[2], _p2[2], _lerp),
				 lerp(_p1[3], _p2[3], _lerp),
				];
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_blend, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}