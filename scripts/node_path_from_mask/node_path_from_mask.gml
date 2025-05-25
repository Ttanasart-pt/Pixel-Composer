function Node_Path_From_Mask(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path from Mask";
	
	newInput(0, nodeValue_Surface("Mask"));
	
	newInput(2, nodeValue_Bool("Smooth",   false));
	newInput(1, nodeValue_Float("Smoothness", 2));
		
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0, 
		["Smooth", false, 2], 1, 
	];
	
	////- Nodes
	
	temp_surface = [ surface_create(1, 1) ];
	
	anchors     = [];
	lengthTotal = 0;
	lengths     = [];
	lengthAccs  = [];
	boundary    = new BoundingBox();
	loop		= true;
	cached_pos  = ds_map_create();
	
	attributes.maximum_dim    = 64;
	attributes.maximum_points = 4096;
	array_push(attributeEditors, ["Max Points", function() /*=>*/ {return attributes.maximum_points}, textBox_Number(function(v) /*=>*/ {return setAttribute("maximum_points", clamp(v, 8, 10000))})]);
	
	static getBoundary		= function() /*=>*/ {return boundary};
	static getAccuLength	= function() /*=>*/ {return lengthAccs};
	static getLength		= function() /*=>*/ {return lengthTotal};
	static getSegmentCount  = function() /*=>*/ {return 1};
	static getLineCount     = function() /*=>*/ {return 1};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{string_format(_dist, 0, 6)},{_ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
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
		
		cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
		
		return out;
	}
	
	static getPointRatio    = function(_rat, _ind = 0, out = undefined) {
		return getPointDistance(frac(_rat) * lengthTotal, _ind, out);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
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
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		var _surf = getInputData(0);
		
		var _smt   = getInputData(2);
		var _smtEp = getInputData(1);
		
		anchors = [];
		if(!is_surface(_surf)) return;
		
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[0], sh_image_trace);
			shader_set_f("dimension", _dim);
			draw_surface_stretched(_surf, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		// printSurface("mask", temp_surface[0]);
		
		var _amo  = attributes.maximum_points;
		var _sbuf = buffer_from_surface(temp_surface[0], false);
		var _obuf = buffer_create(_amo * 2 * 4, buffer_fixed, 4);
		var _args = buffer_create(1, buffer_grow, 1);
		buffer_to_start(_args);
		
		buffer_write(_args, buffer_u64, buffer_get_address(_sbuf));
		buffer_write(_args, buffer_u64, buffer_get_address(_obuf));
		
		buffer_write(_args, buffer_u16, _dim[0]);
		buffer_write(_args, buffer_u16, _dim[1]);
		buffer_write(_args, buffer_u16, _amo);
		
		buffer_write(_args, buffer_bool, bool(_smt));
		buffer_write(_args, buffer_bool, 0);
		buffer_write(_args, buffer_f64,  _smtEp);
		
		var _ancAmo = path_from_mask_ext(buffer_get_address(_args));
		
		var ox, oy, nx, ny;
		var _lind = 0;
		
		lengthTotal = 0;
		lengths     = array_verify(lengths,    _ancAmo - 1);
		lengthAccs  = array_verify(lengthAccs, _ancAmo - 1);
		boundary    = new BoundingBox();
		
		buffer_to_start(_obuf);
		for( var i = 0; i < _ancAmo; i++ ) {
			nx = buffer_read(_obuf, buffer_u16) + .5;
			ny = buffer_read(_obuf, buffer_u16) + .5;
			
			anchors[i][0] = nx;
			anchors[i][1] = ny;
			
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
		
		buffer_delete(_sbuf);
		buffer_delete(_obuf);
		
	}
	
	static getGraphPreviewSurface = function() { return /*temp_surface[0]*/ getInputData(0); }
	static getPreviewValues       = function() { return /*temp_surface[0]*/ getInputData(0); }
}