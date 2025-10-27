#region 
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Canvas", "Selection",       "S");
		hotkeyCustom("Node_Canvas", "Magic Selection", "W");
		hotkeyCustom("Node_Canvas", "Pencil",          "B");
		hotkeyCustom("Node_Canvas", "Eraser",          "E");
		hotkeyCustom("Node_Canvas", "Rectangle",       "N");
		hotkeyCustom("Node_Canvas", "Ellipse",         "M");
		hotkeyCustom("Node_Canvas", "Iso Cube",        "");
		hotkeyCustom("Node_Canvas", "Curve",           "");
		hotkeyCustom("Node_Canvas", "Freeform",        "Q");
		hotkeyCustom("Node_Canvas", "Fill",            "G");
		hotkeyCustom("Node_Canvas", "Gradient",        "G", MOD_KEY.shift);
		
		hotkeyCustom("Node_Canvas", "Outline",         "O", MOD_KEY.alt);
		hotkeyCustom("Node_Canvas", "Extrude",         "E", MOD_KEY.alt);
		hotkeyCustom("Node_Canvas", "Inset",           "I", MOD_KEY.alt);
		hotkeyCustom("Node_Canvas", "Skew",            "S", MOD_KEY.alt);
		hotkeyCustom("Node_Canvas", "Corner",          "C", MOD_KEY.alt);
		
		hotkeyCustom("Node_Canvas", "Resize Canvas",   "");
		// hotkeyCustom("Node_Canvas", "Rotate 90 CW",    "");
		// hotkeyCustom("Node_Canvas", "Rotate 90 CCW",   "");
		// hotkeyCustom("Node_Canvas", "Flip H",          "");
		// hotkeyCustom("Node_Canvas", "Flip V",          "");
		
		hotkeyCustom("Node_Canvas", "New Frame",       "N", MOD_KEY.alt);
		hotkeyCustom("Node_Canvas", "Select All",      "A", MOD_KEY.ctrl);
		hotkeyCustom("Node_Canvas", "Copy Selection",  "C", MOD_KEY.ctrl);
		hotkeyCustom("Node_Canvas", "Paste",           "V", MOD_KEY.ctrl);
		hotkeyCustom("Node_Canvas", "Paste at Cursor", "V", MOD_KEY.ctrl | MOD_KEY.shift);
	});
#endregion 

function Node_Canvas(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Canvas";
	color	= COLORS.node_blend_canvas;
	preview_select_surface = false;
	setAlwaysTimeline(new timelineItemNode_Canvas(self));
	
	////- =Frames
	newInput( 0, nodeValue_Dimension());
	
	////- =Output
	newInput(12, nodeValue_Enum_Scroll( "Output Type",  1, [ "Array", "Animation", "Outputs" ] ));
	newInput( 5, nodeValue_Bool(    "Auto Frame",       true ));
	newInput( 7, nodeValue_Int(     "Frame Index",      0    ));
	newInput(13, nodeValue_Float(   "Animation Speed",  1    ));
	newInput(18, nodeValue_EScroll( "On End",           0, [ "Loop", "Hold", "Clear" ]));
	
	////- =Brush
	newInput( 6, nodeValue_Surface(         "Brush" )).setVisible(true, false);
	newInput(15, nodeValue_Range(           "Brush Distance",            [1,1], { linked : true } ));
	newInput(17, nodeValue_Rotation_Random( "Random Direction",          [0,0,0,0,0]  ));
	newInput(16, nodeValue_Bool(            "Rotate Brush by Direction", false        ));
	
	////- =Background
	newInput(10, nodeValue_Bool(    "Render Background",        true     ));
	newInput( 4, nodeValue_EScroll( "Background Type",          0, ["Surface", "Solid Color"] ));
	newInput( 1, nodeValue_Color(   "Background Color",         ca_black ));
	newInput( 8, nodeValue_Surface( "Background"                         ));
	newInput(14, nodeValue_Bool(    "Use Background Dimension", true     ));
	newInput( 9, nodeValue_Slider(  "Background Alpha",         1        ));
	
	////- =Data Transfer
	newInput(19, nodeValue_Surface( "Data Source" ));
	newInput(20, nodeValue_Bool(    "Transfer Dimension", true ));
	
	/* deprecated */ newInput( 2, nodeValue_ISlider( "Brush Size",     1, [1,32,.1] ));
	/* deprecated */ newInput( 3, nodeValue_Slider(  "Fill Threshold", 0            ));
	/* deprecated */ newInput(11, nodeValue_Slider(  "Alpha",          1            ));
	
	// input 21
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Display
	
	frame_renderer_x     = 0;
	frame_renderer_x_to  = 0;
	frame_renderer_x_max = 0;
	frame_dragging       = noone;
	frame_selecting      = noone;
	
	menu_frame = [
		menuItem(__txt("Duplicate"), function() /*=>*/ { 
			var _dup_surf = surface_clone(canvas_surface[frame_selecting]);
			var _dup_buff = buffer_from_surface(_dup_surf, false);
			
			array_insert(canvas_surface, frame_selecting, _dup_surf);
			array_insert(canvas_buffer,  frame_selecting, _dup_buff);
			
			attributes.frames++;
			refreshFrames();
			update();
			
		}, THEME.duplicate),
		menuItem(__txt("Delete"),    function() /*=>*/ { removeFrame(frame_selecting); }, THEME.cross),
	];
	
	frame_renderer_content = noone;
	frame_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone, _full = true, _fx = frame_renderer_x) {
		var _h     = _full? 64 : 48;
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
		var _frame_hovering = noone;
		
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
				var _surf = array_safe_get(surfs, i);
				if(!is_surface(_surf)) continue;
				
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				
				var _ss = min(_fr_w / _sw, _fr_h / _sh);
				var _sx = _fr_x;
				var _sy = _fr_y + _fr_h / 2 - _sh * _ss / 2;
				
				var _ssw = _sw * _ss;
				var _ssh = _sh * _ss;
				
				draw_surface_ext(_surf, _sx, _sy, _ss, _ss, 0, c_white, 1);
				draw_sprite_stretched_add(THEME.box_r2, 1, _sx, _sy, _ssw, _ssh, i == preview_index? COLORS._main_accent : COLORS.panel_toolbar_outline, 1);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1)) {
					var _del_x = _sx + _fr_w  - 10;
					var _del_y = _sy          + 10;
					var _del_a = noone;
					
					if(key_mod_press(SHIFT) && point_in_circle(_msx, _msy, _del_x, _del_y, 8)) {
						_del_a = 1;
						
						if(mouse_press(mb_left, _focus)) 
							_del = i;
							
					} else if(point_in_rectangle(_msx, _msy, _sx, _sy, _sx + _ssw, _sy + _ssh)) {
						_frame_hovering = i;
						draw_sprite_stretched_add(THEME.box_r2, 1, _sx, _sy, _ssw, _ssh, c_white, .2);
						
						if(mouse_press(mb_left, _focus)) {
							setFrame(i);
							frame_dragging  = i;
							frame_selecting = i;
						}
							
						if(mouse_press(mb_right, _focus))  {
							frame_selecting = i;
							menuCall("node_canvas_frame", menu_frame);
						}
					}
					
					if(_del_a != noone) {
						draw_sprite_ui(THEME.cross_12, 0, _del_x, _del_y, 1, 1, 0, c_white, .5 + _del_a * .5);
					}
				}
				
				if(_focus && i == preview_index) {
					if(key_press(vk_delete)) _del = i;
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
		
		if(_cnt_hover && MOUSE_WHEEL != 0)
			frame_renderer_x_to = clamp(frame_renderer_x_to - 80 * MOUSE_WHEEL, 0, frame_renderer_x_max);
		
		var _bs = _aw - ui(8);
		var _bx = _x1 + _aw / 2 - _bs / 2;
		var _by = _y + _h / 2  - _bs / 2;
		
		if(buttonInstant(noone, _bx, _by, _bs, _bs, _m, _hover, _focus, "", THEME.add_16, 0, [ COLORS._main_icon, COLORS._main_value_positive ]) == 2)
			addFrame(true);
		
		if(frame_dragging != noone) {
			
			if(_frame_hovering != noone && _frame_hovering != frame_dragging) {
				var _dup_surf = canvas_surface[frame_dragging];
				var _dup_buff = canvas_buffer[frame_dragging];
				
				array_delete(canvas_surface, frame_dragging, 1);
				array_delete(canvas_buffer,  frame_dragging, 1);
				
				array_insert(canvas_surface, _frame_hovering, _dup_surf);
				array_insert(canvas_buffer,  _frame_hovering, _dup_buff);
				
				frame_dragging = _frame_hovering;
				
				setFrame(frame_dragging);
				refreshFrames();
				update();
			}
			
			if(mouse_release(mb_left))
				frame_dragging = noone;
		}
		
		return _h + 8 * _full;
		
	}).setNode(self);
	
	b_transferData = button(function() /*=>*/ {return transferData()}).setIcon(THEME.arrow, 0, COLORS._main_value_positive);
	
	input_display_list = [ 
		["Frames",       false    ],  0, frame_renderer, 
		["Output",       false,   ], 12,  5,  7, 13, 18, 
		["Background",    true, 10],  4,  1,  8, 14,  9, 
		["Brush",         true    ],  6, 15, 17, 16, 
		["Data Transfer", true, noone, b_transferData], 19, 20, button(function() /*=>*/ {return transferData()}).setText("Transfer Data"), 
	];
	
	////- Nodes
	
	temp_surface = array_create(2);
	
	live_edit   = false;
	live_target = "";
	output_pool = [];
	
	#region ++++ data ++++
		attributes.frames = 1;
		attribute_surface_depth();
	
		attributes.useBGDim  = false;
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
		preview_draw_tile     = surface_create_empty(1, 1);
		preview_draw_mask     = surface_create_empty(1, 1);
		preview_draw_final    = [ 0, 0 ];
		
		draw_stack = ds_list_create();
		
		attributes.show_slope_check = true;
		array_push(attributeEditors, "Display");
		array_push(attributeEditors, [ "Draw Guide", function() /*=>*/ {return attributes.show_slope_check}, new checkBox(function() /*=>*/ {return toggleAttribute("show_slope_check")}) ]);
	#endregion
	
	////- Tools
	
	#region ++++ tool object ++++
		brush     = new canvas_brush();
		selection = new canvas_selection().setNode(self);
		
		tool_brush          = new canvas_tool_brush(brush, false).setNode(self);
		tool_eraser         = new canvas_tool_brush(brush, true).setNode(self);
		tool_rectangle      = new canvas_tool_shape(brush, CANVAS_TOOL_SHAPE.rectangle).setNode(self);
		tool_ellipse        = new canvas_tool_shape(brush, CANVAS_TOOL_SHAPE.ellipse).setNode(self);
		tool_iso_cube       = new canvas_tool_shape_iso(brush, CANVAS_TOOL_SHAPE_ISO.cube, tool_attribute).setNode(self);
		
		tool_fill           = new canvas_tool_fill(tool_attribute);
		tool_fill_grad      = new canvas_tool_fill_gradient(tool_attribute);
		
		tool_freeform       = new canvas_tool_draw_freeform(brush);
		tool_curve_bez      = new canvas_tool_curve_bezier(brush);
		
		tool_sel_rectangle  = new canvas_tool_selection_shape(selection, CANVAS_TOOL_SHAPE.rectangle);
		tool_sel_ellipse    = new canvas_tool_selection_shape(selection, CANVAS_TOOL_SHAPE.ellipse);
		tool_sel_freeform   = new canvas_tool_selection_freeform(selection, brush);
		tool_sel_magic      = new canvas_tool_selection_magic(selection, tool_attribute);
		tool_sel_brush      = new canvas_tool_selection_brush(selection, brush);
		
		use_color_3d        = false;
		color_3d_selected   = 0;
		
		mouse_cur_x = 0;
		mouse_cur_y = 0;
	#endregion
	
	#region ++++ tools ++++
		palette_picking = false;
		color_picking   = false;
		
		tool_attribute.channel       = [ true, true, true, true ];
		tool_attribute.mirror        = [ false, false, false ];
		tool_attribute.drawLayer     = 0;
		tool_attribute.pickColor     = c_white;
		
		tool_attribute.size          = 1;
		tool_attribute.pressure      = false;
		tool_attribute.pressure_size = [ 1, 1 ];
		
		tool_attribute.thres	     = 0;
		tool_attribute.fillType      = 0;
		tool_attribute.useBG         = true;
		tool_attribute.iso_angle     = 0;
		tool_attribute.button_apply  = [ false, false ];
		
		tool_attribute.dither        = 0;
		
		tool_attribute.pattern       = 2;
		tool_attribute.pattern_inten = 1;
		tool_attribute.pattern_scale = [ 1, 1 ];
		tool_attribute.pattern_pos   = [ 0, 0 ];
		tool_attribute.pattern_mod   = 4;

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tool_pattern      = new canvas_tool_pattern(tool_attribute);
		tool_pattern.node = self;
		
		fill_pattern_data = [ "Solid", 
	           -1, "Stripe X", "Stripe Y", "Stripe D0", "Stripe D1",  
	           -1, "Checker", "Checker Diag", 
	           -1, "Grid", "Grid Diag",    
	           -1, "Half X", "Half Y", "Half D0", "Half D1", 
	           -1, "Grad X", "Grad Y", "Grad D0", "Grad D1",
	           -1, "Grad Both X", "Grad Both Y", "Grad Both D0", "Grad Both D1",
	           -1, "Grad Circular", "Grad Radial", 
	           -1, "Brick X", "Brick Y",
	           -1, "Zigzag X", "Zigzag Y", "Half Zigzag X", "Half Zigzag Y", 
	           -1, "Half Wave X", "Half Wave Y", 
	           -1, "Noise", 
		];
	    fill_pattern_scroll_data = array_create_ext(array_length(fill_pattern_data), 
	    	function(i) /*=>*/ {return fill_pattern_data[i] == -1? -1 : new scrollItem(fill_pattern_data[i], s_node_pb_pattern, i)});
	    
		tool_pattern_type = new scrollBox(fill_pattern_scroll_data, function(v) /*=>*/ { tool_attribute.pattern = v; })
								.setHorizontal(true)
								.setMinWidth(ui(128));
								
		tool_pattern_intn = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { tool_attribute.pattern_inten = clamp(v, 0, 1); })
									.setSlideRange(0, 1)
									
		tool_pattern_scal = new vectorBox(2, function(v,i) /*=>*/ { tool_attribute.pattern_scale[i] = round(v); });
		
		tool_pattern_modi = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { tool_attribute.pattern_mod = round(v); });
		
		tool_pattern_settings = [
			// () => tool_pattern.prev_surface,
			[ "", tool_pattern_type, "pattern",       tool_attribute  ],
			[ THEME.tool_intensity, tool_pattern_intn, "pattern_inten", tool_attribute, "Intensity" ],
			[ THEME.tool_scale,     tool_pattern_scal, "pattern_scale", tool_attribute, "Scale"     ],
			[ THEME.tool_poster,    tool_pattern_modi, "pattern_mod",   tool_attribute, "Modifier"  ],
		];
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tool_channel_edit   = new checkBoxGroup(THEME.tools_canvas_channel, function(v,i) /*=>*/ { tool_attribute.channel[i] = v; });
		
		tool_drawLayer_edit = new buttonGroup( array_create(3, THEME.canvas_draw_layer), function(v) /*=>*/ { tool_attribute.drawLayer = v; })
									.setTooltips( [ "Draw on top", "Draw behind", "Draw inside" ] )
									.setCollape(false);
		
		tool_mirror_edit    = new checkBoxGroup( THEME.canvas_mirror, function(v,i) /*=>*/ { tool_attribute.mirror[i] = v; })
									.setTooltips( [ "Mirror diagonal", "Mirror", "Mirror" ] );
		
		tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { tool_attribute.size = max(1, round(v)); })
									.setSlideType(true)
									.setVAlign(fa_center)
									.setFont(f_p3)
									.setSideButton(button(function() /*=>*/ { dialogPanelCall(new Panel_Node_Canvas_Pressure(self), mouse_mx, mouse_my, { anchor: ANCHOR.top | ANCHOR.left }) })
										.setTooltip("Pen Pressure Settings...")
										.setIcon(THEME.pen_pressure, 0, COLORS._main_icon), true);
		
		tool_thrs_edit      = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { tool_attribute.thres = clamp(v, 0, 1); })
									.setSlideRange(0, 1)
									.setVAlign(fa_center)
									.setFont(f_p3);
		
		tool_fil8_edit      = new buttonGroup( array_create(3, THEME.canvas_fill_type), function(v) /*=>*/ { tool_attribute.fillType = v; })
									.setTooltips( [ "Edge", "Edge + Corner", "Entire image" ] )
									.setCollape(false);
		
		tool_fill_use_bg    = new checkBox( function() /*=>*/ { tool_attribute.useBG = !tool_attribute.useBG; });
		
		tool_curve_buttons  = new buttonGroup( array_create(2, THEME.toolbar_check), function(v) /*=>*/ { if(v == 0) tool_curve_bez.apply(); else tool_curve_bez.cancel(); })
									.setCollape(false);
		
		tool_isoangle       = new buttonGroup( array_create(2, THEME.canvas_iso_angle), function(v) /*=>*/ { tool_attribute.iso_angle = v; })
									.setTooltips( [ "2:1", "1:1" ] )
									.setCollape(false);
		
		tool_dither         = new buttonGroup( array_create(4, THEME.canvas_dither), function(v) /*=>*/ { tool_attribute.dither = v; })
									.setTooltips( [ "No Dithering", "Bayer 2", "Bayer 4", "Bayer 8" ] )
									.setCollape(false);
									
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tool_settings     = [ [ "",                   tool_channel_edit,   "channel",   tool_attribute ], 
						      [ "",                   tool_drawLayer_edit, "drawLayer", tool_attribute ],
						      [ "",                   tool_mirror_edit,    "mirror",    tool_attribute ] ];
		tool_size         =   [ "",                   tool_size_edit,      "size",      tool_attribute, "Brush Size" ];
		tool_thrs         =   [ THEME.tool_threshold, tool_thrs_edit,      "thres",     tool_attribute, "Threshold"  ];
		tool_fil8         =   [ THEME.tool_fill_type, tool_fil8_edit,      "fillType",  tool_attribute, "Fill Type"  ];
		tool_fill_bg      =   [ THEME.tool_bg,        tool_fill_use_bg,    "useBG",     tool_attribute, "Use BG"     ];
		tool_iso_settings =   [ "",                   tool_isoangle,       "iso_angle", tool_attribute ];
		tool_dithering    =   [ "",                   tool_dither,         "dither",    tool_attribute ];
		
		tool_fill_settings = [
			tool_thrs,
			tool_fil8,
			tool_fill_bg,
		];
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tool_fill_grad_obj  = new NodeTool()
			.setSettings(tool_fill_settings)
			.setSetting(tool_dithering)
			.setToolObject(tool_fill_grad);
		
		tool_pattern_obj  = new NodeTool()
			.setSettings(tool_pattern_settings)
			.setToolObject(tool_pattern);
		
		tools = [
			new NodeTool( "Selection",	[ THEME.canvas_tools_selection_rectangle, THEME.canvas_tools_selection_circle, THEME.canvas_tools_freeform_selection, THEME.canvas_tools_selection_brush ])
				.setSettings(tool_settings)
				.setToolObject([ tool_sel_rectangle, tool_sel_ellipse, tool_sel_freeform, tool_sel_brush ]),
			
			new NodeTool( "Magic Selection", THEME.canvas_tools_magic_selection )
				.setSettings(tool_settings)
				.setSettings(tool_fill_settings)
				.setToolObject(tool_sel_magic),
			
			new NodeTool( "Pencil",		  THEME.canvas_tools_pencil)
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setToolObject(tool_brush),
			
			new NodeTool( "Eraser",		  THEME.canvas_tools_eraser)
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setToolObject(tool_eraser),
					
			new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect,  THEME.canvas_tools_rect_fill  ])
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setToolObject(tool_rectangle),
					
			new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip, THEME.canvas_tools_ellip_fill ])
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setToolObject(tool_ellipse),
			
			new NodeTool( "Iso Cube",	[ THEME.canvas_tools_iso_cube, THEME.canvas_tools_iso_cube_wire, THEME.canvas_tools_iso_cube_fill ])
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setSetting(tool_iso_settings)
				.setToolObject(tool_iso_cube),
			
			new NodeTool( "Curve",		  THEME.canvas_tool_curve_icon)
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setSetting([ "", tool_curve_buttons, 0, tool_attribute ])
				.setToolObject(tool_curve_bez),
			
			new NodeTool( "Freeform",	  THEME.canvas_tools_freeform)
				.setSettings(tool_settings)
				.setSetting(tool_size)
				.setToolObject(tool_freeform),
					
			new NodeTool( "Fill",		  THEME.canvas_tools_bucket)
				.setSettings(tool_fill_settings)
				.setToolObject(tool_fill),
			
			new NodeTool( [ "Gradient", "Pattern" ],     [ THEME.canvas_tools_gradient, THEME.canvas_tools_pattern ] )
				.setContext(self)
				.setToolObject( [ new canvas_tool_with_selector(tool_fill_grad_obj), new canvas_tool_with_selector(tool_pattern_obj) ]),
			
		];
	#endregion
	
	#region ++++ node tool ++++
		__action_add_node = method(self, function(c) /*=>*/ { with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: c })) canvas = true; });
		
		tool_node_buttons = new buttonGroup( array_create(2, THEME.toolbar_check), function(v) /*=>*/ { if(v == 0) nodeTool.apply(); else nodeTool.destroy(); })
								.setCollape(false);
		
		nodeTool        = noone;
		nodeToolPreview = new NodeTool( "Apply Node", THEME.canvas_tools_node, self )
								.setSettings(tool_settings)
								.setToolFn(__action_add_node)
								.setContext(self);
								
		
		selectionExtract = function() /*=>*/ {
			var _s  = selection.is_selected;
			var _sx = _s? selection.selection_position[0] : 0;
			var _sy = _s? selection.selection_position[1] : 0;
			var _sw = _s? selection.selection_size[0] : attributes.dimension[0];
			var _sh = _s? selection.selection_size[1] : attributes.dimension[1];
			
			var _nc = nodeBuild("Node_Canvas", x, y + h + 16).skipDefault();
			_nc.inputs[0].setValue([_sw, _sh]);
			
			var _comp = noone; 
			var _o = outputs[0].getJunctionTo();
			for( var i = 0, n = array_length(_o); i < n; i++ ) {
				if(is(_o[i].node, Node_Composite)) _comp = _o[i].node;
			}
			
			if(_comp == noone) {
				_comp = nodeBuild("Node_Composite", x + w + 32, y).skipDefault();
				_comp.addInput(outputs[0]);
				
			} else {
				var _yy = y + h + 16;
				for( var i = 0, n = array_length(_comp.inputs); i < n; i++ ) {
					var _in = _comp.inputs[i].value_from;
					if(_in == noone) continue;
					_yy = max(_yy, _in.node.y + _in.node.h + 16);
				}
					
				_nc.move(x, _yy);
			}
			
			var _j = _comp.addInput(_nc.outputs[0]);
			var _o = _nc.outputs[0].getJunctionTo();
			var _i = _o[0].index;
			
			_comp.inputs[_i+1].unit.mode = VALUE_UNIT.constant;
			_comp.inputs[_i+1].setValue([_sx,_sy]);
			_comp.inputs[_i+6].setValue([0,0]);
			
			PANEL_PREVIEW.setNodePreview(_comp, false, false);
			PANEL_INSPECTOR.setInspecting(_nc);
			PANEL_GRAPH.nodes_selecting = [ _nc ];
			
			if(_s) {
				selection.apply();
				PANEL_PREVIEW.clearTool();
			}
		}
		
		selectionExtractButton = new NodeTool( "Extract Selection", THEME.canvas_tools_extract, self )
								.setToolFn(selectionExtract)
								.setContext(self);
		
		static addNodeTool = function(_node) {
			UNDO_HOLDING = true;
			nodeTool = new canvas_tool_node(self, _node).init();
			UNDO_HOLDING = false;
		}
	#endregion
	
	#region ++++ right tools ++++
		__action_rotate_90_cw  = method(self, function( ) /*=>*/ { if(selection.is_selected) selection.rotate90cw()  else canvas_action_rotate(-90); });
		__action_rotate_90_ccw = method(self, function( ) /*=>*/ { if(selection.is_selected) selection.rotate90ccw() else canvas_action_rotate( 90); });
		__action_flip_h        = method(self, function( ) /*=>*/ { if(selection.is_selected) selection.flipH()       else canvas_action_flip(1);     });
		__action_flip_v        = method(self, function( ) /*=>*/ { if(selection.is_selected) selection.flipV()       else canvas_action_flip(0);     });
		__action_make_brush    = method(self, function( ) /*=>*/ { 
			if(brush.brush_use_surface) {
				brush.brush_surface     = noone;
				brush.brush_use_surface = false;
				
				rtool_brush.spr = THEME.canvas_tools_pencil;
				tool_brush.rightTools     = rightTools_empty;
				tool_eraser.rightTools    = rightTools_empty;
				tool_rectangle.rightTools = rightTools_empty;
				tool_ellipse.rightTools   = rightTools_empty;
				return;
			}
			
			var _surf  = selection.selection_surface;
			if(!is_surface(_surf)) return;
			
			var _bsurf = surface_create(surface_get_width(_surf) + 2, surface_get_height(_surf) + 2);
			
			surface_set_shader(_bsurf, noone);
				draw_surface(_surf, 1, 1);
			surface_reset_shader();
			
			brush.brush_use_surface = true;
			brush.brush_surface     = _bsurf; 
			selection.apply();
			
			PANEL_PREVIEW.tool_current = tools[2];
			
			rtool_brush.spr = THEME.canvas_tools_pencil_surface;
			tool_brush.rightTools     = rightTools_brush;
			tool_eraser.rightTools    = rightTools_brush;
			tool_rectangle.rightTools = rightTools_brush;
			tool_ellipse.rightTools   = rightTools_brush;
		});
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		tool_resizer     = new canvas_tool_resize(self);
		
		tool_resizer_dim = new vectorBox(2, function(v,i) /*=>*/ { tool_resizer.setSize(v,i); })
								.setFont(f_p3)
								.setMinWidth(ui(64));
		
		tool_resizer_anchor  = new buttonAnchor(noone, function(v) /*=>*/ { tool_resizer.setAnchor(v); });
		
		tool_resizer_buttons = new buttonGroup( array_create(2, THEME.toolbar_check), function(v) /*=>*/ { if(v == 0) tool_resizer.apply(); else tool_resizer.cancel(); })
									.setCollape(false);
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		rightTools_general = [ 
			nodeToolPreview,
			selectionExtractButton, 
			-1,
			
			new NodeTool( "Resize Canvas",	  THEME.canvas_resize )
				.setSetting([ THEME.tool_scale, tool_resizer_dim,     "dimension", tool_resizer, "Dimension"])
				.setSetting([ "", tool_resizer_anchor,  0, tool_resizer   ])
				.setSetting([ "", tool_resizer_buttons, 0, tool_attribute ])
				.setToolObject(tool_resizer),
			
			new NodeTool( [ "Rotate 90 CW", "Rotate 90 CCW" ], [ THEME.canvas_rotate_cw, THEME.canvas_rotate_ccw ] )
				.setToolFn( [ __action_rotate_90_cw, __action_rotate_90_ccw ] ),
			
			new NodeTool( [ "Flip H", "Flip V" ], [ THEME.canvas_flip_h, THEME.canvas_flip_v ] )
				.setToolFn( [ __action_flip_h, __action_flip_v ] ),
		];
		
		rtool_brush   = new NodeTool( "Make/Reset Brush", THEME.canvas_tools_pencil ).setToolFn( __action_make_brush );
		rtool_outline = new NodeTool( "Outline", THEME.canvas_tools_outline ).setToolObject( new canvas_tool_outline() );
		rtool_extrude = new NodeTool( "Extrude", THEME.canvas_tools_extrude ).setToolObject( new canvas_tool_extrude() );
		rtool_inset   = new NodeTool( "Inset",   THEME.canvas_tools_inset   ).setToolObject( new canvas_tool_inset()   );
		rtool_skew    = new NodeTool( "Skew",    THEME.canvas_tools_skew    ).setToolObject( new canvas_tool_skew()    );
		rtool_corner  = new NodeTool( "Corner",  THEME.canvas_tools_corner  ).setToolObject( new canvas_tool_corner()  );
		
		rightTools_selection = [ 
			-1,
			rtool_brush,
			-1,
			rtool_outline,
			rtool_extrude,
			rtool_inset,
			rtool_skew,
			rtool_corner,
		];
		
		rightTools_not_selection = [ 
			-1,
			new NodeTool( "Outline", THEME.canvas_tools_outline).setContext(self).setToolObject( new canvas_tool_with_selector(rtool_outline) ).setSettings(tool_settings),
			new NodeTool( "Extrude", THEME.canvas_tools_extrude).setContext(self).setToolObject( new canvas_tool_with_selector(rtool_extrude) ).setSettings(tool_settings),
			new NodeTool( "Inset",   THEME.canvas_tools_inset  ).setContext(self).setToolObject( new canvas_tool_with_selector(rtool_inset)   ).setSettings(tool_settings),
			new NodeTool( "Skew",    THEME.canvas_tools_skew   ).setContext(self).setToolObject( new canvas_tool_with_selector(rtool_skew)    ).setSettings(tool_settings),
			new NodeTool( "Corner",  THEME.canvas_tools_corner ).setContext(self).setToolObject( new canvas_tool_with_selector(rtool_corner)  ).setSettings(tool_settings),
		];
		
		rightTools_empty = [  ];
		rightTools_brush = [ -1, rtool_brush ];
		
		rightTools = rightTools_general;
		tool_brush.rightTools     = rightTools_empty;
		tool_eraser.rightTools    = rightTools_empty;
		tool_rectangle.rightTools = rightTools_empty;
		tool_ellipse.rightTools   = rightTools_empty;
		
		selection_tool_after = noone;
	#endregion
	
	#region ++++ hotkey ++++
		hotkeys = [
			[ "New Frame",  function() /*=>*/ { addFrame(); } ], 
			
			[ "Select All",      function() /*=>*/ { selection.selectAll();                        } ], 
			[ "Copy Selection",  function() /*=>*/ { selection.copySelection(); selection.apply(); } ], 
			[ "Paste",           function() /*=>*/ { pasteSurface(false);                          } ], 
			[ "Paste at Cursor", function() /*=>*/ { pasteSurface(true);                           } ], 
			
		];
	#endregion
	
	function getToolColor() { return !use_color_3d || color_3d_selected == 0? CURRENT_COLOR : brush.colors[color_3d_selected - 1]; }
	function setToolColor(color) { 
		if(!use_color_3d || color_3d_selected == 0) CURRENT_COLOR = color;
		else                                        brush.colors[color_3d_selected - 1] = color;
	}
	
	static drawTools = function(_mx, _my, xx, yy, _tool_size, hover, focus) {
		var _sx0 = xx - _tool_size / 2;
		var _sx1 = xx + _tool_size / 2;
		var hh   = ui(8);
		
		yy += ui(4);
		draw_set_color(COLORS._main_icon_dark);
		draw_line_round(_sx0 + ui(8), yy, _sx1 - ui(8), yy, 2);
		yy += ui(4);
		
		var _cx = _sx0 + ui(8);
		var _cw = _tool_size - ui(16);
		var _ch = ui(12);
		var _pd = ui(5);
		var _currc = CURRENT_COLOR;
		
		yy += ui(8);
		hh += ui(8);
		
		if(use_color_3d) {
			var _3x = _cx + _cw / 2;
			var _3y =  yy + _cw / 2;
			
			draw_sprite_ui(THEME.color_3d, 0, _3x, _3y, 1, 1, 0, CURRENT_COLOR  );
			draw_sprite_ui(THEME.color_3d, 1, _3x, _3y, 1, 1, 0, brush.colors[0]);
			draw_sprite_ui(THEME.color_3d, 2, _3x, _3y, 1, 1, 0, brush.colors[1]);
			
			draw_sprite_ui(THEME.color_3d_selected, color_3d_selected, _3x, _3y);
			
			if(color_3d_selected) _currc = brush.colors[color_3d_selected - 1];
			
			if(point_in_circle(_mx, _my, _3x, _3y, ui(16))) {
				var dir = point_direction(_3x, _3y, _mx, _my);
				var sel = 0;
				
				if(dir > 150 && dir < 270)     sel = 1;
				else if(dir > 270 || dir < 30) sel = 2;
				
				if(mouse_press(mb_left, focus)) { 
					if(color_3d_selected == sel) colorSelectorCall(sel == 0? CURRENT_COLOR : brush.colors[sel - 1], setToolColor);
					else color_3d_selected = sel;
				}
			}
			
			if(focus && keyboard_check_pressed(ord("X")))
				color_3d_selected = (color_3d_selected + 1) % 3;
			
			yy += _cw + ui(12);
			hh += _cw + ui(12);
			
		} else {
			drawColor(CURRENT_COLOR, _cx, yy, _cw, _cw);
			draw_sprite_stretched_ext(THEME.palette_selecting, 0, _cx - _pd, yy - _pd, _cw + _pd * 2, _cw + _pd * 2, c_white, 1);
			
			if(point_in_rectangle(_mx, _my, _cx, yy, _cx + _cw, yy + _cw) && mouse_press(mb_left, focus))
				colorSelectorCall(CURRENT_COLOR, setToolColor);
		
			yy += _cw + ui(8);
			hh += _cw + ui(8);
			
		}
		
		var _sel = noone;
		
		var _scroll = 0;
		var _scrollTarget = noone;
		if(focus && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) _scroll = -sign(MOUSE_WHEEL);
		
		for( var i = 0, n = array_length(DEF_PALETTE); i < n; i++ ) {
			var _c = DEF_PALETTE[i];
			
			var ii = 0;
			if(i == 0)     ii = 4;
			if(i == n - 1) ii = 5;
			
			draw_sprite_stretched_ext(THEME.palette_mask, ii, _cx, yy, _cw, _ch, _c, 1);
			
			if(color_diff(_c, _currc) <= 0) {
				_sel = [ _cx, yy ];
				if(_scroll != 0)
					_scrollTarget = (i + _scroll + n) % n;
			}
					
			if(hover && point_in_rectangle(_mx, _my, _cx, yy, _cx + _cw, yy + _ch)) {
				if(mouse_click(mb_left, focus))
					setToolColor(_c);
			}
			
			yy += _ch;
			hh += _ch;
		}
		
		if(_scrollTarget != noone)
			setToolColor(DEF_PALETTE[_scrollTarget]);
		
		if(_sel != noone) 
			draw_sprite_stretched_ext(THEME.palette_selecting, 0, _sel[0] - _pd, _sel[1] - _pd, _cw + _pd * 2, _ch + _pd * 2 - 1, c_white, 1);
		
		return hh + ui(4);
	}
	
	static tool_pick_color = function(_x, _y) {
		tool_attribute.pickColor = selection.is_selected?
				surface_get_pixel_ext(selection.selection_surface, _x - selection.selection_position[0], _y - selection.selection_position[1]) : 
				surface_get_pixel_ext(getCanvasSurface(), _x, _y);
	}
	
	static getToolSettings = function() { return []; }
	
	static pickColor = function(_x, _y, _s, _mx, _my) {
		var mx = round((_mx - _x) / _s - 0.5);
		var my = round((_my - _y) / _s - 0.5);
				
		var _surf = getOutputSurface();
		var _sw   = surface_get_width_safe(_surf);
		var _sh   = surface_get_height_safe(_surf);
		
		if(mx >= 0 && my >= 0 && mx < _sw && my < _sh && mouse_check_button(mb_left)) {
			var c = surface_getpixel(_surf, mx, my);
			setToolColor(cola(c));
		}
		
		var x0 = _x + mx * _s, x1 = x0 + _s;
		var y0 = _y + my * _s, y1 = y0 + _s;
		
		draw_set_color(c_white);
		draw_rectangle(x0, y0, x1, y1, true);
		
		draw_set_color(c_black);
		draw_rectangle(x0+1, y0+1, x1-1, y1-1, true);
		
		if(keyboard_check_released(vk_alt)) color_picking = false;
	}
	
	nodes = [];
	static refreshNodes = function() {}
	static getNodeList  = function() /*=>*/ {return nodes};
	
	////- Frames
	
	static setFrame = function(frame) {
		var _anim  = getInputData(12);
		var _autof = getInputData( 5);
		if(_anim == 1 && _autof) PROJECT.animator.setFrame(frame);
		
		preview_index = frame;
	}
	
	static addFrame = function(_focus = true) {
		if(_focus) setFrame(attributes.frames);
		attributes.frames++;
		refreshFrames();
		update();
	}
	
	static removeFrame = function(index = 0) {
		if(attributes.frames <= 1) {
			surface_clear(canvas_surface[0]);
			buffer_delete(canvas_buffer[0]);
			update();
			return;
		}
		
		if(preview_index >= attributes.frames) 
			setFrame(max(preview_index - 1, 0));
		attributes.frames--;
		
		surface_free_safe(canvas_surface[index]);
		buffer_delete(canvas_buffer[index]);
			
		array_delete(canvas_surface, index, 1);
		array_delete(canvas_buffer,  index, 1);
		update();
	}
	
	static refreshFrames = function() {
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
	}
	
	////- Surfaces
	
	function getCanvasSurface(index = preview_index) { INLINE return array_safe_get_fast(canvas_surface, index); }
	function getOutputSurface(index = preview_index) { INLINE return array_safe_get_fast(output_surface, index); }
	
	function setCanvasSurface(surface, index = preview_index) { INLINE canvas_surface[index] = surface; }
	
	static   apply_surfaces = function() { for( var i = 0; i < attributes.frames; i++ ) apply_surface(i); }
	function apply_surface(index = preview_index) {
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
				draw_surface_safe(_canvas_surface);
			surface_reset_target();
			
			setCanvasSurface(_newCanvas, index);
			surface_free(_canvas_surface);
		}
		
		drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], cDep);
		surface_clear(drawing_surface);
	}
	
	static surface_store_buffers = function(index = preview_index) { for( var i = 0; i < attributes.frames; i++ ) surface_store_buffer(i); }
	static surface_store_buffer  = function(index = preview_index) {
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
	}
	
	function apply_draw_surface(_applyAlpha = true) {
		var _can = getCanvasSurface();
		var _drw = drawing_surface;
		var _dim = attributes.dimension;
		var _tmp;
		
		if(selection.is_selected) {
			var _tmp = surface_create(surface_get_width_safe(selection.selection_mask), surface_get_height_safe(selection.selection_mask));
			var _spx = selection.selection_position[0];
			var _spy = selection.selection_position[1];
			var _spw = selection.selection_size[0];
			var _sph = selection.selection_size[1];
			
			surface_set_shader(_tmp, noone, true, BLEND.over);
				draw_surface(drawing_surface, -_spx, -_spy);
				
				BLEND_ALPHA
					if(tool_attribute.mirror[1]) draw_surface_ext_safe(drawing_surface, _spx * 2 + _spw - _spx, -_spy, -1, 1);
					if(tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, -_spx, _spy * 2 + _sph - _spy, 1, -1);
					if(tool_attribute.mirror[1] && tool_attribute.mirror[2]) draw_surface_ext_safe(drawing_surface, _spx * 2 + _spw - _spx, _spy * 2 + _sph - _spy, -1, -1);
				
				BLEND_MULTIPLY
					draw_surface_safe(selection.selection_mask);
			surface_reset_shader();
			
			_can = selection.selection_surface;
			
		} else {
			storeAction();
			
			var _tmp = surface_create(_dim[0], _dim[1]);
			
			surface_set_shader(_tmp, noone, true, BLEND.over);
				draw_surface_safe(drawing_surface);
				
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
			surface_reset_shader();
			
		}
		
		var _tw = surface_get_width_safe(_tmp);
		var _th = surface_get_height_safe(_tmp);
		
		var _sw = surface_get_width_safe(_can);
		var _sh = surface_get_height_safe(_can);
		
		var _drawnSurface = surface_create(_sw, _sh);
		
		surface_set_shader(_drawnSurface, sh_canvas_apply_draw);
			shader_set_i("drawLayer", tool_attribute.drawLayer);
			shader_set_i("eraser",    isUsingTool("Eraser"));
			shader_set_f("channels",  tool_attribute.channel);
			shader_set_f("alpha",     _applyAlpha? _color_get_alpha(CURRENT_COLOR) : 1);
			shader_set_f("mirror",    tool_attribute.mirror);
			shader_set_c("pickColor", tool_attribute.pickColor, _color_get_alpha(tool_attribute.pickColor));
			
			shader_set_surface("back", _can);
			shader_set_surface("fore", _tmp);
			
			draw_empty();
		surface_reset_shader();
		
		surface_free(_can);
		surface_free(_tmp);
		surface_clear(drawing_surface);
		
		if(selection.is_selected) {
			selection.selection_surface = _drawnSurface;
			
		} else {
			setCanvasSurface(_drawnSurface);
			surface_store_buffer();
		}
		
		project.setModified();
	}
	
	static storeAction = function() {
		
		var action = recordAction(ACTION_TYPE.custom, function(data) { 
			if(selection.is_selected) selection.apply();
			
			var _canvas = surface_clone(getCanvasSurface(data.index));
			
			if(is_surface(data.surface))
				setCanvasSurface(data.surface, data.index); 
			surface_store_buffer(data.index); 
			
			data.surface = _canvas;
		}, { surface: surface_clone(getCanvasSurface(preview_index)), tooltip: $"Modify canvas {preview_index}", index: preview_index });
		
	}
	
	////- Draw Overlay
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		preview_surface_sample = isNotUsingTool();
		
		#region hotkey
			array_foreach(hotkeys, function(h) /*=>*/ { if(HOTKEYS_CUSTOM[$ "Node_Canvas"][$ h[0]].isPressing()) h[1](); });
		#endregion
		
		#region color picker
			if(!selection.is_selected && active && key_mod_press(ALT)) 
				color_picking = true;
			
			if(color_picking) return pickColor(_x, _y, _s, _mx, _my);
		#endregion
		
		#region parameters
			var hovering = isUsingTool();
			var _panel   = _params[$ "panel"] ?? noone;
			
			if(palette_picking) {
				hover  = false; 
				active = false; 
			}
			
			mouse_cur_x = round((_mx - _x) / _s - 0.5);
			mouse_cur_y = round((_my - _y) / _s - 0.5);
		#endregion
		
		#region brush
			brush.node     = self;
			brush.tileMode = _panel.tileMode
			brush.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			tool_size_edit.setInteract(!is_surface(brush.brush_surface));
		#endregion
		
		#region surfaces
			var _canvas_surface = getCanvasSurface();
			if(!surface_exists(_canvas_surface)) return hovering;
		
			var _dim = attributes.dimension;
			_drawing_surface = surface_verify(_drawing_surface, _dim[0], _dim[1]);
			drawing_surface  = surface_verify( drawing_surface, _dim[0], _dim[1], attrDepth());
			
			surface_set_shader(_drawing_surface, noone); 
				draw_surface_safe(drawing_surface); 
			surface_reset_shader();
			
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			prev_surface 		  = surface_verify(prev_surface,		  _dim[0], _dim[1]);
			preview_draw_surface  = surface_verify(preview_draw_surface,  _dim[0], _dim[1]);
			preview_draw_mask     = surface_verify(preview_draw_mask,     _sw,     _sh);
		#endregion
		
		#region tool
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = noone;
			var _tool_sel = noone;
			use_color_3d  = false;
			
			rightTools = [];
			array_append(rightTools, rightTools_general);
			
			if(nodeTool != noone) 
				_tool = nodeTool;
				
			else if(_currTool != noone) {
				_tool = _currTool.getToolObject();
				
				if(is(_tool, canvas_tool_with_selector))
					_tool_sel = _tool;
				
				if(is(_tool, canvas_tool)) {
					_tool.node = self;
					
					_tool = _tool.getTool();
					_tool.subtool = _currTool.selecting;
					array_append(rightTools, _tool.rightTools);
					
					use_color_3d = _tool.use_color_3d;
				} else 
					_tool = noone;
			}
			
			tool_mirror_edit.sprs = tool_attribute.mirror[0]? THEME.canvas_mirror_diag : THEME.canvas_mirror;
			
		#endregion
			
		#region selection
			selection.drawing_surface    = drawing_surface;
			selection.canvas_surface     = _canvas_surface;
			selection.apply_draw_surface = apply_draw_surface;
			selection.was_selected       = selection.is_selected;
			selection.selection_hovering = false;
			
			if(selection.is_selected) {
				selection.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				if(_tool_sel == noone && is(_tool, canvas_tool_selection))
					selection.onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
					
				array_append(rightTools, rightTools_selection);
			} else
				array_append(rightTools, rightTools_not_selection);
				
		#endregion
		
		#region tool draw override
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
				
				drawToolOutline();
				
				_tool.drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				return hovering;
			}
		#endregion
		
		#region tool step
			if(_tool) {
				_tool.drawing_surface    = drawing_surface;
				_tool.canvas_surface     = _canvas_surface;
				_tool.output_surface     = getOutputSurface();
				_tool.apply_draw_surface = apply_draw_surface;
				_tool.brush              = brush;
				
				_tool.node = self;
				
				var _tx = _x;
				var _ty = _y;
				
				if(_tool.relative && selection.is_selected) {
					_tool.canvas_surface = selection.selection_surface;
					_tx = _x + selection.selection_position[0] * _s;
					_ty = _y + selection.selection_position[1] * _s;
				}
				
				draw_set_color_alpha(isUsingTool("Eraser")? c_white : CURRENT_COLOR, 1);
				
				_tool.step(hover, active, _tx, _ty, _s, _mx, _my, _snx, _sny);
				
				if(_tool.brush_resizable) { 
					if(_panel.pHOVER && key_mod_press(CTRL) && MOUSE_WHEEL != 0)
						tool_attribute.size = clamp(tool_attribute.size + sign(MOUSE_WHEEL), 1, 64);
					
					brush.sizing(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				} 
				
			}
		#endregion
		
		#region preview
			if(_tool_sel) _tool_sel.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_tool)     _tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			
			var _drawToolPreview = _params[$ "drawToolPreview"] ?? true;
			
			surface_set_shader(preview_draw_surface, noone, true, BLEND.alpha);
				draw_surface_safe(_drawing_surface);
				
				if(selection.is_selected) {
					var _spx = selection.selection_position[0];
					var _spy = selection.selection_position[1];
					var _spw = selection.selection_size[0];
					var _sph = selection.selection_size[1];
					
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
				
				if(brush.brush_sizing) canvas_draw_point_brush(brush, brush.brush_sizing_dx, brush.brush_sizing_dy);
				if(_tool) _tool.drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
					
				draw_set_alpha(1);
			surface_reset_shader();
			
			var _pcc = isUsingTool("Eraser")? c_red : c_white;
			var _paa = isUsingTool("Eraser")? .2 : _color_get_alpha(CURRENT_COLOR);
			
			switch(_panel.tileMode) {
				case 0 : 
					draw_surface_ext_safe(getPreviewValues(_drawToolPreview), _x, _y, _s, _s, 0, c_white, 1); 
					break;
				
				case 1 : 
                    preview_draw_tile = surface_verify(preview_draw_tile, _panel.w, _dim[1] * _s);
                    surface_set_target(preview_draw_tile);
                        DRAW_CLEAR
                        draw_surface_tiled_ext_safe(preview_draw_surface, _x, 0, _s, _s, 0, _pcc, _paa); 
                    surface_reset_target();
                    draw_surface_safe(preview_draw_tile, 0, _y);
                    break;
                    
                case 2 : 
                    preview_draw_tile = surface_verify(preview_draw_tile, _dim[0] * _s, _panel.h);
                    surface_set_target(preview_draw_tile);
                        DRAW_CLEAR
                        draw_surface_tiled_ext_safe(preview_draw_surface, 0, _y, _s, _s, 0, _pcc, _paa); 
                    surface_reset_target();
                    draw_surface_safe(preview_draw_tile, _x, 0);
                    break;
                    
                case 3 : 
                	draw_surface_tiled_ext_safe(preview_draw_surface, _x, _y, _s, _s, 0, _pcc, _paa); 
                	break;
			}
			
			var bs = brush.brush_size;
			global.canvas_brush_surface = surface_verify(global.canvas_brush_surface, bs+1, bs+1);
			surface_set_target(global.canvas_brush_surface);
				DRAW_CLEAR
				draw_set_color(c_white);
				canvas_draw_point_brush(brush, floor(bs/2), floor(bs/2));
			surface_reset_target();
			
			surface_set_target(preview_draw_mask);
				DRAW_CLEAR
				if(selection.is_selected) selection.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				if(_tool) {
					_tool.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
					
					var _dx = _x + (mouse_cur_x - floor(bs/2)) * _s;
					var _dy = _y + (mouse_cur_y - floor(bs/2)) * _s;
					draw_surface_ext(global.canvas_brush_surface, _dx, _dy, _s, _s, 0, c_white, 1);
				}
			surface_reset_target();
			
			drawToolOutline();
			
			draw_set_color(COLORS._main_accent);
			if(selection.is_selected) {
				var _spx = selection.selection_position[0];
				var _spy = selection.selection_position[1];
				var _spw = selection.selection_size[0];
				var _sph = selection.selection_size[1];
				
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
			
			var _x0 = _x;
			var _y0 = _y;
			var _x1 = _x0 + _dim[0] * _s;
			var _y1 = _y0 + _dim[1] * _s;
			
			draw_set_color(COLORS.panel_preview_surface_outline);
			draw_rectangle(_x0, _y0, _x1 - 1, _y1 - 1, true);
			draw_set_alpha(1);
			
			if(selection.is_selected && _tool_sel == noone && is(_tool, canvas_tool_selection))
				selection.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		#endregion
		
		#region color picker 
			if(active && key_press(ord("C"), MOD_KEY.shift)) {
				var pick = instance_create(mouse_mx, mouse_my, o_dialog_color_quick_pick);
				array_insert(pick.palette, 0, getToolColor());
				
				pick.use_key = MOD_KEY.shift;
				pick.onApply = setToolColor;
				
			}
			
			palette_picking = instance_exists(o_dialog_color_quick_pick);
		#endregion
		
		#region drag n drop
			if(DRAGGING && hover&& mouse_release(mb_left)) {
				if(DRAGGING.type == "Color") {
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
			}
		#endregion
		
		return hovering;
	}
	
	static drawToolOutline = function() {
		var __s  = surface_get_target();
		var _sw  = surface_get_width(__s);
		var _sh  = surface_get_height(__s);
		
		shader_set(sh_brush_outline);
			shader_set_f("dimension", _sw, _sh);
			draw_surface_ext_safe(preview_draw_mask);
		shader_reset();
	}
	
	////- Nodes
	
	static step = function() {
		var _anim  = getInputData(12);
		var _autof = getInputData( 5);
		var _fram  = attributes.frames;
		
		update_on_frame = _fram > 1 && _anim == 1 && _autof;
		
		if(update_on_frame) {
			var _anims = getInputData(13);
			var _atype = getInputData(18);
			
			if(_atype == 0)  preview_index = safe_mod(CURRENT_FRAME * _anims, _fram);
			else			 preview_index = min(CURRENT_FRAME * _anims, _fram - 1);
		}
		
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _dim   = getInputData( 0);
			
			var _anim  = getInputData(12);
			var _autof = getInputData( 5);
			var _frame = getInputData( 7);
			var _anims = getInputData(13);
			var _atype = getInputData(18);
			
			var _brush = getInputData( 6), _brushSurf = is_surface(_brush);
			
			var _bgr   = getInputData(10);
			var _bgTyp = getInputData( 4);
			var _bgCol = getInputData( 1);
			var _bgSrf = getInputData( 8);
			var _bgDim = getInputData(14);
			var _bgAlp = getInputData( 9);
			
			var cDep   = attrDepth();
			
			inputs[ 7].setVisible(!_autof);
			inputs[13].setVisible( _autof);
			
			inputs[15].setVisible(_brushSurf);
			inputs[16].setVisible(_brushSurf);
			
			inputs[ 1].setVisible(_bgTyp == 1);
			inputs[ 8].setVisible(_bgTyp == 0);
			inputs[14].setVisible(_bgTyp == 0);
		#endregion
		
		#region dimension
			attributes.useBGDim  = false;
			
			if(_bgTyp == 0 && _bgDim) {
				var _bgDim = _bgSrf;
				if(is_array(_bgDim) && !array_empty(_bgDim)) _bgDim = _bgSrf[0];
				if(is_surface(_bgDim)) {
					attributes.useBGDim = true;
					_dim = surface_get_dimension(_bgDim);
				}
			}
			attributes.dimension = _dim;
		#endregion
		
		#region surface
			apply_surfaces();
			
			var _frames  = attributes.frames;
			
			if(!is_array(output_surface)) output_surface = array_create(_frames);
			else if(array_length(output_surface) != _frames)
				array_resize(output_surface, _frames);
			
			if(_frames == 1) {
				var _canvas_surface = getCanvasSurface(0);
				output_surface[0] = surface_verify(output_surface[0], _dim[0], _dim[1], cDep);
				
				surface_set_shader(output_surface[0], noone,, BLEND.alpha);
					if(_bgr) {
						if(_bgTyp == 0) {
							if(is_array(_bgSrf) && !array_empty(_bgSrf)) _bgSrf = _bgSrf[0];
							if(is_surface(_bgSrf)) 
								draw_surface_stretched_safe(_bgSrf, 0, 0, _dim[0], _dim[1], c_white, _bgAlp);
							
						} else if(_bgTyp == 1) {
							draw_clear_alpha(_bgCol, _bgAlp);
						}
					}
					draw_surface_safe(_canvas_surface);
				surface_reset_shader();
				
			} else {
				for( var i = 0; i < _frames; i++ ) {
					var _canvas_surface = getCanvasSurface(i);
					output_surface[i]   = surface_verify(output_surface[i], _dim[0], _dim[1], cDep);
					
					surface_set_shader(output_surface[i], noone,, BLEND.alpha);
						if(_bgr) {
							if(_bgTyp == 0) {
								var _bgArray = is_array(_bgSrf)? array_safe_get_fast(_bgSrf, i, 0) : _bgSrf;
								if(is_surface(_bgArray))
									draw_surface_stretched_ext(_bgArray, 0, 0, _dim[0], _dim[1], c_white, _bgAlp);
								
							} else if(_bgTyp == 1) {
								draw_clear_alpha(_bgCol, _bgAlp);
							}
						}
						draw_surface_safe(_canvas_surface);
					surface_reset_shader();
				}
				
				temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], cDep);
				surface_clear(temp_surface[1]);
			}
		#endregion
		
		#region output
			switch(_anim) {
				case 0 : 
					outputs[0].setName("Surface Out");
					
					if(_frames == 1) outputs[0].setValue(output_surface[0]);
					else outputs[0].setValue(output_surface); 
					
					if(array_length(outputs) != 1) {
						array_resize(outputs, 1);
						__preDraw_data.force = true;
					}
					break;
					
				case 1 : 
					var _fr_index = _autof? (CURRENT_FRAME * _anims) : _frame;
			
					switch(_atype) {
						case 0 : _fr_index = safe_mod(max(0, _fr_index), _frames);                     break;
						case 1 : _fr_index = clamp(_fr_index, 0, _frames - 1);                         break;
						case 2 : _fr_index = _fr_index >= 0 && _fr_index < _frames? _fr_index : noone; break;
					}
					
					outputs[0].setName("Surface Out");
					outputs[0].setValue(_fr_index == noone? temp_surface[1] : output_surface[_fr_index]);
					
					if(array_length(outputs) != 1) {
						array_resize(outputs, 1);
						__preDraw_data.force = true;
					}
					break;
					
				case 2 :
					var amo = _frames;
		
					for (var i = 0; i < amo; i++) {
						if(i >= array_length(outputs)) {
							var _pl = array_safe_get(output_pool, i, 0);
							if(_pl == 0) _pl = nodeValue_Output("Frame", VALUE_TYPE.surface, 0);
							
							newOutput(i, _pl);
							output_pool[i] = _pl;
						}
						
						outputs[i].setName($"Frame {i}");
						outputs[i].setValue(output_surface[i]);
					}
					
					var _rem = array_length(outputs);
					for(var i = amo; i < _rem; i++) {
						var _to = outputs[i].getJunctionTo();
						
						for( var j = 0, m = array_length(_to); j < m; j++ ) 
							_to[j].removeFrom();
					}
					
					array_resize(outputs, amo);
					__preDraw_data.force = true;
					break;
			}
		#endregion
		
		#region live edit
			if(live_edit) {
				if(!is_struct(PANEL_FILE)) return;
				
				var _fileO = PANEL_FILE.file_focus;
				if(_fileO == noone) return;
				
				var path = _fileO.path;
				if(path == "") return;
				
				surface_save(getCanvasSurface(0), path);
				_fileO.refreshThumbnail();
			}
		#endregion
	}
	
	static getPreviewValues = function(_drawBG = true) {
		var _dim = attributes.dimension;
		preview_draw_final[0] = surface_verify(preview_draw_final[0], _dim[0], _dim[1]);
		preview_draw_final[1] = surface_verify(preview_draw_final[1], _dim[0], _dim[1]);
		
		if(nodeTool != noone && !nodeTool.applySelection) {
			for( var i = 0, n = array_length(preview_draw_final); i < n; i++ )
				surface_clear(preview_draw_final[i]);
			return preview_draw_final[0];
		}
		
		var val = getOutputSurface();
		var bg  = 0;
		
		surface_set_shader(preview_draw_final[!bg], noone, true, BLEND.over);
			if(_drawBG) draw_surface_safe(val);
		surface_reset_shader();
		
		if(nodeTool == noone && selection.is_selected) {
			var _fore = selection.selection_surface;
			var _pos  = selection.selection_position;
			
			surface_set_shader(preview_draw_final[bg], sh_blend_normal_ext);
				shader_set_surface("fore",    _fore);
				shader_set_2("dimension",     surface_get_dimension(preview_draw_final[bg]));
				shader_set_2("foreDimension", surface_get_dimension(_fore));
				shader_set_2("position",      _pos);
				
				draw_surface_safe(preview_draw_final[!bg]);
			surface_reset_shader();
			bg = !bg;
		}
		
		if(color_picking) return preview_draw_final[!bg];
		
		surface_set_shader(preview_draw_final[bg], isUsingTool("Eraser")? sh_blend_subtract_alpha : sh_blend_normal, true, BLEND.over);
			shader_set_surface("fore",    preview_draw_surface);
			shader_set_i("useMask",       false);
			shader_set_i("preserveAlpha", false);
			shader_set_f("opacity",       1);
			
			draw_surface_safe(preview_draw_final[!bg]);
		surface_reset_shader();
		bg = !bg;
		
		return preview_draw_final[!bg];
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return getPreviewValues()};
	
	////- Serialize
	
	static doSerialize = function(_map) {
		surface_store_buffers();
		var _buff = array_create(attributes.frames);
		
		for( var i = 0; i < attributes.frames; i++ ) {
			var comp = buffer_compress(canvas_buffer[i], 0, buffer_get_size(canvas_buffer[i]));
			_buff[i] = buffer_base64_encode(comp, 0, buffer_get_size(comp));
		}
			
		_map.surfaces = _buff;
	}
	
	static postApplyDeserialize = function() {
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
	}
	
	static onCleanUp = function() {
		surface_array_free(canvas_surface);
	}
	
	////- Actions
	
	on_drop_file = function(path) {
		loadImagePath(path);
		return true;
	}
	
	static loadImagePath = function(path, live = false) {
		if(!file_exists_empty(path)) return noone;
		
		var _spr = sprite_add(sprite_path_check_depth(path), 0, 0, 0, 0, 0);
		if(_spr == -1) return noone;
		
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		
		var _s  = surface_create(_sw, _sh);
		surface_set_shader(_s, noone)
			draw_sprite(_spr, 0, 0, 0);
		surface_reset_shader();
		
		sprite_delete(_spr);
		
		attributes.dimension = [_sw, _sh];
		inputs[0].setValue([_sw, _sh]);
		setCanvasSurface(_s);
		surface_store_buffer();
		
		if(live) {
			live_edit   = true;
			live_target = path;
		}
	
		return self;
	} 
	
	static dropPath = function(path) {
		if(is_array(path)) path = array_safe_get(path, 0);
		if(!file_exists_empty(path)) return noone;
		
		if(selection.is_selected)
			selection.apply();
		
		var _spr = sprite_add(sprite_path_check_depth(path), 0, 0, 0, 0, 0);
		if(_spr == -1) return noone;
		
		var _sw = sprite_get_width(_spr);
		var _sh = sprite_get_height(_spr);
		
		var surf = surface_create(_sw, _sh);
		surface_set_shader(surf, noone);
			draw_sprite(_spr, 0, 0, 0);
		surface_reset_shader();
		
		sprite_delete(_spr);
		
		selection.createSelectionFromSurface(surf);
		surface_free(surf);
	}

	static transferData = function() {
		var _dat = inputs[19].getValue();
		var _dim = inputs[20].getValue();
		if(!is_surface(_dat)) return;
		
		var _canSurf = getCanvasSurface();
		var _sw = surface_get_width_safe(_dat);
		var _sh = surface_get_height_safe(_dat);
		
		if(_dim) {
			attributes.dimension = [_sw, _sh];
			inputs[0].setValue([_sw, _sh]);
			
			_canSurf = surface_verify(_canSurf, _sw, _sh);
		}
		
		surface_set_shader(_canSurf);
			draw_surface(_dat, 0, 0);
		surface_reset_shader();
		
		setCanvasSurface(_canSurf);
		surface_store_buffer();
	}
	
	static pasteSurface = function(_cursor = false) {
		var _str = json_try_parse(clipboard_get_text(), noone);
		if(!struct_has(_str, "buffer")) return;
		
		var _surf = surface_decode(_str);
		if(!surface_exists(_surf)) return;
		
		selection.createSelectionFromSurface(_surf);
		surface_free_safe(_surf);
		
		var _sel_x = 0;
		var _sel_y = 0;
		
		if(has(_str, "position")) {
			_sel_x = _str.position[0];
			_sel_y = _str.position[1];
		}
		
		if(_cursor) {
			_sel_x = mouse_cur_x;
			_sel_y = mouse_cur_y;
		}
		
		selection.selection_position = [ _sel_x, _sel_y ];
	}
}

function timelineItemNode_Canvas(_node) : timelineItemNode(_node) constructor {
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_Canvas))         return;
		if(!node.attributes.show_timeline) return;
		
		var _surfs = node.output_surface;
		var _surf, _rx, _ry;
		var _rx0, _ry0;
		var _h = h;
		
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
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, _rx0, _ry0, _h, _h, CDEF.main_dkblack);
			
			if(i == node.preview_index) {
				draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
				draw_sprite_stretched_ext(THEME.box_r2, 1, _rx0, _ry0, _h, _h, COLORS._main_accent);
				
			} else {
				draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, 0.1);
				draw_sprite_stretched_ext(THEME.box_r2, 1, _rx0, _ry0, _h, _h, COLORS._main_icon, 0.3);
			}
			
			if(_hover && point_in_rectangle(_msx, _msy, _rx0, _ry0, _rx0 + _h, _ry0 + _h)) {
				draw_sprite_stretched_add(THEME.box_r2, 1, _rx0, _ry0, _h, _h, c_white, 0.3);
				_hov = true;
				
				if(mouse_press(mb_left, _focus))
					node.setFrame(i);
			}
		}
		
		var _fr = round((_msx - _x) / _s);
		if(_fr < 1 || _fr > NODE_TOTAL_FRAMES) return _hov;
		
		var _frAdd = _fr - node.attributes.frames;
		if(!_hov && _chv && _frAdd < 16) {
			
			_rx  = _x + _fr * _s;
			_rx0 = _rx - _h / 2;
			
			draw_sprite_stretched_ext(THEME.box_r2, 0, _rx0, _ry0, _h, _h, CDEF.main_dkblack);
			draw_sprite_stretched_ext(THEME.box_r2, 1, _rx0, _ry0, _h, _h, COLORS._main_value_positive, 0.75);
			
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