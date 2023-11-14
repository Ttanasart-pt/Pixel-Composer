
function FirebaseREST_HTTP_Success_Firestore()
{
	switch(event)
	{
		default:
			FirebaseREST_asyncCall_Firestore()
		break
		
	    case "FirebaseFirestore_Collection_Read":
		case "FirebaseFirestore_Collection_Listener":
			FirebaseREST_asyncCall_Firestore(FirebaseREST_Firestore_collection_decode(event,async_load[?"result"]))
	    break
		
	    case "FirebaseFirestore_Collection_Query":
			FirebaseREST_asyncCall_Firestore(FirebaseREST_Firestore_collection_query_decode(event,async_load[?"result"]))
	    break
		
	    case "FirebaseFirestore_Document_Read":
		case "FirebaseFirestore_Document_Listener":
	        FirebaseREST_asyncCall_Firestore(FirebaseREST_Firestore_jsonDecode(async_load[?"result"]))
	    break
	}
}