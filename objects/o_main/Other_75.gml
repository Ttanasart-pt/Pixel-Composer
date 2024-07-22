/// @description 
var ev_id   = async_load[? "id"];
var ev_type = async_load[? "event_type"];

switch(ev_type) {
		
	case "file_drop_start" :
		FILE_DROPPING = [];
		break;
	
	case "file_drop" :
		array_push(FILE_DROPPING, async_load[?"filename"]);
		break;
	
	case "file_drop_end" :
		_FILE_DROPPED    = true;
		FILE_IS_DROPPING = false;
		break;
		
	case "file_drag_over" :
		FILE_IS_DROPPING = true;
		FILE_DROPPING_X  = async_load[? "x"] - window_get_x();
		FILE_DROPPING_Y  = async_load[? "y"] - window_get_y();
		break;
	
	case "file_drag_leave" :
		FILE_IS_DROPPING = false;
		break;
}