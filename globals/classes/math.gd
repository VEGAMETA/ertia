class_name Math

const PI : float = 3.14159265359
const MINUS_PI : float = -3.14159265359

const INV_PI : float = 0.31830988618

const TWO_BY_PI : float = 0.636619772368
const TWO_BY_MINUS_PI : float = -0.636619772368

const PI_BY_2 : float = 1.57079632679
const PI_BY_MINUS_2 : float = -1.57079632679

const PI_BY_3 : float = 1.0471975512
const PI_BY_MINUS_3 : float = -1.0471975512

const PI_BY_4 : float = 0.78539816339
const PI_BY_MINUS_4 : float = -0.78539816339

const PI_MINUS_PI_BY_4 : float = 2.35619449019
const PI_MINUS_PI_BY_MINUS_4 : float = -2.35619449019

const PI_TIMES_2_BY_3 : float = 2.09439510239
const PI_TIMES_2_BY_MINUS_3 : float = -2.09439510239

const SQRT_TWO_BY_TWO : float = 0.70710678118


static func conjugate(quaternion: Quaternion) -> Quaternion:
	return Quaternion(-quaternion.x, -quaternion.y, -quaternion.z, quaternion.w)


static func pulse_function(x:float, phase_length:float, change_length:float, y:float ) -> float:
	return (cos(PI * clampf((abs(fmod(x, phase_length) - phase_length * 0.5) \
		- phase_length * 0.5 + change_length), 0.0, 1.0)) - 1.0) * y + 1.0
