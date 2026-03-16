using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

#if UNITY_6000_0_OR_NEWER || UNITY_2023_2_OR_NEWER
using UnityEngine.Rendering.RenderGraphModule;

namespace UARP.Rendering.SubsurfaceScattering
{
    /// <summary>
    /// RenderGraph path for Subsurface Scattering (Unity 6+)
    /// </summary>
    public partial class SubsurfaceScatteringPass
    {
        // PassData for RenderGraph
        private class PassData
        {
            internal RendererListHandle rendererList;
        }

        // SSS Filtering PassData
        private class SSSFilteringPassData
        {
            internal ComputeShader subsurfaceScatteringCS;
            internal ComputeShader subsurfaceScatteringDownsampleCS;
            internal int subsurfaceScatteringKernel;
            internal int packDiffusionProfileKernel;
            internal int subsurfaceScatteringDownsampleKernel;
            
            internal TextureHandle colorBuffer;
            internal TextureHandle diffuseBuffer;
            internal TextureHandle sssBuffer;
            internal TextureHandle depthTexture;
            internal TextureHandle downsampleBuffer;
            internal TextureHandle filteringBuffer;
            internal TextureHandle diffusionProfileIndexTexture;
            internal BufferHandle coarseStencilBuffer;
            internal Vector4 coarseStencilBufferSize;
            
            internal int sampleBudget;
            internal int downsampleSteps;
            internal bool subsurfaceScatteringAttenuation;
            
            internal int numTilesX;
            internal int numTilesY;
            internal int viewCount;
            internal Vector2 viewportSize;
        }
        
        // Coarse Stencil PassData
        private class CoarseStencilPassData
        {
            internal ComputeShader resolveStencilCS;
            internal int resolveStencilKernel;
            internal TextureHandle depthStencilBuffer;
            internal BufferHandle coarseStencilBuffer;
            internal TextureHandle resolvedStencilBuffer;
            internal TextureHandle resolvedDepthBuffer;
            internal int coarseStencilWidth;
            internal int coarseStencilHeight;
            internal int viewCount;
            internal int msaaSamples;
            internal bool resolveIsNecessary;
            internal bool resolveOnly;
            internal Vector4 coarseStencilBufferSize;
        }

        // Combine Lighting PassData
        private class CombineLightingPassData
        {
            internal Material combineLightingMaterial;
            internal TextureHandle colorBuffer;
            internal TextureHandle filteringBuffer;
            internal TextureHandle depthStencilBuffer;
            internal TextureHandle cameraDepthTexture;
        }

        /// <summary>
        /// RenderGraph rendering path - Captures split lighting and performs SSS filtering
        /// </summary>
        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
            UniversalLightData lightData = frameData.Get<UniversalLightData>();
            UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();

            // Render SSSBuffer pass and get its textures
            TextureHandle diffuseTexture;
            TextureHandle sssBufferTexture;
            RenderSSSBufferPass(renderGraph, cameraData, renderingData, lightData, resourceData, out diffuseTexture, out sssBufferTexture);

            // Step 2: Build coarse stencil buffer and resolve if needed
            BufferHandle coarseStencilBuffer = BufferHandle.nullHandle;
            TextureHandle resolvedStencilBuffer = TextureHandle.nullHandle;
            TextureHandle resolvedDepthBuffer = TextureHandle.nullHandle;
            Vector4 coarseStencilBufferSize;
            BuildCoarseStencilAndResolveIfNeeded(renderGraph, cameraData, resourceData.activeDepthTexture, 
                false, out coarseStencilBuffer, out resolvedStencilBuffer, out resolvedDepthBuffer, out coarseStencilBufferSize);

            // Determine which depth texture to use for SSS filtering
            // If MSAA is resolved, use the resolved depth buffer; otherwise, use the original depth texture
            TextureHandle depthTextureForSSS = resolvedDepthBuffer.IsValid() ? resolvedDepthBuffer : resourceData.activeDepthTexture;

            // Step 3: Perform SSS filtering
            TextureHandle filteringBuffer = RenderSubsurfaceScatteringScreenSpace(renderGraph, cameraData, resourceData.activeColorTexture, 
                diffuseTexture, sssBufferTexture, depthTextureForSSS, coarseStencilBuffer, coarseStencilBufferSize);

            // Step 4: Combine filtered diffuse lighting with color buffer
            if (m_CombineLightingMaterial != null && filteringBuffer.IsValid())
            {
                CombineLighting(renderGraph, cameraData, resourceData.activeColorTexture, filteringBuffer,
                    resourceData.activeDepthTexture, resourceData.cameraDepthTexture);
            }
        }

        /// <summary>
        /// Render the SSSBuffer MRT pass (SV_Target0: color/specular, SV_Target1: diffuse, SV_Target2: SSS buffer)
        /// </summary>
        private void RenderSSSBufferPass(
            RenderGraph renderGraph,
            UniversalCameraData cameraData,
            UniversalRenderingData renderingData,
            UniversalLightData lightData,
            UniversalResourceData resourceData,
            out TextureHandle diffuseTexture,
            out TextureHandle sssBufferTexture)
        {
            // Target 0: Use camera's active color texture for specular lighting (no temporary texture needed)
            // Target 1: Create temporary texture for diffuse lighting (will be blurred by SSS)
            // Target 2: Create temporary texture for SSS buffer (material data)
            RenderTextureDescriptor desc = cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0;
            // Keep MSAA samples from camera target - MRT requires all targets to have matching MSAA
            int msaaSamples = desc.msaaSamples;

            // Create textures with explicit clear to black - only SSS materials will write to these targets
            TextureDesc diffuseDesc = new TextureDesc(desc.width, desc.height);
            diffuseDesc.colorFormat = GraphicsFormat.B10G11R11_UFloatPack32;
            diffuseDesc.depthBufferBits = DepthBits.None;
            diffuseDesc.msaaSamples = (MSAASamples)msaaSamples;  // Match camera MSAA
            diffuseDesc.dimension = desc.dimension;
            diffuseDesc.clearBuffer = true;
            diffuseDesc.clearColor = Color.black;
            diffuseDesc.bindTextureMS = desc.bindMS;
            diffuseDesc.enableRandomWrite = desc.enableRandomWrite;
            diffuseDesc.filterMode = FilterMode.Bilinear;
            diffuseDesc.name = SSSShaderIDs.SSSDiffuseLightingName;
            diffuseTexture = renderGraph.CreateTexture(diffuseDesc);

            TextureDesc sssBufferDesc = new TextureDesc(desc.width, desc.height);
            sssBufferDesc.colorFormat = GraphicsFormat.R8G8B8A8_SRGB;
            sssBufferDesc.depthBufferBits = DepthBits.None;
            sssBufferDesc.msaaSamples = (MSAASamples)msaaSamples;  // Match camera MSAA
            sssBufferDesc.dimension = desc.dimension;
            sssBufferDesc.clearBuffer = true;
            sssBufferDesc.clearColor = Color.black;
            sssBufferDesc.bindTextureMS = desc.bindMS;
            sssBufferDesc.enableRandomWrite = desc.enableRandomWrite;
            sssBufferDesc.filterMode = FilterMode.Point;
            sssBufferDesc.name = SSSShaderIDs.SSSBufferTextureName;
            sssBufferTexture = renderGraph.CreateTexture(sssBufferDesc);

            // Create renderer list for objects with "SSSBuffer" pass
            var sortingSettings = cameraData.defaultOpaqueSortFlags;
            var drawingSettings = RenderingUtils.CreateDrawingSettings(
                SSSShaderIDs.SSSBufferPass,
                renderingData, cameraData, lightData, sortingSettings);

            var rendererListParams = new RendererListParams(renderingData.cullResults, drawingSettings, m_FilteringSettings);
            RendererListHandle rendererList = renderGraph.CreateRendererList(rendererListParams);

            using (var builder = renderGraph.AddRasterRenderPass<PassData>(SSSShaderIDs.SSSBufferPassName, out var passData, m_SSSBufferSampler))
            {
                passData.rendererList = rendererList;

                builder.UseRendererList(rendererList);
                builder.SetRenderAttachment(resourceData.activeColorTexture, 0, AccessFlags.ReadWrite);
                builder.SetRenderAttachment(diffuseTexture, 1, AccessFlags.Write);
                builder.SetRenderAttachment(sssBufferTexture, 2, AccessFlags.Write);
                builder.SetRenderAttachmentDepth(resourceData.activeDepthTexture, AccessFlags.ReadWrite);  // Must be ReadWrite for ZWrite On to work

                builder.AllowPassCulling(false);
                builder.AllowGlobalStateModification(true);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) =>
                {
                    context.cmd.DrawRendererList(data.rendererList);
                });
            }
        }

        /// <summary>
        /// Build Coarse Stencil Buffer and Resolve If Needed
        /// This pass builds the coarse stencil buffer if requested (i.e. when resolveOnly: false) 
        /// and performs the MSAA resolve of the full res stencil buffer if needed (a pass requires it and MSAA is on).
        /// </summary>
        private void BuildCoarseStencilAndResolveIfNeeded(
            RenderGraph renderGraph,
            UniversalCameraData cameraData,
            TextureHandle depthStencilBuffer,
            bool resolveOnly,
            out BufferHandle coarseStencilBuffer,
            out TextureHandle resolvedStencilBuffer,
            out TextureHandle resolvedDepthBuffer,
            out Vector4 coarseStencilBufferSize)
        {

            using (var builder = renderGraph.AddComputePass<CoarseStencilPassData>(
                SSSShaderIDs.ResolveStencilPassName, out var passData, m_ResolveStencilSampler))
            {
                // Get MSAA information from camera descriptor
                bool MSAAEnabled = cameraData.cameraTargetDescriptor.msaaSamples > 1;
                int msaaSamples = cameraData.cameraTargetDescriptor.msaaSamples;

                // Calculate coarse stencil buffer dimensions (8x8 tile compression)
                int width = cameraData.cameraTargetDescriptor.width;
                int height = cameraData.cameraTargetDescriptor.height;
                int coarseStencilWidth = (width + 7) / 8;  // DivRoundUp(width, 8)
                int coarseStencilHeight = (height + 7) / 8;
                int viewCount = cameraData.xr.enabled ? cameraData.xr.viewCount : 1; // Support VR multi-view rendering

                // Store parameters
                passData.resolveOnly = resolveOnly;
                passData.coarseStencilWidth = coarseStencilWidth;
                passData.coarseStencilHeight = coarseStencilHeight;
                passData.viewCount = viewCount;
                passData.msaaSamples = msaaSamples;

                // With MSAA, SSS requires a copy of the stencil, if not active, no need to do the resolve.
                // (Simplified for URP - always resolve when MSAA is enabled)
                passData.resolveIsNecessary = MSAAEnabled;

                // Store coarse stencil buffer size for shader
                passData.coarseStencilBufferSize = new Vector4(
                    coarseStencilWidth,
                    coarseStencilHeight,
                    1.0f / coarseStencilWidth,
                    1.0f / coarseStencilHeight);

                // Setup compute shader and kernel
                passData.resolveStencilCS = m_ResolveStencilCS;
                passData.resolveStencilKernel = m_ResolveStencilKernel;

                // Input: depth-stencil texture
                passData.depthStencilBuffer = depthStencilBuffer;
                builder.UseTexture(passData.depthStencilBuffer, AccessFlags.Read);

                // Create coarse stencil buffer (persistent, not transient, to share between passes)
                int bufferSize = coarseStencilWidth * coarseStencilHeight * viewCount;
                passData.coarseStencilBuffer = renderGraph.CreateBuffer(
                    new BufferDesc(bufferSize, sizeof(uint), GraphicsBuffer.Target.Structured)
                    { name = SSSShaderIDs.CoarseStencilBufferName });
                builder.UseBuffer(passData.coarseStencilBuffer, AccessFlags.Write);

                // Create resolved stencil buffer if necessary (must match camera resolution)
                if (passData.resolveIsNecessary)
                {
                    passData.resolvedStencilBuffer = renderGraph.CreateTexture(
                        new TextureDesc(width, height)
                        {
                            dimension = TextureDimension.Tex2D,
                            slices = 1,
                            msaaSamples = MSAASamples.None,  // Resolved buffer is never MSAA
                            colorFormat = GraphicsFormat.R8G8_UInt,
                            depthBufferBits = DepthBits.None,
                            enableRandomWrite = true,
                            clearBuffer = false,
                            name = "StencilBufferResolved"
                        });
                    builder.UseTexture(passData.resolvedStencilBuffer, AccessFlags.Write);
                    
                    // Create resolved depth buffer (matching CopyDepthPass format)
                    passData.resolvedDepthBuffer = renderGraph.CreateTexture(
                        new TextureDesc(width, height)
                        {
                            dimension = TextureDimension.Tex2D,
                            slices = 1,
                            msaaSamples = MSAASamples.None,  // Resolved buffer is never MSAA
                            colorFormat = GraphicsFormat.R32_SFloat,
                            depthBufferBits = DepthBits.None,
                            enableRandomWrite = true,
                            clearBuffer = false,
                            name = "DepthBufferResolved"
                        });
                    builder.UseTexture(passData.resolvedDepthBuffer, AccessFlags.Write);
                }
                else
                {
                    passData.resolvedStencilBuffer = TextureHandle.nullHandle;
                    passData.resolvedDepthBuffer = TextureHandle.nullHandle;
                }

                // Allow modifying global state (for shader keywords)
                builder.AllowGlobalStateModification(true);

                // Set render function
                builder.SetRenderFunc((CoarseStencilPassData data, ComputeGraphContext context) =>
                {
                    // Early exit if resolveOnly and resolve is not necessary
                    if (data.resolveOnly && !data.resolveIsNecessary)
                        return;

                    var cmd = context.cmd;
                    ComputeShader cs = data.resolveStencilCS;

                    // Setup compute shader parameters
                    cmd.SetComputeVectorParam(cs, 
                        SSSShaderIDs._CoarseStencilBufferSize, data.coarseStencilBufferSize);
                    cmd.SetComputeBufferParam(cs, data.resolveStencilKernel, 
                        SSSShaderIDs._CoarseStencilBuffer, data.coarseStencilBuffer);
                    
                    cmd.SetComputeTextureParam(cs, data.resolveStencilKernel, 
                        SSSShaderIDs._StencilTexture, data.depthStencilBuffer, 0, RenderTextureSubElement.Stencil);

                    if (data.resolveIsNecessary)
                    {
                        cmd.SetComputeTextureParam(cs, data.resolveStencilKernel, 
                            SSSShaderIDs._DepthTexture, data.depthStencilBuffer, 0, RenderTextureSubElement.Depth);
                        cmd.SetComputeTextureParam(cs, data.resolveStencilKernel, 
                            SSSShaderIDs._OutputStencilBuffer, data.resolvedStencilBuffer);
                        cmd.SetComputeTextureParam(cs, data.resolveStencilKernel, 
                            SSSShaderIDs._OutputDepthBuffer, data.resolvedDepthBuffer);
                    }

                    // Setup MSAA keywords
                    cmd.DisableKeyword(cs, new LocalKeyword(cs, "MSAA2X"));
                    cmd.DisableKeyword(cs, new LocalKeyword(cs, "MSAA4X"));
                    cmd.DisableKeyword(cs, new LocalKeyword(cs, "MSAA8X"));

                    switch (data.msaaSamples)
                    {
                        case 2:
                            cmd.EnableKeyword(cs, new LocalKeyword(cs, "MSAA2X"));
                            break;
                        case 4:
                            cmd.EnableKeyword(cs, new LocalKeyword(cs, "MSAA4X"));
                            break;
                        case 8:
                            cmd.EnableKeyword(cs, new LocalKeyword(cs, "MSAA8X"));
                            break;
                    }

                    // Set COARSE_STENCIL and RESOLVE keywords
                    // COARSE_STENCIL is enabled when: not resolveIsNecessary OR not resolveOnly
                    cmd.SetKeyword(cs, new LocalKeyword(cs, "COARSE_STENCIL"), !data.resolveIsNecessary || !data.resolveOnly);
                    cmd.SetKeyword(cs, new LocalKeyword(cs, "RESOLVE"), data.resolveIsNecessary);

                    // Dispatch compute shader (one thread group per 8x8 tile)
                    cmd.DispatchCompute(cs, data.resolveStencilKernel, 
                        data.coarseStencilWidth, data.coarseStencilHeight, data.viewCount);
                });

                // Set output handles
                coarseStencilBuffer = passData.coarseStencilBuffer;
                resolvedStencilBuffer = passData.resolvedStencilBuffer;
                resolvedDepthBuffer = passData.resolvedDepthBuffer;
                coarseStencilBufferSize = passData.coarseStencilBufferSize;
            }
        }

        /// <summary>
        /// Performs downsample (optional), SSS filtering, and returns filtering buffer for combine pass
        /// </summary>
        private TextureHandle RenderSubsurfaceScatteringScreenSpace(
            RenderGraph renderGraph,
            UniversalCameraData cameraData,
            TextureHandle colorBuffer,
            TextureHandle diffuseBuffer,
            TextureHandle sssBuffer,
            TextureHandle depthTexture,
            BufferHandle coarseStencilBuffer,
            Vector4 coarseStencilBufferSize)
        {
            using (var builder = renderGraph.AddComputePass<SSSFilteringPassData>(
                SSSShaderIDs.SSSFilteringPassName, out var passData, m_SSSFilteringSampler))
            {
                // Setup compute shaders
                passData.subsurfaceScatteringCS = m_SubsurfaceScatteringCS;
                passData.subsurfaceScatteringDownsampleCS = m_SubsurfaceScatteringDownsampleCS;
                passData.subsurfaceScatteringKernel = m_SubsurfaceScatteringKernel;
                passData.packDiffusionProfileKernel = m_PackDiffusionProfileKernel;
                passData.subsurfaceScatteringDownsampleKernel = m_SubsurfaceScatteringDownsampleKernel;

                // Quality settings
                passData.sampleBudget = m_SampleBudget;
                passData.downsampleSteps = m_DownsampleSteps;
                passData.subsurfaceScatteringAttenuation = m_SubsurfaceScatteringAttenuation;

                // Calculate tile count (16x16 thread groups)
                passData.numTilesX = ((int)cameraData.cameraTargetDescriptor.width + 15) / 16;
                passData.numTilesY = ((int)cameraData.cameraTargetDescriptor.height + 15) / 16;
                passData.viewCount = cameraData.xr.enabled ? cameraData.xr.viewCount : 1; // Support VR multi-view rendering
                passData.viewportSize = new Vector2(cameraData.cameraTargetDescriptor.width, cameraData.cameraTargetDescriptor.height);

                // Setup input textures
                passData.colorBuffer = colorBuffer;
                passData.diffuseBuffer = diffuseBuffer;
                passData.sssBuffer = sssBuffer;
                passData.depthTexture = depthTexture;
                passData.coarseStencilBuffer = coarseStencilBuffer;
                
                // Use pre-calculated coarse stencil buffer size (calculated once in BuildCoarseStencilAndResolveIfNeeded)
                passData.coarseStencilBufferSize = coarseStencilBufferSize;
                
                // Declare texture usage
                builder.UseTexture(passData.colorBuffer, AccessFlags.ReadWrite);
                builder.UseTexture(passData.diffuseBuffer, AccessFlags.Read);
                builder.UseTexture(passData.sssBuffer, AccessFlags.Read);
                builder.UseTexture(passData.depthTexture, AccessFlags.Read);
                
                // Declare coarse stencil buffer usage
                if (passData.coarseStencilBuffer.IsValid())
                {
                    builder.UseBuffer(passData.coarseStencilBuffer, AccessFlags.Read);
                }

                // Create downsample buffer if needed
                if (passData.downsampleSteps > 0)
                {
                    float scale = 1.0f / (1u << passData.downsampleSteps);
                    int downsampleWidth = Mathf.Max(1, (int)(cameraData.cameraTargetDescriptor.width * scale));
                    int downsampleHeight = Mathf.Max(1, (int)(cameraData.cameraTargetDescriptor.height * scale));
                    
                    TextureDesc downsampleDesc = new TextureDesc(downsampleWidth, downsampleHeight);
                    downsampleDesc.colorFormat = GraphicsFormat.B10G11R11_UFloatPack32;
                    downsampleDesc.depthBufferBits = DepthBits.None;
                    downsampleDesc.msaaSamples = MSAASamples.None;
                    downsampleDesc.dimension = TextureDimension.Tex2D;
                    downsampleDesc.enableRandomWrite = true;
                    downsampleDesc.clearBuffer = true;  // Clear to avoid residual data
                    downsampleDesc.clearColor = Color.clear;
                    downsampleDesc.filterMode = FilterMode.Bilinear;
                    downsampleDesc.name = SSSShaderIDs.SSSDownsampledTextureName;
                    
                    passData.downsampleBuffer = renderGraph.CreateTexture(downsampleDesc);
                    builder.UseTexture(passData.downsampleBuffer, AccessFlags.ReadWrite);
                }

                // Create temporary filtering buffer for SSS result (URP always uses temporary buffer)
                // IMPORTANT: Must clear to avoid residual data from previous frames
                TextureDesc filteringDesc = new TextureDesc(cameraData.cameraTargetDescriptor.width, cameraData.cameraTargetDescriptor.height);
                filteringDesc.colorFormat = GraphicsFormat.B10G11R11_UFloatPack32;
                filteringDesc.depthBufferBits = DepthBits.None;
                filteringDesc.msaaSamples = MSAASamples.None;
                filteringDesc.dimension = TextureDimension.Tex2D;
                filteringDesc.enableRandomWrite = true;
                filteringDesc.clearBuffer = true;  // Clear to avoid residual data
                filteringDesc.clearColor = Color.clear;
                filteringDesc.filterMode = FilterMode.Bilinear;
                filteringDesc.name = SSSShaderIDs.SSSFilteringTextureName;
                
                passData.filteringBuffer = renderGraph.CreateTexture(filteringDesc);
                builder.UseTexture(passData.filteringBuffer, AccessFlags.ReadWrite);

                // Create diffusion profile index texture if occlusion is enabled
                if (passData.subsurfaceScatteringAttenuation)
                {
                    RenderTextureDescriptor profileIndexDesc = cameraData.cameraTargetDescriptor;
                    profileIndexDesc.width = Mathf.Max(1, profileIndexDesc.width / 2);
                    profileIndexDesc.height = profileIndexDesc.height;
                    profileIndexDesc.depthBufferBits = 0;
                    profileIndexDesc.msaaSamples = 1;
                    profileIndexDesc.enableRandomWrite = true;
                    profileIndexDesc.graphicsFormat = GraphicsFormat.R8_UInt;
                    
                    passData.diffusionProfileIndexTexture = UniversalRenderer.CreateRenderGraphTexture(
                        renderGraph, profileIndexDesc, SSSShaderIDs.SSSProfileIndexTextureName, false);
                    builder.UseTexture(passData.diffusionProfileIndexTexture, AccessFlags.ReadWrite);
                }

                // Set render function
                builder.SetRenderFunc((SSSFilteringPassData data, ComputeGraphContext context) =>
                {
                    ExecuteSSSFiltering(data, context);
                });

                // Return filtering buffer for combine pass
                return passData.filteringBuffer;
            }
        }

        /// <summary>
        /// Execute SSS filtering compute shader
        /// </summary>
        private static void ExecuteSSSFiltering(SSSFilteringPassData data, ComputeGraphContext context)
        {
            var cmd = context.cmd;

            CoreUtils.SetKeyword(data.subsurfaceScatteringCS, "USE_DOWNSAMPLE", data.downsampleSteps > 0);
            CoreUtils.SetKeyword(data.subsurfaceScatteringCS, "USE_SSS_OCCLUSION", data.subsurfaceScatteringAttenuation);

            // Step 1: Downsample if enabled
            if (data.downsampleSteps > 0)
            {
                int shift = data.downsampleSteps - 1;
                
                // Set frame count for random sampling in downsample shader
                cmd.SetComputeIntParam(data.subsurfaceScatteringDownsampleCS, 
                    SSSShaderIDs._FrameCount, Time.frameCount);
                cmd.SetComputeIntParam(data.subsurfaceScatteringDownsampleCS, 
                    SSSShaderIDs._SssDownsampleSteps, data.downsampleSteps);
                cmd.SetComputeTextureParam(data.subsurfaceScatteringDownsampleCS, 
                    data.subsurfaceScatteringDownsampleKernel, SSSShaderIDs._SourceTexture, data.diffuseBuffer);
                cmd.SetComputeTextureParam(data.subsurfaceScatteringDownsampleCS, 
                    data.subsurfaceScatteringDownsampleKernel, SSSShaderIDs._OutputTexture, data.downsampleBuffer);
                
                // Dispatch downsample compute
                cmd.DispatchCompute(data.subsurfaceScatteringDownsampleCS, 
                    data.subsurfaceScatteringDownsampleKernel,
                    Mathf.Max(1, data.numTilesX >> shift),
                    Mathf.Max(1, data.numTilesY >> shift),
                    data.viewCount);
            }

            // Step 2: Setup main SSS compute parameters
            cmd.SetComputeIntParam(data.subsurfaceScatteringCS, 
                SSSShaderIDs._SssSampleBudget, data.sampleBudget);
            cmd.SetComputeIntParam(data.subsurfaceScatteringCS, 
                SSSShaderIDs._SssDownsampleSteps, data.downsampleSteps);

            // Step 3: Bind input textures
            cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel, SSSShaderIDs._DepthTexture, data.depthTexture);
            cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel, SSSShaderIDs._IrradianceSource, data.diffuseBuffer);
            
            if (data.downsampleSteps > 0 && data.downsampleBuffer.IsValid())
            {
                cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                    data.subsurfaceScatteringKernel, SSSShaderIDs._IrradianceSourceDownsampled, data.downsampleBuffer);
            }
            
            cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel, SSSShaderIDs.SSSBufferTexture, data.sssBuffer);

            // Bind coarse stencil buffer for tile-based early rejection
            cmd.SetComputeVectorParam(data.subsurfaceScatteringCS, 
                SSSShaderIDs._CoarseStencilBufferSize, data.coarseStencilBufferSize);
            cmd.SetComputeBufferParam(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel, SSSShaderIDs._CoarseStencilBuffer, data.coarseStencilBuffer);

            // Step 4: Pack diffusion profile indices if occlusion is enabled
            if (data.subsurfaceScatteringAttenuation && data.diffusionProfileIndexTexture.IsValid())
            {
                cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                    data.packDiffusionProfileKernel, SSSShaderIDs._DiffusionProfileIndexTexture, data.diffusionProfileIndexTexture);
                cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                    data.packDiffusionProfileKernel, SSSShaderIDs.SSSBufferTexture, data.sssBuffer);
                
                int xGroupCount = (int)Mathf.Ceil(data.viewportSize.x / 2.0f / 8.0f);
                int yGroupCount = (int)Mathf.Ceil(data.viewportSize.y / 8.0f);
                
                cmd.DispatchCompute(data.subsurfaceScatteringCS, 
                    data.packDiffusionProfileKernel,
                    xGroupCount, yGroupCount, data.viewCount);
            }

            // Bind diffusion profile index texture
            if (data.subsurfaceScatteringAttenuation && data.diffusionProfileIndexTexture.IsValid())
            {
                cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                    data.subsurfaceScatteringKernel, SSSShaderIDs._DiffusionProfileIndexTexture, data.diffusionProfileIndexTexture);
            }
            else
            {
                // Set black texture as fallback when occlusion is disabled
                cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                    data.subsurfaceScatteringKernel, SSSShaderIDs._DiffusionProfileIndexTexture, data.diffuseBuffer);
            }

            // Step 5: Execute main SSS filtering
            // URP always uses temporary filtering buffer for proper compositing
            cmd.SetComputeTextureParam(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel, SSSShaderIDs._CameraFilteringTexture, data.filteringBuffer);
            
            // Dispatch SSS filtering compute
            cmd.DispatchCompute(data.subsurfaceScatteringCS, 
                data.subsurfaceScatteringKernel,
                data.numTilesX, data.numTilesY, data.viewCount);
        }

        /// <summary>
        /// Combine filtered diffuse lighting with color buffer using additive blend
        /// </summary>
        private void CombineLighting(
            RenderGraph renderGraph,
            UniversalCameraData cameraData,
            TextureHandle colorBuffer,
            TextureHandle filteringBuffer,
            TextureHandle depthStencilBuffer,
            TextureHandle cameraDepthTexture)
        {
            using (var builder = renderGraph.AddRasterRenderPass<CombineLightingPassData>(
                SSSShaderIDs.SSSCombineLightingPassName, out var passData, m_CombineLightingSampler))
            {
                // Setup pass data
                passData.combineLightingMaterial = m_CombineLightingMaterial;
                passData.colorBuffer = colorBuffer;
                passData.filteringBuffer = filteringBuffer;
                passData.depthStencilBuffer = depthStencilBuffer;
                passData.cameraDepthTexture = cameraDepthTexture;

                // Declare texture usage
                builder.SetRenderAttachment(passData.colorBuffer, 0, AccessFlags.ReadWrite);
                builder.SetRenderAttachmentDepth(passData.depthStencilBuffer, AccessFlags.Read);
                builder.UseTexture(passData.filteringBuffer, AccessFlags.Read);
                builder.UseTexture(passData.cameraDepthTexture, AccessFlags.Read);

                // Allow global state modification (for blend state)
                builder.AllowGlobalStateModification(true);

                // Set render function
                builder.SetRenderFunc((CombineLightingPassData data, RasterGraphContext context) =>
                {
                    var cmd = context.cmd;
                    data.combineLightingMaterial.SetTexture(SSSShaderIDs._IrradianceSource, data.filteringBuffer);
                    Blitter.BlitTexture(cmd, data.filteringBuffer, new Vector4(1, 1, 0, 0), data.combineLightingMaterial, 0);
                });
            }
        }
    }
}
#endif
