function Node_VFX_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "VFX Trail";
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	length     = [];
	lengthAcc  = [];
	lines      = [];
	lineLength = [];
	lineData   = [];
	
	newInput(0, nodeValue_Particle()).setVisible(true, true);
	
	newInput(1, nodeValue_Int("Life", 4 ));
	
	newInput(2, nodeValue_Bool("Color", false ));
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		0, 
		new Inspector_Label("To render trail properly, make sure to enable \"Output all particles\" in the spawner settings."),
		1, 2, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
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
	}
	
	static getLineCount		= function()      { return array_length(lines);                       }
	static getSegmentCount	= function()      { return array_length(lines);                       }
	static getLength		= function(index) { return array_safe_get_fast(length, index);        }
	static getAccuLength	= function(index) { return array_safe_get_fast(lengthAcc, index, []); }
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _p0, _p1;
		var _x, _y;
		
		var line = lines[_ind];
		var _len = lineLength[_ind] - 1;
		var _st  = _rat * _len;
		var _fl  = floor(_st);
		var _fr  = frac(_st);
				   
		_p0 = line[clamp(_fl + 0, 0, _len)];
		_p1 = line[clamp(_fl + 1, 0, _len)];
		
		if(!is_array(_p0) || !is_array(_p1)) return out;
		
		out.x = lerp(_p0[0], _p1[0], _fr);
		out.y = lerp(_p0[1], _p1[1], _fr);
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / length[ind], ind, out); }
	
	static getPathData = function() { return lineData; } 
	
	static getBoundary = function() {
		var boundary = new BoundingBox();
		
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var _line = lines[i];
			for( var j = 0, m = array_length(_line); j < m; j++ )
				boundary.addPoint(_line[j][0], _line[j][1]);
		}
		
		return boundary; 
	}
	
	static update = function() {
		var _vfxs = getInputData(0);
		
		if(array_empty(_vfxs) || !is_array(_vfxs)) return;
		
		var _life = getInputData(1); _life = max(_life, 1);
		var _colr = getInputData(2);
		
		var _totlLen = array_length(_vfxs);
		lines        = array_verify(lines,      _totlLen);
		length       = array_verify(length,     _totlLen);
		lengthAcc    = array_verify(lengthAcc,  _totlLen);
		lineLength   = array_verify(lineLength, _totlLen);
		lineData     = array_verify(lineData,   _totlLen);
		
		var _len = 0;
		
		for( var i = 0; i < _totlLen; i++ ) {
			var _vfx = _vfxs[i];
			
			var _posx = _vfx.x_history;
			var _posy = _vfx.y_history;
			
			var _trail_ed  = min(_vfx.life_incr, _vfx.life_total);
			var _trail_st  = max(1, _vfx.trailLife - _life);
			var _trail_len = _trail_ed - _trail_st;
			
			if(_trail_len <= 0) continue;
			
			var _lngh = 0;
			var _ox   = _posx[_trail_st], _nx;
			var _oy   = _posy[_trail_st], _ny;
			var _line = array_verify(lines[_len],     _trail_len);
			var _lenA = array_verify(lengthAcc[_len], _trail_len - 1);
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
			
			lines[_len]      = _line;
			length[_len]     = _lngh;
			lengthAcc[_len]  = _lenA;
			lineLength[_len] = _trail_len;
			lineData[_len]   = { color: _vfx.blend, };
			_len++;
		}
		
		array_resize(lines,      _len);
		array_resize(length,     _len);
		array_resize(lengthAcc,  _len);
		array_resize(lineLength, _len);
		array_resize(lineData,   _len);
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_vfx_trail, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}

	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}