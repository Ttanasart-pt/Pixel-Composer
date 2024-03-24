/// @description 
depth = -19999;
tb    = noone;

def_val = 0;
cur_val = 0;
	
def_mx  = 0;
def_my  = 0;
prev_mx = 0;
	
function activate(defVal) {
	def_val = defVal;
	cur_val = defVal;
	
	def_mx = mouse_mx;
	def_my = mouse_my;
	
	prev_mx = mouse_mx;
	
	CURSOR_LOCK_X = mouse_mx;
	CURSOR_LOCK_Y = mouse_my;
}