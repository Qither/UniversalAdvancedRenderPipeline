using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace URPDiffusionProfile.EditorTools
{
    public sealed class LitGUI : ShaderGUI
    {
        private MaterialProperty _baseColor;
        private MaterialProperty _baseColorMap;
        private MaterialProperty _normalMap;
        private MaterialProperty _normalScale;
        private MaterialProperty _subsurfaceMask;
        private MaterialProperty _subsurfaceMaskMap;
        private MaterialProperty _transmissionMask;
        private MaterialProperty _transmissionMaskMap;
        private MaterialProperty _thickness;
        private MaterialProperty _thicknessMap;
        private MaterialProperty _thicknessRemap;
        private MaterialProperty _transmissionEnable;
        private MaterialProperty _diffusionProfileAsset;
        private MaterialProperty _diffusionProfileHash;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            FindProperties(properties);

            DrawSurfaceOptions(materialEditor);
            EditorGUILayout.Space();
            DrawSurfaceInputs(materialEditor);
            EditorGUILayout.Space();
            DrawTransmission(materialEditor);
            EditorGUILayout.Space();
            DrawAdvanced(materialEditor);

            foreach (var target in materialEditor.targets)
            {
                if (target is Material material)
                {
                    ValidateMaterial(material);
                }
            }
        }

        private void FindProperties(MaterialProperty[] properties)
        {
            _baseColor = FindProperty("_BaseColor", properties);
            _baseColorMap = FindProperty("_BaseColorMap", properties);
            _normalMap = FindProperty("_NormalMap", properties);
            _normalScale = FindProperty("_NormalScale", properties);
            _subsurfaceMask = FindProperty("_SubsurfaceMask", properties);
            _subsurfaceMaskMap = FindProperty("_SubsurfaceMaskMap", properties);
            _transmissionMask = FindProperty("_TransmissionMask", properties);
            _transmissionMaskMap = FindProperty("_TransmissionMaskMap", properties);
            _thickness = FindProperty("_Thickness", properties);
            _thicknessMap = FindProperty("_ThicknessMap", properties);
            _thicknessRemap = FindProperty("_ThicknessRemap", properties);
            _transmissionEnable = FindProperty("_TransmissionEnable", properties);
            _diffusionProfileAsset = FindProperty("_DiffusionProfileAsset", properties);
            _diffusionProfileHash = FindProperty("_DiffusionProfileHash", properties);
        }

        private void DrawSurfaceOptions(MaterialEditor materialEditor)
        {
            EditorGUILayout.LabelField("Surface Options", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                materialEditor.ShaderProperty(_transmissionEnable, "Transmission");
            }
        }

        private void DrawSurfaceInputs(MaterialEditor materialEditor)
        {
            EditorGUILayout.LabelField("Surface Inputs", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Base Color"), _baseColorMap, _baseColor);
                materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), _normalMap, _normalScale);
                materialEditor.TexturePropertySingleLine(new GUIContent("Subsurface Radius Map"), _subsurfaceMaskMap, _subsurfaceMask);
                if (DiffusionProfileMaterialUI.IsSupported(materialEditor))
                {
                    DiffusionProfileMaterialUI.OnGUI(materialEditor, _diffusionProfileAsset, _diffusionProfileHash);
                }
            }
        }

        private void DrawTransmission(MaterialEditor materialEditor)
        {
            EditorGUILayout.LabelField("Transmission", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Transmission Mask Map"), _transmissionMaskMap, _transmissionMask);
                materialEditor.TexturePropertySingleLine(new GUIContent("Thickness Map"), _thicknessMap, _thickness);
                materialEditor.VectorProperty(_thicknessRemap, "Thickness Remap");
            }
        }

        private void DrawAdvanced(MaterialEditor materialEditor)
        {
            EditorGUILayout.LabelField("Advanced Options", EditorStyles.boldLabel);
            using (new EditorGUI.IndentLevelScope())
            {
                materialEditor.RenderQueueField();
                materialEditor.EnableInstancingField();
                materialEditor.DoubleSidedGIField();
            }
        }

        private static void ValidateMaterial(Material material)
        {
            CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_SUBSURFACE_SCATTERING", material.GetFloat("_SubsurfaceMask") > 0.0f);
            CoreUtils.SetKeyword(material, "_MATERIAL_FEATURE_TRANSMISSION", material.GetFloat("_TransmissionEnable") > 0.0f);
        }
    }
}
