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
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	input_display_list = [ 5, 
		["Paths",     false], 0, 1, 10, 9, 
		["Scatter",   false], 8, 3, 
		["Position",  false], 2, 
		["Rotation",  false], 7, 11, 
		["Scale",     false], 4, 6, 
	];
	
	cached_pos     = ds_map_create();
	paths          = [];
	segment_counts = [];
	line_lengths   = [];
	accu_lengths   = [];
	line_amount    = 0;
	
	__temp_p = [ 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _path = getInputData(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
	} #endregion
	
	static getLineCount    = function() { return line_amount; }
	static getSegmentCount = function(ind = 0) { return array_safe_get_fast(segment_counts, ind); }
	static getLength       = function(ind = 0) { return array_safe_get_fast(line_lengths, ind); }
	static getAccuLength   = function(ind = 0) { return array_safe_get_fast(accu_lengths, ind); }
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _path = array_safe_get_fast(paths, ind, 0);
		if(_path == 0) return out;
		
		var _pathObj = _path.path;
		if(!is_struct(_pathObj) || !struct_has(_pathObj, "getPointRatio"))
			return out;
		
		var _ori  = _path.ori;
		var _pos  = _path.pos;
		var _rot  = _path.rot;
		var _rotW = _path.rotW;
		var _sca  = _path.sca;
		var _trm  = _path.trim;
		var _flip = _path.flip;
		
		_rat *= _trm;
		
		out = _pathObj.getPointRatio(_rat, 0, out);
		
		var _px = out.x - _ori[0];
		var _py = out.y - _ori[1];
		
		if(_flip && angle_difference(_rotW, 90) < 0)
			_px = -_px;
		
		__temp_p = point_rotate(_px, _py, 0, 0, _rot, __temp_p);
		
		out.x = _pos[0] + __temp_p[0] * _sca;
		out.y = _pos[1] + __temp_p[1] * _sca;
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
	
	static getBoundary = function(ind = 0) { #region
		var _path = getInputData(0);
		return struct_has(_path, "getBoundary")? _path.getBoundary(ind) : new BoundingBox( 0, 0, 1, 1 ); 
	} #endregion
		
	static update = function() { #region
		ds_map_clear(cached_pos);
		
		var path_base = getInputData(0);
		var path_scat = getInputData(1);
		var _range    = getInputData(2);
		var _amount   = getInputData(3);
		var _scale    = getInputData(4);
		var _seed     = getInputData(5);
		var _sca_wid  = getInputData(6);
		var _rotation = getInputData(7);
		var _distrib  = getInputData(8);
		var _trim     = getInputData(9);
		var _trim_rng = getInputData(10);
		var _flip     = getInputData(11);
		
		amount = 0;
		
		if(path_base == noone) return;
		if(path_scat == noone) return;
		
		line_amount    = _amount;
		paths          = array_create(_amount);
		segment_counts = array_create(_amount);
		line_lengths   = array_create(_amount);
		accu_lengths   = array_create(_amount);
		
		var p = new __vec2();
		
		random_set_seed(_seed);
		
		for (var i = 0, n = array_length(paths); i < n; i++) {
			
			p = path_scat.getPointRatio(0, p);
			var ori = [ p.x, p.y ];
			
			var _prog_raw = _distrib? random_range(0, 1) : (i / max(1, line_amount - 1)) * 0.9999;
			var _prog     = lerp(_range[0], _range[1], _prog_raw);
			
			p = path_base.getPointRatio(_prog, p);
			var pos = [ p.x, p.y ];
			
			p = path_base.getPointRatio(clamp(_prog - 0.001, 0., 0.9999), p);
			var x0 = p.x;
			var y0 = p.y;
			
			p = path_base.getPointRatio(clamp(_prog + 0.001, 0., 0.9999), p);
			var x1 = p.x;
			var y1 = p.y;
			
			var _dir  = point_direction(x0, y0, x1, y1);
			var _sca  = random_range(_scale[0], _scale[1]);
			    _sca *= eval_curve_x(_sca_wid, _prog_raw);
			
			var _rot  = _dir;
			var _rotW = angle_random_eval(_rotation);
			    _rot += _rotW;
			    
			var _trm  = _trim_rng;
			    _trm *= eval_curve_x(_trim, _prog_raw);
			
			paths[i] = {
				path : path_scat,
				ori  : ori,
				pos  : pos,
				rot  : _rot,
				rotW : _rotW,
				sca  : _sca,
				trim : max(0, _trm),
				flip : _flip,
			}
			
			var _segment_counts = array_clone(path_scat.getSegmentCount(0));
			var _line_lengths   = array_clone(path_scat.getLength(0));
			var _accu_lengths   = array_clone(path_scat.getAccuLength(0));
			
			_line_lengths *= _sca;
			
			for (var j = 0, m = array_length(_accu_lengths); j < m; j++) 
				_accu_lengths[j] *= _sca;
			
			segment_counts[i] = _segment_counts;
			line_lengths[i]   = _line_lengths;
			accu_lengths[i]   = _accu_lengths;
		}
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_scatter, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}