function SVG() constructor {
	width  = 1;
	height = 1;
	fill   = c_black;
	bbox   = [ 0, 0, 0, 0 ];
	
	contents = [];
}

function SVG_path() constructor {
	anchors = [];
	
	static setDef = function(def) {
		var _mode = "";
		var _len  = string_length(def);
		var _ind  = 1;
		var _val  = "";
		var _par  = [];
		
		var _oa = ord("a"), _oz = ord("z");
		var _oA = ord("A"), _oZ = ord("Z");
		var _o0 = ord("0"), _o9 = ord("9");
		
		var _om = ord("-"); 
		var _od = ord(".");
		var _os = ord(" ");
		
		var _tx = 0;
		var _ty = 0;
		
		repeat(_len) {
			var _chr  = string_char_at(def, _ind);
			var _och  = ord(_chr);
			var _eval = 0;
			
			if((_och >= _oa && _och <= _oz) || (_och >= _oA && _och <= _oZ))
				_eval = 2;
			else if(_och == _os)
				_eval = 1;
			else if((_och >= _o0 && _och >= _o9) || _och == _om || _och == _od)
				_val += _chr;
			
			if(_eval == 1)
				array_push(_par, real(_val));
			
			else if(_eval == 2) {
				array_push(_par, real(_val));
				_val = "";
				
				switch(_mode) {
					case "M" : //Move to absolute
						var _nx = array_safe_get(_par, 0);
						var _ny = array_safe_get(_par, 1);
						
						_tx = _nx;
						_ty = _ny;
						break;
						
					case "m" : //Move to relative
						var _nx = array_safe_get(_par, 0);
						var _ny = array_safe_get(_par, 1);
						
						_tx += _nx;
						_ty += _ny;
						break;
				}
				
				_par = [];
				_mode = _chr;
			} 
			
			_ind++;
		}
	}
}