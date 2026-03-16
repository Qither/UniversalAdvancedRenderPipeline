#ifndef URPPLUS_IRIDESCENCE_INCLUDED
#define URPPLUS_IRIDESCENCE_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"

half3 CalculateIridescence(half eta_1, half cosTheta1, half2 iridescenceTS, half3 specular)
{
    return EvalIridescence(eta_1, cosTheta1, iridescenceTS.x, specular);
}

#endif