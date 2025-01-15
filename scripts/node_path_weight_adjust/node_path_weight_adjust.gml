function Node_Path_Weight_Adjust(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Weight Adjust";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Scroll("Mode", self, 0, [ "Additive", "Multiplicative" ]));
	
	newInput(2, nodeValue_Float("Value", self, 0));
	
	newInput(3, nodeValue_Curve("Length Modifier", self, CURVE_DEF_11));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
	    ["Adjustment", false], 1, 2, 
    ];
	
	curr_path  = noone;
	curr_mode  = 0;
	curr_value = 0;
	
	temp_p = new __vec2P();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(curr_path && struct_has(curr_path, "drawOverlay")) curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getLineCount    = function(       ) /*=>*/ {return struct_has(curr_path, "getLineCount")?    curr_path.getLineCount()       : 1};
	static getSegmentCount = function(ind = 0) /*=>*/ {return struct_has(curr_path, "getSegmentCount")? curr_path.getSegmentCount(ind) : 0};
	static getLength       = function(ind = 0) /*=>*/ {return struct_has(curr_path, "getLength")?       curr_path.getLength(ind)       : 0};
	static getAccuLength   = function(ind = 0) /*=>*/ {return struct_has(curr_path, "getAccuLength")?   curr_path.getAccuLength(ind)   : []};
	static getBoundary     = function(ind = 0) /*=>*/ {return struct_has(curr_path, "getBoundary")?     curr_path.getBoundary(ind)     : new BoundingBox( 0, 0, 1, 1 )};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		temp_p = curr_path.getPointRatio(_rat, ind, temp_p);
		out.x  = temp_p.x;
		out.y  = temp_p.y;
		
		switch(curr_mode) {
		    case 0 : out.weight = max(0, temp_p.weight + curr_value); break;
		    case 1 : out.weight = temp_p.weight * curr_value; break;
		}
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() {
		curr_path  = getInputData(0);
		curr_mode  = getInputData(1);
	    curr_value = getInputData(2);
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_weight_adjust, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}