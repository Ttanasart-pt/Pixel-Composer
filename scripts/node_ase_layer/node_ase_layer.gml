function Node_ASE_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Layer";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(THEME.junc_aseprite, c_white).setVisible(false, true).rejectArray();
	newInput(2, nodeValue_Text( "Layer Name"         )).rejectArray();
	newInput(1, nodeValue_Bool( "Crop Output", false )).rejectArray();
	newInput(3, nodeValue_Bool( "Loop",        false )).rejectArray();
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Layer name",  VALUE_TYPE.text,    ""    ));
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(ase_data == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, 28, COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(32);
		}
		
		var _amo = array_length(ase_data.layers);
		var hh   = ui(24);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(ase_data.layers); i < n; i++ ) {
			var _bx    = _x + ui(24);
			var _yy    = _y + ui(8) + i * hh;
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
			draw_text_add(_bx + ui(16), _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	input_display_list = [
		0, layer_renderer, 2, 1, 3, 
	];
	
	ase_data     = noone;
	layer_object = noone;
	
	static onValueFromUpdate = function(index) { if(index == 0 || index == 2) findLayer(); }
	
	static findLayer = function() {
		var _data  = getInputDataForce(0);
		var _lname = getInputDataForce(2);
		
		ase_data = _data;
		if(_data == noone) return;
		if(layer_object != noone && layer_object.name == _lname) return;
		
		layer_object    = noone;
		update_on_frame = false;
		
		setDisplayName(_lname, false);
		
		for( var i = 0, n = array_length(ase_data.layers); i < n; i++ ) {
			if(ase_data.layers[i].name != _lname) continue;
			
			layer_object    = ase_data.layers[i];
			update_on_frame = layer_object.anim;
			break;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var data   = getInputData(0);
		var celDim = getInputData(1);
		var _lname = getInputData(2);
		var _loop  = getInputData(3);
		
		ase_data = data;
		outputs[1].setValue(_lname);
		
		findLayer();
		if(!update_on_frame) frame = 0;
		if(layer_object == noone) { logNode($"Layer name {_lname} not found."); return; }
		
		var cel = layer_object.getCel(frame - data._tag_delay, _loop);
		var ww  = data.content[$ "Width"];
		var hh  = data.content[$ "Height"];
		var cw  = cel? cel.data[$ "Width"]  : 1;
		var ch  = cel? cel.data[$ "Height"] : 1;
		
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
			
		findLayer();
	}
}