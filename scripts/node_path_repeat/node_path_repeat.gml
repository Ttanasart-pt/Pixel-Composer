function Node_Path_Repeat(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" )).setVisible(true, true);
	
	////- =Repeat
	
	newInput( 6, nodeValue_Enum_Button( "Pattern",      0, ["Linear", "Circular"] ));
	newInput( 1, nodeValue_Int(         "Amount",       4     ));
	newInput( 7, nodeValue_Vec2(        "Center",     [.5,.5] )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 8, nodeValue_Vec2(        "Radius",     [.5,.5] )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Position
	
	newInput(10, nodeValue_Vec2(     "Position",       [0,0]  )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 2, nodeValue_Vec2(     "Shift Position", [0,0]  )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Rotation
	
	newInput(11, nodeValue_Rotation( "Rotation",         0     ));
	newInput( 3, nodeValue_Rotation( "Shift Rotation",   0     ));
	newInput( 5, nodeValue_Vec2(     "Anchor",          [0,0]  )).setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 9, nodeValue_Bool(     "Rotate Along",    true   ));
	
	////- =Scale
	
	newInput(12, nodeValue_Vec2(     "Scale",          [1,1]  ));
	newInput( 4, nodeValue_Vec2(     "Shift Scale",    [1,1]  ));
		
	// input 13
		
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 0, 
		["Repeat",    false], 6, 1, 7, 8, 
		["Position",  false], 10, 2, 
		["Rotation",  false], 11, 3, 5, 9, 
		["Scale",     false], 12, 4, 
	];
	
	////- Nodes
	
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
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var path = _data[ 0];
			
			var patt = _data[ 6];
			var amo  = _data[ 1];
			var cent = _data[ 7];
			var radd = _data[ 8];
			
			var fpos = _data[10];
			var pos  = _data[ 2];
			
			var frot = _data[11];
			var rot  = _data[ 3];
			var anc  = _data[ 5];
			var rcir = _data[ 9];
			
			var fsca = _data[12];
			var sca  = _data[ 4];
			
			inputs[7].setVisible(patt == 1);
			inputs[8].setVisible(patt == 1);
			inputs[9].setVisible(patt == 1);
		#endregion
		
		var _repeat = new Path_Repeat(path);
		if(path == noone) return _repeat;
		
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
		
		var xx, yy, rr;
		var aa = 360 / amo;
		
		for (var i = 0; i < amo; i++) {
			
			switch(patt) {
				case 0 : 
					xx = fpos[0];
					yy = fpos[1];
					rr = frot;
					break;
				
				case 1 : 
					var _ang = aa * i;
					xx = fpos[0] + cent[0] + lengthdir_x(radd[0], _ang);
					yy = fpos[1] + cent[1] + lengthdir_y(radd[1], _ang);
					rr = frot + (rcir? _ang : 0);
					break;
			}
			
			xx += _px * i;
			yy += _py * i;
			
			rr += rot * i;
			
			var sxx = fsca[0] * power(_sx, i);
			var syy = fsca[1] * power(_sy, i);
			
			for (var k = 0; k < _line_amounts; k++) {
				_repeat.paths[_ind] = {
					index : k,
					ori   : anc,
					pos   : [ xx, yy ],
					rot   :   rr,
					sca   : [ sxx, syy ],
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
		
		return _repeat;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_repeat, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}