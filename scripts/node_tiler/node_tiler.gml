function Node_Tile_Drawer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Tile Drawer";
    bypass_grid = true;
    
	tileset = noone;
	
    newInput( 0, nodeValue_Tileset("Tileset", self, noone))
    	.setVisible(true, true);
    
    newInput( 1, nodeValue_IVec2("Map size", self, [ 16, 16 ]));
    
    newInput( 2, nodeValue_Bool("Animated", self, false));
    
	input_display_list = [ 1, 0 ];
	input_display_list_tileset   = ["Tileset",   false, noone, noone];
	input_display_list_autotiles = ["Autotiles",  true, noone, noone];
	input_display_list_palette   = ["Palette",    true, noone, noone];
	input_display_list_animated  = ["Animated",   true,     2, noone];
	
	newOutput(0, nodeValue_Output("Tile output", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tile map", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Index array", self, VALUE_TYPE.integer, []))
	    .setArrayDepth(1);
	
	#region ++++ data ++++
		canvas_surface   = surface_create_empty(1, 1, surface_rgba16float);
		canvas_buffer    = buffer_create(1 * 1 * 2, buffer_grow, 2);
	    
		drawing_surface  = noone;
		draw_stack       = ds_list_create();
		
		preview_drawing_tile      = surface_create_empty(1, 1);
		preview_draw_overlay      = surface_create_empty(1, 1);
		preview_draw_overlay_tile = surface_create_empty(1, 1);
		
		_preview_draw_mask        = surface_create_empty(1, 1);
		preview_draw_mask         = surface_create_empty(1, 1);
		
		attributes.dimension = [ 1, 1 ];
		temp_surface         = [ 0 ];
		
		selection_mask       = noone;
	#endregion
	
	#region ++++ selection ++++
		selecting   = false;
		selection_x = 0;
		selection_y = 0;
		
		selection_mask = noone;
	#endregion
	
	#region ++++ tool object ++++
		tool_brush     = new tiler_tool_brush(self, noone, false);
		tool_eraser    = new tiler_tool_brush(self, noone, true);
		tool_fill      = new tiler_tool_fill( self, noone, tool_attribute);
		
		tool_rectangle = new tiler_tool_shape(self, noone, CANVAS_TOOL_SHAPE.rectangle);
		tool_ellipse   = new tiler_tool_shape(self, noone, CANVAS_TOOL_SHAPE.ellipse);
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
				
			new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect_fill  ])
				.setSetting(tool_size)
				.setToolObject(tool_rectangle),
					
			new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip_fill ])
				.setSetting(tool_size)
				.setToolObject(tool_ellipse),
			
			new NodeTool( "Fill",		  THEME.canvas_tools_bucket)
				.setSetting(tool_fil8)
				.setToolObject(tool_fill),
		];
	#endregion
	
	function apply_draw_surface() {
		if(!is_surface(canvas_surface))  return;
		if(!is_surface(drawing_surface)) return;
		
		if(selecting) {
			surface_set_shader(canvas_surface, sh_draw_tile_apply_selection, true, BLEND.over);
				shader_set_surface("selectionMask", selection_mask);
				draw_surface(drawing_surface, 0, 0);
			surface_reset_shader();
			
		} else {
			surface_set_shader(canvas_surface, sh_draw_tile_apply, true, BLEND.over);
				draw_surface(drawing_surface, 0, 0);
			surface_reset_shader();
		}
		
		triggerRender();
	}
	
	function reset_surface(surface) {
		surface_set_shader(surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
	}
	
    static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
        if(tileset == noone) return;
        
        var _mapSize = current_data[1];
    	var _tileSiz = tileset.tileSize;
	    
	    canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    
        if(!surface_valid(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float)) {
        	drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    	
		    surface_set_shader(drawing_surface, noone, true, BLEND.over);
				draw_surface(canvas_surface, 0, 0);
			surface_reset_shader();
        }
        
	    #region surfaces
	    	var _dim      = attributes.dimension;
	    	var _outDim   = [ _tileSiz[0] * _dim[0], _tileSiz[1] * _dim[1] ];
	    	
			preview_draw_overlay = surface_verify(preview_draw_overlay, _dim[0], _dim[1], surface_rgba16float);
			preview_drawing_tile = surface_verify(preview_drawing_tile, _dim[0] * _tileSiz[0], _dim[1] * _tileSiz[1]);
			preview_draw_overlay_tile = surface_verify(preview_draw_overlay_tile, _dim[0] * _tileSiz[0], _dim[1] * _tileSiz[1]);
	    	
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			_preview_draw_mask = surface_verify(_preview_draw_mask, _dim[0], _dim[1]);
			 preview_draw_mask = surface_verify( preview_draw_mask, _sw, _sh);
			
	    #endregion
	    
	    #region tools
	    	var _currTool = PANEL_PREVIEW.tool_current;
	    	var _tool     = _currTool == noone? noone : _currTool.getToolObject();
	    	
			if(_tool) {
				var brush = tileset.brush;
	    	
	    		brush.node       = self;
		    	brush.brush_size = tool_attribute.size;
		    	brush.autotiler  = array_safe_get(tileset.autotiles, tileset.autotile_selecting, noone);
	    		
				_tool.brush              = brush;
				_tool.subtool            = _currTool.selecting;
				_tool.apply_draw_surface = apply_draw_surface;
				_tool.drawing_surface    = drawing_surface;
				_tool.tile_size          = _tileSiz;
				
				_tool.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				
				surface_set_target(preview_draw_overlay);
					DRAW_CLEAR
					_tool.drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_target();
				
				surface_set_target(_preview_draw_mask);
					DRAW_CLEAR
					_tool.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_target();
				
				surface_set_target(preview_draw_mask);
					DRAW_CLEAR
					draw_surface_ext(_preview_draw_mask, _x, _y, _s * _tileSiz[0], _s * _tileSiz[1], 0, c_white, 1);
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
			
		    surface_set_shader(preview_drawing_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        
		        shader_set_surface("indexTexture", drawing_surface);
		        shader_set_2("indexTextureDim", surface_get_dimension(drawing_surface));
		        
				tileset.shader_submit();
				
		        draw_empty();
		    surface_reset_shader();
		    
	    	draw_surface_ext(preview_drawing_tile, _x, _y, _s, _s, 0, c_white, 1);
	    	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    	
		    surface_set_shader(preview_draw_overlay_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        
		        shader_set_surface("indexTexture", preview_draw_overlay);
		        shader_set_2("indexTextureDim", surface_get_dimension(preview_draw_overlay));
		        
				tileset.shader_submit();
				
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
	    
	    //if(!array_empty(autotiles)) draw_surface_ext(autotiles[0].mask_surface, 32, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(canvas_surface,   32, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(drawing_surface, 232, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(preview_draw_overlay, 432, 32, 8, 8, 0, c_white, 1);
    }
    
	static processData = function(_outData, _data, _output_index, _array_index) {
	    tileset = _data[0];
	    
	    if(tileset == noone) {
			input_display_list = [ 1, 0 ];
			return _outData;
	    }
	    
	    input_display_list_tileset[3]   = tileset.tile_selector_toggler;
		input_display_list_autotiles[3] = tileset.autotile_selector_toggler;
		input_display_list_palette[3]   = tileset.palette_viewer_toggler;
		input_display_list_animated[3]  = tileset.animated_viewer_toggler;
	    
		input_display_list = [ 1, 0, 
			input_display_list_tileset,   tileset.tile_selector, 
			input_display_list_autotiles, tileset.autotile_selector, 
			input_display_list_palette,   tileset.palette_viewer,
			input_display_list_animated,  tileset.animated_viewer,
		]
		
		var _tileSet  = tileset.texture;
		var _tileSiz  = tileset.tileSize;
	    var _mapSize  = _data[1];
	    var _animated = _data[2];
	    update_on_frame = _animated;
	    
	    attributes.dimension[0] = _mapSize[0];
	    attributes.dimension[1] = _mapSize[1];
	    
	    if(!is_surface(canvas_surface) && buffer_exists(canvas_buffer)) {
	    	canvas_surface = surface_create(_mapSize[0], _mapSize[1], surface_rgba16float);
	    	buffer_set_surface(canvas_buffer, canvas_surface, 0);
	    } else 
	    	canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    
	    surface_set_shader(drawing_surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
		
	    if(!is_surface(_tileSet)) return _outData;
	    
	    var _tileOut = _outData[0];
	    var _tileMap = _outData[1];
	    var _arrIndx = _outData[2];
	    
	    var _outDim   = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    
	    _tileOut = surface_verify(_tileOut, _outDim[0],  _outDim[1]);
	    _tileMap = surface_verify(_tileMap, _mapSize[0], _mapSize[1], surface_rgba16float);
	    _arrIndx = array_verify(_arrIndx, _mapSize[0] * _mapSize[1]);
	    
	    buffer_resize(canvas_buffer, _mapSize[0] * _mapSize[1] * 2);
	    buffer_get_surface(canvas_buffer, canvas_surface, 0);
	    
	    surface_set_shader(_tileMap, sh_sample, true, BLEND.over);
	        draw_surface(canvas_surface, 0, 0);
	    surface_reset_shader();
	    
	    var _tileSetDim = surface_get_dimension(_tileSet);
	    
	    surface_set_shader(_tileOut, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        
	        shader_set_surface("indexTexture", _tileMap);
	        shader_set_2("indexTextureDim", surface_get_dimension(_tileMap));
	        
			shader_set_f("frame", CURRENT_FRAME);
	        tileset.shader_submit();
			
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
	     canvas_surface  = surface_verify(canvas_surface,  attributes.dimension[0], attributes.dimension[1], surface_rgba16float);
	     drawing_surface = surface_verify(drawing_surface, attributes.dimension[0], attributes.dimension[1], surface_rgba16float);
	     
	     buffer_set_surface(canvas_buffer, canvas_surface,  0);
	     buffer_set_surface(canvas_buffer, drawing_surface, 0);
	}
	
	static attributeSerialize = function() {
		var _attr = {
			canvas:  buffer_from_surface(canvas_surface)
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		var _canv = struct_try_get(attr, "canvas",  noone);
		
		if(_canv) {
			surface_free_safe(canvas_surface);
			canvas_surface = surface_from_buffer(_canv);
		}
	}
}