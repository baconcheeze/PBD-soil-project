#include "MPMParticle.h"

MPMParticle::MPMParticle()
{
	
	alpha_cur = 0;
	alpha_next = 0;
	Bp_cur = Matrix3d::Zero();
	Bp_next = Matrix3d::Zero();
	Cp = Matrix3d::Zero();
	Dp = Matrix3d::Zero();
	Fp_cur = Matrix3d::Zero();
	Fp_elastic_cur = Matrix3d::Zero();
	Fp_elastic_hat = Matrix3d::Zero();
	Fp_plastic_next = Matrix3d::Zero();
	Fp_hat = Matrix3d::Zero();
	Fp_next = Matrix3d::Zero();
	Fp_plastic_cur = Matrix3d::Zero();
	Fp_plastic_hat = Matrix3d::Zero();
	Fp_plastic_next = Matrix3d::Zero();
	grad_V = Matrix3d::Zero();
	Mp = 0;
	Qp_cur = 0;
	Qp_next = 0;
	V0 = 0;
	Vp_bar = Vector3d::Zero();
	Vp_cur = Vector3d::Zero();
	Vp_next = Vector3d::Zero();
	Xp_cur = Vector3d::Zero();
	Xp_next = Vector3d::Zero();
	
}

MPMParticle::~MPMParticle()
{
}

void MPMParticle::Initialize()
{
}

MPMParticleSystem::MPMParticleSystem()
{
}

MPMParticleSystem::~MPMParticleSystem()
{
}
