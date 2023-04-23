/// @func BBMOD_IRenderable()
///
/// @interface
///
/// @desc An interface describing renderable objects. Any struct or object that
/// implements this interface can be rendered using a {@link BBMOD_Renderer}.
///
/// @example
/// A renderable object:
/// ```gml
/// /// @desc Create event
/// render = function () {
///     var _matrix = matrix_build_identity();
///     _matrix[@ 12] = x;
///     _matrix[@ 13] = y;
///     _matrix[@ 14] = z;
///     matrix_set(matrix_world, _matrix);
///     model.render();
///     return self;
/// };
/// ```
/// A renderable struct:
/// ```gml
/// renderable = {
///     position: new BBMOD_Vec3(),
///     model: /* ... */,
///     render: function () {
///         var _matrix = matrix_build_identity();
///         position.ToArray(_matrix, 12);
///         matrix_set(matrix_world, _matrix);
///         model.render();
///         return self;
///     },
/// };
/// ```
/// @see BBMOD_Renderer
function BBMOD_IRenderable()
{
	/// @func render()
	///
	/// @desc Enqueues the object for rendering.
	///
	/// @return {Struct.BBMOD_IRenderable} Returns `self`.
	///
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static render = function () {
		throw new BBMOD_NotImplementedException();
		//return self;
	};
}
