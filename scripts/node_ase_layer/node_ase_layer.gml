function Node_ASE_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Layer";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(s_junc_aseprite, c_white)
		.setVisible(false, true)
		.rejectArray();
	
	newInput(1, nodeValue_Bool("Crop Output", self, false))
		.rejectArray();
	
	newInput(2, nodeValue_Text("Layer name", self, ""))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Layer name", self, VALUE_TYPE.text, ""));
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(ase_data == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, 28, COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + 14, "No data");
			return 32;
		}
		
		var _amo = array_length(ase_data.layers);
		var hh   = 24;
		var _h   = hh * _amo + 16;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(ase_data.layers); i < n; i++ ) {
			var _bx    = _x + 24;
			var _yy    = _y + 8 + i * hh;
			var _layer = ase_data.layers[i];
			
			if(_layer.type == 0) {
				draw_sprite_ui_uniform(THEME.icon_canvas, 0, _bx, _yy + hh / 2, 1, COLORS._main_icon);
				
			} else if(_layer.type == 1)
				draw_sprite_ui_uniform(THEME.folder_16, 0, _bx, _yy + hh / 2, 1, COLORS._main_icon);
			
			var cc = COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					inputs[2].setValue(_layer.name);
			}
			
			if(_layer == layer_object)
				cc = COLORS._main_text_accent;
			
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_bx + 16, _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	input_display_list = [
		0, layer_renderer, 2, 1, 
	];
	
	ase_data     = noone;
	layer_object = noone;
	
	static onValueFromUpdate = function(index) { findLayer(); }
	
	static findLayer = function() {
		layer_object = noone;
		
		var data = getInputDataForce(0);
		ase_data = data;
		if(data == noone) return;
		
		var _lname = getInputData(2);
		setDisplayName(_lname);
		
		for( var i = 0, n = array_length(data.layers); i < n; i++ ) {
			if(data.layers[i].name == _lname) 
				layer_object = data.layers[i];
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		findLayer();
		
		var data   = getInputData(0);
		var celDim = getInputData(1);
		var _lname = getInputData(2);
		
		ase_data = data;
		outputs[1].setValue(_lname);
		
		if(layer_object == noone) {
			logNode($"Layer name {_lname} not found.");
			return;
		}
		
		var cel  = layer_object.getCel(CURRENT_FRAME - data._tag_delay);
		var ww = data.content[$ "Width"];
		var hh = data.content[$ "Height"];
		var cw = cel? cel.data[$ "Width"]  : 1;
		var ch = cel? cel.data[$ "Height"] : 1;
		
		var surf = outputs[0].getValue();
		if(celDim)	surf = surface_verify(surf, cw, ch);
		else		surf = surface_verify(surf, ww, hh);
		outputs[0].setValue(surf);
		
		if(cel == 0) { surface_clear(surf); return; }
		
		var _inSurf = cel.getSurface();
		var xx = celDim? 0 : cel.data[$ "X"];
		var yy = celDim? 0 : cel.data[$ "Y"];
		
		surface_set_shader(surf, noone);
			draw_surface_safe(_inSurf, xx, yy);
		surface_reset_shader();
	}
	
	static postApplyDeserialize = function() {
		if(LOADING_VERSION < 1_18_00_0 && display_name != "")
			inputs[2].setValue(display_name);
	}
}