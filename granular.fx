#include "value.fx"
#include "func.fx"
#include "SandPBR.fx"

//HeightMap Tex
#define heightmap g_tex_0
#define normalmap g_tex_1

struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;

    float3 vNormal : NORMAL;
    float3 vTangent : TANGENT;
    float3 vBinormal : BINORMAL;

    float4 vWeights : BLENDWEIGHT;
    float4 vIndices : BLENDINDICES;
};


struct Granular_VS_OUT
{
    float3 vLocalPos : POSITION;
    float2 vUV : TEXCOORD;

    float3 vWorldPos : POSITION1;

};

//==========================================================

Granular_VS_OUT VS_Granular(VS_IN _in)
{
    Granular_VS_OUT output = (Granular_VS_OUT)0.f;

    
    output.vLocalPos = _in.vPos;
    output.vUV = _in.vUV;

    output.vWorldPos = mul(float4(output.vLocalPos, 1.f), g_matWorld).xyz;

    return output;
}



//=====================================


// ===========
// Hull Shader
// ===========
// Patch Constant Function
// 패치의 분할 횟수를 지정하는 함수
struct PatchOutput
{
    float Edges[3] : SV_TessFactor;
    float Inside : SV_InsideTessFactor;
};


// LOD : Level Of Detail
PatchOutput PatchConstFunc(InputPatch<Granular_VS_OUT, 3> _input
    , uint PatchID : SV_PrimitiveID)
{
    PatchOutput output = (PatchOutput)0.f;

    int dev = 16;

    output.Edges[0] = dev;
    output.Edges[1] = dev;
    output.Edges[2] = dev;
    output.Inside = dev;


    return output;
}

struct HS_OUT
{
    float3 vLocalPos : POSITION;
    float2 vUV : TEXCOORD;
};

[domain("tri")]
[partitioning("integer")]   // 정수, 실수
//[partitioning("fractional_odd")] // 정수, 실수
[outputtopology("triangle_cw")]
[outputcontrolpoints(3)]
[patchconstantfunc("PatchConstFunc")]
[maxtessfactor(64)]
HS_OUT HS_Granular(InputPatch<Granular_VS_OUT, 3> _input
    , uint i : SV_OutputControlPointID
    , uint PatchID : SV_PrimitiveID)
{
    HS_OUT output = (HS_OUT)0.f;

    output.vLocalPos = _input[i].vLocalPos;
    output.vUV = _input[i].vUV;

    return output;
}

struct DS_OUT
{
    float4 pos : SV_Position;

    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float3 normalDirection : TEXCOORD3;
    float3 worldPos : TEXCOORD4;
    float3 objectPos : TEXCOORD5;
};


[domain("tri")]
DS_OUT DS_Granular(const OutputPatch<HS_OUT, 3> _origin
    , float3 _vWeight : SV_DomainLocation
    , PatchOutput _patchtess)
{
    DS_OUT output = (DS_OUT)0.f;

    float3 vLocalPos = (float3)0.f;
    float2 vUV = (float2)0.f;

    for (int i = 0; i < 3; ++i)
    {
        vLocalPos += _origin[i].vLocalPos * _vWeight[i];
        vUV += _origin[i].vUV * _vWeight[i];

    }    

    
    if (g_btex_1)
    {
        float3 vNormal = normalmap.SampleLevel(g_sam_0, vUV,0).xyz;

        // 0 ~ 1 범위의 값을 -1 ~ 1 로 확장        
        vNormal = vNormal * 2.f - 1.f;

        float3x3 vRotateMat =
        {
            float3(1,0,0),
            float3(0,0,1),
            float3(0,1,0)
        };

        output.normalDirection = normalize(mul(vNormal, vRotateMat));
    }
    

    output.pos = mul(float4(vLocalPos, 1.f), g_matWVP);    
    //output.normalDirection = float3(0, 1, 0);
    output.worldPos = mul(float4(vLocalPos, 1.f), g_matWorld).xyz;
    output.objectPos = vLocalPos;    
    output.uv0 = vUV;
    output.uv1 = vUV;

    return output;
}

//==============================================================================


float4 PS_Granular(DS_OUT i) : SV_Target
{
    float3 _WorldSpaceCameraPos = mul(float4(0,0,0,1.f), g_matViewInv).xyz;

    int _LightIdx = 0;
    tLightInfo LightInfo = g_Light3DBuffer[_LightIdx];    

   // Distance to eye from point
   float pointDistance = length(i.worldPos.xyz - _WorldSpaceCameraPos.xyz);

   // Normal and light direction calculations
   float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
   float3 lightDirection = -normalize(LightInfo.vWorldDir.xyz); 

   return CalculateSandColor(lightDirection, viewDirection, i.normalDirection, i.objectPos.xyz, pointDistance);

}