using System.Collections.Generic;
using System.Linq;
using URPDiffusionProfile.Runtime.Core;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace URPDiffusionProfile.EditorTools
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(URPDiffusionProfileAsset))]
    public sealed class URPDiffusionProfileAssetEditor : UnityEditor.Editor
    {
        private const string DiffusionPreviewShaderPath =
            "Assets/Rendering/UARP/Editor/Preview/Hidden_URP_DrawDiffusionProfile.shader";
        private const string TransmittancePreviewShaderPath =
            "Assets/Rendering/UARP/Editor/Preview/Hidden_URP_DrawTransmittanceGraph.shader";

        private static class Styles
        {
            public static readonly GUIContent ScatteringLabel = EditorGUIUtility.TrTextContent("Scattering");
            public static readonly GUIContent ProfileScatteringColor = EditorGUIUtility.TrTextContent("Scattering Color", "Controls the shape of the Diffusion Profile, and should be similar to the diffuse color of the Material.");
            public static readonly GUIContent ProfileScatteringDistanceMultiplier = EditorGUIUtility.TrTextContent("Multiplier", "Acts as a multiplier on the scattering color to control how far light travels below the surface, and controls the effective radius of the filter.");
            public static readonly GUIContent ProfileTransmissionTint = EditorGUIUtility.TrTextContent("Transmission Tint", "Specifies the tint of the translucent lighting transmitted through objects.");
            public static readonly GUIContent ProfileMaxRadius = EditorGUIUtility.TrTextContent("Max Radius", "The maximum radius of the effect you define in Scattering Color and Multiplier.\nWhen the world scale is 1, this value is in millimeters.");
            public static readonly GUIContent ProfileWorldScale = EditorGUIUtility.TrTextContent("World Scale", "Controls the scale of Unity's world units for this Diffusion Profile.");
            public static readonly GUIContent ProfileIor = EditorGUIUtility.TrTextContent("Index of Refraction", "Controls the refractive behavior of the Material, where larger values increase the intensity of specular reflection.");
            public static readonly GUIContent SubsurfaceScatteringLabel = EditorGUIUtility.TrTextContent("Subsurface Scattering only");
            public static readonly GUIContent DualLobeMultipliers = EditorGUIUtility.TrTextContent("Dual Lobe Multipliers", "Mutlipliers for the smoothness of the two specular lobes");
            public static readonly GUIContent TransmissionLabel = EditorGUIUtility.TrTextContent("Transmission only");
            public static readonly GUIContent ProfileTransmissionMode = EditorGUIUtility.TrTextContent("Transmission Mode", "Specifies how HDRP calculates light transmission.");
            public static readonly GUIContent ProfileMinMaxThickness = EditorGUIUtility.TrTextContent("Thickness Remap Values (Min-Max)", "Sets the range of thickness values (in millimeters) corresponding to the [0, 1] range of texel values stored in the Thickness Map.");
            public static readonly GUIContent ProfileThicknessRemap = EditorGUIUtility.TrTextContent("Thickness Remap (Min-Max)", "Sets the range of thickness values (in millimeters) corresponding to the [0, 1] range of texel values stored in the Thickness Map.");
            public static readonly GUIContent ProfilePreview0 = EditorGUIUtility.TrTextContent("Diffusion Profile Preview");
            public static readonly GUIContent ProfilePreview1 = EditorGUIUtility.TrTextContent("Displays the fraction of lights scattered from the source located in the center.");
            public static readonly GUIContent TransmittancePreview0 = EditorGUIUtility.TrTextContent("Transmittance Preview");
            public static readonly GUIContent TransmittancePreview1 = EditorGUIUtility.TrTextContent("Displays the fraction of light passing through the GameObject depending on the values from the Thickness Remap (mm).");
            public static GUIStyle MiniBoldButton => s_MiniBoldButton.Value;

            private static readonly System.Lazy<GUIStyle> s_MiniBoldButton = new(() => new GUIStyle(GUI.skin.label)
            {
                alignment = TextAnchor.MiddleCenter,
                fontSize = 10,
                fontStyle = FontStyle.Bold,
            });
        }

        private Material m_ProfileMaterial;
        private Material m_TransmittanceMaterial;
        private SerializedURPDiffusionProfileAsset m_SerializedProfile;
        private List<URPDiffusionProfileAsset> m_TargetProfiles;
        private bool m_MultipleObjectSelected;

        private void OnEnable()
        {
            m_ProfileMaterial = CreatePreviewMaterial(DiffusionPreviewShaderPath, "Hidden/URP/DrawDiffusionProfile");
            m_TransmittanceMaterial = CreatePreviewMaterial(TransmittancePreviewShaderPath, "Hidden/URP/DrawTransmittanceGraph");
            m_SerializedProfile = new SerializedURPDiffusionProfileAsset((URPDiffusionProfileAsset)target, serializedObject);
            m_TargetProfiles = targets.Cast<URPDiffusionProfileAsset>().ToList();
            m_MultipleObjectSelected = targets.Length > 1;

            Undo.undoRedoPerformed += UpdateProfile;
        }

        private void OnDisable()
        {
            Undo.undoRedoPerformed -= UpdateProfile;

            m_SerializedProfile?.Dispose();
            CoreUtils.Destroy(m_ProfileMaterial);
            CoreUtils.Destroy(m_TransmittanceMaterial);
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            if (m_ProfileMaterial == null || m_TransmittanceMaterial == null)
            {
                EditorGUILayout.HelpBox(
                    "Preview shaders could not be loaded. Reimport the preview shaders and check the Console for shader import errors.",
                    MessageType.Error);
            }

            DrawScattering(m_MultipleObjectSelected);
            DrawIORAndScale();
            DrawSSS();
            DrawTransmission();

            serializedObject.ApplyModifiedProperties();

            foreach (var profile in m_TargetProfiles)
            {
                UpdateProfile(profile);
            }

            if (!m_MultipleObjectSelected)
            {
                RenderPreview();
            }
        }

        public override bool HasPreviewGUI()
        {
            return !m_MultipleObjectSelected && target is URPDiffusionProfileAsset;
        }

        public override GUIContent GetPreviewTitle()
        {
            return Styles.ProfilePreview0;
        }

        public override void OnPreviewGUI(Rect r, GUIStyle background)
        {
            if (m_MultipleObjectSelected || m_ProfileMaterial == null)
            {
                return;
            }

            var profile = m_SerializedProfile.Asset;
            m_ProfileMaterial.SetFloat("_MaxRadius", profile.FilterRadius);
            m_ProfileMaterial.SetVector("_ShapeParam", profile.ShapeParamAndMaxScatterDist);
            EditorGUI.DrawPreviewTexture(r, m_SerializedProfile.ProfileRT, m_ProfileMaterial, ScaleMode.StretchToFill, 1f);
        }

        private void DrawScattering(bool multipleObjectSelected)
        {
            EditorGUILayout.LabelField(Styles.ScatteringLabel, EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                using (new EditorGUI.MixedValueScope(m_SerializedProfile.ScatteringDistance.hasMultipleDifferentValues))
                using (var changeCheckScope = new EditorGUI.ChangeCheckScope())
                {
                    var color = EditorGUILayout.ColorField(
                        Styles.ProfileScatteringColor,
                        m_SerializedProfile.ScatteringDistance.colorValue.gamma,
                        true,
                        false,
                        false);

                    if (changeCheckScope.changed)
                    {
                        m_SerializedProfile.ScatteringDistance.colorValue = color.linear;
                    }
                }

                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.PropertyField(
                        m_SerializedProfile.ScatteringDistanceMultiplier,
                        Styles.ProfileScatteringDistanceMultiplier);
                }

                if (!multipleObjectSelected)
                {
                    using (new EditorGUI.DisabledScope(true))
                    {
                        EditorGUILayout.FloatField(Styles.ProfileMaxRadius, m_SerializedProfile.Asset.FilterRadius);
                    }
                }
            }

            EditorGUILayout.Space();
        }

        private void DrawIORAndScale()
        {
            EditorGUILayout.Slider(m_SerializedProfile.IndexOfRefraction, 1f, 2f, Styles.ProfileIor);
            EditorGUILayout.PropertyField(m_SerializedProfile.WorldScale, Styles.ProfileWorldScale);
            EditorGUILayout.Space();
        }

        private void DrawSSS()
        {
            EditorGUILayout.LabelField(Styles.SubsurfaceScatteringLabel, EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                EditorGUILayout.PropertyField(m_SerializedProfile.TexturingMode);
                DrawSmoothnessMultipliers();
                EditorGUILayout.PropertyField(m_SerializedProfile.LobeMix);
                EditorGUILayout.PropertyField(m_SerializedProfile.DiffuseShadingPower);
                EditorGUILayout.PropertyField(m_SerializedProfile.BorderAttenuationColor);
            }

            EditorGUILayout.Space();
        }

        private void DrawTransmission()
        {
            EditorGUILayout.LabelField(Styles.TransmissionLabel, EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                EditorGUILayout.PropertyField(m_SerializedProfile.TransmissionMode, Styles.ProfileTransmissionMode);
                EditorGUILayout.PropertyField(m_SerializedProfile.TransmissionTint, Styles.ProfileTransmissionTint);
                EditorGUILayout.PropertyField(m_SerializedProfile.ThicknessRemap, Styles.ProfileMinMaxThickness);

                if (!m_SerializedProfile.ThicknessRemap.hasMultipleDifferentValues)
                {
                    using (var changeCheckScope = new EditorGUI.ChangeCheckScope())
                    {
                        var thicknessRemap = m_SerializedProfile.ThicknessRemap.vector2Value;
                        EditorGUILayout.MinMaxSlider(
                            Styles.ProfileThicknessRemap,
                            ref thicknessRemap.x,
                            ref thicknessRemap.y,
                            0f,
                            50f);

                        if (changeCheckScope.changed)
                        {
                            m_SerializedProfile.ThicknessRemap.vector2Value = thicknessRemap;
                        }
                    }
                }
            }

            EditorGUILayout.Space();
        }

        private void DrawSmoothnessMultipliers()
        {
            var multipliers = m_SerializedProfile.SmoothnessMultipliers.vector2Value;
            var minLimit = 0f;
            var maxLimit = 2f;
            var midLevel = (minLimit + maxLimit) * 0.5f;
            const float fieldWidth = 65f;
            const float padding = 4f;

            var rect = EditorGUILayout.GetControlRect();
            rect = EditorGUI.PrefixLabel(rect, Styles.DualLobeMultipliers);

            EditorGUI.showMixedValue = m_SerializedProfile.SmoothnessMultipliers.hasMultipleDifferentValues;
            EditorGUI.BeginChangeCheck();

            if (rect.width >= 3f * fieldWidth + 2f * padding)
            {
                rect.xMin -= 15f * EditorGUI.indentLevel;
                var tmpRect = new Rect(rect)
                {
                    width = fieldWidth,
                };

                EditorGUI.BeginChangeCheck();
                var leftValue = EditorGUI.FloatField(tmpRect, multipliers.x);
                if (EditorGUI.EndChangeCheck())
                {
                    multipliers.x = Mathf.Clamp(leftValue, minLimit, midLevel);
                }

                tmpRect.x = rect.xMax - fieldWidth;
                EditorGUI.BeginChangeCheck();
                var rightValue = EditorGUI.FloatField(tmpRect, multipliers.y);
                if (EditorGUI.EndChangeCheck())
                {
                    multipliers.y = Mathf.Clamp(rightValue, midLevel, maxLimit);
                }

                tmpRect.xMin = rect.xMin + (fieldWidth + padding);
                tmpRect.xMax = rect.xMax - (EditorGUIUtility.fieldWidth + padding);
                rect = tmpRect;
            }

            rect.width = (rect.width - padding) * 0.5f;
            EditorGUI.BeginChangeCheck();
            var minSlider = GUI.HorizontalSlider(rect, multipliers.x, minLimit, midLevel);
            if (EditorGUI.EndChangeCheck())
            {
                multipliers.x = minSlider;
            }

            rect.x += rect.width + padding - 1f;
            EditorGUI.BeginChangeCheck();
            var maxSlider = GUI.HorizontalSlider(rect, multipliers.y, midLevel, maxLimit);
            if (EditorGUI.EndChangeCheck())
            {
                multipliers.y = maxSlider;
            }

            if (EditorGUI.EndChangeCheck())
            {
                m_SerializedProfile.SmoothnessMultipliers.vector2Value = multipliers;
            }

            EditorGUI.showMixedValue = false;
        }

        private void RenderPreview()
        {
            var profile = m_SerializedProfile.Asset;
            var shape = profile.ShapeParamAndMaxScatterDist;

            EditorGUILayout.LabelField(Styles.ProfilePreview0, Styles.MiniBoldButton);
            EditorGUILayout.LabelField(Styles.ProfilePreview1, EditorStyles.centeredGreyMiniLabel);
            EditorGUILayout.Space();

            if (m_ProfileMaterial != null)
            {
                m_ProfileMaterial.SetFloat("_MaxRadius", profile.FilterRadius);
                m_ProfileMaterial.SetVector("_ShapeParam", shape);
                EditorGUI.DrawPreviewTexture(
                    GUILayoutUtility.GetRect(256f, 256f),
                    m_SerializedProfile.ProfileRT,
                    m_ProfileMaterial,
                    ScaleMode.ScaleToFit,
                    1f);
            }
            else
            {
                EditorGUILayout.HelpBox("Diffusion profile preview shader is unavailable.", MessageType.Error);
                GUILayoutUtility.GetRect(256f, 256f);
            }

            EditorGUILayout.Space();
            EditorGUILayout.LabelField(Styles.TransmittancePreview0, Styles.MiniBoldButton);
            EditorGUILayout.LabelField(Styles.TransmittancePreview1, EditorStyles.centeredGreyMiniLabel);
            EditorGUILayout.Space();

            if (m_TransmittanceMaterial != null)
            {
                m_TransmittanceMaterial.SetVector("_ShapeParam", shape);
                m_TransmittanceMaterial.SetVector(
                    "_TransmissionTint",
                    new Vector4(profile.TransmissionTint.r, profile.TransmissionTint.g, profile.TransmissionTint.b, 1f));
                m_TransmittanceMaterial.SetVector(
                    "_ThicknessRemap",
                    new Vector4(profile.ThicknessRemap.x, profile.ThicknessRemap.y, 0f, 0f));
                EditorGUI.DrawPreviewTexture(
                    GUILayoutUtility.GetRect(16f, 16f),
                    m_SerializedProfile.TransmittanceRT,
                    m_TransmittanceMaterial,
                    ScaleMode.ScaleToFit,
                    16f);
            }
            else
            {
                EditorGUILayout.HelpBox("Transmission preview shader is unavailable.", MessageType.Error);
                GUILayoutUtility.GetRect(16f, 16f);
            }
        }

        private void UpdateProfile()
        {
            UpdateProfile(m_SerializedProfile.Asset);
        }

        private static void UpdateProfile(URPDiffusionProfileAsset profile)
        {
            profile.Validate();
            EditorUtility.SetDirty(profile);
        }

        private static Material CreatePreviewMaterial(string assetPath, string shaderName)
        {
            var shader = AssetDatabase.LoadAssetAtPath<Shader>(assetPath);
            if (shader == null)
            {
                shader = Shader.Find(shaderName);
            }

            return shader != null ? CoreUtils.CreateEngineMaterial(shader) : null;
        }
    }
}
