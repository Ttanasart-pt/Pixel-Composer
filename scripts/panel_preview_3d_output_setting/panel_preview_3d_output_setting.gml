function Panel_Preview_3D_Output_Setting() : Panel_Linear_Setting() constructor {
	title   = __txt("preview_3d_output_settings", "3D Output Settings");
	preview = PANEL_PREVIEW;
	scene   = PANEL_PREVIEW.d3_scene;
	
	properties = [
		
	]
	
	setHeight();
}