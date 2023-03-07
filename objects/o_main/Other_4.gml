/// @description init
MODIFIED = false;
PREF_LOAD();

#region reset data
	ds_stack_clear(UNDO_STACK);
	ds_stack_clear(REDO_STACK);
#endregion