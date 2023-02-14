function __view_get(__prop, __index) {
	var __res = -1;

	switch(__prop)
	{
	case e__VW.XView: var __cam = view_get_camera(__index); __res = camera_get_view_x(__cam); break;
	case e__VW.YView: var __cam = view_get_camera(__index); __res = camera_get_view_y(__cam); break;
	case e__VW.WView: var __cam = view_get_camera(__index); __res = camera_get_view_width(__cam); break;
	case e__VW.HView: var __cam = view_get_camera(__index); __res = camera_get_view_height(__cam); break;
	case e__VW.Angle: var __cam = view_get_camera(__index); __res = camera_get_view_angle(__cam); break;
	case e__VW.HBorder: var __cam = view_get_camera(__index); __res = camera_get_view_border_x(__cam); break;
	case e__VW.VBorder: var __cam = view_get_camera(__index); __res = camera_get_view_border_y(__cam); break;
	case e__VW.HSpeed: var __cam = view_get_camera(__index); __res = camera_get_view_speed_x(__cam); break;
	case e__VW.VSpeed: var __cam = view_get_camera(__index); __res = camera_get_view_speed_y(__cam); break;
	case e__VW.Object: var __cam = view_get_camera(__index); __res = camera_get_view_target(__cam); break;
	case e__VW.Visible: __res = view_get_visible(__index); break;
	case e__VW.XPort: __res = view_get_xport(__index); break;
	case e__VW.YPort: __res = view_get_yport(__index); break;
	case e__VW.WPort: __res = view_get_wport(__index); break;
	case e__VW.HPort: __res = view_get_hport(__index); break;
	case e__VW.Camera: __res = view_get_camera(__index); break;
	case e__VW.SurfaceID: __res = view_get_surface_id(__index); break;
	default: break;
	};

	return __res;
}
