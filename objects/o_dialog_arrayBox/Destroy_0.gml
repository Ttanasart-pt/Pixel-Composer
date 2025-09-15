/// @description init
event_inherited();
if(WIDGET_CURRENT == self) WIDGET_CURRENT = undefined;

if(arrayBox) arrayBox.open = false;
if(onClose) onClose(arraySet);