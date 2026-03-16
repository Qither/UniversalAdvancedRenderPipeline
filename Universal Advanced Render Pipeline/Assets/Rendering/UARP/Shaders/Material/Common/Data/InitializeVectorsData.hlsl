#ifndef URPPLUS_INITIALIZE_VECTORS_DATA_INCLUDED
#define URPPLUS_INITIALIZE_VECTORS_DATA_INCLUDED

void InitializeVectorsData(Varyings input, SurfaceData surfaceData, InputData inputData, out VectorsData vData)
{
    vData = (VectorsData)0;

    vData.geomNormalWS = input.normalWS.xyz;
    vData.normalWS = inputData.normalWS;
    
    vData.coatNormalWS = inputData.normalWS;
    #if defined(_COATNORMALMAP)
        vData.coatNormalWS = NormalizeNormalPerPixel(TransformTangentToWorld(surfaceData.coatNormalTS, inputData.tangentToWorld));
    #endif

    vData.viewDirectionWS = inputData.viewDirectionWS;

    vData.tangentWS = half4(1.0, 1.0, 0.0, 0.0);
    vData.bitangentWS = half3(1.0, 1.0, 0.0);
    #ifdef REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
        vData.tangentWS = input.tangentWS;
        #if defined(_MATERIAL_FEATURE_ANISOTROPY) && defined(_TANGENTMAP)
        vData.tangentWS = real4(TransformTangentToWorld(surfaceData.tangentTS, inputData.tangentToWorld).xyz, input.tangentWS.w);
        #endif
        
        float sgn = input.tangentWS.w; // should be either +1 or -1
        vData.bitangentWS = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    #endif
}

#endif