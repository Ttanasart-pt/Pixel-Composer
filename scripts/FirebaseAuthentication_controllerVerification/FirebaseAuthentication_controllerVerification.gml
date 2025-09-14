
function FirebaseAuthentication_controllerVerification()
{
	if(!instance_number(Obj_FirebaseREST_Authentication))
		instance_create_depth(0,0,0,Obj_FirebaseREST_Authentication)
}
