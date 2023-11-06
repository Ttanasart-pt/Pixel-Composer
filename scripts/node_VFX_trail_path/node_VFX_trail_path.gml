function Node_VFX_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "VFX Trail";
	previewable = false;
	
	w = 96;
	length     = [];
	lengthAcc  = [];
	lines      = [];
	lineLength = [];
	lineData   = [];
	
	inputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, -1 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Life", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4 );
	
	inputs[| 2] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var _line = lines[i];
			
			for( var j = 1, m = array_length(_line); j < m; j++ ) {
				var p0 = _line[j - 1];
				var p1 = _line[j - 0];
				
				draw_line(_x + p0[0] * _s, _y + p0[1] * _s, 
						  _x + p1[0] * _s, _y + p1[1] * _s);
			}
		}
	} #endregion
	
	static getLineCount		= function()      { return array_length(lines); }
	static getSegmentCount	= function()      { return array_length(lines); }
	static getLength		= function(index) { return array_safe_get(length, index); }
	static getAccuLength	= function(index) { return array_safe_get(lengthAcc, index, []); }
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _p0, _p1;
		var _x, _y;
		
		var line = lines[_ind];
		var _st  = _rat * (lineLength[_ind] - 1);
		
		_p0 = line[clamp(floor(_st) + 0, 0, array_length(line) - 1)];
		_p1 = line[clamp(floor(_st) + 1, 0, array_length(line) - 1)];
		
		if(!is_array(_p0)) return out;
		if(!is_array(_p1)) return out;
		
		out.x = lerp(_p0[0], _p1[0], frac(_st));
		out.y = lerp(_p0[1], _p1[1], frac(_st));
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / length[ind], ind, out); }
	
	static getPathData = function() { return lineData; } 
	
	static getBoundary = function() { #region
		var boundary = new BoundingBox();
		
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var _line = lines[i];
			for( var j = 0, m = array_length(_line); j < m; j++ )
				boundary.addPoint(_line[j][0], _line[j][1]);
		}
		
		return boundary; 
	} #endregion
	
	static update = function() { #region
		var _vfxs = getInputData(0);
		if(array_empty(_vfxs) || !is_array(_vfxs)) return;
		
		var _life = getInputData(1); _life = max(_life, 1);
		var _colr = getInputData(2);
		
		lines      = [];
		length     = [];
		lengthAcc  = [];
		lineLength = [];
		lineData   = [];
		
		for( var i = 0; i < array_length(_vfxs); i++ ) {
			var _vfx = _vfxs[i];
			
			var _posx = _vfx.x_history;
			var _posy = _vfx.y_history;
			
			var _trail_ed  = min(_vfx.life_incr, _vfx.life_total);
			var _trail_st  = max(1, _vfx.trailLife - _life);
			var _trail_len = _trail_ed - _trail_st;
			
			//if(_vfx.life_total > 0) print($"{_vfx.active} | {_vfx.seed} : {_vfx.trailLife}")
			if(_trail_len <= 0) continue;
			
			var _lngh = 0;
			var _ox   = _posx[_trail_st], _nx;
			var _oy   = _posy[_trail_st], _ny;
			var _line = array_create(_trail_len);
			var _lenA = array_create(_trail_len - 1);
			_line[0]  = [ _ox, _oy ];
			
			for( var j = 0; j <= _trail_len; j++ ) {
				var _index = _trail_st + j;
				if(j == _trail_len) {
					_nx = _vfx.drawx;
					_ny = _vfx.drawy;
				} else {
					_nx = _posx[_index];
					_ny = _posy[_index];
				}
				
				var dist = point_distance(_ox, _oy, _nx, _ny);
				_lngh += dist;
				_lenA[j] = _lngh;
				_line[j] = [ _nx, _ny ];
				
				_ox = _nx;
			}
			
			array_push(lines,      _line);
			array_push(length,     _lngh);
			array_push(lengthAcc,  _lenA);
			array_push(lineLength, array_length(_line));
			
			if(_colr)
			array_push(lineData, {
				color: _vfx.blend,
			});
		}
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_vfx_trail, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}