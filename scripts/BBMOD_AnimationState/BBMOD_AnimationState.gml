/// @func BBMOD_AnimationState(_name, _animation[, _loop])
///
/// @extends BBMOD_State
/// @implements {BBMOD_IEventListener}
///
/// @desc A state of an animation state machine.
///
/// @param {String} _name The name of the state.
/// @param {Struct.BBMOD_Animation} _animation The animation played while the
/// is active.
/// @param {Bool} [_loop] If `true` then the animation will be looped.
/// Defaults to `false`.
///
/// @example
/// The following code shows examples of animation states which together make
/// a simple locomotion state machine.
///
/// ```gml
/// stateIdle = new BBMOD_AnimationState("Idle", animIdle, true);
/// stateIdle.OnUpdate = method(self, function () {
///     if (in_air())
///     {
///         animationStateMachine.change_state(stateJump);
///         return;
///     }
///     if (speed > 0)
///     {
///         animationStateMachine.change_state(stateWalk);
///         return;
///     }
/// });
/// animationStateMachine.add_state(stateIdle);
///
/// stateWalk = new BBMOD_AnimationState("Walk", animWalk, true);
/// stateWalk.OnUpdate = method(self, function () {
///     if (in_air())
///     {
///         animationStateMachine.change_state(stateJump);
///         return;
///     }
///     if (speed == 0)
///     {
///         animationStateMachine.change_state(stateIdle);
///         return;
///     }
/// });
/// animationStateMachine.add_state(stateWalk);
///
/// stateJump = new BBMOD_AnimationState("Jump", animJump, true);
/// stateJump.OnUpdate = method(self, function () {
///     if (!in_air())
///     {
///         animationStateMachine.change_state(stateLanding);
///         return;
///     }
/// });
/// animationStateMachine.add_state(stateJump);
///
/// stateLanding = new BBMOD_AnimationState("Landing", animLanding);
/// stateLanding.on_event(BBMOD_EV_ANIMATION_END, method(self, function () {
///     animationStateMachine.change_state(stateIdle);
/// }));
/// ```
///
/// @see BBMOD_AnimationStateMachine
function BBMOD_AnimationState(_name, _animation, _loop=false)
	: BBMOD_State(_name) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IEventListener);

	/// @var {Struct.BBMOD_Animation} The animation played while the state is
	/// active.
	/// @readonly
	Animation = _animation;

	/// @var {Bool} If `true` then the animation is played in loops.
	/// @readonly
	Loop = _loop;
}
