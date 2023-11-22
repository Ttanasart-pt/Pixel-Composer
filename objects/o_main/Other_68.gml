/// @description 
var _id = async_load[? "id"];

if(!ds_map_exists(PORT_MAP, _id)) exit;
var nodeTarget = PORT_MAP[? _id];
nodeTarget.asyncPackets(async_load);