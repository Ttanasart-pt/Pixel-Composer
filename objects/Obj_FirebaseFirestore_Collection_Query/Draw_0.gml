
event_inherited();

var string_function = "FirebaseFirestore(\""+collection_path+"\")"

if(!Obj_FirebaseFirestore_Collection_Query_OrderBy.locked)
	string_function += ".OrderBy(\""+Obj_FirebaseFirestore_Collection_Query_OrderBy.value+"\",\""+Obj_FirebaseFirestore_Collection_Query_AscendingDescending.text+"\")"

if(!Obj_FirebaseFirestore_Collection_Query_LessThan.locked)
	string_function += ".WhereLessThan(\""+Obj_FirebaseFirestore_Collection_Query_LessThan.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_LessThan.value)+")"
	
if(!Obj_FirebaseFirestore_Collection_Query_LessEqualThan.locked)
	string_function += ".WhereLessThanOrEqual(\""+Obj_FirebaseFirestore_Collection_Query_LessEqualThan.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_LessEqualThan.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_Greater.locked)
	string_function += ".WhereGreaterThan(\""+Obj_FirebaseFirestore_Collection_Query_Greater.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_Greater.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_GreaterEqual.locked)
	string_function += ".WhereGreaterThanOrEqual(\""+Obj_FirebaseFirestore_Collection_Query_GreaterEqual.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_GreaterEqual.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_Equal.locked)
	string_function += ".WhereEqual(\""+Obj_FirebaseFirestore_Collection_Query_Equal.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_Equal.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_NotEqual.locked)
	string_function += ".WhereNotEqual(\""+Obj_FirebaseFirestore_Collection_Query_NotEqual.path+"\","+string(Obj_FirebaseFirestore_Collection_Query_NotEqual.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_StartAt.locked)
	string_function += ".StartAt("+string(Obj_FirebaseFirestore_Collection_Query_StartAt.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_EndAt.locked)
	string_function += ".EndAt("+string(Obj_FirebaseFirestore_Collection_Query_EndAt.value)+")"

if(!Obj_FirebaseFirestore_Collection_Query_Limit.locked)
	string_function += ".Limit("+string(Obj_FirebaseFirestore_Collection_Query_Limit.value)+")"


string_function += ".Query()"

draw_set_font(Font_YoYo_15)
draw_set_halign(fa_center)
draw_set_valign(fa_center)

draw_text(room_width/2,120,string_function)

