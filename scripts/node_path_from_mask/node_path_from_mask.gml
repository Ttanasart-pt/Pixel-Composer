function Node_Path_From_Mask(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path from Mask";
	
	newInput(0, nodeValue_Surface("Mask", self));
	
	newInput(1, nodeValue_Float("Smooth angle", self, 15));
		
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	temp_surface = [ surface_create(1, 1) ];
	
	anchors     = [];
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= true;
	cached_pos  = ds_map_create();
	
	attributes.maximum_dim = 64;
	array_push(attributeEditors, ["Max Dimension", function() { return attributes.maximum_dim; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.maximum_dim = clamp(val, 8, 8192); })]);
	
	static getBoundary		= function() { return boundary; }
	static getAccuLength	= function() { return lengthAccs; }
	static getLength		= function() { return lengthTotal; }
	static getSegmentCount  = function() { return 1; }
	static getLineCount     = function() { return 1; }
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_dist},{_ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			
			// print($"Getting cache {_cKey} : {_dist} > {out}");
			return out;
		}
		
		var _aid = 0;
		var _dst = _dist;
		
		for( var i = 0, n = array_length(lengthAccs); i < n; i++ ) {
			if(_dist == lengthAccs[i]) {
				out.x = anchors[i + 1][0];
				out.y = anchors[i + 1][1];
				
				return out;
			}
				
			if(_dist < lengthAccs[i]) {
				_aid = i;
				if(i) _dst = _dist - lengthAccs[i - 1];
				break;
			}
		}
		
		var _a0  = anchors[i];
		var _a1  = anchors[i + 1];
		var _rat = _dst / lengths[_aid];
		
		out.x = lerp(_a0[0], _a1[0], _rat);
		out.y = lerp(_a0[1], _a1[1], _rat);
		
		// print($"Getting position {_cKey} : {_dist} - {i} > {out}");
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	} #endregion
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { #region
		var pix = frac(_rat) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
		draw_set_color(COLORS._main_accent);
		var ox, oy, nx, ny, sx, sy;
		
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			nx = _x + anchors[i][0] * _s;
			ny = _y + anchors[i][1] * _s;
			
			if(i) draw_line(ox, oy, nx, ny);
			else {
				sx = nx;
				sy = ny;
			}
			
			draw_circle(nx, ny, 3, false);
			
			ox = nx;
			oy = ny;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		ds_map_clear(cached_pos);
		var _surf = getInputData(0);
		var _smt  = getInputData(1);
		
		anchors = [];
		if(!is_surface(_surf)) return;
		
		#region content extract
			var _dim = surface_get_dimension(_surf);
			var _sca = min(1, attributes.maximum_dim / _dim[0], attributes.maximum_dim / _dim[1]);
			_dim[0] *= _sca;
			_dim[1] *= _sca;
			
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
			
			surface_set_shader(temp_surface[0], sh_image_trace);
				shader_set_f("dimension", _dim);
				draw_surface_stretched(_surf, 0, 0, _dim[0], _dim[1]);
			surface_reset_shader();
			
			var _w   = _dim[0], _h  = _dim[1];
			var _x   = 0,       _y  = 0;
			
			var _buff = buffer_from_surface(temp_surface[0], false);
			var _emp  = true;
			var _ind  = 0;
			
			buffer_seek(_buff, buffer_seek_start, 0);
			repeat(_w * _h) {
				var _b = buffer_read(_buff, buffer_u32);
				if(_b > 0) {
					_emp = false;
					_x   = _ind % _w;
					_y   = floor(_ind / _w);
					break;
				}
				_ind++;
			}
		#endregion
		
		if(_emp) { print("Empty surface"); return; }
		
		var _sx  = _x, _sy  = _y;
		var _px  = _x, _py  = _y;
		var _nx  = _x, _ny  = _y;
		var _amo = _w * _h;
		var _rep = 0;
		
		var _a   = array_create(_amo * 2);
		var _ind = 0;
		
		do {
			buffer_write_at(_buff, (_y * _w + _x) * 4, buffer_u32, 0);
			
			_nx = _x / _sca + 0.5;
			_ny = _y / _sca + 0.5;
			
			if(_ind == 0 || _px != _nx || _py != _ny) {
				_a[_ind++] = _nx;
				_a[_ind++] = _ny;
			}
			
			_px = _nx;
			_py = _ny;
			
			     if(_x < _w - 1 && buffer_read_at(_buff, ((_y    ) * _w + _x + 1) * 4, buffer_u32)) { _x++; }
			else if(_y < _h - 1 && buffer_read_at(_buff, ((_y + 1) * _w + _x    ) * 4, buffer_u32)) { _y++; }
			else if(_x > 0      && buffer_read_at(_buff, ((_y    ) * _w + _x - 1) * 4, buffer_u32)) { _x--; }
			else if(_y > 0      && buffer_read_at(_buff, ((_y - 1) * _w + _x    ) * 4, buffer_u32)) { _y--; }
			
			else if(_x < _w - 1 && _y < _h - 1 && buffer_read_at(_buff, ((_y + 1) * _w + _x + 1) * 4, buffer_u32)) { _x++; _y++; }
			else if(_x < _w - 1 && _y > 0      && buffer_read_at(_buff, ((_y - 1) * _w + _x + 1) * 4, buffer_u32)) { _x++; _y--; }
			else if(_x > 0      && _y < _h - 1 && buffer_read_at(_buff, ((_y + 1) * _w + _x - 1) * 4, buffer_u32)) { _x--; _y++; }
			else if(_x > 0      && _y > 0      && buffer_read_at(_buff, ((_y - 1) * _w + _x - 1) * 4, buffer_u32)) { _x--; _y--; }
			
			if(++_rep >= _amo) break;
		} until(_x == _sx && _y == _sy);
		
		buffer_delete(_buff);
		
		anchors = array_verify(anchors, _ind / 2);
		var _aind = 0;
		
		var ox, oy, cx, cy, nx, ny;
		var a0, a1;
		
		var _aamo = _ind / 2;
		if(_aamo <= 2) return;
		
		for( var i = 0; i < _aamo; i++ ) {
			ox = _a[(i - 1 + _aamo) % _aamo * 2 + 0];
			oy = _a[(i - 1 + _aamo) % _aamo * 2 + 1];
			cx = _a[i * 2 + 0];
			cy = _a[i * 2 + 1];
			nx = _a[(i + 1 + _aamo) % _aamo * 2 + 0];
			ny = _a[(i + 1 + _aamo) % _aamo * 2 + 1];
			
			a0 = point_direction(ox, oy, cx, cy);
			a1 = point_direction(cx, cy, nx, ny);
			
			if(abs(angle_difference(a0, a1)) > _smt)
				anchors[_aind++] = [ cx, cy ];
			
		}
		
		anchors[_aind++] = [ _a[0], _a[1] ];
		
		var _ancAmo = _aind;
		array_resize(anchors, _ancAmo);
		
		var ox, oy, nx, ny;
		lengthTotal = 0;
		lengths     = array_verify(lengths,    _ancAmo - 1);
		lengthAccs  = array_verify(lengthAccs, _ancAmo - 1);
		boundary    = new BoundingBox();
		
		var _lind = 0;
		
		for( var i = 0; i < _ancAmo; i++ ) {
			nx = anchors[i][0];
			ny = anchors[i][1];
			
			boundary.addPoint(nx, ny);
			
			if(i) {
				var ds = point_distance(ox, oy, nx, ny);
				
				lengthTotal      += ds;
				lengths[_lind]    = ds;
				lengthAccs[_lind] = lengthTotal;
				_lind++;
			}
			
			ox = nx;
			oy = ny;
		}
		
		// print($"\n=========== Path ===========");
		// print($"Anchors  : {anchors}");
		// print($"Lengths  : {lengths}");
		// print($"Len Accs : {lengthAccs}");
	} #endregion
	
	static getGraphPreviewSurface = function() { return /*temp_surface[0]*/ getInputData(0); }
	static getPreviewValues       = function() { return /*temp_surface[0]*/ getInputData(0); }
}