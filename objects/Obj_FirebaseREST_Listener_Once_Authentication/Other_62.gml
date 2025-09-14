
if(async_load[?"status"] != 1)// 1==downloading, 0==success ,<0==Error
if(async_load[?"id"] == request)
{
	
    if(async_load[?"http_status"] == 200 and async_load[?"status"] == 0)
    {
		FirebaseREST_HTTP_Success_Authentication()
        instance_destroy()
    }
	else
	{				
	    alarm[0] = errorResetAlarm
	    countError++
	    if(countError >= errorCountLimit)
	    {		
	        FirebaseREST_HTTP_Failed_Authentication()
	        instance_destroy()
	    }
		
	}
}

