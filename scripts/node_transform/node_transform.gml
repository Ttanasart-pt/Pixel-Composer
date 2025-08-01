#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Transform", "Rotation > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue((_n.inputs[5].getValue() + 90) % 360); });
		addHotkey("Node_Transform", "Render Mode > Toggle",  "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[7].setValue((_n.inputs[7].getValue() + 1) % 3); });
		addHotkey("Node_Transform", "Output Dimension Type > Toggle",  "D", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 4); });
	});

	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Transform", "Move",   "G");
		hotkeyTool("Node_Transform", "Rotate", "R");
		hotkeyTool("Node_Transform", "Scale",  "S");
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
			if(drag_axis == 0) draw_line(0, _y + drag_sy * _s, WIN_H, _y + drag_sy * _s);
			if(drag_axis == 1) draw_line(_x + drag_sx * _s, 0, _x + drag_sx * _s, WIN_W);
			
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
				
			if(mouse_press(mb_left, active)) {
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
				
			if(mouse_press(mb_left, active)) {
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
				
			if(mouse_press(mb_left, active)) {
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
	newInput(9, nodeValue_Enum_Scroll( "Output Dimension Type", OUTPUT_SCALING.same_as_input, [
		new scrollItem("Same as input"),
		new scrollItem("Constant"),
		new scrollItem("Relative to input").setTooltip("Set dimension as a multiple of input surface."),
		new scrollItem("Fit content").setTooltip("Automatically set dimension to fit content."),
	]));
	newInput(1, nodeValue_Dimension()).setVisible(false);
	newInput(7, nodeValue_Enum_Button( "Render Mode",  0, [ "Normal", "Tile", "Wrap" ] ));
	
	////- =Position
	newInput( 2, nodeValue_Vec2( "Position",       [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
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
	
	////- =Echo
	newInput(12, nodeValue_Bool( "Echo",        false ));
	newInput(13, nodeValue_Int(  "Echo Amount", 8     ));
	
	// input 15
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Dimension", VALUE_TYPE.integer, [ 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	input_display_list = [ 11, 0,  
		["Output",		 true],	9, 1, 7,
		["Position",	false], 2, 10, 3, 
		["Rotation",	false], 5, 8, 
		["Scale",		false], 6, 
		["Render",		false], 14, 
		["Echo",		 true, 12], 13, 
	];
	
	////- Tool
	
	tool_object_mov = new transform_tool_move(self);
	tool_object_rot = new transform_tool_rotate(self);
	tool_object_sca = new transform_tool_scale(self);
	
	tool_pos = new NodeTool( "Move",   THEME.tools_2d_move   ).setToolObject(tool_object_mov);
	tool_rot = new NodeTool( "Rotate", THEME.tools_2d_rotate ).setToolObject(tool_object_rot);
	tool_sca = new NodeTool( "Scale",  THEME.tools_2d_scale  ).setToolObject(tool_object_sca);
	tools    = [ tool_pos, tool_rot, tool_sca ];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_interpolation();
	
	vel        = 0;
	prev_pos   = [ 0, 0 ];
	prev_data  = noone;
	
	__p0 = [ 0, 0 ];
	__p1 = [ 0, 0 ];
	__p2 = [ 0, 0 ];
	__p3 = [ 0, 0 ];
	
	static getDimension = function(arr = 0) {
		var _surf		= getSingleValue(0, arr);
		var _out_type	= getSingleValue(9, arr);
		var _out		= getSingleValue(1, arr);
		var _rotate		= getSingleValue(5, arr);
		var _scale		= getSingleValue(6, arr);
		var ww, hh;
		
		var sw  = surface_get_width_safe(_surf);
		var sh  = surface_get_height_safe(_surf);
		
		switch(_out_type) {
			case OUTPUT_SCALING.same_as_input :
				ww = sw;
				hh = sh;
				break;
				
			case OUTPUT_SCALING.relative : 
				ww = sw * _out[0];
				hh = sh * _out[1];
				break;
				
			case OUTPUT_SCALING.constant :	
				ww = _out[0];
				hh = _out[1];
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
	
	static step = function() {
		if(!PROJECT.animator.frame_progress) return;
		var pos = getSingleValue(2);
		
		if(IS_FIRST_FRAME) {
			vel = 0;
			prev_pos[0] = pos[0];
			prev_pos[1] = pos[1];
			
		} else {
			vel = point_direction(prev_pos[0], prev_pos[1], pos[0], pos[1]);
				
			prev_pos[0] = pos[0];
			prev_pos[1] = pos[1];
		}
	}
	
	static processData = function(_outData, _data, _array_index) {
		var ins = _data[0];
		
		var out_type  = _data[9];
		var out		  = _data[1];
		var pos		  = [ _data[2][0], _data[2][1] ];
		var pos_exact = _data[10];
		var anc       = [ _data[3][0], _data[3][1] ];
		var rot_vel   = vel * _data[8];
		var rot		  = _data[5] + rot_vel;
		var sca       = _data[6];
		var mode      = _data[7];
		
		var echo      = _data[12];
		var echo_amo  = _data[13];
		var alp       = _data[14];
		
		var _outSurf  = _outData[0];
		
		var cDep = attrDepth();
		
		var  ww = surface_get_width_safe(ins);
		var  hh = surface_get_height_safe(ins);
		var _ww = ww;
		var _hh = hh;
		
		if(!is_surface(ins)) {
			surface_free_safe(_outSurf);
			_outSurf = noone;
		}
		
		_outData[1] = [ ww, hh ];
		if(_ww <= 1 && _hh <= 1) return _outData;
		
		switch(out_type) { // output dimension
			case OUTPUT_SCALING.same_as_input :
				inputs[1].setVisible(false);
				break;
				
			case OUTPUT_SCALING.constant :	
				inputs[1].setVisible(true);
				_ww  = out[0];
				_hh  = out[1];
				break;
				
			case OUTPUT_SCALING.relative : 
				inputs[1].setVisible(true);
				_ww = ww * out[0];
				_hh = hh * out[1];
				break;
				
			case OUTPUT_SCALING.scale : 
				inputs[1].setVisible(false);
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
		
		_outData[1] = [ ww, hh ];
		
		if(_ww <= 0 || _hh <= 0) return _outData;
		
		_outSurf = surface_verify(_outSurf, _ww, _hh, cDep);
		_outData[0] = _outSurf;
		
		anc[0] *= ww * sca[0];
		anc[1] *= hh * sca[1];
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		pos = point_rotate(pos[0], pos[1], pos[0] + anc[0], pos[1] + anc[1], rot);
		
		var draw_x, draw_y;
		draw_x = pos[0];
		draw_y = pos[1];
				
		if(pos_exact) {
			draw_x = round(draw_x);
			draw_y = round(draw_y);
		}
			
		if(mode == 1) { // Tile
			surface_set_shader(_outSurf);
			shader_set_interpolation(ins);
			
				draw_surface_tiled_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
				
			surface_reset_shader();
			
		} else { // Normal or wrap
			surface_set_shader(_outSurf);
			shader_set_interpolation(ins);
			
			if(echo && CURRENT_FRAME && prev_data != noone) {
				var _pre = prev_data[_array_index];
				
				for( var i = 0; i <= echo_amo; i++ ) {
					var rat = i / echo_amo;
					var _px = lerp(_pre[0][0], draw_x, rat);
					var _py = lerp(_pre[0][1], draw_y, rat);
					var _rt = lerp(_pre[1],    rot,    rat);
					var _sx = lerp(_pre[2][0], sca[0], rat);
					var _sy = lerp(_pre[2][1], sca[1], rat);
					
					if(pos_exact) {
						_px = round(_px);
						_py = round(_py);
					}
					
					draw_surface_ext_safe(ins, _px, _py, _sx, _sy, _rt, c_white, alp);
				}
			} else 
				draw_surface_ext_safe(ins, draw_x, draw_y, sca[0], sca[1], rot, c_white, alp);
			
			if(mode == 2) {
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x,       draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y - _hh, sca[0], sca[1], rot, c_white, alp);
				
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y, sca[0], sca[1], rot, c_white, alp);
				
				draw_surface_ext_safe(ins, draw_x - _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x,       draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
				draw_surface_ext_safe(ins, draw_x + _ww, draw_y + _hh, sca[0], sca[1], rot, c_white, alp);
			}
			surface_reset_shader();
		
		}
		
		prev_data[_array_index] = [
			[ draw_x, draw_y ],
			rot,
			[ sca[0], sca[1] ],
		];
		
		return _outData;
	}
	
	overlay_dragging = 0;
	corner_dragging  = 0;
	overlay_drag_mx  = 0;
	overlay_drag_my  = 0;
	overlay_drag_sx  = 0;
	overlay_drag_sy  = 0;
	overlay_drag_px  = 0;
	overlay_drag_py  = 0;
	overlay_drag_ma  = 0;
	overlay_drag_sa  = 0;
	
	__p = [ 0, 0 ];
	__tl  = [ 0, 0 ];
	__tr  = [ 0, 0 ];
	__bl  = [ 0, 0 ];
	__br  = [ 0, 0 ];
	__sz  = [ 0, 0 ];
	__rth = [ 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		if(isUsingTool("Move"))   tool_object_mov.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(isUsingTool("Rotate")) tool_object_rot.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(isUsingTool("Scale"))  tool_object_sca.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _surf = current_data[0];
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _surf_out = outputs[0].getValue();
		if(is_array(_surf_out)) {
			if(array_length(_surf_out) == 0) return;
			_surf_out = _surf_out[preview_index];
		}
		
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
		
		var ow = surface_get_width_safe(_surf_out);
		var oh = surface_get_height_safe(_surf_out);
		
		var ww  = srw * sca[0];
		var hh  = srh * sca[1];
		
		anc[0] *= ww;
		anc[1] *= hh;
		
		pos[0] -= anc[0];
		pos[1] -= anc[1];
		
		#region bounding box
			var bx0 = _x + pos[0] * _s;
			var by0 = _y + pos[1] * _s;
			
			var bx1 = _x + (pos[0] + ww) * _s;
			var by1 = _y + (pos[1] + hh) * _s;
			
			var bx2 = _x + (pos[0] + ww) * _s + 18 * sign(sca[0]);
			var by2 = _y + (pos[1] + hh) * _s + 18 * sign(sca[1]);
			
			var bax = _x + (pos[0] + anc[0]) * _s;
			var bay = _y + (pos[1] + anc[1]) * _s;
			
			point_rotate(bx0, by0, bax, bay, rot, __p); var _tlx = __p[0], _tly = __p[1];
			point_rotate(bx1, by0, bax, bay, rot, __p); var _trx = __p[0], _try = __p[1];
			point_rotate(bx0, by1, bax, bay, rot, __p); var _blx = __p[0], _bly = __p[1];
			point_rotate(bx1, by1, bax, bay, rot, __p); var _brx = __p[0], _bry = __p[1];
			point_rotate(bx2, by2, bax, bay, rot, __p); var _szx = __p[0], _szy = __p[1];
			point_rotate((bx0 + bx1) / 2, by0 - 16 * sign(sca[1]), bax, bay, rot, __p); var _rrx = __p[0], _rry = __p[1];
			var _rcx = (_tlx + _trx) / 2, _rcy = (_tly + _try) / 2;
			
			var a_index  = 0;
			var r_index  = 0;
			var tl_index = 0;
			var tr_index = 0;
			var bl_index = 0;
			var br_index = 0;
			var sz_index = 0;
			
			     if(point_in_circle(_mx, _my,  bax,  bay, 8)) a_index  = 1;
			else if(point_in_circle(_mx, _my, _rrx, _rry, 8)) r_index  = 1;
			else if(point_in_circle(_mx, _my, _tlx, _tly, 8)) tl_index = 1;
			else if(point_in_circle(_mx, _my, _trx, _try, 8)) tr_index = 1;			
			else if(point_in_circle(_mx, _my, _blx, _bly, 8)) bl_index = 1;			
			else if(point_in_circle(_mx, _my, _brx, _bry, 8)) br_index = 1;
			else if(point_in_circle(_mx, _my, _szx, _szy, 8)) sz_index = 1;
			
			draw_set_color(COLORS._main_accent);
			draw_line_width(_tlx, _tly, _trx, _try, 2);
			draw_line_width(_tlx, _tly, _blx, _bly, 2);
			draw_line_width(_trx, _try, _brx, _bry, 2);
			draw_line_width(_blx, _bly, _brx, _bry, 2);
			draw_line_width(_rcx, _rcy, _rrx, _rry, 2);
			draw_line_width(_brx, _bry, _szx, _szy, 2);
			
			draw_anchor(sz_index, _szx, _szy, ui(8), 1);
			draw_anchor(r_index,  _rrx, _rry, ui(8), 1);
			draw_anchor(tl_index, _tlx, _tly, ui(8), 2);
			draw_anchor(tr_index, _trx, _try, ui(8), 2);
			draw_anchor(bl_index, _blx, _bly, ui(8), 2);
			draw_anchor(br_index, _brx, _bry, ui(8), 2);
			
			draw_anchor_cross(a_index * .5, bax, bay, ui(8), 1, rot);
		#endregion
		
		if(overlay_dragging && overlay_dragging < 3) { //Transform
			var px = _mx - overlay_drag_mx;
			var py = _my - overlay_drag_my;
			var pos_x, pos_y;
			
			if(key_mod_press(SHIFT)) {
				var ang  = round(point_direction(overlay_drag_mx, overlay_drag_my, _mx, _my) / 45) * 45;
				var dist = point_distance(overlay_drag_mx, overlay_drag_my, _mx, _my) / _s;
				
				pos_x = overlay_drag_sx + lengthdir_x(dist, ang);
				pos_y = overlay_drag_sy + lengthdir_y(dist, ang);
			} else {
				pos_x = overlay_drag_sx + px / _s;
				pos_y = overlay_drag_sy + py / _s;
			}
			
			pos_x = value_snap(pos_x, _snx);
			pos_y = value_snap(pos_y, _sny);
			
			if(overlay_dragging == 1) { //Move
				if(inputs[2].setValue([ pos_x, pos_y ]))
					UNDO_HOLDING = true;
					
			} else if(overlay_dragging == 2) { //Move anchor
				var nanx = pos_x / ww;
				var nany = pos_y / hh;
				
				if(key_mod_press(ALT)) {
					var modi = false;
					modi = modi || inputs[3].setValue([ nanx, nany ]);
					modi = modi || inputs[2].setValue([ overlay_drag_px + pos_x, overlay_drag_py + pos_y ]);
					
					if(modi) UNDO_HOLDING = true;
				} else {
					if(inputs[3].setValue([ nanx, nany ]))
						UNDO_HOLDING = true;
				}
			}
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;	
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 3) { //Angle
			var aa = point_direction(bax, bay, _mx, _my);
			var da = angle_difference(overlay_drag_ma, aa);
			var sa;
			
			if(key_mod_press(CTRL)) sa = value_snap(overlay_drag_sa - da, 15);
			else					sa = overlay_drag_sa - da;
			
			if(inputs[5].setValue(sa))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		} else if(overlay_dragging == 4) { //Scale
			var ol_x = (overlay_drag_mx - _x) / _s;
			var ol_y = (overlay_drag_my - _y) / _s;
			var ml_x = (_mx - _x) / _s;
			var ml_y = (_my - _y) / _s;
			
			var os_x = value_snap(ol_x, _snx);
			var os_y = value_snap(ol_y, _sny);
			var ms_x = value_snap(ml_x, _snx);
			var ms_y = value_snap(ml_y, _sny);
			
			var _p   = point_rotate(ms_x - os_x, ms_y - os_y, 0, 0, -rot);
			
			var _sw = _p[0] / srw;
			var _sh = _p[1] / srh;
			var sw, sh;
			
			if(corner_dragging == 0) {
				sw = -_sw / _anc[0];
				sh = -_sh / _anc[1];
				
			} else if(corner_dragging == 1) {
				sw =  _sw / (1 - _anc[0]);
				sh = -_sh / _anc[1];
				
			} else if(corner_dragging == 2) {
				sw = -_sw / _anc[0];
				sh =  _sh / (1 - _anc[1]);
				
			} else if(corner_dragging == 3) {
				sw =  _sw / (1 - _anc[0]);
				sh =  _sh / (1 - _anc[1]);
				
			} else if(corner_dragging == 4) {
				sw =  _sw / (1 - _anc[0]);
				sh =  _sh / (1 - _anc[1]);
			}
			
			var _sw = overlay_drag_sx + sw;
			var _sh = overlay_drag_sy + sh;
			
			if(key_mod_press(SHIFT)) {
				_sw = max(_sw, _sh);
				_sh = _sw;
			}
			
			if(inputs[6].setValue([ _sw, _sh ]))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				overlay_dragging = 0;
				UNDO_HOLDING = false;
			}
		}
		
		if(overlay_dragging == 0 && mouse_press(mb_left, active)) {
			if(point_in_circle(_mx, _my, bax, bay, 8)) {
				overlay_dragging = 2;
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = anc[0];
				overlay_drag_sy  = anc[1];
				overlay_drag_px  = pos[0];
				overlay_drag_py  = pos[1];
				
			} else if(point_in_circle(_mx, _my, _tlx, _tly, 8) || 
			          point_in_circle(_mx, _my, _trx, _try, 8) || 
					  point_in_circle(_mx, _my, _blx, _bly, 8) || 
					  point_in_circle(_mx, _my, _brx, _bry, 8) || 
					  point_in_circle(_mx, _my, _szx, _szy, 8)) {
				overlay_dragging = 4;
				
				     if(point_in_circle(_mx, _my, _tlx, _tly, 8)) corner_dragging = 0;
				else if(point_in_circle(_mx, _my, _trx, _try, 8)) corner_dragging = 1;
				else if(point_in_circle(_mx, _my, _blx, _bly, 8)) corner_dragging = 2;
				else if(point_in_circle(_mx, _my, _brx, _bry, 8)) corner_dragging = 3;
				else if(point_in_circle(_mx, _my, _szx, _szy, 8)) corner_dragging = 4;
				
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = sca[0];
				overlay_drag_sy  = sca[1];
				
			} else if(point_in_circle(_mx, _my, _rrx, _rry, 8)) {
				overlay_dragging = 3;
				overlay_drag_ma  = point_direction(bax, bay, _mx, _my);
				overlay_drag_sa  = rot;
				
			} else if(point_in_triangle(_mx, _my, _tlx, _tly, _trx, _try, _blx, _bly) || 
			          point_in_triangle(_mx, _my, _trx, _try, _blx, _bly, _brx, _bry)) {
				overlay_dragging = 1;
				overlay_drag_mx  = _mx;
				overlay_drag_my  = _my;
				overlay_drag_sx  = _pos[0];
				overlay_drag_sy  = _pos[1];
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
	}

	static drawOverlayTransform = function(_node) { 
		if(_node != inputs[0].getNodeFrom()) return noone;
		
		var _tr = array_safe_get(prev_data, preview_index, noone);
		return _tr == noone? noone : [ _tr[0][0], _tr[0][1], _tr[2][0], _tr[2][1], _tr[1] ];
	}
	
}