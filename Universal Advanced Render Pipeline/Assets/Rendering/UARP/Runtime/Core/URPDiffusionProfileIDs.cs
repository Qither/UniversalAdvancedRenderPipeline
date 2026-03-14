using UnityEngine;

namespace URPDiffusionProfile.Runtime.Core
{
    public static class URPDiffusionProfileIDs
    {
        public static readonly int SSSMetadataTex = Shader.PropertyToID("_SSSMetadataTex");
        public static readonly int SSSProfileIndexTex = Shader.PropertyToID("_SSSProfileIndexTex");
        public static readonly int SSSDiffuseTex = Shader.PropertyToID("_SSSDiffuseTex");
        public static readonly int SSSBlurredTex = Shader.PropertyToID("_SSSBlurredTex");

        public static readonly int SSSProfileData0 = Shader.PropertyToID("_SSSProfileData0");
        public static readonly int SSSProfileData1 = Shader.PropertyToID("_SSSProfileData1");
        public static readonly int SSSProfileData2 = Shader.PropertyToID("_SSSProfileData2");
        public static readonly int SSSProfileData3 = Shader.PropertyToID("_SSSProfileData3");
        public static readonly int SSSProfileCount = Shader.PropertyToID("_SSSProfileCount");
        public static readonly int SSSSettings = Shader.PropertyToID("_SSSSettings");

        public static readonly int DiffusionProfileIndex = Shader.PropertyToID("_DiffusionProfileIndex");
        public static readonly int DiffusionProfileHash = Shader.PropertyToID("_DiffusionProfileHash");
        public static readonly int DiffusionProfileAsset = Shader.PropertyToID("_DiffusionProfileAsset");
        public static readonly int SubsurfaceMask = Shader.PropertyToID("_SubsurfaceMask");
        public static readonly int Thickness = Shader.PropertyToID("_Thickness");
        public static readonly int ThicknessRemap = Shader.PropertyToID("_ThicknessRemap");
        public static readonly int TransmissionMask = Shader.PropertyToID("_TransmissionMask");
        public static readonly int TransmissionEnable = Shader.PropertyToID("_TransmissionEnable");
    }
}
