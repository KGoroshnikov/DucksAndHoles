float Cross2D_float(float2 a, float2 b) {
    return a.x * b.y - a.y * b.x;
}

float EdgeSmoothFactor(float2 p, float2 a, float2 b, float feather) {
    float edgeLength = length(b - a);
    float d = Cross2D_float(b - a, p - a) / edgeLength;
    return smoothstep(0.0, feather, d);
}

void GetInsideFactor_float(float2 p, float2 v0, float2 v1, float2 v2, float2 v3, float feather, out float res)
{
    float factor0 = EdgeSmoothFactor(p, v0, v1, feather);
    float factor1 = EdgeSmoothFactor(p, v1, v2, feather);
    float factor2 = EdgeSmoothFactor(p, v2, v3, feather);
    float factor3 = EdgeSmoothFactor(p, v3, v0, feather);

    res = min(min(factor0, factor1), min(factor2, factor3));
}
