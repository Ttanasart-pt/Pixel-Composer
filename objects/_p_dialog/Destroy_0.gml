/// @description init
if(sHOVER)  HOVER = noone;
if(sFOCUS)  setFocus(noone);
if(refocus) setFocus(prefocus);

widget_reset();
ds_list_remove(DIALOGS, self);
DIALOG_JUST_CLOSED = "dialog";

if(parent) array_remove(parent.children, id);