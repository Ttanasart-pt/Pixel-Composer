function Node_PB_Draw_Blob(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Blob";
	
	inputs[| 3] = nodeValue("Top", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
	
	inputs[| 4] = nodeValue("Bottom", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 4, 
	];
	
	static drawOverlayPB = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbox = inputs[| 0].getValue();
		if(_pbox == noone) return;
		
		var x0 = _pbox.x + _pbox.w / 2;
		var y0 = _pbox.y;
		
		x0 = _x + x0 * _s;
		y0 = _y + y0 * _s;
		
		//inputs[| 2].drawOverlay(active, x0, y0, _s, _mx, _my, _snx, _sny);
		
		var x0 = _pbox.x + _pbox.w / 2;
		var y0 = _pbox.y + _pbox.h;
		
		x0 = _x + x0 * _s;
		y0 = _y + y0 * _s;
		
		//inputs[| 3].drawOverlay(active, x0, y0, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		
		var _btop = _data[3];
		var _bbot = _data[4];
		
		_btop *= _pbox.w / 2;
		_bbot *= _pbox.w / 2;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_primitive_begin(pr_trianglelist);
			
			var xc = _pbox.w / 2;
			
			var _samp = 64;
			var _ox, _oy, _nx, _ny;
			for( var i = 0; i <= _samp; i++ ) {
				var  t = i / _samp;
				var _t = 1 - t;
				
				_nx = 3 * _btop * t * _t * _t + 3 * _bbot * t * t * _t;
				_ny = 3 * t * t - 2 * t * t * t;
				if(_pbox.mirror_v) 
					_ny = 1 - _ny;
				_ny = _ny * _pbox.h;
				
				if(i) {
					draw_vertex(xc, 0);
					draw_vertex(xc + _ox, _oy);
					draw_vertex(xc + _nx, _ny);
					
					draw_vertex(xc, 0);
					draw_vertex(xc - _ox, _oy);
					draw_vertex(xc - _nx, _ny);
				}
				
				_ox = _nx;
				_oy = _ny;
			}
			
			draw_primitive_end();
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();

		PB_DRAW_CREATE_MASK
				
		return _nbox;
	}
}