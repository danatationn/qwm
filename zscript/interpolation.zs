Class Q_Interpolate {
	
	static float Lerp(float start_value, float end_value, float pct) {
		int result = (start_value + (end_value - start_value) * pct);
		return result;
	}

	static float EaseIn(float t) {
		return t * t;
	}

	static float EaseOut(float t) {
		return 1 - (1 - t) ** 2;
	}

	static float EaseInOut(float t) {
		return Lerp(EaseIn(t), EaseOut(t), t);
	}
}