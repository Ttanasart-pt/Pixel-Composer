function Node_pSystem_3D_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Trail Path";
	is_3D = NODE_3D.polygon;
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_3d_trail;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Trail
	newInput(3, nodeValue_Range( "Frames", [4,4], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	
	newOutput(0, nodeValue_Output( "Path", VALUE_TYPE.pathnode, self ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Trail",     false ], 3, 4, 
	];
	
	////- Path
	
	segment_count = 0;
	segments      = [];
	boundary      = new BoundingBox3D();
	
	lengthTotal = [];
	lengths     = [];
	lengthAccs  = [];
	loop		= false;
	
	cached_pos  = ds_map_create();
	
	static getLineCount     = function() /*=>*/ {return segment_count};
	static getSegmentCount  = function(i) /*=>*/ {return array_length(segments[i]) - 1};
	static getAccuLength	= function(i) /*=>*/ {return lengthAccs[i]};
	static getLength		= function(i) /*=>*/ {return lengthTotal[i]};
	static getTangentRatio  = function(_rat) /*=>*/ {return 0};
	static getBoundary		= function() /*=>*/ {return boundary};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec3PC(); 
		else { out.x = 0; out.y = 0; out.z = 0; }
		
		var _cKey = $"{_dist}|{_ind}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.z = _p.z;
			out.color = _p.color;
			return out;
		}
		
		var _ls = lengths[_ind];
		var _sg = segments[_ind];
		var _len = array_length(_ls);
		
		for( var i = 0; i < _len; i++ ) {
			var _l = _ls[i];
			if(_l >= _dist) break;
			_dist -= _l;
		}
		
		var ii = i * 4;
		
		if(i >= _len) {
			out.x     = _sg[ii+0];
			out.y     = _sg[ii+1];
			out.z     = _sg[ii+2];
			out.color = _sg[ii+3];
			return out; 
		}
		
		var _r = _dist / _l;
		out.x  = lerp(_sg[ii+0], _sg[ii+4+0], _r);
		out.y  = lerp(_sg[ii+1], _sg[ii+4+1], _r);
		out.z  = lerp(_sg[ii+2], _sg[ii+4+2], _r);
		out.color = _sg[ii+3];
		cached_pos[? _cKey] = new __vec3PC(out.x, out.y, out.z, 1, out.color);
		
		return out;
	}
	
	static getPointRatio = function(_r, _ind = 0, out = undefined) { return getPointDistance(clamp(_r, 0, 1) * lengthTotal[_ind], _ind, out); }
		
	static getPointTangent  = function(_rat, _ind = 0) {
		var _r0 = clamp(clamp(_rat, .001, 0.999) - .001, 0, .999);
		var _r2 = clamp(clamp(_rat, .001, 0.999) + .001, 0, .999);
		
		getPointRatio(_r0, _ind, __temp_p);
		var _p0x = __temp_p.x;
		var _p0y = __temp_p.y;
		var _p0z = __temp_p.z;
		
		getPointRatio(_r2, _ind, __temp_p);
		var _p1x = __temp_p.x;
		var _p1y = __temp_p.y;
		var _p1z = __temp_p.z;
		
		var _dir = point_direction(_p0x, _p0y, _p1x, _p1y);
		return _dir;
	}
	
	static setLength = function() {
		boundary    = new BoundingBox3D();
		
		lengthTotal = [];
		lengths     = [];
		lengthAccs  = [];
		
		var ox, oy, oz, nx, ny, nz;
		
		for( var i = 0; i < segment_count; i++ ) {
			var _sgs  = segments[i];
			var _len  = array_length(_sgs);
			var _lens = array_create((_len / 4) - 1);
			var _lena = array_create((_len / 4) - 1);
			var _lent = 0;
			
			for( var j = 0; j < _len; j += 4 ) {
				nx = _sgs[j+0];
				ny = _sgs[j+1];
				nz = _sgs[j+2];
				
				if(j) { 
					var _d = point_distance_3d(ox, oy, oz, nx, ny, nz);
					_lent += _d;
					_lens[(j/4)-1] = _d;
					_lena[(j/4)-1] = _lent;
				}
				
				ox = nx;
				oy = ny;
				oz = nz;
			}
			
			lengthTotal[i] = _lent;
			lengths[i]     = _lens;
			lengthAccs[i]  = _lena;
		}
	}
	
	////- Draw
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		var ansize = array_length(inputs) - input_fix_len;
		var edited = false;
		
		var _qinv   = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
		var _camera = _params.scene.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		var ray     = _camera.viewPointToWorldRay(_mx, _my);
		
		/////////////////////////////////////////////////////// DRAW PATH ///////////////////////////////////////////////////////
				
		draw_set_color(COLORS._main_accent);
		
		var _v3 = new __vec3();
		
		for( var i = 0; i < segment_count; i++ ) {
			var _seg = segments[i];
			
			var _px = 0, _py = 0, _pz = 0; 
			var _ox = 0, _oy = 0; 
			var _nx = 0, _ny = 0; 
			var  p  = 0;
				
			for( var j = 0, m = array_length(_seg); j < m; j += 4 ) {
				_v3.x = _seg[j + 0];
				_v3.y = _seg[j + 1];
				_v3.z = _seg[j + 2];
				
				var _posView = _camera.worldPointToViewPoint(_v3);
				_nx = _posView.x;
				_ny = _posView.y;
				
				if(j) draw_line_width(_ox, _oy, _nx, _ny, 1);
				
				_ox = _nx;
				_oy = _ny;
			}
		}
		
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
	////- Nodes
	
	curve_fram       = undefined;
	trail_buffer     = undefined;
	buffer_data_size = 8*3 + 4; // px, py, pz, cr, cg, cb
	
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
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		var _fram = getInputData(3), _fram_curved = inputs[3].attributes.curved && curve_fram != undefined;
		
		var _poolSize  = _parts.poolSize;
		var _lenMax    = max(_fram[0], _fram[1]);
		var _bufDatLen = 2 + buffer_data_size * _lenMax;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(trail_buffer == undefined) reset();
		ds_map_clear(cached_pos);
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act) continue;
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			var _dx     = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx), buffer_f64  );
			var _dy     = buffer_read(    _partBuff, buffer_f64  );
			var _dz     = buffer_read(    _partBuff, buffer_f64  );
			
			var _cc     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u32  );
			
			var _buffOffStart = _bufDatLen * _spwnId;
			var _buffInd = _lif % _lenMax;
			var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
			
			buffer_write_at( trail_buffer, _buffOffStart, buffer_u16, _lif);
			buffer_write_at( trail_buffer, _buffOff, buffer_f64, _dx);
			buffer_write(    trail_buffer,           buffer_f64, _dy);
			buffer_write(    trail_buffer,           buffer_f64, _dz);
			buffer_write(    trail_buffer,           buffer_u32, _cc);
		}
		
		if(!is(inline_context, Node_pSystem_3D_Inline) || inline_context.prerendering) return;
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off      = 0;
		
		segment_count = 0;
		segments      = array_verify(segments,     _poolSize);
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act && _lif == 0) continue;
			
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = clamp(_lif / (_lifMax - 1), 0, 1);
			var _fram_mod = _fram_curved? curve_fram.get(rat) : 1;
			var _fram_cur = round(random_range(_fram[0], _fram[1]) * _fram_mod * _mask);
			    
			var _buffOffStart = _bufDatLen * _spwnId;
			
			var _trailLife = min(_fram_cur, _lif);
			var _posIndx   = _lif;
			
			if(!_act) {
				_trailLife = min(_trailLife, _lifMax - (_lif - _trailLife) - 1);
				_posIndx   = _lifMax - 1;
			}
			
			if(_trailLife <= 1) continue;
			
			var ox, oy, nx, ny;
			var _segIndex = 0; 
			var _segs     = array_verify(segments[segment_count], _trailLife * 4);
			var _tr       = 0;
			
			repeat(_trailLife) {
				var _buffInd = _posIndx % _lenMax;
				var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
				
				_segs[_tr++] = buffer_read_at( trail_buffer, _buffOff, buffer_f64 );
				_segs[_tr++] = buffer_read(    trail_buffer,           buffer_f64 );
				_segs[_tr++] = buffer_read(    trail_buffer,           buffer_f64 );
				_segs[_tr++] = buffer_read(    trail_buffer,           buffer_u32 );
				
				_segIndex++;
				_posIndx--;
			}
			
			segments[segment_count] = _segs;
			segment_count++;
		}
		
		setLength();
	}
	
	static cleanUp = function() {
		buffer_delete_safe(trail_buffer);
	}
	
}