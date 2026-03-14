using UnityEngine;

namespace URPDiffusionProfile.Runtime.Core
{
    [CreateAssetMenu(fileName = "URPDiffusionProfileSettings", menuName = "Rendering/URP Diffusion Profile Settings", order = 401)]
    public sealed class URPDiffusionProfileSettings : ScriptableObject
    {
        [Min(2)]
        public int maxActiveProfiles = 8;
        public bool enableHalfResolution;
        public bool enableNormalAwareRejection = true;
        public bool enableDeferredCompatibility = true;
        [Range(3, 25)]
        public int resolveKernelSize = 9;
    }
}
