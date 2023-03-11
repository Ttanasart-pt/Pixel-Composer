function luaArgumentRenderer() {
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var tx = _x;
		var ty = _y + ui(8);
		var hh = ui(8);
		var _th = TEXTBOX_HEIGHT + ui(4);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _jType = inputs[| i + 1];
			var _typ   = _jType.getValue();
			var _h = 0;
			
			_jType.editWidget.setActiveFocus(_focus, _hover);
			_jType.editWidget.draw(tx, ty, ui(128), _th, _jType.display_data[_jType.showValue()], _m, argument_renderer.rx, argument_renderer.ry);
			
			var _jName = inputs[| i + 0];
			_jName.editWidget.setActiveFocus(_focus, _hover);
			_jName.editWidget.draw(tx + ui(128 + 8), ty, _w - ui(128 + 8), _th, _jName.showValue(), _m, _jName.display_type);
			
			_h += _th + ui(6);
			
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(tx + ui(8), ty + _th + ui(6) + ui(6), "Value");
			
			var _jValue = inputs[| i + 2];
			if(_jValue.editWidget != noone) {
				_jValue.editWidget.setActiveFocus(_focus, _hover);
				if(_typ == 2) {
					_jValue.editWidget.draw(tx + ui(64), ty + _th + ui(6), _w - ui(64), ui(96), _jValue.showValue(), _m, argument_renderer.rx, argument_renderer.ry);
					_h += ui(96 + 8);
				} else {
					_jValue.editWidget.draw(tx + ui(64), ty + _th + ui(6), _w - ui(64), TEXTBOX_HEIGHT, _jValue.showValue(), _m);
					_h += TEXTBOX_HEIGHT + ui(8);
				}
			}
			
			hh += _h;
			ty += _h;
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			inputs[| i + 1].editWidget.register(parent);
			inputs[| i + 0].editWidget.register(parent);
			if(inputs[| i + 2].editWidget != noone)
				inputs[| i + 2].editWidget.register(parent);
		}
	}
}