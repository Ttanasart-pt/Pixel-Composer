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
	
	outputs[| 2] = nodeValue("Note velocity", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	outputs[| 3] = nodeValue("Direct values", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	notesPressing = [];
	notesVelocity = {};
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
			
			if (_typ <= 159) {
				var vnote = a[1];
				var velo  = a[2];
				
				if (_typ <= 143) array_remove(notesPressing, vnote);		//note off
				else			 array_push_unique(notesPressing, vnote);	//note on
				
				notesVelocity[$ vnote] = velo;
			} else if (_typ == 176) {
				var vkey = a[1];
				var vval = a[2];
				
				values[$ vkey] = vval;
			}
		}
		
		if(b) print(a);
		
		outputs[| 0].setValue(a);
		outputs[| 1].setValue(notesPressing);
		outputs[| 2].setValue(notesVelocity);
		outputs[| 3].setValue(values);
		
	} #endregion
	
	static onDestroy = function() { rtmidi_deinit(); }
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_midi, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
		draw_sprite_fit(s_midi, 1, bbox.xc, bbox.yc, bbox.w, bbox.h, array_empty(notesPressing)? c_white : COLORS._main_accent);
	} #endregion
}