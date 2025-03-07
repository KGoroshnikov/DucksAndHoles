Shader "Shader Graphs/Hole1"
{
    Properties
    {
        _Speed("Speed", Float) = 1
        _NoiseScale("NoiseScale", Float) = 5
        _HoleRadius("HoleRadius", Float) = 0.7
        _MaskHardness("MaskHardness", Float) = 0.5
        _OutlineHardness("OutlineHardness", Float) = 0.4
        _NoiseRange("NoiseRange", Vector) = (-0.5, 0.5, 0, 0)
        _MainColor("MainColor", Color) = (0, 0, 0, 1)
        _OutlineColor("OutlineColor", Color) = (1, 1, 1, 1)
        [ToggleUI]_IsSphere("IsSphere", Float) = 1
        _RInnerSize("RInnerSize", Float) = 0.2
        _ROuterSize("ROuterSize", Float) = 0.4
        _ROutline("ROutline", Float) = 0.1
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 0
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 1
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 0
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
        }
        Stencil {
            Ref 1
            Comp NotEqual
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_b213462972894480920f87bd3d709e4e_Out_0_Float = _MaskHardness;
            float _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_b213462972894480920f87bd3d709e4e_Out_0_Float, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_R_1_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float);
            float _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float, _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float);
            float _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float;
            Unity_Clamp_float(_Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float, float(0), float(1), _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float);
            float4 _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4 = _MainColor;
            float4 _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float.xxxx), _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4, _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float;
            Unity_Subtract_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float4 _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4 = _OutlineColor;
            float4 _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float.xxxx), _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4);
            float4 _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4, _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.BaseColor = (_Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4.xyz);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite [_ZWrite]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP0;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP1;
            #endif
             float4 texCoord0 : INTERP2;
             float3 positionWS : INTERP3;
             float3 normalWS : INTERP4;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_b213462972894480920f87bd3d709e4e_Out_0_Float = _MaskHardness;
            float _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_b213462972894480920f87bd3d709e4e_Out_0_Float, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_R_1_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float);
            float _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float, _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float);
            float _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float;
            Unity_Clamp_float(_Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float, float(0), float(1), _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float);
            float4 _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4 = _MainColor;
            float4 _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float.xxxx), _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4, _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float;
            Unity_Subtract_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float4 _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4 = _OutlineColor;
            float4 _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float.xxxx), _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4);
            float4 _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4, _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.BaseColor = (_Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4.xyz);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Speed;
        float _NoiseScale;
        float _HoleRadius;
        float _MaskHardness;
        float2 _NoiseRange;
        float4 _MainColor;
        float _OutlineHardness;
        float4 _OutlineColor;
        float _RInnerSize;
        float _ROuterSize;
        float _IsSphere;
        float _ROutline;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        float2 Unity_GradientNoise_Deterministic_Dir_float(float2 p)
        {
            float x; Hash_Tchou_2_1_float(p, x);
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_Deterministic_float (float2 UV, float3 Scale, out float Out)
        {
            float2 p = UV * Scale.xy;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Deterministic_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void SphereMask_float2(float2 Coords, float2 Center, float Radius, float Hardness, out float Out)
        {
            Out = 1 - saturate((distance(Coords, Center) - Radius) / (1 - Hardness));
        }
        
        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A - B;
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Maximum_float(float A, float B, out float Out)
        {
            Out = max(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        struct Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float
        {
        half4 uv0;
        };
        
        void SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(float _RInnerSize, float _ROuterSize, float _ROutline, Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float IN, out float2 Out_Vector4_1)
        {
        float _Property_2252693489ad4269894cfa4003845323_Out_0_Float = _ROuterSize;
        float _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float = _RInnerSize;
        float4 _UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4 = IN.uv0;
        float4 _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4;
        Unity_Subtract_float4(_UV_ef7a53adb81947ddae47f6dfbe011d8b_Out_0_Vector4, float4(0.5, 0.5, 1, 1), _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4);
        float _Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[0];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[1];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_B_3_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[2];
        float _Split_58523661dfe84e01b5fb53885bc84b2f_A_4_Float = _Subtract_a5800cbd4d3c4252a973c3276f8b8a84_Out_2_Vector4[3];
        float _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_R_1_Float, _Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float);
        float _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float;
        Unity_Absolute_float(_Split_58523661dfe84e01b5fb53885bc84b2f_G_2_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float);
        float _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float;
        Unity_Maximum_float(_Absolute_a03e193a02724419b142f9131aec117f_Out_1_Float, _Absolute_f054ed5024bf49d896f6902792e3136f_Out_1_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float);
        float _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float;
        Unity_Smoothstep_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float);
        float _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float = _ROutline;
        float _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float;
        Unity_Add_float(_Property_2252693489ad4269894cfa4003845323_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float);
        float _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float;
        Unity_Add_float(_Property_597b07555a0d487ba45a9fe82db98ac9_Out_0_Float, _Property_d8845cccc6fb4d82bdbeffb0bff85ffe_Out_0_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float);
        float _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float;
        Unity_Smoothstep_float(_Add_4bd34cb7ed514624a6729a9c7f1f63bb_Out_2_Float, _Add_a0d54f1b8a844c4c835a883e8348f9c8_Out_2_Float, _Maximum_2ab7516ec96e459ca0c9a566ce94c15b_Out_2_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        float2 _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2 = float2(_Smoothstep_2153b3261b2344ec91f142dc996d740e_Out_3_Float, _Smoothstep_47f7c7791d064a39a30225fcd2fdf840_Out_3_Float);
        Out_Vector4_1 = _Vector2_dcca42d8c0cb47918ec61b61bcd3c192_Out_0_Vector2;
        }
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Step_float(float Edge, float In, out float Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Blend_Overwrite_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            Out = lerp(Base, Blend, Opacity);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float = _Speed;
            float _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float;
            Unity_Multiply_float_float(_Property_3b0f7f1719854bb389e159d11c857085_Out_0_Float, IN.TimeParameters.x, _Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float);
            float2 _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_55c9ca7f9ad04a63ae8acf9be3382f65_Out_2_Float.xx), _TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2);
            float _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float = _NoiseScale;
            float _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_8d5a311195ff41109cac9847bf1bc4d0_Out_3_Vector2, _Property_83bb13084ebd4e67a87a4d4ab395823f_Out_0_Float, _GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float);
            float2 _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2 = _NoiseRange;
            float _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float;
            Unity_Remap_float(_GradientNoise_fb7ea48b1db84944b09fa9fe57f68785_Out_2_Float, float2 (-1, 1), _Property_ea191b8a4e824c7cbc5c505036882fca_Out_0_Vector2, _Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float);
            float _Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean = _IsSphere;
            float2 _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2);
            float _Property_b213462972894480920f87bd3d709e4e_Out_0_Float = _MaskHardness;
            float _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_b213462972894480920f87bd3d709e4e_Out_0_Float, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float);
            float _Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float = _RInnerSize;
            float _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float = _ROuterSize;
            float _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float = _ROutline;
            Bindings_RectangleMask_e1162f732917c2244a46a1190ea7a822_float _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec;
            _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec.uv0 = IN.uv0;
            float2 _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2;
            SG_RectangleMask_e1162f732917c2244a46a1190ea7a822_float(_Property_48e1382531a24aaa9caac5449ada8173_Out_0_Float, _Property_3b132e3e1907433db05d0e02ba8e41ff_Out_0_Float, _Property_0b89cd705a62490b9c07d8ec0998d27c_Out_0_Float, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec, _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2);
            float _Split_db19fdd654524f0e98298aea649521d0_R_1_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[0];
            float _Split_db19fdd654524f0e98298aea649521d0_G_2_Float = _RectangleMask_9c2f670fec85462f9d8cff2aa6f72fec_OutVector4_1_Vector2[1];
            float _Split_db19fdd654524f0e98298aea649521d0_B_3_Float = 0;
            float _Split_db19fdd654524f0e98298aea649521d0_A_4_Float = 0;
            float _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_2cc9392a79ae4b40afd4b10f934571e2_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_R_1_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float);
            float _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_3c177ec776ce4bbaa46e32f9c341645f_Out_3_Float, _Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float);
            float _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float;
            Unity_Clamp_float(_Step_d5a1d88475b048f8bc570915ca8cc272_Out_2_Float, float(0), float(1), _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float);
            float4 _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4 = _MainColor;
            float4 _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float.xxxx), _Property_3d5cbf043bba4e74b0a8c9a2ed81d781_Out_0_Vector4, _Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4);
            float _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float = _OutlineHardness;
            float _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float;
            SphereMask_float2(_TilingAndOffset_b598cc6c1f8b49ca965ec07777f1bc0a_Out_3_Vector2, float2(0.5, 0.5), float(0), _Property_4ba9b807a17c499e8ad6418e84c44b9b_Out_0_Float, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float);
            float _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float;
            Unity_Branch_float(_Property_9a1aee1e29ad41b9a326f764771ece2e_Out_0_Boolean, _SphereMask_ac731a761a444765b875e40daedfa321_Out_4_Float, _Split_db19fdd654524f0e98298aea649521d0_G_2_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float);
            float _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float;
            Unity_Step_float(_Remap_6ea43a6a6ceb4782a71d6570a4d5925b_Out_3_Float, _Branch_2cbf2ee17731447cb78972c9f8f7c5d6_Out_3_Float, _Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float);
            float _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float;
            Unity_Subtract_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _Clamp_785b006ad0b741a9b6aa5ae486e9c430_Out_3_Float, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float4 _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4 = _OutlineColor;
            float4 _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4;
            Unity_Multiply_float4_float4((_Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float.xxxx), _Property_c61bfd18c72d4543baba4ccd91b55da5_Out_0_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4);
            float4 _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4;
            Unity_Blend_Overwrite_float4(_Multiply_81fa9a4003b44a9e958eaf148fb4f8d3_Out_2_Vector4, _Multiply_d6c986387e05438f843f88bf6e83757f_Out_2_Vector4, _Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4, _Subtract_3eabfb95235c4faab69f751d90721f3f_Out_2_Float);
            float _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            Unity_OneMinus_float(_Step_ef27f8bc8e5a4744921a3b9887baab63_Out_2_Float, _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float);
            surface.BaseColor = (_Blend_f53c066e552b4bed9417ea683b7f0892_Out_2_Vector4.xyz);
            surface.Alpha = float(0.5);
            surface.AlphaClipThreshold = _OneMinus_bb523d395ba44a1392fbfb3adad26915_Out_1_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}