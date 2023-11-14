
if(async_load[?"status"] != 1)// 1:downloading, 0:success ,<0:Error
if(async_load[?"id"] == request)
{   
	alarm[0] = refreshCall
	
    if(async_load[?"http_status"] == 200 and async_load[?"status"] == 0)
    {
		var json_result = FirebaseREST_Firestore_jsonDecode(async_load[?"result"])
		
        if(firstTime or !json_compare(cache,json_result))
        {
            firstTime = false
            cache = json_result
			cache_status_code = async_load[?"http_status"]
                
			FirebaseREST_HTTP_Success_Firestore()
        }
    }
	else
	{
		if(async_load[?"http_status"] == 401 or async_load[?"http_status"] == 403 or async_load[?"http_status"] == 404)//if i not have permissions or not exists, destroy me
		{
			FirebaseREST_HTTP_Failed_Firestore()
			instance_destroy()
			exit
		}
		
		var json_result = FirebaseREST_Firestore_jsonDecode(async_load[?"result"])
		if(firstTime or !json_compare(cache,json_result) or cache_status_code != async_load[?"http_status"])
		{
		    alarm[0] = errorResetAlarm
		    countError++
		    if(countError >= errorCountLimit)
			{
				cache = json_result//async_load[?"result"]
				cache_status_code = async_load[?"http_status"]
				firstTime = false
				countError = 0
		        FirebaseREST_HTTP_Failed_Firestore()
		    }
		}
	}
}

