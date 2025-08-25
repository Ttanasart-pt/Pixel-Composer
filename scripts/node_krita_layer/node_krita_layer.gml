function Node_Krita_layer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Krita Layer";
	
	newInput(0, nodeValue("Data", self, CONNECT_TYPE.input, VALUE_TYPE.object, noone))
		.setIcon(THEME.junc_krita, c_white).setVisible(false, true).rejectArray();
	
	newInput(1, nodeValue_Text("Layer name")).rejectArray();
		
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Layer name",  VALUE_TYPE.text,    ""    ));
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(!is(content, Krita_File)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, 28, COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(32);
		}
		
		var _lay = content.layerDat;
		var _amo = array_length(_lay);
		var hh   = ui(24);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(_lay); i < n; i++ ) {
			var _bx    = _x + ui(24);
			var _yy    = _y + ui(8) + i * hh;
			var _layer = _lay[i];
			
			draw_sprite_ui_uniform(THEME.icon_canvas, 0, _bx, _yy + hh / 2, 1, COLORS._main_icon);
			
			var cc = COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					inputs[1].setValue(_layer.name);
			}
			
			if(_layer == layer_object)
				cc = COLORS._main_text_accent;
			
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_bx + ui(16), _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	input_display_list = [
		0, layer_renderer, 1, 
	];
	
	content      = noone;
	layer_object = noone;
	
	static onValueFromUpdate = function(index) { findLayer(); }
	
	static findLayer = function() {
		layer_object = noone;
		
		var data = getInputDataForce(0);
		content  = data;
		if(!is(content, Krita_File)) return;
		
		var _lname = getInputData(1);
		setDisplayName(_lname, false);
		
		for( var i = 0, n = array_length(data.layerDat); i < n; i++ ) {
			if(data.layerDat[i].name == _lname) 
				layer_object = data.layerDat[i];
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		findLayer();
		
		if(!is(content, Krita_File) || layer_object == noone) return;
		
		var _lname = getInputData(1);
		
		var _meta   = content.metadata;
		var _width  = real(_meta.width);
		var _height = real(_meta.height);
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _width, _height);
		
		var _ldat = layer_object.data;
		var _tileW    = _ldat[0];
		var _tileH    = _ldat[1];
		var _tileData = _ldat[2];
		
		surface_set_shader(_outSurf);
			for( var i = 0, n = array_length(_tileData); i < n; i++ ) {
				var _tile = _tileData[i];
				
				var tx = _tile[0];
				var ty = _tile[1];
				var buffer = _tile[2];
				
				var _surf = surface_create_from_buffer(_tileW, _tileH, buffer);
				if(!is_surface(_surf)) continue;
				
				draw_surface(_surf, tx, ty);
				surface_free(_surf);
			}
			
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(_lname);
	}
}