/// @description 
var ev_id   = async_load[? "id"];
var ev_type = async_load[? "event_type"];
print(ev_type)

switch(ev_type) {
		
	case "file_drop_start" :
		FILE_DROPPING = [];
		break;
	
	case "file_drop" :
		array_push(FILE_DROPPING, async_load[?"filename"]);
		break;
	
	case "file_drop_end" :
		var _dropped  = files_drop_global(FILE_DROPPING);
		_FILE_DROPPED = !_dropped;
		
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

	case "virtual keyboard status":
		print(async_load[? "screen_height"]);
		print(async_load[? "keyboard_status"]);
		break;
}