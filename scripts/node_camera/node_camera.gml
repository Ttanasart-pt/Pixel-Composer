function Node_Camera(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Camera";
	preview_alpha = 0.5;
	
	////- =Camera
	newInput(6, nodeValue_Dimension());
	newInput(0, nodeValue_Vec2(   "Focus Center", [0,0] )).setHotkey("G");
	newInput(1, nodeValue_Slider( "Zoom",          1, [.01,4,.01] ));
	
	////- =FOV
	newInput(2, nodeValue_Bool(  "Depth of Field", false ));
	newInput(3, nodeValue_Float( "Focal distance", 0     ));
	newInput(5, nodeValue_Float( "Focal range",    0     ));
	newInput(4, nodeValue_Float( "Defocus",        1     ));
	// inputs 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	dynamic_input_inspecting    = noone;
	attributes.layer_visible    = [];
	attributes.layer_selectable = [];
	
	hold_visibility = true;
	hold_select		= true;
	
	////- Layer
	
	layer_dragging	= noone;
	layer_remove	= -1;
	layer_height    = 0;
	layer_renderer	= new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		PROCESSOR_OVERLAY_CHECK
		
		var amo = getInputAmount();
		var lh  = ui(28);
		var eh  = ui(36);
		
		var _h = ui(4);
		var hh = amo / (lh + ui(4));
		
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
			
			var _bx = _x + _w - ui(24);
			var aa  = (ind != layer_dragging || layer_dragging == noone)? 1 : 0.5;
			var vis = _vis[ind];
			var sel = _sel[ind];
			
			var _lh  = lh + ui(4);
			_h += _lh;
			
			#region draw buttons
				if(point_in_circle(_m[0], _m[1], _bx, _cy + lh / 2, ui(16))) {
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_value_negative);
					
					if(mouse_press(mb_left, _focus))
						layer_remove = ind;
				} else 
					draw_sprite_ui_uniform(THEME.icon_delete, 3, _bx, _cy + lh / 2, 1, COLORS._main_icon);
				
				if(!is_surface(_surf)) continue;
				
				var _bx = _x + ui(20);
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
				
				var _ssw = surface_get_width_safe(_surf);
				var _ssh = surface_get_height_safe(_surf);
				var _sss = min(ssh / _ssw, ssh / _ssh);
				draw_surface_ext_safe(_surf, _sx0, _sy0, _sss, _sss, 0, c_white, 1);
				
				if(dynamic_input_inspecting == ind) draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_accent, 1);
				else                                draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_icon, 0.3);
			#endregion
			
			#region draw title
				var _txt = _inp.name;
				var _txx = _sx1 + ui(12);
				var _txy = _cy + lh / 2 + ui(2);
				
				var tc = ind == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
				var tf = ind == dynamic_input_inspecting? f_p1b : f_p1;
				if(hover) tc = COLORS._main_text;
					
				draw_set_text(tf, fa_left, fa_center, tc);
				
				var _txw = string_width(_txt);
				var _txh = string_height(_txt);
				
				draw_set_alpha(aa);
				draw_text_add(_txx, _txy, _txt);
				draw_set_alpha(1);
			#endregion
			
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
				
				// if(mouse_press(mb_left, _focus))
			}
			
			if(hover && layer_dragging == noone || layer_dragging == ind) {
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
		
		for( var i = 0; i < data_length; i++ ) {
			var _in = array_safe_get(inputs, idx+i, noone);
			if(_in != noone) _in.removeFrom();
		}
		
		refreshDynamicDisplay();
		doUpdate();
	}
	
	////- Inputs
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _s    = floor((index - input_fix_len) / data_length);
		if(_s) array_push(input_display_list, new Inspector_Spacer(20, true));
		
		newInput(index + 0, nodeValue_Surface(     $"Element {_s}" ));
		newInput(index + 1, nodeValue_Enum_Button( $"Positioning {_s}", false, [ "Space", "Camera" ]));
		newInput(index + 2, nodeValue_Vec2(        $"Position {_s}",    [0,0] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
		newInput(index + 3, nodeValue_Enum_Scroll( $"Oversample {_s}",   0, __enum_array_gen(["Empty ", "Repeat ", "Repeat X", "Repeat Y"], s_node_camera_repeat)));
		newInput(index + 4, nodeValue_Vec2(        $"Parallax {_s}",    [0,0] ));
		newInput(index + 5, nodeValue_Float(       $"Depth {_s}",        0    ));
		
		while(_s >= array_length(attributes.layer_visible))    array_push(attributes.layer_visible,    true);
		while(_s >= array_length(attributes.layer_selectable)) array_push(attributes.layer_selectable, true);
		
		refreshDynamicDisplay();
		return inputs[index + 0];
	} 
	
	input_display_dynamic      =                 [ ["Surface",       false], 0, 3, ["Transform", false],     1, 2, 4, 5 ];
	input_display_dynamic_full = function(j) /*=>*/ { return [ [ $"Surface {j}", false], 0, 3, __inspc(ui(4),1,1,ui(4)), 1, 2, 4, 5 ]; }
	
	input_display_list = [
		["Camera",        false   ], 6, 0, 1, 
		["Depth Of Field", true, 2], 3, 5, 4, 
		["Elements",	  false   ], layer_renderer, 
	];
	
	setDynamicInput(6, true, VALUE_TYPE.surface);
	
	attribute_surface_depth();
	temp_surface = [ noone, noone ];
	
	static getPreviewValues = function() { return getInputData(input_fix_len); }
	
	////- Process
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		PROCESSOR_OVERLAY_CHECK
		
		var _out  = outputs[0].getValue();
		if(is_array(_out)) _out = _out[preview_index];
		
		var _dim  = current_data[6];
		var _pos  = current_data[0];
		var _zoom = current_data[1];
		
		var _cam_x = _x + (_pos[0] - _dim[0] / 2 * _zoom) * _s;
		var _cam_y = _y + (_pos[1] - _dim[1] / 2 * _zoom) * _s;
		
		var _px = _x + _pos[0] * _s;
		var _py = _y + _pos[1] * _s;
		
		if(PANEL_PREVIEW.getNodePreview() == self)
			draw_surface_ext_safe(_out, _cam_x, _cam_y, _s * _zoom, _s * _zoom);
			
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, 0, [.5, .5]));
		
		draw_set_color(COLORS._main_accent);
		var x0 = _cam_x;
		var y0 = _cam_y;
		var x1 = x0 + _dim[0] * _zoom * _s;
		var y1 = y0 + _dim[1] * _zoom * _s;
		
		draw_rectangle_dashed(x0, y0, x1, y1);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim  = _data[6];
		var _pos  = _data[0];
		var _zoom = _data[1];
		
		var _dof      = _data[2];
		var _dof_dist = _data[3];
		var _dof_stop = _data[4];
		var _dof_rang = _data[5];
		
		var cDep   = attrDepth();
		
		var _cam_x = round(_pos[0]);
		var _cam_y = round(_pos[1]);
		var _cam_w = round(_dim[0]);
		var _cam_h = round(_dim[1]);
		
		var _surf_w = round(surface_valid_size(_cam_w));
		var _surf_h = round(surface_valid_size(_cam_h));
		
		_outSurf = surface_verify(_outSurf, _surf_w, _surf_h, cDep);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _surf_w, _surf_h, cDep);
			surface_clear(temp_surface[i]);
		}
		
		var amo = getInputAmount();
		if(amo <= 0) return _outSurf;
		
		shader_set(sh_camera);
		shader_set_f("camDimension", _surf_w, _surf_h);
		shader_set_f("zoom", _zoom);
		
		var ppInd = 0;
		var _vis  = attributes.layer_visible;
		
		for( var i = 0; i < amo; i++ ) {
			var vis  = _vis[i];
			if(!vis) continue;
			
			var  ind   = input_fix_len + i * data_length;
			var _surf  = _data[ind + 0];
			var _sposT = _data[ind + 1];
			var _spos  = _data[ind + 2];
			var _samp  = _data[ind + 3];
			var _paral = _data[ind + 4];
			var _sdof  = _data[ind + 5];
			
			if(!is_surface(_surf)) continue;
			ppInd = !ppInd;
			
			var sx = _spos[0] + _paral[0] * _cam_x;
			var sy = _spos[1] + _paral[1] * _cam_y;
			
			var px, py;
			
			if(_sposT == 0) {
				px = _cam_x - sx;
				py = _cam_y - sy;
			} else {
				px = -sx;
				py = -sy;
			}
			
			var _scnW = surface_get_width_safe(_surf);
			var _scnH = surface_get_height_safe(_surf);
			
			px /= _scnW;
			py /= _scnH;
			
			shader_set_i("sampleMode",	 _samp);
			shader_set_f("scnDimension", _scnW, _scnH);
			shader_set_f("position",	 px, py);
			
			shader_set_f("bokehStrength", 0);
			if(_dof) {
				var _x = max(abs(_sdof - _dof_dist) - _dof_rang, 0);
					_x = _x * tanh(_x / 10);
				shader_set_f("bokehStrength", _x * _dof_stop);
			}
			
			shader_set_surface("backg", temp_surface[!ppInd]);	//prev surface
			shader_set_surface("scene", _surf);					//surface to draw
			
			surface_set_target(temp_surface[ppInd]);
				draw_empty(_surf_w, _surf_h);
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_shader(_outSurf, noone);
			draw_surface_safe(temp_surface[ppInd]);
		surface_reset_shader();
		
		return _outSurf;
	}
}