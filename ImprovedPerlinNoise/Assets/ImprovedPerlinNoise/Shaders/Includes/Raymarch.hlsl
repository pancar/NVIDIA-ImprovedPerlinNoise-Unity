//Base shader adapted from [NikLever Unity URP Cookbook](https://github.com/NikLever/Unity-URP-Cookbook/blob/main/Assets/Scripts/HLSL/Raymarch.hlsl)
#include "Assets/ImprovedPerlinNoise/Shaders/Includes/3DPerlinNoise.hlsl"

bool RayBoxIntersect(float3 ro, float3 rd, float3 boxMin, float3 boxMax, out float tNear, out float tFar)
{
    float3 t0 = (boxMin - ro) / rd;
    float3 t1 = (boxMax - ro) / rd;
    float3 tmin = min(t0, t1);
    float3 tmax = max(t0, t1);

    tNear = max(max(tmin.x, tmin.y), tmin.z);
    tFar  = min(min(tmax.x, tmax.y), tmax.z);
    return tNear < tFar;
}

void raymarch_float(
    float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
    float densityScale, float3 offset, float numLightSteps, float lightStepSize,
    float3 lightDir, float lightAbsorb, float darknessThreshold, float transmittance,
    float3 boxMin, float3 boxMax,
    out float3 result)
{
    float tNear = 0;
    float tFar  = 0;

    if (!RayBoxIntersect(rayOrigin, rayDirection, boxMin, boxMax, tNear, tFar))
    {
        result = float3(0, 0, 0);
        return;
    }

    stepSize = (tFar - tNear) / numSteps;

    float t = tNear;

    float density = 0;
    float transmission = 0;
    float finalLight = 0;

    for (int i = 0; i < numSteps; i++)
    {
        float3 samplePos = rayOrigin + rayDirection * t + offset;

        float sampledDensity = 0;
        GetNoise_float(samplePos, _Offset, _Scale, _Octaves,
                       _Lacunarity, _Gain, _FractOffset, sampledDensity);

        density += sampledDensity * densityScale;

        float3 lightRayOrigin = samplePos;
        float lightAccumulation = 0;

        float boxSize   = length(boxMax - boxMin); 
         lightStepSize = boxSize / numLightSteps;
        
        for (int j = 0; j < numLightSteps; j++)
        {
            lightRayOrigin += lightDir * lightStepSize;

            float lightDensity = 0;
            GetNoise_float(lightRayOrigin, _Offset, _Scale, _Octaves,
                           _Lacunarity, _Gain, _FractOffset, lightDensity);

            lightAccumulation += lightDensity;
        }

        float lightTransmission = exp(-lightAccumulation);
        float shadow = darknessThreshold + lightTransmission * (1.0 - darknessThreshold);

        finalLight += density * transmittance * shadow;

        transmittance *= exp(-density * lightAbsorb);

        t += stepSize;
    }

    transmission = exp(-density);
    result = float3(finalLight, transmission, transmittance);
}
