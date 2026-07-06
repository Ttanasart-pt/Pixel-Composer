#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Warp", "Tile > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 2); });
	});
#endregion

function Node_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Warp";
	
	newActiveInput(5, nodeValue_Bool("Active", true));
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In"   ));
	newInput(10, nodeValue_Surface( "Back Surface" ));
	newInput( 6, nodeValue_EScroll( "Dimension Type", 0, [ "Input", "Absolute", "Relative" ]));
	newInput( 7, nodeValue_Dimension());
	newInput( 9, nodeValue_Vec2( "Relative Dimension", [ 1, 1 ] ));
	
	////- =Area
	newInput(13, nodeValue_Area( "Area", DEF_AREA_REF )).setUnitSimple();
	
	////- =Warp
	newInput( 1, nodeValue_Vec2( "Top Left",     [ 0, 0 ] )).hideLabel().setUnitSimple();
	newInput( 2, nodeValue_Vec2( "Top Right",    [ 1, 0 ] )).hideLabel().setUnitSimple();
	newInput( 3, nodeValue_Vec2( "Bottom Left",  [ 0, 1 ] )).hideLabel().setUnitSimple();
	newInput( 4, nodeValue_Vec2( "Bottom Right", [ 1, 1 ] )).hideLabel().setUnitSimple();
	
	////- =Render
	newInput(12, nodeValue_Vec2(   "UV Position",  [0,0]            ));
	newInput(11, nodeValue_Vec2(   "UV Scale",     [1,1]            ));
	newInput( 8, nodeValue_Toggle( "Tile",          0, [ "X", "Y" ] ));
	newInput(14, nodeValue_Bool(   "Draw Original", false           ));
	// 15
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	b_reset_area = button(function() /*=>*/ {
		var _area = getInputSingle(13);
		
		var x0 = _area[0] - _area[2];
		var y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2];
		var y1 = _area[1] + _area[3];
		
		inputs[ 1].setValue([x0, y0]);
		inputs[ 2].setValue([x1, y0]);
		inputs[ 3].setValue([x0, y1]);
		inputs[ 4].setValue([x1, y1]);
		
	}).setIcon(THEME.refresh_icon, 1, COLORS._main_value_positive).iconPad(ui(6)).setTooltip(__txt("Reset to Area"));
	
	input_display_list = [  5,
		[ "Surfaces", false ],  0, 10,  6,  7,  9, 
		[ "Area",     false ], 13, 
		[ "Warp",     false, noone, b_reset_area ],  1,  2,  3,  4, 
		[ "Render",   false ], 12, 11,  8, 14, 
		
	];
	
	pie_junctions = [ inputs[4], inputs[2], inputs[1], inputs[3] ];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation(false, true);

	attributes.initalset = LOADING || APPENDING;
	
	#region tool
		tool_area = new NodeTool( "Edit Area", THEME.area_tool );
		tools     = [ tool_area ];
	
		drag_side = -1;
		drag_mx   = 0;
		drag_my   = 0;
		drag_s    = [[0, 0], [0, 0]];
	#endregion
	
	temp_surface = array_create(2);
	
	static getDimension = function(arr = 0) {
		var _surfF  = getInputSingle(0);
		if(!is_surface(_surfF)) return PROJ_SURF;
		
		var _dimTyp = getInputSingle(6);
		var _dim    = getInputSingle(7);
		var _sdim   = getInputSingle(9);
			
		var sw = DEF_SURF_W;
		var sh = DEF_SURF_H;
		
		switch(_dimTyp) {
			case 0 : 
				sw = surface_get_width_safe(_surfF);
				sh = surface_get_height_safe(_surfF); 
				break;
				
			case 1 : 
				sw = _dim[0];
				sh = _dim[1]; 
				break;
				
			case 2 : 
				sw = _sdim[0] * surface_get_width_safe(_surfF);
				sh = _sdim[1] * surface_get_height_safe(_surfF); 
				break;
				
		}
		
		return [sw, sh];
	}
	
	static onValueFromUpdate = function(index) { 
		if(index == 0 && attributes.initalset == false) {
			var _surf = getInputData(0);
			if(!is_surface(_surf)) return;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			inputs[1].setValue([   0,   0 ]);
			inputs[2].setValue([ _sw,   0 ]);
			inputs[3].setValue([   0, _sh ]);
			inputs[4].setValue([ _sw, _sh ]);
			
			attributes.initalset = true;
		}
	} if(!LOADING && !APPENDING) run_in(1, function() { onValueFromUpdate(0); }) 
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, params) {
		PROCESSOR_OVERLAY_CHECK
		
		if(isUsingTool(tool_area)) {
			drawOverlayInput(inputs[13].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
			return;
		} else {
			var _area = getInputSingle(13);
			var x0 = _x + (_area[0] - _area[2]) * _s;
			var y0 = _y + (_area[1] - _area[3]) * _s;
			var x1 = _x + (_area[0] + _area[2]) * _s;
			var y1 = _y + (_area[1] + _area[3]) * _s;
			
			draw_set_color(COLORS._main_icon);
			draw_rectangle(x0, y0, x1, y1, true);
		}
		
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _ss = current_data[0];
		if(!is_surface(_ss)) return;
		
		var tlX = _x + current_data[1][0] * _s;
		var trX = _x + current_data[2][0] * _s;
		var blX = _x + current_data[3][0] * _s;
		var brX = _x + current_data[4][0] * _s;
		
		var tlY = _y + current_data[1][1] * _s;
		var trY = _y + current_data[2][1] * _s;
		var blY = _y + current_data[3][1] * _s;
		var brY = _y + current_data[4][1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(.5);
		draw_line_infinite(tlX, tlY, trX, trY);
		draw_line_infinite(tlX, tlY, blX, blY);
		draw_line_infinite(brX, brY, trX, trY);
		draw_line_infinite(brX, brY, blX, blY);
		
		draw_set_alpha(1);
		draw_line(tlX, tlY, trX, trY);
		draw_line(tlX, tlY, blX, blY);
		draw_line(brX, brY, trX, trY);
		draw_line(brX, brY, blX, blY);
		
		var _hactive = active;
		if(point_in_circle(_mx, _my, tlX, tlY, ui(12))) _hactive = false;
		if(point_in_circle(_mx, _my, trX, trY, ui(12))) _hactive = false;
		if(point_in_circle(_mx, _my, blX, blY, ui(12))) _hactive = false;
		if(point_in_circle(_mx, _my, brX, brY, ui(12))) _hactive = false;
		
		var dx = 0;
		var dy = 0;
		
		if(drag_side > -1) {
			w_hovering = true;
			dx = (_mx - drag_mx) / _s;
			dy = (_my - drag_my) / _s;
			
			if(mouse_lrelease()) {
				drag_side = -1;	
				UNDO_HOLDING = false;
			}
		}
		
		#region edit
			draw_set_color(COLORS.node_overlay_gizmo_inactive);
			if(drag_side == 0) {
				draw_line_width_infinite(tlX, tlY, trX, trY, 3);
			
				var _tlx = PANEL_PREVIEW.snapX(drag_s[0][0] + dx);
				var _tly = PANEL_PREVIEW.snapY(drag_s[0][1] + dy);
			
				var _trx = PANEL_PREVIEW.snapX(drag_s[1][0] + dx);
				var _try = PANEL_PREVIEW.snapY(drag_s[1][1] + dy);
			
				var _up1 = inputs[1].setValue([ _tlx, _tly ]);
				var _up2 = inputs[2].setValue([ _trx, _try ]);
			
				if(_up1 || _up2) UNDO_HOLDING = true;
				
			} else if(drag_side == 1) {
				draw_line_width_infinite(tlX, tlY, blX, blY, 3);
			
				var _tlx = PANEL_PREVIEW.snapX(drag_s[0][0] + dx);
				var _tly = PANEL_PREVIEW.snapY(drag_s[0][1] + dy);
								  
				var _blx = PANEL_PREVIEW.snapX(drag_s[1][0] + dx);
				var _bly = PANEL_PREVIEW.snapY(drag_s[1][1] + dy);
			
				var _up1 = inputs[1].setValue([ _tlx, _tly ]);
				var _up3 = inputs[3].setValue([ _blx, _bly ]);
			
				if(_up1 || _up3) UNDO_HOLDING = true;
				
			} else if(drag_side == 2) {
				draw_line_width_infinite(brX, brY, trX, trY, 3);
			
				var _brx = PANEL_PREVIEW.snapX(drag_s[0][0] + dx);
				var _bry = PANEL_PREVIEW.snapY(drag_s[0][1] + dy);
								  
				var _trx = PANEL_PREVIEW.snapX(drag_s[1][0] + dx);
				var _try = PANEL_PREVIEW.snapY(drag_s[1][1] + dy);
			
				var _up4 = inputs[4].setValue([ _brx, _bry ]);
				var _up2 = inputs[2].setValue([ _trx, _try ]);
			
				if(_up4 || _up2) UNDO_HOLDING = true;
				
			} else if(drag_side == 3) {
				draw_line_width_infinite(brX, brY, blX, blY, 3);
			
				var _brx = PANEL_PREVIEW.snapX(drag_s[0][0] + dx);
				var _bry = PANEL_PREVIEW.snapY(drag_s[0][1] + dy);
								  
				var _blx = PANEL_PREVIEW.snapX(drag_s[1][0] + dx);
				var _bly = PANEL_PREVIEW.snapY(drag_s[1][1] + dy);
			
				var _up4 = inputs[4].setValue([ _brx, _bry ]);
				var _up3 = inputs[3].setValue([ _blx, _bly ]);
			
				if(_up4 || _up3) UNDO_HOLDING = true;
				
			} else if(drag_side == 4) {
				draw_line_width(tlX, tlY, trX, trY, 3);
				draw_line_width(tlX, tlY, blX, blY, 3);
				draw_line_width(brX, brY, trX, trY, 3);
				draw_line_width(brX, brY, blX, blY, 3);
				
				var _tlx = PANEL_PREVIEW.snapX(drag_s[0][0] + dx);
				var _tly = PANEL_PREVIEW.snapY(drag_s[0][1] + dy);
			
				var _trx = PANEL_PREVIEW.snapX(drag_s[1][0] + dx);
				var _try = PANEL_PREVIEW.snapY(drag_s[1][1] + dy);
			
				var _blx = PANEL_PREVIEW.snapX(drag_s[2][0] + dx);
				var _bly = PANEL_PREVIEW.snapY(drag_s[2][1] + dy);
			
				var _brx = PANEL_PREVIEW.snapX(drag_s[3][0] + dx);
				var _bry = PANEL_PREVIEW.snapY(drag_s[3][1] + dy);
			  
				var _up1 = inputs[1].setValue([ _tlx, _tly ]);
				var _up2 = inputs[2].setValue([ _trx, _try ]);
				var _up3 = inputs[3].setValue([ _blx, _bly ]);
				var _up4 = inputs[4].setValue([ _brx, _bry ]);
			
				if(_up1 || _up2 || _up4 || _up3) UNDO_HOLDING = true;
				
			} else if(hover) {
				draw_set_color(COLORS._main_accent);
				if(distance_to_line_infinite(_mx, _my, tlX, tlY, trX, trY) < 12) {
					draw_line_width_infinite(tlX, tlY, trX, trY, 3);
					w_hovering = true;
					
					if(mouse_lpress(_hactive)) {
						drag_side = 0;
						drag_mx   = _mx;
						drag_my   = _my;
						drag_s    = [ current_data[1], current_data[2] ];
					}
					
				} else if(distance_to_line_infinite(_mx, _my, tlX, tlY, blX, blY) < 12) {
					draw_line_width_infinite(tlX, tlY, blX, blY, 3);
					w_hovering = true;
					
					if(mouse_lpress(_hactive)) {
						drag_side = 1;
						drag_mx   = _mx;
						drag_my   = _my;
						drag_s    = [ current_data[1], current_data[3] ];
					}
					
				} else if(distance_to_line_infinite(_mx, _my, brX, brY, trX, trY) < 12) {
					draw_line_width_infinite(brX, brY, trX, trY, 3);
					w_hovering = true;
					
					if(mouse_lpress(_hactive)) {
						drag_side = 2;
						drag_mx   = _mx;
						drag_my   = _my;
						drag_s    = [ current_data[4], current_data[2] ];
					}
					
				} else if(distance_to_line_infinite(_mx, _my, brX, brY, blX, blY) < 12) {
					draw_line_width_infinite(brX, brY, blX, blY, 3);
					w_hovering = true;
					
					if(mouse_lpress(_hactive)) {
						drag_side = 3;
						drag_mx   = _mx;
						drag_my   = _my;
						drag_s    = [ current_data[4], current_data[3] ];
					}
					
				} else if(point_in_rectangle_points(_mx, _my, tlX, tlY, trX, trY, blX, blY, brX, brY)) {
					draw_line_width(tlX, tlY, trX, trY, 3);
					draw_line_width(tlX, tlY, blX, blY, 3);
					draw_line_width(brX, brY, trX, trY, 3);
					draw_line_width(brX, brY, blX, blY, 3);
					w_hovering = true;
					
					if(mouse_lpress(_hactive)) {
						drag_side = 4;
						drag_mx   = _mx;
						drag_my   = _my;
						drag_s    = [ current_data[1], current_data[2], current_data[3], current_data[4] ];
					}
					
				}
			}
			
			drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		#endregion
		
		return w_hovering;
	}
	
	static warpSurface = function(surfBase, surfWarp, surfBack, sw, sh, tl, tr, bl, br, tile = 0) {
		var _wdim = surface_get_dimension(surfWarp);
		
		surface_set_shader(surfBase, sh_warp_4points, true, BLEND.over);
		shader_set_interpolation(surfWarp);
		
			shader_set_f( "dimension",   _wdim   );
			shader_set_f( "surfaceSize", [sw,sh] );
			shader_set_i( "tile",        tile    );
			
			shader_set_f( "p0",  tr );
			shader_set_f( "p1",  br );
			shader_set_f( "p2",  bl );
			shader_set_f( "p3",  tl );
			
			shader_set_i( "flip", 1 );
			draw_surface_stretched(surfBack, 0, 0, sw, sh);
			
			shader_set_f( "p0",  br );
			shader_set_f( "p1",  tr );
			shader_set_f( "p2",  tl );
			shader_set_f( "p3",  bl );
			shader_set_i( "flip", 0 );
			draw_surface_stretched(surfWarp, 0, 0, sw, sh);
			
		surface_reset_shader();
		
		return surfBase;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dimTyp = _data[ 6];
			var _dim    = _data[ 7];
			var _sdim   = _data[ 9];
			
			var _area   = _data[13];
			
			var _surfF  = _data[ 0];
			var _surfB  = is_surface(_data[10])? _data[10] : _surfF;
			
			var area     = _data[13];
			
			var tl      = _data[ 1];
			var tr      = _data[ 2];
			var bl      = _data[ 3];
			var br      = _data[ 4];
			
			var uvPos   = _data[12];
			var uvSca   = _data[11];
			var tile    = _data[ 8];
			var dOrig   = _data[14];
			
			inputs[7].setVisible(_dimTyp == 1);
			inputs[8].setVisible(true);
			inputs[9].setVisible(_dimTyp == 2);
			
			if(!is_surface(_surfF)) return _outSurf;
		#endregion
		
		var x0 = _area[0] - _area[2];
		var y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2];
		var y1 = _area[1] + _area[3];
		
		shader_set(sh_warp_4points);
			shader_set_2( "uvPosition", uvPos );
			shader_set_2( "uvScale",    uvSca );
			
			shader_set_2( "position",   [ x0, y0 ] );
			shader_set_2( "scale",      [ x1 - x0, y1 - y0 ] );
		shader_reset();
		
		var sw = 1;
		var sh = 1;
		
		switch(_dimTyp) {
			case 0 : sw = surface_get_width_safe(_surfF);
				     sh = surface_get_height_safe(_surfF); break;
			
			case 1 : sw = _dim[0];
				     sh = _dim[1]; break;
				
			case 2 : sw = _sdim[0] * surface_get_width_safe(_surfF);
				     sh = _sdim[1] * surface_get_height_safe(_surfF); break;
		}
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh, attrDepth());
		temp_surface[0] = warpSurface(temp_surface[0], _surfF, _surfB, sw, sh, tl, tr, bl, br, tile);
		
		_outSurf = surface_verify(_outSurf, sw, sh, attrDepth());
		surface_set_shader(_outSurf);
			if(dOrig) draw_surface(_surfF, 0, 0);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static getPreviewValues = function() { return isUsingTool(tool_area)? inputs[0].getValue() : outputs[0].getValue(); }
	
}