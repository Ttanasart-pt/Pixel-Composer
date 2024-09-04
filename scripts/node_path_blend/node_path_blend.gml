function Node_Path_Blend(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Blend Path";
	setDimension(96, 48);;
	length = 0;
	
	newInput(0, nodeValue_PathNode("Path 1", self, noone))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(1, nodeValue_PathNode("Path 2", self, noone))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(2, nodeValue_Float("Ratio", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _p0 = getInputData(0);
		var _p1 = getInputData(1);
		
		if(_p0) _p0.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(_p1) _p1.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
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
	} #endregion
	
	static getLineCount = function() { #region
		var _path = getInputData(0);
		return struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
	} #endregion
	
	static getSegmentCount = function(ind = 0) { #region
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		var _lerp  = getInputData(2);
		
		var p1 = _path1 != noone && struct_has(_path1, "getSegmentCount");
		var p2 = _path2 != noone && struct_has(_path2, "getSegmentCount");
		
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getSegmentCount(ind);
		if(!p1 &&  p2) return _path2.getSegmentCount(ind);
		
		return max(_path1.getSegmentCount(ind), _path2.getSegmentCount(ind));
	} #endregion
	
	static getLength = function(ind = 0) { #region
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		var _lerp  = getInputData(2);
		
		var p1 = _path1 != noone && struct_has(_path1, "getLength");
		var p2 = _path2 != noone && struct_has(_path2, "getLength");
			
		if(!p1 && !p2) return 0;
		if( p1 && !p2) return _path1.getLength(ind);
		if(!p1 &&  p2) return _path2.getLength(ind);
		
		var _p1 = _path1.getLength(ind);
		var _p2 = _path2.getLength(ind);
		
		return lerp(_p1, _p2, _lerp);
	} #endregion
	
	static getAccuLength = function(ind = 0) { #region
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		var _lerp  = getInputData(2);
		
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
	} #endregion
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_rat},{ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		var _lerp  = getInputData(2);
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return out;
		if( p1 && !p2) return _path1.getPointRatio(_rat, ind, out);
		if(!p1 &&  p2) return _path2.getPointRatio(_rat, ind, out);
		
		var _p1 = _path1.getPointRatio(_rat, ind);
		var _p2 = _path2.getPointRatio(_rat, ind);
		
		out.x = lerp(_p1.x, _p2.x, _lerp);
		out.y = lerp(_p1.y, _p2.y, _lerp);
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
	
	static getBoundary = function(ind = 0) { #region
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		var _lerp  = getInputData(2);
		
		var p1 = _path1 != noone && struct_has(_path1, "getPointRatio");
		var p2 = _path2 != noone && struct_has(_path2, "getPointRatio");
			
		if(!p1 && !p2) return new BoundingBox();
		if( p1 && !p2) return _path1.getBoundary(ind);
		if(!p1 &&  p2) return _path2.getBoundary(ind);
		
		var _p1 = _path1.getBoundary(ind);
		var _p2 = _path2.getBoundary(ind);
		
		return _p1.lerpTo(_p2, _lerp);
	} #endregion
	
	static update = function() { #region
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_blend, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}