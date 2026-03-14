using URPDiffusionProfile.Runtime.Core;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer.Passes
{
    public sealed class SubsurfaceScatteringCompositePass : ScriptableRenderPass
    {
        private readonly ProfilingSampler m_ProfilingSampler = new("Subsurface Scattering Composite");
        private readonly Material m_CompositeMaterial;
        private RTHandle m_DiffuseHandle;
        private RTHandle m_BlurredHandle;
        private RTHandle m_TemporaryColorHandle;

        public SubsurfaceScatteringCompositePass(Material compositeMaterial)
        {
            m_CompositeMaterial = compositeMaterial;
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing + 1;
        }

        public void Setup(RTHandle diffuseHandle, RTHandle blurredHandle)
        {
            m_DiffuseHandle = diffuseHandle;
            m_BlurredHandle = blurredHandle;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;
            RenderingUtils.ReAllocateHandleIfNeeded(ref m_TemporaryColorHandle, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_SSSCompositeTemp");
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_CompositeMaterial == null || m_DiffuseHandle == null || m_BlurredHandle == null)
            {
                return;
            }

            var renderer = renderingData.cameraData.renderer;
            var cameraColor = renderer.cameraColorTargetHandle;
            var cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSDiffuseTex, m_DiffuseHandle);
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSBlurredTex, m_BlurredHandle);
                Blitter.BlitCameraTexture(cmd, cameraColor, m_TemporaryColorHandle);
                Blitter.BlitCameraTexture(cmd, m_TemporaryColorHandle, cameraColor, m_CompositeMaterial, 0);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
