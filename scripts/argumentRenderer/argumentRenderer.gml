function argumentRenderer(_typeArray = []) {
	argument_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		argument_renderer.x = _x;
		argument_renderer.y = _y;
		argument_renderer.w = _w;
		
		var spc = _panel.viewMode == INSP_VIEW_MODE.spacious;
		var tx  = _x;
		var ty  = _y + ui(8);
		var hh  = ui(8);
		
		var _fn = spc? f_p2 : f_p3;
		var _th = line_get_height(_fn, 6);
		var  w1 = ui(128), wh = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _jNam = inputs[i + 0];
			var _jTyp = inputs[i + 1];
			var _jVal = inputs[i + 2];
			
			var _wNam = has(_jNam, "__inspWidget")? _jNam.__inspWidget : _jNam.editWidget.clone(); _jNam.__inspWidget = _wNam;
			var _wTyp = has(_jTyp, "__inspWidget")? _jTyp.__inspWidget : _jTyp.editWidget.clone(); _jTyp.__inspWidget = _wTyp;
			
			_wTyp.setFocusHover(_focus, _hover);
			_wNam.setFocusHover(_focus, _hover);
			
			_wTyp.setFont(_fn);
			_wNam.setFont(_fn);
			
			var ts = _jTyp.display_data.data[_jTyp.showValue()];
			var wh = _wNam.draw(tx + w1 + ui(4), ty, _w - w1 - ui(4), _th, _jNam.showValue(), _m, _jNam.display_type);
			_wTyp.draw(tx, ty, w1, wh, ts, _m, argument_renderer.rx, argument_renderer.ry);
			
			var _h = max(wh, _th) + ui(4);
			hh += _h;
			ty += _h;
			
			var _wVal = _jVal[$ "__inspWidget"];
			if(_wVal == undefined || instanceof(_wVal) != instanceof(_jVal.editWidget)) {
				_wVal = _jVal.editWidget.clone();
				_jVal.__inspWidget = _wVal;
			}
			
			if(argument_renderer.showValue && _wVal != undefined) {
				var params = new widgetParam(tx, ty, _w, _th, _jVal.showValue(), {}, _m, argument_renderer.rx, argument_renderer.ry);
				    params.setFont(_fn);
				
				_wVal.setFocusHover(_focus, _hover);
				
				var _h = _wVal.drawParam(params);
				hh += _h;
				ty += _h;
			}
			
			hh += ui(8);
			ty += ui(8);
		}
		
		argument_renderer.h = hh;
		return hh;
	});
	
	argument_renderer.register = function(parent = noone) {
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			inputs[i + 1].editWidget.register(parent);
			inputs[i + 0].editWidget.register(parent);
			if(inputs[i + 2].editWidget != noone)
				inputs[i + 2].editWidget.register(parent);
		}
	}
	
	argument_renderer.showValue = true;
}