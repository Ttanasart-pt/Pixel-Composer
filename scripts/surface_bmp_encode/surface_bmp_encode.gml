function surface_bmp_encode(surface, path, param = {}) {
	if(!surface_exists(surface)) return;
	
    var sw = surface_get_width(surface);
    var sh = surface_get_height(surface);
    var fr = surface_get_format(surface);
    var bs;
    
    if(fr == surface_rgba8unorm)
    	bs = buffer_from_surface(surface, false);
    else {
    	var s = surface_create(sw, sh, surface_rgba8unorm);
    	
	    switch(fr) {
	    	case surface_rgba4unorm  :
			case surface_rgba8unorm	 :
			case surface_rgba16float :
			case surface_rgba32float :
		    	surface_set_shader(s, sh_draw_normal);
					draw_surface_safe(surface);
				surface_reset_shader();
				break;
				
			case surface_r8unorm	 : 
			case surface_r16float	 : 
			case surface_r32float	 : 
				surface_set_shader(s, sh_draw_single_channel);
					draw_surface_safe(surface);
				surface_reset_shader();
				break;
	    }
	    
	    bs = buffer_from_surface(s, false);
	    surface_free(s);
    }
    
    var b  = buffer_create(1, buffer_grow, 1);
    buffer_to_start(b);
    
    // File Header
    buffer_write(b, buffer_text, "BM"); // 2
    buffer_write(b, buffer_u32,  0);    // 4 size:                          override after [2]
    buffer_write(b, buffer_u16,  0);    // 2
    buffer_write(b, buffer_u16,  0);    // 2
    buffer_write(b, buffer_u32, 54);    // 4 image data offset
    
    // Bitmap Header
    buffer_write(b, buffer_u32,  40);    // 4 header size in bytes
    buffer_write(b, buffer_u32,  sw);    // 4 width
    buffer_write(b, buffer_s32, -sh);    // 4 height (negative for top down)
    buffer_write(b, buffer_u16,   1);    // 2 color plane
    buffer_write(b, buffer_u16,  24);    // 2 bit per pixel
    buffer_write(b, buffer_u32,   0);    // 4 compression
    buffer_write(b, buffer_u32,   0);    // 4 bitmap size:                   override after [34]
    buffer_write(b, buffer_u32,  18);    // 4 x resolution (px/meter)?
    buffer_write(b, buffer_u32,  18);    // 4 y resolution (px/meter)?
    buffer_write(b, buffer_u32,   0);    // 4 number of colors
    buffer_write(b, buffer_u32,   0);    // 4 minimum colors
    
    // Palette (only for <= 8 bit bmp)
    
    
    // Bitmap Data
    buffer_to_start(bs);
    var bitmap_size = 0;
    
    for( var i = 0; i < sh; i++ ) {
    	var bitmap_row = 0;
    	
    	for( var j = 0; j < sw; j++ ) {
    		var cr = buffer_read(bs, buffer_u8);
    		var cg = buffer_read(bs, buffer_u8);
    		var cb = buffer_read(bs, buffer_u8);
    		var ca = buffer_read(bs, buffer_u8);
    		
    		buffer_write(b, buffer_u8, cb * ca / 255);
    		buffer_write(b, buffer_u8, cg * ca / 255);
    		buffer_write(b, buffer_u8, cr * ca / 255);
    		bitmap_row += 3;
    	}
    	
    	bitmap_size += bitmap_row;
    	
        var pad = (4 - (bitmap_size % 4)) % 4;
		repeat(pad) { buffer_write(b, buffer_u8, 0); bitmap_size++; }
    }
    
    var total_size = buffer_tell(b);
    buffer_write_at(b,  2, buffer_u32, total_size);
    buffer_write_at(b, 34, buffer_u32, bitmap_size);
    
    buffer_save(b, path);
    buffer_delete(b);
    return 1;
}