#ifndef URPPLUS_VECTORS_DATA_INCLUDED
#define URPPLUS_VECTORS_DATA_INCLUDED

struct VectorsData
{
    real3 geomNormalWS;
    real3 normalWS;
    real3 coatNormalWS;
    real3 viewDirectionWS;
    real4 tangentWS;
    real3 bitangentWS;
};

VectorsData CreateVectorsData(real3 geomNormalWS, real3 normalWS, real3 viewDirectionWS)
{
    VectorsData vData = (VectorsData)0;

    vData.geomNormalWS = geomNormalWS;
    vData.normalWS = normalWS;
    vData.viewDirectionWS = viewDirectionWS;

    return vData;
}

VectorsData CreateVectorsData(real3 geomNormalWS, real3 normalWS, real3 coatNormalWS, real3 viewDirectionWS, real4 tangentWS)
{
    VectorsData vData = (VectorsData)0;

    vData.geomNormalWS = geomNormalWS;
    vData.normalWS = normalWS;
    vData.coatNormalWS = coatNormalWS;
    vData.viewDirectionWS = viewDirectionWS;
    vData.tangentWS = tangentWS;

    return vData;
}

VectorsData CreateEmptyVectorsData()
{
    const VectorsData data = (VectorsData)0;

    return data;
}

#endif