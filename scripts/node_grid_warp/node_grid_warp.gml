#region global
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Grid_Warp", "Move Selection",      "G");
		hotkeyCustom("Node_Grid_Warp", "Rotate Selection",    "R");
		hotkeyCustom("Node_Grid_Warp", "Scale Selection",     "S");
	});
	
	function grid_warp_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origins = [];
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _ancs = node.anchor_select;
			if(array_empty(_ancs)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			drag_axis = -1;
			
			origins  = [];
			origin_x = 0;
			origin_y = 0;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var _p = node.inputs[_ancs[i]].getValue();
				origins[i] = array_clone(_p);
				
				origin_x += _p[0];
				origin_y += _p[1];
			}
				
			origin_x /= n;
			origin_y /= n;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _ancs = node.anchor_select;
			
			drag_pmx = drag_pmx == undefined? _mx : drag_pmx;
			drag_pmy = drag_pmy == undefined? _my : drag_pmy;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var dx = (_mx - drag_pmx) / _s;
			var dy = (_my - drag_pmy) / _s;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var inp = node.inputs[_ancs[i]];
				var val = inp.getValue();
				var ori = origins[i];
				
				val[0] = ori[0];
				val[1] = ori[1];
				
				if(drag_axis == -1) {
					val[0] = ori[0] + dx;
					val[1] = ori[1] + dy;
					
				} else {
					if(KEYBOARD_NUMBER == undefined) {
						if(drag_axis == 0) val[0] = ori[0] + dx;
						if(drag_axis == 1) val[1] = ori[1] + dy;
						
					} else {
						if(drag_axis == 0) val[0] = ori[0] + KEYBOARD_NUMBER;
						if(drag_axis == 1) val[1] = ori[1] + KEYBOARD_NUMBER;
					}
				}
				
				if(inp.setValue(val)) UNDO_HOLDING = true;
			}
			
			draw_set_color(COLORS._main_icon);
			switch(drag_axis) {
				case  0: draw_line_dashed( 0, oy, 9999, oy); break;
				case  1: draw_line_dashed(ox,  0, ox, 9999); break;
			}
			
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
	
	function grid_warp_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origins = [];
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		rotate_acc = 0;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _ancs = node.anchor_select;
			if(array_empty(_ancs)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			
			rotate_acc = 0;
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			origins  = [];
			origin_x = 0;
			origin_y = 0;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var _p = node.inputs[_ancs[i]].getValue();
				origins[i] = array_clone(_p);
				
				origin_x += _p[0];
				origin_y += _p[1];
			}
				
			origin_x /= n;
			origin_y /= n;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _ancs = node.anchor_select;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var _d0 = point_direction(ox, oy, drag_pmx, drag_pmy);
			var _d1 = point_direction(ox, oy, _mx, _my);
			
			drag_pmx = _mx;
			drag_pmy = _my;
			
			rotate_acc += angle_difference(_d1, _d0);
			var rr = KEYBOARD_NUMBER ?? rotate_acc;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var inp = node.inputs[_ancs[i]];
				var val = inp.getValue();
				var ori = origins[i];
				
				var dis = point_distance(  origin_x, origin_y, ori[0], ori[1] );
				var dir = point_direction( origin_x, origin_y, ori[0], ori[1] );
				
				val[0] = origin_x + lengthdir_x(dis, dir + rr);
				val[1] = origin_y + lengthdir_y(dis, dir + rr);
				
				if(inp.setValue(val)) UNDO_HOLDING = true;
			}
			
			draw_set_color(COLORS._main_icon);
			draw_line_dashed(ox, oy, _mx, _my);
			
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
	
	function grid_warp_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		origins = [];
		origin_x = 0;
		origin_y = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			var _ancs = node.anchor_select;
			if(array_empty(_ancs)) { PANEL_PREVIEW.resetTool(); return; }
			
			activeKeyboard = true;
			
			rotate_acc = 0;
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			drag_axis = -1;
			
			origins  = [];
			origin_x = 0;
			origin_y = 0;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var _p = node.inputs[_ancs[i]].getValue();
				origins[i] = array_clone(_p);
				
				origin_x += _p[0];
				origin_y += _p[1];
			}
				
			origin_x /= n;
			origin_y /= n;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)  { PANEL_PREVIEW.resetTool(); return; }
			
			var _ancs = node.anchor_select;
			
			drag_pmx = drag_pmx == undefined? _mx : drag_pmx;
			drag_pmy = drag_pmy == undefined? _my : drag_pmy;
			
			var ox = _x + origin_x * _s;
			var oy = _y + origin_y * _s;
			
			var _ss = point_distance(_mx, _my, ox, oy) / point_distance(drag_pmx, drag_pmy, ox, oy);
			var _sc = KEYBOARD_NUMBER ?? _ss;
			
			for( var i = 0, n = array_length(_ancs); i < n; i++ ) {
				var inp = node.inputs[_ancs[i]];
				var val = inp.getValue();
				var ori = origins[i];
				
				val[0] = ori[0];
				val[1] = ori[1];
				
				if(drag_axis == -1) {
					val[0] = origin_x + (ori[0] - origin_x) * _sc;
					val[1] = origin_y + (ori[1] - origin_y) * _sc;
					
				} else {
					if(drag_axis == 0) val[0] = origin_x + (ori[0] - origin_x) * _sc;
					if(drag_axis == 1) val[1] = origin_y + (ori[1] - origin_y) * _sc;
					
				}
				
				if(inp.setValue(val)) UNDO_HOLDING = true;
			}
			
			draw_set_color(COLORS._main_icon);
			switch(drag_axis) {
				case -1: draw_line_dashed(ox, oy, _mx, _my); break;
				case  0: draw_line_dashed( 0, oy, 9999, oy); break;
				case  1: draw_line_dashed(ox,  0, ox, 9999); break;
			}
			
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
	
#endregion

function Node_Grid_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid Warp";
	preview_select_surface = false;
	
	newActiveInput(1);
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Mesh
	newInput(4, nodeValue_Area(  "Area",       DEF_AREA_REF )).setUnitSimple();
	newInput(2, nodeValue_IVec2( "Grid",       [2,2]        )).setTooltip("Amount of grid subdivision. Higher number means more grid, detail.").rejectArray();
	newInput(3, nodeValue_Int(   "Subdivision", 4           ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = index - input_fix_len;
		
		newInput(index, nodeValue_Vec2($"Anchor {i}", [ 0, 0 ])).setUnitSimple();
		
		array_push(input_display_list, index);
		inputs[index].overlay_draw_text = false;
		return inputs[index];
	} setDynamicInput(1, false);
	
	b_reset = button(function() /*=>*/ {return resetInput(true)}).setIcon(THEME.refresh_16, 0, COLORS._main_value_negative).setTooltip(__txt("Reset All"));
	
	input_display_list = [ 1, 0, 
		[ "Mesh",    false ], 4, 2, 3, 
		[ "Anchors",  true, noone, b_reset ], 
	];
	
	////- Nodes
	
	#region ---- edit ----
		tools = [
			new NodeTool( "Edit Area",           THEME.canvas_resize   ), 
			-1,
			new NodeTool( "Move Selection",      THEME.tools_2d_move   ).setVisible(false).setToolObject(new grid_warp_tool_move(self)),
			new NodeTool( "Rotate Selection",    THEME.tools_2d_rotate ).setVisible(false).setToolObject(new grid_warp_tool_rotate(self)),
			new NodeTool( "Scale Selection",     THEME.tools_2d_scale  ).setVisible(false).setToolObject(new grid_warp_tool_scale(self)),
		];
		
		anchor_select = [];
		anchor_freeze = 0;
		
		dragging_anchor = undefined;
		dragging_sx = 0;
		dragging_sy = 0;
		dragging_mx = 0;
		dragging_my = 0;
		dragging_px = 0;
		dragging_py = 0;
	#endregion
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static selectClear = function() { anchor_select = []; }
	static selectAll   = function() { 
		anchor_select = array_create(array_length(inputs) - input_fix_len);
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ )
			anchor_select[i - input_fix_len] = i;
	}
	
	static resetInput = function(_val = false) {
		var _dim   = getDimension(0);
		
		var _area  = getInputData(4);
		var _grid  = getInputData(2);
		
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		var _amo   = (_gridW + 1) * (_gridH + 1);
		var _ind   = input_fix_len;
		
		var ax0 = _area[0] - _area[2];
		var ay0 = _area[1] - _area[3];
		var ax1 = _area[0] + _area[2];
		var ay1 = _area[1] + _area[3];
		
		if(_val && array_length(inputs) - input_fix_len == _amo) {
			for(var i = 0; i <= _gridH; i++)
			for(var j = 0; j <= _gridW; j++) {
				var _inp = inputs[input_fix_len + i * (_gridW + 1) + j];
				_inp.setValue([ lerp(ax0, ax1, j / _gridW), lerp(ay0, ay1, i / _gridH) ]);
			}
			return;
		}
		
		input_display_list = array_clone(input_display_list_raw, 1);
		array_resize(inputs, input_fix_len);
		
		for(var i = 0; i <= _gridH; i++)
		for(var j = 0; j <= _gridW; j++) {
			var _inp = createNewInput();
			_inp.setValue([ lerp(ax0, ax1, j / _gridW), lerp(ay0, ay1, i / _gridH) ]);
		}
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _surf  = getInputData(0);
		var _grid  = getInputData(2);
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		var panel  = _params[$ "panel"] ?? noone;
		
		var _aamo = (_gridW + 1) * (_gridH + 1);
		var _iamo = getInputAmount();
		if(_iamo != _aamo) return w_hovering;
		
		#region draw grid
			var _an = array_create(_iamo);
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
				var _i = i - input_fix_len;
				
				var _rawVal = getInputData(i);
				_an[_i][0] = _x + _rawVal[0] * _s;
				_an[_i][1] = _y + _rawVal[1] * _s;
			}
			
			draw_set_color(isUsingTool("Edit Area")? COLORS._main_icon : COLORS._main_accent);
			
			for( var i = 0; i <  _gridH; i++ )
			for( var j = 0; j <= _gridW; j++ ) {
				var _a0 = _an[(i    ) * (_gridW + 1) + j];
				var _a1 = _an[(i + 1) * (_gridW + 1) + j];
				draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
			}
			
			for( var i = 0; i <= _gridH; i++ )
			for( var j = 0; j <  _gridW; j++ ) {
				var _a0 = _an[i * (_gridW + 1) + (j    )];
				var _a1 = _an[i * (_gridW + 1) + (j + 1)];
				draw_line(_a0[0], _a0[1], _a1[0], _a1[1]);
			}
		#endregion
		
		if(isUsingTool("Edit Area"))
			return InputDrawOverlay(inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var hoverIndex = undefined;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var anc = getInputData(i);
			var ax  = _x + anc[0] * _s;
			var ay  = _y + anc[1] * _s;
			
			var _hv = hover && point_in_circle(_mx, _my, ax, ay, ui(8));
			draw_anchor(_hv, ax, ay, ui(8), 1);
			
			if(_hv) hoverIndex = i;
		}
		
		if(hoverIndex != undefined) {
			w_hovering = true;
			
			if(mouse_lpress(active)) {
				var anc = getInputData(hoverIndex);
				
				dragging_anchor = hoverIndex;
				dragging_sx = anc[0];
				dragging_sy = anc[1];
				dragging_mx = _mx;
				dragging_my = _my;
				dragging_px = _mx;
				dragging_py = _my;
			}
		}
		
		if(dragging_anchor != undefined) {
			var _mmx = _mx;
			var _mmy = _my;
			
			if(key_mod_check(CTRL)) {
				_mmx = round(_mx);
				_mmy = round(_my);
			}
			
			var _mmx = value_snap(_mx, _snx);
			var _mmy = value_snap(_my, _sny);
			
			var vx = dragging_sx + (_mmx - dragging_mx) / _s;
			var vy = dragging_sy + (_mmy - dragging_my) / _s;
				
			var _edited = false;
			
			if(inputs[dragging_anchor].setValue([vx, vy]))
				_edited = true;
			
			var dx = (_mx - dragging_px) / _s;
			var dy = (_my - dragging_py) / _s;
			
			for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
				var _a = anchor_select[i];
				if(_a == dragging_anchor) continue;
				
				var _val = getInputData(_a);
				_val[0] += dx;
				_val[1] += dy;
				
				if(inputs[_a].setValue(_val))
					_edited = true;
			}
			
			dragging_px = _mx;
			dragging_py = _my;
				
			if(_edited) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) { 
				dragging_anchor = undefined;
				UNDO_HOLDING    = false;
			}
		}
		
		var _show_selecting = isNotUsingTool();
		
		if(isUsingTool()) {
			var _currTool = PANEL_PREVIEW.tool_current;
			var _tool     = _currTool.getToolObject();
			
			if(_tool != noone) {
				_tool.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
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
				
				var amo = array_length(inputs);
				var anchor_select_map = array_create(amo);
				
				if(key_mod_press(SHIFT)) 
				for( var i = 0, n = array_length(anchor_select); i < n; i++ ) 
					anchor_select_map[anchor_select[i]] = 1;
				
				for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
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
			
			for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
				var _a   = anchor_select[i];
				var _anc = getInputData(_a);
				
				var ax = _x + _anc[0] * _s;
				var ay = _y + _anc[1] * _s;
				
				draw_anchor(0, ax, ay, ui(8), 2);
			}
			
		}
		
		return w_hovering;
	}
	
	static preGetInputs  = function() {
		var _grid  = inputs[2].getValue();
		var _gridW = _grid[0];
		var _gridH = _grid[1];
		
		var _aamo = (_gridW + 1) * (_gridH + 1);
		var _iamo = getInputAmount();
		if(_iamo != _aamo) resetInput();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf  = _data[0];
			
			var _area  = _data[4];
			var _grid  = _data[2];
			var _subd  = _data[3];
			
			var _gridW = _grid[0];
			var _gridH = _grid[1];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim  = surface_get_dimension(_surf);
		var _stW  = _gridW? 1 / _gridW : 1;
		var _stH  = _gridH? 1 / _gridH : 1;
		var _imp  = 1 / _subd;
		
		var u0 = (_area[0] - _area[2]) / _dim[0];
		var v0 = (_area[1] - _area[3]) / _dim[1];
		var u1 = (_area[0] + _area[2]) / _dim[0];
		var v1 = (_area[1] + _area[3]) / _dim[1];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_set_color_alpha(c_white, 1);
			gpu_set_tex_filter(attributes.interpolate > 1);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
			var _itr = 0;
			var ix0, ix1, iy0, iy1;
			
			for( var i = 0; i < _gridH; i++ )
			for( var j = 0; j < _gridW; j++ ) {
				var _a0 = _data[input_fix_len + (i  ) * (_gridW+1) + (j  )];
				var _a1 = _data[input_fix_len + (i  ) * (_gridW+1) + (j+1)];
				var _a2 = _data[input_fix_len + (i+1) * (_gridW+1) + (j  )];
				var _a3 = _data[input_fix_len + (i+1) * (_gridW+1) + (j+1)];
				
				var _a0x = _a0[0], _a0y = _a0[1];
				var _a1x = _a1[0], _a1y = _a1[1];
				var _a2x = _a2[0], _a2y = _a2[1];
				var _a3x = _a3[0], _a3y = _a3[1];

				var _u0 = lerp(u0, u1,  j    * _stW);
				var _u1 = lerp(u0, u1, (j+1) * _stW);
				var _v0 = lerp(v0, v1,  i    * _stH);
				var _v1 = lerp(v0, v1, (i+1) * _stH);
				
				var xx = 0, yy = 0;
				
				repeat( _subd ) {
					xx = 0;
					repeat( _subd ) {
						
						iy0 = yy  * _imp;
						iy1 = iy0 + _imp;
						
						ix0 = xx  * _imp;
						ix1 = ix0 + _imp;
						
						var _aa0x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy0);
						var _aa0y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix0);
						
						var _aa1x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy0);
						var _aa1y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix1);
						
						var _aa2x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy1);
						var _aa2y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix0);
						
						var _aa3x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy1);
						var _aa3y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix1);
						
						var _uu0  = lerp(_u0, _u1, ix0);
						var _uu1  = lerp(_u0, _u1, ix1);
						var _vv0  = lerp(_v0, _v1, iy0);
						var _vv1  = lerp(_v0, _v1, iy1);
						
						draw_vertex_texture(_aa0x, _aa0y, _uu0, _vv0);
						draw_vertex_texture(_aa1x, _aa1y, _uu1, _vv0);
						draw_vertex_texture(_aa2x, _aa2y, _uu0, _vv1);
						
						draw_vertex_texture(_aa1x, _aa1y, _uu1, _vv0);
						draw_vertex_texture(_aa2x, _aa2y, _uu0, _vv1);
						draw_vertex_texture(_aa3x, _aa3y, _uu1, _vv1);
						
						if(++_itr > 32) {
							draw_primitive_end();
							draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
						}
						xx++;
					}
					yy++;
				}
				
			}
			
			draw_primitive_end();
			gpu_set_tex_filter(false);
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}