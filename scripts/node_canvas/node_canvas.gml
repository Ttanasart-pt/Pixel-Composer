function Node_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	setAlwaysTimeline(new timelineItemNode_Canvas(self));
	
	inputs[|  0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[|  1] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	inputs[|  2] = nodeValue("Brush size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	inputs[|  3] = nodeValue("Fill threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[|  4] = nodeValue("Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["4 connect", "8 connect", "Entire canvas"]);
	
	inputs[|  5] = nodeValue("Draw preview overlay", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[|  6] = nodeValue("Brush", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, false);
	
	inputs[|  7] = nodeValue("Surface amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	
	inputs[|  8] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1);
	
	inputs[|  9] = nodeValue("Background alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1.)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 10] = nodeValue("Render background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 11] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 12] = nodeValue("Frames animation", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 13] = nodeValue("Animation speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
	
	inputs[| 14] = nodeValue("Use background dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true );
	
	inputs[| 15] = nodeValue("Brush distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.range, { linked : true });
	
	inputs[| 16] = nodeValue("Rotate brush by direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 17] = nodeValue("Random direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.rotation_random);
	
	inputs[| 18] = nodeValue("Animation Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Loop", "Hold", "Clear" ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	frame_renderer_x     = 0;
	frame_renderer_x_to  = 0;
	frame_renderer_x_max = 0;
	
	frame_renderer_content = surface_create(1, 1);
	frame_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _full = true, _fx = frame_renderer_x) { #region frame_renderer
		var _h = _full? 64 : 48;
		var _anim  = getInputData(12);
		var _cnt_hover = false;
		
		if(_full) {
			_y += 8;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		}
		
		if(_hover && frame_renderer.parent != noone && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			frame_renderer.parent.scroll_lock = true;
			_cnt_hover = _hover;
		}
		
		var _pd = _full? ui(2) : 0;
		var _aw = ui(32);
		var _ww = _w - _pd - _aw;
		var _hh = _h - _pd - _pd;
		
		var _x0 = _x + _pd;
		var _y0 = _y + _pd;
		var _x1 = _x0 + _ww;
		var _y1 = _y0 + _hh;
		
		frame_renderer_x_max   = 0;
		frame_renderer_content = surface_verify(frame_renderer_content, _ww, _hh);
		surface_set_shader(frame_renderer_content);
			var _msx = _m[0] - _x0;
			var _msy = _m[1] - _y0;
			
			var _fr_h = _hh - 8;
			var _fr_w = _fr_h;
			
			var _fr_x = 4 - _fx;
			var _fr_y = 4;
			
			var surfs = output_surface;
			var _del  = noone;
			
			for( var i = 0, n = attributes.frames; i < n; i++ ) {
				var _surf = surfs[i];
				
				if(!is_surface(_surf)) continue;
				
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				
				var _ss = min(_fr_w / _sw, _fr_h / _sh);
				var _sx = _fr_x;
				var _sy = _fr_y + _fr_h / 2 - _sh * _ss / 2;
				
				var _ssw = _sw * _ss;
				var _ssh = _sh * _ss;
				
				draw_surface_ext(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
				draw_sprite_stretched_add(THEME.menu_button_mask, 1, _sx, _sy, _ssw, _ssh, i == preview_index? COLORS._main_accent : COLORS.panel_toolbar_outline, 1);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1)) {
					var _del_x = _sx + _fr_w  - 10;
					var _del_y = _sy          + 10;
					var _del_a = noone;
					
					if(key_mod_press(SHIFT) && point_in_circle(_msx, _msy, _del_x, _del_y, 8)) {
						_del_a = 1;
						
						if(mouse_press(mb_left, _focus)) 
							_del = i;
					} else if(point_in_rectangle(_msx, _msy, _sx, _sy, _sx + _ssw, _sy + _ssh)) {
						_del_a = 0;
						
						if(mouse_press(mb_left, _focus)) 
							setFrame(i);
					}
					
					if(_del_a != noone) {
						draw_sprite_ext(THEME.cross_12, 0, _del_x, _del_y, 1, 1, 0, c_white, .5 + _del_a * .5);
						draw_sprite_stretched_add(THEME.menu_button_mask, 1, _sx, _sy, _ssw, _ssh, c_white, .2);
					}
				}
				
				var _xw = _ssw + 4;
				_fr_x += _xw;
				frame_renderer_x_max += _xw;
			} 
			
			if(_del > noone) removeFrame(_del);
		surface_reset_shader();
		draw_surface(frame_renderer_content, _x0, _y0);
		
		frame_renderer_x_max = max(0, frame_renderer_x_max - 200);
		frame_renderer_x     = lerp_float(frame_renderer_x, frame_renderer_x_to, 3);
		
		if(_cnt_hover) {
			if(mouse_wheel_down()) frame_renderer_x_to = clamp(frame_renderer_x_to + 80, 0, frame_renderer_x_max);
			if(mouse_wheel_up())   frame_renderer_x_to = clamp(frame_renderer_x_to - 80, 0, frame_renderer_x_max);
		}
		
		var _bs = _aw - ui(8);
		var _bx = _x1 + _aw / 2 - _bs / 2;
		var _by = _y + _h / 2  - _bs / 2;
		
		if(buttonInstant(noone, _bx, _by, _bs, _bs, _m, _focus, _hover, "", THEME.add_16, 0, [ COLORS._main_icon, COLORS._main_value_positive ]) == 2) {
			attributes.frames++;
			refreshFrames();
			update();
		}
		
		return _h + 8 * _full;
		
	}).setNode(self); #endregion
	
	temp_surface = array_create(2);
	
	live_edit   = false;
	live_target = "";
	
	input_display_list = [ 
		["Output",	  false], 0, frame_renderer, 12, 18, 13, 
		["Brush",	   true], 6, 15, 17, 16, 
		["Background", true, 10], 8, 14, 9, 
	];
	
	#region ++++ data ++++
		attributes.frames = 1;
		attribute_surface_depth();
	
		attributes.dimension = [ 1, 1 ];
	
		output_surface   = [ surface_create_empty(1, 1) ];
		canvas_surface   = [ surface_create_empty(1, 1) ];
		canvas_buffer    = [ buffer_create(1 * 1 * 4, buffer_fixed, 2) ];
	
		drawing_surface  = surface_create_empty(1, 1);
		_drawing_surface = surface_create_empty(1, 1);
		surface_w = 1;
		surface_h = 1;
	
		prev_surface		  = surface_create_empty(1, 1);
		preview_draw_surface  = surface_create_empty(1, 1);
		preview_draw_mask     = surface_create_empty(1, 1);
		
		draw_stack = ds_list_create();
		
		attributes.show_slope_check = true;
		array_push(attributeEditors, "Display");
		array_push(attributeEditors, [ "Draw Guide", function() { return attributes.show_slope_check; }, new checkBox(function() { attributes.show_slope_check = !attributes.show_slope_check; }) ]);
	#endregion
	
	#region ++++ tool object ++++
		brush = new canvas_brush();
		
		tool_selection = new canvas_tool_selection();
		tool_selection.node = self;
		
		tool_brush     = new canvas_tool_brush(brush, false);
		tool_eraser    = new canvas_tool_brush(brush, true);
		tool_rectangle = new canvas_tool_shape(brush, CANVAS_TOOL_SHAPE.rectangle);
		tool_ellipse   = new canvas_tool_shape(brush, CANVAS_TOOL_SHAPE.ellipse);
		tool_fill      = new canvas_tool_fill(tool_attribute);
		tool_freeform  = new canvas_tool_draw_freeform(brush);
		tool_curve_bez = new canvas_tool_curve_bezier(brush);
		
		tool_sel_rectangle = new canvas_tool_selection_shape(tool_selection, CANVAS_TOOL_SHAPE.rectangle);
		tool_sel_ellipse   = new canvas_tool_selection_shape(tool_selection, CANVAS_TOOL_SHAPE.ellipse);
		tool_sel_freeform  = new canvas_tool_selection_freeform(tool_selection, brush);
		tool_sel_magic     = new canvas_tool_selection_magic(tool_selection, tool_attribute);
		tool_sel_brush     = new canvas_tool_selection_brush(tool_selection, brush);
		
	#endregion
	
	#region ++++ tools ++++
		tool_attribute.channel = [ true, true, true, true ];
		tool_channel_edit      = new checkBoxGroup(THEME.tools_canvas_channel, function(ind, val) { tool_attribute.channel[ind] = val; });
		
		tool_attribute.drawLayer = 0;
		tool_attribute.pickColor = c_white;
		tool_drawLayer_edit      = new buttonGroup( [ THEME.canvas_draw_layer, THEME.canvas_draw_layer, THEME.canvas_draw_layer ], function(val) { tool_attribute.drawLayer = val; })
										.setTooltips( [ "Draw on top", "Draw behind", "Draw inside" ] )
										.setCollape(false);
		
		tool_attribute.mirror = [ false, false, false ];
		tool_mirror_edit      = new checkBoxGroup( THEME.canvas_mirror, function(ind, val) { tool_attribute.mirror[ind] = val; })
										.setTooltips( [ "Toggle diagonal", "", "" ] );
		
		tool_settings          = [ [ "", tool_channel_edit,   "channel",   tool_attribute ], 
								   [ "", tool_drawLayer_edit, "drawLayer", tool_attribute ],
								   [ "", tool_mirror_edit,    "mirror",    tool_attribute ],
							   ];
		
		tool_attribute.size = 1;
		tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(val) { tool_attribute.size = max(1, round(val)); }).setSlidable(0.1, true, [ 1, 999999 ])
									.setFont(f_p3)
									.setSideButton(button(function() { dialogPanelCall(new Panel_Node_Canvas_Pressure(self), mouse_mx, mouse_my, { anchor: ANCHOR.top | ANCHOR.left }) })
										.setIcon(THEME.pen_pressure, 0, COLORS._main_icon));
		tool_size           = [ "Size", tool_size_edit, "size", tool_attribute ];
		
		tool_attribute.pressure      = false;
		tool_attribute.pressure_size = [ 1, 1 ];
		
		tool_attribute.thres	= 0;
		tool_thrs_edit      	= new textBox(TEXTBOX_INPUT.number, function(val) { tool_attribute.thres = clamp(val, 0, 1); }).setSlidable(0.01, false, [ 0, 1 ]).setFont(f_p3);
		tool_thrs           	= [ "Threshold", tool_thrs_edit, "thres", tool_attribute ];
		
		tool_attribute.fillType = 0;
		tool_fil8_edit      	= new buttonGroup( [ THEME.canvas_fill_type, THEME.canvas_fill_type, THEME.canvas_fill_type ], function(val) { tool_attribute.fillType = val; })
									.setTooltips( [ "Edge", "Edge + Corner", "Entire image" ] )
									.setCollape(false);
		tool_fil8           	= [ "Fill", tool_fil8_edit, "fillType", tool_attribute ];
		
		tool_attribute.button_apply = [ false, false ];
		tool_curve_apply  = button( function() { tool_curve_bez.apply();   } ).setIcon(THEME.toolbar_check, 0);
		tool_curve_cancel = button( function() { tool_curve_bez.cancel(); } ).setIcon(THEME.toolbar_check, 1);
		
		toolObject_selection_magic = new NodeTool( "Magic Selection", THEME.canvas_tools_magic_selection )
				.setSetting(tool_thrs)
				.setSetting(tool_fil8)
				.setToolObject(tool_sel_magic)
		
		tools = [
			new NodeTool( "Selection",	[ THEME.canvas_tools_selection_rectangle, THEME.canvas_tools_selection_circle, THEME.canvas_tools_freeform_selection, THEME.canvas_tools_selection_brush ])
				.setToolObject([ tool_sel_rectangle, tool_sel_ellipse, tool_sel_freeform, tool_sel_brush ]),
			
			toolObject_selection_magic,
			
			new NodeTool( "Pencil",		  THEME.canvas_tools_pencil)
				.setSetting(tool_size)
				.setToolObject(tool_brush),
			
			new NodeTool( "Eraser",		  THEME.canvas_tools_eraser)
				.setSetting(tool_size)
				.setToolObject(tool_eraser),
					
			new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect,  THEME.canvas_tools_rect_fill  ])
				.setSetting(tool_size)
				.setToolObject(tool_rectangle),
					
			new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ])
				.setSetting(tool_size)
				.setToolObject(tool_ellipse),
			
			new NodeTool( "Curve",		  THEME.canvas_tool_curve_icon)
				.setSetting(tool_size)
				.setSetting([ "", tool_curve_apply,  0, tool_attribute ])
				.setSetting([ "", tool_curve_cancel, 0, tool_attribute ])
				.setToolObject(tool_curve_bez),
			
			new NodeTool( "Freeform",	  THEME.canvas_tools_freeform)
				.setSetting(tool_size)
				.setToolObject(tool_freeform),
					
			new NodeTool( "Fill",		  THEME.canvas_tools_bucket)
				.setSetting(tool_thrs)
				.setSetting(tool_fil8)
				.setToolObject(tool_fill),
		];
	#endregion
	
	#region ++++ right tools ++++
		__action_rotate_90_cw  = method(self, function() { if(tool_selection.is_selected) tool_selection.rotate90cw()  else canvas_action_rotate(-90); });
		__action_rotate_90_ccw = method(self, function() { if(tool_selection.is_selected) tool_selection.rotate90ccw() else canvas_action_rotate( 90); });
		__action_flip_h        = method(self, function() { if(tool_selection.is_selected) tool_selection.flipH()       else canvas_action_flip(1); });
		__action_flip_v        = method(self, function() { if(tool_selection.is_selected) tool_selection.flipV()       else canvas_action_flip(0); });
		__action_add_node      = method(self, function(ctx) { dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx }); });
		__action_make_brush    = method(self, function() { 
			if(brush.brush_use_surface) {
				brush.brush_surface = noone;
				brush.brush_use_surface = false;
				return;
			}
			var _surf  = tool_selection.selection_surface;
			var _bsurf = surface_create(surface_get_width(_surf) + 2, surface_get_height(_surf) + 2);
			surface_set_target(_bsurf);
				DRAW_CLEAR
				draw_surface(_surf, 1, 1);
			surface_reset_target();
			brush.brush_use_surface = true;
			brush.brush_surface = _bsurf; 
			tool_selection.apply();
			
			PANEL_PREVIEW.tool_current = tools[2];
		});
		
		nodeTool        = noone;
		nodeToolPreview = new NodeTool( "Apply Node",	  THEME.canvas_tools_node, self ).setToolFn( __action_add_node )
								.setContext(self);
		
		rightTools_general = [ 
			nodeToolPreview,
			-1,
			new NodeTool( "Resize Canvas",	  THEME.canvas_resize ).setToolObject( new canvas_tool_resize() ),
			
			new NodeTool( [ "Rotate 90 CW", "Rotate 90 CCW" ],
				[ THEME.canvas_rotate_cw, THEME.canvas_rotate_ccw ] )
				.setToolFn( [ __action_rotate_90_cw, __action_rotate_90_ccw ] ),
			
			new NodeTool( [ "Flip H", "Flip V" ],
				[ THEME.canvas_flip_h, THEME.canvas_flip_v ] )
				.setToolFn( [ __action_flip_h, __action_flip_v ] ),
		];
		
		rightTools_selection = [ 
			/*  0 */ -1,
			/*  1 */ new NodeTool( "Make/Reset Brush", THEME.canvas_tools_pencil ).setToolFn( __action_make_brush ),
			/*  2 */ -1,
			/*  3 */ new NodeTool( "Outline", THEME.canvas_tools_outline ).setToolObject( new canvas_tool_outline() ),
			/*  4 */ new NodeTool( "Extrude", THEME.canvas_tools_extrude ).setToolObject( new canvas_tool_extrude() ),
			/*  5 */ new NodeTool( "Inset",   THEME.canvas_tools_inset   ).setToolObject( new canvas_tool_inset()   ),
			/*  6 */ new NodeTool( "Skew",    THEME.canvas_tools_skew    ).setToolObject( new canvas_tool_skew()   ),
			/*  7 */ new NodeTool( "Corner",  THEME.canvas_tools_corner  ).setToolObject( new canvas_tool_corner()   ),
		];
		
		rightTools_not_selection = [ 
			-1,
			new NodeTool( "Outline", THEME.canvas_tools_outline).setContext(self).setToolObject( new canvas_tool_with_selector(rightTools_selection[3]) ),
			new NodeTool( "Extrude", THEME.canvas_tools_extrude).setContext(self).setToolObject( new canvas_tool_with_selector(rightTools_selection[4]) ),
			new NodeTool( "Inset",   THEME.canvas_tools_inset  ).setContext(self).setToolObject( new canvas_tool_with_selector(rightTools_selection[5]) ),
			new NodeTool( "Skew",    THEME.canvas_tools_skew   ).setContext(self).setToolObject( new canvas_tool_with_selector(rightTools_selection[6]) ),
			new NodeTool( "Corner",  THEME.canvas_tools_corner ).setContext(self).setToolObject( new canvas_tool_with_selector(rightTools_selection[7]) ),
		];
		
		rightTools_brush = [ 
			-1,
			new NodeTool( "Make/Reset Brush", THEME.canvas_tools_pencil ).setToolFn( __action_make_brush ),
		];
		
		rightTools = rightTools_general;
		
		tool_brush.rightTools     = rightTools_brush;
		tool_eraser.rightTools    = rightTools_brush;
		tool_rectangle.rightTools = rightTools_brush;
		tool_ellipse.rightTools   = rightTools_brush;
		
		selection_tool_after = noone;
	#endregion
	
	static setFrame = function(frame) {
		var _anim  = getInputData(12);
		if(_anim) PROJECT.animator.setFrame(frame);
		else      preview_index = frame;
	}
	
	function setToolColor(color) { CURRENT_COLOR = color; }
	
	static drawTools = function(_mx, _my, xx, yy, tool_size, hover, focus) { #region
		var _sx0 = xx - tool_size / 2;
		var _sx1 = xx + tool_size / 2;
		var hh   = ui(8);
		
		yy += ui(4);
		draw_set_color(COLORS._main_icon_dark);
		draw_line_round(_sx0 + ui(8), yy, _sx1 - ui(8), yy, 2);
		yy += ui(4);
		
		var _cx = _sx0 + ui(8);
		var _cw = tool_size - ui(16);
		var _ch = ui(12);
		var _pd = ui(5);
		
		yy += ui(8);
		hh += ui(8);
		drawColor(CURRENT_COLOR, _cx, yy, _cw, _cw);
		draw_sprite_stretched_ext(THEME.palette_selecting, 0, _cx - _pd, yy - _pd, _cw + _pd * 2, _cw + _pd * 2, c_white, 1);
		
		if(point_in_rectangle(_mx, _my, _cx, yy, _cx + _cw, yy + _ch) && mouse_press(mb_left, focus))
			colorSelectorCall(CURRENT_COLOR, setToolColor);
		
		yy += _cw + ui(8);
		hh += _cw + ui(8);
		
		var _sel = noone;
		
		for( var i = 0, n = array_length(DEF_PALETTE); i < n; i++ ) {
			var _c = DEF_PALETTE[i];
			
			var ii = 0;
			if(i == 0)     ii = 4;
			if(i == n - 1) ii = 5;
			
			draw_sprite_stretched_ext(THEME.palette_mask, ii, _cx, yy, _cw, _ch, _c, 1);
			
			if(color_diff(_c, CURRENT_COLOR) <= 0) 
				_sel = [ _cx, yy ];
					
			if(hover && point_in_rectangle(_mx, _my, _cx, yy, _cx + _cw, yy + _ch)) {
				if(mouse_click(mb_left, focus))
					CURRENT_COLOR = _c;
			}
			
			yy += _ch;
			hh += _ch;
		}
		
		if(_sel != noone) 
			draw_sprite_stretched_ext(THEME.palette_selecting, 0, _sel[0] - _pd, _sel[1] - _pd, _cw + _pd * 2, _ch + _pd * 2, c_white, 1);
		
		return hh + ui(4);
	} #endregion
	
	static removeFrame = function(index = 0) { #region
		if(attributes.frames <= 1) return;
		
		if(preview_index == attributes.frames) 
			preview_index--;
		attributes.frames--;
		
		array_delete(canvas_surface, index, 1);
		array_delete(canvas_buffer,  index, 1);
		update();
	} #endregion
	
	static refreshFrames = function() { #region
		var fr   = attributes.frames;
		var _dim = attributes.dimension;
		
		if(array_length(canvas_surface) < fr) {
			for( var i = array_length(canvas_surface); i < fr; i++ )
				canvas_surface[i] = surface_create_empty(_dim[0], _dim[1]);
			
		} else {
			for( var i = fr; i < array_length(canvas_surface); i++ )
				surface_free_safe(canvas_surface[i]);
			array_resize(canvas_surface, fr);
		}
		
		if(array_length(canvas_buffer) < fr) {
			for( var i = array_length(canvas_buffer); i < fr; i++ )
				canvas_buffer[i] = buffer_create(1 * 1 * 4, buffer_fixed, 2);
				
		} else {
			for( var i = fr; i < array_length(canvas_buffer); i++ )
				buffer_delete_safe(canvas_buffer[i]);
				
			array_resize(canvas_buffer, fr);
		}
	} #endregion
	
	function getCanvasSurface(index = preview_index) { INLINE return array_safe_get_fast(canvas_surface, index); }
	
	function setCanvasSurface(surface, index = preview_index) { INLINE canvas_surface[index] = surface; }
	
	static storeAction = function() { #region
		
		var action = recordAction(ACTION_TYPE.custom, function(data) { 
			if(tool_selection.is_selected) tool_selection.apply();
			
			var _canvas = surface_clone(getCanvasSurface(data.index));
			
			if(is_surface(data.surface))
				setCanvasSurface(data.surface, data.index); 
			surface_store_buffer(data.index); 
			
			data.surface = _canvas;
		}, { surface: surface_clone(getCanvasSurface(preview_index)), tooltip: $"Modify canvas {preview_index}", index: preview_index });
		
	} #endregion
	
	static apply_surfaces = function() { #region
		for( var i = 0; i < attributes.frames; i++ )
			apply_surface(i);
	} #endregion
	
	function apply_surface(index = preview_index) { #region
		var _dim = attributes.dimension;
		var cDep = attrDepth();
		
		var _canvas_surface = getCanvasSurface(index);
		
		if(!surface_exists(_canvas_surface)) { // recover surface from bufffer in case of VRAM refresh
			setCanvasSurface(surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[index]), index);
			
		} else if(surface_get_width_safe(_canvas_surface) != _dim[0] || surface_get_height_safe(_canvas_surface) != _dim[1]) { // resize surface
			var _cbuff = array_safe_get_fast(canvas_buffer, index);
			buffer_delete_safe(_cbuff);
			
			canvas_buffer[index] = buffer_create(_dim[0] * _dim[1] * 4, buffer_fixed, 4);
			
			var _newCanvas = surface_create(_dim[0], _dim[1]);
			surface_set_target(_newCanvas);
				DRAW_CLEAR
				draw_surface(_canvas_surface, 0, 0);
			surface_reset_target();
			
			setCanvasSurface(_newCanvas, index);
			surface_free(_canvas_surface);
		}
		
		drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], cDep);
		surface_clear(drawing_surface);
	} #endregion
	
	static surface_store_buffers = function(index = preview_index) { #region
		for( var i = 0; i < attributes.frames; i++ )
			surface_store_buffer(i);
	} #endregion
	
	static surface_store_buffer = function(index = preview_index) { #region
		if(index >= attributes.frames) return;
		
		buffer_delete_safe(canvas_buffer[index]);
		
		var _canvas_surface = getCanvasSurface(index);
		if(!surface_exists(_canvas_surface)) return;
		
		surface_w = surface_get_width_safe(_canvas_surface);
		surface_h = surface_get_height_safe(_canvas_surface);
		canvas_buffer[index] = buffer_create(surface_w * surface_h * 4, buffer_fixed, 4);
		buffer_get_surface(canvas_buffer[index], _canvas_surface, 0);
		
		triggerRender();
		apply_surface(index);
	} #endregion
	
	static tool_pick_color = function(_x, _y) {
		tool_attribute.pickColor = tool_selection.is_selected?
				surface_get_pixel_ext(tool_selection.selection_surface, _x - tool_selection.selection_position[0], _y - tool_selection.selection_position[1]) : 
				surface_get_pixel_ext(getCanvasSurface(), _x, _y);
	}
	
	function apply_draw_surface(_applyAlpha = true) { #region
		var _can = getCanvasSurface();
		var _drw = drawing_surface;
		var _dim = attributes.dimension;
		var _tmp;
		
		if(tool_selection.is_selected) {
			
			var _tmp = surface_create(surface_get_width_safe(tool_selection.selection_mask), surface_get_width_safe(tool_selection.selection_mask));
			
			var _spx = tool_selection.selection_position[0];
			var _spy = tool_selection.selection_position[1];
			var _spw = tool_selection.selection_size[0];
			var _sph = tool_selection.selection_size[1];
			
			surface_set_target(_tmp);
				DRAW_CLEAR
				
				draw_surface(drawing_surface, -_spx, -_spy);
				
				BLEND_ALPHA
					if(tool_attribute.mirror[1]) draw_surface_ext_safe(drawing_surface, _spx * 2 + _spw - _spx, -_spy, -1, 1);
					if(tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, -_spx, _spy * 2 + _sph - _spy, 1, -1);
					if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, _spx * 2 + _spw - _spx, _spy * 2 + _sph - _spy, -1, -1);
				
				BLEND_MULTIPLY
					draw_surface(tool_selection.selection_mask, 0, 0);
				BLEND_NORMAL
			surface_reset_target();
			
			_can = tool_selection.selection_surface;
		} else {
			storeAction();
			
			var _tmp = surface_create(_dim[0], _dim[1]);
			
			surface_set_target(_tmp);
				DRAW_CLEAR
				BLEND_OVERRIDE
				
				draw_surface(drawing_surface, 0, 0);
				
				BLEND_ALPHA
					if(tool_attribute.mirror[0] == false) {
						if(tool_attribute.mirror[1]) draw_surface_ext_safe(drawing_surface, _dim[0], 0, -1, 1);
						if(tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, 0, _dim[1], 1, -1);
						if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, _dim[0], _dim[1], -1, -1);
					} else {
						if(tool_attribute.mirror[1]) draw_surface_ext_safe(drawing_surface, _dim[0], _dim[1], -1, 1, -90);
						if(tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface,       0,       0, -1, 1,  90);
						if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, _dim[0], _dim[1], 1, 1, 180);
					}
				BLEND_NORMAL
			surface_reset_target();
			
		}
		
		var _sw = surface_get_width_safe(_can);
		var _sh = surface_get_height_safe(_can);
		
		var _drawnSurface = surface_create(_sw, _sh);
		
		surface_set_shader(_drawnSurface, sh_canvas_apply_draw);
			shader_set_i("drawLayer", tool_attribute.drawLayer);
			shader_set_i("eraser",    isUsingTool("Eraser"));
			shader_set_f("channels",  tool_attribute.channel);
			shader_set_f("alpha",     _applyAlpha? _color_get_alpha(CURRENT_COLOR) : 1);
			shader_set_f("mirror",    tool_attribute.mirror);
			shader_set_color("pickColor", tool_attribute.pickColor, _color_get_alpha(tool_attribute.pickColor));
			
			shader_set_surface("back", _can);
			shader_set_surface("fore", _tmp);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _sw, _sh);
		surface_reset_shader();
		
		surface_free(_can);
		surface_clear(drawing_surface);
		
		surface_free(_tmp);
		
		if(tool_selection.is_selected) {
			tool_selection.selection_surface = _drawnSurface;
		} else {
			setCanvasSurface(_drawnSurface);
			surface_store_buffer();
		}
		
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(instance_exists(o_dialog_color_picker)) return;
		
		brush.node = self;
		brush.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		if(!tool_selection.is_selected && active && key_mod_press(ALT)) { #region color selector
			var dialog     = instance_create(0, 0, o_dialog_color_picker);
			dialog.onApply = setToolColor;
			dialog.def_c   = CURRENT_COLOR;
		} #endregion
		
		var _canvas_surface = getCanvasSurface();
		if(!surface_exists(_canvas_surface)) return;
		
		#region surfaces
			var _dim = attributes.dimension;
			_drawing_surface = surface_verify(_drawing_surface, _dim[0], _dim[1]);
			drawing_surface  = surface_verify( drawing_surface, _dim[0], _dim[1], attrDepth());
				
			surface_set_target(_drawing_surface); 
				DRAW_CLEAR
				draw_surface_safe(drawing_surface); 
			surface_reset_target();
			
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			prev_surface 		  = surface_verify(prev_surface,		  _dim[0], _dim[1]);
			preview_draw_surface  = surface_verify(preview_draw_surface,  _dim[0], _dim[1]);
			preview_draw_mask     = surface_verify(preview_draw_mask, _sw, _sh);
		#endregion
		
		#region tool
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = noone;
			
			rightTools = [];
			array_append(rightTools, rightTools_general);
			
			if(nodeTool != noone) 
				_tool = nodeTool;
				
			else if(_currTool != noone) {
				_tool = _currTool.getToolObject();
				
				if(_tool) {
					_tool.node = self;
					_tool = _tool.getTool();
					_tool.subtool = _currTool.selecting;
					array_append(rightTools, _tool.rightTools);
				}
			}
			
			tool_selection.drawing_surface    = drawing_surface;
			tool_selection._canvas_surface    = _canvas_surface;
			tool_selection.apply_draw_surface = apply_draw_surface;
			
			if(tool_selection.is_selected && !is_instanceof(_tool, canvas_tool_node)) {
				tool_selection.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				tool_mirror_edit.sprs = (!tool_selection.is_selected && tool_attribute.mirror[0])? THEME.canvas_mirror_diag : THEME.canvas_mirror;
				
				array_append(rightTools, rightTools_selection);
				
			} else
				array_append(rightTools, rightTools_not_selection);
			
			if(_tool && _tool.override) {
				_tool.node = self;
				_tool.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				
				_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				
				surface_set_shader(preview_draw_surface, noone);
					_tool.drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_shader();
				
				draw_surface_ext_safe(preview_draw_surface, _x, _y, _s);
				
				surface_set_shader(preview_draw_mask, noone);
					_tool.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_shader();
				
				shader_set(sh_brush_outline);
					shader_set_f("dimension", _sw, _sh);
					draw_surface_ext_safe(preview_draw_mask);
				shader_reset();
				
				_tool.drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				return;
			}
		
		#endregion
		
		var _alp = _color_get_alpha(CURRENT_COLOR);
		
		draw_set_color(isUsingTool("Eraser")? c_white : CURRENT_COLOR);
		draw_set_alpha(1);
		
		if(_tool) { #region tool step
			
			_tool.drawing_surface    = drawing_surface;
			_tool._canvas_surface    = _canvas_surface;
			
			_tool.apply_draw_surface = apply_draw_surface;
			_tool.brush              = brush;
			
			_tool.node = self;
			
			if(_tool.relative && tool_selection.is_selected) {
				_tool._canvas_surface = tool_selection.selection_surface;
				var _px = tool_selection.selection_position[0];
				var _py = tool_selection.selection_position[1];
				var _rx = _x + _px * _s;
				var _ry = _y + _py * _s;
				
				_tool.step(hover, active, _rx, _ry, _s, _mx, _my, _snx, _sny);
			} else 
				_tool.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			if(_tool.brush_resizable) { 
				if(hover && key_mod_press(CTRL)) {
					if(mouse_wheel_down()) tool_attribute.size = max( 1, tool_attribute.size - 1);
					if(mouse_wheel_up())   tool_attribute.size = min(64, tool_attribute.size + 1);
				}
				
				brush.sizing(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			} 
			
		} #endregion
		
		#region preview
			if(tool_selection.is_selected) tool_selection.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_tool) _tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			surface_set_shader(preview_draw_surface, noone,, BLEND.alpha);
				draw_surface_safe(_drawing_surface, 0, 0);
				
				if(tool_selection.is_selected) {
					var _spx = tool_selection.selection_position[0];
					var _spy = tool_selection.selection_position[1];
					var _spw = tool_selection.selection_size[0];
					var _sph = tool_selection.selection_size[1];
					
					if(tool_attribute.mirror[1]) draw_surface_ext_safe(_drawing_surface, _spx * 2 + _spw, 0, -1, 1);
					if(tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface, 0, _spy * 2 + _sph, 1, -1);
					if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface, _spx * 2 + _spw, _spy * 2 + _sph, -1, -1);
					
				} else {
					if(tool_attribute.mirror[0] == false) {
						if(tool_attribute.mirror[1]) draw_surface_ext_safe(_drawing_surface, _dim[0],       0, -1, 1);
						if(tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface,       0, _dim[1], 1, -1);
						if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface, _dim[0], _dim[1], -1, -1);
					} else {
						if(tool_attribute.mirror[1]) draw_surface_ext_safe(_drawing_surface, _dim[0], _dim[1], -1, 1, -90);
						if(tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface,       0,       0, -1, 1,  90);
						if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(_drawing_surface, _dim[0], _dim[1], 1, 1, 180);
					}
				}
				
				draw_set_color(CURRENT_COLOR);
				
				if(brush.brush_sizing) 
					canvas_draw_point_brush(brush, brush.brush_sizing_dx, brush.brush_sizing_dy);
				else if(_tool)
					_tool.drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
					
				draw_set_alpha(1);
			surface_reset_shader();
				
			draw_surface_ext_safe(preview_draw_surface, _x, _y, _s, _s, 0, isUsingTool("Eraser")? c_red : c_white, isUsingTool("Eraser")? .2 : _alp);
			
			surface_set_target(preview_draw_mask);
				DRAW_CLEAR
				if(tool_selection.is_selected) tool_selection.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				if(_tool) _tool.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			surface_reset_target();
			
			shader_set(sh_brush_outline);
				shader_set_f("dimension", _sw, _sh);
				draw_surface_ext_safe(preview_draw_mask, 0, 0, 1, 1, 0, c_white, 1);
			shader_reset();
			
			draw_set_color(COLORS._main_accent);
			if(tool_selection.is_selected) {
				var _spx = tool_selection.selection_position[0];
				var _spy = tool_selection.selection_position[1];
				var _spw = tool_selection.selection_size[0];
				var _sph = tool_selection.selection_size[1];
				
				var _x0 = _x + _spx * _s;
				var _x1 = _x + (_spx + _spw) * _s;
				var _xc = _x + (_spx + _spw / 2) * _s;
				
				var _y0 = _y + _spy * _s;
				var _y1 = _y + (_spy + _sph) * _s;
				var _yc = _y + (_spy + _sph / 2) * _s;
				
				if(tool_attribute.mirror[1]) draw_line(_xc, _y0, _xc, _y1);
				if(tool_attribute.mirror[2]) draw_line(_x0, _yc, _x1, _yc);
				
			} else {
				var _x0 = _x;
				var _x1 = _x + _dim[0] * _s;
				var _xc = _x + _dim[0] / 2 * _s;
				
				var _y0 = _y;
				var _y1 = _y + _dim[1] * _s;
				var _yc = _y + _dim[1] / 2 * _s;
				
				if(tool_attribute.mirror[0] == false) {
					if(tool_attribute.mirror[1]) draw_line(_xc, _y0, _xc, _y1);
					if(tool_attribute.mirror[2]) draw_line(_x0, _yc, _x1, _yc);
				} else {
					if(tool_attribute.mirror[1]) draw_line(_x0, _y1, _x1, _y0);
					if(tool_attribute.mirror[2]) draw_line(_x0, _y0, _x1, _y1);
				}
			}
			
			if(_tool) _tool.drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		#endregion
		
		var _x0 = _x;
		var _y0 = _y;
		var _x1 = _x0 + _dim[0] * _s;
		var _y1 = _y0 + _dim[1] * _s;
		
		draw_set_color(COLORS.panel_preview_surface_outline);
		draw_rectangle(_x0, _y0, _x1 - 1, _y1 - 1, true);
		draw_set_alpha(1);
		
		#region hotkeys
			if(key_press(ord("C"), MOD_KEY.ctrl) && tool_selection.is_selected) {
				tool_selection.copySelection();
				tool_selection.apply();
			}
			
			if(key_press(ord("V"), MOD_KEY.ctrl) && (_tool == noone || !_tool.mouse_holding)) {
				var _str = json_try_parse(clipboard_get_text(), noone);
				
				if(is_struct(_str) && struct_has(_str, "buffer")) {
					var _surf = surface_decode(_str);
					
					if(surface_exists(_surf)) {
						tool_selection.createSelectionFromSurface(_surf);
						surface_free(_surf);
						
						if(key_mod_press(SHIFT)) {
							var _sel_pos = struct_try_get(_str, "position", [ 0, 0 ]);
							if(is_array(_sel_pos) && array_length(_sel_pos) == 2)
								tool_selection.selection_position = _sel_pos;
						}
					}
				}
			}
			
			if(key_press(ord("A"), MOD_KEY.ctrl)) {
				if(tool_selection.is_selected) tool_selection.apply();
				tool_selection.selectAll();
			}
		#endregion
		
		if(DRAGGING && hover&& mouse_release(mb_left)) { #region drag n drop
			if(DRAGGING.type == "Color") {
				var mouse_cur_x = round((_mx - _x) / _s - 0.5);
				var mouse_cur_y = round((_my - _y) / _s - 0.5);
				var _filType    = tool_attribute.fillType;
				var _filThres   = tool_attribute.thres;
				
				storeAction();
				surface_set_target(_canvas_surface);
					switch(_filType) {
						case 0 : 
						case 1 : canvas_flood_fill_scanline(_canvas_surface, mouse_cur_x, mouse_cur_y, _filThres, _filType); break;
						case 2 : canvas_flood_fill_all(     _canvas_surface, mouse_cur_x, mouse_cur_y, _filThres); break;
					}
				surface_reset_target();
				surface_store_buffer();
			}
		} #endregion
		
	} #endregion
	
	static step = function() { #region
		var fram  = attributes.frames;
		var brush = getInputData(6);
		var anim  = getInputData(12);
		
		inputs[| 15].setVisible(is_surface(brush));
		inputs[| 16].setVisible(is_surface(brush));
		
		update_on_frame = fram > 1 && anim;
		
		if(update_on_frame) {
			var anims = getInputData(13);
			var atype = getInputData(18);
			
			if(atype == 0)  preview_index = safe_mod(CURRENT_FRAME * anims, fram);
			else			preview_index = min(CURRENT_FRAME * anims, fram - 1);
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _dim   = getInputData(0);
		var _bg    = getInputData(8);
		var _bga   = getInputData(9);
		var _bgr   = getInputData(10);
		var _anim  = getInputData(12);
		var _anims = getInputData(13);
		var _bgDim = getInputData(14);
		var _atype = getInputData(18);
		
		var cDep   = attrDepth();
		
		if(_bgDim) {
			var _bgDim = _bg;
			if(is_array(_bgDim) && !array_empty(_bgDim)) _bgDim = _bg[0];
			if(is_surface(_bgDim)) _dim = surface_get_dimension(_bgDim);
		}
		attributes.dimension = _dim;
		apply_surfaces();
		
		var _frames  = attributes.frames;
		
		if(!is_array(output_surface)) output_surface = array_create(_frames);
		else if(array_length(output_surface) != _frames)
			array_resize(output_surface, _frames);
		
		if(_frames == 1) {
			var _canvas_surface = getCanvasSurface(0);
			if(is_array(_bg) && !array_empty(_bg)) _bg = _bg[0];
			
			output_surface[0]   = surface_verify(output_surface[0], _dim[0], _dim[1], cDep);
			
			surface_set_shader(output_surface[0], noone,, BLEND.alpha);
				if(_bgr && is_surface(_bg))
					draw_surface_stretched_ext(_bg, 0, 0, _dim[0], _dim[1], c_white, _bga);
				draw_surface_safe(_canvas_surface, 0, 0);
			surface_reset_shader();
			
			outputs[| 0].setValue(output_surface[0]);
		} else {
			for( var i = 0; i < _frames; i++ ) {
				var _canvas_surface = getCanvasSurface(i);
				var _bgArray        = is_array(_bg)? array_safe_get_fast(_bg, i, 0) : _bg;
				output_surface[i]   = surface_verify(output_surface[i], _dim[0], _dim[1], cDep);
				
				surface_set_shader(output_surface[i], noone,, BLEND.alpha);
					if(_bgr && is_surface(_bgArray))
						draw_surface_stretched_ext(_bgArray, 0, 0, _dim[0], _dim[1], c_white, _bga);
					draw_surface_safe(_canvas_surface, 0, 0);
				surface_reset_shader();
			}
			
			temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], cDep);
			surface_clear(temp_surface[1]);
			
			if(_anim) {
				var _fr_index = CURRENT_FRAME * _anims;
				switch(_atype) {
					case 0 : _fr_index = safe_mod(_fr_index, _frames);				break;
					case 1 : _fr_index = min(_fr_index, _frames - 1);				break;
					case 2 : _fr_index = _fr_index < _frames? _fr_index : noone;	break;
				}
				
				outputs[| 0].setValue(_fr_index == noone? temp_surface[1] : output_surface[_fr_index]);
				
			} else
				outputs[| 0].setValue(output_surface);
		}
		
		if(live_edit) {
			if(!is_struct(PANEL_FILE)) return;
			
			var _fileO = PANEL_FILE.file_focus;
			if(_fileO == noone) return;
			
			var path = _fileO.path;
			if(path == "") return;
			
			surface_save(getCanvasSurface(0), path);
			_fileO.refreshThumbnail();
		}
		
	} #endregion
	
	static doSerialize = function(_map) { #region
		surface_store_buffers();
		var _buff = array_create(attributes.frames);
		
		for( var i = 0; i < attributes.frames; i++ ) {
			var comp = buffer_compress(canvas_buffer[i], 0, buffer_get_size(canvas_buffer[i]));
			_buff[i] = buffer_base64_encode(comp, 0, buffer_get_size(comp));
		}
			
		_map.surfaces = _buff;
	} #endregion
	
	static doApplyDeserialize = function() { #region
		var _dim     = struct_has(attributes, "dimension")? attributes.dimension : getInputData(0);
		
		if(!struct_has(load_map, "surfaces")) {
			if(struct_has(load_map, "surface")) {
				var buff = buffer_base64_decode(load_map.surface);
				
				canvas_buffer[0]  = buffer_decompress(buff);
				canvas_surface[0] = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[0]);
			}
			return;
		}
		
		canvas_buffer  = array_create(array_length(load_map.surfaces));
		canvas_surface = array_create(array_length(load_map.surfaces));
		
		for( var i = 0, n = array_length(load_map.surfaces); i < n; i++ ) {
			var buff = buffer_base64_decode(load_map.surfaces[i]);
			
			canvas_buffer[i]  = buffer_decompress(buff);
			canvas_surface[i] = surface_create_from_buffer(_dim[0], _dim[1], canvas_buffer[i]);
		}
		
		apply_surfaces();
	} #endregion
	
	static onCleanUp = function() { #region
		surface_array_free(canvas_surface);
	} #endregion
	
	///////////////////////////////////
	
	on_drop_file = function(path) { #region
		loadImagePath(path);
		return true;
	} #endregion
	
	static loadImagePath = function(path) { #region
		if(!file_exists_empty(path)) return noone;
		
		var _spr = sprite_add(path, 0, 0, 0, 0, 0);
		if(_spr == -1) return noone;
		
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		
		var _s  = surface_create(_sw, _sh);
		surface_set_shader(_s, noone)
			draw_sprite(_spr, 0, 0, 0);
		surface_reset_shader();
		
		sprite_delete(_spr);
		
		attributes.dimension = [_sw, _sh];
		inputs[| 0].setValue([_sw, _sh]);
		setCanvasSurface(_s);
		surface_store_buffer();
		
		live_edit   = true;
		live_target = path;
	
		return self;
	} #endregion 
	
	static dropPath = function(path) {
		if(!file_exists_empty(path)) return noone;
		
		if(tool_selection.is_selected)
			tool_selection.apply();
		
		var _spr = sprite_add(path, 0, 0, 0, 0, 0);
		if(_spr == -1) return noone;
		
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		
		var surf = surface_create(_sw, _sh);
		surface_set_shader(surf, noone);
			draw_sprite(_spr, 0, 0, 0);
		surface_reset_shader();
		
		sprite_delete(_spr);
		
		tool_selection.createSelectionFromSurface(surf);
		surface_free(surf);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function timelineItemNode_Canvas(node) : timelineItemNode(node) constructor {
	
	static drawDopesheet = function(_x, _y, _s, _msx, _msy) {
		if(!is_instanceof(node, Node_Canvas)) return;
		if(!node.attributes.show_timeline) return;
		
	}
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is_instanceof(node, Node_Canvas)) return;
		if(!node.attributes.show_timeline) return;
		
		var _surfs = node.output_surface;
		var _surf, _rx, _ry;
		var _rx0, _ry0;
		var _h = h - 2;
		
		_ry  = _h / 2 + _y;
		_ry0 = _y;
		
		var _chv = _hover && _msy > _ry0 && _msy <= _ry0 + h;
		var _hov = false;
		
		for (var i = 0, n = array_length(_surfs); i < n; i++) {
			_surf = _surfs[i];
			if(!surface_exists(_surf)) continue;
			
			_rx  = _x + (i + 1) * _s;
			_rx0 = _rx - _h / 2;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			var _ss = _h / max(_sw, _sh);
			
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _rx0, _ry0, _h, _h, CDEF.main_dkblack);
			
			if(i == node.preview_index) {
				draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
				draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _rx0, _ry0, _h, _h, COLORS._main_accent);
				
			} else {
				draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, 0.1);
				draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _rx0, _ry0, _h, _h, COLORS._main_icon, 0.3);
			}
			
			if(_hover && point_in_rectangle(_msx, _msy, _rx0, _ry0, _rx0 + _h, _ry0 + _h)) {
				draw_sprite_stretched_add(THEME.menu_button_mask, 1, _rx0, _ry0, _h, _h, c_white, 0.3);
				_hov = true;
				
				if(mouse_press(mb_left, _focus))
					node.setFrame(i);
			}
		}
		
		if(!_hov && _chv) {
			var _fr = round((_msx - _x) / _s);
			if(_fr < 1 || _fr > TOTAL_FRAMES) return _hov;
			
			_rx  = _x + _fr * _s;
			_rx0 = _rx - _h / 2;
			
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, _rx0, _ry0, _h, _h, CDEF.main_dkblack);
			draw_sprite_stretched_ext(THEME.menu_button_mask, 1, _rx0, _ry0, _h, _h, COLORS._main_value_positive, 0.75);
			
			if(mouse_press(mb_left, _focus)) {
				node.attributes.frames = _fr;
				node.refreshFrames();
				node.update();
				
				node.setFrame(_fr - 1);
			}
			
			return true;
		}
		
		return _hov;
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Canvas";
	}
}