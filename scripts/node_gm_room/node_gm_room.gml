function Node_GMRoom(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "GMRoom";
	color  = COLORS.node_blend_input;
    gmRoom = noone;
    
    newInput( 0, nodeValue_Vec2("Room size", self, [ 16, 16 ]));
    
    newInput( 1, nodeValue_Bool("Persistance", self, false));
    
    attributes.exposed_layer = [];
    
    layer_selecting = noone;
    
	layers_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(gmRoom == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(28);
		}
		
		var _amo = array_length(gmRoom.layers);
		var hh   = ui(28);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(gmRoom.layers); i < n; i++ ) {
			var _bx    = _x + ui(24);
			var _yy    = _y + ui(8) + i * hh;
			var _layer = gmRoom.layers[i];
			
			var cc = layer_selecting == _layer? COLORS._main_text_accent : COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					layer_selecting = layer_selecting == _layer? noone : _layer;
			}
			
			draw_sprite_ui_uniform(s_gmlayer, _layer.index, _bx, _yy + hh / 2, 1, cc);
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_bx + ui(20), _yy + hh / 2, _layer.name);
		}
		
		return _h;
	}); 
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(layer_selecting == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			return ui(28);
		}
		
		var _h = ui(64);
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);	
		
		return _h;
	}); 
	
    input_display_list = [ 
    	["Room settings", false], 0, 1, 
    	["Layers",        false], 
    	layers_renderer,
    	new Inspector_Spacer(ui(4)), 
    	layer_renderer,
	];
    
    static step = function() {
    	
    }
    
    static update = function() {
    	
    }
    
    ////Serialize
    
	static attributeSerialize = function() {
		var _attr = {
			gm_key: gmRoom == noone? noone : gmRoom.key,
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		if(struct_has(attr, "gm_key")) {
			var _key = attr.gm_key;
			var _gm  = project.bind_gamemaker;
			
			if(_gm != noone) gmRoom = struct_try_get(_gm.resourcesMap, _ey, noone);
		}
	}
}