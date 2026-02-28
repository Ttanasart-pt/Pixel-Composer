function Node_pSystem_Render_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render Path";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_render_path);
	setDimension(96, 0);
	
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Trail
	newInput(3, nodeValue_Range( "Frames", [4,4], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput(5, nodeValue_Bool(  "End Trail",  true )).setTooltip("Render trail for dead particles.");
	
	// 
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.pathnode, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Trail",     false ], 3, 4, 5, 
	];
	
	////- Nodes
	
	function _psystemPath(_node) : Path(_node) constructor {
		paths       = [];
		lengthTotal = [];
		lengthAccs  = [];
		lengths     = [];
		bboxs       = [];
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			
			draw_set_color(COLORS._main_icon);
			
			for( var i = 0, n = array_length(paths); i < n; i++ ) {
				var ps = paths[i];
				var ox = ps[0][0], nx;
				var oy = ps[0][1], ny;
				
				for( var j = 1, m = array_length(ps); j < m; j++ ) {
					nx = ps[j][0];
					ny = ps[j][1];
					
					draw_line(ox, oy, nx, ny);
					
					ox = nx;
					oy = ny;
					
				}
			}
			
			return false;
		}
		
		static getLineCount    = function(   ) /*=>*/ {return array_length(paths)};
		static getSegmentCount = function(i=0) /*=>*/ {return array_length(array_safe_get_fast(paths, i, []))};
		static getLength       = function(i=0) /*=>*/ {return array_safe_get_fast(lengthTotal, i, 0)};
		static getAccuLength   = function(i=0) /*=>*/ {return array_safe_get_fast(lengthAccs,  i, [])};
		static getBoundary     = function(i=0) /*=>*/ {return array_safe_get_fast(bboxs,       i, noone)};
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) { return getPointDistance(_rat * getLength(ind), ind, out); }
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { 
			if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
			if(array_empty(paths)) return out;
			
			var ll = getLength(ind);
			_dist = clamp(_dist, 0, ll);
			
			var _p = paths[ind];
			var _l = lengths[ind];
			var _a = getAccuLength(ind);
			var  d = _dist;
			
			for( var i = 0, n = array_length(_l); i < n; i++ ) {
				var l = _l[i];
				if(d <= l) {
					var r  = d / l;
					var p0 = _p[i    ];
					var p1 = _p[i + 1];
					
					out.x = lerp(p0[0], p1[0], r);
					out.y = lerp(p0[1], p1[1], r);
					
					return out;
				}
				
				d -= l;
			}
			
			var p1 = array_last(_p);
			out.x = p1[0];
			out.y = p1[1];
			
			return out;
		}
	}
	
	curve_fram       = undefined;
	trail_buffer     = undefined;
	buffer_data_size = 8 + 8 + 8 + 4; // px, py, thick, color
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static reset = function() {
		curve_fram = new curveMap(getInputData( 4));
		
		var _parts = getInputData(0);
		var _fram  = getInputData(3);
		
		if(!is(_parts, pSystem_Particles)) return;
		
		var _poolSize = _parts.poolSize;
		var _lenMax   = max(_fram[0], _fram[1]);
		var _bufLen   = (2 + buffer_data_size * _lenMax) * _poolSize;
		
		trail_buffer = buffer_verify(trail_buffer, _bufLen, buffer_grow);
		buffer_clear(trail_buffer);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _dim   = getDimension();
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		var _fram = getInputData(3), _fram_curved = inputs[3].attributes.curved && curve_fram != undefined;
		var _endt = getInputData(5);
		
		var _poolSize  = _parts.poolSize;
		var _lenMax    = max(_fram[0], _fram[1]);
		var _bufDatLen = 2 + buffer_data_size * _lenMax;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(trail_buffer == undefined) reset();
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act) continue;
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			
			var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
			var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
			var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
			var _bldA   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8  );
			
			var _draw_x  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
			var _draw_y  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
			var _draw_sx = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax),   buffer_f64  );
			
			var _buffOffStart = _bufDatLen * _spwnId;
			var _buffInd = _lif % _lenMax;
			var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
			
			buffer_write_at(trail_buffer, _buffOffStart, buffer_u16, _lif);
			buffer_seek(trail_buffer, buffer_seek_start, _buffOff);
			
			buffer_write(trail_buffer, buffer_f64, _draw_x);
			buffer_write(trail_buffer, buffer_f64, _draw_y);
			buffer_write(trail_buffer, buffer_f64, _draw_sx);
			
			buffer_write(trail_buffer, buffer_u8, _bldR);
			buffer_write(trail_buffer, buffer_u8, _bldG);
			buffer_write(trail_buffer, buffer_u8, _bldB);
			buffer_write(trail_buffer, buffer_u8, _bldA);
		}
		
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		
		var _path = outputs[0].getValue();
		if(!is(_path, _psystemPath)) _path = new _psystemPath(self);
		outputs[0].setValue(_path);
	
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var _paths = [];
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act && (_lif == 0 || !_endt)) continue;
			
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			random_set_seed(_seed + _spwnId);
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			var _fram_mod = _fram_curved? curve_fram.get(rat) : 1;
			var _fram_cur = round(random_range(_fram[0], _fram[1]) * _fram_mod * _mask);
			
			var _buffOffStart = _bufDatLen * _spwnId;
			
			var _trailLife = min(_fram_cur, _lif);
			var _posIndx   = _lif;
			
			if(!_act) {
				_trailLife = min(_trailLife, _lifMax - (_lif - _trailLife) - 1);
				_posIndx   = _lifMax - 1;
			}
			
			if(_trailLife <= 0) continue;
			
			var _segIndex = 0; 
			var nx, ny;
			var _p = [];
			
			repeat(_trailLife) {
				var _buffInd = _posIndx % _lenMax;
				var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
				
				buffer_seek(trail_buffer, buffer_seek_start, _buffOff);
				nx = buffer_read( trail_buffer, buffer_f64 );
				ny = buffer_read( trail_buffer, buffer_f64 );
				
				array_push(_p, [nx, ny]);
				
				_segIndex++;
				_posIndx--;
			}
			
			if(array_length(_p) > 1)
				array_push(_paths, _p);
		}
		
		var _lengthTotals = [];
		var _lengthAccs   = [];
		var _lengths      = [];
		var _bboxs        = [];
		
		for( var i = 0, n = array_length(_paths); i < n; i++ ) {
			var p  = _paths[i];
			var l  = 0;
			var la = [];
			var ls = [];
			var bb = new BoundingBox();
			
			var ox = p[0][0], nx;
			var oy = p[0][1], ny;
			
			for( var j = 1, m = array_length(p); j < m; j++ ) {
				var nx = p[j][0];
				var ny = p[j][1];
				
				var d = point_distance(ox, oy, nx, ny);
				l += d;
				ls[j-1] = d;
				la[j-1] = l;
				
				bb.addPoint(nx, ny);
				
				ox = nx;
				oy = ny;
			}
			
			_lengthTotals[i] = l;
			_lengthAccs[i]   = la;
			_lengths[i]      = ls;
			_bboxs[i]        = bb;
		}
		
		_path.paths       = _paths;
		_path.lengthTotal = _lengthTotals;
		_path.lengthAccs  = _lengthAccs;
		_path.lengths     = _lengths;
		_path.bboxs       = _bboxs;
		
	}
	
	static cleanUp = function() {
		buffer_delete_safe(trail_buffer);
	}
}