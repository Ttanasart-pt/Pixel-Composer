function tiler_rule() constructor {
	name = "rule";
    open = false;
    
    static deserialize = function(_struct) {
        name = struct_try_get(_struct, "name", name);
        
        return self;
    }
}