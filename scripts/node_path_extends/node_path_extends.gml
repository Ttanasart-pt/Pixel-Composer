function Node_Path_Extends(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Extends";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Paths
	newInput( 0, nodeValue_Path( "Path" ));
	
	////- =Extends
	newInput( 1, nodeValue_EButton( "Side",    0, [ "Start", "End" ] ));
	newInput( 2, nodeValue_Float(   "Length", 16 ));
	// 3
	
	newOutput(0, nodeValue_Output(  "Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [  
		[ "Paths",   false ],  0, 
		[ "Extends", false ],  1,  2,  
	];
	
	////- Nodes
	
	function _extendsPath(_path, _node) : Path(_node) constructor {
		curr_path   = _path;
		side        = 0;
		exLength    = 0;
		cached_pos  = {};
		
		path_length = curr_path.getLength();
		segments    = curr_path.getSegmentCount() + 1;
		lengthTotal = path_length;
		boundary    = curr_path.getBoundary().clone();
		
		var acc = array_clone(curr_path.getAccuLength());
		if(side == 0) {
			array_insert(acc, 0, exLength);
			for( var i = 1, n = array_length(acc); i < n; i++ ) 
				acc[i] += exLength;
				
		} else if(side == 1) 
			array_push(acc, array_last(acc) + exLength);
			
		lengthAccs  = acc;
		
		startPos    = curr_path.getPointRatio(0.000);
		startPos1   = curr_path.getPointRatio(0.001);
		endPos      = curr_path.getPointRatio(0.999);
		endPos1     = curr_path.getPointRatio(0.998);
		
		startDir    = point_direction(startPos1.x, startPos1.y, startPos.x, startPos.y);
		endDir      = point_direction(endPos1.x,   endPos1.y,   endPos.x,   endPos.y);
		
		if(side == 0) boundary.addPoint(startPos.x + lengthdir_x(exLength, startDir), startPos.y + lengthdir_y(exLength, startDir))
		if(side == 1) boundary.addPoint(  endPos.x + lengthdir_x(exLength,   endDir),   endPos.y + lengthdir_y(exLength,   endDir))
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			var hovering = false;
			if(has(curr_path, "drawOverlay")) {
				var hv = curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
				hovering = hovering || hv;
			}
			
			return hovering;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return 1};
		static getSegmentCount = function(i=0) /*=>*/ {return segments};
		static getLength       = function(   ) /*=>*/ {return lengthTotal + exLength};
		static getAccuLength   = function(i=0) /*=>*/ {return lengthAccs};
		static getBoundary     = function(i=0) /*=>*/ {return boundary};
		
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
			
			if(side == 0) {
				if(_dist < exLength) {
					var edis = exLength - _dist;
					out.x = startPos.x + lengthdir_x(edis, startDir);
					out.y = startPos.y + lengthdir_y(edis, startDir);
					
				} else
					curr_path.getPointRatio((_dist - exLength) / path_length, 0, out);
				
			} else if(side == 1) {
				if(_dist > path_length) {
					var edis = _dist - path_length;
					out.x = endPos.x + lengthdir_x(edis, endDir);
					out.y = endPos.y + lengthdir_y(edis, endDir);
					
				} else
					curr_path.getPointRatio(_dist / path_length, 0, out);
				
			}
			
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(outputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var path = getInputData(0); 
			if(!is_path(path)) return;
			
			var side = getInputData(1); 
			var leng = getInputData(2); 
		#endregion
		
		var exPath = new _extendsPath(path, self);
		exPath.side     = side; 
		exPath.exLength = leng; 
		
		outputs[0].setValue(exPath);
	}
}