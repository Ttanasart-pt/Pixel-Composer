function audioObject(sample = 8, channel = 2) constructor {
	self.sound     = [];
	self.soundF    = [];
	self.sample    = sample;
	self.channels  = channel;
	self.bit_depth = 32;
	self.duration  = 0;
	self.packet    = 0;
	self.mono      = false;
	
	preview_surface = noone;
	
	static checkPreview = function(w, h, force = false) {	
		if(!force && is_surface(preview_surface)) return preview_surface;
		
		print($"--- Creating preview surface [{w}, {h}] ---");
		
		var ch = channels;
		if(ch == 0) return;
		
		if(array_length(sound) < 1) return;
		
		var len = array_length(sound[0]);
		if(len == 0) return;
		
		var spc = min(w, len);
		var stp = len / spc;
		
		preview_surface = surface_verify(preview_surface, w, h);
		surface_set_target(preview_surface);
			draw_clear_alpha(c_white, 0);
			draw_set_color(c_white);
			
			var ox, oy, nx, ny;
			
			for( var i = 0; i < len; i += stp ) {
				nx = i / len * 320;
				ny = h / 2 + sound[0][i] * h;
				
				if(i) draw_line_width(ox, oy, nx, ny, 4);
				
				ox = nx;
				oy = ny;
			}
		surface_reset_target();
		
		return preview_surface;
	}
	
	static getChannel = function() { return mono? 1 : channels; }
	static getData    = function() { return mono? soundF : sound; }
	
	static toString = function() { return $"\{duration:{duration}, channels:{channels}\}"; }
}