#ifndef URPPLUS_VERTEX_TESSELLATION_INCLUDED
#define URPPLUS_VERTEX_TESSELLATION_INCLUDED

#include "Assets/Rendering/UARP/Shaders/Material/Common/Displacement/Tessellation/TessStructures.hlsl"

//ref: https://catlikecoding.com/unity/tutorials/advanced-rendering/surface-displacement/
//ref: https://catlikecoding.com/unity/tutorials/advanced-rendering/tessellation/
//ref: https://gist.github.com/NedMakesGames/808a04367e60947a7966976f918081b2

#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
// AMD recommand this value for GCN http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/05/GCNPerformanceTweets.pdf
#define MAX_TESSELLATION_FACTORS 15.0
#else
#define MAX_TESSELLATION_FACTORS 64.0
#endif

struct TessellationFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

bool TriangleIsBelowClipPlane(float3 p0, float3 p1, float3 p2, int planeIndex, float bias) 
{
	float4 plane = unity_CameraWorldClipPlanes[planeIndex];
	return
		dot(float4(p0, 1), plane) < bias &&
		dot(float4(p1, 1), plane) < bias &&
		dot(float4(p2, 1), plane) < bias;
}

bool TriangleIsCulled(float3 p0, float3 p1, float3 p2, float bias) 
{
	return
		TriangleIsBelowClipPlane(p0, p1, p2, 0, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 1, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 2, bias) ||
		TriangleIsBelowClipPlane(p0, p1, p2, 3, bias);
}

float3 GetDistanceBasedTessFactor(float3 p0, float3 p1, float3 p2, float3 cameraPosWS, float tessMinDist, float tessMaxDist)
{
    float3 edgePosition0 = 0.5 * (p1 + p2);
    float3 edgePosition1 = 0.5 * (p0 + p2);
    float3 edgePosition2 = 0.5 * (p0 + p1);

    // In case camera-relative rendering is enabled, 'cameraPosWS' is statically known to be 0,
    // so the compiler will be able to optimize distance() to length().
    float dist0 = distance(edgePosition0, cameraPosWS);
    float dist1 = distance(edgePosition1, cameraPosWS);
    float dist2 = distance(edgePosition2, cameraPosWS);

    // Saturate will handle the produced NaN in case min == max
    float fadeDist = tessMaxDist - tessMinDist;
    float3 tessFactor;
    tessFactor.x = saturate(1.0 - (dist0 - tessMinDist) / fadeDist);
    tessFactor.y = saturate(1.0 - (dist1 - tessMinDist) / fadeDist);
    tessFactor.z = saturate(1.0 - (dist2 - tessMinDist) / fadeDist);

    return tessFactor;
}

float TessellationEdgeFactor(float3 p0, float3 p1) 
{
	float edgeLength = distance(p0, p1);
	float3 edgeCenter = (p0 + p1) * 0.5;
	float viewDistance = distance(edgeCenter, _WorldSpaceCameraPos);
	float tessFactor = edgeLength * _ScreenParams.y / (_TessellationEdgeLength * viewDistance);
    return min(tessFactor, _TessellationFactor);
}

float3 ProjectPointOnPlane(float3 position, float3 planePosition, float3 planeNormal)
{
    return position - (dot(position - planePosition, planeNormal) * planeNormal);
}

float3 PhongTessellation(float3 positionWS, float3 p0, float3 p1, float3 p2, float3 n0, float3 n1, float3 n2, float3 baryCoords, float shape)
{
    float3 c0 = ProjectPointOnPlane(positionWS, p0, n0);
    float3 c1 = ProjectPointOnPlane(positionWS, p1, n1);
    float3 c2 = ProjectPointOnPlane(positionWS, p2, n2);

    float3 phongPositionWS = baryCoords.x * c0 + baryCoords.y * c1 + baryCoords.z * c2;

    return lerp(positionWS, phongPositionWS, shape);
}

TessellationFactors HullConstant(InputPatch<TessellationControlPoint, 3> input)
{
    float3 p0 = mul(GetObjectToWorldMatrix(), input[0].positionOS).xyz;
    float3 p1 = mul(GetObjectToWorldMatrix(), input[1].positionOS).xyz;
    float3 p2 = mul(GetObjectToWorldMatrix(), input[2].positionOS).xyz;

    TessellationFactors f;
    float bias = 0;
    #ifdef _TESSELLATION_DISPLACEMENT
		bias = _TessellationBackFaceCullEpsilon * _HeightAmplitude;
	#endif

    #ifndef META_PASS_VARYINGS
	if (TriangleIsCulled(p0, p1, p2, bias)) 
    {
        f.edge[0] = f.edge[1] = f.edge[2] = f.inside = 0; // Cull the input
    } 
    else
    #endif
    {
        float3 tf = float3(_TessellationFactor, _TessellationFactor, _TessellationFactor);
        #if defined(_TESSELLATION_EDGE)
            tf = float3(TessellationEdgeFactor(p1, p2), TessellationEdgeFactor(p2, p0), TessellationEdgeFactor(p0, p1));
        #elif defined(_TESSELLATION_DISTANCE)
            float3 distFactor = GetDistanceBasedTessFactor(p0, p1, p2, _WorldSpaceCameraPos, _TessellationFactorMinDistance, _TessellationFactorMaxDistance);
            tf *= distFactor * distFactor;
        #endif
        tf = max(tf, float3(1.0, 1.0, 1.0));

        f.edge[0] = min(tf.x, MAX_TESSELLATION_FACTORS);
        f.edge[1] = min(tf.y, MAX_TESSELLATION_FACTORS);
        f.edge[2] = min(tf.z, MAX_TESSELLATION_FACTORS);

        f.inside = (f.edge[0] + f.edge[1] + f.edge[2]) / 3.0;
    }
    
	return f;
}

// ref: http://reedbeta.com/blog/tess-quick-ref/
[maxtessfactor(MAX_TESSELLATION_FACTORS)]
[domain("tri")]
[partitioning("fractional_odd")]
[outputtopology("triangle_cw")]
[patchconstantfunc("HullConstant")]
[outputcontrolpoints(3)]
TessellationControlPoint Hull(InputPatch<TessellationControlPoint, 3> input, uint id : SV_OutputControlPointID)
{
    // Pass-through
    return input[id];
}

#define BARYCENTRIC_INTERPOLATE(fieldName) \
        input[0].fieldName * baryCoords.x + \
        input[1].fieldName * baryCoords.y + \
        input[2].fieldName * baryCoords.z

#endif