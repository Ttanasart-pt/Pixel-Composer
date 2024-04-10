/// @description Insert description here
if(textbox == noone) exit;
if(textbox != WIDGET_CURRENT) exit;
if(array_empty(data)) exit;

if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
	HOVER = self.id;
	if(mouse_press(mb_left)) FOCUS = self.id;
}