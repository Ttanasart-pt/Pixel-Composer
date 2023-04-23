/// @enum Enumeration of cube sides, compatible with
/// [Xpanda](https://github.com/GameMakerDiscord/Xpanda)'s cubemap layout.
enum BBMOD_ECubeSide
{
	/// @member Front cube side.
	PosX,
	/// @member Back cube side.
	NegX,
	/// @member Right cube side.
	PosY,
	/// @member Left cube side.
	NegY,
	/// @member Top cube side.
	PosZ,
	/// @member Bottom cube side.
	NegZ,
	/// @member Number of cube sides.
	SIZE,
};

/// @func BBMOD_Cubemap(_resolution)
///
/// @extends BBMOD_Class
///
/// @implements {BBMOD_IRenderTarget}
///
/// @desc A cubemap.
///
/// @param {Real} _resolution A resolution of single cubemap side. Must be power
/// of 2!
function BBMOD_Cubemap(_resolution)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IRenderTarget);

	static Class_destroy = destroy;

	/// @var {Array} The position of the cubemap in the world space.
	/// @see BBMOD_Cubemap.get_view_matrix
	Position = new BBMOD_Vec3();

	/// @var {Real} Distance to the near clipping plane used in the cubemap's
	/// projection matrix. Defaults to `0.1`.
	/// @see BBMOD_Cubemap.get_projection_matrix
	ZNear = 0.1;

	/// @var {Real} Distance to the far clipping plane used in the cubemap's
	/// projection matrix. Defaults to `8192`.
	/// @see BBMOD_Cubemap.get_projection_matrix
	ZFar = 8192.0;

	/// @var {Array<Id.Surface>} An array of surfaces.
	/// @readonly
	Sides = array_create(BBMOD_ECubeSide.SIZE, noone);

	/// @var {Id.Surface} A single surface containing all cubemap sides.
	/// This can be passed as uniform to a shader for cubemapping.
	/// @readonly
	Surface = noone;

	/// @var {Real} A resolution of single cubemap side. Must be power of two.
	/// @readonly
	Resolution = _resolution;

	/// @var {Real} An index of a side that we are currently rendering to.
	/// Contains values from {@link BBMOD_ECubeSide}.
	/// @see BBMOD_Cubemap.set_target
	/// @private
	__renderTo = 0;

	/// @func get_surface(_side)
	///
	/// @desc Gets a surface for given cubemap side. If the surface is corrupted,
	/// then a new one is created.
	///
	/// @param {Real} _side The cubemap side.
	///
	/// @return {Id.Surface} The surface.
	///
	/// @see BBMOD_ECubeSide
	static get_surface = function (_side) {
		var _surOld = Sides[_side];
		var _sur = bbmod_surface_check(_surOld, Resolution, Resolution);
		if (_sur != _surOld)
		{
			Sides[@ _side] = _sur;
		}
		return _sur;
	};

	/// @func to_single_surface(_clearColor, _clearAlpha)
	///
	/// @desc Puts all faces of the cubemap into a single surface.
	///
	/// @param {Real} _clearColor The color to clear the target surface with
	/// before the cubemap is rendered into it.
	/// @param {Real} _clearAlpha The alpha to clear the targe surface with
	/// before the cubemap is rendered into it.
	///
	/// @see BBMOD_Cubemap.Surface
	static to_single_surface = function (_clearColor, _clearAlpha) {
		Surface = bbmod_surface_check(Surface, Resolution * 8, Resolution);
		surface_set_target(Surface);
		draw_clear_alpha(_clearColor, _clearAlpha);
		var _x = 0;
		var i = 0;
		repeat (BBMOD_ECubeSide.SIZE)
		{
			draw_surface(Sides[i++], _x, 0);
			_x += Resolution;
		}
		surface_reset_target();
	};

	/// @func get_view_matrix(_side)
	///
	/// @desc Creates a view matrix for given cubemap side.
	///
	/// @param {Real} _side The cubemap side. Use values from
	/// {@link BBMOD_ECubeSide}.
	///
	/// @return {Array<Real>} The created view matrix.
	static get_view_matrix = function (_side) {
		var _negEye = Position.Scale(-1.0);
		var _x, _y, _z;

		switch (_side)
		{
		case BBMOD_ECubeSide.PosX:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			break;

		case BBMOD_ECubeSide.NegX:
			_x = new BBMOD_Vec3(0.0, -1.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			break;

		case BBMOD_ECubeSide.PosY:
			_x = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(0.0, +1.0, 0.0);
			break;

		case BBMOD_ECubeSide.NegY:
			_x = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			_y = new BBMOD_Vec3(0.0, 0.0, +1.0);
			_z = new BBMOD_Vec3(0.0, -1.0, 0.0);
			break;

		case BBMOD_ECubeSide.PosZ:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(-1.0, 0.0, 0.0);
			_z = new BBMOD_Vec3(0.0, 0.0, +1.0);
			break;

		case BBMOD_ECubeSide.NegZ:
			_x = new BBMOD_Vec3(0.0, +1.0, 0.0);
			_y = new BBMOD_Vec3(+1.0, 0.0, 0.0);
			_z = new BBMOD_Vec3(0.0, 0.0, -1.0);
			break;
		}

		return [
			_x.X, _y.X, _z.X, 0.0,
			_x.Y, _y.Y, _z.Y, 0.0,
			_x.Z, _y.Z, _z.Z, 0.0,
			_x.Dot(_negEye), _y.Dot(_negEye), _z.Dot(_negEye), 1.0
		];
	}

	/// @func get_projection_matrix()
	///
	/// @desc Creates a projection matrix for the cubemap.
	///
	/// @return {Array<Real>} The created projection matrix.
	static get_projection_matrix = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_perspective_fov(90.0, 1.0, ZNear, ZFar);
	};

	/// @func set_target()
	///
	/// @desc Sets next cubemap side surface as the render target and sets
	/// the current view and projection matrices appropriately.
	///
	/// @return {Bool} Returns `true` if the render target was set or `false`
	/// if all cubemap sides were iterated through.
	///
	/// @example
	/// ```gml
	/// while (cubemap.set_target())
	/// {
	///     draw_clear(c_black);
	///     // Render to cubemap here...
	///     cubemap.reset_target();
	/// }
	/// ```
	///
	/// @see BBMOD_IRenderTarget.reset_target
	static set_target = function () {
		var _renderTo = __renderTo++;
		if (_renderTo < BBMOD_ECubeSide.SIZE)
		{
			surface_set_target(get_surface(_renderTo));
			matrix_set(matrix_view, get_view_matrix(_renderTo));
			matrix_set(matrix_projection, get_projection_matrix());
			return true;
		}
		__renderTo = 0;
		return false;
	};

	static reset_target = function () {
		gml_pragma("forceinline");
		surface_reset_target();
		return self;
	};

	static destroy = function () {
		Class_destroy();
		var i = 0;
		repeat (BBMOD_ECubeSide.SIZE)
		{
			var _surface = Sides[i++];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
		}
		if (surface_exists(Surface))
		{
			surface_free(Surface);
		}
		return undefined;
	};
}
