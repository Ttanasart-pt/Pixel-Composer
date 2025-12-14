function Node_pSystem_Collision(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Collide";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_collision);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Collider
	newInput( 3, nodeValue_Enum_Scroll( "Shape",       0, [ "Ground", "Rectangle", "Ellipse" ] )); 
	newInput( 4, nodeValue_Vec2(        "Position",  [.5,.5] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 5, nodeValue_Vec2(        "Size",      [.5,.5] )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 6, nodeValue_Rotation(    "Rotation",    0     )).setUnitRef(function() /*=>*/ {return getDimension()}, VALUE_UNIT.reference);
	newInput( 7, nodeValue_Slider(      "Chance",      1     )); 
	
	////- =Physics
	newInput( 8, nodeValue_Slider( "Bounciness", .5  )); 
	newInput( 9, nodeValue_Slider( "Friction",   .5  )); 
	newInput(10, nodeValue_Slider( "Threshold",  .05 )); 
	// 11
	
	newOutput(0, nodeValue_Output("Particles",      VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output("On Collide",     VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(2, nodeValue_Output("Collision Mask", VALUE_TYPE.buffer,   false )).setVisible(false);
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Collider",  false ], 3, 4, 5, 6, 7, 
		[ "Physics",   false ], 8, 10, 
	];
	
	////- Nodes
	
	mask_buffer = undefined;
	collideTrig = undefined; collideCount = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		var _shap = getInputData( 3);
		var _posi = getInputData( 4);
		var _size = getInputData( 5);
		var _rota = getInputData( 6);
		
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
		
		var _px = _x + _posi[0] * _s;
		var _py = _y + _posi[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		
		switch(_shap) {
			case 0 : // ground
				draw_line_angle(_px, _py, _rota);
				draw_arrow(_px, _py, _px + lengthdir_x(64, _rota + 90), _py + lengthdir_y(64, _rota + 90), 16);
				
				InputDrawOverlay(inputs[4].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[6].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny));
				break;
				
			case 1 : // rectangle
				draw_rectangle(_px - _size[0] * _s, _py - _size[1] * _s, _px + _size[0] * _s, _py + _size[1] * _s, true);
				
				InputDrawOverlay(inputs[4].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[5].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny));
				break;
				
			case 2 : // ellipse
				draw_set_circle_precision(32);
				draw_ellipse(_px - _size[0] * _s, _py - _size[1] * _s, _px + _size[0] * _s, _py + _size[1] * _s, true);
				
				InputDrawOverlay(inputs[4].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[5].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny));
				break;
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
		
		var _shap = getInputData( 3);
		var _posi = getInputData( 4);
		var _size = getInputData( 5);
		var _rota = getInputData( 6);
		var _chan = getInputData( 7);
		
		var _boun = getInputData( 8);
		var _fric = getInputData( 9);
		var _thrs = getInputData(10);
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var _pools = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		buffer_to_start(mask_buffer);
		
		outputs[2].setValue(mask_buffer);
		
		switch(_shap) {
			case 0 : // ground
				inputs[5].setVisible( false );
				inputs[6].setVisible(  true );
				
				var _gx0 = _posi[0] - lengthdir_x(999, _rota);
				var _gy0 = _posi[1] - lengthdir_y(999, _rota);
				var _gx1 = _posi[0] + lengthdir_x(999, _rota);
				var _gy1 = _posi[1] + lengthdir_y(999, _rota);
				break;
			
			case 1 : // rectangle
			case 2 : // ellipse
				inputs[5].setVisible(  true );
				inputs[6].setVisible( false );
				
				var _sh_x0 = _posi[0] - _size[0];
				var _sh_y0 = _posi[1] - _size[1];
				var _sh_x1 = _posi[0] + _size[0];
				var _sh_y1 = _posi[1] + _size[1];
				break;
		}
		
		collideTrig  = buffer_verify(collideTrig, 4 + _poolSize * global.pSystem_trig_length);
		var collideCount = 0;
		buffer_seek(collideTrig, buffer_seek_start, 4);
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _sx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64  );
			var _sy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			var _groundDist   = 1;
			var _groundNormal = 0;
			
			switch(_shap) {
				case 0 : // ground
					_groundDist   = distance_to_line_infinite_signed(_px, _py, _gx0, _gy0, _gx1, _gy1);
					_groundNormal = _rota + 90;
					break;
					
				case 1 : // rectangle
					var _maxD = -infinity;
					var _minD =  infinity;
				
					var _d0 = distance_to_line_signed(_px, _py, _sh_x0, _sh_y0, _sh_x1, _sh_y0);
					_maxD   = max(_maxD, _d0);
					_minD   = min(_minD, abs(_d0));
					
					var _d1 = distance_to_line_signed(_px, _py, _sh_x1, _sh_y0, _sh_x1, _sh_y1);
					_maxD   = max(_maxD, _d1);
					_minD   = min(_minD, abs(_d1));
					
					var _d2 = distance_to_line_signed(_px, _py, _sh_x1, _sh_y1, _sh_x0, _sh_y1);
					_maxD   = max(_maxD, _d2);
					_minD   = min(_minD, abs(_d2));
					
					var _d3 = distance_to_line_signed(_px, _py, _sh_x0, _sh_y1, _sh_x0, _sh_y0);
					_maxD   = max(_maxD, _d3);
					_minD   = min(_minD, abs(_d3));
					
					_groundDist = _maxD;
					
					if(abs(_d0) == _minD) _groundNormal = 90;
					if(abs(_d1) == _minD) _groundNormal = 0;
					if(abs(_d2) == _minD) _groundNormal = 270;
					if(abs(_d3) == _minD) _groundNormal = 180;
					break;
					
				case 2 : // ellipse
					var dx = _px - _posi[0];
					var dy = _py - _posi[1];
					
					var aa = point_direction(0, 0, dx / _size[0], dy / _size[1]);
					var ex = dcos(aa) * _size[0];
					var ey = dsin(aa) * _size[1];
					
					var dist  = point_distance(0, 0, ex, ey);
					var pdist = point_distance(0, 0, dx, dy);
					
					_groundDist   = pdist - dist;
					_groundNormal = aa;
					break;
			}
			
			if(_groundDist > 0 || random(1) > _chan) {
				buffer_write(mask_buffer, buffer_f32, 0);
				continue;
			}
			
			var _diss = point_distance(  0, 0, _vx, -_vy );
			var _dirr = point_direction( 0, 0, _vx, -_vy );
			var _refl = _groundNormal - angle_difference(_groundNormal, _dirr);
			
			var _cx = _px + lengthdir_x(-_groundDist, _groundNormal);
			var _cy = _py + lengthdir_y(-_groundDist, _groundNormal);
			
			if(_diss < _thrs) {
				_vx = 0;
				_vy = 0;
				
			} else {
				_vx = lengthdir_x(_diss, _refl) * _boun;
				_vy = lengthdir_y(_diss, _refl) * _boun;
				
				buffer_write(collideTrig, buffer_f64, _cx);
				buffer_write(collideTrig, buffer_f64, _cy);
				buffer_write(collideTrig, buffer_f64,   0);
				
				buffer_write(collideTrig, buffer_f64, _vx);
				buffer_write(collideTrig, buffer_f64, _vy);
				buffer_write(collideTrig, buffer_f64,   0);
				collideCount++;
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _cx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _cy );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velx, buffer_f64, _vx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.vely, buffer_f64, _vy );
			
			buffer_write(mask_buffer, buffer_f32, 1);
		}
		
		buffer_write_at(collideTrig, 0, buffer_u32, collideCount);
		outputs[1].setValue(collideTrig);
	}
	
	static reset = function() {
		
	}
}