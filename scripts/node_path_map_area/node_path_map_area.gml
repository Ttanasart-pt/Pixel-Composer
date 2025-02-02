function Node_Path_Map_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Remap Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Area", self, DEF_AREA, { useShape : false }));
	inputs[1].editWidget.adjust_shape = false;
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { 
		inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); 
	}
	
	function _areaMappedPath() constructor {
		
		path = noone;
		area = noone;
		
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
			
			if(!is_struct(path) || !struct_has(path, "getPointRatio"))
				return out;
			
			var _b = path.getBoundary();
			var _p = path.getPointRatio(_rat, ind);
			
			out.x = (area[AREA_INDEX.center_x] - area[AREA_INDEX.half_w]) + (_p.x - _b.minx) / _b.width  * area[AREA_INDEX.half_w] * 2;
			out.y = (area[AREA_INDEX.center_y] - area[AREA_INDEX.half_h]) + (_p.y - _b.miny) / _b.height * area[AREA_INDEX.half_h] * 2;
			out.weight = _p.weight;
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
		
		static getBoundary = function() {
			return new BoundingBox( area[AREA_INDEX.center_x] - area[AREA_INDEX.half_w], 
									area[AREA_INDEX.center_y] - area[AREA_INDEX.half_h], 
									area[AREA_INDEX.center_x] + area[AREA_INDEX.half_w], 
									area[AREA_INDEX.center_y] + area[AREA_INDEX.half_h] );
		}
	}
	
	static processData = function(_outData, _data, _output_index, _array_index = 0) { 
		
		if(!is(_outData, _areaMappedPath)) 
			_outData = new _areaMappedPath();
		
		_outData.path = _data[0];
		_outData.area = _data[1];
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_map_area, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}