#ifndef URPPLUS_LAYERED_TEXCOORD_INCLUDED
#define URPPLUS_LAYERED_TEXCOORD_INCLUDED

struct LayerTexCoord
{
    real2 layerMaskUV;
    
    real2 baseUV0;
    real2 baseUV1;
    real2 baseUV2;
    real2 baseUV3;

    real2 detailUV0;
    real2 detailUV1;
    real2 detailUV2;
    real2 detailUV3;

    real2 uvSpaceScale[4];

    real2 emissionUV;
};

#endif