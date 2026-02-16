function Node_Path_Bake(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bake Path";
	setDrawIcon(THEME.node_draw_path);
	setDimension(96, 48);
	
	////- =Path
	newInput(0, nodeValue_PathNode( "Path" ));
	newInput(2, nodeValue_Bool(     "Spread Single Path", true ));
	
	////- =Type
	newInput(3, nodeValue_Enum_Scroll( "Sample Type",    0, [ "Length", "Amount" ] ));
	newInput(1, nodeValue_Float(       "Segment Length", 1 ));
	newInput(4, nodeValue_Int(         "Output Amount",  1 ));
	// input 5
	
	newOutput(0, nodeValue_Output("Segments", VALUE_TYPE.float,    []    )).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(2);
	newOutput(1, nodeValue_Output("Path",     VALUE_TYPE.pathnode, noone ));
	
	input_display_list = [ 0, 2, 
		[ "Type", false ], 3, 1, 4, 
	];
	
	output_display_list = [ 1, 0 ];
	
	////- Node
	
	path_amount = 1;
	
	function _bakedPath(_node) : Path(_node) constructor {
		points     = [];
		
		lineCount     = 0;
		lengths       = [];
		lengthAccs    = [];
		segmentCounts = [];
		boundary      = [];
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			PathDrawOverlay(self, _x, _y, _s);
			return hovering;
		}
		
		static setData = function(d) /*=>*/ {
			points    = d;
			lineCount = array_length(d);
			
			lengths       = array_create(lineCount);
			lengthAccs    = array_create(lineCount);
			segmentCounts = array_create(lineCount);
			boundary      = array_create(lineCount);
			
			for( var i = 0; i < lineCount; i++ ) {
				var _ps = points[i];
				var _pl = array_length(_ps);
				
				var len  = 0;
				var lenA = [];
				var segC = _pl;
				var bbox = new BoundingBox();
				
				if(_pl < 2) {
					lengths[i]       = len;
					lengthAccs[i]    = lenA;
					segmentCounts[i] = segC;
					boundary[i]      = bbox;	
					continue;
				}
				
				var ox = _ps[0][0];
				var oy = _ps[0][1];
				var nx, ny;
				
				bbox.addPoint(ox, oy);
				
				for( var j = 1; j < _pl; j++ ) {
					var p = _ps[j];
					nx = p[0];
					ny = p[1];
					
					var ll = point_distance(ox, oy, nx, ny);
					len    += ll;
					lenA[j] = len;
					bbox.addPoint(nx, ny);
					
					ox = nx;
					oy = ny;
				}
				
				lengths[i]       = len;
				lengthAccs[i]    = lenA;
				segmentCounts[i] = segC;
				boundary[i]      = bbox;
			}
			
			return self;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return lineCount};
		static getSegmentCount = function(i=0) /*=>*/ {return segmentCounts[i]};
		static getLength       = function(i=0) /*=>*/ {return lengths[i]};
		static getAccuLength   = function(i=0) /*=>*/ {return lengthAccs[i]};
		static getBoundary     = function(i=0) /*=>*/ {return boundary[i]};
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) { return getPointDistance(_rat * getLength(ind), ind, out); }
			
		static getPointDistance = function(_dist, ind = 0, out = undefined) { 
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			var _pp = points[ind];
			var _ll = getLength(ind);
			var _la = getAccuLength(ind);
			_dist   = _dist % _ll;
			
			var i0 = min(array_find_sorted(_la, _dist), array_length(_la) - 2);
			var i1 = i0 + 1;
			
			var _rat = (_dist - _la[i0]) / (_la[i1] - _la[i0]);
			
			out.x = lerp(_pp[i0][0], _pp[i1][0], _rat);
			out.y = lerp(_pp[i0][1], _pp[i1][1], _rat);
			
			return out; 
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		
		var _segs = outputs[0].getValue();
		var ox, oy, nx, ny;
		
		if(array_invalid(_segs) || array_invalid(_segs[0])) return;
		if(!is_array(_segs[0][0])) _segs = [ _segs ];
		
		draw_set_color(COLORS._main_icon);
		
		for( var i = 0, n = array_length(_segs); i < n; i++ ) {
			var _seg = _segs[i];
			
			for( var j = 0, m = array_length(_seg); j < m; j++ ) {
				nx = _x + _seg[j][0] * _s;
				ny = _y + _seg[j][1] * _s;
				
				if(j) draw_line_width(ox, oy, nx, ny, 3);
				
				ox = nx; 
				oy = ny;
			}
		}
	}
	
	static update = function() {
		#region data
			var _path = getInputData(0);
			var _sped = getInputData(2);
			
			var _type = getInputData(3);
			var _dist = getInputData(1);
			var _amou = getInputData(4); _amou = max(2, _amou);
			
			inputs[1].setVisible(_type == 0);
			inputs[4].setVisible(_type == 1);
			
			if(!is_path(_path)) return;
		#endregion
		
		var _bpath = outputs[1].getValue();
		if(!is(_bpath, _bakedPath)) _bpath = new _bakedPath(self);
		
		var _loop   = struct_try_get(_path, "path_loop", false);
		var _amo    = _path.getLineCount();
		path_amount = _amo;
		
		var _segs = array_create(_amo);
		
		var _p = new __vec2P();
		var st = 1 / _amou;
		
		if(_type == 0) {
			for( var i = 0; i < _amo; i++ ) {
				var _len = _path.getLength(i);
				if(_len == 0) { _segs[i] = []; continue; }
				
				var slen = floor(_len / _dist) + _loop;
				var sseg = array_create(slen);
				var sind = 0;
				
				for( var j = 0; j <= _len; j += _dist ) {
					_p = _path.getPointDistance(j, i, _p);
					sseg[sind++] = [ _p.x, _p.y, j / _len ];
				}
				
				if(_loop) sseg[sind++] = [ sseg[0][0], sseg[0][1], 1 ];
				_segs[i] = sseg;
			}
			
		} else if(_type == 1) {
			for( var i = 0; i < _amo; i++ ) {
				var _len = _path.getLength(i);
				if(_len == 0) { _segs[i] = []; continue; }
				
				var slen = _amou + 1 + _loop;
				var sseg = array_create(slen);
				var sind = 0;
				
				for( var j = 0; j <= _amou; j++ ) {
					_p = _path.getPointRatio(j * st, i, _p);
					sseg[sind++] = [ _p.x, _p.y, j * st ];
				}
				
				if(_loop) sseg[sind++] = [ sseg[0][0], sseg[0][1], 1 ];
				_segs[i] = sseg;
			}
			
		}
		
		_bpath.setData(_segs);
		
		if(_sped && _amo == 1) _segs = _segs[0];
		outputs[0].setValue(_segs);
		outputs[1].setValue(_bpath);
	}
	
}