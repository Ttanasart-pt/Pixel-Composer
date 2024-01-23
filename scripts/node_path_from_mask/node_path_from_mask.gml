function Node_Path_From_Mask(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path from Mask";
	
	inputs[| 0] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Smooth angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 15);
		
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	temp_surface = [ surface_create(1, 1) ];
	
	anchors     = [];
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= true;
	cached_pos  = ds_map_create();
	
	static getBoundary		= function() { return boundary; }
	static getAccuLength	= function() { return lengthAccs; }
	static getLength		= function() { return lengthTotal; }
	static getSegmentCount  = function() { return 1; }
	static getLineCount     = function() { return 1; }
	
	static getPointDistance = function(_seg, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{_seg},{_ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			return out;
		}
		
		var _aid = 0;
		var _dst = _seg;
		
		for( var i = 0, n = array_length(lengthAccs); i < n; i++ ) {
			if(_seg == lengthAccs[i]) {
				out.x = anchors[i][0];
				out.y = anchors[i][1];
				
				return out;
			}
				
			if(_seg < lengthAccs[i]) {
				_aid = i;
				if(i) _dst = _seg - lengthAccs[i - 1];
				break;
			}
		}
		
		out.x = lerp(anchors[i][0], anchors[i + 1][0], _dst / lengths[_aid]);
		out.y = lerp(anchors[i][1], anchors[i + 1][1], _dst / lengths[_aid]);
		
		cached_pos[? _cKey] = out.clone();
		
		return out;
	} #endregion
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) { #region
		var pix = frac(_rat) * lengthTotal;
		return getPointDistance(pix, _ind, out);
	} #endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
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
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[0], sh_image_trace);
			shader_set_f("dimension", _dim);
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		var _w   = _dim[0], _h  = _dim[1];
		var _x   = 0,       _y  = 0;
		
		var _buff = buffer_from_surface(temp_surface[0], false);
		var _emp  = false;
		
		while(buffer_getPixel(_buff, _w, _h, _x, _y) == 0) {
			_x++;
			if(_x == _w) {
				_x = 0;
				_y++;
				if(_y == _h) {
					_emp = true;
					break;
				}
			}
		}
		
		if(_emp) return;
		
		var _sx = _x;
		var _sy = _y;
		var _c  = 0;
		var _px = _x;
		var _py = _y;
		var _a  = [];
		var _amo = _w * _h;
		var _rep = 0;
		
		do {
			buffer_setPixel(_buff, _w, _h, _x, _y, 0);
			array_push(_a, [ _x + 0.5, _y + 0.5 ]);
			
			     if(_x < _w - 1 && buffer_getPixel(_buff, _w, _h, _x + 1, _y)) { _x++; }
			else if(_y < _h - 1 && buffer_getPixel(_buff, _w, _h, _x, _y + 1)) { _y++; }
			else if(_x > 0      && buffer_getPixel(_buff, _w, _h, _x - 1, _y)) { _x--; }
			else if(_y > 0      && buffer_getPixel(_buff, _w, _h, _x, _y - 1)) { _y--; }
			
			else if(_x < _w - 1 && _y < _h - 1 && buffer_getPixel(_buff, _w, _h, _x + 1, _y + 1)) { _x++; _y++; }
			else if(_x < _w - 1 && _y > 0      && buffer_getPixel(_buff, _w, _h, _x + 1, _y - 1)) { _x++; _y--; }
			else if(_x > 0      && _y < _h - 1 && buffer_getPixel(_buff, _w, _h, _x - 1, _y + 1)) { _x--; _y++; }
			else if(_x > 0      && _y > 0      && buffer_getPixel(_buff, _w, _h, _x - 1, _y - 1)) { _x--; _y--; }
			
			if(++_rep >= _amo) break;
		} until(_x == _sx && _y == _sy);
		
		buffer_delete(_buff);
		
		anchors = [];
		
		var lx = _a[0][0];
		var ly = _a[0][1];
		var ox, oy, nx, ny;
		
		array_push(_a, _a[0]);
		array_push(anchors, _a[0]);
		
		for( var i = 0, n = array_length(_a); i < n; i++ ) {
			nx = _a[i][0];
			ny = _a[i][1];
			
			if(i) {
				var na = point_direction(ox, oy, nx, ny);
				var la = point_direction(lx, ly, nx, ny);
				
				if(abs(angle_difference(na, la)) > _smt) {
					lx = ox;
					ly = oy;
					
					array_push(anchors, [ ox, oy ]);
				}
			}
			
			ox = nx;
			oy = ny;
		}
		
		array_push(anchors, _a[0]);
		
		var ox, oy, nx, ny;
		lengthTotal = 0;
		lengths     = [];
		lengthAccs  = [];
		boundary    = new BoundingBox();
		
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			nx = _a[i][0];
			ny = _a[i][1];
			
			boundary.addPoint(nx, ny);
			
			if(i) {
				var ds = point_distance(ox, oy, nx, ny);
				lengthTotal += ds;
				array_push(lengths,    ds);
				array_push(lengthAccs, lengthTotal);
			}
			
			ox = nx;
			oy = ny;
		}
	} #endregion
	
	static getGraphPreviewSurface = function() { return /*temp_surface[0]*/ getInputData(0); }
	static getPreviewValues       = function() { return /*temp_surface[0]*/ getInputData(0); }
}