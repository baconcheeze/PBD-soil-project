#ifndef _SandPBR
#define _SandPBR

#include "value.fx"
#include "func.fx"

// User defined variables
#define _Color0  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color1  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color2  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color3  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color4  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color5  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color6  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)
#define _Color7  float4(111.f / 256.f, 79.f / 256.f, 40.f / 256.f, 1.f)

#define _SSS  0.8  // Subsurface Scattering

#define _Rs  0.12  // Specular Roughness
#define _Rt  0.2   // Transmission Roughness
#define _T  0.8  // Transmission
#define _P  1000  // Porosity Factor

#define _Iglints  float4(1, 1, 1, 1) // Glints Color
#define _Sigma  0.02 // Glints Sigma
#define _NoiseScale  2000 // Noise Scale

int colorIndex(float3 rand)
{
    float x = (rand.x + 1) / 2;
    float y = (rand.y + 1) / 2;
    float z = (rand.z + 1) / 2;
    x = x >= 0 ? 1 : 0;
    y = y >= 0 ? 1 : 0;
    z = z >= 0 ? 1 : 0;
    return 4 * x + 2 * y + z;

}

float3 averageColor()
{
    return (_Color0 + _Color1 + _Color2 + _Color3 + _Color4 + _Color5 + _Color6 +
        _Color7) / 8;

}

//---------------------------
//random number generation

// Jarzynski et al. 2020
int3 pcg3d(float3 s)
{
    int3 v = int3(s.x, s.y, s.z);
    v = v * 1664525 + int3(1013904223, 1013904223, 1013904223);
    v.x += v.y * v.z; v.y += v.z * v.x; v.z += v.x * v.y;
    v.x ^= v.x >> 16; v.y ^= v.y >> 16; v.z ^= v.z >> 16;
    v.x += v.y * v.z; v.y += v.z * v.x; v.z += v.x * v.y;
    return v;
}


//---------------------------
//sampling of normals

// Frisvad 2012
float3 rotate_to_normal(float3 normal, float3 v)
{
    float sign = 1;
    if (normal.z < 0) sign = -1;
    float a = -1.0f / (1.0f + abs(normal.z));
    float b = normal.x * normal.y * a;
    v = float3(1.0f + normal.x * normal.x * a, b, -sign * normal.x) * v.x
        + float3(sign * b, sign * (1.0f + normal.y * normal.y * a), -normal.y) * v.y
        + normal * v.z;
    return v;
}

float3 getCubeNormal(int index)
{
    float3 cube[] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(-1, 0, 0),
    float3(0, -1, 0),
    float3(0, 0, -1)
    };

    return cube[index];
}

float3 getViewAlignedNormal(float3 viewDir, float3 q)
{
    int index = 0;
    float maxDot = -100;
    float dotP = 0;

    for (int y = 0; y < 6; y++)
    {

        dotP = dot(viewDir, getCubeNormal(y));
        if (dotP > maxDot) {
            maxDot = dotP;
            index = y;

        }
    }

    return getCubeNormal(index);

}

float3 sampleNormalInSphere(float2 rand)
{
    rand.x = (rand.x + 1.0) / 2.0;
    rand.y = (rand.y + 1.0) / 2.0;

    float phi = 2.0 * 3.141592653589 * rand.x;
    float x = 2 * cos(phi) * sqrt(rand.y * (1 - rand.y));
    float y = 2 * sin(phi) * sqrt(rand.y * (1 - rand.y));
    float z = 1 - 2 * rand.y;
    float3 q = float3(x, y, z);

    return q;
}

// Frisvad 2012
float3x3 inverseMTM(float3 n)
{
    float3 b1, b2;
    if (n.z < -0.9999999f)
    {
        b1 = float3(0.0f, -1.0f, 0.0f);
        b2 = float3(-1.0f, 0.0f, 0.0f);
    }
    else
    {
        float a = 1.0f / (1.0f + n.z);
        float b = -n.x * n.y * a;
        b1 = float3(1.0f - n.x * n.x * a, b, -n.x);
        b2 = float3(b, 1.0f - n.y * n.y * a, -n.y);
    }

    float3x3 mtm = float3x3(b1, b2, n);
    return mtm;

}

float3 getMicroNormal(float3 rnd, float3 viewDirection)
{
    float3 q = sampleNormalInSphere(rnd);
    float3x3 imtm = inverseMTM(normalize(q));
    float3 objectViewDir = normalize(mul(imtm, viewDirection));
    float3 objectNormal = getViewAlignedNormal(objectViewDir, q);
    float3 worldNormal = rotate_to_normal(q, objectNormal);

    return worldNormal;

}

//---------------------------
//shading

// Schlick 1994
float Schlick(float3 v, float3 n)
{
    float ior = 1.458;
    float f0 = pow(ior - 1, 2) / pow(ior + 1, 2);
    float F = f0 + (1 - f0) * pow(1 - abs((dot(n, v))), 5);
    return F;

}

float Cos2Theta(float3 w)
{
    return w.z * w.z;

}


float AbsCosTheta(float3 w)
{
    return abs(w.z);

}

float Sin2Theta(float3 w)
{
    return max(0.0, 1.0 - Cos2Theta(w));

}

float SinTheta(float3 w)
{
    return sqrt(Sin2Theta(w));

}

float CosPhi(float3 w) {
    float sinTheta = SinTheta(w);
    float result = 0;
    if (sinTheta == 0) {
        result = 1;

    }
    else {
        result = clamp(w.x / sinTheta, -1, 1);

    }
    return result;

}

float SinPhi(float3 w) {
    float sinTheta = SinTheta(w);
    float result = 0;
    if (sinTheta == 0) {
        result = 0;

    }
    else {
        result = clamp(w.y / sinTheta, -1, 1);

    }
    return result;

}

// Pharr et al. 2018
float Loren(float3 l, float3 v, float3 n, float sigma)
{
    float sigma2 = sigma * sigma;
    float A = 1.f - (sigma2 / (2.f * (sigma2 + 0.33f)));
    float B = 0.45f * sigma2 / (sigma2 + 0.09f);
    float sinThetaI = SinTheta(l);
    float sinThetaO = SinTheta(v);
    float sinAlpha = 0;
    float tanBeta = 0;
    float maxCos = 0;

    // << Compute cosine term of ?OrenNayar model>>
    if (sinThetaI > 0.0001 && sinThetaO > 0.0001) {
        float sinPhiI = SinPhi(l);
        float cosPhiI = CosPhi(l);
        float sinPhiO = SinPhi(v);
        float cosPhiO = CosPhi(v);
        float dCos = cosPhiI * cosPhiO + sinPhiI * sinPhiO;
        maxCos = max(0.0, dCos);

    }

    // <<Compute sine and tangent terms of ?OrenNayar model >>
    if (AbsCosTheta(l) > AbsCosTheta(v)) {
        sinAlpha = sinThetaO;
        tanBeta = saturate(sinThetaI / AbsCosTheta(l));

    }

    else {
        sinAlpha = sinThetaI;
        tanBeta = saturate(sinThetaO / AbsCosTheta(v));

    }

    return (A + B * maxCos * sinAlpha * tanBeta);

}


// Fresnel strength function
float F()
{
    return saturate(-20.80 * pow(_Rs, 5) + 60 * pow(_Rs, 4) - 55.9 * pow(_Rs, 3) +
        14.55 * pow(_Rs, 2) + 2 * _Rs + 0.25);

}

// Glints strength function
float G()
{
    return saturate(1 / (1 + exp(13.5 * (_Rs - 0.4))));

}

// Diffuse extinction due to transmission
float Text()
{
    return saturate(-3.2 * pow(_T, 4) + 4.8 * pow(_T, 3) - 2.2 * pow(_T, 2) - 0.3 * _T
        + 1);

}

// Glints Gaussian Distribution Function
float GDF(float x)
{
    float mu = 0;
    return max(0, exp(-pow(x - mu, 2) / (2 * pow(_Sigma, 2))));

}

// Custom transmission function
float3 transmission(float3 n, float3 v, float3 l)
{
    float Rt = 0.2 + _Rt * (0.4 - 0.2);
    float t = 1 - max(0, dot(n, v));
    
    t = pow(t, 1 / Rt);
    t *= max(0, dot(l, -v));
    t *= _T;
    t *= (1 - 0.9 * _Rt);
    return saturate(t);

}

float sig(float x, float a, float b)
{
    return 1 / (1 + exp(-a * (x - b)));

}


float4 CalculateSandColor(float3 LightDirection, float3 ViewDirection, float3 NormalVector, float3 LocalPos, float DistanceToEye)
{
    // Subsurface scattering variables
    float scattering = 0.8;
    float absorption = 0.2;
    float fs = scattering * _SSS;
    float fe = exp(-absorption * _SSS);

    // Oren-Nayar variables
    float orenNayarSigma = 0.1;

    // Sigmoid function variables
    float a = 0.0001;
    float b = 1000;

    // Distance to eye from point
    float pointDistance = DistanceToEye;

    // Pseudo random noise generation
    float3 rand = normalize(pcg3d(float3(LocalPos * _NoiseScale)));
    
    // Normal and light direction calculations
    float3 viewDirection = normalize(ViewDirection);

    float3 macroNormalDirection = normalize(NormalVector);

    float3 lightDirection = normalize(LightDirection);

    float3 microNormalDirection = getMicroNormal(rand, viewDirection);

    float3 microLightReflectDirection = normalize(reflect(-lightDirection,
        microNormalDirection));

    float3 macroLightReflectDirection = normalize(reflect(-lightDirection,
        macroNormalDirection));

    float3 macroViewReflectDirection = normalize(reflect(-viewDirection,
        macroNormalDirection));

    float cosine_theta = max(0, dot(macroNormalDirection, lightDirection));

    // Light colors
    float3 lightColor = float3(1, 1, 1);
    float3 skyLight = float3(1.0, 1.0, 1.0);

    // Sand colors
    float4 C[] = {
    _Color0 , _Color1 , _Color2 , _Color3 ,
    _Color4 , _Color5 , _Color6 , _Color7
    };

    float3 rho_m = C[colorIndex(rand)].rgb;
    float3 rho_n = averageColor();
    float Imin =  saturate(exp(-((_P / pointDistance))));
    float rho_m_intensity = Imin + (1 - (   (rand.x+1.f)/2.f * (1 - Imin) + Imin));
    float rho_n_intensity = Imin + (1 - Imin) / 2;
    float3 Kd_m = rho_m / PI;
    float3 Kd_n = rho_n / PI;
    float3 fresnelColor = skyLight + (lightColor * cosine_theta);
    float3 glintsColor = (skyLight + lightColor) * _Iglints;
    float3 transmissionColor = lightColor * rho_n;


    // DIFFUSE and SUBSURFACE SCATTERING
    // Diffuse close
    float3 Ld = Kd_m * lightColor * (fs + (1 - fs) * cosine_theta);
    Ld += Kd_m * skyLight;
    Ld *= fe;

    // Diffuse far
    float3 Lbrdf = lightColor * Kd_n * (fs + (1 - fs) * (Loren(lightDirection, viewDirection, macroNormalDirection, orenNayarSigma) * cosine_theta)); //마이크로 컬러로 임시로 변경
    Lbrdf += skyLight * Kd_n;
    Lbrdf *= fe;

    // GLINTS
    float g = 0.5 * G() * max(0, GDF(rand.x) * dot(viewDirection, microLightReflectDirection)) * cosine_theta;
    //g = G() * max(0, 1.f * dot(viewDirection, microLightReflectDirection)) * cosine_theta;

    // FRESNEL
    float3 h = normalize(lightDirection + macroLightReflectDirection);
    //h = normalize(lightDirection + normalize(float3(-1, 1, -1)));
    //h = float3(0, 1, 0);
    float f = F() * Schlick(viewDirection, h);
    Ld *= (1 - f);
    Lbrdf *= (1 - f);

    // SPECULAR
    float3 Lg = glintsColor * g;
    float3 Lf = fresnelColor * f;
    float3 Ls = Lg + Lf;

    // TRANSMISSION
    float t = transmission(macroNormalDirection, viewDirection, lightDirection);
    float3 Lt = transmissionColor * t;
    Ld *= Text();
    Lbrdf *= Text();

    // CLOSE SHADING
    float3 Lclose = Ld + Ls + Lt;

    //return float4(Lclose, 1);

    // FAR SHADING
    float3 Lfar = Lbrdf + Lf + Lt;

    // POROSITY
    Lclose *=  rho_m_intensity;
    Lfar *=  rho_n_intensity;

    // TRANSITION CLOSE TO FAR
    float3 Lfinal = (1 - sig(pointDistance, a, b)) * Lclose + sig(pointDistance, a, b) * Lfar;

    //return float4(1, 1, 1, 1);

    //Diffuse
    //return float4(Ld, 1);

    //Fresnel
    //return float4(Lf, 1);

    //Glints
    //return float4(Lg, 1);

    //Fresnel Gilnts combined
    //return float4(Ls, 1);

    // porosity
    //return rho_m_intensity * float4(1, 1, 1, 1);

    //transmission
    //return float4(Lt, 1);

    return float4(Lclose, 1);
}



#endif
