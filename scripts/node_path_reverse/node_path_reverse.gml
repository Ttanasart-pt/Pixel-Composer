function Node_Path_Reverse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Reverse Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	cached_pos = ds_map_create();
	
	curr_path  = noone;
	is_path    = false;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(curr_path && struct_has(curr_path, "drawOverlay")) 
			curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getLineCount    = function(       ) /*=>*/ {return is_path? curr_path.getLineCount()                    : 1};
	static getSegmentCount = function(ind = 0) /*=>*/ {return is_path? curr_path.getSegmentCount(ind)              : 0};
	static getLength       = function(ind = 0) /*=>*/ {return is_path? curr_path.getLength(ind)                    : 0};
	static getAccuLength   = function(ind = 0) /*=>*/ {return is_path? array_reverse(curr_path.getAccuLength(ind)) : []};
	static getBoundary     = function(ind = 0) /*=>*/ {return is_path? curr_path.getBoundary(ind)                  : new BoundingBox(0, 0, 1, 1)};
		
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(!is_path) return out;
		
		return curr_path.getPointRatio(1 - _rat, ind, out);
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() {
		curr_path  = getInputData(0);
		is_path    = curr_path != noone && struct_has(curr_path, "getPointRatio");
		
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}