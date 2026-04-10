function Node_pSystem_Render_Line(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render Line";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Line
	newInput(5, nodeValue_EScroll(  "Type", 0, [ "Index Order", "Index Fixed" ] ));
	newInput(3, nodeValue_Range( "Length", [4,4], true )); 
	
	////- =Render
	newInput(4, nodeValue_Range( "Thickness", [1,1], true )).setTooltip("This value then multiply by particle X scale for the final thickness.");
	// 6
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Line",      false ], 5, 3, 
		[ "Render",    false ], 4, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _dim   = getDimension();
			var _seed  = getInputData(2);
			
			var _parts = getInputData(0);
			var _masks = getInputData(1), use_mask = _masks != noone;
		
			var _type  = getInputData(5);
			var _leng  = getInputData(3);
			
			var _thck  = getInputData(4);
		#endregion
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _partAmo  = _parts.maxCursor;
			var _partBuff = _parts.buffer;
			var _off = 0;
			
			var ox, oy, nx, ny;
			var _lineLen = 0;
			var _lineAmo = irandom_range(_leng[0], _leng[1]);
			var _lineWid = irandom_range(_thck[0], _thck[1]);
			
			repeat(_partAmo) {
				var _start = _off;
				_off += global.pSystem_data_length;
				
				var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
				var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
				var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
				var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
				
				if(!_act) continue;
				
				var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
				var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
				
				var _px = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64  );
				var _py = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64  );
				
				var _cr = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsr, buffer_u8  );
				var _cg = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsg, buffer_u8  );
				var _cb = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsb, buffer_u8  );
				var _ca = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsa, buffer_u8  );
				var _cc = make_color_rgba(_cr, _cg, _cb, _ca);
				
				random_set_seed(_seed + _spwnId);
				var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
				    rat = clamp(rat, 0, 1);
				
				// var _thck_base = random_range(_thck[0], _thck[1]);
				nx = _px;
				ny = _py;
				
				if(_lineLen) {
					draw_set_color(_cc);
					draw_line_round(ox, oy, nx, ny, _lineWid);
				}
				
				     if(_type == 0) _lineLen++;
				else if(_type == 1) _lineLen = _spwnId % _lineAmo;
				
				if(_lineLen > _lineAmo) {
					_lineLen = 0;
					_lineAmo = irandom_range(_leng[0], _leng[1]);
					_lineWid = irandom_range(_thck[0], _thck[1]);
				}
				
				ox = nx;
				oy = ny;
			}
			
			draw_set_alpha(1);
		surface_reset_target();
	}
}