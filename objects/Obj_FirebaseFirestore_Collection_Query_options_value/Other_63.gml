
if(request == async_load[?"id"])
if(async_load[?"status"])
if(async_load[?"result"] != "")
{
	value = ds_map_find_value(async_load, "result");
	
	if(string_digits(value) == string(value))
	{
		show_debug_message("is real (number)")
		value = real(value)//is real (number)
	}
}
