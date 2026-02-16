function Node_Path_Map_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Remap Path";
	setDimension(96, 48);
	setDrawIcon(s_node_path_map_area);
	
	newInput(0, nodeValue_PathNode("Path"));
	
	////- =From
	newInput(2, nodeValue_Enum_Scroll( "Map From", 0, [ "Path Boundary", "Fix Dimension", "BBOX" ]));
	newInput(3, nodeValue_Dimension(   "Dimension From"         ));
	newInput(6, nodeValue_Vec4(        "BBOX From",   [0,0,1,1] ));
	
	////- =To
	newInput(4, nodeValue_Enum_Scroll( "Map To",      0, [ "Area", "Fix Dimension", "BBOX" ]));
	newInput(1, nodeValue_Area(        "Area",        DEF_AREA, { useShape : false })).setHotkey("A");
	newInput(5, nodeValue_Dimension(   "Dimension To"           ));
	newInput(7, nodeValue_Vec4(        "BBOX To",     [0,0,1,1] ));
	// input 8
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
		["From", false], 2, 3, 6, 
		["To",   false], 4, 1, 5, 7, 
	]
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {  
		var _toType = getInputSingle(4);
		
		switch(_toType) {
			case 0 : InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			
			case 1 : 
				var _tdim = getInputSingle(5);
				draw_set_color(COLORS._main_accent);
				draw_rectangle(
					_x + 0 * _s,
					_y + 0 * _s,
					_x + _tdim[0] * _s,
					_y + _tdim[1] * _s,
					true
				);
				break;
			
			case 2 : 
				var _tbox = getInputSingle(7);
				draw_set_color(COLORS._main_accent);
				draw_rectangle(
					_x + _tbox[0] * _s,
					_y + _tbox[1] * _s,
					_x + _tbox[2] * _s,
					_y + _tbox[3] * _s,
					true
				);
				break;
				
		}
		
		PathDrawOverlay(outputs[0].getValue(), _x, _y, _s);
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
		
		return w_hovering;
	}
	
	function _areaMappedPath(_node) : Path(_node) constructor {
		path = noone;
		
		areaFrom = [ 0, 0, 1, 1 ];
		areaTo   = [ 0, 0, 1, 1 ];
		
		static getLineCount    = function()    /*=>*/ { return struct_has(path, "getLineCount")?    path.getLineCount()     : 1;  }
		static getSegmentCount = function(i=0) /*=>*/ { return struct_has(path, "getSegmentCount")? path.getSegmentCount(i) : 0;  }
		static getLength       = function(i=0) /*=>*/ { return struct_has(path, "getLength")?       path.getLength(i)       : 0;  }
		static getAccuLength   = function(i=0) /*=>*/ { return struct_has(path, "getAccuLength")?   path.getAccuLength(i)   : []; }
			
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			
			if(is_array(path)) {
				path = array_safe_get_fast(path, ind);
				ind = 0;
			}
			
			if(!is_struct(path) || !is_path(path))
				return out;
			
			var _b = path.getBoundary();
			var _p = path.getPointRatio(_rat, ind);
			
			out.x = (areaTo[AREA_INDEX.center_x] - areaTo[AREA_INDEX.half_w]) + (_p.x - areaFrom[0]) / areaFrom[2] * areaTo[AREA_INDEX.half_w] * 2;
			out.y = (areaTo[AREA_INDEX.center_y] - areaTo[AREA_INDEX.half_h]) + (_p.y - areaFrom[1]) / areaFrom[3] * areaTo[AREA_INDEX.half_h] * 2;
			out.weight = _p.weight;
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
		static getBoundary = function() {
			return new BoundingBox( areaTo[AREA_INDEX.center_x] - areaTo[AREA_INDEX.half_w], 
									areaTo[AREA_INDEX.center_y] - areaTo[AREA_INDEX.half_h], 
									areaTo[AREA_INDEX.center_x] + areaTo[AREA_INDEX.half_w], 
									areaTo[AREA_INDEX.center_y] + areaTo[AREA_INDEX.half_h] );
		}
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _path = _data[0];
		var _from = _data[2];
		var _fdim = _data[3];
		var _fbox = _data[6];
		
		var _to   = _data[4];
		var _area = _data[1];
		var _tdim = _data[5];
		var _tbox = _data[7];
		
		inputs[3].setVisible(_from == 1);
		inputs[6].setVisible(_from == 2);
		
		inputs[1].setVisible(_to == 0);
		inputs[5].setVisible(_to == 1);
		inputs[7].setVisible(_to == 2);
		
		if(!is(_outData, _areaMappedPath)) 
			_outData = new _areaMappedPath();
		
		if(!is_path(_path)) 
			return _outData;
		
		_outData.path = _path;
		
		switch(_from) {
			case 0 : 
				var _bb = _path.getBoundary();
				_outData.areaFrom = [ _bb.minx, _bb.miny, _bb.width, _bb.height ];
				break;
				
			case 1 : _outData.areaFrom = [ 0, 0, _fdim[0], _fdim[1] ]; break;
			case 2 : _outData.areaFrom = [ _fbox[0], _fbox[1], _fbox[2] - _fbox[0], _fbox[3] - _fbox[1] ]; break;
		}
		
		switch(_to) {
			case 0 : _outData.areaTo = _area; break;
			case 1 : _outData.areaTo = [ _tdim[0] / 2, _tdim[1] / 2, _tdim[0] / 2, _tdim[1] / 2, 0 ]; break;
			case 2 : _outData.areaTo = [ (_tbox[0] + _tbox[2]) / 2, (_tbox[1] + _tbox[3]) / 2, 
			                             (_tbox[2] - _tbox[0]) / 2, (_tbox[3] - _tbox[1]) / 2, 0 ]; break;
		}
		
		return _outData;
	}
}