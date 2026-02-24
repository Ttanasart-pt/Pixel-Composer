function Node_ASE_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Layer";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, undefined ))
		.setIcon(THEME.junc_aseprite, c_white).setVisible(false, true).rejectArray();
		
	newInput(2, nodeValue_Text( "Layer Name"         )).rejectArray();
	newInput(1, nodeValue_Bool( "Crop Output", false )).rejectArray();
	newInput(3, nodeValue_Bool( "Loop",        false )).rejectArray();
	// 4
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Layer Name",  VALUE_TYPE.text,    ""    ));
	newOutput(2, nodeValue_Output("Opacity",     VALUE_TYPE.float,   1     ));
	
	static drawLayer = function(_layer, _x, _y, _w, _m, _hover, _focus, _depth = 0) {
		var  hh = ui(24);
		var _bx = _x + ui(24);
		
		if(_layer.type == 0)
			draw_sprite_ui_uniform(THEME.icon_canvas, 0, _bx, _y + hh / 2, 1, COLORS._main_icon);
			
		else if(_layer.type == 1)
			draw_sprite_ui_uniform(THEME.folder_16, 0, _bx, _y + hh / 2, 1, COLORS._main_icon);
		
		var cc = COLORS._main_text_sub;
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh - 1)) {
			cc = COLORS._main_text;
			
			if(mouse_press(mb_left, _focus))
				inputs[2].setValue(_layer.name);
		}
		
		if(_layer == layer_object)
			cc = COLORS._main_text_accent;
		
		draw_set_text(f_p2, fa_left, fa_center, cc);
		draw_text_add(_bx + ui(16) + _depth * ui(16), _y + hh / 2, _layer.name);
		
		var ch  = hh;
		    _y += hh;
		
		if(_layer.expand)
		for( var i = array_length(_layer.contents) - 1; i >= 0; i-- ) {
			var ly = _layer.contents[i];
			var lh = drawLayer(ly, _x, _y, _w, _m, _hover, _focus, _depth + 1);
			
			_y += lh;
			ch += lh;
		}
		
		return ch;
	}
	
	layer_renderer_height = undefined;
	layer_renderer        = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(!has(ase_data, "layerGraph")) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(32);
		}
		
		var _h  = layer_renderer_height ?? 0;
		var _yy = _y + ui(8);
		var _hh = ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for( var i = array_length(ase_data.layerGraph.contents) - 1; i >= 0; i-- ) {
			var _layer = ase_data.layerGraph.contents[i];
			var lh = drawLayer(_layer, _x, _yy, _w, _m, _hover, _focus);
			
			_yy += lh;
			_hh += lh;
		}
		
		layer_renderer_height = _hh;
		return _hh;
	}); 
	
	input_display_list = [
		0, layer_renderer, 2, 1, 3, 
	];
	
	////- Node
	
	ase_data     = undefined;
	layer_object = undefined;
	temp_surface = [ noone, noone, noone ];
	blend_index  = 0;
	target_surf  = noone;
	
	static findLayer = function() {
		var _data  = inputs[0].getValue();
		var _lname = inputs[2].getValue();
		if(_lname != "")
			setDisplayName(_lname, false);
		
		if(!is(_data, Node)) return;
		
		ase_data        = _data;
		layer_object    = has(ase_data.layerMap, _lname)? ase_data.layerMap[$ _lname] : undefined;
		update_on_frame = layer_object? layer_object.anim : false;
	}
	
	static renderLayer = function(_l, data, frame, _loop) {
		var c  = _l.getCel(frame - data._tag_delay, _loop);
		if(is(c, ase_cel)) {
			var cs = c.getSurface();
			var xx = c.data[$ "X"];
			var yy = c.data[$ "Y"];
			var aa = _l.alpha * c.alpha;
			
			surface_set_shader(temp_surface[blend_index], sh_sample, true, BLEND.over);
				draw_surface_blend_ext(temp_surface[!blend_index], cs, xx, yy, 1, 1, 0, c_white, aa);
			surface_reset_shader();
			blend_index = !blend_index;
		}
		
		for( var i = 0, n = array_length(_l.contents); i < n; i++ ) 
			renderLayer(_l.contents[i], data, frame, _loop);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var data   = getInputData(0);
			var celDim = getInputData(1);
			var _lname = getInputData(2);
			var _loop  = getInputData(3);
		#endregion
		
		ase_data = data;
		outputs[1].setValue(_lname);
		
		findLayer();
		if(!update_on_frame) frame = 0;
		if(layer_object == undefined) { logNode($"Layer name {_lname} not found."); return; }
		outputs[2].setValue(layer_object.alpha);
		
		var ww   = data.content[$ "Width"];
		var hh   = data.content[$ "Height"];
		var surf = outputs[0].getValue();
			
		inputs[1].setVisible(layer_object.type != 1);
			
		if(layer_object.type == 1) {
			target_surf = surface_verify(surf, ww, hh);
			blend_index = 0;
			
			for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
				temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
				surface_clear(temp_surface[i]);
			}
			
			blend_temp_surface = temp_surface[2];
			renderLayer(layer_object, data, frame, _loop);
			
			surface_set_shader(target_surf, noone, true, BLEND.over);
				draw_surface(temp_surface[!blend_index], 0, 0);
			surface_reset_shader();
			outputs[0].setValue(target_surf);
			
		} else if(layer_object.type == 0) {
			var cel = layer_object.getCel(frame - data._tag_delay, _loop);
			var cw  = cel? cel.data[$ "Width"]  : 1;
			var ch  = cel? cel.data[$ "Height"] : 1;
			
			if(celDim)	surf = surface_verify(surf, cw, ch);
			else		surf = surface_verify(surf, ww, hh);
			outputs[0].setValue(surf);
			
			if(!is(cel, ase_cel)) { 
				surface_clear(surf); 
				return;
			}
			
			var _inSurf = cel.getSurface();
			var xx = celDim? 0 : cel.data[$ "X"];
			var yy = celDim? 0 : cel.data[$ "Y"];
			var aa = layer_object.alpha * cel.alpha;
			
			surface_set_shader(surf, noone);
				draw_surface_ext_safe(_inSurf, xx, yy, 1, 1, 0, c_white, aa);
			surface_reset_shader();
		}
	}
	
	static postApplyDeserialize = function() {
		if(LOADING_VERSION < 1_18_00_0 && display_name != "")
			inputs[2].setValue(display_name);
			
		findLayer();
	}
}