Shader "Shader Graphs/FogOfWar"
{
    Properties
    {
        _Color1("Color1", Color) = (0, 0, 0, 1)
        _Color2("Color2", Color) = (0.06603771, 0.06603771, 0.06603771, 1)
        _Clip("Clip", Float) = 0.1
        [NoScaleOffset]_RT_Particles("RT_Particles", 2D) = "white" {}
        _Speed("Speed", Float) = 1
        _NoiseScale("NoiseScale", Float) = 5
        _NoiseRange("NoiseRange", Vector) = (-0.5, 0.5, 0, 0)
        _RInnerSize("RInnerSize", Float) = 0.2
        _ROuterSize("ROuterSize", Float) = 0.4
        _SmoothDist("SmoothDist", Float) = 0
        _ROutline("ROutline", Float) = 0.1
        _P1("P1", Vector) = (0, 0, 0, 0)
        _P2("P2", Vector) = (0, 0, 0, 0)
        _P3("P3", Vector) = (0, 0, 0, 0)
        _P4("P4", Vector) = (0, 0, 0, 0)
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
        ZWrite off
        Stencil {
            Ref 1
            Comp always
            Pass replace
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
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
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.BaseColor = (_Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4.xyz);
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 positionWS;
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 positionWS;
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
             float3 AbsoluteWorldSpacePosition;
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
             float3 positionWS : INTERP1;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
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
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.BaseColor = (_Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4.xyz);
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 positionWS;
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
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
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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
        #define VARYINGS_NEED_POSITION_WS
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
             float3 positionWS;
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
             float3 AbsoluteWorldSpacePosition;
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
        float _SmoothDist;
        float2 _P1;
        float2 _P2;
        float2 _P3;
        float2 _P4;
        float2 _NoiseRange;
        float _Speed;
        float _NoiseScale;
        float _RInnerSize;
        float _ROuterSize;
        float _ROutline;
        float4 _Color1;
        float4 _Color2;
        float _Clip;
        float4 _RT_Particles_TexelSize;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_RT_Particles);
        SAMPLER(sampler_RT_Particles);
        
        // Graph Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"
        #include_with_pragmas "Assets/_Project/Graphics/Shaders/QuadMask.hlsl"
        
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
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_OneMinus_float4(float4 In, out float4 Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Step_float4(float4 Edge, float4 In, out float4 Out)
        {
            Out = step(Edge, In);
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
            float4 _Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4 = _Color1;
            float4 _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4 = _Color2;
            float _Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float = _Speed;
            float _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float;
            Unity_Multiply_float_float(_Property_1627a70f83bc4131b1cc2c19fac1a1f2_Out_0_Float, IN.TimeParameters.x, _Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float);
            float2 _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_1abb4145b42b47c787f30b59bf9a83c1_Out_2_Float.xx), _TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2);
            float _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float = _NoiseScale;
            float _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float;
            Unity_GradientNoise_Deterministic_float(_TilingAndOffset_eeb37c8dc9684ef2a493f386da224a4d_Out_3_Vector2, _Property_94d9d4f9497647829cbb195e14bee5e4_Out_0_Float, _GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float);
            float _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), float2 (0, 1), _Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float);
            float4 _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4;
            Unity_Lerp_float4(_Property_118cf34047e74c258a3206b84581d975_Out_0_Vector4, _Property_715cd5d22c6c403fa88798c6530b3d2b_Out_0_Vector4, (_Remap_fc93e337ced8432faafe3b375f6416f1_Out_3_Float.xxxx), _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4);
            float2 _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2 = _NoiseRange;
            float _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float;
            Unity_Remap_float(_GradientNoise_0c7e44cebf9e417c81d768141fa91208_Out_2_Float, float2 (-1, 1), _Property_6f97261e55464055a267dad7cc95ecd5_Out_0_Vector2, _Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float);
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float = IN.AbsoluteWorldSpacePosition[0];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_G_2_Float = IN.AbsoluteWorldSpacePosition[1];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float = IN.AbsoluteWorldSpacePosition[2];
            float _Split_538d90ebc5b74b4f96e51fd30b0aee49_A_4_Float = 0;
            float2 _Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2 = float2(_Split_538d90ebc5b74b4f96e51fd30b0aee49_R_1_Float, _Split_538d90ebc5b74b4f96e51fd30b0aee49_B_3_Float);
            float2 _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2 = _P1;
            float2 _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2 = _P2;
            float2 _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2 = _P3;
            float2 _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2 = _P4;
            float _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float = _SmoothDist;
            float _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float;
            GetInsideFactor_float(_Vector2_418bf94619db4438a2a9c6e8a4055ab3_Out_0_Vector2, _Property_05d1f26d69014c848ad9355ba53f5987_Out_0_Vector2, _Property_ebbca2b5b3e845b6926cc6f60d077774_Out_0_Vector2, _Property_d1d20e45c3c04593808c78e1c3b5de4a_Out_0_Vector2, _Property_9b57252c3d394199a5581ad0c7192d57_Out_0_Vector2, _Property_b7eba52c8fed43acaa4cbafac035d43c_Out_0_Float, _GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float);
            UnityTexture2D _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_RT_Particles);
              float4 _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.tex, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.samplerstate, _Property_c1c9af8e9aae47ab9d3205b9c791401b_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy), float(0));
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_R_5_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_G_6_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_B_7_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_A_8_Float = _SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4.a;
            float4 _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4;
            Unity_OneMinus_float4(_SampleTexture2DLOD_5c9f689ff1d74918b031cba63062a8ea_RGBA_0_Vector4, _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4);
            float4 _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4;
            Unity_Multiply_float4_float4((_GetInsideFactorCustomFunction_50302bf2fe0642c89db93523cb41c6e3_res_5_Float.xxxx), _OneMinus_33dafa6574d2459d8200dec61dbf7487_Out_1_Vector4, _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4);
            float4 _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4;
            Unity_Step_float4((_Remap_a354b957cb514be2a96ca58a1649b1ef_Out_3_Float.xxxx), _Multiply_590325aacfff435192271681bcdbfd09_Out_2_Vector4, _Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4);
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_R_1_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[0];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_G_2_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[1];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_B_3_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[2];
            float _Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float = _Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4[3];
            float4 _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Step_25aa498e99404ada84cfcd7440b8dbc2_Out_2_Vector4, (_Split_2b19b259fdcd41098c7654eb0d05c9e0_A_4_Float.xxxx), _Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4);
            float _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float = _Clip;
            surface.BaseColor = (_Lerp_78072a5c55ee4ca0b7f8f3d76a772869_Out_3_Vector4.xyz);
            surface.Alpha = (_Multiply_b3a8c8f6de984d9ab185c33b00126a8f_Out_2_Vector4).x;
            surface.AlphaClipThreshold = _Property_73c8778f2ff443dd93b270256fa1e4f2_Out_0_Float;
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
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
        
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