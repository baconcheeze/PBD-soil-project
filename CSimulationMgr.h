#pragma once
#include "CSingleton.h"
#include <queue>


enum class ConstraintType
{
    Ground,
    SpringDamper,
    SpringDamperFriction,
};

struct ConstraintInfo
{
    ConstraintType type;
    int            index_other;
};

class CSimulationMgr :
    public CSingleton<CSimulationMgr>
{
    SINGLE(CSimulationMgr);

private:
    std::vector<CGameObject*> vec_objs;
    std::vector<Vec3> vec_pos;
    std::vector<Vec3> vec_vel;
    std::vector<std::vector< ConstraintInfo>> vec_constraint;
    //오브젝트들 여러개 들고있고. 각각을 매프레임 시뮬레이션해서 위치 업데이트.

public:
    void Simulate();
    void AddObject(CGameObject* obj) {
        vec_objs.push_back(obj); 
        vec_pos.push_back(Vec3::Zero);
        vec_vel.push_back(Vec3::Zero);
        
    }

private:
    void Constraint_Distance(Vec3& pos0, Vec3& pos1, float distance, float massinv0, float massinv1, float stiffness = 1.f);
    void Constraint_FixedPoint(Vec3& pos, Vec3 Destpos);
    Vec3 Constraint_SpringDamper(Vec3& pos0, Vec3& pos1, const Vec3& origin0, const Vec3& origin1, float radius0, float radius1, float massinv0, float massinv1 
        , float spring_coefficient, float damper_coefficient , int iteration_time);

    Vec3 Constraint_SpringDamperFriction(Vec3& pos0, Vec3& pos1, const Vec3& origin0, const Vec3& origin1, float radius0, float radius1, float massinv0, float massinv1
        , float spring_coefficient, float damper_coefficient , float static_friction_coefficient, float kinetic_friction_coefficient, int iteration_time);

    Vec3 Constraint_GroundSpringDamperFriction(Vec3& pos0, const Vec3& origin0, float radius0, float ground_height, float massinv0
        , float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, int iteration_time);

    void Constraint_Ground(Vec3& pos, float radius, float ground_height, float stiffness = 1.f);
    bool Check_Collision(Vec3& pos0, Vec3& pos1, float radius0, float radius1);
};

