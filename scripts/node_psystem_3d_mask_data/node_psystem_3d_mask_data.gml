function Node_pSystem_3D_Mask_Data(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Mask Data";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_3d_mask_data;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Data
	data_type_keys = [ 
		"Position X", "Position Y", "Position Z", "Rotation X (degree)", "Rotation Y (degree)", "Rotation Z (degree)", 
		"Scale X", "Scale Y", "Scale Z", "Velocity X", "Velocity Y", "Velocity Z", "Speed", -1, 
		"Life (frame)", "Max life (frame)", "Life Progress (ratio)", -1, 
		"Blending Red (0-255)", "Blending Green (0-255)", "Blending Blue (0-255)", "Blending Alpha (0-255)", "Blending Brightness (0-1)", -1, 
	];
	
	newInput( 3, nodeValue_Enum_Scroll( "Data", 0, data_type_keys)); 
	
	////- =Remap
	newInput( 4, nodeValue_Range( "Remap From",     [0,1]        )); 
	newInput( 5, nodeValue_Range( "Remap To",       [0,1]        )); 
	
	////- =Clamp
	newInput( 9, nodeValue_Bool(  "Use Clamp",  false )); 
	newInput(10, nodeValue_Range( "Clamp",      [0,1] )); 
	
	////- =Curve
	newInput( 8, nodeValue_Bool(  "Use Curve",      false        )); 
	newInput( 6, nodeValue_Curve( "Modifier Curve", CURVE_DEF_01 )); 
	newInput( 7, nodeValue_Range( "Curve X Range",  [0,1]        )); 
	// 11
	
	newOutput(0, nodeValue_Output( "Particles", VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output( "Mask",      VALUE_TYPE.buffer,   noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 
		[ "Data",      false ], 3, 
		[ "Remap",     false ], 4, 5,
		[ "Clamp", false, 9  ], 10, 
		[ "Curve", false, 8  ], 6, 7,
	];
	
	////- Nodes
	
	mask_buffer  = undefined;
	curve_modi   = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static reset = function() {
		curve_modi = new curveMap(getInputData(6));
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[ 0];
		var _masks = _data[ 1];
		
		var _seed = _data[ 2];
		var _type = _data[ 3];
		
		var _mapf = _data[ 4];
		var _mapt = _data[ 5];
		
		var _cuse = _data[ 8] && curve_modi != undefined;
		var _crng = _data[ 7];
		
		var _clam = _data[ 9];
		var _clmr = _data[10];
		
		if(!is(_parts, pSystem_Particles)) return;
		
		var _pools = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		buffer_to_start(mask_buffer);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _pz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _ppx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64  );
			var _ppy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64  );
			var _ppz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospz,  buffer_f64  );
			
			var _sy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			var _sy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			var _sz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scaz,   buffer_f64  );
			
			var _rx  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotx,    buffer_f64  );
			var _ry  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.roty,    buffer_f64  );
			var _rz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotz,    buffer_f64  );
			
			var _vx  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var _life  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,  buffer_f64  );
			var _mlife = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife, buffer_f64  );
			
			var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
			var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
			var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
			var _bldA   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8  );
				
			var _val = 0;
			
			_vx += _px - _ppx;
			_vy += _py - _ppy;
			
			switch(_type) {
				case  0 : _val = _px;  break; // "Position X",
				case  1 : _val = _py;  break; // "Position Y",
				case  2 : _val = _pz;  break; // "Position Z",
				
				case  3 : _val = _rx;  break; // "Rotation X (degree)",
				case  4 : _val = _ry;  break; // "Rotation Y (degree)",
				case  5 : _val = _rz;  break; // "Rotation Z (degree)",
				
				case  6 : _val = _sy;  break; // "Scale X",
				case  7 : _val = _sy;  break; // "Scale Y",
				case  8 : _val = _sz;  break; // "Scale Z",
				
				case  9 : _val = _vx;  break; // "Velocity X",
				case 10 : _val = _vy;  break; // "Velocity Y",
				case 11 : _val = _vz;  break; // "Velocity Z",
				case 12 : _val = point_distance_3d(0, 0, 0, _vx, _vy, _vz); break; // "Speed",
				case 13 : break; // -1,
				
				case 14 : _val = _life;  break; // "Life (frame)",
				case 15 : _val = _mlife; break; // "Max life (frame)",
				case 16 : _val = _life / (_mlife - 1); break; // "Life Progress (ratio)",
				case 17 : break; // -1,
				
				case 18 : _val = _bldR; break; // "Blending Red (0-255)",
				case 19 : _val = _bldG; break; // "Blending Green (0-255)",
				case 20 : _val = _bldB; break; // "Blending Blue (0-255)",
				case 21 : _val = _bldA; break; // "Blending Alpha (0-255)",
				case 22 : _val = 0.299 * _bldR/255 + 0.587 * _bldG/255 + 0.114 * _bldB/255; break; // "Blending Brightness (0-1)",
				case 23 : break; // -1, 
			}
			
			var _inf = lerp(_mapt[0], _mapt[1], lerp_invert(_val, _mapf[0], _mapf[1]));
			
			if(_cuse) _inf = curve_modi.get(lerp_invert(_inf, _crng[0], _crng[1]));
			if(_clam) _inf = clamp(_inf, _clmr[0], _clmr[1]);
			
			buffer_write(mask_buffer, buffer_f32, _inf);
		}
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(mask_buffer);
	}
	
}