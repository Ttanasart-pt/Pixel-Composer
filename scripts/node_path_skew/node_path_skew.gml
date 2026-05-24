function Node_Path_Skew(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Skew";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Paths
	newInput( 0, nodeValue_PathNode( "Path" ));
	
	////- =Skew
	newInput( 1, nodeValue_EButton( "Axis",       0, ["X", "Y"]    )).setPieMenu();
	newInput( 2, nodeValue_Slider(  "Strength",   0, [-1, 1, 0.01] )).setPieMenu();
	newInput( 3, nodeValue_Vec2(    "Center",   [.5,.5] )).setHotkey("G").setUnitSimple().setPieMenu();
	// 4
	
	newOutput(0, nodeValue_Output(  "Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [  
		[ "Paths", false ],  0, 
		[ "Skew",  false ],  1,  2,  3,  
	];
	
	////- Nodes
	
	function _skewPath(_path, _node) : Path(_node) constructor {
		curr_path   = _path;
		cached_pos  = {};
		
		axis        = 0;
		strength    = 0;
		center      = [0,0];

		static getLineCount    = function(   ) /*=>*/ {return curr_path.getLineCount()};
		static getSegmentCount = function(i=0) /*=>*/ {return curr_path.getSegmentCount(i)};
		static getLength       = function(   ) /*=>*/ {return curr_path.getLength()};
		static getAccuLength   = function(i=0) /*=>*/ {return curr_path.getAccuLength(i)};
		static getBoundary     = function(i=0) /*=>*/ {return curr_path.getBoundary(i)};
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
				hovering = hovering || hv;
			}
			
			return hovering;
		}
		
		static getPointRatio    = function(_rat,  ind = 0, out = undefined) { return getPointDistance(_rat * getLength(), ind, out); }
		static getPointDistance = function(_dist, ind = 0, out = undefined) { 
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			var _cKey  = _dist;
			if(struct_has(cached_pos, _cKey)) {
				var _cachep = cached_pos[$ _cKey];
				out.x = _cachep.x;
				out.y = _cachep.y;
				out.weight = _cachep.weight;
				return out;
			}
			
			curr_path.getPointDistance(_dist, 0, out);
			
			     if(axis == 0) out.x += (out.y - center[1]) * strength;
			else if(axis == 1) out.y += (out.x - center[0]) * strength;
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var path = getInputData(0); 
			if(!is_path(path)) return;
			
			var _axis = getInputData(1); 
			var _strn = getInputData(2); 
			var _cent = getInputData(3); 
		#endregion
		
		var skPath = new _skewPath(path, self);
		skPath.axis     = _axis;
		skPath.strength = _strn;
		skPath.center   = _cent;
		
		skPath.getPointDistance(0);
		
		outputs[0].setValue(skPath);
	}
}