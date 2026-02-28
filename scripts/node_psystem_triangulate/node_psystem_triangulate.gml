function Node_pSystem_Triangulate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Triangulate";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Render
	newInput(3, nodeValue_Range( "Thickness", [1,1], true )).setTooltip("This value then multiply by particle X scale for final thickness.");
	// 
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Render",    false ], 3, 
	];
	
	////- Nodes
	
	position_buffer = undefined;
	triangle_buffer = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static reset = function() {
		
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		
		var _dim   = getDimension();
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		
		var _thck = getInputData(3);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		position_buffer = buffer_verify(position_buffer, 8 * 2 * _partAmo, buffer_fixed);
		triangle_buffer = buffer_verify(triangle_buffer, 8 * 6 * _partAmo, buffer_fixed);
		
		buffer_to_start(position_buffer);
		
		var _i = 0, _id = 0;
		var _indexMap = array_create(_partAmo, 0);
		
		repeat(_partAmo) {
			_i++;
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			if(!_act) continue;
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			
			var _draw_x = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
			var _draw_y = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
			
			_indexMap[_id++] = _i - 1;
			buffer_write(position_buffer, buffer_f64, _draw_x);
			buffer_write(position_buffer, buffer_f64, _draw_y);
		}
		
		var _triangleAmount = delaunay_triangulation_ext_c(buffer_get_address(position_buffer), _id, buffer_get_address(triangle_buffer));
		buffer_to_start(triangle_buffer);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			random_set_seed(_seed);
			
			repeat(_triangleAmount) {
				var p1 = _indexMap[buffer_read(triangle_buffer, buffer_s32)];
				var p2 = _indexMap[buffer_read(triangle_buffer, buffer_s32)];
				var p3 = _indexMap[buffer_read(triangle_buffer, buffer_s32)];
				
				var _st1 = global.pSystem_data_length * p1;
				var _st2 = global.pSystem_data_length * p2;
				var _st3 = global.pSystem_data_length * p3;
				
				var _dfg     = buffer_read_at( _partBuff, _st1 + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _draw_x1 = buffer_read_at( _partBuff, _st1 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
				var _draw_y1 = buffer_read_at( _partBuff, _st1 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
				var _draw_s1 = buffer_read_at( _partBuff, _st1 + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax),   buffer_f64  );
				
				var _bldR1   = buffer_read_at( _partBuff, _st1 + PSYSTEM_OFF.blnr, buffer_u8 );
				var _bldG1   = buffer_read_at( _partBuff, _st1 + PSYSTEM_OFF.blng, buffer_u8 );
				var _bldB1   = buffer_read_at( _partBuff, _st1 + PSYSTEM_OFF.blnb, buffer_u8 );
				var _bldA1   = buffer_read_at( _partBuff, _st1 + PSYSTEM_OFF.blna, buffer_u8 );
				var _cc1     = make_color_rgb(_bldR1, _bldG1, _bldB1);
				
				var _dfg     = buffer_read_at( _partBuff, _st2 + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _draw_x2 = buffer_read_at( _partBuff, _st2 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
				var _draw_y2 = buffer_read_at( _partBuff, _st2 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
				var _draw_s2 = buffer_read_at( _partBuff, _st2 + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax),   buffer_f64  );
				
				var _bldR2   = buffer_read_at( _partBuff, _st2 + PSYSTEM_OFF.blnr, buffer_u8 );
				var _bldG2   = buffer_read_at( _partBuff, _st2 + PSYSTEM_OFF.blng, buffer_u8 );
				var _bldB2   = buffer_read_at( _partBuff, _st2 + PSYSTEM_OFF.blnb, buffer_u8 );
				var _bldA2   = buffer_read_at( _partBuff, _st2 + PSYSTEM_OFF.blna, buffer_u8 );
				var _cc2     = make_color_rgb(_bldR2, _bldG2, _bldB2);
				
				var _dfg     = buffer_read_at( _partBuff, _st3 + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _draw_x3 = buffer_read_at( _partBuff, _st3 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
				var _draw_y3 = buffer_read_at( _partBuff, _st3 + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
				var _draw_s3 = buffer_read_at( _partBuff, _st3 + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax),   buffer_f64  );
				
				var _bldR3   = buffer_read_at( _partBuff, _st3 + PSYSTEM_OFF.blnr, buffer_u8 );
				var _bldG3   = buffer_read_at( _partBuff, _st3 + PSYSTEM_OFF.blng, buffer_u8 );
				var _bldB3   = buffer_read_at( _partBuff, _st3 + PSYSTEM_OFF.blnb, buffer_u8 );
				var _bldA3   = buffer_read_at( _partBuff, _st3 + PSYSTEM_OFF.blna, buffer_u8 );
				var _cc3     = make_color_rgb(_bldR3, _bldG3, _bldB3);
				
				var _thck_base = random_range(_thck[0], _thck[1]);
				
				draw_line_width2(_draw_x1, _draw_y1, _draw_x2, _draw_y2, _draw_s1 * _thck_base, _draw_s2 * _thck_base, true, _cc1, _cc2);
				draw_line_width2(_draw_x1, _draw_y1, _draw_x3, _draw_y3, _draw_s1 * _thck_base, _draw_s3 * _thck_base, true, _cc1, _cc3);
				draw_line_width2(_draw_x3, _draw_y3, _draw_x2, _draw_y2, _draw_s3 * _thck_base, _draw_s2 * _thck_base, true, _cc3, _cc2);
			}
			
			draw_set_alpha(1);
		surface_reset_target();
	}
	
	static cleanUp = function() {
		buffer_delete_safe(position_buffer);
		buffer_delete_safe(triangle_buffer);
	}
}