function Node_Path_Reverse(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Reverse Path";
	setDimension(96, 48);
	setDrawIcon(s_node_path_reverse);
	
	newInput(0, nodeValue_PathNode("Path"));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	function _reversePath(_node) : Path(_node) constructor {
		curr_path  = noone;
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
			var hovering = false;
			
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
				hovering = hovering || hv;
			}
			
			PathDrawOverlay(self, _x, _y, _s);
			
			return hovering;
		}
		
		static getLineCount    = function(       ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()                    : 1};
		static getSegmentCount = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(ind)              : 0};
		static getLength       = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(ind)                    : 0};
		static getAccuLength   = function(ind = 0) /*=>*/ {return is_path(curr_path)? array_reverse(curr_path.getAccuLength(ind)) : []};
		static getBoundary     = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(ind)                  : new BoundingBox(0, 0, 1, 1)};
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			if(!is_path(curr_path)) return out;
			
			return curr_path.getPointRatio(1 - _rat, ind, out);
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		
		if(!is(_outData, _reversePath)) 
			_outData = new _reversePath(self);
		
		_outData.curr_path  = _data[0];
		return _outData;
	}
	
}