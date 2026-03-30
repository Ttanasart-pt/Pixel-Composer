function instance_create(_x, _y, _object, _param = {}) { return instance_create_depth(_x, _y, 0, _object, _param); }

function instance_toggle(ins) { if(!instance_exists(ins)) instance_create_depth(0, 0, 0, ins); }