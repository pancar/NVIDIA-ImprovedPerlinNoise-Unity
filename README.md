<img width="964" height="540" alt="image" src="https://github.com/user-attachments/assets/c62cb6cd-d261-4231-ac07-1f31dce552a6" /># NVIDIA Improved Perlin Noise for Unity

Improved Perlin Noise implementation for Unity using gradient and permutation LUT textures.  
Source inspired by [GPU Gems 2, Chapter 26](https://developer.nvidia.com/gpugems/gpugems2/part-iii-high-quality-rendering/chapter-26-implementing-improved-perlin-noise).

---

## Overview

This package provides Perlin Noise generation for Unity projects.  
It supports multiple noise types and can be used in PBR, raymarching, and procedural shader setups.

Features:
- Gradient and permutation LUT textures for GPU-accelerated noise evaluation.
- ScriptableObject-based LUT management.
- Sample scene with multiple noise examples: Perlin, FBM, Turbulence, Ridged Multi-Fractal, and more.

---


## Usage

### Generating LUTs
1. Use the **Generate Global Texture Data + LUTs** tool under `Tools/ImprovedPerlinNoise/Generate Global Texture Data + LUTs`.
2. This will:
   - Generate gradient and permutation LUT textures.
   - Create a ScriptableObject for LUT assignment.
   - Assign the LUTs as global textures for shaders.

> **Note:** The ScriptableObject handles global texture assignment, so manual assignment is generally not needed.

### Sample Scene
- Black & white noise outputs
- Raymarching examples
- Llit shader examples

Noise types included:
- **Perlin** – Classic Perlin noise
- **FBM** – Fractal Brownian Motion using Perlin as base
- **Turbulence** – Absolute value variation of Perlin
- **Ridged Multi-Fractal** – Multi-octave Perlin with ridged effect
