#pragma once

#include <Eigen/Dense>
#include <Eigen/Core>

using namespace Eigen;

class MPMParticle
{
public:
	MPMParticle();
	virtual ~MPMParticle();

public:
	void Initialize();

private:
	double Mp;	// particle mass
	double V0;  // initial particle volume
	double alpha_cur, alpha_next; // yield surface size
	double Qp_cur, Qp_next;		// hardening state

	Matrix3d Bp_cur, Bp_next;  // affine momentum
	Matrix3d Fp_cur, Fp_next;  // deformation gradient
	Matrix3d Fp_elastic_cur, Fp_elastic_next; // elastic deformation gradient
	Matrix3d Fp_plastic_cur, Fp_plastic_next; // plastic deformation gradient
	Vector3d  Vp_cur, Vp_next;		// Velocity
	Vector3d  Xp_cur, Xp_next;      // Position
	Matrix3d Cp;					// Particle Velocity Derivative
	Matrix3d Dp;					// Affine inertia tensor
	Matrix3d Fp_hat;				// Deformation gradient before plasticity
	Matrix3d Fp_elastic_hat;       // elastic Deformation gradient before plasticity
	Matrix3d Fp_plastic_hat;		// plastic Deformation gradient before plasticity
	Matrix3d grad_V;				// grid_based velocity gradient
	Vector3d Vp_bar;				// Particle affine velocity field


	friend class MPMSolver;
};

class MPMParticleSystem
{
public:
	MPMParticleSystem();
	virtual ~MPMParticleSystem();

	std::vector<MPMParticle*>& GetVecParticles() { return vec_Particles; }

	friend class MPMSolver;

private:
	std::vector<MPMParticle*> vec_Particles;


};

