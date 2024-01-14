globalvar MIDI_INPORT;
MIDI_INPORT = noone;

function Node_MIDI_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MIDI In";
	update_on_frame = true;
	
	w     = 128;
	min_h = 128;
	
	rtmidi_init();
	rtmidi_ignore_messages(true, true, true);
	
	var inps = rtmidi_probe_ins();
	var _miniNames = [];
	for( var i = 0; i < inps; i++ ) 
		_miniNames[i] = rtmidi_name_in(i);
	
	inputs[| 0] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: _miniNames, update_hover: false })
		.rejectArray();
		
	outputs[| 0] = nodeValue("Raw Message", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	outputs[| 1] = nodeValue("Pressing notes", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	outputs[| 2] = nodeValue("Direct values", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	watcher_controllers = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _h = ui(48);
		
		var bw = _w / 2 - ui(4);
		var bh = ui(36);
		var bx = _x;
		var by = _y + ui(8);
		if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, _focus, _hover) == 2) {
			createNewInput();
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon_light);
		var bxc = bx + bw / 2 - (string_width("Add") + ui(64)) / 2;
		var byc = by + bh / 2;
		draw_sprite_ui(THEME.add, 0, bxc + ui(24), byc,,,, COLORS._main_icon_light);
		draw_text(bxc + ui(48), byc, __txt("Add"));
		
		var bx = _x + bw + ui(8);
		var amo = ds_list_size(inputs);
		if(amo > 1 && buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, _focus, _hover) == 2) {
			var _out = outputs[| ds_list_size(outputs) - 1];
			for( var i = 0, n = array_length(_out.value_to); i < n; i++ )
				_out.value_to[i].removeFrom();
			
			array_remove(input_display_list, ds_list_size(inputs) - 1);
			ds_list_delete(inputs,  ds_list_size(inputs)  - 1);
			ds_list_delete(outputs, ds_list_size(outputs) - 1);
		}
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon_light);
		var bxc = bx + bw / 2 - (string_width("Remove") + ui(64)) / 2;
		var byc = by + bh / 2;
		draw_sprite_ui(THEME.minus, 0, bxc + ui(24), byc,,,, COLORS._main_icon_light, (amo > 1) * 0.5 + 0.5);
		draw_set_alpha((amo > 1) * 0.5 + 0.5);
		draw_text(bxc + ui(48), byc, __txt("Remove"));
		draw_set_alpha(1);
		
		var _wx = TEXTBOX_HEIGHT + ui(16);
		var _wy = by + bh + ui(8);
		var _ww = _w - _wx;
		var _wh = TEXTBOX_HEIGHT;
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i++ ) {
			var jun   = inputs[| i];
			var _name = jun.getName();
			var wid   = jun.editWidget;
			var _show = jun.showValue();
			
			var bs = TEXTBOX_HEIGHT;
			var bx = _x;
			var by = _wy;
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover) == 2)
				index_watching = index_watching == i? noone : i;
			var cc = index_watching == i? COLORS._main_value_negative : COLORS._main_icon;
			draw_sprite_ext(THEME.circle_16, 0, bx + bs / 2, by + bs / 2, 1, 1, 0, cc, 1);
			
			var param = new widgetParam(_wx, _wy, _ww, _wh, _show, jun.display_data, _m);
			wid.setFocusHover(_focus, _hover);
			
			var hh = wid.drawParam(param) + ui(8);
			
			if(index_watching == i) {
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_value_negative);
				draw_text(_wx + ui(6), _wy + _wh / 2 + ui(2), "Waiting for MIDI input...");
			}
			
			_h  += hh;
			_wy += hh;
		}
		
		return _h;
	}); #endregion
	
	input_display_list = [ 0, 
		["Watchers", false], watcher_controllers, 
	];
	
	setIsDynamicInput(1);
	
	static createNewInput = function() { #region
		index_watching = ds_list_size(inputs);
		
		var _inp = nodeValue("Index", self, JUNCTION_CONNECT.input,  VALUE_TYPE.integer, -1 );
		ds_list_add(inputs,  _inp);
		ds_list_add(outputs, nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, -1 ));
		
		_inp.editWidget.slidable = false;
	} #endregion
	
	index_watching = noone;
	disp_value     = 0;
	
	notesPressing = [];
	values = {};
	
	attributes.live_update = true;
	array_push(attributeEditors, ["Live update", function() { return attributes.live_update; },
		new checkBox(function() { attributes.live_update = !attributes.live_update; })]
	);
	
	static step = function() { #region
		LIVE_UPDATE = attributes.live_update;
	} #endregion
	
	static update = function() { #region
		var _inport = inputs[| 0].getValue();
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
				inputs[| index_watching].setValue(vkey);
				index_watching = noone;
			}
		}
		
		outputs[| 0].setValue(a);
		outputs[| 1].setValue(notesPressing);
		outputs[| 2].setValue(values);
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i++ ) {
			var _ikey = inputs[| i].getValue();
			outputs[| i + 2].setName($"{_ikey} Value");
			outputs[| i + 2].setValue(struct_try_get(values, _ikey, 0));
		}
		
	} #endregion
	
	static onDestroy = function() { rtmidi_deinit(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var bx   = bbox.xc;
		var by   = bbox.y0 + bbox.h * 0.55;
		
		draw_sprite_fit(s_midi, 0, bx, by, bbox.w, bbox.h * 0.75);
		draw_sprite_fit(s_midi, 1, bx, by, bbox.w, bbox.h * 0.75, array_empty(notesPressing)? c_white : COLORS._main_accent);
		
		draw_set_text(f_sdf, fa_center, fa_center, c_white);
		var text = string(disp_value);
			
		var ss = max(0.5, _s) * 0.5;
		by = bbox.y0 + bbox.h * 0.25 / 2;
			
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
			
		draw_text_cut(bx, by, text, bbox.w, ss);
	} #endregion
}