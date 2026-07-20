function Node_Puppet_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Puppet Warp";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Mesh
	newInput( 1, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	// 
	
	newOutput( 0, nodeValue_Output( "Surface Out",   VALUE_TYPE.surface, noone      ));
	newOutput( 1, nodeValue_Output( "Deformed Mesh", VALUE_TYPE.mesh,    new Mesh() ));
	
	input_display_dynamic = [ 
		[ "/Pin",    false ],  0,  1, 
	];
	
	input_display_list = [ 
		[ "Surface", false ],  0, 
		[ "Mesh",    false ],  1, 
		[ "Pin",     false ],  
	];
	
	function createNewInput(i = array_length(inputs)) {
		newInput( i+0, nodeValue_Vec2("Pin Position", [0,0] )).setUnitSimple();
		newInput( i+1, nodeValue_Vec2("Pin Offset",   [0,0] )).setUnitSimple();
		
		refreshDynamicDisplay();
		return inputs[i];
	} setDynamicInput(2, false);
	
	////- Tools
	
	tool_edit = new NodeTool( "Edit Pin", THEME.control_add  );
	tools = [ tool_edit ];
	
	pin_moving = undefined;
	
	pin_mov_sx = undefined;
	pin_mov_sy = undefined;
	pin_mov_ox = undefined;
	pin_mov_oy = undefined;
	
	pin_mov_mx = undefined;
	pin_mov_my = undefined;
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _mesh = PANEL_PREVIEW.tool_current == tool_edit? getInputSingle(1) : getInputSingle(1, preview_index, true);
		
		if(is(_mesh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_mesh.draw(_x, _y, _s);
		}
		
		var pinAmo = getInputAmount();
		var pinHov = undefined;
		
		for( var i = 0; i < pinAmo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			var _pos = getInputSingle(_ind + 0);
			var _off = getInputSingle(_ind + 1);
			
			var _px = _x + _pos[0] * _s;
			var _py = _y + _pos[1] * _s;
			
			var _nx = _px + _off[0] * _s;
			var _ny = _py + _off[1] * _s;
			
			var  hv = false;
			
			if(PANEL_PREVIEW.tool_current == tool_edit) {
				if(hover && point_in_circle(_mx, _my, _px, _py, ui(8))) {
					pinHov = i;
					hv = true;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _nx, _ny);
				draw_circle(_nx, _ny, ui(6), true);
				
				draw_anchor(hv, _px, _py, ui(10));
				
			} else {
				if(hover && point_in_circle(_mx, _my, _nx, _ny, ui(8))) {
					pinHov = i;
					hv = true;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _nx, _ny);
				draw_circle(_px, _py, ui(6), true);
				
				draw_anchor(hv, _nx, _ny, ui(10));
				
			}
			
		}
		
		if(pinHov != undefined) w_hovering = true;
		
		switch(PANEL_PREVIEW.tool_current) {
			case tool_edit :
				w_hovering = true;
				if(pinHov == undefined) {
					CURSOR_SPRITE = THEME.cursor_add;
					
					if(mouse_lpress(active)) {
						pin_moving = array_length(inputs);
						var _pin = createNewInput();
						var _px  = (_mx - _x) / _s;
						var _py  = (_my - _y) / _s;
						_pin.setValue([_px, _py]);
						
						pin_mov_sx = _px;
						pin_mov_sy = _py;
						pin_mov_ox = 0;
						pin_mov_oy = 0;
	
						pin_mov_mx = _mx;
						pin_mov_my = _my;
					}
					
				} else {
					CURSOR_SPRITE = THEME.cursor_remove;
					
					if(mouse_lpress(active)) {
						var _ind = input_fix_len + pinHov * data_length;
						array_delete(inputs, _ind, data_length);
						refreshDynamicDisplay();
					}
				}
				break;
				
			default :
				if(pinHov != undefined) {
					if(mouse_lpress(active)) {
						var _ind = input_fix_len + pinHov * data_length;
						var _pos = getInputSingle(_ind + 0);
						var _off = getInputSingle(_ind + 1);
						
						pin_moving = _ind;
						
						pin_mov_sx = _px;
						pin_mov_sy = _py;
						pin_mov_ox = _off[0];
						pin_mov_oy = _off[1];
	
						pin_mov_mx = _mx;
						pin_mov_my = _my;
					}
				}
				break;
		}
		
		if(pin_moving != undefined) {
			var _ind = input_fix_len + pin_moving * data_length;
			
			var ox = pin_mov_ox + (_mx - pin_mov_mx) / _s;
			var oy = pin_mov_oy + (_my - pin_mov_my) / _s;
			
			var nx = ox + pin_mov_sx;
			var ny = oy + pin_mov_sy;
			
			if(inputs[pin_moving + 1].setValue([ox, oy])) 
				UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				pin_moving = undefined;
				triggerRender();
				UNDO_HOLDING = false;
			}
		}
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _mesh = _data[ 1];
			
			if(!is_surface(_surf)) return _outData;
			if(!is(_mesh, Mesh))   return _outData;
		#endregion
		
		var pinAmo = getInputAmount();
		var pins   = array_create(pinAmo);
		
		for( var i = 0; i < pinAmo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			var _pos = _data[_ind + 0];
			var _off = _data[_ind + 1];
			
			pins[i] = [
				new __vec2( _pos[0], _pos[1]),
				new __vec2( _pos[0] + _off[0], _pos[1] + _off[1]),
			];
		}
		
		var _outMesh = _mesh.clone();
		_outData[1]  = _outMesh;
		
		var _tris = _outMesh.triangles;
		var _pnts = _outMesh.points;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = _outData[0];
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _tex = surface_get_texture(_surf);
			draw_set_color_alpha(c_white, 1);
			draw_primitive_begin_texture(pr_trianglelist, _tex);
			
			for( var i = 0, n = array_length(_tris); i < n; i++ ) {
				var _t = _tris[i];
				var p0 = _pnts[_t[0]];
				var p1 = _pnts[_t[1]];
				var p2 = _pnts[_t[2]];
				
				draw_vertex_texture(p0.x, p0.y, p0.u, p0.v);
				draw_vertex_texture(p1.x, p1.y, p1.u, p1.v);
				draw_vertex_texture(p2.x, p2.y, p2.u, p2.v);
				
				if(i && i % 64 == 0) {
					draw_primitive_end();
					draw_primitive_begin_texture(pr_trianglelist, _tex);
				}
			}
			
			draw_primitive_end();
			
		surface_reset_target();
		
		return _outData; 
	}
	
}