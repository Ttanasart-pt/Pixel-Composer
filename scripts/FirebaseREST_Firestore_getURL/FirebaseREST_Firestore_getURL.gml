function FirebaseREST_Firestore_getURL(path)
{
	return FirebaseFirestore_Path_Join(
		"https://firestore.googleapis.com/v1/projects/",
		FIRESTORE_ID,
		"/databases/(default)/documents/",
		path)
}
