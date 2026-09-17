function Node_Path_Redistribute(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path Redistribute";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Path( "Path" ));
	
	////- =Distributrion
	newInput( 1, nodeValue_Curve( "Curve", CURVE_DEF_01 ));
	// input 2
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
		[ "Distributrion", false ], 1, 
	];
	
	////- Node
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {  
		drawOverlayInput(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	function _reDistPath(_node) : Path(_node) constructor {
		path  = noone;
		curve = undefined;
		
		__p = new __vec2P();
		
		static getLineCount    = function(   ) /*=>*/ {return path.getLineCount()};
		static getSegmentCount = function(i=0) /*=>*/ {return path.getSegmentCount(i)};
		static getLength       = function(   ) /*=>*/ {return path.getLength()};
		static getAccuLength   = function(i=0) /*=>*/ {return path.getAccuLength(i)};
		static getBoundary     = function(i=0) /*=>*/ {return path.getBoundary(i)};
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			if(has(path, "drawOverlay")) {
				var hv = path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
				hovering = hovering || hv;
			}
			
			return hovering;
		}
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			_rat = curve.get(_rat);
			__p  = path.getPointRatio(_rat, ind, __p);
			
			out.x = __p.x;
			out.y = __p.y;
			out.weight = __p.weight;
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _path  = _data[0];
			
			var _curve = _data[1];
			
			if(!is_path(_path)) return _outData;
		#endregion
		
		if(!is(_outData, _reDistPath)) 
			_outData = new _reDistPath();
		
		_outData.path  = _path;
		_outData.curve = new curveMap(_curve);
		
		return _outData;
	}
}