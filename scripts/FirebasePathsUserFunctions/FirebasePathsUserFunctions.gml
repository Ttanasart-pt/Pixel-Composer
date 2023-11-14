
function Firebase_Path_Join()
{
	var path = argument[0]
	for(var a = 1 ; a < argument_count ; a ++)
		path = Firebase_Path_Join_Pair(path,argument[a])
	
	return path
}

function Firebase_Path_Join_Pair(path0,path1)
{
	if(!string_count("http",path0))
		path0 = "/" + path0
	path0 += "/"
	
	path1 = "/" + path1
	path1 += "/"
	
	var path = path0+path1
	
	while(string_count("//",path))
		path = string_replace(path,"//","/")
	
	path = string_replace(path,":/","://")
	
	return path
}

function Firebase_Path_GetName(path,offset)
{
	var list = Firebase_Path_ToList(path)
	var name = list[|ds_list_size(list)-1-offset]
	ds_list_destroy(list)

	return(name)
}

function Firebase_Path_ToList(path)
{
	var list = ds_list_create()
	
	var str = ""
	for(var a = 1 ; a <= string_length(path) ; a ++)
	{
		var char = string_char_at(path,a)
		if(char == "/")
		{
			if(str != "")
				ds_list_add(list,str)
			
			str = ""
		}
		else
			str += char
	}
	
	if(str != "")
		ds_list_add(list,str)
	
	return list
}

function Firebase_Path_Compare(path0,path1) 
{
	var list0 = Firebase_Path_ToList(path0)
	var list1 = Firebase_Path_ToList(path1)
	
	var ok = ds_list_size(list0) == ds_list_size(list1)
	
	if(ok)
	for(var a = 0 ; a < ds_list_size(list0) ; a++)
	if(list0[|a] != list1[|a])
	{
		ok = false
		break
	}
	
	ds_list_destroy(list0)
	ds_list_destroy(list1)
	
	return ok
}

function Firebase_Path_Back(path,count)
{
	var str = ""
	var list = Firebase_Path_ToList(path)
	for(var a = 0 ; a < ds_list_size(list) - count ; a++)
		str += list[|a] + "/"
	
	ds_list_destroy(list)
	
	return str
}

