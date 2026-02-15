#region 
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Transform", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 90) % 360); });
		addHotkey("Node_Transform", "Render Mode > Toggle",  "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 3); });
		addHotkey("Node_Transform", "Output Dimension Type > Toggle",  "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 4); });
	});

	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_Transform", "Move",   "G");
		hotkeyCustom("Node_Transform", "Rotate", "R");
		hotkeyCustom("Node_Transform", "Scale",  "S");
	});
	
	enum OUTPUT_SCALING {
		same_as_input,
		constant,
		relative,
		scale
	}
	
	function transform_tool_move(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		drag_sx = 0;
		drag_sy = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			var _val = node.inputs[2].getValue();
			drag_sx = _val[0];
			drag_sy = _val[1];
			
			drag_axis = -1;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)     return;
			
			var _val = node.inputs[2].getValue();
			var  val = [drag_sx, drag_sy];
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			if(drag_axis == -1) {
				val[0] = drag_sx + (_mx - drag_pmx) / PANEL_PREVIEW.canvas_s;
				val[1] = drag_sy + (_my - drag_pmy) / PANEL_PREVIEW.canvas_s;
				
			} else {
				if(KEYBOARD_NUMBER == undefined) {
					if(drag_axis == 0) val[0] = drag_sx + (_mx - drag_pmx) / PANEL_PREVIEW.canvas_s;
					if(drag_axis == 1) val[1] = drag_sy + (_my - drag_pmy) / PANEL_PREVIEW.canvas_s;
					
				} else {
					if(drag_axis == 0) val[0] = drag_sx + KEYBOARD_NUMBER;
					if(drag_axis == 1) val[1] = drag_sy + KEYBOARD_NUMBER;
					
				}
			}
			
			draw_set_color(COLORS._main_icon);
			if(drag_axis == 0) draw_line_dashed(0, _y + drag_sy * _s, WIN_H, _y + drag_sy * _s);
			if(drag_axis == 1) draw_line_dashed(_x + drag_sx * _s, 0, _x + drag_sx * _s, WIN_W);
			
			if(node.inputs[2].setValue(val))
				UNDO_HOLDING = true;
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left)) {
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
	
	function transform_tool_rotate(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		drag_sr  = 0;
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
			activeKeyboard = true;
			
			var _val = node.inputs[5].getValue();
			drag_sr  = _val;
			rotate_acc = 0;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)     return;
				
			var _pos = node.inputs[2].getValue();
			var _px = _x + _pos[0] * _s;
			var _py = _y + _pos[1] * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var _d0 = point_direction(_px, _py, drag_pmx, drag_pmy);
			var _d1 = point_direction(_px, _py, _mx, _my);
			
			drag_pmx = _mx;
			drag_pmy = _my;
			
			rotate_acc += angle_difference(_d1, _d0);
			var _rr = drag_sr + rotate_acc;
			if(KEYBOARD_NUMBER != undefined) _rr = drag_sr + KEYBOARD_NUMBER;
			
			if(node.inputs[5].setValue(_rr))
				UNDO_HOLDING   = true;
				
			if(mouse_press(mb_left)) {
				activeKeyboard = false;
				UNDO_HOLDING   = false;
				PANEL_PREVIEW.resetTool();
			}
			
			var _tooltipText = "Rotating";
			if(KEYBOARD_NUMBER != undefined) _tooltipText += $" [{KEYBOARD_NUMBER}]";
			PANEL_PREVIEW.setActionTooltip(_tooltipText);
			
		}
	}
	
	function transform_tool_scale(_node) : ToolObject() constructor {
		setNode(_node);
		activeKeyboard = false;
		
		drag_sx = 0;
		drag_sy = 0;
		
		drag_pmx = undefined;
		drag_pmy = undefined;
		
		drag_axis = -1;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
			
			drag_pmx = undefined;
			drag_pmy = undefined;
			
			var _val = node.inputs[6].getValue();
			drag_sx = _val[0];
			drag_sy = _val[1];
			
			drag_axis = -1;
		}
		
		static drawOverlay  = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) /*=>*/ {
			if(!activeKeyboard)     return;
			
			var _pos = node.inputs[2].getValue();
			var _rot = node.inputs[5].getValue();
			var _px = _x + _pos[0] * _s;
			var _py = _y + _pos[1] * _s;
			
			if(drag_pmx == undefined) drag_pmx = _mx;
			if(drag_pmy == undefined) drag_pmy = _my;
			
			var val = [drag_sx, drag_sy];
			var _ss = point_distance(_mx, _my, _px, _py) / point_distance(drag_pmx, drag_pmy, _px, _py);
			var _sx = key_mod_press(SHIFT)? (_mx - _px) / (drag_pmx - _px) : _ss;
			var _sy = key_mod_press(SHIFT)? (_my - _py) / (drag_pmy - _py) : _ss;
			
			if(drag_axis == -1) {
				val[0] = drag_sx * _sx;
				val[1] = drag_sy * _sy;
				
			} else {
				if(KEYBOARD_NUMBER == undefined) {
					if(drag_axis == 0) val[0] = drag_sx * _sx;
					if(drag_axis == 1) val[1] = drag_sy * _sy;
					
				} else {
					if(drag_axis == 0) val[0] = drag_sx + KEYBOARD_NUMBER;
					if(drag_axis == 1) val[1] = drag_sy + KEYBOARD_NUMBER;
					
				}
			}
			
			draw_set_color(COLORS._main_icon);
			if(drag_axis == 0) draw_line(_px - lengthdir_x(9999, _rot), _py - lengthdir_y(9999, _rot), 
			                             _px + lengthdir_x(9999, _rot), _py + lengthdir_y(9999, _rot));
			if(drag_axis == 1) draw_line(_px - lengthdir_x(9999, _rot + 90), _py - lengthdir_y(9999, _rot + 90), 
			                             _px + lengthdir_x(9999, _rot + 90), _py + lengthdir_y(9999, _rot + 90));
			
			if(node.inputs[6].setValue(val))
				UNDO_HOLDING = true;
			
			if(key_press(ord("X"))) {
				drag_axis = drag_axis == 0? -1 : 0;
				KEYBOARD_STRING = "";
			}
			
			if(key_press(ord("Y"))) {
				drag_axis = drag_axis == 1? -1 : 1;
				KEYBOARD_STRING = "";
			}
				
			if(mouse_press(mb_left)) {
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

function Node_Transform(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform";
	dimension_index = -1;
	
	newActiveInput(11);
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Output
	newInput( 9, nodeValue_Enum_Scroll( "Output Dimension Type", OUTPUT_SCALING.same_as_input, [
		new scrollItem("Same as input"),
		new scrollItem("Constant"),
		new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
		new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
	]));
	newInput( 1, nodeValue_Dimension()).setVisible(false);
	newInput(15, nodeValue_Vec2( "Dimension Scale", [1,1], { linked: true} ));
	newInput( 7, nodeValue_Enum_Button( "Render Mode",  0, [ "Normal", "Tile", "Wrap" ] ));
	
	////- =Position
	newInput( 2, nodeValue_Vec2( "Position", [.5,.5] )).setUnitSimple()
		.setAnimPreset([
			[ "Left",  [ [ 0, [ 1.5, 0.5] ], [ 1, [-0.5, 0.5] ]], THEME.apreset_left  ], 
			[ "Right", [ [ 0, [-0.5, 0.5] ], [ 1, [ 1.5, 0.5] ]], THEME.apreset_right ], 
			[ "Up",    [ [ 0, [ 0.5, 1.5] ], [ 1, [ 0.5,-0.5] ]], THEME.apreset_up    ], 
			[ "Down",  [ [ 0, [ 0.5,-0.5] ], [ 1, [ 0.5, 1.5] ]], THEME.apreset_down  ], 
		]);
	newInput(10, nodeValue_Bool( "Round Position",  false, "Round position to the nearest integer value to avoid jittering."));
	newInput( 3, nodeValue_Anchor());
	
	////- =Rotation
	newInput(4, nodeValue_Bool(     "Relative Anchor",    true ));
	newInput(5, nodeValue_Rotation( "Rotation",           0    ));
	newInput(8, nodeValue_Slider(   "Rotate by Velocity", 0    )).setTooltip("Make the surface rotates to follow its movement.");
	
	////- =Scale
	newInput(6, nodeValue_Vec2( "Scale", [1,1], { linked: true} ));
	
	////- =Render
	newInput(14, nodeValue_Slider( "Alpha", 1 ));
	
	////- =Stretch
	newInput(17, nodeValue_Bool(  "Stretch",           false ));
	newInput(18, nodeValue_Float( "Stretch Intensity", 4     ));
	newInput(19, nodeValue_Float( "Inv Stretch",       0     )).setTooltip("Contract the other axis when stretching to preserve volume.");
	
	////- =Echo
	newInput(12, nodeValue_Bool(    "Echo",        false ));
	newInput(16, nodeValue_EButton( "Echo Type",   0, [ "Static", "Animated" ] ));
	newInput(13, nodeValue_Int(     "Echo Amount", 8     ));
	// input 20
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone    ));
	newOutput(2, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []       ));
	newOutput(1, nodeValue_Output( "Dimension",   VALUE_TYPE.integer, [ 1, 1 ] )).setDisplay(VALUE_DISPLAY.vector).setVisible(false);
	
	input_display_list = [ 11, 0,  
		[ "Output",   true     ], 9, 1, 15, 7,
		[ "Position", false    ], 2, 10, 3, 
		[ "Rotation", false    ], 5, 8, 
		[ "Scale",    false    ], 6, 
		[ "Render",   false    ], 14, 
		[ "Stretch",  true, 17 ], 18, 19, 
		[ "Echo",     true, 12 ], 16, 13, 
	];
	
	output_display_list = [ 0, 2, 1 ];
	
	////- Tool
	
	tool_object_mov = new transform_tool_move(self);
	tool_object_rot = new transform_tool_rotate(self);
	tool_object_sca = new transform_tool_scale(self);
	
	tool_pos = new NodeTool( "Move",   THEME.tools_2d_move   ).setToolObject(tool_object_mov);
	tool_rot = new NodeTool( "Rotate", THEME.tools_2d_rotate ).setToolObject(tool_object_rot);
	tool_sca = new NodeTool( "Scale",  THEME.tools_2d_scale  ).setToolObject(tool_object_sca);
	tools    = [ tool_pos, tool_rot, tool_sca ];
	
	////- Draw
	
	attribute_surface_depth();
	attribute_interpolation();
	
	transformData = noone;
	
	__p0 = [ 0, 0 ];
	__p1 = [ 0, 0 ];
	__p2 = [ 0, 0 ];
	__p3 = [ 0, 0 ];
	
	drag_type = noone;
	drag_anchor  = 0;
	dragging_ax  = 0; dragging_ay  = 0;
	dragging_sx  = 0; dragging_sy  = 0;
	dragging_px  = 0; dragging_py  = 0;
	dragging_mx  = 0; dragging_my  = 0;
	dragging_ma  = 0; 
	dragging_sa  = 0;
	
	__p = [ 0, 0 ];
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		if(isUsingTool("Move"))   tool_object_mov.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(isUsingTool("Rotate")) tool_object_rot.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(isUsingTool("Scale"))  tool_object_sca.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _surf = current_data[0];
		if(is_array(_surf)) { 
			if(array_empty(_surf)) return;
			_surf = _surf[preview_index];
		}
		
		var _surf_out = outputs[0].getValue();
		if(is_array(_surf_out)) {
			if(array_empty(_surf_out)) return;
			_surf_out = _surf_out[preview_index];
		}
		
		var hovering = false;
		var __pos = current_data[2];
		var pos   = [ __pos[0], __pos[1] ];
		var _pos  = [ __pos[0], __pos[1] ];
		
		var __anc = current_data[3];
		var anc   = [ __anc[0], __anc[1] ];
		var _anc  = [ __anc[0], __anc[1] ];
		
		var rot = current_data[5];
		var sca = current_data[6];
		
		var srw = surface_get_width_safe(_surf);
		var srh = surface_get_height_safe(_surf);
		
		var ow  = surface_get_width_safe(_surf_out);
		var oh  = surface_get_height_safe(_surf_out);
		
		var ww  = srw * sca[0];
		var hh  = srh * sca[1];
		
		var hov_ax = 0;
		var hov_ay = 0;
		
		anc[0] *= ww;
		anc[1] *= hh;
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		#region bounding box
			var bx0 = _x + pos[0] * _s;
			var by0 = _y + pos[1] * _s;
			
			var bx1 = _x + (pos[0] + ww) * _s;
			var by1 = _y + (pos[1] + hh) * _s;
			
			var bx2 = _x + (pos[0] + ww) * _s + 16 * sign(sca[0]);
			var by2 = _y + (pos[1] + hh) * _s + 16 * sign(sca[1]);
			
			var bax = _x + (pos[0] + anc[0]) * _s;
			var bay = _y + (pos[1] + anc[1]) * _s;
			
			point_rotate(bx0, by0, bax, bay, rot, __p); 
			var _tlx = __p[0], _tly = __p[1];
			
			point_rotate(bx1, by0, bax, bay, rot, __p); 
			var _trx = __p[0], _try = __p[1];
			
			point_rotate(bx0, by1, bax, bay, rot, __p); 
			var _blx = __p[0], _bly = __p[1];
			
			point_rotate(bx1, by1, bax, bay, rot, __p); 
			var _brx = __p[0], _bry = __p[1];
			
			point_rotate(bx2, by2, bax, bay, rot, __p); 
			var _szx = __p[0], _szy = __p[1];
			
			point_rotate((bx0 + bx1) / 2, by0 - 24 * sign(sca[1]), bax, bay, rot, __p); var _rrx = __p[0], _rry = __p[1];
			var _rcx = (_tlx + _trx) / 2, _rcy = (_tly + _try) / 2;
			
			var a_index  = 0;
			var r_index  = 0;
			var sz_index = 0;
			
			var hov_corner = noone;
			
			     if(point_in_circle(_mx, _my,  bax,  bay, 8)) a_index  = 1;
			else if(point_in_circle(_mx, _my, _rrx, _rry, 8)) r_index  = 1;
			else if(point_in_circle(_mx, _my, _szx, _szy, 8)) sz_index = 1;
			
			else if(point_in_circle(_mx, _my, _tlx, _tly, 8)) { hov_corner = 0; hov_ax = _brx; hov_ay = _bry; }
			else if(point_in_circle(_mx, _my, _blx, _bly, 8)) { hov_corner = 1; hov_ax = _trx; hov_ay = _try; }
			else if(point_in_circle(_mx, _my, _trx, _try, 8)) { hov_corner = 2; hov_ax = _blx; hov_ay = _bly; }
			else if(point_in_circle(_mx, _my, _brx, _bry, 8)) { hov_corner = 3; hov_ax = _tlx; hov_ay = _tly; }
			
			draw_set_color(COLORS._main_accent);
			draw_line_width(_tlx, _tly, _trx, _try, 2);
			draw_line_width(_tlx, _tly, _blx, _bly, 2);
			draw_line_width(_trx, _try, _brx, _bry, 2);
			draw_line_width(_blx, _bly, _brx, _bry, 2);
			draw_line_width(_rcx, _rcy, _rrx, _rry, 2);
			draw_line_width(_brx, _bry, _szx, _szy, 2);
			
			draw_anchor(sz_index, _szx, _szy, ui(8), 1);
			draw_anchor(r_index,  _rrx, _rry, ui(8), 1);
			
			draw_anchor(hov_corner == 0, _tlx, _tly, ui(8), 2);
			draw_anchor(hov_corner == 1, _blx, _bly, ui(8), 2);
			draw_anchor(hov_corner == 2, _trx, _try, ui(8), 2);
			draw_anchor(hov_corner == 3, _brx, _bry, ui(8), 2);
			
			draw_anchor_cross(a_index * .5, bax, bay, ui(8 + a_index * 2), 1, rot);
		#endregion
		
		if(drag_type != noone) {
			if(drag_type == NODE_COMPOSE_DRAG.move) {
				var px = _mx - dragging_mx;
				var py = _my - dragging_my;
				var pos_x, pos_y;
				
				if(key_mod_press(SHIFT)) {
					var ang  = round(point_direction(dragging_mx, dragging_my, _mx, _my) / 45) * 45;
					var dist = point_distance(dragging_mx, dragging_my, _mx, _my) / _s;
					
					pos_x = dragging_sx + lengthdir_x(dist, ang);
					pos_y = dragging_sy + lengthdir_y(dist, ang);
					
					draw_set_color(COLORS._main_icon);
					draw_line_dashed(_x + dragging_sx * _s + lengthdir_x(9999, ang), _y + dragging_sy * _s + lengthdir_y(9999, ang), 
					                 _x + dragging_sx * _s - lengthdir_x(9999, ang), _y + dragging_sy * _s - lengthdir_y(9999, ang));
					
				} else {
					pos_x = dragging_sx + px / _s;
					pos_y = dragging_sy + py / _s;
				}
				
				pos_x = value_snap(pos_x, _snx);
				pos_y = value_snap(pos_y, _sny);
				
				if(inputs[2].setValue([ pos_x, pos_y ])) UNDO_HOLDING = true;
			
			} else if(drag_type == NODE_COMPOSE_DRAG.anchor) {
				var px = _mx - dragging_mx;
				var py = _my - dragging_my;
				var pos_x, pos_y;
				
				if(key_mod_press(SHIFT)) {
					var ang  = round(point_direction(dragging_mx, dragging_my, _mx, _my) / 45) * 45;
					var dist = point_distance(dragging_mx, dragging_my, _mx, _my) / _s;
					
					pos_x = dragging_sx + lengthdir_x(dist, ang);
					pos_y = dragging_sy + lengthdir_y(dist, ang);
					
					draw_set_color(COLORS._main_icon);
					draw_line_dashed(bax + lengthdir_x(9999, ang), bay + lengthdir_y(9999, ang), 
					                 bax - lengthdir_x(9999, ang), bay - lengthdir_y(9999, ang));
					
				} else {
					pos_x = dragging_sx + px / _s;
					pos_y = dragging_sy + py / _s;
				}
				
				var nanx = value_snap(pos_x, _snx) / ww;
				var nany = value_snap(pos_y, _sny) / hh;
				
				if(key_mod_press(ALT)) {
					var a0 = inputs[3].setValue([ nanx, nany ]);
					var a1 = inputs[2].setValue([ dragging_px + pos_x, dragging_py + pos_y ]);
					
					if(a0 || a1) UNDO_HOLDING = true;
					
				} else {
					if(inputs[3].setValue([ nanx, nany ])) UNDO_HOLDING = true;
				}
				
			} else if(drag_type == NODE_COMPOSE_DRAG.rotate) {
				var aa = point_direction(bax, bay, _mx, _my);
				var da = angle_difference(dragging_ma, aa);
				var sa;
				
				if(key_mod_press(CTRL)) sa = value_snap(dragging_sa - da, 15);
				else					sa = dragging_sa - da;
				
				if(inputs[5].setValue(sa)) UNDO_HOLDING = true;
				
			} else if(drag_type == NODE_COMPOSE_DRAG.scale) {
				var _dmx  = _mx - dragging_mx;
				var _dmy  = _my - dragging_my;
				var _p    = point_rotate_origin(_dmx, _dmy, -rot, __p);
				
				var sca_x = (dragging_sx + _p[0] / (1 - _anc[0])) / _s / srw;
		        var sca_y = (dragging_sy + _p[1] / (1 - _anc[1])) / _s / srh;
		        
				if(key_mod_press(SHIFT)) {
					sca_x = min(sca_x, sca_y);
					sca_y = sca_x;
				}
				
				var e1 = inputs[6].setValue([ sca_x, sca_y ]);
				if(e1) UNDO_HOLDING = true;
				
			} else if(drag_type == NODE_COMPOSE_DRAG.box) {
				var _mmx = _mx;
				var _mmy = _my;
				
				if(key_mod_press(SHIFT)) {
					var _aax = key_mod_press(ALT)? bax : dragging_ax;
					var _aay = key_mod_press(ALT)? bay : dragging_ay;
					
					var _dax = _mx - _aax;
					var _day = _my - _aay;
					var _p = point_rotate_origin(_dax, _day, -rot, __p);
					
					_dax = _p[0];
					_day = _p[1];
					
					var _scd = min(abs(_dax / srw), abs(_day / srh));
					var _p = point_rotate_origin(srw * sign(_dax), srh * sign(_day), rot, __p);
					
					_mmx = _aax + _scd * _p[0];
					_mmy = _aay + _scd * _p[1];
				}
				
				var _dmx  = _mmx - dragging_mx;
				var _dmy  = _mmy - dragging_my;
				var _p    = point_rotate_origin(_dmx, _dmy, -rot, __p);
				
				var _sdx = _p[0] * (bool(drag_anchor & 0b10) * 2 - 1);
				var _sdy = _p[1] * (bool(drag_anchor & 0b01) * 2 - 1);
				
				var _ax  = bool(drag_anchor & 0b10)? _anc[0] : 1 - _anc[0];
				var _ay  = bool(drag_anchor & 0b01)? _anc[1] : 1 - _anc[1];
				
				if(key_mod_press(ALT)) {
					var sca_x = (dragging_sx + _sdx / (1 - _ax)) / _s / srw;
			        var sca_y = (dragging_sy + _sdy / (1 - _ay)) / _s / srh;
			        
					var pos_x = dragging_px;
					var pos_y = dragging_py;
					
			        var e0 = inputs[2].setValue([ pos_x, pos_y ]);
					var e1 = inputs[6].setValue([ sca_x, sca_y ]);
				    if(e0 || e1) UNDO_HOLDING = true;
					
				} else {
					var sca_x = (dragging_sx + _sdx) / _s / srw;
			        var sca_y = (dragging_sy + _sdy) / _s / srh;
			        
					var pos_x = dragging_px + _dmx / _s * _ax;
					var pos_y = dragging_py + _dmy / _s * _ay;
				
					var e0 = inputs[2].setValue([ pos_x, pos_y ]);
					var e1 = inputs[6].setValue([ sca_x, sca_y ]);
					if(e0 || e1) UNDO_HOLDING = true;
				}
				
			}
			
			if(mouse_release(mb_left)) {
				drag_type = noone;
				UNDO_HOLDING = false;
			}
			
		} else {
			var hov_rect   = point_in_rectangle_points(_mx, _my, _tlx, _tly, _trx, _try, _blx, _bly, _brx, _bry);
			
			if(a_index) {
				hovering = true;
				
				if(mouse_press(mb_left, active)) {
					drag_type    = NODE_COMPOSE_DRAG.anchor;
					dragging_mx  = _mx;
					dragging_my  = _my;
					dragging_sx  = anc[0];
					dragging_sy  = anc[1];
					dragging_px  = pos[0];
					dragging_py  = pos[1];
				}
				
			} else if(sz_index) {
				hovering = true;
				
				if(mouse_press(mb_left, active)) {
					drag_type    = NODE_COMPOSE_DRAG.scale;
					dragging_mx  = _mx;
					dragging_my  = _my;
					dragging_sx  =  sca[0] * _s * srw;
					dragging_sy  =  sca[1] * _s * srh;
					dragging_px  = _pos[0];
					dragging_py  = _pos[1];
				}
				
			} else if(r_index) {
				hovering = true;
				
				if(mouse_press(mb_left, active)) {
					drag_type    = NODE_COMPOSE_DRAG.rotate;
					dragging_ma  = point_direction(bax, bay, _mx, _my);
					dragging_sa  = rot;
				}
				
			} else if(hov_corner != noone) {
				hovering = true;
				
				if(mouse_press(mb_left, active)) {
					drag_type    = NODE_COMPOSE_DRAG.box;
					drag_anchor  = hov_corner;
					dragging_mx  = _mx;
					dragging_my  = _my;
					dragging_sx  =  sca[0] * _s * srw;
					dragging_sy  =  sca[1] * _s * srh;
					dragging_px  = _pos[0];
					dragging_py  = _pos[1];
					dragging_ax	 = hov_ax;
					dragging_ay	 = hov_ay;
				}
				
			} else if(hov_rect) {
				hovering = true;
				
	          	if(mouse_press(mb_left, active)) {
					drag_type    = NODE_COMPOSE_DRAG.move;
					dragging_mx  = _mx;
					dragging_my  = _my;
					dragging_sx  = _pos[0];
					dragging_sy  = _pos[1];
	          	}
			}
		}
	
		if(inputs[2].is_anim && inputs[2].value_from == noone && !inputs[2].sep_axis) { // draw path
			var posInp = inputs[2];
			var allPos = posInp.animator.values;
			var ox, oy, nx, ny;
			var _val, _px, _py;
			
			draw_set_color(COLORS._main_accent);
			
			for( var i = 0, n = array_length(allPos); i < n; i++ ) {
				_val = allPos[i].value;
				_px  = _val[0];
				_py  = _val[1];
				
				if(posInp.unit.mode == VALUE_UNIT.reference) {
					_px *= ow;
					_py *= oh;
				}
			
				nx = _x + _px * _s;
				ny = _y + _py * _s;
				
				draw_set_alpha(1);
				draw_circle_prec(nx, ny, 4, false);
				
				if(i) {
					draw_set_alpha(0.5);
					draw_line_dashed(ox, oy, nx, ny);
				}
			
				ox = nx;
				oy = ny;
			}
		
			draw_set_alpha(1);
		}
	
		return hovering;
	}

	static drawOverlayTransform = function(_node) { 
		if(_node != inputs[0].getNodeFrom()) return noone;
		if(transformData == noone) return;
		
		var _fr = array_safe_get(transformData, CURRENT_FRAME);
		return array_safe_get(_fr, preview_index, noone);
	}
	
	////- Nodes
	
	static getDimension = function(arr = 0) {
		var _surf     = getInputSingle( 0, arr);
		var _out_type = getInputSingle( 9, arr);
		var _dim      = getInputSingle( 1, arr);
		var _dimScal  = getInputSingle(15, arr);
		var _rotate   = getInputSingle( 5, arr);
		var _scale    = getInputSingle( 6, arr);
		var ww, hh;
		
		var sw  = surface_get_width_safe(_surf);
		var sh  = surface_get_height_safe(_surf);
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				ww = sw;
				hh = sh;
				break;
				
			case OUTPUT_SCALING.relative : 
				ww = sw * _dimScal[0];
				hh = sh * _dimScal[1];
				break;
				
			case OUTPUT_SCALING.constant :	
				ww = _dim[0];
				hh = _dim[1];
				break;
				
			case OUTPUT_SCALING.scale :	
				ww = sw * _scale[0];
				hh = sh * _scale[1];
				
				var p0 = point_rotate( 0,  0, ww / 2, hh / 2, _rotate, __p0);
				var p1 = point_rotate(ww,  0, ww / 2, hh / 2, _rotate, __p1);
				var p2 = point_rotate( 0, hh, ww / 2, hh / 2, _rotate, __p2);
				var p3 = point_rotate(ww, hh, ww / 2, hh / 2, _rotate, __p3);
				
				var minx = min(p0[0], p1[0], p2[0], p3[0]);
				var maxx = max(p0[0], p1[0], p2[0], p3[0]);
				var miny = min(p0[1], p1[1], p2[1], p3[1]);
				var maxy = max(p0[1], p1[1], p2[1], p3[1]);
				
				ww = maxx - minx;
				hh = maxy - miny;
				break;
		}
		
		return [ ww, hh ];
	}
	
	static centerAnchor = function() {
		var _surf = getInputData(0);
		
		var _out_type = getInputData(9);
		var _out = getInputData(1);
		var _sca = getInputData(6);
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		inputs[3].setValue([ 0.5, 0.5 ]);
		inputs[2].setValue([ surface_get_width_safe(_surf) / 2, surface_get_height_safe(_surf) / 2 ]);
	}
	
	static processData = function(_outData, _data, _array_index) {
		
		#region data
			var surf      = _data[ 0];
			
			var out_type  = _data[ 9];
			var dim		  = _data[ 1];
			var dimScal   = _data[15];
			var mode      = _data[ 7];
			
			var pos_raw   = _data[ 2], pos = [ pos_raw[0], pos_raw[1] ];
			var pos_exact = _data[10];
			var anc_raw	  = _data[ 3], anc = [ anc_raw[0], anc_raw[1] ];
			
			var rot		  = _data[ 5];
			var rot_vel   = _data[ 8];
			
			var sca       = _data[ 6];
			
			var alp       = _data[14];
			
			var strt      = _data[17];
			var strt_amo  = _data[18];
			var strt_inv  = _data[19];
			
			var echo      = _data[12];
			var echo_typ  = _data[16];
			var echo_amo  = _data[13];
			
			var cDep = attrDepth();
			
			transformData[CURRENT_FRAME] = noone;
		#endregion
		
		#region frames data
			var _prevData = array_safe_get(transformData, CURRENT_FRAME - 1, noone);
			    _prevData = array_safe_get(_prevData, _array_index, noone);
			
			if(_prevData != noone) {
				var dirr = point_direction( _prevData[5], _prevData[6], pos_raw[0], pos_raw[1] );
				rot += rot_vel * dirr;
			}
			
		#endregion
		
		var  ww = surface_get_width_safe(surf);
		var  hh = surface_get_height_safe(surf);
		var _ww = ww;
		var _hh = hh;
		
		var _outSurf  = _outData[0];
		if(!is_surface(surf)) { 
			surface_free_safe(_outSurf);
			_outSurf = noone;
		}
		
		_outData[1] = [ ww, hh ];
		if(_ww <= 1 && _hh <= 1) return _outData;
		
		inputs[ 1].setVisible(out_type == OUTPUT_SCALING.constant);
		inputs[15].setVisible(out_type == OUTPUT_SCALING.relative);
		
		switch(out_type) { // output dimension
			case OUTPUT_SCALING.same_as_input :
				break;
				
			case OUTPUT_SCALING.constant :	
				_ww  = dim[0];
				_hh  = dim[1];
				break;
				
			case OUTPUT_SCALING.relative : 
				_ww = ww * dimScal[0];
				_hh = hh * dimScal[1];
				break;
				
			case OUTPUT_SCALING.scale : 
				_ww = ww * sca[0];
				_hh = hh * sca[1];
				
				var p0 = point_rotate(  0,   0, _ww / 2, _hh / 2, rot, __p0);
				var p1 = point_rotate(_ww,   0, _ww / 2, _hh / 2, rot, __p1);
				var p2 = point_rotate(  0, _hh, _ww / 2, _hh / 2, rot, __p2);
				var p3 = point_rotate(_ww, _hh, _ww / 2, _hh / 2, rot, __p3);
				
				var minx = min(p0[0], p1[0], p2[0], p3[0]);
				var maxx = max(p0[0], p1[0], p2[0], p3[0]);
				var miny = min(p0[1], p1[1], p2[1], p3[1]);
				var maxy = max(p0[1], p1[1], p2[1], p3[1]);
				
				_ww = maxx - minx;
				_hh = maxy - miny;
				break;
		}
		
		if(_ww < 1 || _hh < 1) return _outData;
		_outData[1] = [ _ww, _hh ];
		
		_outSurf = surface_verify(_outSurf, _ww, _hh, cDep);
		_outData[0] = _outSurf;
		
		anc[0] *= ww * sca[0];
		anc[1] *= hh * sca[1];
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		__p = point_rotate(pos[0], pos[1], pos[0] + anc[0], pos[1] + anc[1], rot, __p);
		
		var draw_x = pos_exact? round(__p[0]) : __p[0];
		var draw_y = pos_exact? round(__p[1]) : __p[1];
		
		_outData[2] = new SurfaceAtlas(surf, pos[0], pos[1], rot, sca[0], sca[1]);
		
		if(mode == 1) { // Tile
			surface_set_shader(_outSurf);
			shader_set_interpolation(surf);
			draw_surface_tiled_ext_safe(surf, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
			surface_reset_shader();
			
			transformData[CURRENT_FRAME][_array_index] = [ draw_x, draw_y, sca[0], sca[1], rot, pos_raw[0], pos_raw[1] ];
			return _outData;
		} 
		
		// Normal or wrap
		surface_set_shader(_outSurf);
		shader_set_interpolation(surf);
		
		if(echo) {
			if(echo_typ == 0) {
				for( var i = 0; i <= echo_amo; i++ ) {
					var rat = i / echo_amo;
					var _px = lerp(_ww/2, pos_raw[0], rat);
					var _py = lerp(_hh/2, pos_raw[1], rat);
					var _rt = lerp(0,     rot,        rat);
					var _sx = lerp(1,     sca[0],     rat);
					var _sy = lerp(1,     sca[1],     rat);
					
					var  ax = lerp(.5, anc_raw[0], rat) * ww * _sx;
					var  ay = lerp(.5, anc_raw[1], rat) * hh * _sy;
					
					_px -= ax;
					_py -= ay;
					__p = point_rotate(_px, _py, _px + ax, _py + ay, _rt, __p);
					
					_px = pos_exact? round(__p[0]) : __p[0];
					_py = pos_exact? round(__p[1]) : __p[1];
					
					draw_surface_ext_safe(surf, _px, _py, _sx, _sy, _rt, c_white, alp);
				}
				
			} else if(echo_typ == 1 && array_safe_get(transformData, CURRENT_FRAME - 1, noone) != noone) {
				var _pre = transformData[CURRENT_FRAME - 1][_array_index];
				
				for( var i = 0; i <= echo_amo; i++ ) {
					var rat = i / echo_amo;
					var _px = lerp(_pre[0], draw_x, rat);
					var _py = lerp(_pre[1], draw_y, rat);
					var _sx = lerp(_pre[2], sca[0], rat);
					var _sy = lerp(_pre[3], sca[1], rat);
					var _rt = lerp(_pre[4], rot,    rat);
					
					_px = pos_exact? round(_px) : _px;
					_py = pos_exact? round(_py) : _py;
					
					draw_surface_ext_safe(surf, _px, _py, _sx, _sy, _rt, c_white, alp);
				}
			} else 
				draw_surface_ext_safe(surf, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
			
		} else 
			draw_surface_ext_safe(surf, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
		
		if(mode == 2) {
			draw_surface_ext_safe(surf, draw_x - _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
			draw_surface_ext_safe(surf, draw_x,       draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
			draw_surface_ext_safe(surf, draw_x + _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
			
			draw_surface_ext_safe(surf, draw_x - _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
			draw_surface_ext_safe(surf, draw_x + _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
			
			draw_surface_ext_safe(surf, draw_x - _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
			draw_surface_ext_safe(surf, draw_x,       draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
			draw_surface_ext_safe(surf, draw_x + _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
		}
		surface_reset_shader();
		
		if(!strt || _prevData == noone) {
			transformData[CURRENT_FRAME][_array_index] = [ draw_x, draw_y, sca[0], sca[1], rot, pos_raw[0], pos_raw[1] ];
			return _outData;
		}
		
		var ox = _prevData[5];
		var oy = _prevData[6];
		
		var dirr  = point_direction( ox, oy, pos_raw[0], pos_raw[1] );
		var diss  = point_distance(  ox, oy, pos_raw[0], pos_raw[1] ) / _ww;
		    diss *= strt_amo;
		
		var _stAnc = [ (pos[0] + anc[0]) / _ww, 
		               (pos[1] + anc[1]) / _hh ];
		var _stDir = dirr;
		var _stStr = [1 + diss, 1 - diss * strt_inv];
		
		temp_surface[0] = surface_verify(temp_surface[0], _ww, _hh, cDep);
		surface_set_shader(temp_surface[0], sh_stretch);
			shader_set_interpolation(surf);
			shader_set_i("sampleMode", 0);
			shader_set_2("dimension", [_ww, _hh]);
			
			shader_set_2("anchor",    _stAnc );
			shader_set_f("direction", _stDir );
			shader_set_2("strength",  _stStr );

			draw_surface(_outSurf, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outSurf);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		transformData[CURRENT_FRAME][_array_index] = [ draw_x, draw_y, sca[0], sca[1], rot, pos_raw[0], pos_raw[1] ];
		return _outData;
	}
	
}