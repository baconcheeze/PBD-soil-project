#ifndef _Soil
#define _Soil

#include "value.fx"
#include "func.fx"
#include "SandPBR.fx"

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

struct VS_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;

    float3 vLocalPos : LOCAL;
    float3 vViewPos : POSITION;
    float3 vWorldPos : World;
    float3 vViewNormal : NORMAL;
    float3 vViewTangent : TANGENT;
    float3 vViewBinormal : BINORMAL;
};



// Parameter
#define NormalTex g_tex_1


VS_OUT VS_Soil_Deferred(VS_IN _in)
{
    VS_OUT output = (VS_OUT)0.f;

    // 로컬에서의 Normal 방향을 월드로 이동    
    output.vLocalPos = _in.vPos;
    output.vViewPos = mul(float4(_in.vPos, 1.f), g_matWV);
    output.vWorldPos = mul(float4(_in.vPos, 1.f), g_matWorld);
    output.vViewNormal = normalize(mul(mul(float4(_in.vNormal, 0.f), g_matWorldInvTrans), g_matView)).xyz;
    output.vViewTangent = normalize(mul(mul(float4(_in.vTangent, 0.f), g_matWorldInvTrans), g_matView)).xyz;
    output.vViewBinormal = normalize(mul(mul(float4(_in.vBinormal, 0.f), g_matWorldInvTrans), g_matView)).xyz;

    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;

    return output;
}


struct PS_OUT
{
    float4 vNormal : SV_Target0;
    float4 vPosition : SV_Target1;
    float4 vColor : SV_Target2;
    float4 vLocalPos : SV_Target3;
};

struct PS_OUT2
{
    float4 vColor : SV_Target0;
    float4 vNormal : SV_Target1;
    float4 vPosition : SV_Target2;
    float4 vEmissive : SV_Target3;
    float4 vData : SV_Target4;
    float4 vWorld : SV_Target5;
};

PS_OUT PS_Soil_Deferred(VS_OUT _in)
{
    PS_OUT output = (PS_OUT)0.f;

    float3 vViewNormal = _in.vViewNormal;    

    output.vNormal = float4(vViewNormal, 1.f);
    output.vPosition = float4(_in.vViewPos, 1.f);
    output.vColor = g_tex_0.Sample(g_sam_0, 0.5 * _in.vUV);    
    output.vLocalPos = float4(_in.vLocalPos, 1.f);

    return output;
}


// Blur

VS_OUT VS_Soil_BlurShader(VS_IN _in)
{
    VS_OUT output = (VS_OUT)0.f;

    // 사용하는 메쉬가 RectMesh(로컬 스페이스에서 반지름 0.5 짜리 정사각형)
    // 따라서 2배로 키워서 화면 전체가 픽셀쉐이더가 호출될 수 있게 한다.
    output.vPosition = float4(_in.vPos.xyz * 2.f, 1.f);

    return output;
}

//Parameter
#define NormalTargetTex     g_tex_0
#define PositionTargetTex  g_tex_1
#define ColorTargetTex  g_tex_2
#define LocalPosTargetTex g_tex_3

float4 PS_Soil_BlurShader(VS_OUT _in) : SV_Target
{
    PS_OUT2 _out = (PS_OUT2)0.f;

    float2 vScreenUV = _in.vPosition.xy / g_Resolution.xy;
    float3 viewpos = PositionTargetTex.Sample(g_sam_0, vScreenUV).xyz;

    float z = 0.f;
    float3 localpos = (float3)0.f;


    for (int i = -2; i <= 2; ++i)
        for (int j = -2; j <= 2; ++j)
        {
            z += PositionTargetTex.Sample(g_sam_0, (_in.vPosition.xy + float2(3000 * i, 3000 * j) / (viewpos.z)) / g_Resolution.xy).z * 0.04;// *GaussianFilter[i + 2][j + 2];

            localpos += LocalPosTargetTex.Sample(g_sam_0, (_in.vPosition.xy + float2(3000 * i, 3000 * j) / (viewpos.z)) / g_Resolution.xy).xyz * 0.04;
        }

    float3 normal = (float3)0.f;

    for (int i = -2; i <= 2; ++i)
        for (int j = -2; j <= 2; ++j)
        {
            normal += NormalTargetTex.Sample(g_sam_0, (_in.vPosition.xy + float2(3000 * i, 3000 * j) / (viewpos.z)) / g_Resolution.xy).xyz * 0.04;// *GaussianFilter[i + 2][j + 2];
        }

    float4 color = (float4)0.f;

    for (int i = -2; i <= 2; ++i)
        for (int j = -2; j <= 2; ++j)
        {
            color += ColorTargetTex.Sample(g_sam_0, (_in.vPosition.xy + float2(3000 * i, 3000 * j) / (viewpos.z)) / g_Resolution.xy) * 0.04;// *GaussianFilter[i + 2][j + 2];
        }


    normal = normalize(normal);


    //normal = NormalTargetTex.Sample(g_sam_0, vScreenUV).xyz;


    if (length(viewpos) == 0.f)
        discard;


    //return float4(1, 1, 1, 1);

    _out.vColor = 0.5 * float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f);

    //노말과 view포지션 blur

    _out.vNormal = float4(normal, 1.f);//NormalTargetTex.Sample(g_sam_0, vScreenUV);// 
    _out.vPosition = PositionTargetTex.Sample(g_sam_0, vScreenUV);
    _out.vPosition.z = z;
    //_out.vColor = color;


    //=============================================
    tLightColor lightcolor = (tLightColor)0.f;
    float fSpecPow = 0.f;

    for (uint i = 0; i < g_Light3DCount; ++i)
    {
        float asdf = 1.f;
        CalcLight3D(_out.vPosition.xyz, _out.vNormal.xyz, i, lightcolor, fSpecPow, asdf);
    }

    float4 vOutColor = 0.5 * float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f);


    vOutColor.xyz = vOutColor.xyz * lightcolor.vDiffuse.xyz
        + vOutColor.xyz * lightcolor.vAmbient.xyz
        + saturate(g_Light3DBuffer[0].Color.vSpecular.xyz) * 0.3f * fSpecPow;

    vOutColor.a = 1.f;

    //===========================================================================



    //============================================================================


    float3 _WorldSpaceCameraPos = mul(float4(0, 0, 0, 1.f), g_matViewInv).xyz;
    float3 _WorldPos = mul(float4(_out.vPosition.xyz, 1.f), g_matViewInv).xyz;
    float3 _WorldNormal = mul(float4(_out.vNormal.xyz, 0.f), g_matViewInv).xyz;

    int _LightIdx = 0;
    tLightInfo LightInfo = g_Light3DBuffer[_LightIdx];

    // Distance to eye from point
    float pointDistance = length(_WorldPos - _WorldSpaceCameraPos.xyz);

    // Normal and light direction calculations
    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - _WorldPos);
    float3 lightDirection = -normalize(LightInfo.vWorldDir.xyz);

    return CalculateSandColor(lightDirection, viewDirection, _WorldNormal, localpos, pointDistance);
    
    

    return vOutColor;
    //return _out;
}

//================================================================================================



#endif