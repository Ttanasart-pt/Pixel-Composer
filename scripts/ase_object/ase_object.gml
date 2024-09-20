function ase_cel(_layer, _data, _file) constructor {
	data = _data;
	file = _file;
	layerTarget = _layer;
	
	static checkSurface = function() {
		var width  = data[$ "Width"];
		var height = data[$ "Height"];
		data[$ "Surface"] = surface_verify(data[$ "Surface"], width, height);
		
		var color  = file[$ "Color depth"];
		if(color == 32) {//rgba 
			buffer_set_surface(data[$ "Buffer"], data[$ "Surface"], 0);
			return;
		}
		
		var size = width * height;
		var buff = buffer_create(size * 4, buffer_fixed, 1);
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_seek(data[$ "Buffer"], buffer_seek_start, 0);
		
		if(color == 16) { //grey
			repeat(size) {
				var _bin = buffer_read(data[$ "Buffer"], buffer_u16);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin >> 8);
			}
			
		} else if(color == 8) { //index
			var palet  = file[$ "Palette"];
			
			repeat(size) {
				var _bin = buffer_read(data[$ "Buffer"], buffer_u8);
				var cc   = array_safe_get_fast(palet, _bin);
				
				for( var i = 0; i < 4; i++ )
					buffer_write(buff, buffer_u8, cc[i]);
			}
		}
		
		buffer_set_surface(buff, data[$ "Surface"], 0);
	}
	
	static getSurface = function() {
		var type = data[$ "Cel type"];
		
		if(type == 0) {
			
		} else if(type == 1) {
			var frTarget = data[$ "Frame position"];
			// print($"Get frame {frTarget}")
			
			var cel = layerTarget.getCelRaw(frTarget);
			if(!cel) return noone;
			return cel.getSurface();
			
		} else if(type == 2) {
			checkSurface();
			return data[$ "Surface"];
		}
		
		return noone;
	}
	
	function toStr() {
		return {
			type: data[$ "Cel type"], 
			link: data[$ "Frame position"]
		};
	}
	
	function toString() {
		var st = json_stringify(toStr());
		
		return $"[ase cel] {st}";
	}
}

function ase_layer(name, type = 0) constructor {
	self.name = name;
	self.type = type;
	cels	= [];
	tag		= noone;
	
	static setFrameCel = function(index, cel) { cels[index] = cel; }
	
	static getCelRaw = function(index = CURRENT_FRAME) {
		ind = safe_mod(index, array_length(cels));
		return array_safe_get_fast(cels, ind);
	}
	
	static getCel = function(index = CURRENT_FRAME) {
		if(tag == noone) return getCelRaw(index);
			
		var st  = tag[$ "Frame start"];
		var ed  = tag[$ "Frame end"];
		var ind = st + safe_mod(index, ed - st + 1);
		
		return array_safe_get_fast(cels, ind);
	}
	
	function toString() {
		var st = json_stringify({
			type, 
			cels : array_map(cels, function(cel) /*=>*/ {return cel.toStr()}),
		});
		
		return $"[ase layer] {st}";
	}
}