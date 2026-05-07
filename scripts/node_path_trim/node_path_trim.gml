function Node_Path_Trim(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Trim Path";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_PathNode( "Path"));
	
	////- =Trim
	newInput( 1, nodeValue_SliRange( "Range", [0,1] ));
	newInput( 2, nodeValue_Float(    "Shift", 0     ));
	
	////- =Clamp
	newInput( 3, nodeValue_Bool(     "Clamp", false ));
	newInput( 4, nodeValue_Range(    "Range", [0,1] ));
	// 4
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		[ "Path",  false    ],  0,
		[ "Trim",  false    ],  1,  2,  
		[ "Clamp", false, 3 ],  4, 
	];
	
	////- Node
	
	function _trimmedPath(_node) : Path(_node) constructor {
		curr_path  = noone;
		curr_range = noone;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()     : 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(i) : 0};
		static getLength       = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(i) * (curr_range[1] - curr_range[0]) : 0};
		static getAccuLength   = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(i)   : []};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(i)     : new BoundingBox( 0, 0, 1, 1 )};
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(!is_path(curr_path)) return out;
			_rat = lerp(curr_range[0], curr_range[1], _rat);
			return curr_path.getPointRatio(_rat, ind, out);
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _outp = outputs[0].getValue();
		if(!is_path(_outp)) return false;
		
		InputDrawOverlay(_outp.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _path = _data[0];
			
			var _rang = _data[1];
			var _shft = _data[2];
			
			var _clam = _data[3];
			var _cran = _data[4];
		#endregion
		
		_rang = [
			_rang[0] + _shft, 
			_rang[1] + _shft	
		];
		
		if(_clam) {
			_rang[0] = clamp(_rang[0], _cran[0], _cran[1]);
			_rang[1] = clamp(_rang[1], _cran[0], _cran[1]);
		}
		
		if(!is(_outData, _trimmedPath)) 
			_outData = new _trimmedPath(self);
			
		_outData.cached_pos = {};
		_outData.curr_path  = _path;
		_outData.curr_range = _rang;
		
		return _outData;
	}
	
}