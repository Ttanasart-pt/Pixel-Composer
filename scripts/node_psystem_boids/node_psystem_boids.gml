function Node_pSystem_Boids(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Boids";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_boids;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Separation
	newInput( 3, nodeValue_Bool(   "Separate",  true ));
	newInput( 4, nodeValue_Float(  "Radius",    4    )).setInternalName("sep_radius");
	newInput( 5, nodeValue_Slider( "Influence", 0.2  )).setInternalName("sep_influence");
	
	////- =Alignment
	newInput( 6, nodeValue_Bool(   "Align",     true ));
	newInput( 7, nodeValue_Float(  "Radius",    32   )).setInternalName("ali_radius");
	newInput( 8, nodeValue_Slider( "Influence", 0.2  )).setInternalName("ali_influence");
	
	////- =Grouping
	newInput( 9, nodeValue_Bool(   "Group",     true ));
	newInput(10, nodeValue_Float(  "Radius",    32   )).setInternalName("grp_radius");
	newInput(11, nodeValue_Slider( "Influence", 0.2  )).setInternalName("grp_influence");
	
	////- =Follow
	newInput(12, nodeValue_Bool(   "Follow point", false ));
	newInput(13, nodeValue_Vec2(   "Point",        [0,0] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput(14, nodeValue_Slider( "Influence",    .1    )).setInternalName("fol_influence");
	
	// 15
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles",  false     ],  0,  1, 
		[ "Separation", false,  3 ],  4,  5, 
		[ "Alignment",  false,  6 ],  7,  8, 
		[ "Grouping",   false,  9 ], 10, 11, 
		[ "Follow",     false, 12 ], 13, 14, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData( 0);
		var _fol   = getInputData(12);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
		
		if(_fol) {
			InputDrawOverlay(inputs[13].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
		}
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		
		var _use_sep = getInputData( 3);
		var _sep_rad = getInputData( 4), _sep_rad2 = _sep_rad * _sep_rad;
		var _sep_amo = getInputData( 5);
		
		var _use_ali = getInputData( 6);
		var _ali_rad = getInputData( 7), _ali_rad2 = _ali_rad * _ali_rad;
		var _ali_amo = getInputData( 8);
		
		var _use_grp = getInputData( 9);
		var _grp_rad = getInputData(10), _grp_rad2 = _grp_rad * _grp_rad;
		var _grp_amo = getInputData(11);
		var _spd_amp = 1;
		
		var _fol_pnt = getInputData(12);
		var _pnt_tar = getInputData(13);
		var _fol_inf = getInputData(14);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var p0x, p0y, p0vx, p0vy;
		var p1x, p1y, p1vx, p1vy;
		var avx, avy, avc;
		var ax, ay, ac;
		
		var tarx = _pnt_tar[0];
		var tary = _pnt_tar[1];
		
		var max_rad2 = max(_sep_rad2, _ali_rad2, _grp_rad2);
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			p0x  = _px;
			p0y  = _py;
			p0vx = _vx;
			p0vy = _vy;
			
			avx = 0;
			avy = 0;
			avc = 0;
			
			ax  = 0;
			ay  = 0;
			ac  = 0;
			
			var dis   = sqrt(p0vx * p0vx + p0vy * p0vy) * _spd_amp;
			var _off2 = 0;
			
			repeat(_partAmo) {
				var _start2 = _off2;
				_off2 += global.pSystem_data_length;
				if(_start == _start2) continue;
				
				var _act = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.active, buffer_bool );
				if(!_act) continue;
				
				p1x  = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.posx,   buffer_f64  );
				p1y  = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.posy,   buffer_f64  );
				
				p1vx = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.velx,   buffer_f64  );
				p1vy = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.vely,   buffer_f64  );
				
				var _dx = p0x - p1x;
				var _dy = p0y - p1y;
				
				var _dist = _dx * _dx + _dy * _dy;
				if(_dist >= max_rad2) continue;
				
				if(_use_sep && _dist < _sep_rad2) {
					p0x += (p0x - p1x) * _sep_amo * _mask;
					p0y += (p0y - p1y) * _sep_amo * _mask;
				}
				
				if(_use_ali && _dist < _ali_rad2) {
					avx += p1vx;
					avy += p1vy;
					avc++;
				}
				
				if(_use_grp && _dist < _grp_rad2) {
					ax += p1x;
					ay += p1y;
					ac++;
				}
			}
			
			if(_use_ali && avc) {
				avx /= avc;
				avy /= avc;
				
				p0vx += (avx - p0vx) * _ali_amo * _mask;
				p0vy += (avy - p0vy) * _ali_amo * _mask;
			}
			
			if(_use_grp && ac) {
				ax /= ac;
				ay /= ac;
				
				p0x += (ax - p0x) * _grp_amo * _mask;
				p0y += (ay - p0y) * _grp_amo * _mask;
			}
			
			if(_fol_pnt) {
				p0x += (tarx - p0x) * _fol_inf * _mask;
				p0y += (tary - p0y) * _fol_inf * _mask;
			}
			
			var dir   = point_direction(_px, _py, p0x, p0y);
			var _disn = point_distance( _px, _py, p0x, p0y);
			
			var _vx = lengthdir_x(min(dis, _disn), dir);
			var _vy = lengthdir_y(min(dis, _disn), dir);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.velx, buffer_f64, _vx );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.vely, buffer_f64, _vy );
		}
		
	}
	
	static reset = function() {
		
	}
}