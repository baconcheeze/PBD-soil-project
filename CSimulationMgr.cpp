#include "pch.h"
#include "CSimulationMgr.h"
#include "CSimulationInfo.h"
#include "CTransform.h"
#include "CTimeMgr.h"

CSimulationMgr::CSimulationMgr()	
{
}

CSimulationMgr::~CSimulationMgr()
{
	
}

void CSimulationMgr::Simulate()
{
	static bool start = true;

	if (start)
	{
		start = false;
		vec_constraint.resize(vec_objs.size());

		return;
	}


	//forall vertices i do vi ← vi +∆twifext(xi)

	for (int i = 0; i<vec_objs.size(); ++i)
	{
		CGameObject* obj = vec_objs[i];

		if (nullptr == obj->SimulationInfo())
			continue;

		vec_pos[i] = obj->Transform()->GetRelativePos();
		vec_vel[i] = obj->SimulationInfo()->GetVelocity();

		vec_vel[i] += Vec3(0, -98, 0) * DT;
	}

	// dampVelocities(v1,...,vN)


	//forall vertices i do pi ← xi + ∆tvi
	for (int i = 0; i < vec_objs.size(); ++i)
	{
		CGameObject* obj = vec_objs[i];

		if (nullptr == obj->SimulationInfo())
			continue;

		vec_pos[i] += vec_vel[i] * DT;
	}

	//forall vertices i do generateCollisionConstraints(xi → pi)

	float ground_height = -400.f;

	for (int i = 0; i < vec_objs.size(); ++i)
	{
		if (vec_pos[i].y - vec_objs[i]->Transform()->GetRelativeScale().x*0.5 >= ground_height)
			continue;

		ConstraintInfo info;
		info.type = ConstraintType::Ground;
		info.index_other = i;

		vec_constraint[i].push_back(info);
	}

	for (int i = 0; i < vec_objs.size()-1; ++i)
		for (int j = i + 1; j < vec_objs.size(); ++j)
		{
			bool b_collide = Check_Collision(vec_pos[i], vec_pos[j], 25, 25);

			if (b_collide)
			{
				//spring_damper constraint 생성
				ConstraintInfo info;
				info.type = ConstraintType::SpringDamperFriction;
				info.index_other = j;

				vec_constraint[i].push_back(info);

				info.index_other = i;

				vec_constraint[j].push_back(info);

			}
		}

	//loop solverIterations times
	//projectConstraints(C1, ..., CM + Mcoll, p1, ..., pN)
	//endloop

	int iteration_times = 10;

	//float mass0 = vec_objs[0]->SimulationInfo()->GetMass();
	//float mass1 = vec_objs[1]->SimulationInfo()->GetMass();

	//float w0 = 1.f / mass0;
	//float w1 = 1.f / mass1;
	
	float distance = 200.f;

	for (int n = 0; n < iteration_times; ++n)
	{

		for (int i = 0; i < vec_objs.size(); ++i)
		{
			//Constraint_Ground(vec_pos[i], 25.f, -400.f);


			Vec3 delta = Vec3::Zero;
			int count = vec_constraint[i].size();

			for(ConstraintInfo info : vec_constraint[i])
			{

				int j = info.index_other;

				switch (info.type)
				{

				case ConstraintType::Ground:
				{
					delta += Constraint_GroundSpringDamperFriction(vec_pos[i], vec_objs[i]->Transform()->GetRelativePos(), vec_objs[i]->Transform()->GetRelativeScale().x * 0.5
						, -400.f, 1.f / vec_objs[i]->SimulationInfo()->GetMass(), 1000.f, 100.f, 0.1, 0.1, iteration_times);
				}
				break;

				case ConstraintType::SpringDamper:
				{
					delta += Constraint_SpringDamper(vec_pos[i], vec_pos[j], vec_objs[i]->Transform()->GetRelativePos(), vec_objs[j]->Transform()->GetRelativePos()
						, vec_objs[i]->Transform()->GetRelativeScale().x * 0.5, vec_objs[j]->Transform()->GetRelativeScale().x * 0.5
						, 1.f / vec_objs[i]->SimulationInfo()->GetMass(), 1.f / vec_objs[j]->SimulationInfo()->GetMass()
						, 1000.f, 100.f , iteration_times);
				}
				break;

				case ConstraintType::SpringDamperFriction:
				{
					delta += Constraint_SpringDamperFriction(vec_pos[i], vec_pos[j], vec_objs[i]->Transform()->GetRelativePos(), vec_objs[j]->Transform()->GetRelativePos()
						, vec_objs[i]->Transform()->GetRelativeScale().x * 0.5, vec_objs[j]->Transform()->GetRelativeScale().x * 0.5
						, 1.f / vec_objs[i]->SimulationInfo()->GetMass(), 1.f / vec_objs[j]->SimulationInfo()->GetMass()
						, 1000.f, 100.f, 0.2f , 0.2f , iteration_times);
				}
				break;

				}

			}


			if (count > 0)
				delta /= count;

			vec_pos[i] += delta;
		}

		//Constraint_Distance(vec_pos[0], vec_pos[1], distance, w0, w1, 0.369f);
		//Constraint_Distance(vec_pos[1], vec_pos[2], distance, w0, w1, 0.369f);
		//Constraint_FixedPoint(vec_pos[0], Vec3(0, 0, 50));

	}


	//forall vertices i
	// vi ←(pi −xi) / ∆t
	// xi ← pi
	for (int i = 0; i < vec_objs.size(); ++i)
	{
		CGameObject* obj = vec_objs[i];

		if (nullptr == obj->SimulationInfo())
			continue;

		Vec3 _vel_new = (vec_pos[i] - obj->Transform()->GetRelativePos()) / DT;

		obj->Transform()->SetRelativePos(vec_pos[i]);
		obj->SimulationInfo()->SetVelocity(_vel_new);
	}


	for (int i = 0; i < vec_objs.size(); ++i)
	{
		vec_constraint[i].clear();
	}
}

void CSimulationMgr::Constraint_Distance(Vec3& pos0, Vec3& pos1,  float distance, float massinv0, float massinv1, float stiffness)
{
	Vec3 delta0 = Vec3::Zero;
	Vec3 delta1 = Vec3::Zero;

	float d01 = Vector3::Distance(pos0, pos1);

	float k = stiffness;

	float w0 = massinv0;
	float w1 = massinv1;

	delta0 = -w0 / (w0 + w1) * (d01 - distance) * (pos0 - pos1) / d01;
	delta1 = w1 / (w0 + w1) * (d01 - distance) * (pos0 - pos1) / d01;

	pos0 += k * delta0;
	pos1 += k * delta1;

}

void CSimulationMgr::Constraint_FixedPoint(Vec3& pos, Vec3 Destpos)
{
	pos = Destpos;
}

Vec3 CSimulationMgr::Constraint_SpringDamper(Vec3& pos0, Vec3& pos1, const Vec3& origin0, const Vec3& origin1, float radius0, float radius1, float massinv0, float massinv1
	, float spring_coefficient, float damper_coefficient, int iteration_time)
{
	Vec3 norm = (pos0 - pos1).Normalize();

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = DT;


	float delta_spring;
	float delta_damper;

	delta_spring = -massinv0 / (massinv0 + massinv1) * (Vec3::Distance(pos0, pos1) - (radius0 + radius1));
	delta_damper = -massinv0 / (massinv0 + massinv1) * ((pos0 - origin0) - (pos1 - origin1)).Dot(norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	return (k_pbb * delta_spring + c_pbb * delta_damper) * norm;


}

Vec3 CSimulationMgr::Constraint_SpringDamperFriction(Vec3& pos0, Vec3& pos1, const Vec3& origin0, const Vec3& origin1, float radius0, float radius1, float massinv0, float massinv1
	, float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, int iteration_time)
{
	Vec3 norm = (pos0 - pos1).Normalize();
	Vec3 vel = (pos0 - origin0) - (pos1 - origin1);

	Vec3 tangent = (vel - vel.Dot(norm) * norm).Normalize();

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = DT;


	float delta_spring;
	float delta_damper;

	float beta = -massinv0 / (massinv0 + massinv1);

	delta_spring = (Vec3::Distance(pos0, pos1) - (radius0 + radius1));
	delta_damper = vel.Dot(norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	float lambda = vel.Dot(tangent);
	float lambda_normal = (k_pbb * delta_spring + c_pbb * delta_damper);

	float lambda_friction = abs(lambda) <= static_friction_coefficient * abs(lambda_normal) ? lambda : kinetic_friction_coefficient * abs(lambda_normal);

	return beta * (lambda_friction * tangent + lambda_normal*norm);
}

Vec3 CSimulationMgr::Constraint_GroundSpringDamperFriction(Vec3& pos0, const Vec3& origin0, float radius0 , float ground_height , float massinv0
	, float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, int iteration_time)
{
	Vec3 norm = Vec3(0, 1.f, 0);
	Vec3 vel = (pos0 - origin0);

	Vec3 tangent = (vel - vel.Dot(norm) * norm).Normalize();

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = DT;

	float delta_spring;
	float delta_damper;

	float beta = -1.f;

	delta_spring = (pos0.y - (radius0+ground_height));
	delta_damper = vel.Dot(norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	float lambda = vel.Dot(tangent);
	float lambda_normal = (k_pbb * delta_spring + c_pbb * delta_damper);

	float lambda_friction = abs(lambda) <= static_friction_coefficient * abs(delta_spring) ? lambda : kinetic_friction_coefficient * abs(delta_spring);

	return beta * (lambda_friction * tangent + lambda_normal * norm);
	//pos0.y += beta * delta_spring;
	//return beta* (lambda_friction * tangent + delta_spring * norm);
	//return beta* delta_spring* norm;
}

void CSimulationMgr::Constraint_Ground(Vec3& pos, float radius, float ground_height, float stiffness)
{
	if (pos.y - radius >= ground_height)
		return;

	pos.y += stiffness * (radius - pos.y + ground_height);
}

bool CSimulationMgr::Check_Collision(Vec3& pos0, Vec3& pos1, float radius0, float radius1)
{
	float D = Vec3::Distance(pos0, pos1);
	
	if (D > radius0 + radius1)
		return false;

	return true;

}
