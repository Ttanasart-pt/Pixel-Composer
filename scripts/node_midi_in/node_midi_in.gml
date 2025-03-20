globalvar MIDI_INPORT;
MIDI_INPORT = noone;

function Node_MIDI_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MIDI In";
	update_on_frame = true;
		
	rtmidi_init();
	rtmidi_ignore_messages(true, true, true);
	
	var inps = rtmidi_probe_ins();
	if(inps == 0) noti_warning($"No MIDI device detected.", noone, self);
	var _miniNames = [];
	for( var i = 0; i < inps; i++ ) 
		_miniNames[i] = rtmidi_name_in(i);
	
	newInput(0, nodeValue_Enum_Scroll("Input", self,  0, { data: _miniNames, update_hover: false }))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Raw Message", self, VALUE_TYPE.float, []));
	
	newOutput(1, nodeValue_Output("Pressing notes", self, VALUE_TYPE.float, []));
	
	newOutput(2, nodeValue_Output("Direct values", self, VALUE_TYPE.struct, {}));
	
	watcher_controllers = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide_fill, _x, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			createNewInput();
		}
		
		var amo = array_length(inputs);
		if(buttonTextIconInstant(amo > 1, THEME.button_hide_fill, _x + _w - bw, _y + ui(8), bw, bh, _m, _focus, _hover, "", THEME.minus, __txt("Remove"), COLORS._main_value_negative) == 2) {
			var _out = outputs[array_length(outputs) - 1];
			for( var i = 0, n = array_length(_out.value_to); i < n; i++ )
				_out.value_to[i].removeFrom();
			
			array_remove(input_display_list, array_length(inputs) - 1);
			array_delete(inputs, array_length(inputs) - 1, 1);
			array_delete(inputs, array_length(inputs) - 1, 1);
			array_delete(outputs, array_length(outputs) - 1, 1);
		}
		
		var _wx = TEXTBOX_HEIGHT + ui(16);
		var _wy = _y + bh + ui(16);
		var _wh = TEXTBOX_HEIGHT;
		var _ww = _w - _wx - _wh - ui(8);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var jun   = inputs[i + 0];
			var nor   = inputs[i + 1];
			
			var _name = jun.getName();
			var wid   = jun.editWidget;
			var shw   = jun.showValue();
			
			var nwid  = nor.editWidget;
			var nshw  = nor.showValue();
			
			var bs = TEXTBOX_HEIGHT;
			var bx = _x;
			var by = _wy;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus) == 2)
				index_watching = index_watching == i? noone : i;
			var cc = index_watching == i? COLORS._main_value_negative : COLORS._main_icon;
			draw_sprite_ui(THEME.circle_16, 0, bx + bs / 2, by + bs / 2, 1, 1, 0, cc, 1);
			
			wid .setFocusHover(_focus, _hover);
			nwid.setFocusHover(_focus, _hover);
			
			var param = new widgetParam(_wx, _wy, _ww, _wh, shw, jun.display_data, _m);
			var hh = wid.drawParam(param) + ui(8);
			
			param   = new widgetParam(_wx + _ww + ui(8), _wy, _wh, _wh, nshw, nor.display_data, _m);
			param.s = _wh;
			nwid.drawParam(param);
			
			if(index_watching == i) {
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_value_negative);
				draw_text(_wx + ui(6), _wy + _wh / 2 + ui(2), "Waiting for MIDI input...");
			}
			
			_h  += hh;
			_wy += hh;
		}
		
		return _h;
	});
	
	input_display_list = [ 0, 
		["Watchers", false], watcher_controllers, 
	];
	
	static createNewInput = function(index = array_length(inputs)) {
		index_watching = index;
		
		newInput(index + 0, nodeValue_Int(  "Index",     self, -1    ));
		newInput(index + 1, nodeValue_Bool( "Normalize", self, false ));
		inputs[index].editWidget.slidable = false;
		
		var _out = nodeValue_Output("Value", self, VALUE_TYPE.float, -1 );
		array_push(outputs, _out);
		
		return inputs[index];
	} setDynamicInput(2, false);
	
	index_watching = noone;
	disp_value     = 0;
	
	notesPressing = [];
	values = {};
	
	attributes.live_update = true;
	array_push(attributeEditors, ["Live update", function() { return attributes.live_update; },
		new checkBox(function() { attributes.live_update = !attributes.live_update; })]
	);
	
	static step = function() {
		LIVE_UPDATE = attributes.live_update;
	}
	
	static update = function() {
		var _inport = inputs[0].getValue();
		if(_inport != MIDI_INPORT) {
			rtmidi_set_inport(_inport);
			MIDI_INPORT = _inport;
		}
		
		var b = rtmidi_check_message();
		var a = [];

		for (var i = 0; i < b; i++) {
			a[i]  = rtmidi_get_message(i);
		}
		
		if(array_length(a) >= 3) {
			var _typ = a[0];
			var vkey = a[1];
			var vval = a[2];
				
			if (_typ <= 159) {
				if (_typ <= 143) array_remove(notesPressing, vkey);			//note off
				else			 array_push_unique(notesPressing, vkey);	//note on
			}
			
			values[$ vkey] = vval;
			disp_value = vval;
			
			if(index_watching != noone) {
				inputs[index_watching].setValue(vkey);
				index_watching = noone;
			}
		}
		
		outputs[0].setValue(a);
		outputs[1].setValue(notesPressing);
		outputs[2].setValue(values);
		
		var _ind = 1;
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _ikey = inputs[i + 0].getValue();
			var _inor = inputs[i + 1].getValue();
			
			var _val = struct_try_get(values, _ikey, 0);
			if(_inor) _val /= 127;
			
			outputs[2 + _ind].setName($"{_ikey} Value");
			outputs[2 + _ind].setValue(_val);
			_ind++;
		}
		
	}
	
	static onDestroy = function() { rtmidi_deinit(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var bx   = bbox.xc;
		var by   = bbox.y0 + bbox.h * 0.55;
		
		draw_sprite_fit(s_midi, 0, bx, by, bbox.w, bbox.h * 0.75);
		draw_sprite_fit(s_midi, 1, bx, by, bbox.w, bbox.h * 0.75, array_empty(notesPressing)? c_white : COLORS._main_accent);
		
		draw_set_text(f_sdf, fa_center, fa_center, c_white);
		var text = string(disp_value);
		var ss = max(0.5, _s) * 0.5;
		by = bbox.y0 + bbox.h * 0.25 / 2;
			
		draw_text_cut(bx, by, text, bbox.w, ss);
	}
}