/// @description init
if(sHOVER)  HOVER = noone;
if(sFOCUS)  setFocus(noone);
if(refocus) setFocus(prefocus);

WIDGET_CURRENT = undefined;
ds_list_remove(DIALOGS, self);

if(parent) array_remove(parent.children, id);

if(!passthrough) MOUSE_BLOCK = true;