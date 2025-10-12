#ifndef PERLIN_NOISE_INCLUDED
#define PERLIN_NOISE_INCLUDED
//https://developer.nvidia.com/gpugems/gpugems2/part-iii-high-quality-rendering/chapter-26-implementing-improved-perlin-noise
#include "Assets/ImprovedPerlinNoise/Shaders/Includes/NoiseUtils.hlsl"

TEXTURE2D(_PermutationTex);
SAMPLER(sampler_PermutationTex);
TEXTURE2D(_GradientTex);
SAMPLER(sampler_GradientTex);

float perm(float x)
{
    float2 uv = float2(x, 0);
    float sample = SAMPLE_TEXTURE2D_LOD(_PermutationTex, sampler_PermutationTex, uv, 0).r;
    return sample;
}

float grad(float x, float3 p)
{
    float2 uv = float2(x, 0);
    float3 g = SAMPLE_TEXTURE2D_LOD(_GradientTex, sampler_GradientTex, uv, 0).rgb;
    return dot(g, p);
}

float3 fade(float3 t)
{
    return t * t * t * (t * (t * 6 - 15) + 10); // new curve
    //
    return t * t * (3 - 2 * t); // old curve
}

float inoise(float3 p)
{
    float3 P = fmod(floor(p), 256.0);
    p -= floor(p);
    float3 f = fade(p);
    P = P / 256;
    const float one = 1.0 / 256.0;
    // HASH COORDINATES FOR 6 OF THE 8 CUBE CORNERS
    float A = perm(P.x) + P.y;
    float AA = perm(A) + P.z;
    float AB = perm(A + one) + P.z;
    float B = perm(P.x + one) + P.y;
    float BA = perm(B) + P.z;
    float BB = perm(B + one) + P.z;
    // AND ADD BLENDED RESULTS FROM 8 CORNERS OF CUBE
    return lerp(
        lerp(lerp(grad(perm(AA), p),
                  grad(perm(BA), p + float3(-1, 0, 0)),
                  f.x),
             lerp(grad(perm(AB), p + float3(0, -1, 0)),
                  grad(perm(BB), p + float3(-1, -1, 0)),
                  f.x),
             f.y),
        lerp(lerp(grad(perm(AA + one), p + float3(0, 0, -1)),
                  grad(perm(BA + one), p + float3(-1, 0, -1)), f.x),
             lerp(grad(perm(AB + one), p + float3(0, -1, -1)),
                  grad(perm(BB + one), p + float3(-1, -1, -1)), f.x),
             f.y),
        f.z);
}

void GetPerlinNoise_float(float3 pos, float3 offset, float scale, out float output)
{
    output = NormalizeNoise(inoise(pos * scale.xxx + offset));
}

void fBm_float(float3 p, float3 offset, float scale, float octaves, float lacunarity, float gain, out float output)
{
    p *= scale;
    p += offset;
    float freq = 1.0, amp = 0.5;
    float sum = 0;
    for (int i = 0; i < octaves; i++)
    {
        sum += inoise(p * freq) * amp;
        freq *= lacunarity;
        amp *= gain;
    }
    output = NormalizeNoise(sum);
}

void Turbulence_float(float3 p, float3 offset, float scale, float octaves, float lacunarity, float gain,
                      out float output)
{
    p *= scale;
    p += offset;
    float sum = 0;
    float freq = 1.0, amp = 1.0;
    for (int i = 0; i < octaves; i++)
    {
        sum += abs(inoise(p * freq)) * amp;
        freq *= lacunarity;
        amp *= gain;
    }
    output = NormalizeNoise(sum);
}

float ridge(float h, float offset)
{
    h = abs(h);
    h = offset - h;
    h = h * h;
    return h;
}

void RidgedMultifractal_float(float3 p, float3 offset, float scale,
                              float octaves,
                              float lacunarity,
                              float gain, float fractOffset, out float output)
{
    float sum = 0;
    float freq = 1.0, amp = 0.5;
    float prev = 1.0;
    p *= scale;
    p += offset;
    for (int i = 0; i < octaves; i++)
    {
        float n = ridge(inoise(p * freq), fractOffset);
        sum += n * amp * prev;
        prev = n;
        freq *= lacunarity;
        amp *= gain;
    }
    output = NormalizeNoise(sum);
}

void GetNoise_float(float3 p, float3 offset, float scale,
                    float octaves,
                    float lacunarity,
                    float gain, float fractOffset, out float output)
{
    offset += _Direction * _Time.y;
    #if defined(NOISETYPE_PERLIN)
    GetPerlinNoise_float(p, offset, scale, output);
    #elif defined(NOISETYPE_FBM)
    fBm_float(p, offset, scale, octaves, lacunarity, gain, output);
    #elif defined(NOISETYPE_TURBULENCE)
    Turbulence_float( p,  offset,  scale,  octaves,  lacunarity,  gain, output);
    #elif defined(NOISETYPE_RIDGEDMULTIFRACTAL)
    RidgedMultifractal_float( p,  offset, scale,octaves, lacunarity,
                               gain, fractOffset, output);
    #else
    output = 1;
    #endif
}

#endif
