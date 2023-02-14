// initialization
// in old versions of GMS, you'd have this ran separately instead.
// in GMS2 it'd need to be @"..." instead of just "..."
gml_pragma("global", @"
	global.g_json_minify_fb = buffer_create(1024, buffer_fast, 1);
	global.g_json_minify_rb = buffer_create(1024, buffer_grow, 1);
");

function json_minify(src) {
	var rb = global.g_json_minify_rb;		// copy text to string buffer:
	buffer_seek(rb, buffer_seek_start, 0);
	buffer_write(rb, buffer_string, src);
	var size = buffer_tell(rb) - 1;
	var fb = global.g_json_minify_fb;		// then copy it to "fast" input buffer for peeking:
	if (buffer_get_size(fb) < size) buffer_resize(fb, size);
	buffer_copy(rb, 0, size, fb, 0);
	
	var rbpos = 0;			// writing position in output buffer
	var start = 0;			// start offset in input buffer
	var pos = 0;			// reading position in input buffer
	var next;				// number of bytes to be copied
	while (pos < size) {
	    var c = buffer_peek(fb, pos++, buffer_u8);
	    switch (c) {
	        case 9: case 10: case 13: case 32: // `\t\n\r `	
	            next = pos - 1 - start;							// flush:
	            buffer_copy(fb, start, next, rb, rbpos);
	            rbpos += next;									
	            while (pos < size) {							// skip over trailing whitespace:
	                switch (buffer_peek(fb, pos, buffer_u8)) {
	                    case 9: case 10: case 13: case 32: pos += 1; continue;
	                    // default -> break
	                } break;
	            }
	            start = pos;
	            break;
	        case 34: // `"`
	            while (pos < size) {
	                switch (buffer_peek(fb, pos++, buffer_u8)) {
	                    case 92: pos++; continue; // `\"`
	                    case 34: break; // `"` -> break
	                    default: continue; // else
	                } break;
	            }
	            break;
	        default:
	            if (c >= ord("0") && c <= ord("9")) {					// `0`..`9`
	                var pre = true;										// whether reading pre-dot or not
	                var till = pos - 1;									// index at which meaningful part of the number ends
	                while (pos < size) {
	                    c = buffer_peek(fb, pos, buffer_u8);
	                    if (c == ord(".")) {
	                        pre = false;								// whether reading pre-dot or not
	                        pos += 1;									// index at which meaningful part of the number ends
	                    } else if (c >= ord("0") && c <= ord("9")) {	// write all pre-dot, and till the last non-zero after dot:
	                        if (pre || c != ord("0")) till = pos;
	                        pos += 1;
	                    } else break;
	                }
	                if (till < pos) {									// flush if number can be shortened
	                    next = till + 1 - start;
	                    buffer_copy(fb, start, next, rb, rbpos);
	                    rbpos += next;
	                    start = pos;
	                }
	            }
	    } // switch (c)
	} // while (pos < size)
	
	if (start == 0) return src;						// source string was unchanged
	if (start < pos) {								// flush if there's more data left
	    next = pos - start;
	    buffer_copy(fb, start, next, rb, rbpos);
	    rbpos += next;
	}
	buffer_poke(rb, rbpos, buffer_u8, 0);			// terminating byte
	buffer_seek(rb, buffer_seek_start, 0);
	return buffer_read(rb, buffer_string);
}