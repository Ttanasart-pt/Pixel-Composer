#define file_dropper_init
/// file_dropper_init()->bool
var _buf = file_dropper_prepare_buffer(8);
buffer_write(_buf, buffer_u64, int64(window_handle()));
return file_dropper_init_raw(buffer_get_address(_buf), 8);

