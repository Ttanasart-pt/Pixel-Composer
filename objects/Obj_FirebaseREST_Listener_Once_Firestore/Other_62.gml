
if(async_load[?"status"] != 1)// 1==downloading, 0==success ,<0==Error
if(async_load[?"id"] == request)
{
	
    if(async_load[?"http_status"] == 200 and async_load[?"status"] == 0)
    {
		FirebaseREST_HTTP_Success_Firestore()
        instance_destroy()
    }
	else
	{		
		if(async_load[?"http_status"] == 401 or async_load[?"http_status"] == 403 or async_load[?"http_status"] == 404)//if i not have permissions or not exists, destroy me
		{
			FirebaseREST_HTTP_Failed_Firestore()
			instance_destroy()
			exit
		}
		
	    alarm[0] = errorResetAlarm
	    countError++
	    if(countError >= errorCountLimit)
	    {		
	        FirebaseREST_HTTP_Failed_Firestore()
	        instance_destroy()
	    }
	}
}

