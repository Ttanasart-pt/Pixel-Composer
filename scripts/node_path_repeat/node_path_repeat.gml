function Node_Path_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path"))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Amount", 4));
	
	newInput(2, nodeValue_Vec2("Shift Position", [ 0, 0 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newInput(3, nodeValue_Rotation("Shift Rotation", 0));
	
	newInput(4, nodeValue_Vec2("Shift Scale", [ 1, 1 ]));
	
	newInput(5, nodeValue_Vec2("Anchor", [ 0, 0 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
		
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 
		["Paths",     false], 0, 1, 
		["Position",  false], 2, 
		["Rotation",  false], 3, 5, 
		["Scale",     false], 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0);
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _pos = getSingleValue(2);
		var _px = _x + _pos[0] * _s;
		var _py = _y + _pos[1] * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function Path_Repeat(_path) constructor {
		line_amount    = 0;
		path           = _path;
		paths          = [];
		segment_counts = [];
		line_lengths   = [];
		accu_lengths   = [];
		
		__temp_p = [ 0, 0 ];
		
		static getLineCount     = function()    /*=>*/ {return line_amount};
		static getSegmentCount  = function(i=0) /*=>*/ {return array_safe_get_fast(segment_counts, i)};
		static getLength        = function(i=0) /*=>*/ {return array_safe_get_fast(line_lengths, i)};
		static getAccuLength    = function(i=0) /*=>*/ {return array_safe_get_fast(accu_lengths, i)};
		
		static getPointRatio    = function(_rat,  ind = 0, out = undefined) {
			out ??= new __vec2P();
			
			var _path = array_safe_get_fast(paths, ind, 0);
			if(_path == 0) return out;
			
			if(!is_struct(path) || !struct_has(path, "getPointRatio"))
				return out;
			
			var _ind  = _path.index;
			var _ori  = _path.ori;
			var _pos  = _path.pos;
			var _rot  = _path.rot;
			var _sca  = _path.sca;
			
			out = path.getPointRatio(_rat, _ind, out);
			
			var _px = out.x - _ori[0];
			var _py = out.y - _ori[1];
			
			__temp_p = point_rotate(_px, _py, 0, 0, _rot, __temp_p);
			
			out.x = _ori[0] + _pos[0] + __temp_p[0] * _sca[0];
			out.y = _ori[1] + _pos[1] + __temp_p[1] * _sca[1];
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
		
		static getBoundary      = function(ind = 0) {
			var _path = array_safe_get_fast(paths, ind, 0);
			return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static update = function() {
		var path = inputs[0].getValue();
		var amo  = inputs[1].getValue();
		var pos  = inputs[2].getValue();
		var rot  = inputs[3].getValue();
		var sca  = inputs[4].getValue();
		var anc  = inputs[5].getValue();
		
		var _repeat = new Path_Repeat(path);
		outputs[0].setValue(_repeat);
		
		if(path == noone) return;
		
		var _line_amounts = path.getLineCount();
		_repeat.line_amount    = amo * _line_amounts;
		_repeat.paths          = array_create(_repeat.line_amount);
		_repeat.segment_counts = array_create(_repeat.line_amount);
		_repeat.line_lengths   = array_create(_repeat.line_amount);
		_repeat.accu_lengths   = array_create(_repeat.line_amount);
		
		var _px  = pos[0];
		var _py  = pos[1];
		var _sx  = sca[0];
		var _sy  = sca[1];
		var _ind = 0;
		
		for (var i = 0; i < amo; i++) {
			var _pos = [ _px * i, _py * i ];
			var _rot = rot * i;
			var _sca = [ power(_sx, i), power(_sy, i) ];
			var _ori = anc;
			
			for (var k = 0; k < _line_amounts; k++) {
				_repeat.paths[_ind] = {
					index : k,
					ori   : _ori,
					pos   : _pos,
					rot   : _rot,
					sca   : _sca,
				}
				
				var _segment_counts = array_clone(path.getSegmentCount(k));
				var _line_lengths   = array_clone(path.getLength(k));
				var _accu_lengths   = array_clone(path.getAccuLength(k));
				
				_repeat.segment_counts[_ind] = _segment_counts;
				_repeat.line_lengths[_ind]   = _line_lengths;
				_repeat.accu_lengths[_ind]   = _accu_lengths;
				
				_ind++;
			}
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_repeat, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}