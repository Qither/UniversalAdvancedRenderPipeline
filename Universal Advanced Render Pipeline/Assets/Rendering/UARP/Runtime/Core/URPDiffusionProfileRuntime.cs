using System.Collections.Generic;
using URPDiffusionProfile.Runtime.Materials;
using UnityEngine;

namespace URPDiffusionProfile.Runtime.Core
{
    public static class URPDiffusionProfileRuntime
    {
        private static readonly List<SSSMaterialBinder> s_Binders = new();
        private static URPDiffusionProfileRegistry s_Registry;

        public static URPDiffusionProfileRegistry EnsureRegistry(URPDiffusionProfileSettings settings)
        {
            s_Registry ??= new URPDiffusionProfileRegistry();
            s_Registry.Configure(settings);
            return s_Registry;
        }

        public static IReadOnlyList<SSSMaterialBinder> CollectBinders()
        {
            s_Binders.Clear();
            var binders = Object.FindObjectsByType<SSSMaterialBinder>(FindObjectsSortMode.None);
            foreach (var binder in binders)
            {
                if (binder != null && binder.isActiveAndEnabled)
                {
                    s_Binders.Add(binder);
                }
            }

            return s_Binders;
        }
    }
}
