#pragma once

#include "MPMParticle.h"
#include "MPMGrid.h"

enum class CollisionType
{
	Sticky,
	Seperating,
	Sleep,
};

struct CollisionConstraint
{
	std::function<double(Vector3d)> phi;
	std::function<Vector3d(Vector3d)> Dphi;

	CollisionType	_Type = CollisionType::Sticky;
	Vector3d Colliding_Mesh_Velocity;   // 부딪히는 오브젝트의 Velocity , 땅이면 그냥 0벡터
};

class MPMSolver
{
public:
	MPMSolver();
	virtual ~MPMSolver();

	void Initialize(int X_GRID, int Y_GRID, int Z_GRID);
	void Simulate(double dt);


private:
	MPMParticleSystem mParticleSystem;
	MPMGrid			  mGrid;

	void TransferToGrid();
	void UpdateVelocity();
	void ResolveCollision();
	void TransferToParticle();
	void UpdateParticleState();
	void UpdateCurState();
	std::vector<CollisionConstraint> mCollisionConstraints;
};

