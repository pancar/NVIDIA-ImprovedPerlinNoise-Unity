#ifndef NOISE_UTILS_INCLUDED
#define NOISE_UTILS_INCLUDED

inline float SmoothTreshold(float value, float threshold, float transitionWidth)
{
    #if (USESMOOTHTRESHOLD == 1)
    return smoothstep(threshold - transitionWidth, threshold + transitionWidth, value);
    #else
    return value;
    #endif
}

inline float NormalizeNoise(float x)
{
    #if defined( NOISE_NORMALIZATION_METHOD_LINEAR01)
    x = (x + 1.0) * 0.5;
    #elif defined(NOISE_NORMALIZATION_METHOD_CLAMPED01)
    x =  saturate((x + 1.0) * 0.5);
    #elif defined(NOISE_NORMALIZATION_METHOD_ABS)
    x =  abs(x);
    #else
    x = 0;
    #endif

    return SmoothTreshold(x, _threshold, _transitionWidth);
}

#endif
