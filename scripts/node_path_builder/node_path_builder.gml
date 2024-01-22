function Node_Path_Builder(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Builder";
	w    = 96;
	
	length    = [];
	lengthAcc = [];
	
	lines = [];
	
	inputs[| 0] = nodeValue("Point array", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [])
		.setVisible(true, true)
		.setArrayDepth(2);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var _line = lines[i];
			
			for( var j = 1, m = array_length(_line); j < m; j++ ) {
				var p0 = _line[j - 1];
				var p1 = _line[j - 0];
				
				draw_line(_x + p0[0] * _s, _y + p0[1] * _s, 
						  _x + p1[0] * _s, _y + p1[1] * _s);
						  
				if(j == 1) draw_circle(_x + p0[0] * _s, _y + p0[1] * _s, 4, false);
				draw_circle(_x + p1[0] * _s, _y + p1[1] * _s, 4, false);
			}
		}
	} #endregion
	
	static getLineCount		= function()      { return array_length(lines); }
	static getSegmentCount	= function()      { return array_length(lines); }
	static getLength		= function(index) { return array_safe_get(length, index); }
	static getAccuLength	= function(index) { return array_safe_get(lengthAcc, index, []); }
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _p0, _p1;
		var _x, _y;
		
		var line = array_safe_get(lines, _ind, []);
		var _st  = _rat * (array_length(line) - 1);
		_p0 = array_safe_get(line, floor(_st) + 0);
		_p1 = array_safe_get(line, floor(_st) + 1);
		
		if(!is_array(_p0)) return out;
		if(!is_array(_p1)) return out;
			
		out.x = lerp(_p0[0], _p1[0], frac(_st));
		out.y = lerp(_p0[1], _p1[1], frac(_st));
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / length[ind], ind, out); }
	
	static getBoundary = function() { #region
		var boundary = new BoundingBox();
		
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var _line = lines[i];
			for( var j = 0, m = array_length(_line); j < m; j++ )
				boundary.addPoint(_line[j][0], _line[j][1]);
		}
		
		return boundary; 
	} #endregion
	
	static update = function() { #region
		var _lines = getInputData(0);
		if(array_empty(_lines)) return;
		
		lines = _lines;
		if(!is_array(_lines[0][0])) 
			lines = [ lines ];
		
		var _len  = array_length(lines);
		length    = array_create(_len);
		lengthAcc = array_create(_len);
		
		for( var i = 0; i < _len; i++ ) {
			var _line = lines[i];
			var _lngh = 0;
			var _lenA = [];
			
			var _ox = _line[0], _nx;
			
			for( var j = 1, m = array_length(_line); j < m; j++ ) {
				_nx = _line[j];
				
				var p0x = array_safe_get(_ox, 0);
				var p0y = array_safe_get(_ox, 1);
				var p1x = array_safe_get(_nx, 0);
				var p1y = array_safe_get(_nx, 1);
				
				p0x	= is_real(p0x)? p0x : 0;
				p0y	= is_real(p0y)? p0y : 0;
				p1x	= is_real(p1x)? p1x : 0;
				p1y = is_real(p1y)? p1y : 0;
				
				var dist = point_distance(p0x, p0y, p1x, p1y);
				_lngh += dist;
				array_push(_lenA, dist);
				
				_ox = _nx;
			}
			
			length[i]    = _lngh;
			lengthAcc[i] = _lenA;
		}
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_builder, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}