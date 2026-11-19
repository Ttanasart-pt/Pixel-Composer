function argumentRenderer(_typeArray = []) {
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var rx = argument_renderer.rx;
		var ry = argument_renderer.ry;
		
		var spc = _panel.viewMode == INSP_VIEW_MODE.spacious;
		var tx  = _x;
		var ty  = _y + ui(8);
		var hh  = ui(8);
		
		var _fn = spc? f_p2 : f_p3;
		var _th = line_get_height(_fn, 6);
		var  w1 = ui(128), wh = 0;
		var _tv = __txt("Value");
		
		var bs = _th;
		var bc = [COLORS._main_icon, COLORS._main_value_negative];
		
		var toDel = undefined;
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _jNam = inputs[i + 0];
			var _jTyp = inputs[i + 1];
			var _jVal = inputs[i + 2];
			
			var _vNam = _jNam.showValue();
			
			var _wNam = has(_jNam, "__inspWidget")? _jNam.__inspWidget : _jNam.getEditWidget().clone(); _jNam.__inspWidget = _wNam;
			var _wTyp = has(_jTyp, "__inspWidget")? _jTyp.__inspWidget : _jTyp.getEditWidget().clone(); _jTyp.__inspWidget = _wTyp;
			
			_wNam.boxColor = _vNam == ""? COLORS._main_value_negative : c_white;
			
			_wTyp.setFocusHover(_focus, _hover);
			_wNam.setFocusHover(_focus, _hover);
			
			_wTyp.setFont(_fn);
			_wNam.setFont(_fn);
			
			var ts  = _jTyp.display_data.data[_jTyp.showValue()];
			var wh0 = _wNam.draw(tx + w1 + ui(4), ty, _w - w1 - ui(4 + 4) - bs, _th, _vNam, _m, _jNam.display_type);
			var wh1 = _wTyp.draw(tx, ty, w1, wh0, ts, _m, argument_renderer.rx, argument_renderer.ry);
			
			////////////////////////////
			
			var bb = THEME.button_hide_fill;
			var bx = _x + _w - bs;
			var by = ty;
			
			if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, bc, 1, ui(6)) == 2)
				toDel = (i - input_fix_len) / data_length;
			 
			////////////////////////////
			
			var wh = max(wh0, wh1);
			var _h = max(wh, _th) + ui(4);
			hh += _h;
			ty += _h;
			
			var _wVal = _jVal[$ "__inspWidget"];
			if(_wVal == undefined || instanceof(_wVal) != instanceof(_jVal.getEditWidget())) {
				_wVal = _jVal.getEditWidget().clone();
				_jVal.__inspWidget = _wVal;
			}
			
			if(argument_renderer.showValue && _wVal != undefined) {
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
				draw_text_add(_x + ui(8), ty + _th / 2, _tv);
				var _tw = string_width(_tv) + ui(24);
				
				var params = new widgetParam(tx + _tw, ty, _w - _tw, _th, _jVal.showValue(), undefined, _m, rx, ry);
				    params.setFont(_fn);
				
				_wVal.setFocusHover(_focus, _hover);
				
				var _h = _wVal.drawParam(params);
				hh += _h;
				ty += _h;
			}
			
			hh += ui(8);
			ty += ui(8);
		}
		
		if(toDel != undefined) deleteArgument(toDel);
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var edt0 = inputs[i + 0].getEditWidget();
			var edt1 = inputs[i + 1].getEditWidget();
			var edt2 = inputs[i + 2].getEditWidget();
			
			edt1.register(parent);
			edt0.register(parent);
			if(edt2 != noone) edt2.register(parent);
		}
	}
	
	argument_renderer.showValue = true;
	
	function deleteArgument(ind) {
		var _ind = input_fix_len + ind * data_length;
		array_delete(inputs, _ind, data_length);
		
		refreshDynamicInput();
		refreshNodeDisplay();
		triggerRender();
	}
	
	b_argAdd = button(function() /*=>*/ {return createNewInput()}).setIcon(THEME.add_16, 0, COLORS._main_value_positive).setTooltip(__txt("Add argument"));
	
}