#include "MPMSolver.h"
#include "MPMFunction.h"
#include "MPMDefine.h"
#include <PoissonGenerator/PoissonGenerator.h>

static double DT;

MPMSolver::MPMSolver()
{
}

MPMSolver::~MPMSolver()
{
}

void MPMSolver::Initialize(int X_GRID, int Y_GRID, int Z_GRID)
{
	
	DefaultPRNG PRNG;

	std::vector<sPoint> P_c = GeneratePoissonPoints(2000, PRNG);
	int NP = static_cast <int>(P_c.size());

	double W_COL = X_GRID / 8.0;
	double H_COL = (Y_GRID - 2 * CUB) * 0.9;
	double X_COL = (X_GRID - W_COL) / 2.0;
	double Y_COL = CUB;

	double VOL = W_COL * H_COL / static_cast<double>(NP);
	double MASS = VOL * RHO_dry_sand / 100.0;
	
	Vector2f v = Vector2f::Zero();							// Initial velocity
	Matrix2f a = Matrix2f::Zero();

	for (int p = 0; p < NP; p++)
	{
		Vector2f pos = Vector2f(P_c[p].x * W_COL + X_COL, P_c[p].y * H_COL + Y_COL);

		MPMParticle* particle = new MPMParticle;
		

		mParticleSystem.vec_Particles.push_back(particle);
	}

	
}

void MPMSolver::Simulate(double dt)
{
	DT = dt;

	//Only Explicit, Implicity Case는 나중에

	//1. Particle -> Grid 정보 전달
	TransferToGrid();

	//2. Grid Velocity Update v->v*
	UpdateVelocity();

	//3. Collision + Friction
	ResolveCollision();

	//4. Grid -> Particle 정보 전달
	TransferToParticle();

	//5. Particle State Update
	UpdateParticleState();

	//6. CurState <- Next States 정보전달
	UpdateCurState();
}

void MPMSolver::TransferToGrid()
{
	// For every particle

	for (MPMParticle* particle : mParticleSystem.GetVecParticles())
	{

		// Calculate Closest Bottom Left Node
			int X = static_cast<int>(particle->Xp_cur(0) - mGrid.minX);
			int Y = static_cast<int>(particle->Xp_cur(1) - mGrid.minY);
			int Z = static_cast<int>(particle->Xp_cur(2) - mGrid.minY);


		// Loop Over Close nodes
			for (int i = X - 1; i < X + 3; ++i)
			{
				for (int j = Y - 1; j < Y + 3; ++j)
				{
					for (int w = Z - 1; w < Z + 3; ++w)
					{
						if (i < mGrid.minX || j < mGrid.minY || w < mGrid.minZ ||
							i >= mGrid.minX + mGrid.mResolutionX || j >= mGrid.minY + mGrid.mResolutionY || w >= mGrid.minZ + mGrid.mResolutionZ)
							continue;

						MPMGridNode& node = mGrid.mGrid[i][j][w];
						
						Vector3d gridpos = Vector3d(i, j, w);

						// Calculate wip and dwip
						Vector3d dist =  particle->Xp_cur - gridpos;
						double wip = getWip(dist);
						Vector3d Dwip = getdWip(dist);

						// Push Mass
						
						node.Mi += wip * particle->Mp;

						// Push Velocity
						double Dp_inv = 3 / (mGrid.grid_length * mGrid.grid_length);
						node.Vi += wip * particle->Mp * (particle->Vp_cur + Dp_inv * particle->Bp_cur * (-dist));

						// Calcute and Push Force
						// 1. SVD decomposition
						Matrix3d U, V;
						Vector3d Eps;
						Eigen::BDCSVD<Eigen::Matrix3d> svd(particle->Fp_elastic_cur, Eigen::ComputeThinU | Eigen::ComputeThinV);
						U = svd.matrixU();
						V = svd.matrixV();
						Eps = svd.singularValues();						
						Matrix3d EpsMat = DiagonalMatrix<double, 3>(Eps);
						Matrix3d LogEpsMat = DiagonalMatrix<double, 3>(vectorLog(Eps));
						
						EpsMat * LogEpsMat;
						Matrix3d dFeMat = 2 * MU_dry_sand * EpsMat.inverse() * LogEpsMat + LAMBDA_dry_sand * vectorLog(Eps).sum()* EpsMat.inverse();	
								
						Vector3d Force = -particle->Mp * U * dFeMat * V.transpose() * particle->Fp_elastic_cur.transpose() * Dwip;
						Force += wip * particle->Mp * Vector3d(0, -Gravity_Accelaration, 0);
						node.Fi += Force;

					}
				}
			}
	}
}

void MPMSolver::UpdateVelocity()
{
	//Loop over every node of grid
	for (int i = 0; i < mGrid.mResolutionX; ++i)
		for (int j = 0; j < mGrid.mResolutionY; ++j)
			for (int w = 0; w < mGrid.mResolutionZ; ++w)
			{
				MPMGridNode& node = mGrid.mGrid[i][j][w];

				node.Vi_star.setZero();

				if(node.Mi > Epsilon)
					node.Vi_star = node.Vi + node.Fi / node.Mi;

				node.Vi_col_fric = node.Vi_col = node.Vi_star;
			}
	
}

void MPMSolver::ResolveCollision()
{
	//Loop over every node of grid
	for (int i = 0; i < mGrid.mResolutionX; ++i)
		for (int j = 0; j < mGrid.mResolutionY; ++j)
			for (int w = 0; w < mGrid.mResolutionZ; ++w)
			{
				MPMGridNode& node = mGrid.mGrid[i][j][w];

				Vector3d WorldPos(mGrid.minX + mGrid.grid_length * i, mGrid.minY + mGrid.grid_length * j, mGrid.minZ + mGrid.grid_length * w);

				for (CollisionConstraint constraint : mCollisionConstraints)
				{
					if (constraint.phi(WorldPos) <= 0)  // Collision 발생
					{						
						const Vector3d& velocity = node.Vi_star;
						const Vector3d& normal = constraint.Dphi(WorldPos);

						Vector3d vRef = velocity - constraint.Colliding_Mesh_Velocity; // 상대속도
						double vRef_norm = vRef.dot(normal);

						switch (constraint._Type)
						{
						case CollisionType::Sticky:  // 달라붙음
						{
							node.Vi_col = constraint.Colliding_Mesh_Velocity;
						}
						break;

						case CollisionType::Seperating:
						{
							node.Vi_col = node.Vi_star;
						}
						break;

						case CollisionType::Sleep: // 미끄러짐
						{
							if (vRef_norm < 0.0) // approaching
							{
								Vector3d vTangential = vRef - vRef_norm * normal;

								node.Vi_col = vTangential;

								if (vTangential.norm() < static_friction_coefficient * abs(vRef_norm)) // 정지 마찰
								{
									vRef = Vector3d::Zero();
								}

								else
								{
									vRef = vTangential + dynamic_friction_coefficient * vRef_norm * vTangential / vTangential.norm();
								}

								node.Vi_col_fric = vRef;
							}
						}
						break;

						}



						// Friction
						Vector3d velocity_change = node.Vi_col - node.Vi_star;
						Vector3d Impulse = node.Mi * velocity_change;
						double velocity_normal = node.Vi_col.dot(normal);
						Vector3d velocity_tangent = node.Vi_col - velocity_normal * normal;
						double tangent_scalar = velocity_tangent.norm();

						if (tangent_scalar <= static_friction_coefficient * Impulse.norm() / node.Mi)
							node.Vi_col_fric = normal * velocity_normal;

						else
							node.Vi_col_fric = node.Vi_col - dynamic_friction_coefficient * Impulse.norm() * velocity_tangent/tangent_scalar / node.Mi;

						//Xi_bar Update
						node.Xi_bar = node.Xi + DT * node.Vi_col;
					}
				}
			}
}

void MPMSolver::TransferToParticle()
{
	for (MPMParticle* particle : mParticleSystem.GetVecParticles())
	{
		// SetZero values for summation
		particle->Vp_next.setZero();
		particle->Bp_next.setZero();
		particle->Xp_next.setZero();
		particle->grad_V.setZero();

		// Calculate Closest Bottom Left Node
		int X = static_cast<int>(particle->Xp_cur(0) - mGrid.minX);
		int Y = static_cast<int>(particle->Xp_cur(1) - mGrid.minY);
		int Z = static_cast<int>(particle->Xp_cur(2) - mGrid.minY);


		// Loop Over Close nodes
		for (int i = X - 1; i < X + 3; ++i)
		{
			for (int j = Y - 1; j < Y + 3; ++j)
			{
				for (int w = Z - 1; w < Z + 3; ++w)
				{
					if (i < mGrid.minX || j < mGrid.minY || w < mGrid.minZ ||
						i >= mGrid.minX + mGrid.mResolutionX || j >= mGrid.minY + mGrid.mResolutionY || w >= mGrid.minZ + mGrid.mResolutionZ)
						continue;

					MPMGridNode& node = mGrid.mGrid[i][j][w];

					Vector3d gridpos = Vector3d(i, j, w);

					// Calculate wip and dwip
					Vector3d dist = particle->Xp_cur - gridpos;
					double wip = getWip(dist);
					Vector3d Dwip = getdWip(dist);

					// Transfer Mass
					particle->Vp_next += wip * node.Vi_col_fric;

					// Transfer Affine Momentum
					particle->Bp_next += wip * node.Vi_col_fric * (gridpos - particle->Xp_cur).transpose();

					// Particle next Position
					particle->Xp_next += wip * node.Xi_bar;

					// Particle Grad V Update
					particle->grad_V += node.Vi_col * Dwip.transpose();
				}
			}
		}
	}
}

void MPMSolver::UpdateParticleState()
{
	for (MPMParticle* particle : mParticleSystem.GetVecParticles())
	{
		//Deformation Gradient Update
		particle->Fp_elastic_hat = particle->Fp_elastic_cur + DT * particle->grad_V * particle->Fp_elastic_cur;
		particle->Fp_plastic_hat = particle->Fp_plastic_cur;

		//Plastic and Projection
		Eigen::BDCSVD<Eigen::Matrix3d> svd(particle->Fp_elastic_hat, Eigen::ComputeThinU | Eigen::ComputeThinV);
		Matrix3d U = svd.matrixU();
		Matrix3d V = svd.matrixV();
		Vector3d Eps = svd.singularValues();
		Matrix3d EpsMat = DiagonalMatrix<double, 3>(Eps);
		Matrix3d ep = DiagonalMatrix<double, 3>(vectorLog(Eps));

		double d = 3.f; // Spatial Dimension

		Matrix3d ep_hat = ep - ep.sum() / d * Matrix3d::Identity();
		double dr = ep_hat.norm() + (LAMBDA_dry_sand + MU_dry_sand) / MU_dry_sand * ep.sum() * particle->alpha_cur;
		double dq;   

		if (dr < 0)
		{
			// do nothing
			ep = EpsMat;
			dq = 0;
		}

		else if (ep.sum() > 0 || ep_hat.norm() == 0)
		{
			ep = Matrix3d::Identity();
			dq = ep.norm();
		}

		else
		{
			Matrix3d Hp = ep - dr * ep_hat / ep_hat.norm();   // Note that this is diagonal Matrix. therefore applying exponential is done trivially.
			ep = MatrixExp(Hp);
			dq = dr;			
		}
		

		// Hardening
		particle->Qp_next = particle->Qp_cur + dq;
		double phi = H0 + (H1 * particle->Qp_next - H3) * exp(-H2 * particle->Qp_next);
		particle->alpha_next = (double)(sqrt(2.0 / 3.0) * (2.0 * sin(phi)) / (3.0 - sin(phi)));

		//finalize  Deformation 
		particle->Fp_elastic_next = U * ep * V.transpose();
		particle->Fp_next = particle->Fp_elastic_hat * particle->Fp_plastic_hat;
		particle->Fp_plastic_next = particle->Fp_elastic_next.inverse() * particle->Fp_next;
	}
}

void MPMSolver::UpdateCurState()
{
	for (MPMParticle* particle : mParticleSystem.GetVecParticles())
	{
		particle->alpha_cur = particle->alpha_next;
		particle->Bp_cur = particle->Bp_next;
		particle->Fp_cur = particle->Fp_next;
		particle->Fp_elastic_cur = particle->Fp_elastic_next;
		particle->Fp_plastic_cur = particle->Fp_plastic_next;
		particle->Qp_cur = particle->Qp_next;
		particle->Vp_cur = particle->Vp_next;
		particle->Xp_cur = particle->Xp_next;

		particle->alpha_next = 0;
		particle->Bp_next.setZero();
		particle->Fp_next.setZero();
		particle->Fp_elastic_next.setZero();
		particle->Fp_plastic_next.setZero();
		particle->Qp_next = 0.f;
		particle->Vp_next.setZero();
		particle->Xp_next.setZero();
	}
}

