using URPDiffusionProfile.Runtime.Core;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace URPDiffusionProfile.Runtime.Renderer.Passes
{
    public sealed class DiffusionProfileUploadPass : ScriptableRenderPass
    {
        private readonly ProfilingSampler m_ProfilingSampler = new("Diffusion Profile Upload");
        private URPDiffusionProfileSettings m_Settings;

        public DiffusionProfileUploadPass()
        {
            renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
        }

        public void Setup(URPDiffusionProfileSettings settings)
        {
            m_Settings = settings;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (renderingData.cameraData.isPreviewCamera)
            {
                return;
            }

            var registry = URPDiffusionProfileRuntime.EnsureRegistry(m_Settings);
            registry.BeginFrame(renderingData.cameraData.camera);
            var binders = URPDiffusionProfileRuntime.CollectBinders();
            registry.RegisterBinders(binders);
            registry.BuildGpuData(out var data0, out var data1, out var data2, out var data3);

            var cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                cmd.SetGlobalVectorArray(URPDiffusionProfileIDs.SSSProfileData0, data0);
                cmd.SetGlobalVectorArray(URPDiffusionProfileIDs.SSSProfileData1, data1);
                cmd.SetGlobalVectorArray(URPDiffusionProfileIDs.SSSProfileData2, data2);
                cmd.SetGlobalVectorArray(URPDiffusionProfileIDs.SSSProfileData3, data3);
                cmd.SetGlobalFloat(URPDiffusionProfileIDs.SSSProfileCount, registry.ActiveProfileCount);
                cmd.SetGlobalVector(
                    URPDiffusionProfileIDs.SSSSettings,
                    new Vector4(
                        m_Settings != null && m_Settings.enableHalfResolution ? 1f : 0f,
                        m_Settings != null && m_Settings.enableNormalAwareRejection ? 1f : 0f,
                        m_Settings != null ? m_Settings.resolveKernelSize : 9,
                        m_Settings != null && m_Settings.enableDeferredCompatibility ? 1f : 0f));
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }
}
