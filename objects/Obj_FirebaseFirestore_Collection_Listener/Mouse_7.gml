
if(listener == noone)
{
	text = "Collection Listener Remove"
	listener = FirebaseFirestore("Collection").Listener()
}
else
{
	FirebaseFirestore().ListenerRemove(listener)
	listener = noone
	text = "Collection Listener"
}
