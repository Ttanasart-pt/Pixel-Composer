function ase_layer(_name, _data, _type = 0, _node = undefined) constructor {
	index = 0;
	
	name = _name;
	data = _data;
	type = _type;
	node = _node;
	
	alpha = (data[$ "Opacity"] ?? 255) / 255;
	cels  = [];
	anim  = false;
	tag	  = noone;
	
	contents = [];
	expand   = true;
	
	static setFrameCel = function(i, cel) { 
		cels[i] = cel; 
		anim = array_length(cels) > 1;
	}
	
	static getCelRaw = function(i = GLOBAL_CURRENT_FRAME, _loop = false) {
		ind = _loop? safe_mod(i, array_length(cels)) : i;
		return array_safe_get_fast(cels, ind);
	}
	
	static getCel = function(i = GLOBAL_CURRENT_FRAME, _loop = false) {
		if(tag == noone) return getCelRaw(i, _loop);
			
		var st  = tag[$ "Frame start"];
		var ed  = tag[$ "Frame end"];
		if(_loop) {
			var ind = st + safe_mod(i, ed - st + 1);
			return array_safe_get_fast(cels, ind);
		}
		
		if(i < st || i > ed) return 0;
		return array_safe_get_fast(cels, i);
	}
	
	static getTileSet = function() {
		var _ind = data[$ "Tileset index"];
		return array_safe_get_fast(node.tilesets, _ind);
	}
	
	function toString() {
		var st = json_stringify({
			type, 
			cels : array_map(cels, function(cel) /*=>*/ {return cel.toStr()}),
		});
		
		return $"[ase layer] {st}";
	}
}