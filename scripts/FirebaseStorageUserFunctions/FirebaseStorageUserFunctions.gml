
function FirebaseStorage_Cancel(ind)
{
	return SDKFirebaseStorage_Cancel(ind)
}

function FirebaseStorage_Download(localfilename, firebasePath, bucket = "")
{
	return SDKFirebaseStorage_Download(localfilename,firebasePath,bucket)
}

function FirebaseStorage_Upload(localPath, firebasePath, bucket = "")
{
	return SDKFirebaseStorage_Upload(localPath,firebasePath,bucket)
}

function FirebaseStorage_Delete(firebasePath, bucket = "")
{
	return SDKFirebaseStorage_Delete(firebasePath,bucket)
}

function FirebaseStorage_GetURL(firebasePath, bucket = "")
{
	return SDKFirebaseStorage_GetURL(firebasePath,bucket)
}

function FirebaseStorage_List(firebasePath, maxResults, pageToken = "", bucket = "")
{
	return SDKFirebaseStorage_List(firebasePath,maxResults,pageToken,bucket)
}

function FirebaseStorage_ListAll(firebasePath, bucket = "")
{
	return SDKFirebaseStorage_ListAll(firebasePath,bucket)
}

