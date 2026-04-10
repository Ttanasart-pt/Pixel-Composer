function Node_pSystem_Render_Triangle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render Triangle";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Line
	newInput( 5, nodeValue_EScroll(  "Type", 0, [ "Index Order", "Index Fixed", "Closet" ] ));
	newInput( 3, nodeValue_Range(    "Length", [3,3], true )); 
	newInput( 6, nodeValue_Vec2(     "Target", [.5,.5] )).setUnitSimple(); 
	
	////- =Render
	newInput( 4, nodeValue_Range(   "Thickness", [1,1], true )).setTooltip("This value then multiply by particle X scale for the final thickness.");
	
	newInput( 7, nodeValue_EScroll( "Color Type",       0, [ "Solid", "Fixed" ]   )); 
	newInput( 8, nodeValue_Color(   "Target Color",     ca_black                  )); 
	newInput( 9, nodeValue_EScroll( "Thickness Type",   0, [ "Uniform", "Fixed" ] )); 
	newInput(10, nodeValue_Range(   "Target Thickness", [1,1], true               )); 
	// 11
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ],  0,  1, 
		[ "Line",      false ],  5,  3,  6, 
		[ "Render",    false ],  7,  8,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
		
		var _type  = getInputData(5);
		if(_type == 3) InputDrawOverlay(inputs[6].drawOverlay(hover, active, _x, _y, _s, _mx, _my)); 
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _dim   = getDimension();
			var _seed  = getInputData( 2);
			
			var _parts = getInputData( 0);
			var _masks = getInputData( 1), use_mask = _masks != noone;
		
			var _type  = getInputData( 5);
			var _leng  = getInputData( 3);
			var _pont  = getInputData( 6);
			
			var _thck  = getInputData( 4);
			
			var _ctyp  = getInputData( 7);
			var _ctar  = getInputData( 8);
			var _ttyp  = getInputData( 9);
			var _ttar  = getInputData(10);
			
			inputs[ 3].setVisible(_type != 3);
			inputs[ 6].setVisible(_type == 3);
			
			inputs[ 7].setVisible(_type == 3);
			inputs[ 8].setVisible(_type == 3 && _ctyp);
			inputs[ 9].setVisible(_type == 3);
			inputs[10].setVisible(_type == 3 && _ttyp);
		#endregion
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var _points = [];
		
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _partAmo  = _parts.maxCursor;
			var _partBuff = _parts.buffer;
			var _off = 0;
			
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
				
				var _sx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax, buffer_f64  );
				var _sy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay, buffer_f64  );
				
				var _cr = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsr, buffer_u8  );
				var _cg = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsg, buffer_u8  );
				var _cb = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsb, buffer_u8  );
				var _ca = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnsa, buffer_u8  );
				var _cc = make_color_rgba(_cr, _cg, _cb, _ca);
				
				random_set_seed(_seed + _spwnId);
				var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
				    rat = clamp(rat, 0, 1);
				
				array_push(_points, [
					_spwnId,
					rat,
					_px, _py,
					_sx, _sy,
					_cc,
				]);
			}
			
			var ox, oy, nx, ny;
			var ow, nw, oc, nc;
			
			var _lineLen = 0;
			var _lineAmo = irandom_range(_leng[0], _leng[1]);
			var _lineWid = irandom_range(_thck[0], _thck[1]);
			
			if(_type < 2) {
				draw_primitive_begin(pr_trianglelist);
				
				for( var i = 0, n = array_length(_points); i < n; i++ ) {
					var p   =  _points[i];
					var sid = p[0];
					var rat = p[1];
					var px  = p[2], py = p[3];
					var sx  = p[4], sy = p[5];
					var cc  = p[6];
					
					nx = px;
					ny = py;
					nc = cc;
					nw = _lineWid * sx;
					
					draw_vertex_color(nx, ny, nc, color_get_a(nc));
					
					     if(_type == 0) _lineLen++;
					else if(_type == 1) _lineLen = sid % _lineAmo;
					
					if(_lineLen > _lineAmo) {
						draw_primitive_end();
						draw_primitive_begin(pr_trianglelist);
						
						_lineLen = 0;
						_lineAmo = irandom_range(_leng[0], _leng[1]);
						_lineWid = irandom_range(_thck[0], _thck[1]);
					}
				}
				
				draw_primitive_end();
				
			} else if(_type == 2) {
				var _len = array_length(_points);
				var _closest   = array_create(_len);
				var _drawnlist = array_create(_len, 0);

				for( var i = 0; i < _len; i++ ) {
					var p1 = _points[i];
					var cx = p1[2], cy = p1[3];
					
					var closestId = -1;
					var closestDist = 0;
					
					for( var j = 0; j < _len; j++ ) {
						if(i == j) continue;
						
						var p2 = _points[j];
						var px = p2[2], py = p2[3];
						
						var dist = point_distance(cx, cy, px, py);
						if(closestId == -1 || dist < closestDist) {
							closestId = j;
							closestDist = dist;
						}
					}
					
					_closest[i] = closestId;
				}
				
				for( var i = 0; i < _len; i++ ) {
					_lineAmo = irandom_range(_leng[0], _leng[1]);
					_lineWid = irandom_range(_thck[0], _thck[1]);
					
					var pp = _points[i];
					
					ox = pp[2];
					oy = pp[3];
					oc = pp[6];
					ow = pp[4] * _lineWid;
					
					draw_primitive_begin(pr_trianglelist);
					draw_vertex_color(ox, oy, oc, color_get_a(oc));
					
					repeat(_lineAmo) {
						var cid = _closest[i];
						if(cid == -1 || _drawnlist[cid]) break;
						
						// _drawnlist[cid] = 1;
						
						var pc = _points[cid];
						nx = pc[2];
						ny = pc[3];
						nc = pc[6];
						nw = pc[4] * _lineWid;
						
						draw_vertex_color(nx, ny, nc, color_get_a(nc));
					}
					
					draw_primitive_end();
				}
				
			} else if(_type == 3) {
				for( var i = 0, n = array_length(_points); i < n; i++ ) {
					var p   =  _points[i];
					var sid = p[0];
					var rat = p[1];
					var px  = p[2], py = p[3];
					var sx  = p[4], sy = p[5];
					var cc  = p[6];
					
					ox = _pont[0];
					oy = _pont[1];
					oc = _ctyp? _ctar : cc;
					ow = _ttyp? irandom_range(_ttar[0], _ttar[1]) : _lineWid * sx;
					
					nx = px;
					ny = py;
					nc = cc;
					nw = _lineWid * sx;
					
					draw_vertex_color(nx, ny, nc, color_get_a(nc));
				}
			}
			
			draw_set_alpha(1);
		surface_reset_target();
	}
}