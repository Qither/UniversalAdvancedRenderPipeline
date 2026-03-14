using System;
using URPDiffusionProfile.Runtime.Core;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace URPDiffusionProfile.EditorTools
{
    internal sealed class SerializedURPDiffusionProfileAsset : IDisposable
    {
        internal URPDiffusionProfileAsset Asset { get; }
        internal SerializedProperty ScatteringDistance { get; }
        internal SerializedProperty ScatteringDistanceMultiplier { get; }
        internal SerializedProperty WorldScale { get; }
        internal SerializedProperty IndexOfRefraction { get; }
        internal SerializedProperty TransmissionTint { get; }
        internal SerializedProperty TransmissionMode { get; }
        internal SerializedProperty ThicknessRemap { get; }
        internal SerializedProperty TexturingMode { get; }
        internal SerializedProperty SmoothnessMultipliers { get; }
        internal SerializedProperty LobeMix { get; }
        internal SerializedProperty DiffuseShadingPower { get; }
        internal SerializedProperty BorderAttenuationColor { get; }
        internal RenderTexture ProfileRT { get; }
        internal RenderTexture TransmittanceRT { get; }

        internal SerializedURPDiffusionProfileAsset(URPDiffusionProfileAsset asset, SerializedObject serializedObject)
        {
            Asset = asset;
            var profile = serializedObject.FindProperty("profile");
            ScatteringDistance = profile.FindPropertyRelative("scatteringDistance");
            ScatteringDistanceMultiplier = profile.FindPropertyRelative("scatteringDistanceMultiplier");
            WorldScale = profile.FindPropertyRelative("worldScale");
            IndexOfRefraction = profile.FindPropertyRelative("ior");
            TransmissionTint = profile.FindPropertyRelative("transmissionTint");
            TransmissionMode = profile.FindPropertyRelative("transmissionMode");
            ThicknessRemap = profile.FindPropertyRelative("thicknessRemap");
            TexturingMode = profile.FindPropertyRelative("texturingMode");
            SmoothnessMultipliers = profile.FindPropertyRelative("smoothnessMultipliers");
            LobeMix = profile.FindPropertyRelative("lobeMix");
            DiffuseShadingPower = profile.FindPropertyRelative("diffuseShadingPower");
            BorderAttenuationColor = profile.FindPropertyRelative("borderAttenuationColor");

            ProfileRT = new RenderTexture(256, 256, 0, GraphicsFormat.R16G16B16A16_SFloat);
            TransmittanceRT = new RenderTexture(16, 256, 0, GraphicsFormat.R16G16B16A16_SFloat);
        }

        public void Dispose()
        {
            CoreUtils.Destroy(ProfileRT);
            CoreUtils.Destroy(TransmittanceRT);
        }
    }
}
