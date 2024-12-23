function Node_Path_Scatter(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Base Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_PathNode("Scatter Path", self, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Slider_Range("Range", self, [ 0, 1 ]));
	
	newInput(3, nodeValue_Int("Amount", self, 4));
	
	newInput(4, nodeValue_Slider_Range("Scale", self, [ 0.5, 1 ]));
	
	newInput(5, nodeValueSeed(self));
	
	newInput(6, nodeValue_Curve("Scale over Length", self, CURVE_DEF_11));
	
	newInput(7, nodeValue_Rotation_Random("Rotation", self, [ 0, 45, 135, 0, 0 ] ));
	
	newInput(8, nodeValue_Enum_Scroll("Distribution", self,  0 , [ "Uniform", "Random" ]));
	
	newInput(9, nodeValue_Curve("Trim over Length", self, CURVE_DEF_11));
	
	newInput(10, nodeValue_Float("Range", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Bool("Flip if Negative", self, false ));
	
	newInput(12, nodeValue_Enum_Scroll("Origin", self,  0 , [ "Individual", "First", "Zero" ]));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 5, 
		["Paths",     false], 0, 1, 10, 9, 
		["Scatter",   false], 8, 3, 
		["Position",  false], 12, 2, 
		["Rotation",  false], 7, 11, 
		["Scale",     false], 4, 6, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getSingleValue(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _path = getSingleValue(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function Path_Scatter() constructor {
		line_amount    = 0;
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
			if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
			
			var _path = array_safe_get_fast(paths, ind, 0);
			if(_path == 0) return out;
			
			var _pathObj = _path.path;
			if(!is_struct(_pathObj) || !struct_has(_pathObj, "getPointRatio"))
				return out;
			
			var _ind  = _path.index;
			var _ori  = _path.ori;
			var _pos  = _path.pos;
			var _rot  = _path.rot;
			var _rotW = _path.rotW;
			var _sca  = _path.sca;
			var _trm  = _path.trim;
			var _flip = _path.flip;
			
			_rat *= _trm;
			
			out = _pathObj.getPointRatio(_rat, _ind, out);
			
			var _px = out.x - _ori[0];
			var _py = out.y - _ori[1];
			
			if(_flip && angle_difference(_rotW, 90) < 0)
				_px = -_px;
			
			__temp_p = point_rotate(_px, _py, 0, 0, _rot, __temp_p);
			
			out.x = _pos[0] + __temp_p[0] * _sca;
			out.y = _pos[1] + __temp_p[1] * _sca;
			
			return out;
		}
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
		static getBoundary      = function(ind = 0) {
			var _path = getInputData(0);
			return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		var path_base = _data[ 0];
		var path_scat = _data[ 1];
		var _range    = _data[ 2];
		var _repeat   = _data[ 3];
		var _scale    = _data[ 4];
		var _seed     = _data[ 5];
		var _sca_wid  = _data[ 6];
		var _rotation = _data[ 7];
		var _distrib  = _data[ 8];
		var _trim     = _data[ 9];
		var _trim_rng = _data[10];
		var _flip     = _data[11];
		var _resetOri = _data[12];
		
		var _scattered = new Path_Scatter();
		if(path_base == noone) return _scattered;
		if(path_scat == noone) return _scattered;
		
		var _line_amounts = path_scat.getLineCount();
		_scattered.line_amount    = _repeat * _line_amounts;
		_scattered.paths          = array_create(_scattered.line_amount);
		_scattered.segment_counts = array_create(_scattered.line_amount);
		_scattered.line_lengths   = array_create(_scattered.line_amount);
		_scattered.accu_lengths   = array_create(_scattered.line_amount);
		
		random_set_seed(_seed);
		var _ind = 0;
		var p = new __vec2();
		var ori, pos;
		var _prog_raw, _prog;
		var _dir, _sca, _rot, _rotW, _trm;
		var x0, y0, x1, y1;
		
		for (var i = 0; i < _repeat; i++) {
			
			_prog_raw = _distrib? random_range(0, 1) : (i / max(1, _repeat - 1)) * 0.9999;
			_prog     = lerp(_range[0], _range[1], _prog_raw);
			
			_sca  = random_range(_scale[0], _scale[1]);
			_sca *= eval_curve_x(_sca_wid, _prog_raw);
			
			_rot = angle_random_eval(_rotation);
			
			_trm  = _trim_rng;
			_trm *= eval_curve_x(_trim, _prog_raw);
			
			for (var k = 0; k < _line_amounts; k++) {
				
				switch(_resetOri) {
					case 0 : 
						p = path_scat.getPointRatio(0, k, p);
						ori = [ p.x, p.y ];
						break;
						
					case 1 : 
						p = path_scat.getPointRatio(0, 0, p);
						ori = [ p.x, p.y ];
						break;
						
					case 2 : 
						ori = [ 0, 0 ];
						break;
				}
				
				p = path_base.getPointRatio(_prog, k, p);
				pos = [ p.x, p.y ];
				
				p = path_base.getPointRatio(clamp(_prog - 0.001, 0., 0.9999), k, p);
				x0 = p.x;
				y0 = p.y;
				
				p = path_base.getPointRatio(clamp(_prog + 0.001, 0., 0.9999), k, p);
				x1 = p.x;
				y1 = p.y;
				
				_dir  = point_direction(x0, y0, x1, y1);
				_dir += _rot;
				
				_scattered.paths[_ind] = {
					path  : path_scat,
					index : k,
					ori   : ori,
					pos   : pos,
					rot   : _dir,
					rotW  : _rot,
					sca   : _sca,
					trim  : max(0, _trm),
					flip  : _flip,
				}
				
				var _segment_counts = array_clone(path_scat.getSegmentCount(k));
				var _line_lengths   = array_clone(path_scat.getLength(k));
				var _accu_lengths   = array_clone(path_scat.getAccuLength(k));
				
				_line_lengths *= _sca;
				
				for (var j = 0, m = array_length(_accu_lengths); j < m; j++) 
					_accu_lengths[j] *= _sca;
				
				_scattered.segment_counts[_ind] = _segment_counts;
				_scattered.line_lengths[_ind]   = _line_lengths;
				_scattered.accu_lengths[_ind]   = _accu_lengths;
				
				_ind++;
			}
		}
		
		return _scattered;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_scatter, 0, bbox);
	}
}