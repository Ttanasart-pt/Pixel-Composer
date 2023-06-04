/// @description 
var port = async_load[? "port"];

if(!ds_map_exists(PORT_MAP, port)) exit;
var nodeTarget = PORT_MAP[? port];
for( var i = 0; i < array_length(nodeTarget); i++ )
	nodeTarget[i].asyncPackets(async_load);