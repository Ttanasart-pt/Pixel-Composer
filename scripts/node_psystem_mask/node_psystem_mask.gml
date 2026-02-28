function Node_pSystem_Mask(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mask";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_mask);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Mask
	newInput( 3, nodeValue_Enum_Scroll( "Type",   0, [ "Area", "Linear", "Map" ] )); 
	newInput( 4, nodeValue_Area(     "Area",      DEF_AREA_REF )).setUnitSimple();
	newInput( 7, nodeValue_Vec2(     "Center",  [.5,.5]        )).setUnitSimple();
	newInput( 8, nodeValue_Rotation( "Angle",     0            ));
	newInput( 9, nodeValue_Surface(  "Map" ));
	
	////- =Falloff
	newInput( 5, nodeValue_Float( "Falloff Distance", 4 )).setCurvable( 6, CURVE_DEF_11, "Curve"); 
	// 10
	
	newOutput(0, nodeValue_Output( "Particles", VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output( "Mask",      VALUE_TYPE.buffer,   noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 
		[ "Mask",      false ], 3, 4, 7, 8, 9, 
		[ "Falloff",   false ], 5, 6, 
	];
	
	////- Nodes
	
	curve_strn   = undefined;
	mask_buffer  = undefined;
	mask_sampler = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
		
		var _type = getInputData(3);
		var _fall = getInputData(5) * _s;
		
		if(_type == 0) {
			var _area = getInputData(4);
			var cx = _x + _area[0] * _s;
			var cy = _y + _area[1] * _s;
			var cw = _area[2] * _s;
			var ch = _area[3] * _s;
			var cs = _area[4];
			
			var x0 = cx - cw + _fall;
			var x1 = cx + cw - _fall;
			var y0 = cy - ch + _fall;
			var y1 = cy + ch - _fall;
			
			if(x1 > x0 && y1 > y0) {
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(.5);
				switch(cs) {
					case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw - _fall, ch - _fall); break;	
					case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
				}
				draw_set_alpha(1);
			}
			
			x0 = cx - cw - _fall;
			x1 = cx + cw + _fall;
			y0 = cy - ch - _fall;
			y1 = cy + ch + _fall;
			
			if(x1 > x0 && y1 > y0) {
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(.5);
				switch(cs) {
					case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + _fall, ch + _fall); break;	
					case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
				}
				draw_set_alpha(1);
			}
			
			InputDrawOverlay(inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
			
		} else if(_type == 1) {
			var _cent = getInputData(7);
			var _rota = getInputData(8) + 90;
			
			var _cx = _x + _cent[0] * _s;
			var _cy = _y + _cent[1] * _s;
			
			var _dx = lengthdir_x(_fall, _rota + 90);
			var _dy = lengthdir_y(_fall, _rota + 90);
			
			draw_set_color(COLORS._main_accent);
			draw_line_angle(_cx, _cy, _rota);
			draw_line_dashed_angle(_cx + _dx, _cy + _dy, _rota);
			draw_line_dashed_angle(_cx - _dx, _cy - _dy, _rota);
			
			InputDrawOverlay(inputs[7].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my));
			InputDrawOverlay(inputs[8].drawOverlay(hover, active, _cx, _cy, _s, _mx, _my));
		}
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1);
		
		var _seed = getInputData( 2);
		var _type = getInputData( 3);
		
		var _area = getInputData( 4);
		var _cent = getInputData( 7);
		var _rota = getInputData( 8) + 90;
		var _fdis = getInputData( 5), _fall_curved = inputs[5].attributes.curved;
		var _fcrv = getInputData( 6);
		var _mapp = getInputData( 9);
		
		inputs[4].setVisible(_type == 0);
		inputs[7].setVisible(_type == 1);
		inputs[8].setVisible(_type == 1);
		
		inputs[9].setVisible(_type == 2, _type == 2);
		
		if(!is(_parts, pSystem_Particles)) return;
		
		var _pools = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		outputs[0].setValue(_parts);
		outputs[1].setValue(mask_buffer);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		buffer_to_start(mask_buffer);
		
		switch(_type) {
			case 1 : 
				var _line_x0 = _cent[0] - lengthdir_x(1, _rota);
				var _line_y0 = _cent[1] - lengthdir_y(1, _rota);
				var _line_x1 = _cent[0] + lengthdir_x(1, _rota);
				var _line_y1 = _cent[1] + lengthdir_y(1, _rota);
				break;
				
			case 2 : 
				if(!is_surface(_mapp)) return;
				if(mask_sampler != undefined) mask_sampler.free();
				mask_sampler = new Surface_Sampler_Grey(_mapp);
				
				var _mapw = surface_get_width(_mapp);
				var _maph = surface_get_height(_mapp);
				break;
		}
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _inf = 0;
			
			switch(_type) {
				case 0 : _inf = area_point_in_fallout(_area, _px, _py, _fdis); break;
				case 1 : 
					var _dirr = point_direction(_cent[0], _cent[1], _px, _py);
					var _delt = -angle_difference(_rota, _dirr);
					var _dist = distance_to_line_infinite(_px, _py, _line_x0, _line_y0, _line_x1, _line_y1);
					
					_inf = _delt < 0;
					if(_dist < _fdis) _inf = _delt < 0? .5 + _dist / _fdis * .5 : .5 - _dist / _fdis * .5;
					break;
					
				case 2 : _inf = mask_sampler.getPixel(_px / _mapw, _py / _maph); break;
			}
			
			if(_fall_curved)    _inf = eval_curve_x(_fcrv, clamp(_inf, 0., 1.));
			
			buffer_write(mask_buffer, buffer_f32, _inf);
		}
		
	}
	
	static reset = function() {
		
	}
}