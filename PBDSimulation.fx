#ifndef _LANDSCAPE
#define _LANDSCAPE

#include "struct.fx"
#include "value.fx"

RWStructuredBuffer<PBDParticle> _PBDParticle	: register(u0);
RWStructuredBuffer<float4>      _PBDPredictedPos : register(u1);
RWTexture2D<float4> CollisionInfoTex : register(u2); // x : 누구랑 , y : 어떻게
RWStructuredBuffer<float4>      _PBDDelta : register(u3);

#define ParticleCount   g_int_0
#define GroundHeight    g_float_0

/*
struct PBDParticle
{
	Vec3 Pos;
	float Radius;
	Vec3 Velocity;
	float Mass;
};
*/

//============================================================FUNC

float3 Constraint_GroundSpringDamperFriction(inout float3 pos0, float3 origin0, float radius0, float ground_height, float massinv0
	, float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, int iteration_time)
{
	float3 norm = float3(0, 1.f, 0);
	float3 vel = (pos0 - origin0);

	float3 tangent = (vel - dot(vel,norm) * norm);
	
	float d = length(tangent);
	if (d > 0.0001)
		tangent = tangent / d;

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = g_DT;

	float delta_spring;
	float delta_damper;

	float beta = -1.f;

	delta_spring = (pos0.y - (radius0 + ground_height));
	delta_damper = dot(vel, norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	float lambda = dot(vel,tangent);
	float lambda_normal = (k_pbb * delta_spring + c_pbb * delta_damper);

	float lambda_friction = abs(lambda) <= static_friction_coefficient * abs(delta_spring) ? lambda : kinetic_friction_coefficient * abs(delta_spring);

	//return beta * lambda_normal * norm;

	return beta * (lambda_friction * tangent + lambda_normal * norm);
	
}


float3 Constraint_SpringDamperFriction(inout float3 pos0, float3 pos1, float3 origin0, float3 origin1, float radius0, float radius1, float massinv0, float massinv1
	, float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, float adhesion_coefficient, int iteration_time)
{
	float3 norm = normalize((pos0 - pos1));
	float3 vel = (pos0 - origin0) - (pos1 - origin1);

	float3 tangent = (vel - dot(vel, norm) * norm);

	float d = length(tangent);
	if (d > 0.0001)
		tangent = tangent / d;
	

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = g_DT;


	float delta_spring;
	float delta_damper;

	float beta = -massinv0 / (massinv0 + massinv1);

	delta_spring = length(pos0 - pos1) - (radius0 + radius1);
	delta_damper = dot(vel, norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	float lambda = dot(vel, tangent);
	float lambda_normal = (k_pbb * delta_spring + c_pbb * delta_damper);

	float Area = PI * radius0 * radius0 * (1 - (abs(delta_spring) / radius0) * (abs(delta_spring) / radius0));
	float Adhesion_Force = adhesion_coefficient * Area; // 힘계산, 복잡한걸로 추후 수정 가능성 o

	float lambda_adhesion = Adhesion_Force * g_DT * g_DT * massinv0;

	float lambda_friction = abs(lambda) <= static_friction_coefficient * abs(lambda_normal + lambda_adhesion / iteration_time) ? lambda : kinetic_friction_coefficient * abs(lambda_normal + lambda_adhesion / iteration_time);

	return beta * lambda_normal * norm;

	return beta * (lambda_friction * tangent + lambda_normal * norm + lambda_adhesion / iteration_time * norm);




}

//============================================================



[numthreads(256, 1, 1)]
void CS_PBDParticle_SetProjection(uint3 id : SV_DispatchThreadID)
{
	if (id.x >= ParticleCount)
	{
		return;
	}

	
	// forall vertices i do vi ← vi +?twifext(xi) : 외력적용
	_PBDParticle[id.x].Velocity += float3(0, -98, 0) * g_DT;

	// forall vertices i do pi ← xi + ?tvi
	PBDParticle particle = _PBDParticle[id.x];
	_PBDPredictedPos[id.x].xyz = particle.Pos +particle.Velocity * g_DT;
	_PBDPredictedPos[id.x].w = 1.f;

	int count = 0;
	
	//forall vertices i do generateCollisionConstraints(xi → pi)
	for (int j = 0; j < ParticleCount; ++j)
	{
		if (j == id.x)
			continue;

				
		if (length(particle.Pos - _PBDParticle[j].Pos) < particle.Radius + _PBDParticle[j].Radius)
		{
			//Collision 발생

			CollisionInfoTex[int2(id.x, count++)] = float4(j, 1, 0, 1);
		}
		
		if (particle.Pos.y - particle.Radius < GroundHeight)
		{
			//GroundCollision 발생
			CollisionInfoTex[int2(id.x, count++)] = float4(id.x, 2, 0, 1);
		}
		
	}

	CollisionInfoTex[int2(id.x, count)] = float4(-1, 0, 0, 1);
	

}

[numthreads(256, 1, 1)]
void CS_PBDParticle_Projection(uint3 id : SV_DispatchThreadID)
{
	if (id.x >= ParticleCount)
	{
		return;
	}

	int iteration_times = 10;
	

		float3 delta = (float3)0.f;
		
		
		for (int j = 0; j < ParticleCount; ++j)
		{
			int who = CollisionInfoTex[int2(id.x, j)].x;
			int how = CollisionInfoTex[int2(id.x,j)].y;

			if (who < 0)
				break;

			if (how == 0)
				break;

			switch (how)
			{

			case 2.0:
			{
				//delta = float3(0, 1, 0) * (-400.f + _PBDParticle[id.x].Radius - _PBDPredictedPos[id.x].y);
				delta = Constraint_GroundSpringDamperFriction(_PBDPredictedPos[id.x].xyz, _PBDParticle[id.x].Pos, _PBDParticle[id.x].Radius
					, -400.f, 1.f / _PBDParticle[id.x].Mass, 1000.f, 100.f, 0.3, 0.3, iteration_times);
			}
			break;

			case 1.0:
			{
				/*
				delta += Constraint_SpringDamperFriction(_PBDPredictedPos[id.x].xyz, _PBDPredictedPos[j].xyz
				, _PBDParticle[id.x].Pos, _PBDParticle[j].Pos
				, _PBDParticle[id.x].Radius, _PBDParticle[j].Radius
				, 1.f / _PBDParticle[id.x].Mass, 1.f / _PBDParticle[j].Radius
				, 500.f, 400.f, 0.3f, 0.3f, 0.1f, iteration_times);
				*/
				
			}
			break;

			}

		}
		
		_PBDDelta[id.x] = float4(delta, 0);
		//_PBDPredictedPos[id.x] = _PBDPredictedPos[id.x] + _PBDDelta[id.x];

}

[numthreads(256, 1, 1)]
void CS_PBDParticle_DeltaToPred(uint3 id : SV_DispatchThreadID)
{
	if (id.x >= ParticleCount)
	{
		return;
	}

	int iteration_times = 10;


	float3 delta = (float3)0.f;


	for (int j = 0; j < ParticleCount; ++j)
	{
		int who = CollisionInfoTex[int2(id.x, j)].x;
		int how = CollisionInfoTex[int2(id.x, j)].y;

		if (who < 0)
			break;

		if (how == 0)
			break;

		switch (how)
		{

		case 2.0:
		{
			//delta = float3(0, 1, 0) * (-400.f + _PBDParticle[id.x].Radius - _PBDPredictedPos[id.x].y);
			delta = Constraint_GroundSpringDamperFriction(_PBDPredictedPos[id.x].xyz, _PBDParticle[id.x].Pos, _PBDParticle[id.x].Radius
				, -400.f, 1.f / _PBDParticle[id.x].Mass, 1000.f, 100.f, 0.3, 0.3, iteration_times);
		}
		break;

		case 1.0:
		{
			/*
			delta += Constraint_SpringDamperFriction(_PBDPredictedPos[id.x].xyz, _PBDPredictedPos[j].xyz
			, _PBDParticle[id.x].Pos, _PBDParticle[j].Pos
			, _PBDParticle[id.x].Radius, _PBDParticle[j].Radius
			, 1.f / _PBDParticle[id.x].Mass, 1.f / _PBDParticle[j].Radius
			, 500.f, 400.f, 0.3f, 0.3f, 0.1f, iteration_times);
			*/

		}
		break;

		}

	}

	//_PBDDelta[id.x] = float4(delta, 0);
	_PBDPredictedPos[id.x] = _PBDPredictedPos[id.x] + _PBDDelta[id.x];
}


[numthreads(256, 1, 1)]
void CS_PBDParticle_SetParameter(uint3 id : SV_DispatchThreadID)
{
	if (id.x >= ParticleCount)
	{
		return;
	}


	//forall vertices i
	// vi ←(pi ?xi) / ?t
	// xi ← pi

	_PBDParticle[id.x].Velocity = (_PBDPredictedPos[id.x].xyz - _PBDParticle[id.x].Pos) / g_DT;
	_PBDParticle[id.x].Pos = _PBDPredictedPos[id.x].xyz;
}

#endif