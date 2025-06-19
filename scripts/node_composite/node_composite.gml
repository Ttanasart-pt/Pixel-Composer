enum NODE_COMPOSE_DRAG {
	move,
	rotate,
	scale
}

enum COMPOSE_OUTPUT_SCALING {
	first,
	largest,
	constant
}

function Node_Composite(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Composite";
	dimension_index = -1;
	dynamic_input_inspecting = noone;
	
	newInput(0, nodeValue_Padding(     "Padding", [0,0,0,0] ));
	newInput(1, nodeValue_Enum_Scroll( "Output dimension", COMPOSE_OUTPUT_SCALING.first, [ "First surface", "Largest surface", "Constant" ]));
	newInput(2, nodeValue_Dimension()).setVisible(false);
	
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
	rename_text     = "";
	renaming_index  = noone;
	tb_rename       = textBox_Text(function(_n) /*=>*/ { 
		if(renaming == noone) return;
		
		     if(is_real(renaming))  inputs[renaming].setName(_n);
		else if(is(renaming, Node)) renaming.setDisplayName(_n, false) 
		
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
						doUpdate();
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
				var _txy = _cy + lh / 2 + ui(2);
				
				if(_junc_canvas) hover = hover && _m[0] > _txx + ui(8 + 16);
				
				var tc = ind == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
				var tf = ind == dynamic_input_inspecting? f_p1b : f_p1;
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
						var _icy = _txy - ui(1);
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
				var _mdx   = _sx0;
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
	
	static createNewInput = function(index = array_length(inputs)) {
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
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []    ));
	newOutput(2, nodeValue_Output( "Dimension",   VALUE_TYPE.integer, [1,1] )).setVisible(false).setDisplay(VALUE_DISPLAY.vector);
	
	////- Nodes
	
	temp_surface       = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	blend_temp_surface = temp_surface[2];
	
	surf_dragging  = -1;
	input_dragging = -1;
	drag_type      = 0;
	dragging_sx    = 0;
	dragging_sy    = 0;
	dragging_mx    = 0;
	dragging_my    = 0;
	
	rot_anc_x = 0;
	rot_anc_y = 0;
	
	draw_transforms   = [];
	selection_surf    = noone;
	selection_sampler = new Surface_sampler();
	
	__d0 = [ 0, 0 ];
	__d1 = [ 0, 0 ];
	__d2 = [ 0, 0 ];
	__d3 = [ 0, 0 ];
	__rr = [ 0, 0 ];

	canvas_group    = noone;
	canvas_draw     = noone;
	
	////- Overlay
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pad  = current_data[0];
		var outs = getSingleValue(0, preview_index, true);
		var ww   = surface_get_width_safe(outs);
		var hh   = surface_get_height_safe(outs);
		
		var x0  = _x +       pad[2]  * _s;
		var x1  = _x + (ww - pad[0]) * _s;
		var y0  = _y +       pad[1]  * _s;
		var y1  = _y + (hh - pad[3]) * _s;
		
		if(input_dragging > -1) {
			if(drag_type == NODE_COMPOSE_DRAG.move) {
				var _dx = (_mx - dragging_mx) / _s;
				var _dy = (_my - dragging_my) / _s;
				
				if(key_mod_press(SHIFT)) {
					if(abs(_dx) > abs(_dy) + ui(16))
						_dy = 0;
						
					else if(abs(_dy) > abs(_dx) + ui(16))
						_dx = 0;
						
					else {
						_dx = max(_dx, _dy);
						_dy = _dx;
					}
				}
				
				var pos_x = value_snap(dragging_sx + _dx, _snx);
				var pos_y = value_snap(dragging_sy + _dy, _sny);
				
				if(key_mod_press(ALT)) {
					var _surf = current_data[input_dragging - 1];
					var _sw = surface_get_width_safe(_surf);
					var _sh = surface_get_height_safe(_surf);
					
					var x0 = pos_x, x1 = pos_x + _sw;
					var y0 = pos_y, y1 = pos_y + _sh;
					var xc = (x0 + x1) / 2;
					var yc = (y0 + y1) / 2;
					var snap = 4;
					
					draw_set_color(COLORS._main_accent);
					if(abs(x0 -  0) < snap) {
						pos_x = 0;
						draw_line_width(_x + _s * 0, 0, _x + _s * 0, WIN_H, 2);
					}
					
					if(abs(y0 -  0) < snap) {
						pos_y = 0;
						draw_line_width(0, _y + _s * 0, WIN_W, _y + _s * 0, 2);
					}
					
					if(abs(x1 - ww) < snap) {
						pos_x = ww - _sw;
						draw_line_width(_x + _s * ww, 0, _x + _s * ww, WIN_H, 2);
					}
					
					if(abs(y1 - hh) < snap) {
						pos_y = hh - _sh;
						draw_line_width(0, _y + _s * hh, WIN_W, _y + _s * hh, 2);
					}
					
					if(abs(xc - ww / 2) < snap) {
						pos_x = ww / 2 - _sw / 2;
						draw_line_width(_x + _s * ww / 2, 0, _x + _s * ww / 2, WIN_H, 2);
					}
					
					if(abs(yc - hh / 2) < snap) {
						pos_y = hh / 2 - _sh / 2;
						draw_line_width(0, _y + _s * hh / 2, WIN_W, _y + _s * hh / 2, 2);
					}
				}
				
				if(inputs[input_dragging].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
					
			} else if(drag_type == NODE_COMPOSE_DRAG.rotate) {
				var aa = point_direction(rot_anc_x, rot_anc_y, _mx, _my);
				var da = angle_difference(dragging_mx, aa);
				var sa = dragging_sx - da;
				
				if(key_mod_press(CTRL)) 
					sa = value_snap(sa, 15);
			
				if(inputs[input_dragging].setValue(sa))
					UNDO_HOLDING = true;	
			
			} else if(drag_type == NODE_COMPOSE_DRAG.scale) {
				var _surf = current_data[surf_dragging + 0];
				var _rot  = current_data[surf_dragging + 2];
				var _anc  = current_data[surf_dragging + 6];
				var _sw   = surface_get_width_safe(_surf);
				var _sh   = surface_get_height_safe(_surf);
				
				var _p    = point_rotate(_mx - dragging_mx, _my - dragging_my, 0, 0, -_rot);
				var sca_x = _p[0] / _s / _sw / .5//(1 - _anc[0]);
				var sca_y = _p[1] / _s / _sh / .5//(1 - _anc[1]);
				
				if(key_mod_press(SHIFT)) {
					sca_x = min(sca_x, sca_y);
					sca_y = sca_x;
				}
				
				if(inputs[input_dragging].setValue([ sca_x, sca_y ]))
					UNDO_HOLDING = true;
				
			}
			
			if(mouse_release(mb_left)) {
				input_dragging = -1;
				UNDO_HOLDING = false;
			}
		}
		
		var hovering      = noone;
		var hovering_type = noone;
		var _vis = attributes.layer_visible;
		var _sel = attributes.layer_selectable;
		
		var amo     = getInputAmount();
		var anchors = array_create(array_length(inputs));
		
		if(amo == 0) { dynamic_input_inspecting = noone; return; }
		dynamic_input_inspecting = min(dynamic_input_inspecting, amo - 1);
		
		for(var i = 0; i < amo; i++) {
			var index = input_fix_len + i * data_length;
			var _surf = current_data[index + 0];
			var _pos  = current_data[index + 1];
			var _rot  = current_data[index + 2];
			var _sca  = current_data[index + 3];
			var _anc  = current_data[index + 6];
			
			if(!is_surface(_surf)) continue;
			
			var _ww = surface_get_width_safe(_surf);
			var _hh = surface_get_height_safe(_surf);
			var _sw = _ww * _sca[0];
			var _sh = _hh * _sca[1];
			
			var _ax = _sw *      _anc[0];
			var _ay = _sh *      _anc[1];
			var iax = _sw * (1 - _anc[0]);
			var iay = _sh * (1 - _anc[1]);
			
			var _cx = _pos[0];
			var _cy = _pos[1];
			
			var _d0 = point_rotate(_cx - _ax, _cy - _ay, _cx, _cy, _rot, __d0);
			var _d1 = point_rotate(_cx - _ax, _cy + iay, _cx, _cy, _rot, __d1);
			var _d2 = point_rotate(_cx + iax, _cy - _ay, _cx, _cy, _rot, __d2);
			var _d3 = point_rotate(_cx + iax, _cy + iay, _cx, _cy, _rot, __d3);
			
			var _rr = point_rotate(_cx + _sw / 2 - _ax, _cy - _ay - 1, _cx, _cy, _rot, __rr);
			
			_d0 = [ overlay_x(_d0[0], _x, _s), overlay_y(_d0[1], _y, _s) ];
			_d1 = [ overlay_x(_d1[0], _x, _s), overlay_y(_d1[1], _y, _s) ];
			_d2 = [ overlay_x(_d2[0], _x, _s), overlay_y(_d2[1], _y, _s) ];
			_d3 = [ overlay_x(_d3[0], _x, _s), overlay_y(_d3[1], _y, _s) ];
			_rr = [ overlay_x(_rr[0], _x, _s), overlay_y(_rr[1], _y, _s) ];
			
			anchors[index] = {
				d0: _d0, d1: _d1, d2: _d2, d3: _d3,
				cx: _cx, cy: _cy,
				rr: _rr,
				
				rot: _rot,
			}
		}
		
		for(var i = 0; i < amo; i++) {
			var vis = _vis[i];
			var sel = _sel[i];
			if(!vis) continue;
			
			var index = input_fix_len + i * data_length;
			var _surf = current_data[index + 0];
			var _pos  = current_data[index + 1];
			var _rot  = current_data[index + 2];
			var _sca  = current_data[index + 3];
			
			if(!_surf || is_array(_surf)) continue;
			
			var a = anchors[index];
			if(!is_struct(a)) continue;
			
			var p0x = a.d0[0], p0y = a.d0[1];
			var p1x = a.d1[0], p1y = a.d1[1];
			var p2x = a.d2[0], p2y = a.d2[1];
			var p3x = a.d3[0], p3y = a.d3[1];
			
			var rx = a.rr[0], ry = a.rr[1];
			
			var _hov = point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y);
			
			if(dynamic_input_inspecting == i) {
				var _ri = 0;
				var _si = 0;
			
				if(point_in_circle(_mx, _my, p3x, p3y, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.scale;
					hovering = i;
					_si = 1;
					
				} else if(_hov) {
					hovering_type = NODE_COMPOSE_DRAG.move;
					hovering = i;
					
				} else if(point_in_circle(_mx, _my, rx, ry, 12)) {
					hovering_type = NODE_COMPOSE_DRAG.rotate;
					hovering = i;
					_ri = 1;
				}
				
				draw_sprite_colored(THEME.anchor_rotate, _ri, rx, ry, 1, a.rot);
				draw_anchor(_si, p3x, p3y);
				
			} else if(!attributes.select_object && _hov && (hovering != dynamic_input_inspecting || dynamic_input_inspecting == noone)) {
				hovering_type = NODE_COMPOSE_DRAG.move;
				hovering = i;
			}
		}
		
		if(attributes.select_object && selection_sampler.active) {
			var _msx = floor((_mx - _x) / _s);
			var _msy = floor((_my - _y) / _s);
			var _ind = selection_sampler.getPixel(_msx, _msy);
			
			if(_ind) {
				hovering = _ind - 1;
				hovering_type = NODE_COMPOSE_DRAG.move;
			}
		}
		
		if(mouse_press(mb_left, active)) {
			dynamic_input_inspecting = hovering;
			refreshDynamicDisplay();
		}
		
		if(dynamic_input_inspecting != noone) {
			var _ss = input_fix_len + dynamic_input_inspecting * data_length;
			var   a = array_safe_get_fast(anchors, _ss);
			
			if(is_struct(a)) {
				draw_set_color(COLORS._main_accent);
				draw_line(a.d0[0], a.d0[1], a.d1[0], a.d1[1]);
				draw_line(a.d0[0], a.d0[1], a.d2[0], a.d2[1]);
				draw_line(a.d3[0], a.d3[1], a.d1[0], a.d1[1]);
				draw_line(a.d3[0], a.d3[1], a.d2[0], a.d2[1]);
			}
		}
		
		if(hovering != noone) {
			var hi = input_fix_len + hovering * data_length;
			var a  = array_safe_get_fast(anchors, hi);
			
			if(is_struct(a)) {
				if(dynamic_input_inspecting == noone) {
					draw_set_color(COLORS.node_composite_overlay_border);
					draw_line(a.d0[0], a.d0[1], a.d1[0], a.d1[1]);
					draw_line(a.d0[0], a.d0[1], a.d2[0], a.d2[1]);
					draw_line(a.d3[0], a.d3[1], a.d1[0], a.d1[1]);
					draw_line(a.d3[0], a.d3[1], a.d2[0], a.d2[1]);
				}
				
				if(mouse_press(mb_left, active)) {
					if(hovering_type == NODE_COMPOSE_DRAG.move) {
						surf_dragging	= hi;
						input_dragging	= hi + 1;
						drag_type		= hovering_type;
						dragging_sx		= current_data[hi + 1][0];
						dragging_sy		= current_data[hi + 1][1];
						dragging_mx		= _mx;
						dragging_my		= _my;
						
					} else if(hovering_type == NODE_COMPOSE_DRAG.rotate) { //rot
						surf_dragging	= hi;
						input_dragging	= hi + 2;
						drag_type		= hovering_type;
						dragging_sx		= current_data[hi + 2];
						rot_anc_x		= overlay_x(a.cx, _x, _s);
						rot_anc_y		= overlay_y(a.cy, _y, _s);
						dragging_mx		= point_direction(rot_anc_x, rot_anc_y, _mx, _my);
						
					} else if(hovering_type == NODE_COMPOSE_DRAG.scale) { //sca
						surf_dragging	= hi;
						input_dragging	= hi + 3;
						drag_type		= hovering_type;
						dragging_sx		= _sca[0];
						dragging_sy		= _sca[1];
						dragging_mx		= (a.d0[0] + a.d3[0]) / 2;
						dragging_my		= (a.d0[1] + a.d3[1]) / 2;
					}
				}
			}
		}
		
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
				for(var i = input_fix_len; i < array_length(_data) - data_length; i += data_length) {
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
			
			array_push(_atlas, new SurfaceAtlas(_s, _d0[0], _d0[1], _rot, _sca[0], _sca[1]));
			_trans[i] = [ _d0[0], _d0[1], _sca[0], _sca[1], _rot ];
			
			surface_set_shader(temp_surface[_bg], sh_sample, true, BLEND.over);
				try { draw_surface_blend_ext(temp_surface[!_bg], _s, _d0[0], _d0[1], _sca[0], _sca[1], _rot, c_white, _alp, _bld, true); }
				catch(e) { noti_warning(e, noone, self); }
			surface_reset_shader();
			
			surface_set_shader(selection_surf, sh_selection_mask, false, BLEND.maximum);
				shader_set_f("index", i + 1);
				draw_surface_ext(_s, _d0[0], _d0[1], _sca[0], _sca[1], _rot, c_white, 1);
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
		
		if(LOADING_VERSION < 1_19_03_1) {
			var _ins  = load_map.inputs;
			var _dlen = load_map.data_length;
			
			if(_dlen == 7)
			for( var i = input_fix_len, n = array_length(_ins); i < n; i += data_length ) {
				if(!is_struct(_ins[i+6]) || !struct_has(_ins[i+6], "raw_value")) 
					_ins[i+6] = { raw_value: { d: [0,0] }};
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