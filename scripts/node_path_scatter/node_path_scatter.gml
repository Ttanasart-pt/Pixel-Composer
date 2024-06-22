function Node_Path_Scatter(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Scatter Path";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Base Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Scatter Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 3] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 4] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 6] = nodeValue("Scale over Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 7] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 45, 135, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
	
	inputs[| 8] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Uniform", "Random" ]);
	
	inputs[| 9] = nodeValue("Trim over Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 10] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 11] = nodeValue("Flip if Negative", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 12] = nodeValue("Origin", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Individual", "First", "Zero" ]);
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [ 5, 
		["Paths",     false], 0, 1, 10, 9, 
		["Scatter",   false], 8, 3, 
		["Position",  false], 12, 2, 
		["Rotation",  false], 7, 11, 
		["Scale",     false], 4, 6, 
	];
	
	cached_pos     = ds_map_create();
	
	line_amount    = 0;
	paths          = [];
	segment_counts = [];
	line_lengths   = [];
	accu_lengths   = [];
	
	__temp_p = [ 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _path = getInputData(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
	}
	
	static getLineCount     = function() { return line_amount; }
	static getSegmentCount  = function(ind = 0) { return array_safe_get_fast(segment_counts, ind); }
	static getLength        = function(ind = 0) { return array_safe_get_fast(line_lengths, ind); }
	static getAccuLength    = function(ind = 0) { return array_safe_get_fast(accu_lengths, ind); }
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
	
	static update = function() {
		ds_map_clear(cached_pos);
		
		var path_base = getInputData(0);
		var path_scat = getInputData(1);
		var _range    = getInputData(2);
		var _repeat   = getInputData(3);
		var _scale    = getInputData(4);
		var _seed     = getInputData(5);
		var _sca_wid  = getInputData(6);
		var _rotation = getInputData(7);
		var _distrib  = getInputData(8);
		var _trim     = getInputData(9);
		var _trim_rng = getInputData(10);
		var _flip     = getInputData(11);
		var _resetOri = getInputData(12);
		
		if(path_base == noone) return;
		if(path_scat == noone) return;
		var p = new __vec2();
		
		random_set_seed(_seed);
		
		var _line_amounts = path_scat.getLineCount();
		var _ind = 0;
		
		line_amount    = _repeat * _line_amounts;
		paths          = array_create(line_amount);
		segment_counts = array_create(line_amount);
		line_lengths   = array_create(line_amount);
		accu_lengths   = array_create(line_amount);
		
		var ori, pos;
		var _prog_raw, _prog;
		var x0, y0, x1, y1;
		var _dir, _sca, _rot, _rotW, _trm;
		
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
				
				paths[_ind] = {
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
				
				segment_counts[_ind] = _segment_counts;
				line_lengths[_ind]   = _line_lengths;
				accu_lengths[_ind]   = _accu_lengths;
				
				_ind++;
			}
		}
		
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_path_scatter, 0, bbox);
	}
}