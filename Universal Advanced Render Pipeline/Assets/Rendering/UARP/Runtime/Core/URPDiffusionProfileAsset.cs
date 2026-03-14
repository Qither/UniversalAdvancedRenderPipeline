using System;
using UnityEngine;

namespace URPDiffusionProfile.Runtime.Core
{
    [CreateAssetMenu(fileName = "URPDiffusionProfile", menuName = "Rendering/URP Diffusion Profile", order = 400)]
    public sealed class URPDiffusionProfileAsset : ScriptableObject
    {
        public enum TexturingMode : uint
        {
            [InspectorName("Pre and Post-Scatter")]
            [Tooltip("Partially applies the albedo to the Material twice, before and after the subsurface scattering pass, for a softer look.")]
            PreAndPostScatter = 0,
            [InspectorName("Post-Scatter")]
            [Tooltip("Applies the albedo to the Material after the subsurface scattering pass, so the contents of the albedo texture aren't blurred.")]
            PostScatter = 1,
        }

        public enum TransmissionMode : uint
        {
            [InspectorName("Thick Object")]
            [Tooltip("Select this mode for geometrically thick objects. This mode uses shadow maps.")]
            Regular = 0,
            [InspectorName("Thin Object")]
            [Tooltip("Select this mode for thin, double-sided geometry, such as paper or leaves.")]
            ThinObject = 1,
        }

        [Serializable]
        public sealed class DiffusionProfileData : IEquatable<DiffusionProfileData>
        {
            [ColorUsage(false, false)]
            public Color scatteringDistance;

            [Min(0.0f)]
            public float scatteringDistanceMultiplier;

            [ColorUsage(false, true)]
            public Color transmissionTint;

            [Tooltip("Specifies when the albedo of the Material is applied.")]
            public TexturingMode texturingMode;

            [Range(1.0f, 2.0f)]
            public Vector2 smoothnessMultipliers;

            [Range(0.0f, 1.0f), Tooltip("Amount of mixing between the primary and secondary specular lobes.")]
            public float lobeMix;

            [Range(1.0f, 3.0f), Tooltip("Exponent on the cosine component of the diffuse lobe.\nHelps to simulate surfaces with strong subsurface scattering.")]
            public float diffuseShadingPower;

            [ColorUsage(false, false)]
            [Tooltip("The color used when a subsurface scattering sample encounters a border. A border is defined by a material not having the same diffusion profile.")]
            public Color borderAttenuationColor;

            public TransmissionMode transmissionMode;
            public Vector2 thicknessRemap;
            public float worldScale;
            public float ior;

            public Vector3 shapeParam { get; private set; }
            public float filterRadius { get; private set; }
            public float maxScatteringDistance { get; private set; }
            public uint hash = 0;

            public DiffusionProfileData()
            {
                ResetToDefault();
            }

            public void ResetToDefault()
            {
                scatteringDistance = Color.grey;
                scatteringDistanceMultiplier = 1f;
                transmissionTint = Color.white;
                texturingMode = TexturingMode.PreAndPostScatter;
                smoothnessMultipliers = Vector2.one;
                lobeMix = 0.5f;
                diffuseShadingPower = 1.0f;
                transmissionMode = TransmissionMode.ThinObject;
                thicknessRemap = new Vector2(0f, 5f);
                worldScale = 1f;
                ior = 1.4f;
                borderAttenuationColor = Color.black;
            }

            public void Validate()
            {
                thicknessRemap.y = Mathf.Max(thicknessRemap.y, 0f);
                thicknessRemap.x = Mathf.Clamp(thicknessRemap.x, 0f, thicknessRemap.y);
                worldScale = Mathf.Max(worldScale, 0.001f);
                ior = Mathf.Clamp(ior, 1.0f, 2.0f);

                if (diffuseShadingPower == 0.0f)
                {
                    smoothnessMultipliers = Vector2.one;
                    lobeMix = 0.5f;
                    diffuseShadingPower = 1.0f;
                }

                UpdateKernel();
            }

            public bool Equals(DiffusionProfileData other)
            {
                if (other == null)
                {
                    return false;
                }

                return scatteringDistance == other.scatteringDistance &&
                       scatteringDistanceMultiplier == other.scatteringDistanceMultiplier &&
                       transmissionTint == other.transmissionTint &&
                       texturingMode == other.texturingMode &&
                       smoothnessMultipliers == other.smoothnessMultipliers &&
                       lobeMix == other.lobeMix &&
                       diffuseShadingPower == other.diffuseShadingPower &&
                       borderAttenuationColor == other.borderAttenuationColor &&
                       transmissionMode == other.transmissionMode &&
                       thicknessRemap == other.thicknessRemap &&
                       worldScale == other.worldScale &&
                       ior == other.ior;
            }

            private void UpdateKernel()
            {
                var scattering = scatteringDistanceMultiplier * (Vector3)(Vector4)scatteringDistance;

                shapeParam = new Vector3(
                    Mathf.Min(16777216f, 1.0f / scattering.x),
                    Mathf.Min(16777216f, 1.0f / scattering.y),
                    Mathf.Min(16777216f, 1.0f / scattering.z));

                maxScatteringDistance = Mathf.Max(scattering.x, Mathf.Max(scattering.y, scattering.z));
                filterRadius = SampleBurleyDiffusionProfile(0.997f, maxScatteringDistance);
            }

            private static float SampleBurleyDiffusionProfile(float u, float rcpS)
            {
                u = 1f - u;
                var g = 1f + (4f * u) * (2f * u + Mathf.Sqrt(1f + (4f * u) * u));
                var n = Mathf.Pow(g, -1.0f / 3.0f);
                var p = (g * n) * n;
                var c = 1f + p + n;
                var x = 3f * Mathf.Log(c / (4f * u));
                return x * rcpS;
            }
        }

        [Serializable]
        public struct GpuData
        {
            public Vector4 data0;
            public Vector4 data1;
            public Vector4 data2;
            public Vector4 data3;
        }

        [SerializeField] internal DiffusionProfileData profile;

        [NonSerialized] internal Vector4 worldScaleAndFilterRadiusAndThicknessRemap;
        [NonSerialized] internal Vector4 shapeParamAndMaxScatterDist;
        [NonSerialized] internal Vector4 transmissionTintAndFresnel0;
        [NonSerialized] internal Vector4 disabledTransmissionTintAndFresnel0;
        [NonSerialized] internal Vector4 dualLobeAndDiffusePower;
        [NonSerialized] internal Vector4 borderAttenuationColorMultiplier;
        [NonSerialized] internal int updateCount;

        public uint ProfileHash => profile.hash;
        public Color ScatteringColor => profile.scatteringDistance;
        public float ScatteringDistanceMultiplier => profile.scatteringDistanceMultiplier;
        public Color ScatteringDistance => profile.scatteringDistance * profile.scatteringDistanceMultiplier;
        public float WorldScale => profile.worldScale;
        public float IndexOfRefraction => profile.ior;
        public Color TransmissionTint => profile.transmissionTint;
        public TransmissionMode Transmission => profile.transmissionMode;
        public Vector2 ThicknessRemap => profile.thicknessRemap;
        public TexturingMode Texturing => profile.texturingMode;
        public Vector2 SmoothnessMultipliers => profile.smoothnessMultipliers;
        public float SecondarySmoothnessMultiplier => profile.smoothnessMultipliers.x;
        public float PrimarySmoothnessMultiplier => profile.smoothnessMultipliers.y;
        public float LobeMix => profile.lobeMix;
        public float DiffuseShadingPower => profile.diffuseShadingPower;
        public Color BorderAttenuationColor => profile.borderAttenuationColor;
        public float FilterRadius => profile.filterRadius;
        public float MaxScatterDistance => profile.maxScatteringDistance;
        public Vector4 WorldScaleAndFilterRadiusAndThicknessRemap => worldScaleAndFilterRadiusAndThicknessRemap;
        public Vector4 ShapeParamAndMaxScatterDist => shapeParamAndMaxScatterDist;
        public Vector4 TransmissionTintAndFresnel0 => transmissionTintAndFresnel0;
        public Vector4 DisabledTransmissionTintAndFresnel0 => disabledTransmissionTintAndFresnel0;
        public Vector4 DualLobeAndDiffusePower => dualLobeAndDiffusePower;
        public Vector4 BorderAttenuationColorMultiplier => borderAttenuationColorMultiplier;
        public int UpdateCount => updateCount;

        public GpuData GetGpuData()
        {
            return new GpuData
            {
                data0 = shapeParamAndMaxScatterDist,
                data1 = transmissionTintAndFresnel0,
                data2 = worldScaleAndFilterRadiusAndThicknessRemap,
                data3 = dualLobeAndDiffusePower,
            };
        }

        public void Validate()
        {
            if (profile == null)
            {
                profile = new DiffusionProfileData();
            }

            profile.Validate();

            if (profile.hash == 0)
            {
                unchecked
                {
                    profile.hash = (uint)GetInstanceID();
                }
            }

            UpdateCache();
        }

        private void OnEnable()
        {
            Validate();
        }

        private void OnValidate()
        {
            Validate();
        }

        private void UpdateCache()
        {
            worldScaleAndFilterRadiusAndThicknessRemap = new Vector4(
                profile.worldScale,
                profile.filterRadius,
                profile.thicknessRemap.x,
                profile.thicknessRemap.y - profile.thicknessRemap.x);

            shapeParamAndMaxScatterDist = profile.shapeParam;
            shapeParamAndMaxScatterDist.w = profile.maxScatteringDistance;

            var fresnel0 = (profile.ior - 1.0f) / (profile.ior + 1.0f);
            fresnel0 *= fresnel0;

            transmissionTintAndFresnel0 = new Vector4(
                profile.transmissionTint.r * 0.25f,
                profile.transmissionTint.g * 0.25f,
                profile.transmissionTint.b * 0.25f,
                fresnel0);
            disabledTransmissionTintAndFresnel0 = new Vector4(0.0f, 0.0f, 0.0f, fresnel0);

            var smoothnessB = Mathf.Approximately(profile.lobeMix, 0.0f) ? 1.0f : profile.smoothnessMultipliers.y;
            dualLobeAndDiffusePower = new Vector4(
                profile.smoothnessMultipliers.x,
                smoothnessB,
                profile.lobeMix,
                profile.diffuseShadingPower - 1.0f);
            borderAttenuationColorMultiplier = profile.borderAttenuationColor;

            updateCount++;
        }
    }
}
