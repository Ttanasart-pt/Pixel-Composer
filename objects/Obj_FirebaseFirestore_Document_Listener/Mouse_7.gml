
if(listener == noone)
{
	text = "Document Listener Remove"
	listener = FirebaseFirestore("Collection/Document").Listener()
}
else
{
	FirebaseFirestore().ListenerRemove(listener)
	listener = noone
	text = "Document Listener"
}
