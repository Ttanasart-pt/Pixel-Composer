#region 
	enum NODE_COMPOSE_DRAG {
		move,
		rotate,
		scale,
		box,
		anchor,
	}
	
	enum COMPOSE_OUTPUT_SCALING {
		first,
		largest,
		constant
	}
	
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Composite", "Anchor", "A");
		hotkeyCustom("Node_Composite", "Move",   "G");
		hotkeyCustom("Node_Composite", "Rotate", "R");
		hotkeyCustom("Node_Composite", "Scale",  "S");
	});
	
	function composite_transform_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surf_dragging  = noone;
		
		drag_position  = [ 0, 0 ];
		drag_positions = [];
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.dynamic_input_inspecting == noone && array_empty(node.surface_selecting)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_axis = -1;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			if(array_empty(node.surface_selecting)) {
				surf_dragging  = node.input_fix_len + node.dynamic_input_inspecting * node.data_length;
				
				var _val = node.inputs[surf_dragging + 1].getValue();
				drag_position[0] = _val[0];
				drag_position[1] = _val[1];
				
			} else {
				var _amo = array_length(node.inputs);
				drag_positions = array_verify(drag_positions, _amo);
				
				for( var i = 0; i < _amo; i++ ) drag_positions[i] = node.inputs[i].getValue();
				
				drag_position[0] = node.selection_bbox[4];
				drag_position[1] = node.selection_bbox[5];
			}
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard) { PANEL_PREVIEW.resetTool(); return; }
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var _dx = KEYBOARD_NUMBER ?? (_mx - drag_pmx) / PANEL_PREVIEW.canvas_s;
			var _dy = KEYBOARD_NUMBER ?? (_my - drag_pmy) / PANEL_PREVIEW.canvas_s;
			var _edit = false;
			
			if(array_empty(node.surface_selecting)) {
				var val = [ drag_position[0], drag_position[1] ];
				
				if(drag_axis == -1 || drag_axis == 0) val[0] = drag_position[0] + _dx;
				if(drag_axis == -1 || drag_axis == 1) val[1] = drag_position[1] + _dy;
				
				if(node.inputs[surf_dragging + 1].setValue(val)) _edit = true;
				
			} else {
				for( var i = 0, n = array_length(node.surface_selecting); i < n; i++ ) {
					var _suri = node.surface_selecting[i];
					var _orig = drag_positions[_suri + 1];
					
					var val = [ _orig[0], _orig[1] ];
					
					if(drag_axis == -1 || drag_axis == 0) val[0] = _orig[0] + _dx;
					if(drag_axis == -1 || drag_axis == 1) val[1] = _orig[1] + _dy;
					
					if(node.inputs[_suri + 1].setValue(val)) _edit = true;
				}
				
			}
			
			if(_edit) UNDO_HOLDING = true;
				
			draw_set_color(COLORS._main_icon);
			if(drag_axis == 0) draw_line_dashed(0, _y + drag_position[1] * _s, WIN_H, _y + drag_position[1] * _s);
			if(drag_axis == 1) draw_line_dashed(_x + drag_position[0] * _s, 0, _x + drag_position[0] * _s, WIN_W);
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Dragging";
			switch(drag_axis) {
				case 0 : _tooltipText += " X"; break;
				case 1 : _tooltipText += " Y"; break;
			}
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function composite_transform_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surf_dragging  = noone;
		
		drag_rotation   = 0;
		drag_rotations  = [];
		rotation_anchor = [ 0, 0 ];
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		rotate_acc = 0;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.dynamic_input_inspecting == noone && array_empty(node.surface_selecting)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			rotate_acc = 0;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			if(array_empty(node.surface_selecting)) {
				surf_dragging  = node.input_fix_len + node.dynamic_input_inspecting * node.data_length;
				
				drag_rotation   = node.inputs[surf_dragging + 2].getValue();
				rotation_anchor = node.inputs[surf_dragging + 1].getValue();
				
			} else {
				var _amo = array_length(node.inputs);
				drag_rotations = array_verify(drag_rotations, _amo);
				
				for( var i = 0; i < _amo; i++ ) drag_rotations[i] = node.inputs[i].getValue();
				
				rotation_anchor[0] = node.selection_bbox[4];
				rotation_anchor[1] = node.selection_bbox[5];
			}
			
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard) { PANEL_PREVIEW.resetTool(); return; }
			
			var _px = _x + rotation_anchor[0] * _s;
			var _py = _y + rotation_anchor[1] * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var _d0 = point_direction(_px, _py, drag_pmx, drag_pmy);
			var _d1 = point_direction(_px, _py, _mx, _my);
			
			drag_pmx = _mx;
			drag_pmy = _my;
			
			rotate_acc += angle_difference(_d1, _d0);
			
			var _dr   = KEYBOARD_NUMBER ?? rotate_acc;
			var _edit = false;
			
			if(array_empty(node.surface_selecting)) {
				var _rr = drag_rotation + _dr;
				if(node.inputs[surf_dragging + 2].setValue(_rr)) _edit = true;
					
			} else {
				for( var i = 0, n = array_length(node.surface_selecting); i < n; i++ ) {
					var _suri = node.surface_selecting[i];
					var _opos = drag_rotations[_suri + 1];
					var _orot = drag_rotations[_suri + 2];
					var _rr   = _orot + _dr;
					
					var _pp = point_rotate(_opos[0], _opos[1], rotation_anchor[0], rotation_anchor[1], _rr);
					
					if(node.inputs[_suri + 1].setValue(_pp)) _edit = true;
					if(node.inputs[_suri + 2].setValue(_rr)) _edit = true;
				}
				
			}
			
			if(_edit) UNDO_HOLDING = true;
				
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Rotating";
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function composite_transform_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surf_dragging  = noone;
		
		drag_scale   = [ 0, 0 ];
		drag_scales  = [];
		scale_anchor = [ 0, 0 ];
		axis_angle   = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.dynamic_input_inspecting == noone && array_empty(node.surface_selecting)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			drag_axis = -1;
			
			drag_pmx  = undefined;
			drag_pmy  = undefined;
			
			if(array_empty(node.surface_selecting)) {
				surf_dragging  = node.input_fix_len + node.dynamic_input_inspecting * node.data_length;
				var _val = node.inputs[surf_dragging + 3].getValue();
				drag_scale[0] = _val[0];
				drag_scale[1] = _val[1];
				
				var _val = node.inputs[surf_dragging + 1].getValue();
				scale_anchor[0] = _val[0];
				scale_anchor[1] = _val[1];
				
				axis_angle = node.inputs[surf_dragging + 2].getValue();
				
			} else {
				var _amo = array_length(node.inputs);
				drag_scales = array_verify(drag_scales, _amo);
				
				for( var i = 0; i < _amo; i++ ) drag_scales[i] = node.inputs[i].getValue();
				
				scale_anchor[0] = node.selection_bbox[4];
				scale_anchor[1] = node.selection_bbox[5];
				
				axis_angle = 0;
			}
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard) { PANEL_PREVIEW.resetTool(); return; }
			
			var _px = _x + scale_anchor[0] * _s;
			var _py = _y + scale_anchor[1] * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var _ss = point_distance(_mx, _my, _px, _py) / point_distance(drag_pmx, drag_pmy, _px, _py);
			var _sx = key_mod_press(SHIFT)? (_mx - _px) / (drag_pmx - _px) : _ss;
			var _sy = key_mod_press(SHIFT)? (_my - _py) / (drag_pmy - _py) : _ss;
			var _edit = false;
			
			if(array_empty(node.surface_selecting)) {
				var val = [drag_scale[0], drag_scale[1]];
				if(drag_axis == -1 || drag_axis == 0) val[0] = KEYBOARD_NUMBER == undefined? drag_scale[0] * _sx : drag_scale[0] + KEYBOARD_NUMBER;
				if(drag_axis == -1 || drag_axis == 1) val[1] = KEYBOARD_NUMBER == undefined? drag_scale[1] * _sy : drag_scale[1] + KEYBOARD_NUMBER;
				
				if(node.inputs[surf_dragging + 3].setValue(val)) _edit = true;
				
			} else {
				for( var i = 0, n = array_length(node.surface_selecting); i < n; i++ ) {
					var _suri = node.surface_selecting[i];
					var _opos = drag_scales[_suri + 1];
					var _osca = drag_scales[_suri + 3];
					
					var _ss = [_osca[0], _osca[1]];
					if(drag_axis == -1 || drag_axis == 0) _ss[0] = KEYBOARD_NUMBER == undefined? _osca[0] * _sx : _osca[0] + KEYBOARD_NUMBER;
					if(drag_axis == -1 || drag_axis == 1) _ss[1] = KEYBOARD_NUMBER == undefined? _osca[1] * _sy : _osca[1] + KEYBOARD_NUMBER;
					
					var _pp = [_opos[0], _opos[1]];
					_pp[0] = scale_anchor[0] + (_opos[0] - scale_anchor[0]) / _osca[0] * _ss[0];
					_pp[1] = scale_anchor[1] + (_opos[1] - scale_anchor[1]) / _osca[1] * _ss[1];
				
					if(node.inputs[_suri + 1].setValue(_pp)) _edit = true;
					if(node.inputs[_suri + 3].setValue(_ss)) _edit = true;
				}
				
			}
			
			if(_edit) UNDO_HOLDING = true;
			
			draw_set_color(COLORS._main_icon);
			if(drag_axis == 0) draw_line(_px - lengthdir_x(9999, axis_angle     ), _py - lengthdir_y(9999, axis_angle     ), 
			                             _px + lengthdir_x(9999, axis_angle     ), _py + lengthdir_y(9999, axis_angle     ));
			if(drag_axis == 1) draw_line(_px - lengthdir_x(9999, axis_angle + 90), _py - lengthdir_y(9999, axis_angle + 90), 
			                             _px + lengthdir_x(9999, axis_angle + 90), _py + lengthdir_y(9999, axis_angle + 90));
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Scaling";
			switch(drag_axis) {
				case 0 : _tooltipText += " X"; break;
				case 1 : _tooltipText += " Y"; break;
			}
			
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function composite_transform_tool_anchor(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		surf_dragging  = noone;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			if(node.dynamic_input_inspecting == noone) { PANEL_PREVIEW.resetTool(); return; }
			
			surf_dragging  = node.input_fix_len + node.dynamic_input_inspecting * node.data_length;
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard || surf_dragging == noone) { PANEL_PREVIEW.resetTool(); return; }
			
			if(mouse_press(mb_left) || key_press(vk_enter)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
		}
	}
	
#endregion

function Node_Composite(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Composite";
	dimension_index = -1;
	dynamic_input_inspecting = noone;
	preview_select_surface   = false;
	
	newInput(0, nodeValue_Padding(     "Padding", [0,0,0,0] ));
	newInput(1, nodeValue_Enum_Scroll( "Output dimension", COMPOSE_OUTPUT_SCALING.first, [ "First surface", "Largest surface", "Constant" ]));
	newInput(2, nodeValue_Dimension()).setVisible(false);
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []    ));
	newOutput(2, nodeValue_Output( "Dimension",   VALUE_TYPE.integer, [1,1] )).setVisible(false).setDisplay(VALUE_DISPLAY.vector);
	
	////- Attributes
	
	attribute_surface_depth();
	attribute_interpolation();
	attributes.layer_visible    = [];
	attributes.layer_selectable = [];
	properties_expand           = [];
	
	attributes.select_object = false;
	array_push(attributeEditors, "Selection");
	array_push(attributeEditors, ["Content-Based", function() /*=>*/ {return attributes.select_object}, new checkBox(function() /*=>*/ {return toggleAttribute("select_object", true)})]);
	
	////- Layers
	
	renaming        = noone;
	renaming_index  = noone;
	rename_text     = "";
	tb_rename       = textBox_Text(function(_n) /*=>*/ { 
		if(renaming == noone) return;
		
		     if(is_real(renaming))  inputs[renaming].setName( _n, true  );
		else if(is(renaming, Node)) renaming.setDisplayName(  _n, false );
		
		renaming       = noone;
		renaming_index = noone;
	}).setHide(1).setFont(f_p1);
	
	hold_visibility = true;
	hold_select		= true;
	
	layer_dragging	= noone;
	layer_remove	= -1;
	layer_height    = 0;
	layer_renderer	= new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		PROCESSOR_OVERLAY_CHECK
		
		var amo = getInputAmount();
		var lh  = ui(28);
		var eh  = ui(36);
		
		properties_expand = array_verify(properties_expand, amo);
		var _h = ui(4);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, layer_height, COLORS.node_composite_bg_blend, 1);
		
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		var ly   = _y + ui(4);
		var ssh  = lh - ui(4);
		var hoverIndex = noone;
		
		var _cy = ly;
		
		layer_remove = -1;
		for(var i = 0; i < amo; i++) {
			var ind   = amo - i - 1;
			var index = input_fix_len + ind * data_length;
			var _surf = current_data[index + 0];
			var _pos  = current_data[index + 1];
			var _inp  = inputs[index];
			var _junc = _inp.value_from? _inp.value_from.node : noone;
			
			var _bx = _x + _w - ui(24);
			var aa  = (ind != layer_dragging || layer_dragging == noone)? 1 : 0.5;
			var vis = array_safe_get_fast(_vis, ind);
			var sel = array_safe_get_fast(_sel, ind);
			
			var _exp = properties_expand[i];
			var _lh  = lh + ui(4) + _exp * eh;
			_h += _lh;
			
			if(_exp) { // expanded
				var _px = _x + ui(4);
				var _py = _cy + lh + ui(4);
				var _pw = _w - ui(8);
				var _ph = eh - ui(4);
				
				var _pww = (_pw - ui(8)) / 2 - ui(8);
				var _pwh = _ph - ui(8);
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, _px, _py, _pw, _ph, COLORS.node_composite_bg_blend, 1);
				
				var jn_bld = inputs[index + 4];
				var jn_alp = inputs[index + 5];
				
				var wd_bld = jn_bld.editWidget;
				var wd_alp = jn_alp.editWidget;
				
				var _param = new widgetParam(_px + ui(4), _py + ui(4), _pww, _pwh, jn_bld.showValue(), jn_bld.display_data, _m, layer_renderer.rx, layer_renderer.ry);
				    _param.font = f_p2;
				    
				wd_bld.setFocusHover(_focus, _hover);
				wd_bld.drawParam(_param);
				
				var _param = new widgetParam(_px + ui(4) + _pww + ui(8), _py + ui(4), _pww, _pwh, jn_alp.showValue(), jn_alp.display_data, _m, layer_renderer.rx, layer_renderer.ry);
				    _param.font = f_p2;
				    
				wd_alp.setFocusHover(_focus, _hover);
				wd_alp.drawParam(_param);
			} 
			
			#region draw buttons
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(16))) {
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
					
					if(mouse_press(mb_left, _focus))
						layer_remove = ind;
				} else 
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				
				var _bx = _x + ui(16 + 24);
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(12))) {
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, c_white);
					
					if(mouse_press(mb_left, _focus))
						hold_visibility = !_vis[ind];
						
					if(mouse_click(mb_left, _focus) && _vis[ind] != hold_visibility) {
						_vis[ind] = hold_visibility;
						triggerRender();
					}
				} else 
					draw_sprite_ui_uniform(THEME.junc_visible, vis, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * vis);
				
				_bx += ui(12 + 1 + 12);
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(12))) {
					draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, c_white);
					
					if(mouse_press(mb_left, _focus))
						hold_select = !_sel[ind];
						
					if(mouse_click(mb_left, _focus) && _sel[ind] != hold_select)
						_sel[ind] = hold_select;
				} else 
					draw_sprite_ui_uniform(THEME.cursor_select, sel, _bx, _cy + lh / 2, 1, COLORS._main_icon, 0.5 + 0.5 * sel);
				
				var hover = _hover && point_in_rectangle(_m[0], _m[1], _bx + ui(12 + 6), _cy, _x + _w - ui(48), _cy + lh - 1);
			#endregion
			
			#region draw surface
				var _sx0 = _bx + ui(12 + 6);
				var _sx1 = _sx0 + ssh;
				var _sy0 = _cy + ui(3);
				var _sy1 = _sy0 + ssh;
				
				if(is_surface(_surf)) {
					var _ssw = surface_get_width_safe(_surf);
					var _ssh = surface_get_height_safe(_surf);
					var _sss = min(ssh / _ssw, ssh / _ssh);
					draw_surface_ext_safe(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
				}				
				
				if(dynamic_input_inspecting == ind) draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_accent, 1);
				else                                draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_icon, 0.3);
			#endregion
			
			#region canvas layers
				var _junc_canvas = noone;
				var _jun_layer   = noone;
				if(canvas_draw != noone && _junc && struct_has(canvas_draw.layers, _junc.node_id)) {
					_jun_layer   = canvas_draw.layers[$ _junc.node_id];
					_junc_canvas = _jun_layer.canvas;
				}
			#endregion
			
			#region draw title
				var _txt = _inp.name;
				var _txx = _sx1 + ui(12);
				var _txy = _cy + lh / 2;
				
				if(_junc_canvas) hover = hover && _m[0] > _txx + ui(8 + 16);
				
				var tc = ind == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
				var tf = ind == dynamic_input_inspecting? f_p2b : f_p2;
				if(hover) tc = COLORS._main_text;
					
				draw_set_text(tf, fa_left, fa_center, tc);
				
				if(canvas_draw != noone && _junc_canvas)
					_txt = _junc_canvas.display_name;
				
				if(renaming_index == index) {
					tb_rename.setFocusHover(_focus, _hover);
					tb_rename.draw(_txx, _cy, _w - ui(172), lh, rename_text, _m);
				
				} else {
					var _txw = string_width(_txt);
					var _txh = string_height(_txt);
					
					if(_junc_canvas) {
						var _icx = _txx + ui(8);
						var _icy = _txy;
						var _icc = COLORS._main_icon;
						var _ica = aa * .8;
						
						if(_hover && point_in_circle(_m[0], _m[1], _icx, _icy, ui(10))) {
							_icc = COLORS._main_icon_light;
							_ica = 1;
							
							if(DOUBLE_CLICK) New_Inspect_Node_Panel(_junc_canvas, false);
						}
				
						draw_sprite_ui_uniform(THEME.icon_canvas, 0, _icx, _icy, 1, _icc, _ica);
						
						draw_set_alpha(aa);
						draw_text_add(_txx + ui(8 + 16), _txy, _txt);
						draw_set_alpha(1);
						
					} else {
						draw_set_alpha(aa);
						draw_text_add(_txx, _txy, _txt);
						draw_set_alpha(1);
					}
				}
			#endregion
			
			if(_jun_layer) { // modifiers
				var _modis = _jun_layer.modifier;
				var _mdx   = _x + ui(16 + 24 + 12);
				var _mdy   = _cy + _lh;
				var mh     = ui(24);
				
				for (var j = array_length(_modis) - 1; j >= 0; j--) {
					var _modi = _modis[j];
					var _mtx  = _mdx;
					
					if(_modi.active_index != -1) {
						var _bx = _mtx + ui(12);
						var _by = _mdy + mh / 2;
						
						var _acti = _modi.getInputData(_modi.active_index);
						
						if(_hover && point_in_circle(_m[0], _m[1], _bx, _by, ui(12))) {
							draw_sprite_ui_uniform(THEME.visible_12, _acti, _bx, _by - ui(2), 1, c_white);
							
							if(mouse_press(mb_left, _focus))
								_modi.inputs[_modi.active_index].setValue(!_acti);
						} else 
							draw_sprite_ui_uniform(THEME.visible_12, _acti, _bx, _by - ui(2), 1, COLORS._main_icon);
							
					}
					
					_mtx += ui(24);
					var _mhov = _hover && point_in_rectangle(_m[0], _m[1], _mtx, _mdy, _x + _w, _mdy + mh - 1);
					draw_set_text(f_p2, fa_left, fa_center, _mhov? COLORS._main_text : COLORS._main_text_sub);
					draw_text_add(_mtx, _mdy + mh / 2 - ui(2), _modi.display_name);
					
					if(_mhov && DOUBLE_CLICK) {
						var pan = panelAdd("Panel_Inspector", true);
						pan.content.setInspecting(_modi, true);
					}
					
					_h   += mh;
					_lh  += mh;
					_mdy += mh;
				}
			}
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + lh)) {
				hoverIndex = ind;
				if(layer_dragging != noone) {
					draw_set_color(COLORS._main_accent);
					if(layer_dragging > ind)
						draw_line_width(_x + ui(16), _cy + lh + 2, _x + _w - ui(16), _cy + lh + ui(2), 2);
						
					else if(layer_dragging < ind)
						draw_line_width(_x + ui(16), _cy - 2, _x + _w - ui(16), _cy - ui(2), 2);
				}
			}
			
			var _bx = _x + ui(8 + 8);
			var cc  = COLORS._main_icon;
			if(point_in_rectangle(_m[0], _m[1], _bx - ui(8), _cy + ui(4), _bx + ui(8), _cy + lh - ui(4))) {
				cc = c_white;
				
				if(mouse_press(mb_left, _focus))
					properties_expand[i] = !properties_expand[i];
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _exp? 3 : 0, _bx, _cy + lh / 2 + _exp * 2, 1, cc);
			
			if(hover && layer_dragging == noone || layer_dragging == ind) {
				if(DOUBLE_CLICK) {
					renaming_index = index;
					renaming       = index;
					rename_text    = _txt;
					
					if(canvas_draw != noone && _junc_canvas)
						renaming = _junc_canvas;
						
					tb_rename._current_text = _txt;
					tb_rename.activate();
				}
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = dynamic_input_inspecting == ind? noone : ind;
					layer_dragging = ind;
					refreshDynamicDisplay();
				}
			}
			
			_cy += _lh;
		}
		
		if(layer_dragging != noone && mouse_release(mb_left)) {
			if(layer_dragging != hoverIndex && hoverIndex != noone) {
				var index = input_fix_len + layer_dragging * data_length;
				var targt = input_fix_len + hoverIndex * data_length;
				var _vis = attributes.layer_visible;
				var _sel = attributes.layer_selectable;
				
				var ext = [];
				var vis = _vis[layer_dragging];
				array_delete(_vis, layer_dragging, 1);
				array_insert(_vis, hoverIndex, vis);
				
				var sel = _sel[layer_dragging];
				array_delete(_sel, layer_dragging, 1);
				array_insert(_sel, hoverIndex, sel);
				
				for( var i = 0; i < data_length; i++ ) {
					ext[i] = inputs[index];
					array_delete(inputs, index, 1);
				}
				
				for( var i = 0; i < data_length; i++ )
					array_insert(inputs, targt + i, ext[i]);
				
				doUpdate();
			}
			
			layer_dragging = noone;
			if(canvas_group) canvas_group.onLayerChanged();
			refreshDynamicDisplay();
		}
		
		layer_height     = max(ui(16), _h);
		layer_renderer.h = layer_height;
		
		if(layer_remove > -1) {
			deleteLayer(layer_remove);
			refreshDynamicDisplay();
			layer_remove = -1;
		}
		
		return layer_height;
	});
	
	function deleteLayer(index) {
		var idx = input_fix_len + index * data_length;
		
		if(canvas_group) {
			var _inp   = inputs[idx];
			var _nodes = [];
			
			while(_inp != noone) {
				var _n = _inp.value_from.node;
				array_push_unique(_nodes, _n);
				
				_inp = noone;
				for(var i = 0; i < array_length(_n.inputs); i++) {
					if(_n.inputs[i].value_from != noone)
						_inp = _n.inputs[i];
				}
			}
			
			for (var i = 0, n = array_length(_nodes); i < n; i++)
				_nodes[i].destroy();
			return;
		} 
		
		for( var i = 0; i < data_length; i++ ) {
			var _in = array_safe_get(inputs, idx+i, noone);
			if(_in != noone) _in.removeFrom();
		}
		
		refreshDynamicDisplay();
		doUpdate();
	}
	
	////- Dynamic IO
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		
		newInput(index + 0, nodeValue_Surface(     $"Surface {_s}"));
		newInput(index + 4, nodeValue_Enum_Scroll( $"Blend {_s}",     0, BLEND_TYPES ))
			.setHistory([ BLEND_TYPES, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_00_0}, list: global.BLEND_TYPES_18 } ]);
		newInput(index + 5, nodeValue_Slider(      $"Opacity {_s}",   1));
		
		newInput(index + 1, nodeValue_Vec2(        $"Position {_s}", [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
		newInput(index + 6, nodeValue_Anchor());
		newInput(index + 2, nodeValue_Rotation(    $"Rotation {_s}",  0));
		newInput(index + 3, nodeValue_Vec2(        $"Scale {_s}",    [1,1] ));
		
		// input + 7
		
		inputs[index + 0].hover_effect  = 0;
		
		while(_s >= array_length(attributes.layer_visible))    array_push(attributes.layer_visible,    true);
		while(_s >= array_length(attributes.layer_selectable)) array_push(attributes.layer_selectable, true);
		
		refreshDynamicDisplay();
		return inputs[index + 0];
	} 
	
	input_display_dynamic = [ 
		["Surface",   false], 0, 4, 5, 
		["Transform", false], 1, 6, 2, 3, 
	];
	
	input_display_dynamic_full = function(j) { return [ 
		[ $"Surface {j}", false], 0, 4, 5, __inspc(ui(4), true, true, ui(4)), 1, 6, 2, 3 
	]; }
	
	input_display_list = [
		["Output",	 true],	0, 1, 2,
		["Layers",	false],	layer_renderer,
	];
	
	setDynamicInput(7, true, VALUE_TYPE.surface);
	
	////- Tools
	
	tool_object_anc = new composite_transform_tool_anchor(self);
	tool_object_mov = new composite_transform_tool_move(self);
	tool_object_rot = new composite_transform_tool_rotate(self);
	tool_object_sca = new composite_transform_tool_scale(self);
	
	tool_anc = new NodeTool( "Anchor", THEME.tools_3d_scale  ).setToolObject(tool_object_anc);
	tool_pos = new NodeTool( "Move",   THEME.tools_2d_move   ).setToolObject(tool_object_mov);
	tool_rot = new NodeTool( "Rotate", THEME.tools_2d_rotate ).setToolObject(tool_object_rot);
	tool_sca = new NodeTool( "Scale",  THEME.tools_2d_scale  ).setToolObject(tool_object_sca);
	tools    = [ tool_pos, tool_rot, tool_sca ];
	
	////- Nodes
	
	temp_surface       = array_create(3, noone);
	blend_temp_surface = temp_surface[2];
	
	surf_dragging     = noone;
	surface_selecting = [];
	surface_predrag   = [];
	select_freeze     = 0;
	selection_bbox    = [0, 0, 1, 1, 0, 0];
	
	drag_type   = 0; drag_anchor = 0;
	dragging_sx = 0; dragging_sy = 0;
	dragging_px = 0; dragging_py = 0;
	dragging_mx = 0; dragging_my = 0;
	dragging_ax = 0; dragging_ay = 0;
	rot_anc_x   = 0; rot_anc_y   = 0;
	dragging_bbox = [0, 0, 1, 1, 0, 0];
	
	draw_transforms    = [];
	selection_surf     = noone;
	selection_sampler  = new Surface_sampler();
	
	canvas_group       = noone;
	canvas_draw        = noone;
	
	__p = [ 0, 0 ];

	////- Overlay
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		PROCESSOR_OVERLAY_CHECK
		
		var pad   = current_data[0];
		var outs  = getSingleValue(0, preview_index, true);
		var ww    = surface_get_width_safe(outs);
		var hh    = surface_get_height_safe(outs);
		var panel = _params[$ "panel"] ?? noone;
		
		var x0 = _x +       pad[2]  * _s;
		var x1 = _x + (ww - pad[0]) * _s;
		var y0 = _y +       pad[1]  * _s;
		var y1 = _y + (hh - pad[3]) * _s;
		var snap = 4;
		
		if(surf_dragging > noone) {
			var _edit = false;
			
			switch(drag_type) {
				case NODE_COMPOSE_DRAG.move : 
					var _dx = (_mx - dragging_mx) / _s;
					var _dy = (_my - dragging_my) / _s;
					
					if(key_mod_press(SHIFT)) {
						draw_set_color(COLORS._main_icon);
						
						var _dirr = value_snap(point_direction(0, 0, _dx, _dy), 45);
						var _diss = point_distance(0, 0, _dx, _dy);
						
						_dx = lengthdir_x(_diss, _dirr);
						_dy = lengthdir_y(_diss, _dirr);
						
						var _ddx = _x + dragging_sx * _s;
						var _ddy = _y + dragging_sy * _s;
						draw_line(_ddx - lengthdir_x(999, _dirr), _ddy - lengthdir_y(999, _dirr), 
						          _ddx + lengthdir_x(999, _dirr), _ddy + lengthdir_y(999, _dirr));
					}
					
					if(surf_dragging > -1) {
						var pos_x = value_snap(dragging_sx + _dx, _snx);
						var pos_y = value_snap(dragging_sy + _dy, _sny);
						
						if(key_mod_press(ALT)) {
							var _sind = surf_dragging;
							
							var _surf = current_data[_sind + 0];
							var _sca  = current_data[_sind + 3];
							var _anc  = current_data[_sind + 6];
							var _sw   = surface_get_width_safe(_surf)  * _sca[0];
							var _sh   = surface_get_height_safe(_surf) * _sca[1];
							
							var _ax = _anc[0] * _sw;
							var _ay = _anc[1] * _sh;
							
							var  x0 = pos_x - _ax;
							var  y0 = pos_y - _ay;
							var  x1 = x0 + _sw;
							var  y1 = y0 + _sh;
							
							draw_set_color(COLORS._main_icon);
							var amo = getInputAmount();
							for( var i = -1; i < amo; i++ ) {
								var _indS = input_fix_len + i * data_length;
								if(_indS == _sind) continue;
								
								var bbox = [0, 0, ww, hh];
								if(i >= 0) {
									var _isurf = current_data[_indS + 0];
									if(!is_surface(_isurf)) continue;
									
									var _ipos  = current_data[_indS + 1];
									var _isca  = current_data[_indS + 3];
									var _ianc  = current_data[_indS + 6];
									
									var _isw   = surface_get_width_safe(_isurf)  * _isca[0];
									var _ish   = surface_get_height_safe(_isurf) * _isca[1];
									
									var _iax = _ianc[0] * _isw;
									var _iay = _ianc[1] * _ish;
									
									bbox[0] = _ipos[0] - _iax;
									bbox[1] = _ipos[1] - _iay;
									bbox[2] =  bbox[0] + _isw;
									bbox[3] =  bbox[1] + _ish;
								}
								
								var _ix0 = _x + _s * bbox[0];
								var _iy0 = _y + _s * bbox[1];
								var _ix1 = _x + _s * bbox[2];
								var _iy1 = _y + _s * bbox[3];
								
								if(abs(x0 - bbox[0]) < snap) { pos_x = bbox[0] + _ax;         draw_line(_ix0, 0, _ix0, WIN_H); }
								if(abs(x0 - bbox[2]) < snap) { pos_x = bbox[2] + _ax;         draw_line(_ix1, 0, _ix1, WIN_H); }
								
								if(abs(x1 - bbox[0]) < snap) { pos_x = bbox[0] - (_sw - _ax); draw_line(_ix0, 0, _ix0, WIN_H); }
								if(abs(x1 - bbox[2]) < snap) { pos_x = bbox[2] - (_sw - _ax); draw_line(_ix1, 0, _ix1, WIN_H); }
								
								if(abs(y0 - bbox[1]) < snap) { pos_y = bbox[1] + _ay;         draw_line(0, _iy0, WIN_W, _iy0); }
								if(abs(y0 - bbox[3]) < snap) { pos_y = bbox[3] + _ay;         draw_line(0, _iy1, WIN_W, _iy1); }
								
								if(abs(y1 - bbox[1]) < snap) { pos_y = bbox[1] - (_sh - _ay); draw_line(0, _iy0, WIN_W, _iy0); }
								if(abs(y1 - bbox[3]) < snap) { pos_y = bbox[3] - (_sh - _ay); draw_line(0, _iy1, WIN_W, _iy1); }
							}
							
						}
						
						if(inputs[surf_dragging + 1].setValue([ pos_x, pos_y ])) _edit = true;
						
					} else {
						for( var i = 0, n = array_length(surface_selecting); i < n; i++ ) {
							var _surf_dragging = surface_selecting[i];
							var _surf_position = surface_predrag[_surf_dragging + 1];
							
							var pos_x = value_snap(_surf_position[0] + _dx, _snx);
							var pos_y = value_snap(_surf_position[1] + _dy, _sny);
							
							if(inputs[_surf_dragging + 1].setValue([ pos_x, pos_y ])) _edit = true;
						}
					}
					break;
						
				case NODE_COMPOSE_DRAG.rotate : 
					var aa = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
					var da = angle_difference(aa, dragging_mx);
					
					if(surf_dragging > -1) {
						var sa = dragging_sx + da;
						if(key_mod_press(CTRL)) sa = value_snap(sa, 15);
						if(inputs[surf_dragging + 2].setValue(sa)) _edit = true;	
						
					} else {
						var cx = (rot_anc_x - _x) / _s;
						var cy = (rot_anc_y - _y) / _s;
						
						for( var i = 0, n = array_length(surface_selecting); i < n; i++ ) {
							var _surf_dragging = surface_selecting[i];
							var _surf_position = surface_predrag[_surf_dragging + 1];
							var _surf_rotation = surface_predrag[_surf_dragging + 2];
							
							var sa = _surf_rotation + da;
							if(key_mod_press(CTRL)) sa = value_snap(sa, 15);
							
							var _p = point_rotate(_surf_position[0], _surf_position[1], cx, cy, da);
							
							if(inputs[_surf_dragging + 1].setValue(_p)) _edit = true;
							if(inputs[_surf_dragging + 2].setValue(sa)) _edit = true;
						}
					}
				
					break;
					
				case NODE_COMPOSE_DRAG.scale : 
					if(surf_dragging > -1) {
						var _surf = current_data[surf_dragging + 0];
						var _rot  = current_data[surf_dragging + 2];
						var _anc  = current_data[surf_dragging + 6];
						var _sw   = surface_get_width_safe(_surf);
						var _sh   = surface_get_height_safe(_surf);
						
						var _pmx  = (_mx - dragging_mx) / (1 - _anc[0]);
						var _pmy  = (_my - dragging_my) / (1 - _anc[1]);
						var _p    = point_rotate(_pmx, _pmy, 0, 0, -_rot, __p);
						var sca_x = (dragging_sx + _p[0]) / _s / _sw;
						var sca_y = (dragging_sy + _p[1]) / _s / _sh;
						
						if(key_mod_press(SHIFT)) {
							sca_x = min(sca_x, sca_y);
							sca_y = sca_x;
						}
						
						if(inputs[surf_dragging + 3].setValue([ sca_x, sca_y ])) _edit = true;
						
					} else {
						var cx = (rot_anc_x - _x) / _s;
						var cy = (rot_anc_y - _y) / _s;
						
						var sca_x = (_mx - rot_anc_x) / (dragging_mx - rot_anc_x);
						var sca_y = (_my - rot_anc_y) / (dragging_my - rot_anc_y);
						
						if(key_mod_press(SHIFT)) {
							sca_x = min(sca_x, sca_y);
							sca_y = sca_x;
						}
							
						for( var i = 0, n = array_length(surface_selecting); i < n; i++ ) {
							var _surf_dragging = surface_selecting[i];
							var _surf_position = surface_predrag[_surf_dragging + 1];
							var _surf_scale    = surface_predrag[_surf_dragging + 3];
							
							var sa = [_surf_scale[0], _surf_scale[1]];
							sa[0] *= sca_x;
							sa[1] *= sca_y;
							
							var _p = [0,0];
							_p[0] = cx + (_surf_position[0] - cx) * sca_x;
							_p[1] = cy + (_surf_position[1] - cy) * sca_y;
							
							if(inputs[_surf_dragging + 1].setValue(_p)) _edit = true;
							if(inputs[_surf_dragging + 3].setValue(sa)) _edit = true;
						}
					}
					break;
					
				case NODE_COMPOSE_DRAG.box : 
					var _surf = current_data[surf_dragging + 0];
					var _pos  = current_data[surf_dragging + 1];
					var _rot  = current_data[surf_dragging + 2];
					var _sca  = current_data[surf_dragging + 3];
					var _anc  = current_data[surf_dragging + 6];
					var _sw   = surface_get_width_safe(_surf);
					var _sh   = surface_get_height_safe(_surf);
					
					var pos_x = _pos[0], pos_y = _pos[1];
					var sca_x = _sca[0], sca_y = _sca[1];
					
					var _mmx = _mx;
					var _mmy = _my;
					
					if(key_mod_press(SHIFT)) {
						var _aax = key_mod_press(ALT)? _x + pos_x * _s : dragging_ax;
						var _aay = key_mod_press(ALT)? _y + pos_y * _s : dragging_ay;
						
						var _dax = _mx - _aax;
						var _day = _my - _aay;
						var _p = point_rotate_origin(_dax, _day, -_rot, __p);
						
						_dax = _p[0];
						_day = _p[1];
						
						var _scd = min(abs(_dax / _sw), abs(_day / _sh));
						var _p = point_rotate_origin(_sw * sign(_dax), _sh * sign(_day), _rot, __p);
						
						_mmx = _aax + _scd * _p[0];
						_mmy = _aay + _scd * _p[1];
					}
					
					var _dmx  = _mmx - dragging_mx;
					var _dmy  = _mmy - dragging_my;
					var _p = point_rotate_origin(_dmx, _dmy, -_rot, __p);
					
					var _sdx = _p[0] * (bool(drag_anchor & 0b10) * 2 - 1);
					var _sdy = _p[1] * (bool(drag_anchor & 0b01) * 2 - 1);
					
					var _ax  = bool(drag_anchor & 0b10)? _anc[0] : 1 - _anc[0];
					var _ay  = bool(drag_anchor & 0b01)? _anc[1] : 1 - _anc[1];
					
					if(key_mod_press(ALT)) {
						var sca_x = (dragging_sx + _sdx / (1 - _ax)) / _s / _sw;
				        var sca_y = (dragging_sy + _sdy / (1 - _ay)) / _s / _sh;
				        
						var pos_x = dragging_px;
						var pos_y = dragging_py;
						
				        var e0 = inputs[surf_dragging + 1].setValue([ pos_x, pos_y ]);
						var e1 = inputs[surf_dragging + 3].setValue([ sca_x, sca_y ]);
						if(e0 || e1) _edit = true;
						
					} else {
						var sca_x = (dragging_sx + _sdx) / _s / _sw;
				        var sca_y = (dragging_sy + _sdy) / _s / _sh;
				        
						var pos_x  = dragging_px + _dmx / _s * _ax;
						var pos_y  = dragging_py + _dmy / _s * _ay;
						
						var e0 = inputs[surf_dragging + 1].setValue([ pos_x, pos_y ]);
						var e1 = inputs[surf_dragging + 3].setValue([ sca_x, sca_y ]);
						if(e0 || e1) _edit = true;
					}
					break;
					
				case NODE_COMPOSE_DRAG.anchor : 
					var _surf = current_data[surf_dragging + 0];
					var _pos  = current_data[surf_dragging + 1];
					var _rot  = current_data[surf_dragging + 2];
					var _sca  = current_data[surf_dragging + 3];
					var _anc  = current_data[surf_dragging + 6];
					var _sw   = surface_get_width_safe(_surf)  * _sca[0];
					var _sh   = surface_get_height_safe(_surf) * _sca[1];
					
					var _dmx = (_mx - dragging_mx) / _s / _sw;
					var _dmy = (_my - dragging_my) / _s / _sh;
					var _p   = point_rotate_origin(_dmx, _dmy, -_rot, __p);
					
					var _aax = dragging_sx + _p[0];
					var _aay = dragging_sy + _p[1];
					
					var _px = dragging_px;
					var _py = dragging_py;
						
					if(key_mod_press(CTRL)) {
						_px += _p[0] * _sw;
						_py += _p[1] * _sh;
					}
					
					var e0 = inputs[surf_dragging + 1].setValue([ _px,  _py  ]);
					var e1 = inputs[surf_dragging + 6].setValue([ _aax, _aay ]);
					if(e0 || e1) _edit = true;
					break;
			}
			
			if(_edit) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				surf_dragging = noone;
				UNDO_HOLDING  = false;
			}
		}
		
		var w_hover       = false;
		var hovering      = noone;
		var hovering_type = noone;
		var hovering_oanc = noone;
		var hovering_ianc = noone;
		var hovering_ai   = noone;
		
		var hovering_con  = noone;
		
		var amo     = getInputAmount();
		var anchors = array_create(array_length(inputs));
		if(amo == 0) { dynamic_input_inspecting = noone; return; }
		
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		dynamic_input_inspecting = min(dynamic_input_inspecting, amo - 1);
		
		if(attributes.select_object && selection_sampler.active) {
			var _msx = floor((_mx - _x) / _s);
			var _msy = floor((_my - _y) / _s);
			var _ind = selection_sampler.getPixel(_msx, _msy);
			
			if(_ind) {
				hovering_type = NODE_COMPOSE_DRAG.move;
				hovering_con  = _ind - 1;
			}
		}
		
		for(var i = 0; i < amo; i++) {
			var index = input_fix_len + i * data_length;
			var _surf = current_data[index + 0];
			
			if(!is_surface(_surf) || !_vis[i]) continue;
			
			var _pos  = current_data[index + 1];
			var _rot  = current_data[index + 2];
			var _sca  = current_data[index + 3];
			var _anc  = current_data[index + 6];
			
			var _ww = surface_get_width_safe(_surf);
			var _hh = surface_get_height_safe(_surf);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _ax = _sw *      _anc[0];
			var _ay = _sh *      _anc[1];
			var iax = _sw * (1 - _anc[0]);
			var iay = _sh * (1 - _anc[1]);
			
			var _siz = [ _sw * _s, _sh * _s ];
			var _cx = _pos[0];
			var _cy = _pos[1];
			
			var _c0x = _cx - _ax;
			var _c0y = _cy - _ay;
			var _c1x = _cx + iax;
			var _c1y = _cy + iay;
			
			point_rotate(_cx, _cy, _cx, _cy, _rot, __p);
			var _aa = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c0x, _c0y, _cx, _cy, _rot, __p);
			var _d0 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c0x, _c1y, _cx, _cy, _rot, __p);
			var _d1 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x, _c0y, _cx, _cy, _rot, __p);
			var _d2 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x, _c1y, _cx, _cy, _rot, __p);
			var _d3 = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_cx + _sw / 2 - _ax, _c0y - (24 / _s) * sign(_sca[1]), _cx, _cy, _rot, __p);
			var _rr = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_cx + _sw / 2 - _ax, _c0y, _cx, _cy, _rot, __p);
			var _rc = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			point_rotate(_c1x + (16 / _s) * sign(_sca[0]), _c1y + (16 / _s) * sign(_sca[1]), _cx, _cy, _rot, __p);
			var _ss = [ _x + __p[0] * _s, _y + __p[1] * _s ];
			
			anchors[index] = {
				d0: _d0, d1: _d1, d2: _d2, d3: _d3,
				cx: _cx, cy: _cy,
				rr: _rr, ss: _ss, rc: _rc, 
				
				anc: _aa, 
				siz: _siz,
				
				raw_pos: _pos,
				raw_rot: _rot,
				raw_sca: _sca,
				raw_anc: _anc,
			}
			
			if(!_sel[i]) continue;
			
			var _hov = point_in_rectangle_points(_mx, _my, _d0[0], _d0[1], _d1[0], _d1[1], _d2[0], _d2[1], _d3[0], _d3[1]);
			
			if(_hov) {
				if(isNotUsingTool() || isUsingTool("Move"))
					hovering_type = NODE_COMPOSE_DRAG.move;
				hovering = i;
			}
		}
		
		if(attributes.select_object && selection_sampler.active)
			hovering = hovering_con;
		
		var _a = noone;
		
		if(dynamic_input_inspecting >= 0) {
			var _index = dynamic_input_inspecting;
			var _ancid = input_fix_len + dynamic_input_inspecting * data_length;
			_a = anchors[_ancid];
		}
			
		if(is_struct(_a)) {
			var p0x = _a.d0[0], p0y = _a.d0[1];
			var p1x = _a.d1[0], p1y = _a.d1[1];
			var p2x = _a.d2[0], p2y = _a.d2[1];
			var p3x = _a.d3[0], p3y = _a.d3[1];
			var rcx = _a.rc[0], rcy = _a.rc[1];
			var  rx = _a.rr[0],  ry = _a.rr[1];
			var  sx = _a.ss[0],  sy = _a.ss[1];
			var  ax = _a.anc[0], ay = _a.anc[1];
			
			var _ri = 0;
			var _si = 0;
			var _ai = 0;
			var _bi = noone;
			
			var _hov = !attributes.select_object && point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y);
		
			if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p0x, p0y, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.box;
				hovering_oanc = _d3;
				hovering_ai   = 0;
				hovering      = _index; _bi = 0;
				
			} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p1x, p1y, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.box;
				hovering_oanc = _d2;
				hovering_ai   = 1;
				hovering      = _index; _bi = 1;
				
			} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p2x, p2y, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.box;
				hovering_oanc = _d1;
				hovering_ai   = 2;
				hovering      = _index; _bi = 2;
				
			} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, p3x, p3y, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.box;
				hovering_oanc = _d0;
				hovering_ai   = 3;
				hovering      = _index; _bi = 3;
				
			} else if((isNotUsingTool() || isUsingTool("Anchor")) && point_in_circle(_mx, _my, ax, ay, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.anchor;
				hovering      = _index; _ai = 3;
				
			} else if((isNotUsingTool() || isUsingTool("Move")) && _hov) {
				hovering_type = NODE_COMPOSE_DRAG.move; 
				hovering      = _index;
				
			} else if((isNotUsingTool() || isUsingTool("Rotate")) && point_in_circle(_mx, _my, rx, ry, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.rotate;
				hovering      = _index; _ri = 1;
				
			} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, sx, sy, 12)) {
				hovering_type = NODE_COMPOSE_DRAG.scale;
				hovering      = _index; _si = 1;
			}
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle_border_points(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, 2);
			
			if(isNotUsingTool() || isUsingTool("Rotate")) {
				draw_line_width(rcx, rcy, rx,  ry,  2);
				
				draw_anchor(_ri,      rx,  ry,  ui(8), 1);
			}
			
			if(isNotUsingTool() || isUsingTool("Scale")) {
				draw_line_width(p3x, p3y, sx,  sy,  2);
				
				draw_anchor(_si,      sx,  sy,  ui(8), 1);
				draw_anchor(_bi == 0, p0x, p0y, ui(8), 2);
				draw_anchor(_bi == 1, p1x, p1y, ui(8), 2);
				draw_anchor(_bi == 2, p2x, p2y, ui(8), 2);
				draw_anchor(_bi == 3, p3x, p3y, ui(8), 2);
			}
			
			if(isNotUsingTool() || isUsingTool("Anchor"))
				draw_anchor_cross(_ai * .5, ax, ay, ui(8), 1, _rot);
			
		}
		
		if(hovering != noone) hovering_ianc = array_safe_get_fast(anchors, input_fix_len + hovering * data_length);
		
		var _show_selecting = true;
		if(isUsingTool()) {
			_show_selecting = false;
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = _currTool.getToolObject();
			
			if(_tool != noone) {
				_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				if(mouse_lclick()) select_freeze = 1;
				_show_selecting = true;
			}
		}
		
		if(_show_selecting) { // Multi Selections
			if(select_freeze == 0 && panel.selection_selecting && surf_dragging == noone) {
				var sx0 = _x + panel.selection_x0 * _s;
				var sy0 = _y + panel.selection_y0 * _s;
				var sx1 = _x + panel.selection_x1 * _s;
				var sy1 = _y + panel.selection_y1 * _s;
				
				surface_selecting = [];
				
				for( var i = 0; i < amo; i++ ) {
					if(!_vis[i] || !_sel[i]) continue;
					
					var ind = input_fix_len + i * data_length;
					var a  = anchors[ind];
					if(!is_struct(a)) continue;
					
					var p00 = a.d0[0], p01 = a.d0[1];
					var p10 = a.d1[0], p11 = a.d1[1];
					var p20 = a.d2[0], p21 = a.d2[1];
					var p30 = a.d3[0], p31 = a.d3[1];
					
					var o0 = rectangle_in_triangle(sx0, sy0, sx1, sy1, p00, p01, p10, p11, p20, p21);
					var o1 = rectangle_in_triangle(sx0, sy0, sx1, sy1, p10, p11, p20, p21, p30, p31);
					
					if(o0 || o1) array_push(surface_selecting, ind);
				}
				
			}
			
			if(!array_empty(surface_selecting)) {
				var _selx0 =  infinity;
				var _sely0 =  infinity;
				var _selx1 = -infinity;
				var _sely1 = -infinity;
				
				draw_set_color(COLORS._main_accent);
				for( var i = 0, n = array_length(surface_selecting); i < n; i++ ) {
					var a = array_safe_get_fast(anchors, surface_selecting[i]);
					if(!is_struct(a)) continue;
					
					draw_rectangle_border_points(a.d0[0], a.d0[1], a.d1[0], a.d1[1], a.d2[0], a.d2[1], a.d3[0], a.d3[1]);
					
					_selx0 = min(_selx0, a.d0[0]); _sely0 = min(_sely0, a.d0[1]);
					_selx1 = max(_selx1, a.d0[0]); _sely1 = max(_sely1, a.d0[1]);
					
					_selx0 = min(_selx0, a.d1[0]); _sely0 = min(_sely0, a.d1[1]);
					_selx1 = max(_selx1, a.d1[0]); _sely1 = max(_sely1, a.d1[1]);
					
					_selx0 = min(_selx0, a.d2[0]); _sely0 = min(_sely0, a.d2[1]);
					_selx1 = max(_selx1, a.d2[0]); _sely1 = max(_sely1, a.d2[1]);
					
					_selx0 = min(_selx0, a.d3[0]); _sely0 = min(_sely0, a.d3[1]);
					_selx1 = max(_selx1, a.d3[0]); _sely1 = max(_sely1, a.d3[1]);
					
				}
				
				var _selxc = (_selx0 + _selx1) / 2;
				var _selyc = (_sely0 + _sely1) / 2;
				var _ri = 0;
				var _si = 0;
				var _ai = 0;
				var _bi = noone;
				var _hov = point_in_rectangle(_mx, _my, _selx0, _sely0, _selx1, _sely1);
				
				selection_bbox[0] = (_selx0 - _x) / _s;
				selection_bbox[1] = (_sely0 - _y) / _s;
				selection_bbox[2] = (_selx1 - _x) / _s;
				selection_bbox[3] = (_sely1 - _y) / _s;
				selection_bbox[4] = (_selxc - _x) / _s;
				selection_bbox[5] = (_selyc - _y) / _s;
				
				// if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, _selx0, _sely0, 12)) {
				// 	hovering_type = NODE_COMPOSE_DRAG.box;
				// 	hovering_oanc = [_selx1, _sely1];
				// 	hovering_ai   = 0;
				// 	hovering = -1; _bi = 0;
					
				// } else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, _selx1, _sely0, 12)) {
				// 	hovering_type = NODE_COMPOSE_DRAG.box;
				// 	hovering_oanc = [_selx0, _sely1];
				// 	hovering_ai   = 1;
				// 	hovering = -1; _bi = 1;
					
				// } else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, _selx0, _sely1, 12)) {
				// 	hovering_type = NODE_COMPOSE_DRAG.box;
				// 	hovering_oanc = [_selx1, _sely0];
				// 	hovering_ai   = 2;
				// 	hovering = -1; _bi = 2;
					
				// } else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, _selx1, _sely1, 12)) {
				// 	hovering_type = NODE_COMPOSE_DRAG.box;
				// 	hovering_oanc = [_selx0, _sely0];
				// 	hovering_ai   = 3;
				// 	hovering = -1; _bi = 3;
					
				// } else 
				
				if((isNotUsingTool() || isUsingTool("Move")) && _hov) {
					hovering_type = NODE_COMPOSE_DRAG.move; 
					hovering = -1;
					
				} else if((isNotUsingTool() || isUsingTool("Rotate")) && point_in_circle(_mx, _my, _selxc, _sely0 - 24, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.rotate;
					hovering = -1; _ri = 1;
					
				} else if((isNotUsingTool() || isUsingTool("Scale")) && point_in_circle(_mx, _my, _selx1 + 16, _sely1 + 16, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.scale;
					hovering = -1; _si = 1;
				}
				
				if(hovering == -1) {
					hovering_ianc = {
						d0: [_selx0, _sely0], d1: [_selx1, _sely0], d2: [_selx0, _sely1], d3: [_selx1, _sely1],
						rr: [_selxc, _sely0 - 24], ss: [_selx1 + 16, _sely1 + 16], 
						cx: selection_bbox[4], cy: selection_bbox[5],
						
						anc: [ _selxc, _selyc ],
						siz: [ _selx1 - _selx0, _sely1 - _sely0 ],
						
						raw_pos: [ _selxc, _selyc ],
						raw_rot: 0,
						raw_sca: [ 1, 1 ],
						raw_anc: [ .5, .5 ],
					};
				}
				
				draw_rectangle_border(_selx0, _sely0, _selx1, _sely1, 2);
				
				draw_line_width(_selxc, _sely0 - 24, _selxc, _sely0,  2);
				draw_anchor(_ri, _selxc, _sely0 - 24,  ui(8), 1);
				
				draw_line_width(_selx1, _sely1, _selx1 + 16, _sely1 + 16,  2);
				draw_anchor(_si, _selx1 + 16, _sely1 + 16,  ui(8), 1);
				// draw_anchor(_bi == 0, _selx0, _sely0, ui(8), 2);
				// draw_anchor(_bi == 1, _selx1, _sely0, ui(8), 2);
				// draw_anchor(_bi == 2, _selx0, _sely1, ui(8), 2);
				// draw_anchor(_bi == 3, _selx1, _sely1, ui(8), 2);
				
			}
		}
		
		if(select_freeze == 0 && mouse_lpress(active)) { 
			dynamic_input_inspecting = hovering; 
			if(hovering != -1) surface_selecting = [];
			
			refreshDynamicDisplay(); 
		}
		
		if(mouse_lrelease()) select_freeze = 0;
		
		if(hovering != noone) {
			w_hover = true;
			var a   = hovering_ianc;
			
			if(is_struct(a)) {
				if(hovering > -1 && hovering != dynamic_input_inspecting) {
					draw_set_color(COLORS.node_composite_overlay_border);
					draw_rectangle_border_points(a.d0[0], a.d0[1], a.d1[0], a.d1[1], a.d2[0], a.d2[1], a.d3[0], a.d3[1]);
				}
				
				if(mouse_lpress(active)) {
					
					surf_dragging	= hovering > -1? input_fix_len + hovering * data_length : -1;
					drag_type		= hovering_type;
					
					surface_predrag = array_verify(surface_predrag, array_length(inputs));
					for( var i = 0, n = array_length(inputs); i < n; i++ ) surface_predrag[i] = inputs[i].getValue();
					
					dragging_bbox = array_clone(selection_bbox);
					
					switch(hovering_type) {
						case NODE_COMPOSE_DRAG.move : 
							dragging_sx		= a.raw_pos[0];
							dragging_sy		= a.raw_pos[1];
							dragging_mx		= _mx;
							dragging_my		= _my;
							break;
							
						case NODE_COMPOSE_DRAG.rotate : 
							dragging_sx		= a.raw_rot;
							rot_anc_x		= overlay_x(a.cx, _x, _s);
							rot_anc_y		= overlay_y(a.cy, _y, _s);
							dragging_mx		= point_direction(rot_anc_x, rot_anc_y, _mx, _my);
							break;
							
						case NODE_COMPOSE_DRAG.scale : 
							dragging_sx		= a.siz[0];
							dragging_sy		= a.siz[1];
							dragging_ax		= a.d0[0];
							dragging_ay		= a.d0[1];
							dragging_mx		= _mx;
							dragging_my		= _my;
							rot_anc_x		= overlay_x(a.cx, _x, _s);
							rot_anc_y		= overlay_y(a.cy, _y, _s);
							break;
							
						case NODE_COMPOSE_DRAG.box : 
							drag_anchor     = hovering_ai;
							dragging_sx		= a.siz[0];
							dragging_sy		= a.siz[1];
							dragging_px		= a.raw_pos[0];
							dragging_py		= a.raw_pos[1];
							dragging_ax		= hovering_oanc[0];
							dragging_ay		= hovering_oanc[1];
							dragging_mx		= _mx;
							dragging_my		= _my;
							break;
							
						case NODE_COMPOSE_DRAG.anchor : 
							dragging_sx		= a.raw_anc[0];
							dragging_sy		= a.raw_anc[1];
							dragging_px		= a.raw_pos[0];
							dragging_py		= a.raw_pos[1];
							dragging_mx		= _mx;
							dragging_my		= _my;
							break;
					}
				}
			}
		}
		
		return w_hover;
	}
	
	static drawOverlayTransform = function(_node) { 
		var _df  = array_safe_get(draw_transforms, preview_index, noone);
		if(_df == noone) return noone;
		
		var _amo = getInputAmount();
		for( var i = 0; i < _amo; i++ ) {
			if(_node == inputs[input_fix_len + i * data_length].getNodeFrom())
				return _df[i];
		}
		
		return noone;
	}
	
	////- Update
	
	static getDimension = function(arr = 0) { 
		if(getInputAmount() == 0) return [1,1];
		
		var _pad  = getSingleValue(0, arr);
		var _dimt = getSingleValue(1, arr);
		var _dim  = getSingleValue(2, arr);
		var base  = getSingleValue(3, arr);
		
		var ww = 0, hh = 0;
		
		switch(_dimt) {
			case COMPOSE_OUTPUT_SCALING.first :
				ww = surface_get_width_safe(base);
				hh = surface_get_height_safe(base);
				break;
				
			case COMPOSE_OUTPUT_SCALING.largest :
				for(var i = input_fix_len; i < array_length(inputs) - data_length; i += data_length) {
					var _s = getSingleValue(i, arr);
					ww = max(ww, surface_get_width_safe(_s));
					hh = max(hh, surface_get_height_safe(_s));
				}
				break;
				
			case COMPOSE_OUTPUT_SCALING.constant :	
				ww = _dim[0];
				hh = _dim[1];
				break;
		}
		
		ww += _pad[0] + _pad[2];
		hh += _pad[1] + _pad[3];
	
		return [ ww, hh ];
	} 
	
	static processData = function(_outData, _data, _array_index) {
		draw_transforms[_array_index] = noone;
		
		#region data
			var imageAmo  = getInputAmount();
			if( imageAmo == 0) return _outData;
			
			var _pad  = _data[0];
			var _dimt = _data[1];
			var _dim  = _data[2];
			var base  = _data[3];
			var cDep  = attrDepth();
			
			var _outSurf  = _outData[0];
			
			inputs[2].setVisible(_dimt == COMPOSE_OUTPUT_SCALING.constant);
		
			if(!is_surface(base)) return _outData;
		
			var _odim = getDimension(_array_index);
			var  ww   = _odim[0];
			var  hh   = _odim[1];
			
			for(var i = 0; i < 3; i++) temp_surface[i] = surface_clear(surface_verify(temp_surface[i], ww, hh, cDep));
			
			attributes.layer_visible    = array_verify(attributes.layer_visible,    imageAmo);
			attributes.layer_selectable = array_verify(attributes.layer_selectable, imageAmo);
		#endregion
		
		var res_index = 0;
		var _vis      = attributes.layer_visible;
		var bg        = 0;
		var _bg       = 0;
		var _atlas    = [];
		var _trans    = array_create(imageAmo, noone);
		
		var _selDraw  = _array_index == preview_index && attributes.select_object;
		if(_selDraw) selection_surf = surface_clear(surface_verify(selection_surf, ww, hh, surface_r16float));
		
		blend_temp_surface = temp_surface[2];
		for(var i = 0; i < imageAmo; i++) {
			var vis  = _vis[i];
			if(!vis) continue;
			
			var _ind = input_fix_len + i * data_length;
			var _s   = _data[_ind + 0];
			var _pos = _data[_ind + 1];
			var _rot = _data[_ind + 2];
			var _sca = _data[_ind + 3];
			var _bld = _data[_ind + 4];
			var _alp = _data[_ind + 5];
			var _anc = _data[_ind + 6];
			
			if(!is_surface(_s)) continue;
			var _ww = surface_get_width_safe(_s);
			var _hh = surface_get_height_safe(_s);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _ax = _anc[0] * _sw;
			var _ay = _anc[1] * _sh;
			
			var _cx = _pos[0];
			var _cy = _pos[1];
			
			var _d0 = point_rotate(_cx - _ax, _cy - _ay, _cx, _cy, _rot);
			// _d0[0] = round(_d0[0]); _d0[1] = round(_d0[1]);
			
			array_push(_atlas, new SurfaceAtlas(_s, _d0[0], _d0[1], _rot, _sca[0], _sca[1]));
			_trans[i] = [ _d0[0], _d0[1], _sca[0], _sca[1], _rot ];
			
			surface_set_shader(temp_surface[_bg], sh_sample, true, BLEND.over);
				try { draw_surface_blend_ext(temp_surface[!_bg], _s, _d0[0], _d0[1], _sca[0], _sca[1], _rot, c_white, _alp, _bld, true); }
				catch(e) { noti_warning(e, noone, self); }
			surface_reset_shader();
			
			surface_set_shader(selection_surf, sh_selection_mask, false, BLEND.maximum);
				shader_set_f("index", i + 1);
				draw_surface_ext_safe(_s, _d0[0], _d0[1], _sca[0], _sca[1], _rot, c_white, 1);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		if(_selDraw) selection_sampler.setSurface(selection_surf);
		
		_outSurf = surface_verify(_outSurf, ww, hh, cDep);
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		_outData[0] = _outSurf;
		_outData[1] = _atlas;
		_outData[2] = [ww, hh];
		draw_transforms[_array_index] = _trans;
		
		return _outData;
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_19_04_0) {
			var _ins  = load_map.inputs;
			var _dlen = load_map.data_length;
			
			for( var i = input_fix_len, n = array_length(_ins); i < n; i += data_length ) {
				var _pos = _ins[i+1];
				var _anc = _ins[i+6];
				
				var _setAnc = is_struct(_anc) && struct_has(_anc, "raw_value");
				if(!_setAnc) _ins[i+6] = { raw_value: { d: [0,0] }};
			}
		}
	}
	
	static attributeSerialize = function() {
		var att = {};
		att.layer_visible    = attributes.layer_visible;
		att.layer_selectable = attributes.layer_selectable;
		
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "layer_visible"))    attributes.layer_visible    = attr.layer_visible;
		if(struct_has(attr, "layer_selectable")) attributes.layer_selectable = attr.layer_selectable;
	}
}