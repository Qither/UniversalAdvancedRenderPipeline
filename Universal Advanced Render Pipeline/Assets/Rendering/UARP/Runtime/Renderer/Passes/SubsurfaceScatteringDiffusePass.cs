using URPDiffusionProfile.Runtime.Core;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer.Passes
{
    public sealed class SubsurfaceScatteringDiffusePass : ScriptableRenderPass
    {
        private static readonly ShaderTagId k_ShaderTagId = new("SSSDiffuse");

        private readonly ProfilingSampler m_ProfilingSampler = new("Subsurface Scattering Diffuse");
        private RTHandle m_DiffuseHandle;

        public SubsurfaceScatteringDiffusePass()
        {
            renderPassEvent = RenderPassEvent.AfterRenderingOpaques + 1;
        }

        public RTHandle DiffuseHandle => m_DiffuseHandle;

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;
            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat;
            RenderingUtils.ReAllocateHandleIfNeeded(ref m_DiffuseHandle, descriptor, FilterMode.Bilinear, TextureWrapMode.Clamp, name: "_SSSDiffuseRT");

            ConfigureTarget(m_DiffuseHandle);
            ConfigureClear(ClearFlag.Color, Color.clear);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var sorting = renderingData.cameraData.defaultOpaqueSortFlags;
            var drawingSettings = CreateDrawingSettings(k_ShaderTagId, ref renderingData, sorting);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

            var cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();
                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (m_DiffuseHandle != null)
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSDiffuseTex, m_DiffuseHandle.nameID);
            }
        }
    }
}
