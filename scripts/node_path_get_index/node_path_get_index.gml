function Node_Path_Get_Index(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path Select Index";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Path
	newInput( 0, nodeValue_Path(    "Path"        ));
	
	////- =Index
	newInput( 1, nodeValue_Int(     "Index",    0 ));
	newInput( 2, nodeValue_EScroll( "Overflow", 0, [ "Loop", "Clamp" ] ));
	// 3
	
	newOutput(0, nodeValue_Output(  "Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		[ "Path",  false ],  0, 
		[ "Index", false ],  1,  2, 
	]
	
	////- Node
	
	function _indexedPath(_node) : Path(_node) constructor {
		curr_path  = noone;
		index      = 0;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { drawUI(_x, _y, _s); }
		
		static getLineCount    = function(   ) /*=>*/ {return 1};
		static getSegmentCount = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(index)              : 0};
		static getLength       = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(index)                    : 0};
		static getAccuLength   = function(i=0) /*=>*/ {return is_path(curr_path)? array_reverse(curr_path.getAccuLength(index)) : []};
		static getBoundary     = function(i=0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(index)                  : new BoundingBox(0, 0, 1, 1)};
		
		static getPointRatio    = function(_rat, ind = 0, out = undefined) { return curr_path.getPointRatio(_rat, index, out);    }
		static getPointDistance = function(_dst, ind = 0, out = undefined) { return curr_path.getPointDistance(_rat, index, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _path = _data[ 0];
			
			var _indx = _data[ 1];
			var _over = _data[ 2];
			
			if(!is_path(_path)) return _outData;
		#endregion
		
		if(!is(_outData, _indexedPath)) 
			_outData = new _indexedPath(self);
		
		var _lamo = is_path(_path)? _path.getLineCount() : 1;
		switch(_over) {
			case 0 : _indx = safe_mod(_indx, _lamo); break;
			case 1 : _indx = clamp(_indx, 0, _lamo); break;
		}
		
		_outData.curr_path = _path;
		_outData.index     = _indx;
		
		return _outData;
	}
}