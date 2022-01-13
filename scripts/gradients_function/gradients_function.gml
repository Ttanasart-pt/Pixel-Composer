enum GRADIENT_INTER {
	smooth,
	none
}

function draw_gradient(_x, _y, _w, _h, _grad, _int = GRADIENT_INTER.smooth) {
	static RES = 48;
	var _step  = _w / RES;
	
	var _ox, _oc;
	
	for(var i = 0; i <= RES; i++) {
		var _nx = _x + _step * i;
		var _nc = gradient_eval(_grad, i / RES, _int);
		
		if(i) {
			switch(_int) {
				case GRADIENT_INTER.smooth :
					draw_rectangle_color(_ox, _y, _nx, _y + _h, _oc, _nc, _nc, _oc, false);
					break;
				case GRADIENT_INTER.none :
					draw_set_color(_nc);
					draw_rectangle(_ox, _y, _nx, _y + _h, false);
					break;
			}
		}
		
		_ox = _nx;
		_oc = _nc;
	}
}

function gradient_eval(_gradient, _time, _int = GRADIENT_INTER.smooth) {
	if(ds_list_size(_gradient) == 0) return c_white;
	if(ds_list_size(_gradient) == 1) return _gradient[| 0].value;
	
	for(var i = 0; i < ds_list_size(_gradient); i++) {
		var _key = _gradient[| i];
		if(_key.time >= _time) {
			if(i == 0) 
				return _gradient[| 0].value;
			else {
				var c0 = _gradient[| i - 1].value;
				if(_int == GRADIENT_INTER.smooth) {
					var rat = (_time - _gradient[| i - 1].time) / (_gradient[| i].time - _gradient[| i - 1].time);
					var c1 = _gradient[| i].value;
					return merge_color(c0, c1, rat);
				} else if(_int == GRADIENT_INTER.none) {
					return c0;
				}
			}
		}
	}
	
	return _gradient[| ds_list_size(_gradient) - 1].value;
}

function gradient_add(_gradient, _addkey, _deleteDup) {
	if(ds_list_size(_gradient) == 0) {
		ds_list_add(_gradient, _addkey);
		return;
	}
		
	for(var i = 0; i < ds_list_size(_gradient); i++) {
		var _key = _gradient[| i];
		if(_key.time == _addkey.time) {
			if(_deleteDup)
				_key.value = _addkey.value;
			return;
		} else if(_key.time > _addkey.time) {
			ds_list_insert(_gradient, i, _addkey);
			return;
		}
	}
		
	ds_list_add(_gradient, _addkey);
}