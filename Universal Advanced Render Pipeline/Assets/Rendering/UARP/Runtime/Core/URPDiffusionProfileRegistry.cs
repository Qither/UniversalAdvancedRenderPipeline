using System.Collections.Generic;
using URPDiffusionProfile.Runtime.Materials;
using UnityEngine;

namespace URPDiffusionProfile.Runtime.Core
{
    public sealed class URPDiffusionProfileRegistry
    {
        private readonly Dictionary<URPDiffusionProfileAsset, int> m_ProfileToIndex = new();
        private readonly List<URPDiffusionProfileAsset> m_Profiles = new();
        private URPDiffusionProfileSettings m_Settings;

        public int MaxActiveProfiles => Mathf.Max(2, m_Settings != null ? m_Settings.maxActiveProfiles : 8);
        public int ActiveProfileCount => m_Profiles.Count;

        public void Configure(URPDiffusionProfileSettings settings)
        {
            m_Settings = settings;
        }

        public void BeginFrame(Camera camera)
        {
            m_ProfileToIndex.Clear();
            m_Profiles.Clear();
            m_Profiles.Add(null);
            m_ProfileToIndex[null] = 0;
        }

        public int Register(URPDiffusionProfileAsset profile)
        {
            if (m_ProfileToIndex.TryGetValue(profile, out var existingIndex))
            {
                return existingIndex;
            }

            if (m_Profiles.Count >= MaxActiveProfiles)
            {
                return 0;
            }

            var index = m_Profiles.Count;
            m_Profiles.Add(profile);
            m_ProfileToIndex.Add(profile, index);
            return index;
        }

        public int GetIndex(URPDiffusionProfileAsset profile)
        {
            return m_ProfileToIndex.TryGetValue(profile, out var index) ? index : 0;
        }

        public void RegisterBinders(IReadOnlyList<SSSMaterialBinder> binders)
        {
            for (var i = 0; i < binders.Count; i++)
            {
                Register(binders[i].DiffusionProfile);
            }

            for (var i = 0; i < binders.Count; i++)
            {
                binders[i].ApplyRuntimeValues(GetIndex(binders[i].DiffusionProfile));
            }
        }

        public void BuildGpuData(out Vector4[] data0, out Vector4[] data1, out Vector4[] data2, out Vector4[] data3)
        {
            var count = MaxActiveProfiles;
            data0 = new Vector4[count];
            data1 = new Vector4[count];
            data2 = new Vector4[count];
            data3 = new Vector4[count];

            for (var i = 1; i < m_Profiles.Count; i++)
            {
                var profile = m_Profiles[i];
                if (profile == null)
                {
                    continue;
                }

                var gpu = profile.GetGpuData();
                data0[i] = gpu.data0;
                data1[i] = gpu.data1;
                data2[i] = gpu.data2;
                data3[i] = gpu.data3;
            }
        }
    }
}
