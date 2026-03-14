using URPDiffusionProfile.Runtime.Core;
using UnityEngine;

namespace URPDiffusionProfile.Runtime.Materials
{
    [DisallowMultipleComponent]
    [RequireComponent(typeof(UnityEngine.Renderer))]
    public sealed class SSSMaterialBinder : MonoBehaviour
    {
        [SerializeField] private URPDiffusionProfileAsset m_DiffusionProfile;
        [Range(0f, 1f)]
        [SerializeField] private float m_SubsurfaceMask = 1f;
        [Min(0f)]
        [SerializeField] private float m_Thickness = 1f;
        [SerializeField] private Vector2 m_ThicknessRemap = new(0f, 1f);
        [Range(0f, 1f)]
        [SerializeField] private float m_TransmissionMask = 1f;
        [SerializeField] private bool m_TransmissionEnabled = true;

        private readonly MaterialPropertyBlock m_PropertyBlock = new();
        private UnityEngine.Renderer m_Renderer;

        public URPDiffusionProfileAsset DiffusionProfile => m_DiffusionProfile;

        private void Awake()
        {
            EnsureRenderer();
        }

        private void OnEnable()
        {
            EnsureRenderer();
            ApplyRuntimeValues(0);
        }

        private void OnValidate()
        {
            EnsureRenderer();
            ApplyRuntimeValues(0);
        }

        public void ApplyRuntimeValues(int profileIndex)
        {
            if (m_Renderer == null)
            {
                return;
            }

            m_Renderer.GetPropertyBlock(m_PropertyBlock);
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.DiffusionProfileIndex, profileIndex);
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.DiffusionProfileHash, m_DiffusionProfile != null ? m_DiffusionProfile.ProfileHash : 0f);
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.SubsurfaceMask, m_SubsurfaceMask);
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.Thickness, m_Thickness);
            m_PropertyBlock.SetVector(URPDiffusionProfileIDs.ThicknessRemap, new Vector4(m_ThicknessRemap.x, m_ThicknessRemap.y, 0f, 0f));
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.TransmissionMask, m_TransmissionMask);
            m_PropertyBlock.SetFloat(URPDiffusionProfileIDs.TransmissionEnable, m_TransmissionEnabled ? 1f : 0f);
            m_Renderer.SetPropertyBlock(m_PropertyBlock);
        }

        private void EnsureRenderer()
        {
            if (m_Renderer == null)
            {
                m_Renderer = GetComponent<UnityEngine.Renderer>();
            }
        }
    }
}
