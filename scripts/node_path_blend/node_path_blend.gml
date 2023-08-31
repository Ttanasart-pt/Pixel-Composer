function Node_Path_Blend(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Blend Path";
	previewable = false;
	
	w = 96;
	length = 0;
	
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
	
	static getLineCount = function() { 
		var _path = inputs[| 0].getValue();
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	}
	
	static getSegmentCount = function(ind = 0) { 
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getSegmentCount");
		var p2 = _path2 != noone && struct_has(_path2, "getSegmentCount");
		
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getSegmentCount(ind);
		if(!p1 &&  p2) return _path2.getSegmentCount(ind);
		
		return max(_path1.getSegmentCount(ind), _path2.getSegmentCount(ind));
	}
	
	static getLength = function(ind = 0) { 
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getLength");
		var p2 = _path2 != noone && struct_has(_path2, "getLength");
			
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getLength(ind);
		if(!p1 &&  p2) return _path2.getLength(ind);
		
		var _p1 = _path1.getLength(ind);
		var _p2 = _path2.getLength(ind);
		
		return lerp(_p1, _p2, _lerp);
	}
	
	static getAccuLength = function(ind = 0) { 
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getAccuLength");
		var p2 = _path2 != noone && struct_has(_path2, "getAccuLength");
			
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getAccuLength(ind);
		if(!p1 &&  p2) return _path2.getAccuLength(ind);
		
		var _p1 = _path1.getAccuLength(ind);
		var _p2 = _path2.getAccuLength(ind);
		
		var len = max(array_length(_p1), array_length(_p2));
		var res = [];
		
		for( var i = 0; i < len; i++ ) {
			var _l1 = array_get_decimal(_p1, i);
			var _l2 = array_get_decimal(_p2, i);
			
			res[i] = lerp(_l1, _l2, _lerp);
		}
		
		return res;
	}
	
	static getPointRatio = function(_rat, ind = 0) {
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return new __vec2();
		if( p1 && !p2) return _path1.getPointRatio(_rat, ind);
		if(!p1 &&  p2) return _path2.getPointRatio(_rat, ind);
		
		var _p1 = _path1.getPointRatio(_rat, ind);
		var _p2 = _path2.getPointRatio(_rat, ind);
		var _r  = new __vec2();
		
		_r.x = lerp(_p1.x, _p2.x, _lerp);
		_r.y = lerp(_p1.y, _p2.y, _lerp);
		
		return _r;
	}
	
	static getPointDistance = function(_dist, ind = 0) {
		return getPointRatio(_dist / getLength(ind), ind);
	}
	
	static getBoundary = function(ind = 0) {
		var _path1 = inputs[| 0].getValue();
		var _path2 = inputs[| 1].getValue();
		var _lerp  = inputs[| 2].getValue();
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return new BoundingBox();
		if( p1 && !p2) return _path1.getBoundary(ind);
		if(!p1 &&  p2) return _path2.getBoundary(ind);
		
		var _p1 = _path1.getBoundary(ind);
		var _p2 = _path2.getBoundary(ind);
		
		return _p1.lerpTo(_p2, _lerp);
	}
	
	function update() { 
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_blend, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}