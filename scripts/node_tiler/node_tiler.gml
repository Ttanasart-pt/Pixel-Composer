function Node_Tile_Drawer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Tile Drawer";
    bypass_grid = true;
    
    newInput( 0, nodeValue_Surface("Tileset", self, noone));
    
    newInput( 1, nodeValue_IVec2("Map size", self, [ 16, 16 ]));
    
    newInput( 2, nodeValue_Vec2("Tile size", self, [ 16, 16 ]));
    
    #region tile selector 
	    tile_selector_surface = 0;
	    tile_selector_mask    = 0;
	    tile_selector_h       = ui(320);
	    
	    tile_selector_x    = 0;
	    tile_selector_y    = 0;
	    tile_selector_s    = 1;
	    tile_selector_s_to = 1;
	    
	    tile_dragging = false;
	    tile_drag_sx  = 0;
	    tile_drag_sy  = 0;
	    tile_drag_mx  = 0;
	    tile_drag_my  = 0;
	    
	    tile_selecting = false;
	    tile_select_ss = [ 0, 0 ];
	    
	    grid_draw = true;
	    
	    tile_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
	    	var _h       = tile_selector_h;
	    	var _pd      = ui(4);
	    	var _tileSet = current_data[0];
	    	var _tileSiz = current_data[2];
	    	
	    	var _sx = _x + _pd;
	    	var _sy = _y + _pd;
	    	var _sw = _w - _pd * 2;
	    	var _sh = _h - _pd * 2;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, c_white, 1);
	    	tile_selector_surface = surface_verify(tile_selector_surface, _sw, _sh);
	    	tile_selector_mask    = surface_verify(tile_selector_mask,    _sw, _sh);
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
	    	var _tileSel_w =_tileSiz[0] * tile_selector_s;
	    	var _tileSel_h =_tileSiz[1] * tile_selector_s;
	    	
	    	var _msx = _m[0] - _sx - tile_selector_x;
	    	var _msy = _m[1] - _sy - tile_selector_y;
	    	
	    	var _mtx = floor(_msx / tile_selector_s / _tileSiz[0]);
	    	var _mty = floor(_msy / tile_selector_s / _tileSiz[1]);
	    	var _mid = _mtx >= 0 && _mtx < _tileAmo[0] && _mty >= 0 && _mtx < _tileAmo[1]? _mty * _tileAmo[0] + _mtx : noone;
	    	
	    	var _tileHov_x = tile_selector_x + _mtx * _tileSiz[0] * tile_selector_s;
	    	var _tileHov_y = tile_selector_y + _mty * _tileSiz[1] * tile_selector_s;
	    	
	    	var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
	    	
	    	surface_set_target(tile_selector_surface);
	    		draw_clear(COLORS.panel_bg_clear);
	    		draw_sprite_tiled_ext(s_transparent, 0, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, COLORS.panel_preview_transparent, 1);
	    		
	    		draw_surface_ext(_tileSet, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, 0, c_white, 1);
	    		
	    		if(grid_draw) {
	    			var _gw = _tileSiz[0] * tile_selector_s;
			        var _gh = _tileSiz[1] * tile_selector_s;
			        
			        var gw = _tdim[0] / _tileSiz[0];
			        var gh = _tdim[1] / _tileSiz[1];
			    	
			        var cx = tile_selector_x;
			        var cy = tile_selector_y;
			    
			        draw_set_color(PROJECT.previewGrid.color);
			        draw_set_alpha(PROJECT.previewGrid.opacity);
			        
			        for( var i = 1; i < gw; i++ ) {
			            var _xx = cx + i * _gw;
			            draw_line(_xx, cy, _xx, cy + _tdim[1] * tile_selector_s);
			        }
			    
			        for( var i = 1; i < gh; i++ ) {
			            var _yy = cy + i * _gh;
			            draw_line(cx, _yy, cx + _tdim[0] * tile_selector_s, _yy);
			        }
			        
			        draw_set_alpha(1);
	    		}
	    		
	    		draw_set_color(COLORS.panel_preview_surface_outline);
            	draw_rectangle(tile_selector_x, tile_selector_y, tile_selector_x + _tdim[0] * tile_selector_s - 1, tile_selector_y + _tdim[1] * tile_selector_s - 1, true);
	    		
	    		draw_set_color(c_black);
	    		draw_rectangle_width(_tileHov_x, _tileHov_y, _tileHov_x + _tileSel_w - 1, _tileHov_y + _tileSel_h - 1, 1);
	    		
	    		if(_hov && _mid > noone && mouse_press(mb_left, _focus)) {
    				tile_selecting = true;
    				tile_select_ss = [ _mtx, _mty ];
	    		}
	    	surface_reset_target();
	    	
	    	surface_set_target(tile_selector_mask);
	    		DRAW_CLEAR
	    		
	    		draw_set_color(c_white);
	    		
	    		for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
	    		for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
	    			var _bindex      = brush.brush_indices[i][j];
			    	var _tileSel_row = floor(_bindex / _tileAmo[0]);
			    	var _tileSel_col = safe_mod(_bindex, _tileAmo[0]);
		    		var _tileSel_x   = tile_selector_x + _tileSel_col * _tileSiz[0] * tile_selector_s;
		    		var _tileSel_y   = tile_selector_y + _tileSel_row * _tileSiz[1] * tile_selector_s;
		    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
	    		}
	    	surface_reset_target();
	    	
	    	#region tile selection
	    		if(tile_selecting) {
	    			var _ts_sx = clamp(min(tile_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
	    			var _ts_sy = clamp(min(tile_select_ss[1], _mty), 0, _tileAmo[1] - 1);
	    			var _ts_ex = clamp(max(tile_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
	    			var _ts_ey = clamp(max(tile_select_ss[1], _mty), 0, _tileAmo[1] - 1);
	    			
	    			brush.brush_indices = [];
	    			brush.brush_width   = _ts_ex - _ts_sx + 1;
    				brush.brush_height  = _ts_ey - _ts_sy + 1;
	    			var _ind = 0;
	    			
	    			for( var i = _ts_sy; i <= _ts_ey; i++ ) 
	    			for( var j = _ts_sx; j <= _ts_ex; j++ )
	    				brush.brush_indices[i - _ts_sy][j - _ts_sx] = i * _tileAmo[0] + j;
	    			
	    			if(mouse_release(mb_left))
		    			tile_selecting = false;
	    		}
	    	#endregion
	    	
	    	#region pan zoom 
		    	if(tile_dragging) {
		    		var _tdx = _m[0] - tile_drag_mx;
		    		var _tdy = _m[1] - tile_drag_my;
		    		
		    		tile_selector_x = tile_drag_sx + _tdx;
				    tile_selector_y = tile_drag_sy + _tdy;
				    
		    		if(mouse_release(mb_middle))
		    			tile_dragging = false;
		    	}
		    	
		    	if(_hov) {
		    		if(mouse_press(mb_middle, _focus)) {
			    		tile_dragging = true;
			    		tile_drag_sx  = tile_selector_x;
					    tile_drag_sy  = tile_selector_y;
					    tile_drag_mx  = _m[0];
					    tile_drag_my  = _m[1];
		    		}
		    		
		    		var _s = tile_selector_s;
		    		if(mouse_wheel_up())   { tile_selector_s_to = clamp(tile_selector_s_to * 1.1, 0.5, 4); }
		    		if(mouse_wheel_down()) { tile_selector_s_to = clamp(tile_selector_s_to / 1.1, 0.5, 4); }
		    		tile_selector_s = lerp_float(tile_selector_s, tile_selector_s_to, 3);
		    		
		    		if(_s != tile_selector_s) {
		    			var _ds  = tile_selector_s - _s;
		    			
		    			tile_selector_x -= _msx * _ds / _s;
		    			tile_selector_y -= _msy * _ds / _s;
		    		}
		    	}
		    	
		    	var _tdim_ws = _tdim[0] * tile_selector_s;
		    	var _tdim_hs = _tdim[1] * tile_selector_s;
		    	var _minx = -(_tdim_ws - _w) - 32;
		    	var _miny = -(_tdim_hs - _h) - 32;
		    	var _maxx = 32;
		    	var _maxy = 32;
		    	if(_minx > _maxx) { _minx = (_minx + _maxx) / 2; _maxx = _minx; }
		    	if(_miny > _maxy) { _miny = (_miny + _maxy) / 2; _maxy = _miny; }
		    	
		    	tile_selector_x = clamp(tile_selector_x, _minx, _maxx);
			    tile_selector_y = clamp(tile_selector_y, _miny, _maxy);
		    #endregion
		    	
	    	draw_surface(tile_selector_surface, _sx, _sy);
	    	
			shader_set(sh_brush_outline);
				shader_set_f("dimension", _sw, _sh);
				draw_surface(tile_selector_mask, _sx, _sy);
			shader_reset();
			
	    	return _h;
	    });
    #endregion
    
	input_display_list = [ 
		["Tileset",  false], 0, 2, 
		["Map",      false], 1, 
		["Tiles",    false], tile_selector, 
	]
	
	newOutput(0, nodeValue_Output("Tile output", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tile map", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Index array", self, VALUE_TYPE.integer, []))
	    .setArrayDepth(1);
	
	#region ++++ data ++++
		canvas_surface   = surface_create_empty(1, 1, surface_r16float);
		canvas_buffer    = buffer_create(1 * 1 * 2, buffer_grow, 2);
	    
		drawing_surface  = surface_create_empty(1, 1, surface_r16float);
		draw_stack       = ds_list_create();
		
		preview_drawing_tile      = surface_create_empty(1, 1);
		preview_draw_overlay      = surface_create_empty(1, 1);
		preview_draw_overlay_tile = surface_create_empty(1, 1);
		
		_preview_draw_mask        = surface_create_empty(1, 1);
		preview_draw_mask         = surface_create_empty(1, 1);
		
		attributes.dimension = [ 1, 1 ];
		temp_surface = [ 0 ];
	#endregion
	
	#region ++++ tool object ++++
		brush = new tiler_brush(self);
		
		tool_brush     = new tiler_tool_brush(self, brush, false);
		tool_eraser    = new tiler_tool_brush(self, brush, true);
		tool_fill      = new tiler_tool_fill( self, brush, tool_attribute);
	#endregion
	
	#region ++++ tools ++++
		tool_attribute.size = 1;
		tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(val) { tool_attribute.size = max(1, round(val)); }).setSlideType(true)
									.setFont(f_p3)
									.setSideButton(button(function() { dialogPanelCall(new Panel_Node_Canvas_Pressure(self), mouse_mx, mouse_my, { anchor: ANCHOR.top | ANCHOR.left }) })
										.setIcon(THEME.pen_pressure, 0, COLORS._main_icon));
		tool_size           = [ "Size", tool_size_edit, "size", tool_attribute ];
		
		tool_attribute.fillType = 0;
		tool_fil8_edit      	= new buttonGroup( [ THEME.canvas_fill_type, THEME.canvas_fill_type, THEME.canvas_fill_type ], function(val) { tool_attribute.fillType = val; })
									.setTooltips( [ "Edge", "Edge + Corner" ] )
									.setCollape(false);
		tool_fil8           	= [ "Fill", tool_fil8_edit, "fillType", tool_attribute ];
		
		tools = [
			new NodeTool( "Pencil",		  THEME.canvas_tools_pencil)
				.setSetting(tool_size)
				.setToolObject(tool_brush),
			
			new NodeTool( "Eraser",		  THEME.canvas_tools_eraser)
				.setSetting(tool_size)
				.setToolObject(tool_eraser),
				
			new NodeTool( "Fill",		  THEME.canvas_tools_bucket)
				.setSetting(tool_fil8)
				.setToolObject(tool_fill),
		];
	#endregion
	
	function apply_draw_surface() {
		if(!is_surface(canvas_surface)) return;
		if(!is_surface(drawing_surface)) return;
		
		surface_set_shader(canvas_surface, noone, true, BLEND.over);
			draw_surface(drawing_surface, 0, 0);
		surface_reset_shader();
		
		triggerRender();
	}
	
    static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
        var _tileSet  = current_data[0];
        var _mapSize  = current_data[1];
    	var _tileSize = current_data[2];
	    
        if(!is_surface(drawing_surface)) {
        	drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_r16float);
	    
		    surface_set_shader(drawing_surface, noone, true, BLEND.over);
				draw_surface(canvas_surface, 0, 0);
			surface_reset_shader();
        }
        
	    #region surfaces
	    	var _dim      = attributes.dimension;
	    	var _outDim   = [ _tileSize[0] * _dim[0], _tileSize[1] * _dim[1] ];
	    	
			preview_draw_overlay = surface_verify(preview_draw_overlay, _dim[0], _dim[1], surface_r16float);
			preview_drawing_tile = surface_verify(preview_drawing_tile, _dim[0] * _tileSize[0], _dim[1] * _tileSize[1]);
			preview_draw_overlay_tile = surface_verify(preview_draw_overlay_tile, _dim[0] * _tileSize[0], _dim[1] * _tileSize[1]);
	    	
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			_preview_draw_mask = surface_verify(_preview_draw_mask, _dim[0], _dim[1]);
			 preview_draw_mask = surface_verify( preview_draw_mask, _sw, _sh);
			
	    #endregion
	    
	    #region tools
	    	var _currTool = PANEL_PREVIEW.tool_current;
	    	var _tool     = _currTool == noone? noone : _currTool.getToolObject();
	    	
	    	brush.brush_size = tool_attribute.size;
	    	
			if(_tool) {
				_tool.subtool            = _currTool.selecting;
				_tool.apply_draw_surface = apply_draw_surface;
				_tool.drawing_surface    = drawing_surface;
				_tool.tile_size          = _tileSize;
				
				_tool.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				
				surface_set_target(preview_draw_overlay);
					DRAW_CLEAR
					_tool.drawPreview();
				surface_reset_target();
				
				surface_set_target(_preview_draw_mask);
					DRAW_CLEAR
					_tool.drawMask();
				surface_reset_target();
				
				surface_set_target(preview_draw_mask);
					DRAW_CLEAR
					draw_surface_ext(_preview_draw_mask, _x, _y, _s * _tileSize[0], _s * _tileSize[1], 0, c_white, 1);
				surface_reset_target();
				
				if(_tool.brush_resizable) { 
					if(hover && key_mod_press(CTRL)) {
						if(mouse_wheel_down()) tool_attribute.size = max( 1, tool_attribute.size - 1);
						if(mouse_wheel_up())   tool_attribute.size = min(64, tool_attribute.size + 1);
					}
					
					brush.sizing(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				} 
			}
	    #endregion
	    
	    #region draw preview surfaces
			var _tileSetDim = surface_get_dimension(_tileSet);
	    	
		    surface_set_shader(preview_drawing_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        shader_set_2("tileSize",  _tileSize);
		        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
		        
		        shader_set_surface("tileTexture", _tileSet);
		        shader_set_2("tileTextureDim", _tileSetDim);
		        
		        shader_set_surface("indexTexture", drawing_surface);
		        shader_set_2("indexTextureDim", surface_get_dimension(drawing_surface));
		        
		        draw_empty();
		    surface_reset_shader();
		    
	    	draw_surface_ext(preview_drawing_tile, _x, _y, _s, _s, 0, c_white, 1);
	    	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    	
		    surface_set_shader(preview_draw_overlay_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        shader_set_2("tileSize",  _tileSize);
		        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
		        
		        shader_set_surface("tileTexture", _tileSet);
		        shader_set_2("tileTextureDim", _tileSetDim);
		        
		        shader_set_surface("indexTexture", preview_draw_overlay);
		        shader_set_2("indexTextureDim", surface_get_dimension(preview_draw_overlay));
		        
		        draw_empty();
		    surface_reset_shader();
		    
	    	draw_surface_ext(preview_draw_overlay_tile, _x, _y, _s, _s, 0, c_white, 1);
	    	
	    	params.panel.drawNodeGrid();
	    	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    	
			shader_set(sh_brush_outline);
				shader_set_f("dimension", _sw, _sh);
				draw_surface(preview_draw_mask, 0, 0);
			shader_reset();
			
	    #endregion
    }
    
	static processData = function(_outData, _data, _output_index, _array_index) {
	    var _tileSet  = _data[0];
	    var _mapSize  = _data[1];
	    var _tileSize = _data[2];
	    
	    attributes.dimension[0] = _mapSize[0];
	    attributes.dimension[1] = _mapSize[1];
	    
	    if(!is_surface(canvas_surface) && buffer_exists(canvas_buffer)) {
	    	canvas_surface = surface_create(_mapSize[0], _mapSize[1], surface_r16float);
	    	buffer_set_surface(canvas_buffer, canvas_surface, 0);
	    } else 
	    	canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_r16float);
	    drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_r16float);
	    
	    surface_set_shader(drawing_surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
		
	    if(!is_surface(_tileSet)) return _outData;
	    
	    var _tileOut = _outData[0];
	    var _tileMap = _outData[1];
	    var _arrIndx = _outData[2];
	    
	    var _outDim   = [ _tileSize[0] * _mapSize[0], _tileSize[1] * _mapSize[1] ];
	    
	    _tileOut = surface_verify(_tileOut, _outDim[0],  _outDim[1]);
	    _tileMap = surface_verify(_tileMap, _mapSize[0], _mapSize[1], surface_r16float);
	    _arrIndx = array_verify(_arrIndx, _mapSize[0] * _mapSize[1]);
	    
	    buffer_resize(canvas_buffer, _mapSize[0] * _mapSize[1] * 2);
	    buffer_get_surface(canvas_buffer, canvas_surface, 0);
	    
	    surface_set_shader(_tileMap, sh_sample, true, BLEND.over);
	        draw_surface(canvas_surface, 0, 0);
	    surface_reset_shader();
	    
	    var _tileSetDim = surface_get_dimension(_tileSet);
	    
	    surface_set_shader(_tileOut, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        shader_set_2("tileSize",  _tileSize);
	        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
	        
	        shader_set_surface("tileTexture", _tileSet);
	        shader_set_2("tileTextureDim", _tileSetDim);
	        
	        shader_set_surface("indexTexture", _tileMap);
	        shader_set_2("indexTextureDim", surface_get_dimension(_tileMap));
	        
	        draw_empty();
	    surface_reset_shader();
	    
	    return [ _tileOut, _tileMap, _arrIndx ];
	}
	
    static getPreviewValues       = function() { return preview_drawing_tile; }
    static getGraphPreviewSurface = function() { return getSingleValue(0, preview_index, true); }
	
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
	static doSerialize = function(_map) {
		_map.surface = buffer_serialize(canvas_buffer);
	}
	
	static doApplyDeserialize = function() {
	     canvas_buffer   = buffer_deserialize(load_map.surface);
	     canvas_surface  = surface_verify(canvas_surface,  attributes.dimension[0], attributes.dimension[1], surface_r16float);
	     drawing_surface = surface_verify(drawing_surface, attributes.dimension[0], attributes.dimension[1], surface_r16float);
	     
	     buffer_set_surface(canvas_buffer, canvas_surface,  0);
	     buffer_set_surface(canvas_buffer, drawing_surface, 0);
	}
	
}