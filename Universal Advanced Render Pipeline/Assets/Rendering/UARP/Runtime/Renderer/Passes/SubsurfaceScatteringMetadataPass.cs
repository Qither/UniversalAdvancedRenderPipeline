using URPDiffusionProfile.Runtime.Core;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer.Passes
{
    public sealed class SubsurfaceScatteringMetadataPass : ScriptableRenderPass
    {
        private static readonly ShaderTagId k_ShaderTagId = new("SSSMeta");

        private readonly ProfilingSampler m_ProfilingSampler = new("Subsurface Scattering Metadata");
        private RTHandle m_MetadataHandle;
        private RTHandle m_ProfileIndexHandle;

        public SubsurfaceScatteringMetadataPass()
        {
            renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        }

        public RTHandle MetadataHandle => m_MetadataHandle;
        public RTHandle ProfileIndexHandle => m_ProfileIndexHandle;

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.depthBufferBits = 0;
            descriptor.msaaSamples = 1;
            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16G16B16A16_SFloat;
            RenderingUtils.ReAllocateHandleIfNeeded(ref m_MetadataHandle, descriptor, FilterMode.Point, TextureWrapMode.Clamp, name: "_SSSMetadataRT");

            descriptor.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
            RenderingUtils.ReAllocateHandleIfNeeded(ref m_ProfileIndexHandle, descriptor, FilterMode.Point, TextureWrapMode.Clamp, name: "_SSSProfileIndexRT");

            ConfigureTarget(new[] { m_MetadataHandle, m_ProfileIndexHandle });
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
            if (m_MetadataHandle != null)
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSMetadataTex, m_MetadataHandle.nameID);
            }

            if (m_ProfileIndexHandle != null)
            {
                cmd.SetGlobalTexture(URPDiffusionProfileIDs.SSSProfileIndexTex, m_ProfileIndexHandle.nameID);
            }
        }
    }
}
