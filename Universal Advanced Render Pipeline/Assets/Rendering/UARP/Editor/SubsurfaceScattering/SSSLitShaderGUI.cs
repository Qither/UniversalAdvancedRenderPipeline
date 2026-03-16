using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using UnityEditor.Rendering;
using UnityEditor.Rendering.Universal.ShaderGUI;

namespace UARP.Rendering.SubsurfaceScattering.Editor
{
    /// <summary>
    /// Custom ShaderGUI for SSSLit shader with Diffusion Profile support
    /// </summary>
    public class SSSLitShaderGUI : BaseShaderGUI
    {
        /// <summary>
        /// Container for the text and tooltips used to display the shader.
        /// </summary>
        public static class Styles
        {
            // Subsurface Scattering section
            public static readonly GUIContent sssHeader = EditorGUIUtility.TrTextContent("Subsurface Scattering",
                "Configure subsurface scattering and transmission properties using a Diffusion Profile.");

            public static readonly GUIContent diffusionProfileText = EditorGUIUtility.TrTextContent("Diffusion Profile",
                "Specifies the Diffusion Profile asset that defines the scattering shape and transmission properties.");

            public static readonly GUIContent subsurfaceMaskText = EditorGUIUtility.TrTextContent("Subsurface Mask",
                "Specifies the Subsurface mask map (R) for this Material and controls the overall strength of the subsurface scattering effect.");

            public static readonly GUIContent transmissionMaskText = EditorGUIUtility.TrTextContent("Transmission Mask",
                "Specifies the Transmission mask map (R) for this Material and controls the overall strength of the transmission effect.");

            public static readonly GUIContent thicknessText = EditorGUIUtility.TrTextContent("Thickness",
                "Controls the strength of the Thickness Map, low values allow some light to transmit through the object.");

            public static readonly GUIContent thicknessMapText = EditorGUIUtility.TrTextContent("Thickness Map",
                "Specifies the Thickness Map (R) for this Material - This map describes the thickness of the object. When subsurface scattering is enabled, low values allow some light to transmit through the object.");

            public static readonly GUIContent transmissionHeader = EditorGUIUtility.TrTextContent("Transmission",
                "Configure light transmission through the surface.");

            // Warnings
            public static readonly string diffusionProfileNotAssigned = "The Diffusion Profile on this material is not assigned. Please assign a Diffusion Profile asset.";
            
            public static readonly GUIContent diffusionProfileInfo = new GUIContent(
                "Profile Info", 
                "Information about the selected Diffusion Profile.");
        }

        /// <summary>
        /// Container for SSS-specific properties.
        /// </summary>
        public struct SSSProperties
        {
            // Diffusion Profile
            public MaterialProperty diffusionProfileAsset;
            public MaterialProperty diffusionProfileHash;
            
            // SSS parameters
            public MaterialProperty subsurfaceMask;
            public MaterialProperty subsurfaceMaskMap;
            
            // Transmission parameters
            public MaterialProperty transmissionMask;
            public MaterialProperty transmissionMaskMap;
            public MaterialProperty thickness;
            public MaterialProperty thicknessMap;

            public SSSProperties(MaterialProperty[] properties)
            {
                diffusionProfileAsset = BaseShaderGUI.FindProperty(SSSShaderIDs.DiffusionProfileAsset, properties, false);
                diffusionProfileHash = BaseShaderGUI.FindProperty(SSSShaderIDs.DiffusionProfileHash, properties, false);
                subsurfaceMask = BaseShaderGUI.FindProperty(SSSShaderIDs.SubsurfaceMask, properties, false);
                subsurfaceMaskMap = BaseShaderGUI.FindProperty(SSSShaderIDs.SubsurfaceMaskMap, properties, false);
                transmissionMask = BaseShaderGUI.FindProperty(SSSShaderIDs.TransmissionMask, properties, false);
                transmissionMaskMap = BaseShaderGUI.FindProperty(SSSShaderIDs.TransmissionMaskMap, properties, false);
                thickness = BaseShaderGUI.FindProperty(SSSShaderIDs.Thickness, properties, false);
                thicknessMap = BaseShaderGUI.FindProperty(SSSShaderIDs.ThicknessMap, properties, false);
            }
        }

        // Properties
        private LitGUI.LitProperties litProperties;
        private SSSProperties sssProperties;

        // Foldout states
        private static bool sssFoldout = true;

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new LitGUI.LitProperties(properties);
            sssProperties = new SSSProperties(properties);
        }

        public override void DrawSurfaceOptions(Material material)
        {
            base.DrawSurfaceOptions(material);
        }

        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            LitGUI.Inputs(litProperties, materialEditor, material);
            DrawEmissionProperties(material, true);
            DrawTileOffset(materialEditor, baseMapProp);
        }

        public override void DrawAdvancedOptions(Material material)
        {
            base.DrawAdvancedOptions(material);
        }

        public override void FillAdditionalFoldouts(MaterialHeaderScopeList materialScopesList)
        {
            materialScopesList.RegisterHeaderScope(Styles.sssHeader, (uint)Expandable.Details + 1, DrawSSSInputs);
        }

        /// <summary>
        /// Draws the Subsurface Scattering section
        /// </summary>
        /// <param name="material"></param>
        public void DrawSSSInputs(Material material)
        {
            if (sssProperties.diffusionProfileHash == null || sssProperties.diffusionProfileAsset == null)
            {
                return;
            }

            string guid = ConvertVector4ToGUID(sssProperties.diffusionProfileAsset.vectorValue);
            DiffusionProfileSettings profile = AssetDatabase.LoadAssetAtPath<DiffusionProfileSettings>(
                AssetDatabase.GUIDToAssetPath(guid)
            );

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = sssProperties.diffusionProfileAsset.hasMixedValue;
            
            var newProfile = (DiffusionProfileSettings)EditorGUILayout.ObjectField(
                Styles.diffusionProfileText,
                profile,
                typeof(DiffusionProfileSettings),
                false
            );
            
            EditorGUI.showMixedValue = false;

            if (EditorGUI.EndChangeCheck())
            {
                // Update profile reference
                Vector4 newGuid = Vector4.zero;
                float hash = 0;

                if (newProfile != null)
                {
                    // Ensure profile is valid
                    if (newProfile.profile == null)
                    {
                        newProfile.profile = new DiffusionProfile(true);
                    }
                    newProfile.profile.Validate();
                    newProfile.UpdateCache();

                    string assetPath = AssetDatabase.GetAssetPath(newProfile);
                    guid = AssetDatabase.AssetPathToGUID(assetPath);
                    newGuid = ConvertGUIDToVector4(guid);
                    hash = Asfloat(newProfile.profile.hash);
                }

                sssProperties.diffusionProfileAsset.vectorValue = newGuid;
                sssProperties.diffusionProfileHash.floatValue = hash;
                
                // Mark material as dirty
                EditorUtility.SetDirty(material);
                materialEditor.Repaint();
            }

            DrawDiffusionProfileWarning(newProfile ?? profile);

            if (sssProperties.subsurfaceMask != null && sssProperties.subsurfaceMaskMap != null)
            {
                materialEditor.TexturePropertySingleLine(Styles.subsurfaceMaskText, sssProperties.subsurfaceMaskMap, sssProperties.subsurfaceMask);
            }
            
            if (sssProperties.transmissionMask != null && sssProperties.transmissionMaskMap != null)
            {
                materialEditor.TexturePropertySingleLine(Styles.transmissionMaskText, sssProperties.transmissionMaskMap, sssProperties.transmissionMask);
            }
            
            if (sssProperties.thickness != null && sssProperties.thicknessMap != null)
            {
                materialEditor.TexturePropertySingleLine(Styles.thicknessText, sssProperties.thicknessMap, sssProperties.thickness);
            }
        }

        private void DrawDiffusionProfileWarning(DiffusionProfileSettings profile)
        {
            if (profile == null)
            {
                EditorGUILayout.HelpBox(Styles.diffusionProfileNotAssigned, MessageType.Error);
            }
        }

        public override void ValidateMaterial(Material material)
        {
            // Use base implementation which calls SetMaterialKeywords properly
            SetMaterialKeywords(material, LitGUI.SetMaterialKeywords);
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            // Clear all keywords for fresh start
            if (material == null)
            {
                return;
            }

            // Clear old shader keywords
            material.shaderKeywords = null;

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            // Setup material with Lit + SSS keywords
            SetMaterialKeywords(material, LitGUI.SetMaterialKeywords);
        }

        public override void OnOpenGUI(Material material, MaterialEditor materialEditor)
        {
            base.OnOpenGUI(material, materialEditor);
        }

        /// <summary>
        /// Sets up keywords for the material based on current property values.
        /// Wrapper for SSS-specific keyword setup.
        /// </summary>
        public static void SetMaterialKeywords(Material material, System.Action<Material> shadingModelFunc = null)
        {
            // Call base implementation which handles all standard keywords including _EMISSION
            BaseShaderGUI.SetMaterialKeywords(material, shadingModelFunc, SetSSSKeywords);
        }

        /// <summary>
        /// Setup SSS-specific keywords
        /// </summary>
        private static void SetSSSKeywords(Material material)
        {
            if (material.HasProperty("_SubsurfaceMaskMap"))
            {
                bool hasSubsurfaceMaskMap = material.GetTexture("_SubsurfaceMaskMap") != null;
                CoreUtils.SetKeyword(material, "_SUBSURFACE_MASK_MAP", hasSubsurfaceMaskMap);
            }

            if (material.HasProperty("_TransmissionMaskMap"))
            {
                bool hasTransmissionMaskMap = material.GetTexture("_TransmissionMaskMap") != null;
                CoreUtils.SetKeyword(material, "_TRANSMISSION_MASK_MAP", hasTransmissionMaskMap);
            }

            if (material.HasProperty("_ThicknessMap"))
            {
                bool hasThicknessMap = material.GetTexture("_ThicknessMap") != null;
                CoreUtils.SetKeyword(material, "_THICKNESS_MAP", hasThicknessMap);
            }
        }

        private static Vector4 ConvertGUIDToVector4(string guid)
        {
            if (string.IsNullOrEmpty(guid))
            {
                return Vector4.zero;
            }

            try
            {
                Vector4 vector;
                byte[] bytes = System.Guid.Parse(guid).ToByteArray();
                
                // Convert uint to float using Asfloat to preserve exact bits
                uint x = System.BitConverter.ToUInt32(bytes, 0);
                uint y = System.BitConverter.ToUInt32(bytes, 4);
                uint z = System.BitConverter.ToUInt32(bytes, 8);
                uint w = System.BitConverter.ToUInt32(bytes, 12);
                
                vector.x = Asfloat(x);
                vector.y = Asfloat(y);
                vector.z = Asfloat(z);
                vector.w = Asfloat(w);
                
                return vector;
            }
            catch (System.Exception e)
            {
                Debug.LogWarning($"Failed to convert GUID to Vector4: {e.Message}");
                return Vector4.zero;
            }
        }

        private static string ConvertVector4ToGUID(Vector4 vector)
        {
            if (vector == Vector4.zero)
            {
                return string.Empty;
            }

            try
            {
                byte[] bytes = new byte[16];
                
                // Convert float back to uint using Asuint to preserve exact bits
                uint x = Asuint(vector.x);
                uint y = Asuint(vector.y);
                uint z = Asuint(vector.z);
                uint w = Asuint(vector.w);
                
                System.BitConverter.GetBytes(x).CopyTo(bytes, 0);
                System.BitConverter.GetBytes(y).CopyTo(bytes, 4);
                System.BitConverter.GetBytes(z).CopyTo(bytes, 8);
                System.BitConverter.GetBytes(w).CopyTo(bytes, 12);
                
                return new System.Guid(bytes).ToString("N");
            }
            catch (System.Exception e)
            {
                Debug.LogWarning($"Failed to convert Vector4 to GUID: {e.Message}");
                return string.Empty;
            }
        }

        // Convert uint to float without changing bit representation
        private static float Asfloat(uint value)
        {
            return System.BitConverter.ToSingle(System.BitConverter.GetBytes(value), 0);
        }

        // Convert float to uint without changing bit representation
        private static uint Asuint(float value)
        {
            return System.BitConverter.ToUInt32(System.BitConverter.GetBytes(value), 0);
        }
    }
}

