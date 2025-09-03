function Node_pSystem_3D_Trail_Mesh(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Trail Mesh";
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
	
	newOutput(0, nodeValue_Output( "Path", VALUE_TYPE.d3Mesh, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Trail",     false ], 3, 4, 
	];
	
	////- Nodes
	
	segment_count = 0;
	object   = new __3dObject();
	segments = [];
	vertices = [];
	edges    = [];
	
	curve_fram       = undefined;
	trail_buffer     = undefined;
	buffer_data_size = 8*3 + 4; // px, py, pz, cr, cg, cb
	
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
		segments = array_verify(segments, _poolSize);
		vertices = array_verify(vertices, _poolSize);
		edges    = array_verify(edges,    _poolSize);
		
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
			
			var ox, oy, oz, oc;
			var nx, ny, nz, nc;
			var _segI = 0; 
			var _segs = array_verify(segments[segment_count], _trailLife * 4),       _sggI = 0;
			var _vers = array_verify(vertices[segment_count], (_trailLife - 1) * 6), _verI = 0;
			var _edgs = array_verify(edges[segment_count],    (_trailLife - 1) * 2), _edgI = 0;
			
			repeat(_trailLife) {
				var _buffInd = _posIndx % _lenMax;
				var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
				
				nx = buffer_read_at( trail_buffer, _buffOff, buffer_f64 );
				ny = buffer_read(    trail_buffer,           buffer_f64 );
				nz = buffer_read(    trail_buffer,           buffer_f64 );
				nc = buffer_read(    trail_buffer,           buffer_u32 );
				
				if(_segI) {
					var dx = nx - ox;
					var dy = ny - oy;
					var dz = nz - oz;
					
					var x0 = ox - .1;
					var y0 = oy;
					var z0 = oz;
					
					var x1 = ox + .1;
					var y1 = oy;
					var z1 = oz;
					
					var x2 = nx - .1;
					var y2 = ny;
					var z2 = nz;
					
					var x3 = nx + .1;
					var y3 = ny;
					var z3 = nz;
					
					_vers[_verI++] = new __vertex(x0, y0, z0);
					_vers[_verI++] = new __vertex(x1, y1, z1);
					_vers[_verI++] = new __vertex(x2, y2, z2);
					_vers[_verI++] = new __vertex(x1, y1, z1);
					_vers[_verI++] = new __vertex(x3, y3, z3);
					_vers[_verI++] = new __vertex(x2, y2, z2);
					
					_edgs[_edgI++] = new __3dObject_Edge( [x0, y0, z0], [x2, y2, z2] );
					_edgs[_edgI++] = new __3dObject_Edge( [x1, y1, z1], [x3, y3, z3] );
				}
				
				_segs[_sggI++] = nx;
				_segs[_sggI++] = ny;
				_segs[_sggI++] = nz;
				_segs[_sggI++] = nc;
				
				ox = nx;
				oy = ny;
				oz = nz;
				
				_segI++;
				_posIndx--;
			}
			
			segments[segment_count] = _segs;
			vertices[segment_count] = _vers;
			edges[segment_count]    = _edgs;
			segment_count++;
		}
		
		array_resize(vertices, segment_count);
		array_resize(edges,    segment_count);
		
		object.object_counts = segment_count;
		object.vertex = vertices;
		object.edges  = edges;
		object.VF     = global.VF_POS_NORM_TEX_COL;
		object.VB     = object.build();
		
		outputs[0].setValue(object);
	}
	
	static getObject = function(index, class = object_class) {
		var _obj = array_safe_get_fast(cached_object, index, noone);
		
		if(_obj == noone) {
			_obj = new class();
		} else if(!is_instanceof(_obj, class)) {
			_obj.destroy();
			_obj = new class();
		}
		
		cached_object[index] = _obj;
		return _obj;
	}
	
	static getPreviewObjects		= function() { return [ getPreviewObject() ]; }
	static getPreviewObjectOutline  = function() { return [ getPreviewObject() ]; }
	
	static cleanUp = function() {
		buffer_delete_safe(trail_buffer);
	}
	
}