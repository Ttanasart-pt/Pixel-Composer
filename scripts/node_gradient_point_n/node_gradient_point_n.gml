function Node_Gradient_Points_N(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Points Gradient";
	preview_select_surface = false;
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Rendering
	newInput( 1, nodeValue_EScroll( "Blend Mode", 0, [ "Exponential", "Gaussian", "Linear" ] ));
	// 
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Rendering", false ], 1, 
		[ "Points",    false ], 
	];
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = (index - input_fix_len) / data_length;
		
		newInput(index+0, nodeValue_Vec2(  $"Point {i}",     [0,0]    )).setUnitSimple();
		newInput(index+1, nodeValue_Color( $"Color {i}",     ca_white ));
		newInput(index+2, nodeValue_Float( $"Influence {i}",  6       ));
		
		array_push(input_display_list, index+0, index+1, index+2);
		
		inputs[index].overlay_draw_text = false;
		return inputs[index];
		
	} setDynamicInput(3, false);
	
	////- Node
	
	attribute_surface_depth();
	
	#region ---- edit ----
		tools = [
			new NodeTool( "Add Point",    THEME.control_add ),
			new NodeTool( "Remove Point", THEME.control_subtract ),
		];
		
		anchor_select = [];
		anchor_freeze = 0;
		
		editIndex      = undefined;
		
		point_dragging = undefined;
		point_drag_s   = undefined;
		point_drag_m   = undefined;
		point_drag_p   = undefined;
		
		selection_filter = [];
	#endregion
	
	static selectClear = function() /*=>*/ { anchor_select = []; }
	static selectAll   = function() /*=>*/ { 
		anchor_select = array_create((array_length(inputs) - input_fix_len) / data_length);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length )
			anchor_select[(i - input_fix_len) / data_length] = i;
	}
	
	static updateDisplay = function() {
		input_display_list = array_clone(input_display_list_raw, 1);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) 
			array_push(input_display_list, i);
	}
	
	static removePoint = function(index) {
		array_delete(inputs, index, data_length);
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) 
			inputs[i].index = i;
			
		updateDisplay();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var msx   = (_mx - _x) / _s;
		var msy   = (_my - _y) / _s;
		var panel = _params[$ "panel"] ?? noone;
		var hoverIndex = undefined;
		selection_filter = array_verify(selection_filter, array_length(inputs));
		
		draw_set_circle_precision(32);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var pnt = getInputData(i+0);
			var col = getInputData(i+1);
			
			var ax  = _x + pnt[0] * _s;
			var ay  = _y + pnt[1] * _s;
			
			var _hv = hover && point_in_circle(_mx, _my, ax, ay, ui(8));
			draw_anchor(_hv, ax, ay, ui(8), 0, col, selection_filter[i]? COLORS._main_accent : c_white);
			selection_filter[i] = false;
			
			if(_hv) hoverIndex = i;
		}
		
		if(point_dragging != undefined) {
			var _vx = point_drag_s[0] + (msx - point_drag_m[0]);
			var _vy = point_drag_s[1] + (msy - point_drag_m[1]);
			var _edited = false;
			
			if(inputs[point_dragging].setValue([_vx, _vy]))
				_edited = true;
			
			var dx = (_mx - point_drag_p[0]) / _s;
			var dy = (_my - point_drag_p[1]) / _s;
			
			for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
				var _a = anchor_select[i];
				if(_a == point_dragging) continue;
				
				var _val = getInputData(_a);
				_val[0] += dx;
				_val[1] += dy;
				
				if(inputs[_a].setValue(_val))
					_edited = true;
			}
			
			point_drag_p[0] = _mx;
			point_drag_p[1] = _my;
				
			if(_edited) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				point_dragging = undefined;
				UNDO_HOLDING   = false;
			}
			
			return w_hovering;
		}
		
		if(isUsingTool("Add Point")) {
			if(hoverIndex == undefined && mouse_lpress(active)) {
				var _newP = createNewInput();
				_newP.setValue([msx, msy]);
				updateDisplay();
				triggerRender();
				
				point_dragging = _newP.index;
				point_drag_s   = [msx, msy];
				point_drag_m   = [msx, msy];
			}
			
		} else if(isUsingTool("Remove Point")) {
			if(hoverIndex != undefined && mouse_lpress(active)) {
				removePoint(hoverIndex);
				triggerRender();
			}
			
		} else if(hoverIndex != undefined) {
			if(DOUBLE_CLICK) {
				var col   = getInputData(hoverIndex + 1);
				editIndex = hoverIndex + 1;
				
				var dialog = dialogCall(o_dialog_color_selector).setDefault(col).setApply(function(c) /*=>*/ { 
					if(array_empty(anchor_select))
						inputs[editIndex].setValue(c); 
					else for( var i = 0, n = array_length(anchor_select); i < n; i++ )
							inputs[anchor_select[i] + 1].setValue(c); 
				});
								
			} else if(mouse_lpress(active)) {
				var pnt = getInputData(hoverIndex);
				point_dragging = hoverIndex;
				point_drag_s   = [pnt[0], pnt[1]];
				point_drag_m   = [msx, msy];
				point_drag_p   = [_mx, _my];
			}
			
		}
		
		var _show_selecting = isNotUsingTool();
		
		if(isUsingTool()) {
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = _currTool.getToolObject();
			
			if(_tool != noone) {
				_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my);
				if(mouse_lclick()) anchor_freeze = 1;
				_show_selecting = true;
			}
		}
		
		if(_show_selecting) {
			if(anchor_freeze == 0 && panel.selection_selecting && !w_hovering) {
				var sx0 = panel.selection_x0;
				var sy0 = panel.selection_y0;
				var sx1 = panel.selection_x1;
				var sy1 = panel.selection_y1;
				
				var anchor_select_map = array_length(inputs);
				
				if(key_mod_press(SHIFT)) 
				for( var i = 0, n = array_length(anchor_select); i < n; i++ ) 
					anchor_select_map[anchor_select[i]] = 1;
				
				for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length) {
					var _anc = getInputData(i);
					
					if(point_in_rectangle(_anc[0], _anc[1], sx0, sy0, sx1, sy1)) 
						anchor_select_map[i] = 1;
				}
				
				anchor_select = [];
				for( var i = 0, n = array_length(anchor_select_map); i < n; i++ ) 
					if(anchor_select_map[i] == 1) array_push(anchor_select, i)
					
			}
			
			if(mouse_lrelease())
				anchor_freeze = 0;
			
			draw_set_color(COLORS._main_accent);
			for( var i = 0, n = array_length(anchor_select); i < n; i++ )
				selection_filter[anchor_select[i]] = true;
			
		}
		
		if(hoverIndex != undefined)
			w_hovering = true;
			
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[0];
			var _mode = _data[1];
		#endregion
		
		var _amo = getInputAmount();
		var _points = array_create(_amo * 2);
		var _colors = array_create(_amo * 4);
		var _ranges = array_create(_amo * 1);
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			var _pnt = _data[_ind + 0];
			var _col = _data[_ind + 1];
			var _rng = _data[_ind + 2];
			
			_points[i * 2 + 0] = _pnt[0] / _dim[0];
			_points[i * 2 + 1] = _pnt[1] / _dim[1];

			_colors[i * 4 + 0] = _color_get_r(_col);
			_colors[i * 4 + 1] = _color_get_g(_col);
			_colors[i * 4 + 2] = _color_get_b(_col);
			_colors[i * 4 + 3] = _color_get_a(_col);
			
			_ranges[i * 1 + 0] = _rng;
		}
		
		surface_set_shader(_outSurf, sh_gradient_points_n);
			shader_set_2("dimension",  _dim  );
			shader_set_i("mode",       _mode );
			
			shader_set_i("pointAmount", _amo );
			shader_set_f("points",   _points );
			shader_set_f("colors",   _colors );
			shader_set_f("ranges",   _ranges );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}
