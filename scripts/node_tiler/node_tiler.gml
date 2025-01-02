function Node_Tile_Drawer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name        = "Tile Drawer";
    bypass_grid = true;
    
	tileset     = noone;
	gmTileLayer = noone;
	
    newInput( 0, nodeValue_Tileset("Tileset", self, noone))
    	.setVisible(true, true);
    
    newInput( 1, nodeValue_IVec2("Map size", self, [ 16, 16 ]));
    
    newInput( 2, nodeValue_Bool("Animated", self, false));
    
    newInput( 3, nodeValueSeed(self));
    
	input_display_list = [ 3, 1, 0 ];
	input_display_list_tileset      = ["Tileset",      false, noone, noone];
	input_display_list_autoterrains = ["Autoterrains",  true, noone, noone];
	input_display_list_palette      = ["Palette",       true, noone, noone];
	input_display_list_animated     = ["Animated tiles",true,     2, noone];
	input_display_list_rule         = ["Rules",         true, noone, noone];
	
	newOutput(0, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tilemap", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Tileset", self, VALUE_TYPE.tileset, noone));
	
	newOutput(3, nodeValue_Output("Tile Data", self, VALUE_TYPE.struct, {}));
	outputs[3].editWidget.shorted = true;
	
	output_display_list = [ 2, 1, 0, 3 ];
	
	#region ++++ data ++++
		canvas_surface   = surface_create_empty(1, 1, surface_rgba16float);
		canvas_buffer    = buffer_create(1, buffer_grow, 1);
	    
		drawing_surface  = noone;
		draw_stack       = ds_list_create();
		
		preview_drawing_tile      = surface_create_empty(1, 1);
		preview_draw_overlay      = surface_create_empty(1, 1);
		preview_draw_overlay_tile = surface_create_empty(1, 1);
		
		_preview_draw_mask        = surface_create_empty(1, 1);
		preview_draw_mask         = surface_create_empty(1, 1);
		
		temp_surface         = [ 0, 0, 0 ];
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
		tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { tool_attribute.size = max(1, round(val)); }).setSlideType(true)
									.setFont(f_p3)
									.setSideButton(button(function() /*=>*/ { dialogPanelCall(new Panel_Node_Canvas_Pressure(self), mouse_mx, mouse_my, { anchor: ANCHOR.top | ANCHOR.left }) })
										.setIcon(THEME.pen_pressure, 0, COLORS._main_icon));
		tool_size           = [ "Size", tool_size_edit, "size", tool_attribute ];
		
		tool_attribute.fillType = 0;
		tool_fil8_edit      	= new buttonGroup( [ THEME.canvas_fill_type, THEME.canvas_fill_type, THEME.canvas_fill_type ], function(val) /*=>*/ { tool_attribute.fillType = val; })
									.setTooltips( [ "Edge", "Edge + Corner" ] )
									.setCollape(false);
		tool_fil8           	= [ "Fill", tool_fil8_edit, "fillType", tool_attribute ];
		
		tool_varient_rotate  = [ "", new buttonGroup( [ s_canvas_rotate, s_canvas_rotate ], function(v) /*=>*/ {return brush_action_rotate(v)} )
			.setCollape(0).setTooltips([ "Rotate CW", "Rotate CCW" ]) ];
			
		tool_varient_flip    = [ "", new buttonGroup( [ s_canvas_flip, s_canvas_flip ], function(v) /*=>*/ {return brush_action_flip(v)} )
			.setCollape(0).setTooltips([ "Flip X", "Flip Y" ]) ];
		
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		node_tool_pencil	= new NodeTool( "Pencil", THEME.canvas_tools_pencil).setToolObject(tool_brush)
								.setSetting(tool_size, tool_varient_rotate, tool_varient_flip)
		
		node_tool_eraser	= new NodeTool( "Eraser", THEME.canvas_tools_eraser).setToolObject(tool_eraser)
								.setSetting(tool_size)
				
		node_tool_rectangle = new NodeTool( "Rectangle", THEME.canvas_tools_rect_fill).setToolObject(tool_rectangle)
								.setSetting(tool_size, tool_varient_rotate, tool_varient_flip)
						
		node_tool_ellipse	= new NodeTool( "Ellipse", THEME.canvas_tools_ellip_fill).setToolObject(tool_ellipse)
								.setSetting(tool_size, tool_varient_rotate, tool_varient_flip)
						
		node_tool_fill		= new NodeTool( "Fill", THEME.canvas_tools_bucket).setToolObject(tool_fill)
								.setSetting(tool_fil8, tool_varient_rotate, tool_varient_flip)
		
		tools = [
			node_tool_pencil,
			node_tool_eraser,
			node_tool_rectangle,
			node_tool_ellipse,
			node_tool_fill,
		];
		
		tool_tile_picker = false;
	#endregion
	
	#region ++++ tools actions ++++
		function brush_action_rotate(ccw) {
			if(tileset == noone) return;
			var brush = tileset.brush;
			var _rot  = ccw? -1 : 1;
			
			for( var i = 0, n = brush.brush_height; i < n; i++ ) 
			for( var j = 0, m = brush.brush_width;  j < m; j++ ) {
				var _b  = brush.brush_indices[i][j];
				var _fl = floor(_b[1] / 4) * 4;
				var _rt = _b[1] % 4;
				
				_b[1] = _fl + (_rt + _rot + 4) % 4;
			}
		}
		
		function brush_action_flip(axs) {
			if(tileset == noone) return;
			var brush = tileset.brush;
			var flp   = axs? 0b1000 : 0b0100;
			
			for( var i = 0, n = brush.brush_height; i < n; i++ ) 
			for( var j = 0, m = brush.brush_width;  j < m; j++ ) {
				var _b = brush.brush_indices[i][j];
				_b[1] = _b[1] ^ flp;
			}
		}
	#endregion
	
	#region ++++ hotkeys ++++
		hotkeys = [
			["Brush Rotate CW",  function() /*=>*/ { brush_action_rotate(0); }], 
			["Brush Rotate CCW", function() /*=>*/ { brush_action_rotate(1); }], 
			["Brush Flip H",     function() /*=>*/ { brush_action_flip(0);   }], 
			["Brush Flip V",     function() /*=>*/ { brush_action_flip(1);   }], 
		];
	#endregion
	
	function apply_draw_surface() { 
		if(!is_surface(canvas_surface) || !is_surface(drawing_surface)) return;
		
		surface_set_shader(canvas_surface, sh_draw_tile_apply, true, BLEND.over);
			draw_surface(drawing_surface, 0, 0);
		surface_reset_shader();
		
		triggerRender();
	}
	
	static storeAction = function() {
		var action = recordAction(ACTION_TYPE.custom, function(data) { 
			var _canvas    = surface_clone(canvas_surface);
			canvas_surface = data.surface;
			data.surface   = _canvas;
			triggerRender();
			
		}, { surface: surface_clone(canvas_surface), tooltip: "Modify tilemap" });
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
	    
        if(!surface_valid(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float)) return false;
        
	    #region surfaces
	    	var _outDim   = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    	
			preview_draw_overlay      = surface_verify(preview_draw_overlay,      _mapSize[0],               _mapSize[1], surface_rgba16float);
			preview_drawing_tile      = surface_verify(preview_drawing_tile,      _mapSize[0] * _tileSiz[0], _mapSize[1] * _tileSiz[1]);
			preview_draw_overlay_tile = surface_verify(preview_draw_overlay_tile, _mapSize[0] * _tileSiz[0], _mapSize[1] * _tileSiz[1]);
	    	
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			_preview_draw_mask = surface_verify(_preview_draw_mask, _mapSize[0], _mapSize[1]);
			 preview_draw_mask = surface_verify( preview_draw_mask, _sw, _sh);
			
	    #endregion
	    
    	var _currTool = PANEL_PREVIEW.tool_current;
    	var _tool     = _currTool == noone? noone : _currTool.getToolObject();
    	
    	if(!is(_tool, tiler_tool))
    		_tool = noone;
    	
		if(_tool) { // tool action
			var brush = tileset.brush;
    	
    		brush.node        = self;
	    	brush.brush_size  = tool_attribute.size;
	    	brush.autoterrain = is(tileset.object_selecting, tiler_brush_autoterrain)? tileset.object_selecting : noone;
    		
			_tool.brush              = brush;
			_tool.subtool            = _currTool.selecting;
			_tool.apply_draw_surface = apply_draw_surface;
			_tool.drawing_surface    = drawing_surface;
			_tool.tile_size          = _tileSiz;
			
			if(!tool_tile_picker) {
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
				
			    surface_set_shader(preview_draw_overlay_tile, sh_draw_tile_map, true, BLEND.over);
			        shader_set_2("dimension", _outDim);
			        
			        shader_set_surface("indexTexture", preview_draw_overlay);
			        shader_set_2("indexTextureDim", surface_get_dimension(preview_draw_overlay));
			        
					tileset.shader_submit();
					
			        draw_empty();
			    surface_reset_shader();
			    
		    	draw_surface_ext(preview_draw_overlay_tile, _x, _y, _s, _s, 0, c_white, 1);
		    	
		    	params.panel.drawNodeGrid();
		    	
				shader_set(sh_brush_outline);
					shader_set_f("dimension", _sw, _sh);
					draw_surface(preview_draw_mask, 0, 0);
				shader_reset();
			} 
			
			if(tool_tile_picker) {
				var _mtx = floor(round((_mx - _x) / _s - 0.5) / _tileSiz[0]);
				var _mty = floor(round((_my - _y) / _s - 0.5) / _tileSiz[1]);
				
				var _mrx = _x + _mtx * _s * _tileSiz[0];
				var _mry = _y + _mty * _s * _tileSiz[1];
				
				draw_set_color(COLORS._main_accent);
				draw_rectangle(_mrx, _mry, _mrx + _s * _tileSiz[0], _mry + _s * _tileSiz[0], true);
				
				var _cc = surface_getpixel_ext(canvas_surface, _mtx, _mty);
				
				if(is_array(_cc)) {
					params.panel.sample_data = {
						type: "tileset",
						drawFn: tileset.drawTile,
						index: _cc[0] - 1,
					};
					
					if(mouse_click(mb_left, active)) {
						brush.brush_indices = [[[ _cc[0] - 1, _cc[1] ]]];
		    			brush.brush_width   = 1;
						brush.brush_height  = 1;
						
						tool_tile_picker = false;
					}
				}
				
				if(!key_mod_press(ALT))
					tool_tile_picker = false;
			}
			
			if(hover && key_mod_press(ALT))
				tool_tile_picker = true;
		}
	    
	    for( var i = 0, n = array_length(hotkeys); i < n; i++ ) {
	    	var _hk = hotkeys[i];
	    	var _h = getToolHotkey("Node_Tile_Drawer", _hk[0]);
	    	if(_h == noone) continue;
	    	
	    	if(_h.isPressing()) _hk[1]();
	    }
    }
    
    ////- Update
    
    static preGetInputs = function() {
    	if(gmTileLayer == noone) return;
    	
		inputs[1].setValue([ gmTileLayer.tiles.SerialiseWidth, gmTileLayer.tiles.SerialiseHeight ]);
    }
    
	static processData = function(_outData, _data, _output_index, _array_index) {
	    tileset = _data[0];
	    _outData[2] = tileset;
	    
	    if(tileset == noone) {
			input_display_list = [ 3, 1, 0 ];
			return _outData;
	    }
		 
	    input_display_list_tileset[3]      = tileset.tile_selector.b_toggle;
		input_display_list_autoterrains[3] = tileset.autoterrain_selector.b_toggle;
		input_display_list_palette[3]      = tileset.palette_viewer.b_toggle;
		input_display_list_animated[3]     = tileset.animated_viewer.b_toggle;
		input_display_list_rule[3]         = tileset.rules.b_toggle;
	    
		input_display_list = [ 3, 1, 0, 
			input_display_list_tileset,      tileset.tile_selector, 
			input_display_list_autoterrains, tileset.autoterrain_selector, 
			input_display_list_palette,      tileset.palette_viewer,
			input_display_list_animated,     tileset.animated_viewer,
			input_display_list_rule,         tileset.rules,
		]
		
		var _tileSet    = tileset.texture;
		var _tileSiz    = tileset.tileSize;
	    var _mapSize    = _data[1];
	    var _animated   = _data[2];
	    var _seed       = _data[3];
	    update_on_frame = _animated;
	    
	    if(!is_surface(canvas_surface) && buffer_exists(canvas_buffer)) { 
	    	canvas_surface = surface_create(_mapSize[0], _mapSize[1], surface_rgba16float);
	    	buffer_set_surface(canvas_buffer, canvas_surface, 0);
	    } else 
	    	canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    	
	    drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    temp_surface[0] = surface_verify(temp_surface[0], _mapSize[0], _mapSize[1], surface_rgba16float);
	    temp_surface[1] = surface_verify(temp_surface[1], _mapSize[0], _mapSize[1], surface_rgba16float);
	    temp_surface[2] = surface_verify(temp_surface[2], _mapSize[0], _mapSize[1], surface_rgba16float);
	    
	    surface_set_shader(drawing_surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
		
	    if(!is_surface(_tileSet)) return _outData;
	    
	    var _outDim   = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    
	    var _tileOut = surface_verify(_outData[0], _outDim[0],  _outDim[1]);
	    var _tileMap = surface_verify(_outData[1], _mapSize[0], _mapSize[1], surface_rgba16float);
	    
	    canvas_buffer = buffer_verify(canvas_buffer, _mapSize[0] * _mapSize[1] * 8);
	    buffer_get_surface(canvas_buffer, canvas_surface, 0);
	    
	    surface_set_shader(temp_surface[2], sh_sample, true, BLEND.over);
	        draw_surface(canvas_surface, 0, 0);
	    surface_reset_shader();
	    
	    var _applied = tileset.rules.apply(temp_surface[2], _seed);
	    
	    surface_set_shader(_tileMap, sh_sample, true, BLEND.over);
	        draw_surface(_applied, 0, 0);
	    surface_reset_shader();
	    
	    surface_set_shader(_tileOut, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        
	        shader_set_surface("indexTexture", _tileMap);
	        shader_set_2("indexTextureDim", surface_get_dimension(_tileMap));
	        
			shader_set_f("frame", CURRENT_FRAME);
	        tileset.shader_submit();
			
	        draw_empty();
	    surface_reset_shader();
	    
	    var tileData = _outData[3];
	    var amo      = _mapSize[0] * _mapSize[1];
	    
	    if(gmTileLayer != noone) {
	    	var tileArr = array_verify(struct_try_get(tileData, "data"), amo);
	    	var i = 0;
	    	var b;
	    	
	    	buffer_to_start(canvas_buffer);
	    	
	    	repeat(amo) {
	    		b = buffer_read(canvas_buffer, buffer_f16);
	    		    buffer_read(canvas_buffer, buffer_f16);
				    buffer_read(canvas_buffer, buffer_f16);
				    buffer_read(canvas_buffer, buffer_f16);
				
	    		b = round(b);
	    		
	    		switch(b) {
	    			case 0 :  tileArr[i] = 0;     break;
	    			default : tileArr[i] = b - 1; break;
	    		}
	    		 
				i++;
	    	}
	    	
	    	tileData.tileset =  tileset;
	    	tileData.data    =  tileArr;
	    	tileData.preview = _tileOut;
	    }
	    
	    return [ _tileOut, _tileMap, tileset, tileData ];
	}
	
    ////- GM
    
    static bindTile = function(_gmTile) {
    	gmTileLayer = _gmTile;
    	
    	inputs[0].editable = gmTileLayer == noone;
		inputs[1].editable = gmTileLayer == noone;
		inputs[2].editable = gmTileLayer == noone;
		
		outputs[0].setVisible(gmTileLayer == noone);
		outputs[1].setVisible(gmTileLayer == noone);
		outputs[2].setVisible(gmTileLayer == noone);
		outputs[3].setVisible(gmTileLayer != noone);
		
    	if(gmTileLayer == noone) return;
    	
    	display_name = gmTileLayer.name;
    	
		var _w = gmTileLayer.tiles.SerialiseWidth;
		var _h = gmTileLayer.tiles.SerialiseHeight;
		inputs[1].setValue([ _w, _h ]);
		
		var _form = struct_try_get(gmTileLayer.tiles, "TileDataFormat", 0), _data = [];
		var _b = buffer_create(_w * _h * 8, buffer_grow, 1);
		buffer_to_start(_b);
		
		if(_form == 0) {
			_data = gmTileLayer.tiles.TileSerialiseData;
			
			for( var i = 0, n = array_length(_data); i < n; i++ ) {
				buffer_write(_b, buffer_f16, _data[i]);
				buffer_write(_b, buffer_f16, 0);
				buffer_write(_b, buffer_f16, 0);
				buffer_write(_b, buffer_f16, 0);
			}
			
		} else if(_form == 1) {
			_data = gmTileLayer.tiles.TileCompressedData;
			
			var _amo, _til;
			
			for( var i = 0, n = array_length(_data); i < n; i += 2 ) {
				_amo = -_data[i + 0];
				_til =  _data[i + 1];
				_til = max(0, _til + bool(_til));
				
				repeat(_amo) {
					buffer_write(_b, buffer_f16, _til);
					buffer_write(_b, buffer_f16, 0);
					buffer_write(_b, buffer_f16, 0);
					buffer_write(_b, buffer_f16, bool(_til));
				}
			}
		}
		
		buffer_delete_safe(canvas_buffer);
		canvas_buffer  = _b;
		canvas_surface = surface_verify(canvas_surface, _w, _h, surface_rgba16float);
		buffer_set_surface(canvas_buffer, canvas_surface, 0);
    }
    
	////- Serialize
    
	static attributeSerialize = function() {
		var _attr = {
			canvas : surface_encode(canvas_surface),
			gm_key:  gmTileLayer == noone? noone : gmTileLayer.roomObject.key,
			gm_name: gmTileLayer == noone? noone : gmTileLayer.name,
		}
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		
		if(struct_has(attr, "gm_key") && project.bind_gamemaker) {
			var _room = project.bind_gamemaker.getResourceFromPath(attr.gm_key);
			var _name = attr[$ "gm_name"];
			if(_room != noone && !is_undefined(_name))
				bindTile(_room.getLayerFromName(_name));
		}
		
		if(struct_has(attr, "canvas")) {
			var _canv = attr.canvas;
		
			surface_free_safe(canvas_surface);
			canvas_surface = surface_decode(_canv);
			
			var _dim = surface_get_dimension(canvas_surface);
			buffer_delete_safe(canvas_buffer);
			canvas_buffer  = buffer_from_surface(canvas_surface, false, buffer_grow);
		}
		
	}

	////- Actions
	
	function resizeBBOX(bbox) {
		var _nw =  bbox[2] - bbox[0];
		var _nh =  bbox[3] - bbox[1];
		var _dx = -bbox[0];
		var _dy = -bbox[1];
		
		gmTileLayer.tiles.SerialiseWidth  = _nw;
		gmTileLayer.tiles.SerialiseHeight = _nh;
		
		var _newSurf = surface_create(_nw, _nh, surface_rgba16float);
		surface_set_target(_newSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(canvas_surface, _dx, _dy);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_free_safe(canvas_surface);
		canvas_surface = _newSurf;
		
		triggerRender();
	}
	
}