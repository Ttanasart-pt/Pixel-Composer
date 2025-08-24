#define __tabletstuff_init_gml
/// @description __tabletstuff_init_gml()
gml_pragma("global",
"global.__tabletstuff_ds_map = -1; if (__tabletstuff_is_present()) global.__tabletstuff_init_code = __tabletstuff_init(window_handle()); else global.__tabletstuff_init_code = tabletstuff_error_invalid;"
);
return true;

#define tabletstuff_get_init_error_code
/// @description tabletstuff_get_init_error_code()
return global.__tabletstuff_init_code;

#define tabletstuff_perform_script
/// @description tabletstuff_perform_script(script)
/// @param script
var __tabletstuff_script, __tabletstuff_thing, __tabletstuff_name, __tabletstuff_type;
__tabletstuff_script = argument0;
if (!__tabletstuff_is_present()) {
    return false;
}
while (__tabletstuff_event_begin()) {
    __tabletstuff_thing = ds_map_create();
    
    repeat (__tabletstuff_event_length()) {
        __tabletstuff_type = __tabletstuff_event_get_type();
        // YYC has different evaluation order.
        __tabletstuff_name = __tabletstuff_event_get_name();
        
        if (__tabletstuff_type == 1) {
            ds_map_add(__tabletstuff_thing, __tabletstuff_name, __tabletstuff_event_get_string());
        }
        else {
            ds_map_add(__tabletstuff_thing, __tabletstuff_name, __tabletstuff_event_get_number());
        }
    }
    
    global.__tabletstuff_ds_map = __tabletstuff_thing;
    /*script_execute(__tabletstuff_script, __tabletstuff_thing);*/ __tabletstuff_script(__tabletstuff_thing);
    global.__tabletstuff_ds_map = -1;
    
    ds_map_destroy(__tabletstuff_thing);
    __tabletstuff_thing = -1;
    
    __tabletstuff_event_next();
}
return true;

#define tabletstuff_perform_event
/// @description tabletstuff_perform_event(instance,evtype,evnumb)
/// @param instance
/// @param evtype
/// @param evnumb
var __tabletstuff_instance, __tabletstuff_evtype, __tabletstuff_evnumb, __tabletstuff_thing, __tabletstuff_name, __tabletstuff_type;
__tabletstuff_instance = argument0;
__tabletstuff_evtype = argument1;
__tabletstuff_evnumb = argument2;
if (!__tabletstuff_is_present()) {
    return false;
}
with (__tabletstuff_instance) {
    while (__tabletstuff_event_begin()) {
        __tabletstuff_thing = ds_map_create();
        
        repeat (__tabletstuff_event_length()) {
            __tabletstuff_type = __tabletstuff_event_get_type();
            // YYC has different evaluation order.
            __tabletstuff_name = __tabletstuff_event_get_name();
            
            if (__tabletstuff_type == 1) {
                ds_map_add(__tabletstuff_thing, __tabletstuff_name, __tabletstuff_event_get_string());
            }
            else {
                ds_map_add(__tabletstuff_thing, __tabletstuff_name, __tabletstuff_event_get_number());
            }
        }
        
        global.__tabletstuff_ds_map = __tabletstuff_thing;
        event_perform(__tabletstuff_evtype, __tabletstuff_evnumb);
        global.__tabletstuff_ds_map = -1;
        
        ds_map_destroy(__tabletstuff_thing);
        __tabletstuff_thing = -1;
        
        __tabletstuff_event_next();
    }
}
return true;

#define tabletstuff_get_event_data
/// @description tabletstuff_get_event_data()
return global.__tabletstuff_ds_map;

