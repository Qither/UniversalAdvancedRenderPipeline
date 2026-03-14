using URPDiffusionProfile.Runtime.Core;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer.Passes
{
    public sealed class SubsurfaceScatteringResolvePass : ScriptableRenderPass
    {
        private readonly ProfilingSampler m_ProfilingSampler = new("Subsurface Scattering Resolve");
        private readonly Material m_ResolveMaterial;
        private RTHandle m_BlurredHandle;
        private RTHandle m_MetadataHandle;
        private RTHandle m_ProfileIndexHandle;
        private RTHandle m_DiffuseHandle;

        public SubsurfaceScatteringResolvePass(Material resolveMaterial)
        {
            m_ResolveMaterial = resolveMaterial;
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        }

        public RTHandle BlurredHandle => m_BlurredHandle;

        public void Setup(RTHandle metadataHandle, RTHandle profileIndexHandle, RTHandle diffuseHandle)
        {
            m_MetadataHandle = metadataHandle;
            m_ProfileIndexHandle = profileIndexHandle;
            m_DiffuseHandle = diffuseHandle;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;
            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat;
            RenderingUtils.ReAllocateHandleIfNeeded(ref m_BlurredHandle, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_SSSBlurredRT");
            ConfigureTarget(m_BlurredHandle);
            ConfigureClear(ClearFlag.Color, Color.clear);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_ResolveMaterial == null || m_MetadataHandle == null || m_DiffuseHandle == null)
            {
                return;
            }

            var cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSMetadataTex, m_MetadataHandle);
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSProfileIndexTex, m_ProfileIndexHandle);
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSDiffuseTex, m_DiffuseHandle);
                Blitter.BlitCameraTexture(cmd, m_DiffuseHandle, m_BlurredHandle, m_ResolveMaterial, 0);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (m_BlurredHandle != null)
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSBlurredTex, m_BlurredHandle.nameID);
            }
        }
    }
}
