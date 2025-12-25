function ase_layer(_name, _data, _type = 0, _node = undefined) constructor {
	name = _name;
	data = _data;
	type = _type;
	node = _node;
	cels = [];
	anim = false;
	tag	 = noone;
	
	static setFrameCel = function(index, cel) { 
		cels[index] = cel; 
		anim = array_length(cels) > 1;
	}
	
	static getCelRaw = function(index = GLOBAL_CURRENT_FRAME, _loop = false) {
		ind = _loop? safe_mod(index, array_length(cels)) : index;
		return array_safe_get_fast(cels, ind);
	}
	
	static getCel = function(index = GLOBAL_CURRENT_FRAME, _loop = false) {
		if(tag == noone) return getCelRaw(index, _loop);
			
		var st  = tag[$ "Frame start"];
		var ed  = tag[$ "Frame end"];
		if(_loop) {
			var ind = st + safe_mod(index, ed - st + 1);
			return array_safe_get_fast(cels, ind);
		}
		
		if(index < st || index > ed) return 0;
		return array_safe_get_fast(cels, index);
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