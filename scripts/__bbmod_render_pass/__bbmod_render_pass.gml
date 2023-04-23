/// @enum Enumeration of render passes.
enum BBMOD_ERenderPass
{
	/// @member Render pass where shadow-casting are objects rendered into
	/// shadow maps.
	Shadows   = 0,
	/// @member Render pass where opaque are rendered into an off-screen depth
	/// buffer when using {@link BBMOD_DefaultRenderer}.
	/// @deprecated Please use {@link BBMOD_ERenderPass.DepthOnly} instead.
	Deferred  = 1,
	/// @member Render pass where opaque objects are rendered into an off-screen
	/// depth buffer.
	DepthOnly = 1,
	/// @member Render pass where opaque objects are rendered into a G-Buffer.
	GBuffer,
	/// @member Render pass where opaque objects are rendered into the frame
	/// buffer.
	Forward,
	/// @member Render pass where alpha-blended objects are rendered.
	Alpha,
	/// @member Render pass where instance IDs are rendered into an off-screen
	/// buffer.
	Id,
	/// @member Total number of members of this enum.
	SIZE,
};

/// @var {Real}
/// @private
global.__bbmodRenderPass = BBMOD_ERenderPass.Forward;

/// @func bbmod_render_pass_to_string(_pass)
///
/// @desc Retrieves a name of a render pass.
///
/// @param {Real} _pass The render pass to get the name of. Use values from
/// {@link BBMOD_ERenderPass}.
///
/// @return {String} The name of the render pass.
function bbmod_render_pass_to_string(_pass)
{
	switch (_pass)
	{
	case BBMOD_ERenderPass.Shadows:
		return "Shadows";

	case BBMOD_ERenderPass.DepthOnly:
		return "DepthOnly";

	case BBMOD_ERenderPass.Forward:
		return "Forward";

	case BBMOD_ERenderPass.Alpha:
		return "Alpha";

	case BBMOD_ERenderPass.Id:
		return "Id";

	default:
		return "";
	}
}

/// @func bbmod_render_pass_from_string(_name)
///
/// @desc Retrieves a render pass from its name.
///
/// @param {String} _name The name of the render pass.
///
/// @return {Real} One of the render passes defined in {@link BBMOD_ERenderPass}.
///
/// @throws {BBMOD_Exception} If an invalid name is passed.
function bbmod_render_pass_from_string(_name)
{
	switch (_name)
	{
	case "Shadows":
		return BBMOD_ERenderPass.Shadows;

	case "Deferred":
	case "DepthOnly":
		return BBMOD_ERenderPass.DepthOnly;

	case "Forward":
		return BBMOD_ERenderPass.Forward;

	case "Alpha":
		return BBMOD_ERenderPass.Alpha;

	case "Id":
		return BBMOD_ERenderPass.Id;

	default:
		throw new BBMOD_Exception("Invalid render pass \"" + _name + "\"!");
	}
}

/// @func bbmod_render_pass_get()
///
/// @desc Retrieves the current render pass.
///
/// @return {Real} The current render pass.
///
/// @see bbmod_render_pass_set
/// @see BBMOD_ERenderPass
function bbmod_render_pass_get()
{
	gml_pragma("forceinline");
	return global.__bbmodRenderPass;
}

/// @func bbmod_render_pass_set(_pass)
///
/// @desc Sets the current render pass. Only meshes with materials that have
/// a shader defined for the render pass will be rendered.
///
/// @param {Real} _pass The render pass. Use values from {@link BBMOD_ERenderPass}.
/// By default this is set to {@link BBMOD_ERenderPass.Forward}.
///
/// @see bbmod_render_pass_get
/// @see BBMOD_BaseMaterial.set_shader
/// @see BBMOD_ERenderPass
function bbmod_render_pass_set(_pass)
{
	gml_pragma("forceinline");
	bbmod_material_reset();
	global.__bbmodRenderPass = _pass;
}
