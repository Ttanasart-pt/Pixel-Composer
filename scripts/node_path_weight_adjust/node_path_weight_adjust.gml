function Node_Path_Weight_Adjust(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Weight Adjust";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path"));
	
	newInput(1, nodeValue_Enum_Scroll("Mode", 0, [ "Additive", "Multiplicative" ]));
	
	newInput(2, nodeValue_Float("Value", 0));
	
	newInput(3, nodeValue_Curve("Curve", CURVE_DEF_11));
	
	newInput(4, nodeValue_Enum_Scroll("Type", 0, [ "Constant", "Curve" ]));
	
	newInput(5, nodeValue_Vec2("Curve Range", [ 0, 1 ]));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
	    ["Adjustment", false], 1, 4, 2, 3, 5, 
    ];
	
	curr_path  = noone;
	curr_mode  = 0;
	curr_type  = 0;
	curr_value = 0;
	curr_curve = noone;
	curr_curve_range = [ 0, 1 ];
	
	temp_p = new __vec2P();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(has(curr_path, "drawOverlay")) InputDrawOverlay(curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
	}
	
	static getLineCount    = function(       ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()       : 1};
	static getSegmentCount = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(ind) : 0};
	static getLength       = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(ind)       : 0};
	static getAccuLength   = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(ind)   : []};
	static getBoundary     = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(ind)     : new BoundingBox( 0, 0, 1, 1 )};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(!is_path(curr_path)) return out;
		
		temp_p = curr_path.getPointRatio(_rat, ind, temp_p);
		out.x  = temp_p.x;
		out.y  = temp_p.y;
		
		var _v = curr_value;
		if(curr_type) _v = lerp(curr_curve_range[0], curr_curve_range[1], curr_curve.get(_rat));
		
		switch(curr_mode) {
		    case 0 : out.weight = max(0, temp_p.weight + _v); break;
		    case 1 : out.weight = temp_p.weight * _v; break;
		}
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() {
		var _path  = getInputData(0);
	    var _mode  = getInputData(1);
	    var _value = getInputData(2);
	    var _curve = getInputData(3);
	    var _type  = getInputData(4);
	    var _curve_range = getInputData(5);
	    
		inputs[2].setVisible(_type == 0);
		inputs[3].setVisible(_type == 1);
		inputs[5].setVisible(_type == 1);
		
		curr_path  = _path;
		curr_mode  = _mode;
	    curr_value = _value;
	    
	    curr_curve       = new curveMap(_curve, TOTAL_FRAMES);
	    curr_type        = _type;
	    curr_curve_range = _curve_range;
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_weight_adjust, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}