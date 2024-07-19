#pragma once

#include <Eigen/Dense>
#include <Eigen/Core>

using namespace Eigen;

struct MPMGridNode
{
	double Mi;			// Grid Mass
	Vector3d Vi;		// rasterized velocity
	Vector3d Vi_col; //  Final Grid Velocity, before friction
	Vector3d Vi_col_fric; // Final Grid Velocity
	Vector3d Vi_star;	  // Velocity with explicit forces

	Vector3d Xi;			// Grid Node Position

	Vector3d Xi_bar;        // Grid Node Position moved by Vi_col

	Vector3d Fi;		    // Force Derived from Deformation Gradient of Particles

	friend class MPMSolver;

};

class MPMGrid
{
public:
	MPMGrid();
	virtual ~MPMGrid();

	friend class MPMSolver;

	void CreateGrid(int Xsize, int Ysize, int Zsize)
	{
		mGrid = (MPMGridNode***)malloc(Xsize * sizeof(MPMGridNode**));

		for (int x = 0; x < Xsize; ++x)
		{
			mGrid[x] = (MPMGridNode**)malloc(Ysize * sizeof(MPMGridNode*));

			for(int y=0;y<Ysize; ++y)
				mGrid[x][y] = (MPMGridNode*)malloc(Zsize * sizeof(MPMGridNode));
		}
			
	}

private:
	MPMGridNode*** mGrid;

	int			mResolutionX;
	int			mResolutionY;
	int			mResolutionZ;
	

	int			minX;		// 가장 왼쪽 
	int			minY;		// 가장 아랫쪽
	int			minZ;		// 가장 

	int			grid_length = 1;

};

