#region global
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Grid_Warp", "Move Points",      "G");
		hotkeyCustom("Node_Grid_Warp", "Rotate Points",    "R");
		hotkeyCustom("Node_Grid_Warp", "Scale Points",     "S");
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
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my) /*=>*/ {
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
				
			if(mouse_lpress() || key_press(vk_enter)) {
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
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my) /*=>*/ {
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
			
			if(mouse_lpress() || key_press(vk_enter)) {
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
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my) /*=>*/ {
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
				
			if(mouse_lpress() || key_press(vk_enter)) {
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
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	
	////- =Mesh
	newInput( 4, nodeValue_Area(  "Area",       DEF_AREA_REF )).setUnitSimple();
	newInput( 2, nodeValue_IVec2( "Grid",       [2,2]        )).setTooltip("Amount of grid subdivision. Higher number means more grid, detail.").rejectArray();
	newInput( 3, nodeValue_Int(   "Subdivision", 4           ));
	newInput( 5, nodeValue_Bool(  "Bezier",     true         ));
	// 6
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	b_reset = button(function() /*=>*/ {return resetInput(true)}).setIcon(THEME.refresh_16, 0, COLORS._main_value_negative).setTooltip(__txt("Reset All"));
	
	input_display_list = [ 1, 0, 
		[ "Mesh",    false ],  4,  2,  3,  5, 
		[ "Anchors",  true, noone, b_reset ], 
	];
	
	function createNewInput() {
		var index = array_length(inputs);
		var i = index - input_fix_len;
		
		newInput( index, nodeValue_Grid_Anchor($"Anchor {i}", array_create(10) )).setUnitSimple();
		
		array_push(input_display_list, index);
		inputs[index].overlay_draw_text = false;
		return inputs[index];
	} setDynamicInput(1, false);
	
	////- Nodes
	
	#region ---- edit ----
		tools = [
			new NodeTool( "Edit Area",     THEME.canvas_resize   ), 
			-1,
			new NodeTool( "Move Points",   THEME.tools_2d_move   ).setVisible(false).setToolObject(new grid_warp_tool_move(self)),
			new NodeTool( "Rotate Points", THEME.tools_2d_rotate ).setVisible(false).setToolObject(new grid_warp_tool_rotate(self)),
			new NodeTool( "Scale Points",  THEME.tools_2d_scale  ).setVisible(false).setToolObject(new grid_warp_tool_scale(self)),
		];
		
		anchor_select = [];
		anchor_freeze = 0;
		
		dragging_anchor = undefined;
		dragging_type   = undefined;
		dragging_group  = undefined;
		
		dragging_s  = 0;
		dragging_px = undefined;
		dragging_py = undefined;
		dragging_mx = 0;
		dragging_my = 0;
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
		var _area  = inputs[4].getValue();
		var _grid  = inputs[2].getValue();
		
		var _gridW = round(_grid[0]);
		var _gridH = round(_grid[1]);
		var _amo   = (_gridW + 1) * (_gridH + 1);
		var _ind   = input_fix_len;
		
		var ax0 = _area[0] - _area[2];
		var ay0 = _area[1] - _area[3];
		var ax1 = _area[0] + _area[2];
		var ay1 = _area[1] + _area[3];
		
		var cx  = (ax1 - ax0) / _gridW / 3;
		var cy  = (ay1 - ay0) / _gridH / 3;
		
		if(_val && array_length(inputs) - input_fix_len == _amo) {
			for(var i = 0; i <= _gridH; i++)
			for(var j = 0; j <= _gridW; j++) {
				var _inp = inputs[input_fix_len + i * (_gridW + 1) + j];
				var _ivl/*:GRID_ANCHOR*/ = _inp.getValue();
				
				_ivl[@GRID_ANCHOR.x] = lerp(ax0, ax1, j / _gridW);
				_ivl[@GRID_ANCHOR.y] = lerp(ay0, ay1, i / _gridH);
				
				_ivl[@GRID_ANCHOR.tx] = 0;
				_ivl[@GRID_ANCHOR.ty] = -cy;
				
				_ivl[@GRID_ANCHOR.lx] = -cx;
				_ivl[@GRID_ANCHOR.ly] = 0;
				
				_ivl[@GRID_ANCHOR.bx] = 0;
				_ivl[@GRID_ANCHOR.by] = cy;
				
				_ivl[@GRID_ANCHOR.rx] = cx;
				_ivl[@GRID_ANCHOR.ry] = 0;
				
				_inp.setValue(_ivl);
			}
			return;
		}
		
		input_display_list = array_clone(input_display_list_raw, 1);
		array_resize(inputs, input_fix_len);
		
		for(var i = 0; i <= _gridH; i++)
		for(var j = 0; j <= _gridW; j++) {
			var _inp = createNewInput();
			var _ivl/*:GRID_ANCHOR*/ = _inp.getValue();
			
			_ivl[@GRID_ANCHOR.x] = lerp(ax0, ax1, j / _gridW);
			_ivl[@GRID_ANCHOR.y] = lerp(ay0, ay1, i / _gridH);
			
			_ivl[@GRID_ANCHOR.tx] = 0;
			_ivl[@GRID_ANCHOR.ty] = -cy;
			
			_ivl[@GRID_ANCHOR.lx] = -cx;
			_ivl[@GRID_ANCHOR.ly] = 0;
			
			_ivl[@GRID_ANCHOR.bx] = 0;
			_ivl[@GRID_ANCHOR.by] = cy;
			
			_ivl[@GRID_ANCHOR.rx] = cx;
			_ivl[@GRID_ANCHOR.ry] = 0;
			
			_inp.setValue(_ivl);
		}
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _surf  = getInputData( 0);
		
		var _area  = getInputData( 4);
		var _grid  = getInputData( 2);
		var _bezr  = getInputData( 5);
		
		var _gridW = round(_grid[0]);
		var _gridH = round(_grid[1]);
		var panel  = _params[$ "panel"] ?? noone;
		
		var gw = _gridW + 1;
		var gh = _gridH + 1;
		
		var _aamo = gw * gh;
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
			return drawOverlayInput(inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		
		var hoverIndex = undefined;
		var hoverType  = undefined;
		var hoverGroup = 0;
		
		if(key_mod_press(SHIFT)) 
			hoverGroup = key_mod_press(ALT)? 2 : 1;
		
		if(dragging_anchor != undefined)
			hoverGroup = dragging_group;
				
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var anc/*:GRID_ANCHOR*/ = getInputData(i);
			
			var ind = i - input_fix_len;
			var row = floor(ind / gw);
			var col = floor(ind % gw);
			
			var ax  = _x + anc[GRID_ANCHOR.x] * _s;
			var ay  = _y + anc[GRID_ANCHOR.y] * _s;
			
			var drt = row > 0;
			var drl = col > 0;
			var drb = row < gh - 1;
			var drr = col < gw - 1;
			
			var atx  = ax + anc[GRID_ANCHOR.tx] * _s;
			var aty  = ay + anc[GRID_ANCHOR.ty] * _s;
			
			var alx  = ax + anc[GRID_ANCHOR.lx] * _s;
			var aly  = ay + anc[GRID_ANCHOR.ly] * _s;
			
			var abx  = ax + anc[GRID_ANCHOR.bx] * _s;
			var aby  = ay + anc[GRID_ANCHOR.by] * _s;
			
			var arx  = ax + anc[GRID_ANCHOR.rx] * _s;
			var ary  = ay + anc[GRID_ANCHOR.ry] * _s;
			
			var hvt = undefined;
			
			if(hover) {
				if(_bezr) {
					if(drt && point_in_circle(_mx, _my, atx, aty, ui(10))) hvt = 1;
					if(drl && point_in_circle(_mx, _my, alx, aly, ui(10))) hvt = 2;
					if(drb && point_in_circle(_mx, _my, abx, aby, ui(10))) hvt = 3;
					if(drr && point_in_circle(_mx, _my, arx, ary, ui(10))) hvt = 4;
				}
				
				if(point_in_circle(_mx, _my, ax, ay, ui(10))) hvt = 0;
			}
			
			if(_bezr) {
				draw_set_color(COLORS._main_icon);
				if(drt) {
					var cc = hvt == 1? COLORS._main_accent : COLORS._main_icon;
					     if(hoverGroup == 0 && hvt != 0 && hvt != undefined) cc = COLORS._main_accent;
					else if(hoverGroup == 1 && hvt == 3) cc = COLORS._main_accent;
					
					draw_set_alpha(.5); draw_line(ax, ay, atx, aty); draw_set_alpha(1); 
					draw_anchor(hvt == 1, atx, aty, ui(6), 1, cc);
				}
				
				if(drl) {
					var cc = hvt == 2? COLORS._main_accent : COLORS._main_icon;
					     if(hoverGroup == 0 && hvt != 0 && hvt != undefined) cc = COLORS._main_accent;
					else if(hoverGroup == 1 && hvt == 4) cc = COLORS._main_accent;
					
					draw_set_alpha(.5); draw_line(ax, ay, alx, aly); draw_set_alpha(1); 
					draw_anchor(hvt == 2, alx, aly, ui(6), 1, cc);
				}
				
				if(drb) {
					var cc = hvt == 3? COLORS._main_accent : COLORS._main_icon;
					     if(hoverGroup == 0 && hvt != 0 && hvt != undefined) cc = COLORS._main_accent;
					else if(hoverGroup == 1 && hvt == 1) cc = COLORS._main_accent;
					
					draw_set_alpha(.5); draw_line(ax, ay, abx, aby); draw_set_alpha(1); 
					draw_anchor(hvt == 3, abx, aby, ui(6), 1, cc);
				}
				
				if(drr) {
					var cc = hvt == 4? COLORS._main_accent : COLORS._main_icon;
					     if(hoverGroup == 0 && hvt != 0 && hvt != undefined) cc = COLORS._main_accent;
					else if(hoverGroup == 1 && hvt == 2) cc = COLORS._main_accent;
					
					draw_set_alpha(.5); draw_line(ax, ay, arx, ary); draw_set_alpha(1); 
					draw_anchor(hvt == 4, arx, ary, ui(6), 1, cc);
				}
			}
			
			draw_anchor(hvt == 0, ax, ay, ui(10), 1);
			
			if(hvt != undefined) {
				hoverIndex = i;
				hoverType  = hvt;
			}
		}
		
		if(hoverIndex != undefined) {
			w_hovering = true;
			
			if(DOUBLE_CLICK) {
				var anc/*:GRID_ANCHOR*/ = getInputData(hoverIndex);
				
				var cx = _area[2] * 2 / _gridW / 3;
				var cy = _area[3] * 2 / _gridH / 3;
				
				anc[@GRID_ANCHOR.tx] = 0;
				anc[@GRID_ANCHOR.ty] = -cy;
				
				anc[@GRID_ANCHOR.lx] = -cx;
				anc[@GRID_ANCHOR.ly] = 0;
				
				anc[@GRID_ANCHOR.bx] = 0;
				anc[@GRID_ANCHOR.by] = cy;
				
				anc[@GRID_ANCHOR.rx] = cx;
				anc[@GRID_ANCHOR.ry] = 0;
			
				inputs[hoverIndex].setValue(anc);
				
			} else if(mouse_lpress(active)) {
				var anc/*:GRID_ANCHOR*/ = getInputData(hoverIndex);
				
				dragging_anchor = hoverIndex;
				dragging_type   = hoverType;
				dragging_group  = hoverGroup;
				
				dragging_s  = array_clone(anc);
				dragging_px = undefined;
				dragging_py = undefined;
				
				dragging_mx = mx;
				dragging_my = my;
			}
		}
		
		if(dragging_anchor != undefined) {
			var _edited = false;
			
			var drags/*:GRID_ANCHOR*/ = dragging_s;
			var ov/*:GRID_ANCHOR*/ = inputs[dragging_anchor].getValue();
			
			var vx = dragging_px;
			var vy = dragging_py;
			
			switch(dragging_type) {
				case 0 :
					var vx = drags[GRID_ANCHOR.x] + (mx - dragging_mx);
					var vy = drags[GRID_ANCHOR.y] + (my - dragging_my);
					
					if(key_mod_check(MOD_KEY.ctrl)) vx = round(vx); vx = PANEL_PREVIEW.snapX(vx);
					if(key_mod_check(MOD_KEY.ctrl)) vy = round(vy); vy = PANEL_PREVIEW.snapY(vy);
					
					ov[@GRID_ANCHOR.x] = vx;
					ov[@GRID_ANCHOR.y] = vy;
					
					if(inputs[dragging_anchor].setValue(ov))
						_edited = true;
					
					var dx = dragging_px == undefined? 0 : vx - dragging_px;
					var dy = dragging_py == undefined? 0 : vy - dragging_py;
					
					for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
						var _a = anchor_select[i];
						if(_a == dragging_anchor) continue;
						
						var _val/*:GRID_ANCHOR*/ = getInputData(_a);
						_val[@GRID_ANCHOR.x] += dx;
						_val[@GRID_ANCHOR.y] += dy;
						
						if(inputs[_a].setValue(_val))
							_edited = true;
					}
					break;
					
				case 1 :
					var vx = drags[GRID_ANCHOR.tx] + (mx - dragging_mx);
					var vy = drags[GRID_ANCHOR.ty] + (my - dragging_my);
					
					if(key_mod_check(MOD_KEY.ctrl)) vx = round(vx); vx = PANEL_PREVIEW.snapX(vx);
					if(key_mod_check(MOD_KEY.ctrl)) vy = round(vy); vy = PANEL_PREVIEW.snapY(vy);
					
					var dx = vx - drags[GRID_ANCHOR.tx];
					var dy = vy - drags[GRID_ANCHOR.ty];
					
					ov[@GRID_ANCHOR.tx] = drags[GRID_ANCHOR.tx] + dx; 
					ov[@GRID_ANCHOR.ty] = drags[GRID_ANCHOR.ty] + dy;
					
					if(dragging_group < 2) {
						ov[@GRID_ANCHOR.bx] = drags[GRID_ANCHOR.bx] - dx; 
						ov[@GRID_ANCHOR.by] = drags[GRID_ANCHOR.by] - dy;
					}
					
					if(dragging_group < 1) {
						ov[@GRID_ANCHOR.lx] = drags[GRID_ANCHOR.lx] + dy; 
						ov[@GRID_ANCHOR.ly] = drags[GRID_ANCHOR.ly] - dx;
						
						ov[@GRID_ANCHOR.rx] = drags[GRID_ANCHOR.rx] - dy; 
						ov[@GRID_ANCHOR.ry] = drags[GRID_ANCHOR.ry] + dx;
					}
					
					if(inputs[dragging_anchor].setValue(ov))
						_edited = true;
					
					var dx = dragging_px == undefined? 0 : vx - dragging_px;
					var dy = dragging_py == undefined? 0 : vy - dragging_py;
					
					for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
						var _a = anchor_select[i];
						if(_a == dragging_anchor) continue;
						
						var _val/*:GRID_ANCHOR*/ = getInputData(_a);
						_val[@GRID_ANCHOR.tx] += dx; 
						_val[@GRID_ANCHOR.ty] += dy;
						
						if(dragging_group < 2) {
							_val[@GRID_ANCHOR.bx] -= dx; 
							_val[@GRID_ANCHOR.by] -= dy;
						}
						
						if(dragging_group < 1) {
							_val[@GRID_ANCHOR.lx] += dy; 
							_val[@GRID_ANCHOR.ly] -= dx;
							
							_val[@GRID_ANCHOR.rx] -= dy; 
							_val[@GRID_ANCHOR.ry] += dx;
						}
						
						if(inputs[_a].setValue(_val))
							_edited = true;
					}
					break;
				
				case 2 :
					var vx = drags[GRID_ANCHOR.lx] + (mx - dragging_mx);
					var vy = drags[GRID_ANCHOR.ly] + (my - dragging_my);
					
					if(key_mod_check(MOD_KEY.ctrl)) vx = round(vx); vx = PANEL_PREVIEW.snapX(vx);
					if(key_mod_check(MOD_KEY.ctrl)) vy = round(vy); vy = PANEL_PREVIEW.snapY(vy);
					
					var dx = vx - drags[GRID_ANCHOR.lx];
					var dy = vy - drags[GRID_ANCHOR.ly];
					
					ov[@GRID_ANCHOR.lx] = drags[GRID_ANCHOR.lx] + dx; 
					ov[@GRID_ANCHOR.ly] = drags[GRID_ANCHOR.ly] + dy;
					
					if(dragging_group < 2) {
						ov[@GRID_ANCHOR.rx] = drags[GRID_ANCHOR.rx] - dx; 
						ov[@GRID_ANCHOR.ry] = drags[GRID_ANCHOR.ry] - dy;
					}
					
					if(dragging_group < 1) {
						ov[@GRID_ANCHOR.tx] = drags[GRID_ANCHOR.tx] - dy; 
						ov[@GRID_ANCHOR.ty] = drags[GRID_ANCHOR.ty] + dx;
						
						ov[@GRID_ANCHOR.bx] = drags[GRID_ANCHOR.bx] + dy; 
						ov[@GRID_ANCHOR.by] = drags[GRID_ANCHOR.by] - dx;
					}
					
					if(inputs[dragging_anchor].setValue(ov))
						_edited = true;
					
					var dx = dragging_px == undefined? 0 : vx - dragging_px;
					var dy = dragging_py == undefined? 0 : vy - dragging_py;
					
					for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
						var _a = anchor_select[i];
						if(_a == dragging_anchor) continue;
						
						var _val/*:GRID_ANCHOR*/ = getInputData(_a);
						_val[@GRID_ANCHOR.lx] += dx; 
						_val[@GRID_ANCHOR.ly] += dy;
						
						if(dragging_group < 2) {
							_val[@GRID_ANCHOR.rx] -= dx; 
							_val[@GRID_ANCHOR.ry] -= dy;
						}
						
						if(dragging_group < 1) {
							_val[@GRID_ANCHOR.tx] -= dy; 
							_val[@GRID_ANCHOR.ty] += dx;
							
							_val[@GRID_ANCHOR.bx] += dy; 
							_val[@GRID_ANCHOR.by] -= dx;
						}
						
						if(inputs[_a].setValue(_val))
							_edited = true;
					}
					break;
					
				case 3 :
					var vx = drags[GRID_ANCHOR.bx] + (mx - dragging_mx);
					var vy = drags[GRID_ANCHOR.by] + (my - dragging_my);
					
					if(key_mod_check(MOD_KEY.ctrl)) vx = round(vx); vx = PANEL_PREVIEW.snapX(vx);
					if(key_mod_check(MOD_KEY.ctrl)) vy = round(vy); vy = PANEL_PREVIEW.snapY(vy);
					
					var dx = vx - drags[GRID_ANCHOR.bx];
					var dy = vy - drags[GRID_ANCHOR.by];
					
					ov[@GRID_ANCHOR.bx] = drags[GRID_ANCHOR.bx] + dx; 
					ov[@GRID_ANCHOR.by] = drags[GRID_ANCHOR.by] + dy;
					
					if(dragging_group < 2) {
						ov[@GRID_ANCHOR.tx] = drags[GRID_ANCHOR.tx] - dx; 
						ov[@GRID_ANCHOR.ty] = drags[GRID_ANCHOR.ty] - dy;
					}
					
					if(dragging_group < 1) {
						ov[@GRID_ANCHOR.lx] = drags[GRID_ANCHOR.lx] - dy; 
						ov[@GRID_ANCHOR.ly] = drags[GRID_ANCHOR.ly] + dx;
						
						ov[@GRID_ANCHOR.rx] = drags[GRID_ANCHOR.rx] + dy; 
						ov[@GRID_ANCHOR.ry] = drags[GRID_ANCHOR.ry] - dx;
					}
					
					if(inputs[dragging_anchor].setValue(ov))
						_edited = true;
					
					var dx = dragging_px == undefined? 0 : vx - dragging_px;
					var dy = dragging_py == undefined? 0 : vy - dragging_py;
					
					for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
						var _a = anchor_select[i];
						if(_a == dragging_anchor) continue;
						
						var _val/*:GRID_ANCHOR*/ = getInputData(_a);
						_val[@GRID_ANCHOR.bx] += dx; 
						_val[@GRID_ANCHOR.by] += dy;
						
						if(dragging_group < 2) {
							_val[@GRID_ANCHOR.tx] -= dx; 
							_val[@GRID_ANCHOR.ty] -= dy;
						}
						
						if(dragging_group < 1) {
							_val[@GRID_ANCHOR.lx] -= dy; 
							_val[@GRID_ANCHOR.ly] += dx;
							
							_val[@GRID_ANCHOR.rx] += dy; 
							_val[@GRID_ANCHOR.ry] -= dx;
						}
						
						if(inputs[_a].setValue(_val))
							_edited = true;
					}
					break;
				
				case 4 :
					var vx = drags[GRID_ANCHOR.rx] + (mx - dragging_mx);
					var vy = drags[GRID_ANCHOR.ry] + (my - dragging_my);
					
					if(key_mod_check(MOD_KEY.ctrl)) vx = round(vx); vx = PANEL_PREVIEW.snapX(vx);
					if(key_mod_check(MOD_KEY.ctrl)) vy = round(vy); vy = PANEL_PREVIEW.snapY(vy);
					
					var dx = vx - drags[GRID_ANCHOR.rx];
					var dy = vy - drags[GRID_ANCHOR.ry];
					
					ov[@GRID_ANCHOR.rx] = drags[GRID_ANCHOR.rx] + dx; 
					ov[@GRID_ANCHOR.ry] = drags[GRID_ANCHOR.ry] + dy;
					
					if(dragging_group < 2) {
						ov[@GRID_ANCHOR.lx] = drags[GRID_ANCHOR.lx] - dx; 
						ov[@GRID_ANCHOR.ly] = drags[GRID_ANCHOR.ly] - dy;
					}
					
					if(dragging_group < 1) {
						ov[@GRID_ANCHOR.tx] = drags[GRID_ANCHOR.tx] + dy; 
						ov[@GRID_ANCHOR.ty] = drags[GRID_ANCHOR.ty] - dx;
						
						ov[@GRID_ANCHOR.bx] = drags[GRID_ANCHOR.bx] - dy; 
						ov[@GRID_ANCHOR.by] = drags[GRID_ANCHOR.by] + dx;
					}
					
					if(inputs[dragging_anchor].setValue(ov))
						_edited = true;
					
					var dx = dragging_px == undefined? 0 : vx - dragging_px;
					var dy = dragging_py == undefined? 0 : vy - dragging_py;
					
					for( var i = 0, n = array_length(anchor_select); i < n; i++ ) {
						var _a = anchor_select[i];
						if(_a == dragging_anchor) continue;
						
						var _val/*:GRID_ANCHOR*/ = getInputData(_a);
						_val[@GRID_ANCHOR.rx] += dx; 
						_val[@GRID_ANCHOR.ry] += dy;
						
						if(dragging_group < 2) {
							_val[@GRID_ANCHOR.lx] -= dx; 
							_val[@GRID_ANCHOR.ly] -= dy;
						}
						
						if(dragging_group < 1) {
							_val[@GRID_ANCHOR.tx] += dy; 
							_val[@GRID_ANCHOR.ty] -= dx;
							
							_val[@GRID_ANCHOR.bx] -= dy; 
							_val[@GRID_ANCHOR.by] += dx;
						}
						
						if(inputs[_a].setValue(_val))
							_edited = true;
					}
					break;
					
			}
			
			dragging_px = vx;
			dragging_py = vy;
						
			if(_edited) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) { 
				dragging_anchor = undefined;
				dragging_type   = undefined;
				dragging_group  = 0;
				UNDO_HOLDING    = false;
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
		var _gridW = round(_grid[0]);
		var _gridH = round(_grid[1]);
		
		var _aamo = (_gridW + 1) * (_gridH + 1);
		var _iamo = getInputAmount();
		if(_iamo != _aamo) resetInput();
	}
	
	////- Update
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf  = _data[ 0];
			
			var _area  = _data[ 4];
			var _grid  = _data[ 2];
			var _subd  = _data[ 3];
			var _bezr  = _data[ 5];
			
			var _gridW = round(_grid[0]);
			var _gridH = round(_grid[1]);
			
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
			var aa0, aa1, aa2, aa3;
			
			for( var i = 0; i < _gridH; i++ )
			for( var j = 0; j < _gridW; j++ ) {
				var _a0/*:GRID_ANCHOR*/ = _data[input_fix_len + (i  ) * (_gridW+1) + (j  )];
				var _a1/*:GRID_ANCHOR*/ = _data[input_fix_len + (i  ) * (_gridW+1) + (j+1)];
				var _a2/*:GRID_ANCHOR*/ = _data[input_fix_len + (i+1) * (_gridW+1) + (j  )];
				var _a3/*:GRID_ANCHOR*/ = _data[input_fix_len + (i+1) * (_gridW+1) + (j+1)];
				
				var _a0x  = _a0[GRID_ANCHOR.x],  _a0y  = _a0[GRID_ANCHOR.y];
				var _a0rx = _a0[GRID_ANCHOR.rx], _a0ry = _a0[GRID_ANCHOR.ry];
				var _a0bx = _a0[GRID_ANCHOR.bx], _a0by = _a0[GRID_ANCHOR.by];
				
				var _a1x  = _a1[GRID_ANCHOR.x],  _a1y  = _a1[GRID_ANCHOR.y];
				var _a1lx = _a1[GRID_ANCHOR.lx], _a1ly = _a1[GRID_ANCHOR.ly];
				var _a1bx = _a1[GRID_ANCHOR.bx], _a1by = _a1[GRID_ANCHOR.by];
				
				var _a2x  = _a2[GRID_ANCHOR.x],  _a2y  = _a2[GRID_ANCHOR.y];
				var _a2rx = _a2[GRID_ANCHOR.rx], _a2ry = _a2[GRID_ANCHOR.ry];
				var _a2tx = _a2[GRID_ANCHOR.tx], _a2ty = _a2[GRID_ANCHOR.ty];
				
				var _a3x  = _a3[GRID_ANCHOR.x],  _a3y  = _a3[GRID_ANCHOR.y];
				var _a3lx = _a3[GRID_ANCHOR.lx], _a3ly = _a3[GRID_ANCHOR.ly];
				var _a3tx = _a3[GRID_ANCHOR.tx], _a3ty = _a3[GRID_ANCHOR.ty];
				
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
						
						if(_bezr) {
							var a01  = eval_bezier(ix0, _a0x, _a0y, _a1x, _a1y, _a0x+_a0rx, _a0y+_a0ry, _a1x+_a1lx, _a1y+_a1ly);
							var a23  = eval_bezier(ix0, _a2x, _a2y, _a3x, _a3y, _a2x+_a2rx, _a2y+_a2ry, _a3x+_a3lx, _a3y+_a3ly);
							
							var a01b = eval_bezier(ix0, _a0bx, _a0by, _a1bx, _a1by, _a0bx+_a0rx, _a0by+_a0ry, _a1bx+_a1lx, _a1by+_a1ly);
							var a23t = eval_bezier(ix0, _a2tx, _a2ty, _a3tx, _a3ty, _a2tx+_a2rx, _a2ty+_a0ry, _a3tx+_a3lx, _a3ty+_a3ly);
							
							aa0 = eval_bezier(iy0, a01[0], a01[1], a23[0], a23[1], a01[0]+a01b[0], a01[1]+a01b[1], a23[0]+a23t[0], a23[1]+a23t[1]);
							aa2 = eval_bezier(iy1, a01[0], a01[1], a23[0], a23[1], a01[0]+a01b[0], a01[1]+a01b[1], a23[0]+a23t[0], a23[1]+a23t[1]);
							
							var b01  = eval_bezier(ix1, _a0x, _a0y, _a1x, _a1y, _a0x+_a0rx, _a0y+_a0ry, _a1x+_a1lx, _a1y+_a1ly);
							var b23  = eval_bezier(ix1, _a2x, _a2y, _a3x, _a3y, _a2x+_a2rx, _a2y+_a2ry, _a3x+_a3lx, _a3y+_a3ly);
							
							var b01b = eval_bezier(ix1, _a0bx, _a0by, _a1bx, _a1by, _a0bx+_a0rx, _a0by+_a0ry, _a1bx+_a1lx, _a1by+_a1ly);
							var b23t = eval_bezier(ix1, _a2tx, _a2ty, _a3tx, _a3ty, _a2tx+_a2rx, _a2ty+_a0ry, _a3tx+_a3lx, _a3ty+_a3ly);
							
							aa1 = eval_bezier(iy0, b01[0], b01[1], b23[0], b23[1], b01[0]+b01b[0], b01[1]+b01b[1], b23[0]+b23t[0], b23[1]+b23t[1]);
							aa3 = eval_bezier(iy1, b01[0], b01[1], b23[0], b23[1], b01[0]+b01b[0], b01[1]+b01b[1], b23[0]+b23t[0], b23[1]+b23t[1]);
							
						} else {
							var _aa0x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy0);
							var _aa0y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix0);
							
							var _aa1x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy0);
							var _aa1y = lerp(lerp(_a0y, _a2y, iy0), lerp(_a1y, _a3y, iy0), ix1);
							
							var _aa2x = lerp(lerp(_a0x, _a1x, ix0), lerp(_a2x, _a3x, ix0), iy1);
							var _aa2y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix0);
							
							var _aa3x = lerp(lerp(_a0x, _a1x, ix1), lerp(_a2x, _a3x, ix1), iy1);
							var _aa3y = lerp(lerp(_a0y, _a2y, iy1), lerp(_a1y, _a3y, iy1), ix1);
							
							aa0 = [ _aa0x, _aa0y ];
							aa1 = [ _aa1x, _aa1y ];
							aa2 = [ _aa2x, _aa2y ];
							aa3 = [ _aa3x, _aa3y ];
						}
						
						var _uu0  = lerp(_u0, _u1, ix0);
						var _uu1  = lerp(_u0, _u1, ix1);
						var _vv0  = lerp(_v0, _v1, iy0);
						var _vv1  = lerp(_v0, _v1, iy1);
						
						draw_vertex_texture(aa0[0], aa0[1], _uu0, _vv0);
						draw_vertex_texture(aa1[0], aa1[1], _uu1, _vv0);
						draw_vertex_texture(aa2[0], aa2[1], _uu0, _vv1);
						
						draw_vertex_texture(aa1[0], aa1[1], _uu1, _vv0);
						draw_vertex_texture(aa2[0], aa2[1], _uu0, _vv1);
						draw_vertex_texture(aa3[0], aa3[1], _uu1, _vv1);
						
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