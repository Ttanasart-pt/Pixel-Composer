function ase_cel(_layer, _data, _file) constructor {
	data = _data;
	file = _file;
	layerTarget = _layer;
	
	static checkSurface = function() {
		var width  = data[? "Width"];
		var height = data[? "Height"];
		data[? "Surface"] = surface_verify(data[? "Surface"], width, height);
		
		var color  = file[? "Color depth"];
		if(color == 32) {//rgba 
			buffer_set_surface(data[? "Buffer"], data[? "Surface"], 0);
			return;
		}
		
		var size = width * height;
		var buff = buffer_create(size * 4, buffer_fixed, 1);
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_seek(data[? "Buffer"], buffer_seek_start, 0);
		
		if(color == 16) { //grey
			repeat(size) {
				var bin = buffer_read(data[? "Buffer"], buffer_u16);
				buffer_write(buff, buffer_u8, bin);
				buffer_write(buff, buffer_u8, bin);
				buffer_write(buff, buffer_u8, bin);
				buffer_write(buff, buffer_u8, bin >> 8);
			}
		} else if(color == 8) { //index
			var palet  = file[? "Palette"];
			
			repeat(size) {
				var bin = buffer_read(data[? "Buffer"], buffer_u8);
				var cc  = array_safe_get(palet, bin);
				for( var i = 0; i < 4; i++ )
					buffer_write(buff, buffer_u8, cc[i]);
			}
		}
		
		buffer_set_surface(buff, data[? "Surface"], 0);
	}
	
	static getSurface = function() {
		var type = data[? "Cel type"];
		
		if(type == 0) {
			
		} else if(type == 1) {
			var frTarget = data[? "Frame position"];
			var cel = layerTarget.getCel(frTarget);
			if(!cel) return noone;
			return cel.getSurface();
		} else if(type == 2) {
			checkSurface();
			return data[? "Surface"];
		}
		
		return noone;
	}
}

function ase_layer(name) constructor {
	self.name = name;
	cels	= [];
	tag		= noone;
	
	static setFrameCel = function(index, cel) {
		cels[index] = cel;
	}
	
	static getCel = function(index = PROJECT.animator.current_frame) {
		var ind;
		
		if(tag != noone) {
			var st = tag[? "Frame start"];
			var ed = tag[? "Frame end"];
			ind = st + safe_mod(index, ed - st + 1);
		} else 
			ind = safe_mod(index, array_length(cels));
		
		return array_safe_get(cels, ind);
	}
}