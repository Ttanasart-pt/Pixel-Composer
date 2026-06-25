function Node_Threshold_Switch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Threshold Switch";
	setDimension(96, 48);
	setAlwaysTimeline(new timelineItemNode_Threshold_Switch(self));
	
	newInput( 2, nodeValue_EButton( "Type", 0, [ "Number", "Frame" ] ));
	newInput( 0, nodeValue_Float(   "Index" )).setVisible(true, true).rejectArray();
	newInput( 1, nodeValue( "Default Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(false, true);
	// 3
	
	size_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bx = _x;
		var by = _y + ui(8);
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		var bc = COLORS._main_value_positive;
		
		if(buttonTextIconInstant(true, THEME.button_hide_fill, bx, by, bw, bh, _m, _hover, _focus, "", THEME.add, __txt("Add"), bc) == 2)
			addInput();
		
		var bx = _x + _w - bw;
		var by = _y + ui(8);
		var bc = COLORS._main_value_negative;
		var amo = attributes.size;
		var act = attributes.size > 0;
		
		if(buttonTextIconInstant(act, THEME.button_hide_fill, bx, by, bw, bh, _m, _hover, _focus, "", THEME.minus, __txt("Remove"), bc) == 2)
			deleteInput(array_length(inputs) - data_length);
		
		return _h;
	});
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.any, 0));
	
	b_add = button(function() /*=>*/ {return addInput()}).setIcon(THEME.add, 0, COLORS._main_value_positive).iconPad();
	
	input_display_list = [ 
		[ "Selector",   false ], 2, 0, 1, 
		[ "Thresholds", false, noone, b_add ], 
	]
	
	input_selecting = noone;
	
	////- Dynamic IO

	function createNewInput(index = array_length(inputs)) {
		var bDel = button(function() /*=>*/ {return node.deleteInput(index)}).setIcon(THEME.minus_16, 0, COLORS._main_icon)
			.setHoverColor(COLORS._main_value_negative);
		
		inputs[index + 0] = nodeValue_Float("Value", 0).setSideButton(bDel).setAnimable(false);
		bDel.setContext(inputs[index + 0]);
		
		inputs[index + 1] = nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ).setVisible(false, false);
		
		return inputs[index + 0];
	} 
	
	setDynamicInput(2, false);
	
	static addInput = function() {
		var index = array_length(inputs);
		
		attributes.size++;
		createNewInput();
		
		if(!UNDO_HOLDING) {
			var _inputs = array_create(data_length);
			for(var i = 0; i < data_length; i++)
				_inputs[i] = inputs[index + i];
			
			recordAction(ACTION_TYPE.custom, function(data, undo) {
				if(undo) deleteInput(data.index);
				else     insertInput(data.index, data.inputs);
				
			}, { index, inputs : _inputs }).setRef(self);
		}
		
		onInputResize();
	}
	
	static deleteInput = function(index) {
		if(!UNDO_HOLDING) {
			var _inputs = array_create(data_length);
			for(var i = 0; i < data_length; i++)
				_inputs[i] = inputs[index + i];
			
			recordAction(ACTION_TYPE.custom, function(data, undo) {
				if(undo) insertInput(data.index, data.inputs);
				else     deleteInput(data.index);
				
			}, { index, inputs : _inputs }).setRef(self);
		}
		
		attributes.size--;
		for(var i = data_length - 1; i >= 0; i--)
			array_delete(inputs, index + i, 1);
		
		onInputResize();
	}
	
	static insertInput = function(index, _inputs) {
		attributes.size++;
		
		for(var i = 0; i < data_length; i++)
			array_insert(inputs, index + i, _inputs[i]);
		
		onInputResize();
	}
	
	static refreshDynamicInput = function() {
		input_display_list = array_clone(input_display_list_raw);
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			inputs[i].index = i;
			array_push(input_display_list, i);
		}
		
		getJunctionList();
	}
	
	////- Nodes
	
	frame_switch = false;
	frame_active = undefined;
	frames       = [];
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		if(index < 0) return;
		
		inputs[1].setType(inputs[1].value_from? inputs[1].value_from.type : VALUE_TYPE.any);
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			inputs[i + 1].setType(VALUE_TYPE.any);
			if(inputs[i + 1].value_from != noone)
				inputs[i + 1].setType(inputs[i + 1].value_from.type);
		}
	}
	
	static onValueUpdate = function(index = 0) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		if(safe_mod(index - input_fix_len, data_length) == 0) {
			inputs[index + 1].setVisible(false, true);
			inputs[index + 1].name = $"{getInputData(index)} value";
		}
		
		refreshDynamicInput();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _src = getInputData(2);
			var _num = getInputData(0);
			
			var _res = getInputData(1);
			
			inputs[0].setVisible(_src == 0, _src == 0);
			
			update_on_frame = _src == 1;
			frame_switch    = _src == 1;
			frame_active    = undefined;
			frames          = [];
		#endregion
		
		var _typ = inputs[1].value_from? inputs[1].value_from.type : VALUE_TYPE.any;
		var _sel = 0;
		var _suf = "";
		
		inputs[1].setType(_typ);
		
		switch(_src) {
			case 0 : _sel = _num;    _suf = "value"; break;
			case 1 : _sel = frame+1; _suf = "frame"; break;
		}
		
		input_selecting = inputs[1];
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _inp = inputs[i + 1];
			if(_inp.value_from != noone) _inp.setType(_inp.value_from.type);
			
			var _thr = getInputData(i + 0);
			var _val = getInputData(i + 1);
			
			array_push(frames, _thr);
			
			_inp.setName($"{_thr}");
			if(_thr == "") continue;
			
			if(_sel >= _thr) {
				frame_active    = _thr;
				input_selecting = inputs[i + 1];
				_res = _val;
				_typ = inputs[i + 1].value_from? inputs[i + 1].value_from.type : inputs[i + 1].type;
			}
		}
		
		outputs[0].setType(_typ);
		outputs[0].setValue(_res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var _sel = getInputData(0);
		var _res = getInputData(1);
		var _frm = input_selecting;
		if(!is(_frm, NodeValue)) return;
		
		var to = outputs[0];
		var c0 = value_color(_frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(_frm.x, _frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
		
		draw_set_text(f_sdf, fa_left, fa_center);
		var bbox = draw_bbox;
		
		var _sw = bbox.w - 16 * _s;
		var _sh = junction_draw_hei_y * _s;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			if(!inputs[i+1].visible) continue;
			
			var val = getInputData(i);
			var str = string(val);
			
			var ss  = min(_s * 0.4 / UI_SCALE, string_scale(str, _sw, _sh));
			var sw  = string_width(str) * ss;
			var sh  = string_height(str) * ss;
			
			var sx  = bbox.x0 + 8 * _s;
			var sy  = inputs[i+1].y;
			
			draw_set_color(value_color(inputs[i+1].type));
			draw_text_transformed(sx, sy, str, ss, ss, 0);
			
		}
	}
	
	////- Timeline
	
	static drawAnimationTimeline = function(_shf, _w, _h, _s) {
		if(!frame_switch) return;
		
		draw_set_color(COLORS._main_icon);
		
		for( var i = 0, n = array_length(frames); i < n; i++ ) {
			var _x = _shf + (frames[i]) * _s;
			draw_line_width(_x, _h/2, _x, _h, 1);
		}
	}
	
	////- Serialize
	
	static postApplyDeserialize = function() { refreshDynamicInput(); }
}

function timelineItemNode_Threshold_Switch(_node) : timelineItemNode(_node) constructor {
	
	dragging = undefined;
	drag_sx  = 0;
	drag_mx  = 0;
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is(node, Node_Threshold_Switch)) return;
		if(!node.attributes.show_timeline)   return;
		if(!node.frame_switch)               return;
		
		var hovering = false;
		
		var y0 = _y;
		var y1 = _y + h;
		var cc = node.getColor();
		if(cc == c_white || cc < 0) 
			cc = COLORS._main_icon;
		
		for( var i = 0, n = array_length(node.frames); i < n; i++ ) {
			var f0 = node.frames[i];
			var f1 = i < n - 1? node.frames[i+1] : NODE_TOTAL_FRAMES;
			
			var f0x = _x + (f0 - .5) * _s;
			var f1x = _x + (f1 - .5) * _s;
			var fw  = f1x - f0x;
			
			var act = node.frame_active == f0;
			var hov = _hover && point_in_rectangle(_msx, _msy, f0x, y0, f0x + _s, y1);
			
			draw_sprite_stretched_ext(THEME.box_r5, 0, f0x, y0, fw, h, cc, .2 + act * .1);
			draw_sprite_stretched_add(THEME.box_r5, 0, f0x, y0, _s, h, cc, .2 + hov * .5);
			
			draw_sprite_stretched_ext(THEME.box_r5, 1, f0x, y0, fw, h, cc, .5 + act * .4);
			
			if(hov) hovering = true;
			if(hov && mouse_lpress(_focus)) {
				dragging = node.input_fix_len + i * node.data_length;
				drag_sx  = f0;
				drag_mx  = _msx;
			}
		}
		
		if(dragging != undefined) {
			var dv = drag_sx + (_msx - drag_mx) / _s;
			    dv = round(dv);
			    
			if(node.inputs[dragging].setValue(dv))
				UNDO_HOLDING = true;
				
			if(mouse_lrelease()) {
				dragging = undefined;
				UNDO_HOLDING = false;
			}
		}
		
		return hovering;
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Threshold_Switch";
	}
}

