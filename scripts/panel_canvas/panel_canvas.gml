function Panel_Canvas() : PanelContent() constructor {
	context_str  = "Canvas";
	title        = "Canvas";
	auto_pin     = true;
	title_height = 0;
	
	w = min(WIN_W, ui(1200));
	h = min(WIN_H, ui(800));
	
	 node = undefined;
	_node = undefined;
	
	#region hotkey
		var ctx = context_str;
		var n = MOD_KEY.none;
    	var c = MOD_KEY.ctrl;
    	var s = MOD_KEY.shift;
    	var a = MOD_KEY.alt;
    	
		registerFunction(ctx, "Swap Color",      "X", n, function() /*=>*/ {return swapColor()} );
		
		registerFunction(ctx, "Flip Horizontal", "F", n, function() /*=>*/ {return flipH()} );
		registerFunction(ctx, "Flip Vertical",   "F", s, function() /*=>*/ {return flipV()} );
		
		registerFunction(ctx, "Rotate CW",       "R", n, function() /*=>*/ {return rotateCCW()} );
		registerFunction(ctx, "Rotate CCW",      "R", s, function() /*=>*/ {return rotateCW()}  );
	#endregion
	
	#region preview
		node_dimension  = [1,1];
		
		content_surface = undefined;
		preview_surface = undefined;
		
		preview_x = 0;
		preview_y = 0;
		preview_s = 1;
		
		view_dragging = false;
		view_drag_sx  = 0;
		view_drag_sy  = 0;
		view_drag_mx  = 0;
		view_drag_my  = 0;
		
		hover_content = false;
	#endregion
	
	#region tool
		tool_current   = undefined;
		tool_color     = ca_white;
		tool_color_sub = ca_black;
	#endregion
	
	#region global settings
		resize_editor = new __Simple_Editor( "", button(function() /*=>*/ { setTool(new canvas_s_tool_resize(self)); }).setTooltip("Resize...")
			.setBaseSprite(THEME.button_hide_fill).setIcon(THEME.resize, 0, COLORS._main_icon_light, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} );
		
		rotate_editor = new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_rotate), 
			function(b) /*=>*/ { if(b == 0) rotateCCW(); else rotateCW(); }).iconPad(ui(6)).setTooltips([ 
				new tooltipHotkey( "Rotate CW",  ctx, "Rotate CW"  ), 
				new tooltipHotkey( "Rotate CCW", ctx, "Rotate CCW" ) 
			]), function() /*=>*/ {return -1}, function(b) /*=>*/ {} );
		
		flip_editor = new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_flip), 
			function(b) /*=>*/ { if(b == 0) flipH(); else flipV(); }).iconPad(ui(6)).setTooltips([ 
				new tooltipHotkey( "Flip Horizontal", ctx, "Flip Horizontal" ), 
				new tooltipHotkey( "Flip Vertical",   ctx, "Flip Vertical"   ) 
			]), function() /*=>*/ {return -1}, function(b) /*=>*/ {} );
		
		no_tool_settings = [
			resize_editor, 
			-1, 
			rotate_editor, 
			flip_editor, 
		];
	#endregion
	
	#region draw settings
		drawing_surface       = undefined;
		brush_surface         = undefined;
		brush_outline_surface = undefined;
		
		draw_layer        = 0;
		draw_layer_editor = new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_draw_layer), 
			function(b) /*=>*/ { draw_layer = b; }).iconPad(ui(6)), function() /*=>*/ {return draw_layer}, function(b) /*=>*/ { draw_layer = b; } );
		
		mirror        = [0,0,0];
		mirror_pos_x  = 0;
		mirror_pos_y  = 0;
		mirror_edit   = new checkBoxGroup( THEME.canvas_mirror, function(v,i) /*=>*/ { 
			if(i == 0) {
				mirror_pos_x = 0;
				mirror_pos_y = 0;
			} else mirror[i] = v; 
		}).setTooltips( [ "Reset Mirror", "Mirror Vertical", "Mirror Horizontal" ] );
			
		mirror_editor = new __Simple_Editor( "", mirror_edit, function() /*=>*/ {return mirror}, function(b) /*=>*/ { mirror = b; } );
		
		mirror_dragging = undefined;
		mirror_drag_sx  = 0;
		mirror_drag_sy  = 0;
		mirror_drag_mx  = 0;
		mirror_drag_my  = 0;
		
		draw_settings = [
			draw_layer_editor,
			mirror_editor,
		];
	#endregion
	
	#region view settings
		tile        = [0,0];
		tile_edit   = new checkBoxGroup( THEME.canvas_tile, function(v,i) /*=>*/ { tile[i] = v; }).setTooltips( [ "Tile Vertical", "Tile Horizontal" ] );
		tile_editor = new __Simple_Editor( "", tile_edit, function() /*=>*/ {return tile}, function(b) /*=>*/ { tile = b; } );
		
		grid_show   = false;
		grid_pixel  = false;
		grid_size   = 8;
		grid_color  = cola(c_white, .2);
		grid_editor = new __Simple_Editor( "", button(function() /*=>*/ {return dialogPanelCall(
				new Panel_Canvas_Grid_Setting(self), mouse_mx - ui(8), mouse_my + ui(8), { anchor: ANCHOR.right | ANCHOR.top }
			)}).setTooltip("Grid Settings...").setBaseSprite(THEME.button_hide_fill).setIcon(THEME.icon_grid_setting, 1, COLORS._main_icon_light, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} );
		
		view_settings = [
			tile_editor,
			grid_editor, 
		];
	#endregion
	
	#region selection settings
		select_bool       = 0;
		select_bool_fixed = 0;
		select_cleanEdge  = 0;
		
		select_bool_editor = new __Simple_Editor( "", new buttonGroup(array_create(4, THEME.canvas_boolean), function(b) /*=>*/ {
			select_bool_fixed = select_bool_fixed == b? 0 : b;
		}).iconPad(ui(6)), function() /*=>*/ {return select_bool_fixed? select_bool_fixed : select_bool}, function(b) /*=>*/ { select_bool_fixed = b; } );
		
		select_inter_editor = new __Simple_Editor( "", new buttonGroup(array_create(2, THEME.canvas_interpolate), function(b) /*=>*/ {
			select_cleanEdge = b;
		}).iconPad(ui(6)), function() /*=>*/ {return select_cleanEdge}, function(b) /*=>*/ { select_cleanEdge = b; } );
		
		selector_settings = [
			select_bool_editor,
			-1, 
			rotate_editor,
			flip_editor,
			-1,
			select_inter_editor, 
		];
	#endregion
	
	////- Node
	
	function getResources()   { return node.resources; }
	function getResource(ind) { return array_safe_get_fast(node.resources, ind, noone); }
	
	////- Tool
	
	function resetTool() { 
		if(tool_current) tool_current.destroy();
		tool_current = undefined; 
	}
	
	function setTool(_tool) {
		if(_tool == undefined) return resetTool();
		tool_current = _tool;
		tool_current.init(node);
	}
	
	////- View
	
	function fullView() {
		if(!is(node, Node_Canvas_S)) {
			preview_x = 0;
			preview_y = 0;
			preview_s = 1;
			return;
		}
		
		node_dimension = node.attributes.dimension;
		
		var pad = ui(32);
		preview_s = min(
			(w - pad * 2) / node_dimension[0], 
			(h - pad * 2) / node_dimension[1], 
		);
		
		preview_x = w / 2 - node_dimension[0] * preview_s / 2;
		preview_y = h / 2 - node_dimension[1] * preview_s / 2;
	}
	
	function setViewZoom(_s) {
		preview_s = _s;
		
		preview_x = w/2 - node_dimension[0] * _s / 2;
		preview_y = h/2 - node_dimension[1] * _s / 2;
	}
	
	function getSurface() {
		content_surface = surface_verify(content_surface, node.attributes.dimension[0], node.attributes.dimension[1]);
		surface_set_shader(content_surface, noone, true, BLEND.over);
			draw_surface_safe(node.outputs[0].getValue(), 0, 0);
		surface_reset_shader();
	}
	
	////- Selection
	
	#region select
		selecting      = false;
		selection_mask = undefined;
		selection_cont = undefined;
		
		select_crop_mask = undefined;
		select_crop_cont = undefined;
		
		selection_x    = 0;
		selection_y    = 0;
		selection_w    = 0;
		selection_h    = 0;
		selection_rot  = 0;
		
		select_edit     = undefined;
		select_edit_mx  = 0; 
		select_edit_my  = 0;
		
		select_edit_x   = 0;
		select_edit_y   = 0;
		select_edit_cx  = 0;
		select_edit_cy  = 0;
		select_edit_w   = 1;
		select_edit_h   = 1;
		select_edit_rot = 0;
		
		select_edit_rd  = 0;
	#endregion
	
	static applySelection = function(_clear = true) {
		if(!selecting) return;
		selecting = false;
		
		node_dimension  = node.attributes.dimension;
		var output_surface = surface_create(node_dimension[0], node_dimension[1]);
		
		surface_set_shader(output_surface, sh_canvas_surface_blend);
			shader_set_2( "dimension",  node_dimension  );
			shader_set_s( "bg",         content_surface );
			shader_set_i( "layer",      0               );
			
			shader_set_i( "selecting",  false    );
			
			shader_set_i( "erase",      0        );
			shader_set_c( "color",      ca_white );
			
			shader_set_i( "mirror_x",   0        );
			shader_set_i( "mirror_y",   0        );
			
			draw_surface(selection_cont, 0, 0);
		surface_reset_shader();
		
		if(_clear) {
			surface_clear(selection_mask);
			surface_clear(selection_cont);
		}
		
		applyToNode(output_surface, true);
	}
	
	static createSelection = function(_mask) {
		if(selecting) applySelection(false);
		selecting = true;
		
		var _dim = node.attributes.dimension;
		
		selection_mask = surface_verify(selection_mask, _dim[0], _dim[1]);
		selection_cont = surface_verify(selection_cont, _dim[0], _dim[1]);
		
		var boolType = select_bool_fixed? select_bool_fixed : select_bool;
		
		surface_set_shader(selection_mask, noone, boolType == 0);
			if(boolType == 2) BLEND_SUBTRACT
			if(boolType == 3) BLEND_MULTIPLY
			draw_surface(_mask, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(selection_cont, sh_canvas_selection_multiply, true, BLEND.over);
			shader_set_s( "mask", selection_mask );
			draw_surface(content_surface, 0, 0);
		surface_reset_shader();
		
		surface_set_target(content_surface);
			BLEND_SUBTRACT
			draw_surface(selection_mask, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_clear(_mask);
		
		var _bbox = surface_get_bbox(selection_mask);
		selection_x   = _bbox[0];
		selection_y   = _bbox[1];
		selection_w   = _bbox[2];
		selection_h   = _bbox[3];
		selection_rot = 0;
		
		if(selection_w < 1 || selection_h < 1) {
			selecting = false;
			return;
		}
		
		select_crop_mask = surface_verify(select_crop_mask, selection_w, selection_h);
		select_crop_cont = surface_verify(select_crop_cont, selection_w, selection_h);
		
		surface_set_target(select_crop_mask);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface(selection_mask, -selection_x, -selection_y);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(select_crop_cont);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface(selection_cont, -selection_x, -selection_y);
			BLEND_NORMAL
		surface_reset_target();
		
	}
	
	static deleteSelection = function(_apply = true) {
		if(!selecting) return;
		selecting = false;
		
		surface_clear(selection_mask);
		surface_clear(selection_cont);
		if(_apply) applyToNode(content_surface, false);
	}
	
	static recalculateSelection = function() {
		var _bbox = surface_get_bbox(selection_mask);
		selection_x   = _bbox[0];
		selection_y   = _bbox[1];
		selection_w   = _bbox[2];
		selection_h   = _bbox[3];
		selection_rot = 0;
	}
	
	////- Draw
	
	static applyToNode = function(_surf, _free = false) {
		recordAction(ACTION_TYPE.custom, function(data, _undo) /*=>*/ { 
			var _px = node.pixel_data;
			node.pixel_data = data.pixel_data;
			data.pixel_data = _px;
			node.triggerRender();
			node.update();
			getSurface();
			
		}, { pixel_data : node.pixel_data }).setName("Edit canvas");
		
		var buff = buffer_create(1, buffer_grow, 1);
		buffer_get_surface(buff, _surf, 0);
		node.pixel_data = buff;
		node.triggerRender();
		node.update();
		getSurface();
		
		if(_free) surface_free(_surf);
	}
	
	static applySurface = function(_surf, _erase = false) {
		node_dimension  = node.attributes.dimension;
		
		var output_surface = surface_create(node_dimension[0], node_dimension[1]);
		var lay = tool_current && tool_current.overrideLayer? 0 : draw_layer;
		var col = tool_current && tool_current.overrideColor? ca_white : tool_color;
				
		surface_set_shader(output_surface, sh_canvas_surface_blend);
			shader_set_2( "dimension",  node_dimension  );
			shader_set_s( "bg",         content_surface );
			shader_set_i( "layer",      lay             );
			
			shader_set_i( "selecting",  selecting       );
			shader_set_s( "selectMask", selection_mask  );
			shader_set_s( "selectSurf", selection_cont  );
			
			shader_set_i( "erase",      _erase          );
			shader_set_c( "color",      col             );
			
			shader_set_i( "mirror_x",   mirror[1]       );
			shader_set_i( "mirror_y",   mirror[2]       );
			shader_set_f( "mirror_dx",  mirror_pos_x    );
			shader_set_f( "mirror_dy",  mirror_pos_y    );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		surface_clear(_surf);
		
		applyToNode(output_surface, true);
	}
	
	static viewManipulation = function() {
		if(pFOCUS) {
			if(key_press(ord("F"))) fullView();
			
			if(key_press(ord("1"))) setViewZoom(1);
			if(key_press(ord("2"))) setViewZoom(2);
			if(key_press(ord("3"))) setViewZoom(3);
			if(key_press(ord("4"))) setViewZoom(4);
			if(key_press(ord("5"))) setViewZoom(8);
			if(key_press(ord("6"))) setViewZoom(16);
		}
			
		if(pHOVER) {
			if(MOUSE_WHEEL != 0) {
				var _ss = preview_s;
				
				var mox = (mx - preview_x) / preview_s;
				var moy = (my - preview_y) / preview_s;
					
				if(MOUSE_WHEEL > 0) { preview_s = clamp(preview_s * 1.2, 0.025, 128); }
				if(MOUSE_WHEEL < 0) { preview_s = clamp(preview_s * 0.8, 0.025, 128); }
				
				var mnx = (mx - preview_x) / preview_s;
				var mny = (my - preview_y) / preview_s;
				
				preview_x += (mnx - mox) * preview_s;
				preview_y += (mny - moy) * preview_s;
			}
			
			if(mouse_press(mb_middle, pFOCUS)) {
				view_dragging = true;
				view_drag_sx  = preview_x;
				view_drag_sy  = preview_y;
				view_drag_mx  = mx;
				view_drag_my  = my;
			}
		}
		
		if(view_dragging) {
			preview_x = view_drag_sx + mx - view_drag_mx;
			preview_y = view_drag_sy + my - view_drag_my;
			
			if(mouse_release(mb_middle)) {
				view_dragging = false;
			}
		}
	}
	
	function drawContent(panel) {
		if(!is(node, Node_Canvas_S)) return;
		
		var _hover_content = hover_content;
		hover_content = pHOVER;
		
		#region view
			if(_node != node) {
				_node = node;
				fullView();
			}
			
			viewManipulation();
		#endregion
		
		#region bg
			var cc = PROJECT.previewSetting.bg_color;
    		if(cc == -1) cc = COLORS.panel_preview_bg;
    		
    		var ch = PROJECT.previewSetting.bg_color_ch;
    		if(ch == -1) ch = COLORS.panel_preview_transparent;
    		
    		var _ts = max(preview_s, .1);
    		draw_clear(cc);
    		draw_sprite_tiled_ext(s_transparent, 0, preview_x, preview_y, _ts, _ts, ch, 1);
		#endregion
		
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		
		#region dimension
			node_dimension  = node.attributes.dimension;
			
			surf_w  = node_dimension[0];
			surf_h  = node_dimension[1];
			surf_pw = surf_w * preview_s;
			surf_ph = surf_h * preview_s;
			
			if(!surface_valid(content_surface, surf_w, surf_h))
				getSurface();
		#endregion
		
		#region selection draw
			if(selecting) {
				selection_mask = surface_verify(selection_mask, surf_w, surf_h);
				selection_cont = surface_verify(selection_cont, surf_w, surf_h);
				
				var sx = selection_w / surface_get_width(select_crop_mask);
				var sy = selection_h / surface_get_height(select_crop_mask);
				
				surface_set_shader(selection_mask, sh_sample, true, BLEND.over);
					shader_set_2( "sampleDimension", [ selection_w, selection_h ]   );
					shader_set_i( "interpolation",   select_cleanEdge * 6 );
					shader_set_i( "sampleMode",      0 );
				    shader_set_i( "useUvMap",        0 );
					
					draw_surface_ext_safe(select_crop_mask, selection_x, selection_y, sx, sy, selection_rot);
				surface_reset_shader();
				
				surface_set_shader(selection_cont, sh_sample, true, BLEND.over);
					shader_set_2( "sampleDimension", [ selection_w, selection_h ]   );
					shader_set_i( "interpolation",   select_cleanEdge * 6 );
					shader_set_i( "sampleMode",      0 );
				    shader_set_i( "useUvMap",        0 );
					
					draw_surface_ext_safe(select_crop_cont, selection_x, selection_y, sx, sy, selection_rot);
				surface_reset_shader();
			}
		#endregion
		
		#region preview
			preview_surface = surface_verify(preview_surface, surf_w, surf_h);
			
			if(tool_current) {
				if(tool_current.preview_override) {
					surface_set_shader(preview_surface, noone, true, BLEND.over);
						draw_surface_safe(tool_current.preview_override, 0, 0);
					surface_reset_shader();
					
				} else {
					var lay = tool_current && tool_current.overrideLayer? 0 : draw_layer;
					var col = tool_current && tool_current.overrideColor? ca_white : tool_color;
					
					surface_set_shader(preview_surface, sh_canvas_surface_blend, true, BLEND.over);
						shader_set_2( "dimension",  node_dimension     );
						shader_set_s( "bg",         content_surface    );
						shader_set_i( "layer",      lay                );
						
						shader_set_i( "selecting",  selecting          );
						shader_set_s( "selectMask", selection_mask     );
						shader_set_s( "selectSurf", selection_cont     );
						
						shader_set_i( "erase",      tool_current.erase );
						shader_set_c( "color",      col                );
						
						shader_set_i( "mirror_x",   mirror[1]          );
						shader_set_i( "mirror_y",   mirror[2]          );
						shader_set_f( "mirror_dx",  mirror_pos_x       );
						shader_set_f( "mirror_dy",  mirror_pos_y       );
						
						draw_surface_safe(drawing_surface, 0, 0);
					surface_reset_shader();
				}
				
			} else {
				surface_set_shader(preview_surface, sh_canvas_surface_blend_selection, true, BLEND.over);
					shader_set_i( "selecting",  selecting          );
					shader_set_s( "selectSurf", selection_cont     );
					
					draw_surface(content_surface, 0, 0);
				surface_reset_shader();
			}
			
			if(tile[0] && tile[1]) draw_surface_tiled_ext_safe( preview_surface, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
			else if(tile[0])       draw_surface_tiled_hori(     preview_surface, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
			else if(tile[1])       draw_surface_tiled_vert(     preview_surface, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
			else                   draw_surface_ext(            preview_surface, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
		#endregion
		
		#region overlay
			brush_outline_surface = surface_verify(brush_outline_surface, w, h);
			
			if(selecting && !select_edit) {
				surface_set_target(brush_outline_surface);
					DRAW_CLEAR
					draw_surface_ext(selection_mask, preview_x, preview_y, preview_s, preview_s, 0, c_white, 1);
				surface_reset_target();
				
				shader_set(sh_canvas_preview_outline_selection);
				shader_set_2( "dimension", [w,h]        );
				shader_set_f( "time",      current_time / 100 );
				shader_set_f( "scale",     preview_s    );
				shader_set_f( "size",      ui(6)        );
				
				draw_surface(brush_outline_surface, 0, 0);
				shader_reset();
			}
			
			if(tool_current) {
				surface_set_target(brush_outline_surface);
					DRAW_CLEAR
					tool_current.drawOutline(preview_x, preview_y, preview_s);
				surface_reset_target();
				
				shader_set(sh_canvas_preview_outline);
				shader_set_2( "dimension", [w,h] );
				draw_surface(brush_outline_surface, 0, 0);
				shader_reset();
					
				if(_hover_content && is_just_surface(brush_surface)) {
					var _dpx = preview_x + (mpx - ceil(surface_get_width(brush_surface)  / 2) + 1) * preview_s;
					var _dpy = preview_y + (mpy - ceil(surface_get_height(brush_surface) / 2) + 1) * preview_s;
					
					surface_set_target(brush_outline_surface);
						DRAW_CLEAR
						draw_surface_ext(brush_surface, _dpx, _dpy, preview_s, preview_s, 0, c_white, 1);
					surface_reset_target();
					
					shader_set(sh_canvas_preview_outline);
					shader_set_2( "dimension", [w,h] );
					draw_surface(brush_outline_surface, 0, 0);
					shader_reset();
				}
			}
		#endregion
		
		#region selection edit
			if(selecting && tool_current && tool_current.isSelector) {
				var hovType = undefined;
				
				var hovMaskPix = surface_getpixel(selection_mask, mpx, mpy);
				if(hovMaskPix > 0) {
					hovType = 9;
					CURSOR_SPRITE = THEME.cursor_move; 
				}
				
				var cx = selection_x + selection_w / 2;
				var cy = selection_y + selection_h / 2;
				var p  = point_rotate(cx, cy, selection_x, selection_y, selection_rot);
				    cx = p[0];
				    cy = p[1];
				
				var cdx = preview_x + cx * preview_s;
				var cdy = preview_y + cy * preview_s;
				draw_anchor(0, cdx, cdy, ui(6), 2);
				
				var s0x = preview_x + (selection_x) * preview_s;
				var s0y = preview_y + (selection_y) * preview_s;
				
				var p   = point_rotate_origin(selection_w/2, -selection_h/2, selection_rot);
				var s1x = preview_x + (cx + p[0]) * preview_s;
				var s1y = preview_y + (cy + p[1]) * preview_s;
				
				var p   = point_rotate_origin(-selection_w/2, selection_h/2, selection_rot);
				var s2x = preview_x + (cx + p[0]) * preview_s;
				var s2y = preview_y + (cy + p[1]) * preview_s;
				
				var p   = point_rotate_origin(selection_w/2, selection_h/2, selection_rot);
				var s3x = preview_x + (cx + p[0]) * preview_s;
				var s3y = preview_y + (cy + p[1]) * preview_s;
				
				var r = ui(10);
				
				if(pHOVER) {
					if(hovType == undefined) {
						var rr = r + ui(12);
						if(point_in_circle(mx, my, s0x, s0y, rr)) { hovType = 5; CURSOR_SPRITE = THEME.cursor_rotate; }
						if(point_in_circle(mx, my, s1x, s1y, rr)) { hovType = 5; CURSOR_SPRITE = THEME.cursor_rotate; }
						if(point_in_circle(mx, my, s2x, s2y, rr)) { hovType = 5; CURSOR_SPRITE = THEME.cursor_rotate; }
						if(point_in_circle(mx, my, s3x, s3y, rr)) { hovType = 5; CURSOR_SPRITE = THEME.cursor_rotate; }
					}
					
					if(point_in_circle(mx, my, s0x, s0y, r)) { hovType = 1; CURSOR_SPRITE = THEME.cursor_scale_diag; }
					if(point_in_circle(mx, my, s1x, s1y, r)) { hovType = 2; CURSOR_SPRITE = THEME.cursor_scale_diag; }
					if(point_in_circle(mx, my, s2x, s2y, r)) { hovType = 3; CURSOR_SPRITE = THEME.cursor_scale_diag; }
					if(point_in_circle(mx, my, s3x, s3y, r)) { hovType = 4; CURSOR_SPRITE = THEME.cursor_scale_diag; }
					
				}
				
				draw_anchor(hovType == 1, s0x, s0y, r, 0);
				draw_anchor(hovType == 2, s1x, s1y, r, 0);
				draw_anchor(hovType == 3, s2x, s2y, r, 0);
				draw_anchor(hovType == 4, s3x, s3y, r, 0);
				
				if(select_edit) {
					var dx = (mx - select_edit_mx) / preview_s;
					var dy = (my - select_edit_my) / preview_s;
					hover_content = false;
					
					switch(select_edit) {
						case 9 : // move
							if(key_mod_press(SHIFT)) {
								if(abs(dx) < abs(dy)) dx = 0;
								if(abs(dx) > abs(dy)) dy = 0;
							}
							
							CURSOR_SPRITE = THEME.cursor_move; 
							selection_x = select_edit_x + dx;
							selection_y = select_edit_y + dy;
							break;
							
						case 1 : 
							CURSOR_SPRITE = THEME.cursor_scale_diag;
							var dp  = point_rotate_origin(dx, dy, -selection_rot);
							
							selection_w = select_edit_w - dp[0];
							selection_h = select_edit_h - dp[1];
							
							selection_x = select_edit_x + dx;
							selection_y = select_edit_y + dy;
							break;
						case 2 : 
							CURSOR_SPRITE = THEME.cursor_scale_diag;
							var dp  = point_rotate_origin(dx, dy, -selection_rot);
							selection_w = select_edit_w + dp[0];
							selection_h = select_edit_h - dp[1];
							
							var dp  = point_rotate_origin(0, dp[1], -selection_rot);
							selection_x = select_edit_x - dp[0];
							selection_y = select_edit_y + dp[1];
							break;
						case 3 : 
							CURSOR_SPRITE = THEME.cursor_scale_diag;
							var dp  = point_rotate_origin(dx, dy, -selection_rot);
							selection_w = select_edit_w - dp[0];
							selection_h = select_edit_h + dp[1];
							
							var dp  = point_rotate_origin(dp[0], 0, -selection_rot);
							selection_x = select_edit_x + dp[0];
							selection_y = select_edit_y - dp[1];
							break;
						case 4 : 
							CURSOR_SPRITE = THEME.cursor_scale_diag;
							var dp  = point_rotate_origin(dx, dy, -selection_rot);
							
							selection_w = select_edit_w + dp[0];
							selection_h = select_edit_h + dp[1];
							break;
							
						case 5 :
							CURSOR_SPRITE = THEME.cursor_rotate;
							var cx = select_edit_cx;
							var cy = select_edit_cy;
							var cdx = preview_x + cx * preview_s;
							var cdy = preview_y + cy * preview_s;
							draw_anchor(0, cdx, cdy, ui(16), 2);
				
							var ax = preview_x + cx * preview_s;
							var ay = preview_y + cy * preview_s;
							
							var a0 = point_direction(ax, ay, select_edit_mx, select_edit_my);
							var a1 = point_direction(ax, ay, mx, my);
							
							select_edit_mx  = mx;
							select_edit_my  = my;
							
							select_edit_rd += angle_difference(a1, a0);
							selection_rot   = select_edit_rot + select_edit_rd;
							
							if(key_mod_press(CTRL))  selection_rot = round(selection_rot);
							if(key_mod_press(SHIFT)) selection_rot = value_snap(selection_rot, 15);
							
							var p = point_rotate_origin(-select_edit_w/2, -select_edit_h/2, selection_rot);
							selection_x = cx + p[0];
							selection_y = cy + p[1];
							break;
					}
					
					if(mouse_lrelease()) {
						select_edit = undefined;
					}
					
				} else if(pHOVER && hovType) {
					hover_content = false;
					
					if(mouse_lpress(pFOCUS)) {
						select_edit      = hovType;
						select_edit_mx   = mx; 
						select_edit_my   = my;
						
						select_edit_x    = selection_x;
						select_edit_y    = selection_y;
						select_edit_cx   = cx;
						select_edit_cy   = cy;
						
						select_edit_w    = selection_w;
						select_edit_h    = selection_h;
						select_edit_rd   = 0;
						select_edit_rot  = selection_rot;
					}
				}
				
				if(pFOCUS && key_press(vk_delete)) deleteSelection();
			}
		#endregion
		
		#region tool
			drawing_surface = surface_verify(drawing_surface, surf_w, surf_h);
			
			if(tool_current) {
				if(tool_current.isSelector) {
					var bolc = select_bool_fixed? COLORS._main_accent : COLORS._main_icon_light;
					
					if(!tool_current.selecting) {
						select_bool = 0;
						
						if(key_mod_press(SHIFT)) {
							select_bool = 1;
							if(key_mod_press(ALT))  select_bool = 3;
							if(key_mod_press(CTRL)) select_bool = 2;
						}
					} else 
						bolc = COLORS._main_icon;
					
					select_bool_editor.editWidget.setBlend(bolc);
				}
				
				tool_current.canvas = self;
				tool_current.content_surface = content_surface;
				tool_current.step(_hover_content, pFOCUS, preview_x, preview_y, preview_s, mx, my);
				
				brush_surface = tool_current.drawBrush(brush_surface);
				tool_current.drawing(drawing_surface);
				
			}
		#endregion
		
		#region grid
			draw_set_color(COLORS.panel_preview_surface_outline);
			draw_rectangle(preview_x, preview_y, preview_x + surf_pw, preview_y + surf_ph, true);
			
			var x0 = preview_x;
			var y0 = preview_y;
			var x1 = preview_x + surf_w * preview_s;
			var y1 = preview_y + surf_h * preview_s;
			
			if(grid_pixel) {
				draw_set_color_alpha(grid_color, _color_get_a(grid_color) * .5);
				for( var i = 0; i <= surf_w; i++ ) {
					var gx = preview_x + i * preview_s;
					draw_line(gx, y0, gx, y1);
				}
				
				for( var i = 0; i <= surf_h; i++ ) {
					var gy = preview_y + i * preview_s;
					draw_line(x0, gy, x1, gy);
				}
				
				draw_set_alpha(1);
			}
			if(grid_show) {
				draw_set_color_alpha(grid_color, _color_get_a(grid_color));
				for( var i = 0; i <= surf_w; i += grid_size ) {
					var gx = preview_x + i * preview_s;
					draw_line(gx, y0, gx, y1);
				}
				
				for( var i = 0; i <= surf_h; i += grid_size ) {
					var gy = preview_y + i * preview_s;
					draw_line(x0, gy, x1, gy);
				}
				
				draw_set_alpha(1);
			}
			
		#endregion
		
		#region mirror
			if(mirror[1]) { // vertical
				var cx = surf_w / 2 + mirror_pos_x;
				
				var cdx = preview_x + cx * preview_s;
				var y0  = max(preview_y, ui(8));
				var y1  = min(preview_y + surf_h * preview_s, h - ui(8));
				
				draw_set_color(COLORS._main_accent);
				draw_line(cdx, y0, cdx, y1);
				
				var anc = 0;
				if(pHOVER && point_in_circle(mx, my, cdx, y0, ui(8))) {
					hover_content = false;
					anc = 1;
					
					if(mouse_lpress(pFOCUS)) {
						mirror_dragging = 1;
						mirror_drag_sx  = mirror_pos_x;
						mirror_drag_mx  = mx;
					}
				}
				
				draw_anchor(anc, cdx, y0, ui(8), 2);
				
				var anc = 0;
				if(pHOVER && point_in_circle(mx, my, cdx, y1, ui(8))) {
					hover_content = false;
					anc = 1;
					
					if(mouse_lpress(pFOCUS)) {
						mirror_dragging = 1;
						mirror_drag_sx  = mirror_pos_x;
						mirror_drag_mx  = mx;
					}
				}
				
				draw_anchor(anc, cdx, y1, ui(8), 2);
				
			}
			
			if(mirror[2]) { // horizontal
				var cy = surf_h / 2 + mirror_pos_y;
				
				var cdy = preview_y + cy * preview_s;
				var x0  = max(preview_x, ui(8));
				var x1  = min(preview_x + surf_w * preview_s, w - ui(8));
				
				draw_set_color(COLORS._main_accent);
				draw_line(x0, cdy, x1, cdy);
				
				var anc = 0;
				if(pHOVER && point_in_circle(mx, my, x0, cdy, ui(8))) {
					hover_content = false;
					anc = 1;
					
					if(mouse_lpress(pFOCUS)) {
						mirror_dragging = 2;
						mirror_drag_sx  = mirror_pos_x;
						mirror_drag_mx  = mx;
					}
				}
				
				draw_anchor(anc, x0, cdy, ui(8), 2);
				
				var anc = 0;
				if(pHOVER && point_in_circle(mx, my, x1, cdy, ui(8))) {
					hover_content = false;
					anc = 1;
					
					if(mouse_lpress(pFOCUS)) {
						mirror_dragging = 2;
						mirror_drag_sx  = mirror_pos_x;
						mirror_drag_mx  = mx;
					}
				}
				
				draw_anchor(anc, x1, cdy, ui(8), 2);
				
			}
			
			if(mirror_dragging == 1) {
				mirror_pos_x = mirror_drag_sx + round((mx - mirror_drag_mx) / preview_s);
				if(mouse_lrelease())
					mirror_dragging = undefined;
			}
			
			if(mirror_dragging == 2) {
				mirror_pos_y = mirror_drag_sy + round((my - mirror_drag_my) / preview_s);
				if(mouse_lrelease())
					mirror_dragging = undefined;
			}
		#endregion
		
		#region info
			var rx = w - ui(4);
			var ry = ui(4);
			
			var ls = THEME.box_r5_clr;
			var lc = CDEF.main_dark;
			
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			
			var tt = $"[{mpx}, {mpy}]";
			var tw = string_width(tt)  + ui(6);
			var th = string_height(tt) + ui(6);
			
			rx -= tw;
			draw_sprite_stretched_ext(ls, 0, rx, ry, tw, th, lc, .8);
			draw_text_add(rx + ui(3), ry + ui(3), tt);
			rx -= ui(2);
			
			var tt = $"x{preview_s}";
			var tw = string_width(tt)  + ui(6);
			var th = string_height(tt) + ui(6);
			
			rx -= tw;
			draw_sprite_stretched_ext(ls, 0, rx, ry, tw, th, lc, .8);
			draw_text_add(rx + ui(3), ry + ui(3), tt);
			rx -= ui(2);
			
		#endregion
	}
	
	////- Action
	
	static swapColor = function() {
		var r = tool_color;
		tool_color     = tool_color_sub;
		tool_color_sub = r;
	}
	
	static flipH = function() {
		if(selecting) {
			var sx = selection_x;
			var sy = selection_y;
			var sw = selection_w;
			var sh = selection_h;
			
			var cx = sx + sw / 2;
			var cy = sy + sh / 2;
			
			var dim = surface_get_dimension(select_crop_mask);
			
			var _baseMask = select_crop_mask;
			var _flipMask = surface_create(dim[0], dim[1]);
			
			var _baseCont = select_crop_cont;
			var _flipCont = surface_create(dim[0], dim[1]);
			
			surface_set_target(_flipMask);
				BLEND_OVERRIDE
				draw_surface_ext(_baseMask, dim[0], 0, -1, 1, 0, c_white, 1);
				BLEND_NORMAL
			surface_reset_target();
			
			surface_set_target(_flipCont);
				BLEND_OVERRIDE
				draw_surface_ext(_baseCont, dim[0], 0, -1, 1, 0, c_white, 1); 
				BLEND_NORMAL
			surface_reset_target();
			
			surface_free(select_crop_mask);
			surface_free(select_crop_cont);
			
			select_crop_mask = _flipMask;
			select_crop_cont = _flipCont;
			return;
		}
		
		var dim = node_dimension;
		var _baseSurf = content_surface;
		var _flipSurf = surface_create(dim[0], dim[1]);
		
		surface_set_target(_flipSurf);
			BLEND_OVERRIDE
			draw_surface_ext(_baseSurf, dim[0], 0, -1, 1, 0, c_white, 1);
			BLEND_NORMAL
		surface_reset_target();
		
		applyToNode(_flipSurf, true);
	}
	
	static flipV = function() {
		if(selecting) {
			var sx = selection_x;
			var sy = selection_y;
			var sw = selection_w;
			var sh = selection_h;
			
			var cx = sx + sw / 2;
			var cy = sy + sh / 2;
			
			var dim = surface_get_dimension(select_crop_mask);
			
			var _baseMask = select_crop_mask;
			var _flipMask = surface_create(dim[0], dim[1]);
			
			var _baseCont = select_crop_cont;
			var _flipCont = surface_create(dim[0], dim[1]);
			
			surface_set_target(_flipMask);
				BLEND_OVERRIDE
				draw_surface_ext(_baseMask, 0, dim[1], 1, -1, 0, c_white, 1);
				BLEND_NORMAL
			surface_reset_target();
			
			surface_set_target(_flipCont);
				BLEND_OVERRIDE
				draw_surface_ext(_baseCont, 0, dim[1], 1, -1, 0, c_white, 1);
				BLEND_NORMAL
			surface_reset_target();
			
			surface_free(select_crop_mask);
			surface_free(select_crop_cont);
			
			select_crop_mask = _flipMask;
			select_crop_cont = _flipCont;
			return;
		}
		
		var dim = node_dimension;
		var _baseSurf = content_surface;
		var _flipSurf = surface_create(dim[0], dim[1]);
		
		surface_set_target(_flipSurf);
			BLEND_OVERRIDE
			draw_surface_ext(_baseSurf, 0, dim[1], 1, -1, 0, c_white, 1);
			BLEND_NORMAL
		surface_reset_target();
		
		applyToNode(_flipSurf, true);
	}
	
	static rotateCCW = function() {
		if(selecting) {
			var cx = selection_x + selection_w / 2;
			var cy = selection_y + selection_h / 2;
			var p  = point_rotate(cx, cy, selection_x, selection_y, selection_rot);
			    cx = p[0];
			    cy = p[1];
			
			var p   = point_rotate_origin(-selection_w/2, -selection_h/2, selection_rot);
			var s0x = (cx + p[0]);
			var s0y = (cy + p[1]);
			
			selection_rot -= 90;
			
			var p   = point_rotate_origin(-selection_w/2, -selection_h/2, selection_rot);
			var s1x = (cx + p[0]);
			var s1y = (cy + p[1]);
			
			selection_x += s1x - s0x;
			selection_y += s1y - s0y;
			return;
		}
		
		var dim = node_dimension;
		var _baseSurf = content_surface;
		var _rotSurf  = surface_create(dim[1], dim[0]);
		
		surface_set_target(_rotSurf);
			BLEND_OVERRIDE
			draw_surface_ext(_baseSurf, dim[0], 0, 1, 1, -90, c_white, 1);
			BLEND_NORMAL
		surface_reset_target();
		
		applyToNode(_rotSurf, true);
	}

	static rotateCW = function() {
		if(selecting) {
			var cx = selection_x + selection_w / 2;
			var cy = selection_y + selection_h / 2;
			var p  = point_rotate(cx, cy, selection_x, selection_y, selection_rot);
			    cx = p[0];
			    cy = p[1];
			
			var p   = point_rotate_origin(-selection_w/2, -selection_h/2, selection_rot);
			var s0x = (cx + p[0]);
			var s0y = (cy + p[1]);
			
			selection_rot += 90;
			
			var p   = point_rotate_origin(-selection_w/2, -selection_h/2, selection_rot);
			var s1x = (cx + p[0]);
			var s1y = (cy + p[1]);
			
			selection_x += s1x - s0x;
			selection_y += s1y - s0y;
			return;
		}
		
		var dim = node_dimension;
		var _baseSurf = content_surface;
		var _rotSurf  = surface_create(dim[1], dim[0]);
		
		surface_set_target(_rotSurf);
			BLEND_OVERRIDE
			draw_surface_ext(_baseSurf, 0, dim[1], 1, 1, 90, c_white, 1);
			BLEND_NORMAL
		surface_reset_target();
		
		applyToNode(_rotSurf, true);
	}
}