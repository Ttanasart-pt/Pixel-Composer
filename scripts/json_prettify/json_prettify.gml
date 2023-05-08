/// json_beautify(json_string)
// initialization
// in old versions of GMS, you'd have this ran separately instead.
// in GMS2 it'd need to be @"..." instead of just "..."
gml_pragma("global", @"
global.g_json_beautify_fb = buffer_create(1024, buffer_fast, 1);
global.g_json_beautify_rb = buffer_create(1024, buffer_grow, 1);
");

function buffer_write_slice(buffer, data_buffer, data_start, data_end) {
	var next  = data_end - data_start;
	if (next <= 0) exit;
	var size = buffer_get_size(buffer);
	var pos  = buffer_tell(buffer);
	var need = pos + next;
	if (size < need) {
	    do size *= 2 until (size >= need);
	    buffer_resize(buffer, size);
	}
	buffer_copy(data_buffer, data_start, next, buffer, pos);
	buffer_seek(buffer, buffer_seek_relative, next);
}
	
function json_beautify(src) {
	// copy text to string buffer:
	var rb = global.g_json_beautify_rb;
	buffer_seek(rb, buffer_seek_start, 0);
	buffer_write(rb, buffer_string, src);
	var size = buffer_tell(rb) - 1;
	var rbsize = buffer_get_size(rb);
	// then copy it to "fast" input buffer for peeking:
	var fb = global.g_json_beautify_fb;
	if (buffer_get_size(fb) < size) buffer_resize(fb, size);
	buffer_copy(rb, 0, size, fb, 0);
	buffer_seek(rb, buffer_seek_start, 0);
	//
	var rbpos = 0; // writing position in output buffer
	var start = 0; // start offset in input buffer
	var pos = 0; // reading position in input buffer
	var next; // number of bytes to be copied
	var need;
	var nest = 0;
	while (pos < size) {
	    var c = buffer_peek(fb, pos++, buffer_u8);
	    switch (c) {
	        case 9: case 10: case 13: case 32: // `\t\n\r `
	            buffer_write_slice(rb, fb, start, pos - 1);
	            // skip over trailing whitespace:
	            while (pos < size) {
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
	        case ord("["): case ord("{"):
	            buffer_write_slice(rb, fb, start, pos);
	            // skip over trailing whitespace:
	            while (pos < size) {
	                switch (buffer_peek(fb, pos, buffer_u8)) {
	                    case 9: case 10: case 13: case 32: pos += 1; continue;
	                    // default -> break
	                } break;
	            }
	            // indent or contract `[]`/`{}`
	            c = buffer_peek(fb, pos, buffer_u8);
	            switch (c) {
	                case ord("]"): case ord("}"): // `[]` or `{}`
	                    buffer_write(rb, buffer_u8, c);
	                    pos += 1;
	                    break;
	                default: // `[\r\n\t
	                    buffer_write(rb, buffer_u16, 2573); // `\r\n`
	                    repeat (++nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            }
	            start = pos;
	            break;
	        case ord("]"): case ord("}"):
	            buffer_write_slice(rb, fb, start, pos - 1);
	            buffer_write(rb, buffer_u16, 2573); // `\r\n`
	            repeat (--nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            buffer_write(rb, buffer_u8, c);
	            start = pos;
	            break;
	        case ord(","):
	            buffer_write_slice(rb, fb, start, pos);
	            buffer_write(rb, buffer_u16, 2573); // `\r\n`
	            repeat (nest) buffer_write(rb, buffer_u8, 9); // `\t`
	            start = pos;
	            break;
	        case ord(":"):
	            if (buffer_peek(fb, pos, buffer_u8) != ord(" ")) {
	                buffer_write_slice(rb, fb, start, pos);
	                buffer_write(rb, buffer_u8, ord(" "));
	                start = pos;
	            } else pos += 1;
	            break;
	        default:
	            if (c >= ord("0") && c <= ord("9")) { // `0`..`9`
	                var pre = true; // whether reading pre-dot or not
	                var till = pos - 1; // index at which meaningful part of the number ends
	                while (pos < size) {
	                    c = buffer_peek(fb, pos, buffer_u8);
	                    if (c == ord(".")) {
	                        pre = false; // whether reading pre-dot or not
	                        pos += 1; // index at which meaningful part of the number ends
	                    } else if (c >= ord("0") && c <= ord("9")) {
	                        // write all pre-dot, and till the last non-zero after dot:
	                        if (pre || c != ord("0")) till = pos;
	                        pos += 1;
	                    } else break;
	                }
	                if (till < pos) { // flush if number can be shortened
	                    buffer_write_slice(rb, fb, start, till + 1);
	                    start = pos;
	                }
	            }
	    }
	}
	if (start == 0) return src; // source string was unchanged
	buffer_write_slice(rb, fb, start, pos);
	buffer_write(rb, buffer_u8, 0); // terminating byte
	buffer_seek(rb, buffer_seek_start, 0);
	return buffer_read(rb, buffer_string);
}