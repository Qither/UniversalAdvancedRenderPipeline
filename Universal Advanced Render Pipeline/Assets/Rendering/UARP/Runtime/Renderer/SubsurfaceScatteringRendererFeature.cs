using URPDiffusionProfile.Runtime.Core;
using URPDiffusionProfile.Runtime.Renderer.Passes;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer
{
    public sealed class SubsurfaceScatteringRendererFeature : ScriptableRendererFeature
    {
        [SerializeField] private bool m_FeatureEnabled = true;
        [SerializeField] private bool m_RunInSceneView = true;
        [SerializeField] private URPDiffusionProfileSettings m_Settings;

        private Material m_ResolveMaterial;
        private Material m_CompositeMaterial;

        private DiffusionProfileUploadPass m_ProfileUploadPass;
        private SubsurfaceScatteringMetadataPass m_MetadataPass;
        private SubsurfaceScatteringDiffusePass m_DiffusePass;
        private SubsurfaceScatteringResolvePass m_ResolvePass;
        private SubsurfaceScatteringCompositePass m_CompositePass;

        public override void Create()
        {
            m_ResolveMaterial = CreateMaterial("Hidden/URP/SubsurfaceScatteringResolve");
            m_CompositeMaterial = CreateMaterial("Hidden/URP/SubsurfaceScatteringComposite");

            m_ProfileUploadPass ??= new DiffusionProfileUploadPass();
            m_MetadataPass ??= new SubsurfaceScatteringMetadataPass();
            m_DiffusePass ??= new SubsurfaceScatteringDiffusePass();
            m_ResolvePass ??= new SubsurfaceScatteringResolvePass(m_ResolveMaterial);
            m_CompositePass ??= new SubsurfaceScatteringCompositePass(m_CompositeMaterial);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (!m_FeatureEnabled || renderingData.cameraData.isPreviewCamera)
            {
                return;
            }

            if (renderingData.cameraData.isSceneViewCamera && !m_RunInSceneView)
            {
                return;
            }

            if (m_ResolveMaterial == null || m_CompositeMaterial == null)
            {
                return;
            }

            m_ProfileUploadPass.Setup(m_Settings);
            m_ResolvePass.Setup(m_MetadataPass.MetadataHandle, m_MetadataPass.ProfileIndexHandle, m_DiffusePass.DiffuseHandle);
            m_CompositePass.Setup(m_DiffusePass.DiffuseHandle, m_ResolvePass.BlurredHandle);

            renderer.EnqueuePass(m_ProfileUploadPass);
            renderer.EnqueuePass(m_MetadataPass);
            renderer.EnqueuePass(m_DiffusePass);
            renderer.EnqueuePass(m_ResolvePass);
            renderer.EnqueuePass(m_CompositePass);
        }

        protected override void Dispose(bool disposing)
        {
            CoreUtils.Destroy(m_ResolveMaterial);
            CoreUtils.Destroy(m_CompositeMaterial);
        }

        private static Material CreateMaterial(string shaderName)
        {
            var shader = Shader.Find(shaderName);
            return shader != null ? CoreUtils.CreateEngineMaterial(shader) : null;
        }
    }
}
