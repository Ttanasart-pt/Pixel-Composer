#define file_dropper_init
/// file_dropper_init()->bool
var _buf = file_dropper_prepare_buffer(8);
buffer_write(_buf, buffer_u64, int64(window_handle()));
return file_dropper_init_raw(buffer_get_address(_buf), ptr(8));

#define file_dropper_set_allow
/// file_dropper_set_allow(allow:bool)
var _buf = file_dropper_prepare_buffer(1);
buffer_write(_buf, buffer_bool, argument0);
file_dropper_set_allow_raw(buffer_get_address(_buf), ptr(1));

#define file_dropper_set_effect
/// file_dropper_set_effect(effect:int)->number
var _buf = file_dropper_prepare_buffer(4);
buffer_write(_buf, buffer_s32, argument0);
return file_dropper_set_effect_raw(buffer_get_address(_buf), ptr(4));

#define file_dropper_set_default_allow
/// file_dropper_set_default_allow(allow:bool)
var _buf = file_dropper_prepare_buffer(1);
buffer_write(_buf, buffer_bool, argument0);
file_dropper_set_default_allow_raw(buffer_get_address(_buf), ptr(1));

#define file_dropper_set_default_effect
/// file_dropper_set_default_effect(effect:int)->number
var _buf = file_dropper_prepare_buffer(4);
buffer_write(_buf, buffer_s32, argument0);
return file_dropper_set_default_effect_raw(buffer_get_address(_buf), ptr(4));

