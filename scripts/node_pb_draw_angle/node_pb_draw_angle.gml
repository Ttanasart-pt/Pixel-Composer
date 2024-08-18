function Node_PB_Draw_Angle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Angle";
	
	newInput(3, nodeValue_Enum_Button("Side", self,  0 , array_create(4, THEME.obj_angle) ));
	
	inputs[4] = nodeValue_Bool("Round", self, false )
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 4, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		var _side = _data[3];
		var _roun = _data[4];
		
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		switch(_side) {
			case 0 : 
				if( _pbox.mirror_h &&  _pbox.mirror_v) _side = 2; 
				if( _pbox.mirror_h && !_pbox.mirror_v) _side = 1; 
				if(!_pbox.mirror_h &&  _pbox.mirror_v) _side = 3; 
				break;				   
			case 1 : 				   
				if( _pbox.mirror_h &&  _pbox.mirror_v) _side = 3; 
				if( _pbox.mirror_h && !_pbox.mirror_v) _side = 0; 
				if(!_pbox.mirror_h &&  _pbox.mirror_v) _side = 2; 
				break;				   
			case 2 : 
				if( _pbox.mirror_h &&  _pbox.mirror_v) _side = 0; 
				if( _pbox.mirror_h && !_pbox.mirror_v) _side = 3; 
				if(!_pbox.mirror_h &&  _pbox.mirror_v) _side = 1; 
				break;				   
			case 3 : 				   
				if( _pbox.mirror_h &&  _pbox.mirror_v) _side = 1; 
				if( _pbox.mirror_h && !_pbox.mirror_v) _side = 2; 
				if(!_pbox.mirror_h &&  _pbox.mirror_v) _side = 0; 
				break;
		}
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_primitive_begin(pr_trianglelist);
			
			var as, ae, rx, ry;
			
			switch(_side) {
				case 0 :
					if(_roun) {
						as = 0;
						ae = -90;
						
						rx = 0;
						ry = 0;
					} else {
						draw_vertex(0, 0);
						draw_vertex(_pbox.w, 0);
						draw_vertex(0, _pbox.h);
					}
					break;
				case 1 :
					if(_roun) {
						as = 180;
						ae = 270;
						
						rx = _pbox.w;
						ry = 0;
					} else {
						draw_vertex(0, 0);
						draw_vertex(_pbox.w, 0);
						draw_vertex(_pbox.w, _pbox.h);
					}
					break;
				case 2 :
					if(_roun) {
						as = 90;
						ae = 180;
						
						rx = _pbox.w;
						ry = _pbox.h;
					} else {
						draw_vertex(_pbox.w, 0);
						draw_vertex(_pbox.w, _pbox.h);
						draw_vertex(0, _pbox.h);
					}
					break;
				case 3 :
					if(_roun) {
						as = 0;
						ae = 90;
						
						rx = 0;
						ry = _pbox.h;
					} else {
						draw_vertex(0, 0);
						draw_vertex(_pbox.w, _pbox.h);
						draw_vertex(0, _pbox.h);	
					}
					break;
			}
			
			if(_roun) {
				var ox, oy, nx, ny;
						
				for( var i = 0; i <= 64; i++ ) {
					var a = lerp(as, ae, i / 64);
					nx = rx + lengthdir_x(_pbox.w, a);
					ny = ry + lengthdir_y(_pbox.h, a);
					
					if(i) {
						draw_vertex(rx, ry);
						draw_vertex(ox, oy);
						draw_vertex(nx, ny);
					}
							
					ox = nx;
					oy = ny;
				}
			}
			draw_primitive_end();
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}