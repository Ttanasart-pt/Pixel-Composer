
event_inherited()

if(request == async_load[?"id"])
if(async_load[?"status"])
if(async_load[?"result"] != "")
{
	path_request = get_string_async("Path",path)
}


if(path_request == async_load[?"id"])
if(async_load[?"status"])
if(async_load[?"result"] != "")
{
	path = ds_map_find_value(async_load, "result");
}
