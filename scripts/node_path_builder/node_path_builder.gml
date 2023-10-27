function Node_Path_Builder(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Path Builder";
	previewable = false;
	
	w = 96;
	length    = 0;
	lengthAcc = [];
	
	lines = [];
	connected = false;
	
	inputs[| 0] = nodeValue("Point array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setVisible(true, true)
		.setArrayDepth(2);
	
	inputs[| 1] = nodeValue("Connected", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "If set to true, will draw a single path from one point to another. If not set will treat each pair of points as an individual line.");
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		draw_set_color(COLORS._main_accent);
		
		if(connected) {
			for( var i = 1, n = array_length(lines); i < n; i++ ) {
				var p0 = lines[i - 1];
				var p1 = lines[i - 0];
				
				draw_line(_x + p0[0] * _s, _y + p0[1] * _s, 
						  _x + p1[0] * _s, _y + p1[1] * _s);
			}
		} else {
			var len = floor(array_length(lines) / 2) * 2;
			
			for( var i = 0; i < len; i += 2 ) {
				var p0 = lines[i + 0];
				var p1 = lines[i + 1];
				
				draw_line(_x + p0[0] * _s, _y + p0[1] * _s, 
						  _x + p1[0] * _s, _y + p1[1] * _s);
			}
		}
	} #endregion
	
	static getLineCount = function() { #region
		return connected? 1 : floor(array_length(lines) / 2); 
	} #endregion
	
	static getSegmentCount = function() { #region
		return connected? array_length(lines) - 1 : 1; 
	} #endregion
	
	static getLength = function(index) { return is_array(length)? array_safe_get(length, index) : length; }
	
	static getAccuLength = function(index) { return array_safe_get(lengthAcc, index, []); }
	
	static getPointRatio = function(_rat, _ind = 0) { #region
		var _p0, _p1;
		var _x, _y;
		
		if(connected) {
			var _st = _rat * (array_length(lines) - 1);
			_p0 = array_safe_get(lines, floor(_st) + 0,, ARRAY_OVERFLOW._default);
			_p1 = array_safe_get(lines, floor(_st) + 1,, ARRAY_OVERFLOW._default);
			
			if(!is_array(_p0)) return new __vec2();
			if(!is_array(_p1)) return new __vec2();
			
			_x  = lerp(_p0[0], _p1[0], frac(_st));
			_y  = lerp(_p0[1], _p1[1], frac(_st));
		
			return new __vec2( _x, _y );
		} else {
			_p0 = array_safe_get(lines, _ind * 2 + 0,, ARRAY_OVERFLOW._default);
			_p1 = array_safe_get(lines, _ind * 2 + 1,, ARRAY_OVERFLOW._default);
			
			if(!is_array(_p0)) return new __vec2();
			if(!is_array(_p1)) return new __vec2();
			
			_x  = lerp(_p0[0], _p1[0], _rat);
			_y  = lerp(_p0[1], _p1[1], _rat);
		
			return new __vec2( _x, _y );
		}
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0) { #region
		if(connected) return getPointRatio(_dist / length);
		else		  return getPointRatio(_dist / length[ind], ind);
	} #endregion
	
	static getBoundary = function() { #region
		var boundary = new BoundingBox();
		var lines = getInputData(0);
		for( var i = 0, n = array_length(lines); i < n; i++ )
			boundary.addPoint(lines[i][0], lines[i][1]);
		
		return boundary; 
	} #endregion
	
	static update = function() { #region
		lines     = [];
		array_spread(getInputData(0), lines, 1);
		connected = getInputData(1);
		
		if(connected) {
			length = 0;
			lengthAcc = [];
			
			for( var i = 1, n = array_length(lines); i < n; i++ ) {
				var p0 = lines[i - 1];
				var p1 = lines[i - 0];
				
				var dist = point_distance(p0[0], p0[1], p1[0], p1[1]);
				
				length += dist;
				array_push(lengthAcc, length);
			}
		} else {
			length    = [];
			lengthAcc = [];
			
			var len = floor(array_length(lines) / 2) * 2;
			
			for( var i = 0; i < len; i += 2 ) {
				var p0 = lines[i + 0];
				var p1 = lines[i + 1];
				
				var p0x = array_safe_get(p0, 0);
				var p0y = array_safe_get(p0, 1);
				var p1x = array_safe_get(p1, 0);
				var p1y = array_safe_get(p1, 1);
				
				p0x	= is_real(p0x)? p0x : 0;
				p0y	= is_real(p0y)? p0y : 0;
				p1x	= is_real(p1x)? p1x : 0;
				p1y = is_real(p1y)? p1y : 0;
				
				lines[i + 0] = [ p0x, p0y ];
				lines[i + 1] = [ p1x, p1y ];
				
				var dist = point_distance(p0x, p0y, p1x, p1y);
				
				array_push(length, dist);
				array_push(lengthAcc, [ dist ]);
			}
		}
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_builder, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}