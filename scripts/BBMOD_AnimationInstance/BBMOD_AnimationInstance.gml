/// @func BBMOD_AnimationInstance(_animation)
///
/// @desc An instance of an animation. Used for animation playback.
///
/// @param {Struct.BBMOD_Animation} _animation An animation to create an
/// instance of.
///
/// @see BBMOD_Animation
function BBMOD_AnimationInstance(_animation) constructor
{
	/// @var {Struct.BBMOD_Animation} The animation to be played.
	/// @see BBMOD_Animation
	/// @readonly
	Animation = _animation;

	/// @var {Bool} If `true` then the animation should be looped.
	/// @readonly
	Loop = false;

	/// @var {Real} The last frame when animation events were executed.
	/// @private
	__eventExecuted = -1;

	/// @var {Real}
	/// @private
	__animationTime = 0;
}
