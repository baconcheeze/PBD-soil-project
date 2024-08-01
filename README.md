# Soil Simulation

- 주제 선정
  - Position Based Dynamics를 활용한 Soil Simulation 및 Screen-space volume rendering을 활용한 Soil 렌더링
 
- 참고 자료
  - Position Based Dynamics (by Matthias Müller Bruno Heidelberger Marcus Hennix John Ratcliff)
  - Parallel Particles (P2): A Parallel Position Based Approach for Fast and StableSimulation of Granular Materials (by D. Holz)
  - Real-Time Mud Simulation for Virtual Environments.pdf (by Daniel Holz, Adam Galarneau)
  - On the Stress–Force–Fabric Relationship for Unsaturated Granular Materials in Pendular States (by Ji-Peng Wang , Xia Li , Hai-Sui Yu)
  - Unified Particle Physics for Real-Time Applications (by Miles Macklin, Matthias Muller, Nuttapong Chentanez, Tae-Yong Kim)
 
    
  - Real­Time Rendering of Granular Materials (by Nynne Kajs)
  - An analytic BRDF for materials with spherical Lambertian scatterers (by Eugene d'Eon)


 
## 2024.07.02 
- Parallel Particles (P2): A Parallel Position Based Approach for Fast and Stable Simulation of Granular Materials 학습
- Particle간의 Friction, Spring, Damping Constraint가 있는 간단한 PBD 구현.
<img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/98a921a4-8c28-4ca6-ae0b-c2c96bdd20bd">

## 2024.07.03 
- On the Stress–Force–Fabric Relationship for Unsaturated Granular Materials in Pendular States 학습.
- PBD에 Adhesion Constraint 추가
- 3D로 변환 후 테스트
<img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/f09882df-22f3-42fa-b1e6-9fbb6b805f82">

## 2024.07.04
- 멀티 렌더 타겟의 view position을 blur하는 방식으로 진흙같이 뭉쳐져 있는 느낌이 나게 구현
<img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/cfd80342-38b9-4903-b1d1-bcd9c1375d43">

## 2024.07.05
- PBR 기본이론 학습
- Real­Time Rendering of Granular Materials(by Nynne Kajs) 학습
- 모래 (Granular Material)를 위한 PBR 이식



  - Diffuse
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/530e57a3-85e5-462c-8fa5-aa3f7263ba92">
  - Fresnel
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/37e63f77-5c4f-4b63-b164-d6d49af0fa55">
  - Glints
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/c5470e19-2767-4bfc-987f-82ce35045f38">
  - Porosity
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/82bf4793-3fd4-44f6-93d8-c8999c520434">
  - Transmission
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/3d51bcc3-ced5-4b5d-a3a0-b2530f790a75">
  - Combined
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/bfc5ee93-e6b6-407c-a04f-d23fe0d32ed6">

## 2024.07.08
- 모래 PBR을 PBD Particle 렌더링에 활용
- PBD로직 Compute Shader로 옮기는 작업 진행중.
  <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/e1417e3c-8ddf-4d7f-995f-b000ac2274fa">

## 2주차 목표
- PBD GPU로 처리하게 이식
- PBD Inner Particle Collision Detection (Continuous Collision Dectection, NeighborGrid Collision Detection)
- PBD Particle <-> Rigid Body Interaction 구현
- 흙 Particle이 떨어져서 풍차가 돌아가고, 쇠구슬이 떨어져서 쌓여있는 모래가 움푹 파이는 장면을 구현하는것이 목표.

## 2024.07.09
- PBD로직 Compute Shader로 옮기는 작업 완료.


  -<img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4a805bd7-8219-4ea4-b011-c29dab33951e">
  -<img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/39fcb1d7-a0f3-4775-9f82-1671eae4eb96">

 - 물성을 조절하기 위해 수치를 변경하던 도중 문제점 확인.
   - 정지마찰을 고정으로 줬을경우 (ie. 정지마찰계수 := 무한대 , delta = -velocity*tangent) 입자가 터져나가는 현상 확인  
    <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/2a5e6a51-b304-41ed-80f4-624409df91fe">

    - 문제원인으로 생각되는것 : 정지마찰로 인한 delta가 이중삼중적용되나 이 경우 iteration을 거쳐도 오류가 줄어들지 못함.  
     <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4fd67e59-d397-442f-8e33-0f01db93fb3c">
     - 입자 두개만 충돌시켜도 같은 문제가 발생하는걸 확인. 위는 원인이 아닌듯함
     - Stiffness Factor 1-(1-k)^1/n 을 안걸어서 발생했던 문제로 확인, k=0.99로 두고 걸었더니 해결.


    - Parallel Particles (P2): A Parallel Position Based Approach for Fast and StableSimulation of Granular Materials (by D. Holz) 를 XPBD로 적용시키면 어떨까 싶어서 XPBD 학습중.

## 2024.07.10
-모래 물성이 반영된 Granular PBD 로직 1차 완성
  - 전체 흐름


     <img src="https://github.com/user-attachments/assets/ee8faacb-152a-47e3-8779-3db92fc54b29">  

  
  
  - 가장 핵심인 입자간의 Contact Resolution 처리 :
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4cd9bc0c-dc01-48a5-961c-d2cefd6b1d0d"> 
    
  - Deriving Coefficients :
   https://github.com/user-attachments/assets/6b092687-b147-4217-a498-458aeabf35bb
   https://github.com/user-attachments/assets/c9eea572-8244-48ee-9007-362e602add80


```
float3 Constraint_SpringDamperFriction(inout float3 pos0, float3 pos1, float3 origin0, float3 origin1, float radius0, float radius1, float massinv0, float massinv1
	, float spring_coefficient, float damper_coefficient, float static_friction_coefficient, float kinetic_friction_coefficient, float adhesion_coefficient, int iteration_time 
	, inout float3 normaldelta, inout float3 tangentdelta)
{
	float3 norm = normalize((pos0 - pos1));
	float3 vel = (pos0 - origin0) - (pos1 - origin1);

	float3 tangent = (vel - dot(vel, norm) * norm);

	float d = length(tangent);

	
	if (d > 0.001)
		tangent = tangent / d;

	else
		tangent = (float3)0.f;

	float k = spring_coefficient;
	float c = damper_coefficient;
	float t = g_DT;


	float delta_spring;
	float delta_damper;

	float beta = massinv0 / (massinv0 + massinv1);

	delta_spring = -length(pos0 - pos1) + (radius0 + radius1);
	delta_damper = -dot(vel, norm);



	float k_pb = (t * t * k * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);
	float c_pb = (t * c * massinv0) / (1.f + t * c * massinv0 + t * t * k * massinv0);

	float alpha = 1.f - k_pb - c_pb;

	float k_pbb = 1 - c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha) - pow(alpha, 1.f / iteration_time);
	float c_pbb = c_pb * (1 - pow(alpha, 1.f / iteration_time)) / (1 - alpha);

	float lambda = dot(vel, tangent);
	float lamda_normal_before = (k_pb * delta_spring + c_pb * delta_damper);
	float lambda_normal = (k_pbb * delta_spring + c_pbb * delta_damper);

	float Area = PI * radius0 * radius0 * (1 -  (positive(delta_spring) / radius0  - 1.f) * (positive(delta_spring) / radius0 - 1.f));
	float Adhesion_Force = adhesion_coefficient * Area; // heuristic 힘계산, 정확하고 복잡한걸로 추후 수정 가능성 o

	float lambda_adhesion = Adhesion_Force * g_DT * g_DT * massinv0;

	float k_prime = 1 - pow((1 - 0.999), 1.f / iteration_time);	

	float lambda_friction = abs(lambda) <= static_friction_coefficient * (abs(lambda_normal)+ lambda_adhesion)
		? -k_prime * lambda : -k_prime * lambda * min(1.f, kinetic_friction_coefficient * (abs(lambda_normal) + lambda_adhesion));

	normaldelta += beta * (lambda_normal - lambda_adhesion / iteration_time) * norm;
	tangentdelta +=  beta* lambda_friction* tangent;

	return beta * (lambda_friction * tangent + lambda_normal * norm - lambda_adhesion / iteration_time * norm);




}
```


- Static Friction Coefficient: 0.3  // Kinetic Friction Coefficient: 0.3 // Adhesion Coefficient: 0.0
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/2f13c215-ca78-45df-a325-2f461a84378a"> 
- Static Friction Coefficient: 1.5  // Kinetic Friction Coefficient: 1.5 // Adhesion Coefficient: 0.0
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4c7ba685-b7de-4ad7-87a5-17ff3a4132dd"> 

- Static Friction Coefficient: 0.3  // Kinetic Friction Coefficient: 0.3 // Adhesion Coefficient: 0.2
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/85949d06-c0a9-411e-9572-85e782385b64"> 
- Static Friction Coefficient: 1.5  // Kinetic Friction Coefficient: 1.5 // Adhesion Coefficient: 0.2
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/bf245dda-99c8-4656-82d7-20cf22eb3f13">


- Granular 파티클과 상호작용할 Rigid Body와 Soft Body를 구현하기 위한 Extended Positional Dynamics 학습 및 구현중
  <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/a0b79324-3b7c-419d-b1e1-ec72c06d9d4e">


## 2024.07.11
  - 위의 PBD로 RigidBody내 파티클들의 위치를 시뮬레이션 한 뒤 Shape Matching 및 Volume Preserving Constraint를 통해 RigidBody 형태를 유지시키는 방법이 성능적으로 한계가 있다고 생각해
    Body에 통으로 XPBD를 적용시키기 위해 Detailed Rigid Body Simulation with Extended Position Based Dynamics 학습 및 구현중

## 2024.07.12
  - RigidBody XPBD에 Positional Constraint(Collision Constraint)을 반영한 Position Projection // Restitution, Friction 이 반영된 Velocity Projection 구현.


     <img src="https://github.com/user-attachments/assets/681a061a-9ed0-4c73-9b1e-e9d06539fd8c">
     <img src="https://github.com/user-attachments/assets/204d26e1-df56-47a6-a8a5-855d9611621d">

  - Iteration으로 Position만을 수정해나가는 Granular PBD , Timestep을 잘게 쪼개서 Position을 수정하고 velocity를 바로 이어서 수정해나가는 RigidBody XPBD를 융합하기 위해서
    Granular 파티클들의 업데이트 로직을 XPBD와 같게 만들 필요가 있지 않을까 생각, 바꿔보는중

## 2024.07.15
- 정지마찰 로직 작성
  
- 정지마찰이 상시로 적용된 상태 (static friction coefficient := infinity)

  <img src="https://github.com/user-attachments/assets/4032d331-be0e-43dc-b332-eaf471aae776">

- 마찰 on 토크 10  

 <img src="https://github.com/user-attachments/assets/2e4a806a-d6e4-4636-86b4-5d980fa8a0ab">

- 마찰 off 토크 10

 <img src="https://github.com/user-attachments/assets/dfc7d220-f7a7-4767-8199-1f58dbe9296a">

- Rigid Body 전체 흐름


   <img src="https://github.com/user-attachments/assets/46e01623-a67f-4ae6-b474-94bcf4cbcfc0">



-  Solve Collision Logic


<img src="https://github.com/user-attachments/assets/16758256-a37d-4371-a091-8defee3264e2">
            <img src="https://github.com/user-attachments/assets/3d7afff4-da46-435a-85d8-bc5c0b02454e">
            <img src="https://github.com/user-attachments/assets/b7f52595-63cc-4359-898c-ae452f969651">



- Solve Velocity Logic

  <img src="https://github.com/user-attachments/assets/63faca57-e767-46fa-a86f-afd148d81208">
            <img src="https://github.com/user-attachments/assets/5b4bb245-4d90-4b8c-920a-43a8f6f15368">



     - 정지마찰 positional impulse를 ∆_vt/|∆_vt | 로 줬을때의 문제점
       
       <img src="https://github.com/user-attachments/assets/a16d6131-4c9c-442c-a689-687532e36ea4">

       -> normal 방향으로 물체를 끄집어 올린것도 이 impulse를 줄경우 그대로 돌려버리기 때문에 normal 방향 projection이 없던일이 되서 물체를 뚫고 들어감.

     - 가장 단순한 방법으로 velocity solve 단계에서 tangent 방향 impulse를 -v_t 로 줬을때의 문제점
 
       <img src="https://github.com/user-attachments/assets/bdb828e4-8fc4-465e-a3c2-a68088bfe683">

       -> 가장 직관적인 방법인데 왜 이러는지 모르겠음, granular pbd에 friction을 줬을때와 같은 이유인가 싶어서 Stiffness Factor 1-(1-k)^1/n 를 걸어봐도 똑같이 문제 발생


     - 마찰과 restitution이 stable하게 적용된듯한 지금 상황 가장 큰 문제점.
 
	 <img src="https://github.com/user-attachments/assets/4952e8aa-e234-418f-8973-584c2b03b65b">

  	멈추지 않고 영원히 굴러가는 공
	

      
## 3주차 목표
- XPBD RigidBody와 PBD Granular Particle의 Interaction 구현

## 2024.07.16
  ## 당연하다고 생각하고 읽고 넘어갔던것들을 넘겨짚는 시간을 가졌습니다.

- ## Convergence rate of regularized newton rhapson method Iteration in PBD

  ## Definition of L-smoothness :

  ## A function f is "L-smooth"if $f(w') <= f(w) + \nabla f(w) \dot (w' - w) + L/2 ||w-w'||^2$
 
  ## if C is L-smooth and $\parallel\nabla C(x_*)\parallel$ > 0 and C(x) = 0 has solution

  ## Proof) By Definition of L-smoothness, 
  
  ## $C(x_{t+1}) <= C(x_t) + \nabla C(x_t) \cdot \bigtriangleup x_t + L/2 \parallel\bigtriangleup x_t\parallel^2$

  ## Since $C(x_t) + \nabla C(x_t) \cdot \bigtriangleup x_t = 0$
  it follows that

  ## $C(x_{t+1}) <= L/2 \parallel\bigtriangleup x_t\parallel^2 = L/2 \frac{C(x_t)^2}{\||\nabla C(x_t)\||^2} = L/2 \frac{C(x_t)}{\||\nabla C(x_t)\||^2}* C(x_t)$

  ## $\therefore \frac{C(x_{t+1})}{C(x_t)} <= L/2 \frac{C(x_t)}{\||\nabla C(x_t)\||^2}$

  ## By Initializing x_0 so that $C(x_0) < \delta_1 , ||\nabla C(x_t)||^2 > \delta_2 , \frac{\delta_1}{\delta_2} = \epsilon $

  ## $C(x_t) -> C(x_*)$ in   $\epsilon^t$ speed , 지수함수로 빠르게 수렴하기에 iteration count 5~20이면 만족스러운 결과가 얻어진다.

  ## if C is Linear function along $\nabla C(x)$ direction, L=0 therefore method converges to optimal point in just single iteration.

  ## Constraint의 상당수를 차지하는 거리 함수는 위의 $\nabla C(x)$ 방향 선형성이 만족되므로 Iteration 한번만에 Solve되버린다. 하지만 어제 순간적으로 헷갈렸던 바대로 Constraint 여러개에 Gauss-Seider 방식으로 여러 Linearized된 제약조건들을 풀어나가기 때문에 Iteration이 필요하다.

  ## 하나의 frame에 iteration만을 여러번 수행하는 PBD와 달리 XPBD는 하나의 frame을 여러 substep으로 나누고 delta time도 substep 수 만큼 나눠서 loop를 돌게 되는데 이 경우 delta time을 작아지게 해서 initial point x0를 optimal point로 덜 벗어나게 하기 때문에 $\epsilon$ 을

  ## quadratic 하게 더 작아지게 할수 있고 더 효율적인 수렴속도가 보장된다. 저자가 기존 PBD의 방법과 달리 XPBD에선 Timestep 쪼개기를 적용한것이 이 때문으로 추측된다.

  ## $\bigtriangleup x$ 를 $\nabla C(x)$ 와 나란하게 하는 또다른 이유 :

  ## Translation T(x)에 대해 Constraint C는 영향 받지 않아야 한다. ex) 박스메쉬의 world position이 translated 되어도 버텍스간의 거리는 동일

  ## C(x) = C(T(x) for any T

  ## $\therefore$ $\nabla C(T(x))$ $\cdot$ $\frac{\partial T}{\partial x}$ = $\Sigma \nabla_{x_i} C(x_i) = 0$

  ## 따라서 Linear Momentum conservation이 이루어진다.

  ## 마찬가지로 rotation에 대해서도

  ## $C(r_1,...,r_n) = C(r_1+r_1 \times \bigtriangleup p_1 , ... , r_n+r_n \times \bigtriangleup p_n)$ 이 되어야 한다

  ## $\nabla C(p)$ $\cdot$ $(r_1 \times \bigtriangleup p_1 , ... , r_n \times \bigtriangleup p_n)$ = 0

  ## $\Sigma_i \nabla_i C(p)$ $\cdot$ $(r_i \times \bigtriangleup p_i)$ = 0

   ## $\Sigma_i \bigtriangleup p_i$ $\cdot$ $(r_i \times \nabla_i C(p))$ = 0 holds for any  $\bigtriangleup p$

  ## 따라서 $\Sigma_i$ $(r_i \times \nabla_i C(p))$ = 0

   ## Angular Momentum conservation도 충족된다.
   


## 2024.07.17 
- XPBD와 continuum mechanics를 활용한 PBI method (Position-Based Dynamics Handles Updated Lagrangian Inelasticity)
- 그 밑바탕이 된 Drucker-Prager Elastoplasticity for Sand Animation의 MPM method
- 이를 이해하기 위해 필요한 continuum mechanics 학습중

## 2024.07.18
- "Drucker-Prager Elastoplasticity for Sand Animation"를 보고 일단은 CPU로만 구동되는 MPM Method Sand Simulation Code 1차 작성 완료. Test는 아직 돌려보지 않았습니다. 

## 2024.07.19
- Article에 나와있는데로 3D 그리드로 구현해서는 CPU로는 리얼타임 테스트가 불가능해 일단 2D로 변경, Rigid Body Signed Distance Field를 활용해 Collision 처리를 하기 위해 "Distance Fields for Rapid Collision Detection in Physically Based
Modeling" 학습

## 2024.07.22 3주차 결산
- PBD Particle -> XPBD의 인터렉션을 PBD Particle 하나 하나를 XPBD에서의 구형 Rigid Body와 똑같이 취급하는 방식으로 CPU에서 브루트 포스로 Collision Detection을 한 뒤에 XPBD Rigid 바디를 밀어 내게 하는 방식으로 구현
- 결과는 예상한바대로 나왔으나 모래의 거동이 봐도 봐도 마음에 들지 않아 이것저것 영상자료를 보던 와중
- https://www.youtube.com/watch?v=Bqme4WWuIVQ 영상을 보고 반해버려서 Material Point Method를 활용한 Sand 시뮬레이션 학습 및 구현

## 0. Overview
 <img src="https://github.com/user-attachments/assets/9b8175fc-e198-4599-a073-f73dbf4ec526">

## 1. Particle To Grid
   - Kernel Weight 계산
   -  <img src="https://github.com/user-attachments/assets/1e615b29-136b-4052-bdf2-b128a3e596a3">
   -  <img src="https://github.com/user-attachments/assets/073bae0e-f7f0-4d2e-9e44-8d68bbc71c66">
   

```
static float Bspline(float x) // Cubic Bspline
		{
			float W;
			x = fabs(x);

			if (x < 1)
				W = (x * x * x / 2.0f - x * x + 2 / 3.0f);

			else if (x < 2)
				W = (2 - x) * (2 - x) * (2 - x) / 6.0f;

			else
				W = 0;

			return W;
		}

		static float dBspline(float x) // Cubic Bspline derivative
		{
			float dW;
			float x_abs;
			x_abs = fabs(x);

			if (x_abs < 1)
				dW = 1.5f * x * x_abs - 2.0f * x;

			else if (x_abs < 2)
				dW = -x * x_abs / 2.0f + 2 * x - 2 * x / x_abs;

			else
				dW = 0;

			return dW;
		}



static float getWip(const Vector2f& dist) // 2D weight
		{
			return Bspline(dist[0]) * Bspline(dist[1]);
		}

		static Vector2f getdWip(const Vector2f& dist) // 2D weight gradient
		{
			return Vector2f(dBspline(dist[0]) * Bspline(dist[1]),
				Bspline(dist[0]) * dBspline(dist[1]));
		}



```


- 질량 계산
- <img src="https://github.com/user-attachments/assets/0f679316-e3ce-4d9f-aea9-c9a317e9b6b3">

```
float inMi = Wip * particles[p].Mp;
```


- 그 파티클이 전해주는 Velocity 계산
- <img src="https://github.com/user-attachments/assets/d4487c52-b829-438d-bd3b-d7882fbe45ea">
- <img src="https://github.com/user-attachments/assets/cc966b97-ddfc-4847-8f61-6306effe572f">

```
{
Vector2f inVi = Wip * particles[p].Mp *	(particles[p].Vp + Dp_scal * H_INV * H_INV * particles[p].Bp * (-dist));
}
```

- 파티클이 전해주는 힘 계산
- <img src="https://github.com/user-attachments/assets/64a6209a-9e7a-4cc9-a60e-fc3506731004">
- <img src="https://github.com/user-attachments/assets/89a43453-c035-402e-a4eb-0b8109019d04">
- <img src="https://github.com/user-attachments/assets/eb357f15-130a-4d3e-a963-09559f95f0fc">
- <img src="https://github.com/user-attachments/assets/63d0523f-e688-4284-ad8f-df7a906031eb">

```
void DrySand::ConstitutiveModel() {
        Matrix2f U, V;
        Vector2f Eps;
        Fe.svd(&U, &Eps, &V); // SVD decomposition

        Vector2f dFe = 2 * MU_dry_sand * Eps.inv() * Eps.log() +
            LAMBDA_dry_sand * Eps.log().sum() * Eps.inv();

        Ap = Vp0 * U.diag_product(dFe) * V.transpose() * Fe.transpose();
    }

{
	particles[p].ConstitutiveModel();
	Vector2f inFi = particles[p].Ap * dWip;
}
```

- Particle To Grid 최종 전달 
  
```
#pragma omp atomic
					nodes[node_id].Mi += inMi;

#pragma omp atomic
					nodes[node_id].Vi[0] += inVi[0];
#pragma omp atomic
					nodes[node_id].Vi[1] += inVi[1];

#pragma omp atomic
					nodes[node_id].Fi[0] += inFi[0];
#pragma omp atomic
					nodes[node_id].Fi[1] += inFi[1];



```

## 2. Grid Update

-  Velocity에 Mass 나눠주기 (== Kerner 적용 normalizing 작업)

```
nodes[i].Vi /= nodes[i].Mi;
```

- Force가 적용된 New Velocity 계산

- <img src="https://github.com/user-attachments/assets/ff1a0036-6de3-4aa2-8f9b-d2bc5ed20b3e">
```
nodes[i].Fi = DeltaTime * (-nodes[i].Fi / nodes[i].Mi + G);
				nodes[i].Vi += nodes[i].Fi;
```

- Signed Distance Field 를 통한 Collision과 Friction 처리 // 일단 SDF는 간단한 원과 선만
- Force가 적용된 Vi, Collision까지 적용된 Vi_Col, Collision 이후 Friction 까지 적용된 Vi_Fri 까지 나누어서 저장하는것을 유의
```
Vector2f center = Vector2f(150, 100);
		float radius = 50;

		/* Current distance between node and boundary. */
		float distance = (Xi - center).norm() - radius;
		
		if(distance<0)
		{
			Vector2f trial_position = Xi + DeltaTime * Vi_col;
			float trial_distance = (trial_position - center).norm() - radius;
			float dist_c = trial_distance - std::min(distance, 0.0f);

			Vector2f normal = (trial_position - center) / ((trial_position - center).norm() + 0.0001);

			/* Record collision and update node velocity. */
			if (dist_c < 0) 
			{
				Vi_col -= dist_c * normal / DeltaTime;
				

				//Friction
				/* Compute tangential velocity. */
				Vector2f Vt = Vi_col - normal * (normal.dot(Vi_fri));
				if (Vt.norm() > 1e-7) {
					Vector2f t = Vt / Vt.norm();
					/* Apply Coulomb's friction to tangential velocity. */
					Vi_fri -= std::min(Vt.norm(), CFRI * (Vi_col - Vi).norm()) * t;
				}
			}

			
		}
```

## 3. Grid To Particle
   - Velocity와 Affine Momentum Update (세 Vi중 최종 계산량인 Vi_fri으로 계산하는 것에 유의)
     <img src="https://github.com/user-attachments/assets/e5879dd7-b7a8-4074-9317-558b3e5c593d">

```
particles[p].Vp += Wip * nodes[node_id].Vi_fri;
					particles[p].Bp += Wip * (nodes[node_id].Vi_fri.outer_product(-dist));
```

## 4. Update Particle
   - Position 및 Velocity Gradient 업데이트 (둘다 Friction이 적용되기 전인 Vi_Col로 계산 (왜지???))
   - <img src="https://github.com/user-attachments/assets/c93d0fbc-fe16-45e5-a43d-d0414a42ca6a">
   - <img src="https://github.com/user-attachments/assets/1c54ea23-7f56-4c29-b5c2-9543e2b75112">

```
particles[p].Xp += Wip * (nodes[node_id].Xi + DeltaTime * nodes[node_id].Vi_col);
T += nodes[node_id].Vi_col.outer_product(dWip);
 ```

## 5. Deformation Gradient에 Plasticity, Hardening 반영
   - Deformation Gradient는 elastic 파트와 plastic 파트로 분해되어 관리됨
   - Plastic 파트는 그대로 두고 elastic 파트만 다음과 같이 업데이트
   - Projection 이후 elastic , plastic deformation gradient finalize
   <img src="https://github.com/user-attachments/assets/59866b6a-ec2c-4537-a4f0-0bdc5749d1e5">

   <img src="https://github.com/user-attachments/assets/4594b7cc-0d0d-43a6-bd40-1dc09584d8c8">
   

```
FeTr = (Matrix2f(1, 0, 0, 1) + DeltaTime * T) * Fe;
        FpTr = Fp;

 
```

```
 DrySand::Projection(Eps, &T, &dq);

        // Elastic and plastic state
        Fe = U.diag_product(T) * V.transpose();
        Fp = V.diag_product_inv(T).diag_product(Eps) * V.transpose() * FpTr;
 
```

- Projection
      <img src="https://github.com/user-attachments/assets/6cf254b5-cf64-4c01-b5e5-a4f4ec20bb19">

```
void DrySand::Projection(const Vector2f& Eps, Vector2f* T, float* dq) {
        Vector2f e, e_c;

        e = Eps.log();
        e_c = e - e.sum() / 2.0f * Vector2f(1);

        if (e_c.norm() < 1e-8 || e.sum() > 0) {
            T->setOnes();
            *dq = e.norm();
            return; 
        }

        float dg = e_c.norm() +
            (LAMBDA_dry_sand + MU_dry_sand) / MU_dry_sand * e.sum() * alpha;

        if (dg <= 0) {
            *T = Eps;
            *dq = 0;
            return; 
        }

        Vector2f Hm = e - dg * e_c / e_c.norm();

        *T = Hm.exp();
        *dq = dg;
        return; 
    }
```



- Hardening

- Projection에서 dg를 구할때 쓰이는 alpha값 업데이트
- <img src="https://github.com/user-attachments/assets/b709d0aa-267f-4ed9-9be3-58c2fb967736">
```
 // hardening
        q += dq;
        float phi = H0 + (H1 * q - H3) * exp(-H2 * q);
        alpha = (float)(sqrt(2.0 / 3.0) * (2.0 * sin(phi)) / (3.0f - sin(phi)));
```


- Particle 및 Node 구성요소

```
/* Particle Info */
        float Vp0; // Initial volume 
        float Mp;  // Particle mass 
        Vector2f Xp; // Particle position
        Vector2f Vp; // Particle Velocity
        Matrix2f Bp; // Affine Momentum
	Matrix2f Fe, FeTr; // Elastic deformation 최종, 프로젝션 전
	Matrix2f Fp, FpTr; // Plastic deformation 최종 , 프로젝션전
	Matrix2f Ap; // 힘계산 중간과정에 사용되는 Matrix

/* Node Info */
		float Mi; // Node mass

		Vector2f Xi;     // Node position (월드좌표)
		Vector2f Vi;     // Node velocity, Force 적용
		Vector2f Vi_col; // Node velocity, Force, Collision 적용
		Vector2f Vi_fri; // Node velocity, Force, Collision, Friction 적용

		Vector2f Fi; // Force applied to the node
```
  
-   
Friction Coefficient 0.3

RHO_dry_sand  1600

E_dry_sand  353700

V_dry_sand  0.3

LAMBDA_dry_sand = E_dry_sand * V_dry_sand / (1.0f + V_dry_sand) / (1.0f - 2.0f * V_dry_sand)

MU_dry_sand = E_dry_sand / (1.0f + V_dry_sand) / 2.0

H0 35

H1 9

H2 0.2

H3 10

GridSize 300x300 , Particle Count 500, dt 0.0005 일때의 영상 :  https://www.youtube.com/watch?v=QS7OU6l7vhI

MPMSDFSimulate()의 1프레임 경과시간: 19ms 

## 4주차 과제
1. Distance Fields for Rapid Collision Detection in Physically Based Modeling 를 학습해서 단순한 정육면체, 구 외에의 오브젝트에서도 Signed Distance Field를 구하고 모래와 충돌 시키기

  <img src="https://github.com/user-attachments/assets/1b24cf7e-ec16-45ab-8b96-9473742ed0bb">
  
  <img src="https://github.com/user-attachments/assets/b6290ed2-a058-4d48-994f-4256957a8691">
2. MPM Sand Particle <- Rigid Body의 인터렉션은 지금 MPM으로 구현되 있는 상황. Collision 이후 속도 처리를 움직이는 오브젝트에도 영향 받는 방식으로 변경 (ex. Vi_Col = V_RigidBodyObject + Something), Friction도 RigidBody의 각속도까지 고려한 상대속도를 반영하도록 변경
- MPM Sand Particle -> Rigid Body의 인터렉션이 챌린징 한 부분.
  1안: Particle 하나 하나를 모두 조그만 rigidbody 구 오브젝트로 취급하여 RigidBody와 Collision Detection을 하고 XPBD 적용.
  2안: Grid 노드들에 있는 속도와 Mass 정보를 활용, 이를 rigidbody와 겹쳐서 rigidbody에 impulse 적용.

3. 2의 결과까지 만족스럽다고 판단되면 모든 로직 GPU로 옮기고 3D로 구현, Particle 및 Grid 개수를 최대한 줄이고 DT값을 최대한 올려보기
  
## 07.23  
- ConstituveModel 이리저리 가지고 놀다가 particle들의 Particle과 Rigid 바디의 Constituve Model을 다르게 해주기만 하면 Rigid바디 <-> Particle Interaction을 얻을수 있을것 같음을 확인. 

- <img src="https://github.com/user-attachments/assets/24898737-0d28-43c0-9eaf-41013950db6d">


- "A Moving Least Squares Material Point Method with Displacement Discontinuity and Two-Way Rigid Body Coupling" 학습중

  

## 07.24  
- CPU 병렬화를 하고 DT를 최대한 끌어올려서 real time 환경에서의 거동 테스트, Particle count 500, Grid Size 300x300, dt 0.005, 1 frame 경과시간 1ms 미만
- <img src="https://github.com/user-attachments/assets/40f7cf67-c55b-4437-bf8d-e2bc2468415b"> 

- Hyper elastic body의 constituve model을 적용해서 테스트 해봤으나 물체의 형태가 유지되지 않는 문제 발생.
-<img src="https://github.com/user-attachments/assets/37c28f29-2cb3-49da-9c40-fe30a45c7549">

## 07.25 
- Moving Least Square 근사를 활용해 MPM을 최적화하는 기법 적용
- 중요변경 1.

변경전

  <img src="https://github.com/user-attachments/assets/52650957-acfb-412a-8f54-31bed3e2e8d2">
  
변경후
   
  <img src="https://github.com/user-attachments/assets/d4f52710-252d-4029-b754-1fccfbccae58">


  - 이로 인해
```
Vector2f inFi = particles[p].Ap * dWip;

#pragma omp atomic
					nodes[node_id].Fi[0] += inFi[0];
#pragma omp atomic
					nodes[node_id].Fi[1] += inFi[1];

```

    위 처럼 Particle To Grid 단계에서 Fi 역시 전달해주고 Grid에서 이를 Velocity에 다시 적용시켜줘야 됐던 부분이

```
double Dinv = Dp_scal * H_INV * H_INV;
Matrix2f stress = -DeltaTime * (Dinv * particles[p].Ap)/ particles[p].Mp;
Matrix2f affine = stress + particles[p].Cp;
Vector2f NewVal = Wip * particles[p].Mp * (particles[p].Vp + affine * (-dist));
```

      위 처럼 P2G 단계에서부터 Force를 New Velocity에 적용할수 있게 되어 atomic operation인 P2G 단계에서의 Force 전달을 생략할수 있게 되었다.

     - 중요변경 2. 
     
     <img src="https://github.com/user-attachments/assets/824b0e6d-387c-4b3b-a245-1b2b53f34c23">

     Velocity Gradient Field를 전단계에 이미 구해놓은 Cp로 근사한다. (Cp는 Bp를 통해 간단히 계산가능)

```
particles[p].Xp += Wip * (nodes[node_id].Xi + DeltaTime * nodes[node_id].Vi_col);
T += nodes[node_id].Vi_col.outer_product(dWip);
```

     모든 파티클들이 인접노드들을 순회하며 행했던 Velocity Gradient와 Position Update가 생략되고 
     Particle Position Update는 

```
     particles[p].Xp += DeltaTime * particles[p].Vp;
```

루프문을 돌 필요없이 이 와 같이 가장 간단한 형태로 축약된다.


Paricle Count : 7000 , dt: 0.005, 중력가속도: -10 , 1 frame 경과 시간 4ms 미만


 <img src="https://github.com/user-attachments/assets/f9bb170e-e687-4915-b806-6383d2e8d795">

 <img src="https://github.com/user-attachments/assets/9523adce-4d32-4760-a416-efe7ceb317aa">



- CPIC을 통해 Rigid Body <-> Particle 인터렉션을 하는 Pseodo Code 작성
```
// CDF

// Grid Node에 저장할것
// d, A, T , rigidbody particle closest to node (body마다) := rpcb
// rigidbody closest to node := rc

// Particle 단위로 저장할것
// d, A, T , normal (body 마다)

//======================================  1. Grid CDF

// 1. Grid Node 마다 d,A,T,rpcb, rc 초기화

// 2. 모든 rigid body의 모든 rigid particle을 돌며
// d,A,rpcb,T 계산

// 3. 모든 grid node를 돌며 rc 계산


//====================================== 2. Particle CDF

// 1. 인접 커널 Node들을 돌며 하나라도 A == 1이라면 particle의 A = 1로 세팅 (Easy~)

// 2. Tpr 계산  ( https://yuanming.taichi.graphics/publication/2018-mlsmpm/mls-mpm-cpic.pdf   eq. 21)

// 3. A == 1 이고 Tpr > 0 이면 T = 1, A==1이고 Tpr < 0 이면 T = -1, A==0이면 T=0

// 4. A == 1이라면 d와 normal 역시 계산

//====================================== 3. P2G

// 1. MPM P2G As Usual

// 2. 인접노드들을 돌며 particle과의 comptatiblity 확인 
//  How? => 모든 body k에 대해서 node_T[k] == particle_T[k] == 1 or node_T[k] == particle_T[k] == -1 or node_T[k] == 0 or particle_T[k] == 0 을 만족하는지 확인
// 하나의 body와 라도 만족 안하면 incompatible!

// Compatible 한 경우에만 v, m Transfer (https://yuanming.taichi.graphics/publication/2018-mlsmpm/mls-mpm-cpic.pdf  eq.23 , eq.24)

// ===================================== 4. Grid MPM Update as usual

// ===================================== 5. G2P

// 1. 모든 파티클에 대해 모든 인접노들을 돌며 P2G때와 마찬가지 방법으로 Compatiblity Check!

// 2. incompatible 한 경우와 Compatible 한 경우 구분해서 g_v 계산

// 3. new_v += weight * g_v  , new_C update as usual

// 4. Penalty Force f_penalty 계산 후 new_v += dt * f_penalty / p_mass; (https://yuanming.taichi.graphics/publication/2018-mlsmpm/mls-mpm-cpic.pdf eq.22)

// 5. ** Particle Advection

// 6. ** Rigidbody Advection


// 부록 1. g_v 구하기

//r_body = grid_r[base + offset]                                      // Node에서 가장 가까운 body
//temp = base + offset                                                // 노드 인덱스
//r_id = grid_rp[temp[0], temp[1], r_body]                            // 그 body의 rigid particle중 Node와 가장 가까운것

//line = (x_r[r_id + 1, r_body] - x_r[r_id, r_body]).normalized()     // rigid body 파티클이 속해있는 라인 (3차원이었으면 triangle이었겠으나 2차원이므로 line)
//pa = x[p] - x_r[r_id, r_body]
//np = (pa - pa.dot(line) * line).normalized()                        // particle -> line으로 내린 수선 := np
//sg = (v[p] - v_rp[r_id, r_body]).dot(np)                            // particle과 rigidbody 파티클의 np 방향 상대속도 := sg
//if sg > 0:													      // sg > 0 이면 벗어나고 있다는 뜻이므로 g_v = v[p] 그대로
//g_v = v[p]
//else:
//vt = (v[p] - v_rp[r_id, r_body]) - sg * np                          // 탄젠트 방향 상대속도
//xi = max(0, vt.norm() + dy * sg)                                    // Projection
//g_v = vt.normalized() * xi + v_rp[r_id, r_body]

//# accumulate angular momentum
//rp = x_rp[r_id, r_body] - x_r[n_rseg, r_body]                       // rigid particle의 center of mass 기준 상대 좌표
//weight = w[i][0] * w[j][1]										  
//mvp = p_mass  * (v[p] - g_v)										  // 모멘텀
//Mt += weight * rp[0] * mvp[1] - rp[1] * mvp[0] # cross product for 2D   // Angular 모멘텀 


// 부록 2. Rigid Body Advection


 

//# rigid body advection
// 
// 1. 관성 모멘텀 J_line과 모멘텀 변화 Mt로 각속도 omega를 업데이트
//dw = Mt / J_line
//omega[None] += dw

// 2. 모든 rigid바디 파티클마다 속도 계산
//og_Vec = ti.Vector([0.0, 0.0, omega])
//for p, body in x_rp :
//rp = x_rp[p, body] - x_r[n_rseg, body]
//rp_Vec = ti.Vector([rp[0], rp[1], 0.0])
//vrp = og_Vec.cross(rp_Vec)
//#print(vrp)
//v_rp[p, body] = ti.Vector([vrp[0], vrp[1]])

// v_rp를 이용해서 x_rp, x_r 업데이트
//for p, body in x_rp :
//x_rp[p, body] = x_rp[p, body] + dt * v_rp[p, body]
//for j in ti.static(range(n_bodies)) :
//	for i in range(n_rseg - 1) :
//		x_r[i + 1, j] = (x_rp[i, j] + x_rp[i + 1, j]) / 2.0
//		x_r[0, j] = 2 * x_rp[0, j] - x_r[1, j]
//		x_r[n_rseg, j] = 2 * x_rp[n_rseg - 1, j] - x_r[n_rseg - 1, j]
//		


```

## 07.26

- Colored Distance Field와 Moving Least Square를 활용한 RigidBody <-> MPM particle 커플링 코드 작성시작
- Colored Distance Field를 매프레임 기록하고 Moving Least Square을 통해 RigidBody까지의 Distance, Normal을 근사하는 작업까지 테스트
- <img src="https://github.com/user-attachments/assets/ad5482de-78bd-4774-a711-53d6f417736c">

- Particle To Grid 단계에서 Colored Distance Field로 Compatibility를 체크하고 컴패터블한 Grid에만 Information을 전달해줬을 경우 테스트
- <img src="https://github.com/user-attachments/assets/403af10c-bba8-43d3-a88c-fdd62e88f9da">


## CDF-MLS-RIGID BODY COUPLING OVERVIEW

<img src="https://github.com/user-attachments/assets/5b3098e4-8dbb-40fc-89cb-c20fe12f615e">

0. Initialize 단계
   - RigidBody의 바운더리를 따라서 RigidParticle 생성
1. Rigid Particle -> Grid 정보 전달 (A,T,D)
2. Grid Particle -> MPM Particle 정보 전달
3. MPM Particle -> Grid 정보 전달 (Compatibility 연산 후 수행 Compatibility는 충돌 여부와 연관 o)
4. 일반적인 MPM Grid Update 진행
5. Grid -> MPM Particle 정보 전달 (마찬가지로 Compatibility 연산 후 수행)
6. Rigid Body Advection, MPM Particle Advection 수행

## 1. Rigid Particle -> Grid 정보 전달

<img src="https://github.com/user-attachments/assets/ca5bd91b-0dbf-482a-9b65-ba81d8529318">


- A : 그리드 점 에서 해당 Rigid Particle이 속해있는 triangle(2차원의 경우 line) 까지 Distance가 Valid한지 여부 (해당 line으로의 Projection이 그 line 위에 존재 하는지 여부)
- T : A가 invalid이면 0, line(triangle)의 바깥쪽이면 1, line(triangle)의 안쪽이면 -1
- D : Distance (절대값)
- Closest Body : 가장 가까운 RigidBody (하나만)
- Closest Rigid Particle : Body마다 가장 가까운 RigidParticle 하나씩 기록

```
void MPMCdf::UpdateCdf(const std::vector<MPMRigidBody*>& inRigidBody)
	{
		// Initialize node cdf
		for(int i=0;i<CDFGrid.size();++i)
			for (int j = 0; j < CDFGrid.size(); ++j)
			{
				MPMCDfNode& node = CDFGrid[i][j];

				for (int k = 0; k < inRigidBody.size(); ++k)
				{
					// Initialize A
					node.A_ib[k] = 0;
					// Initialize T
					node.T_ib[k] = 0;
					// Initialize D
					node.D_ib[k] = -1;
					// Initialize ClosestRigidParticle
					node.ClosestRigidParticle[k] = -1;
					
				}

				node.ClosestBody = nullptr;
			}

		//
		for (int k = 0; k < inRigidBody.size(); ++k)
		{
			for (int p = 0; p < inRigidBody[k]->vec_RigidParticleLocation.size(); ++p)
			{
				int index = inRigidBody[k]->vec_RigidParticleLocation[p];

				// Line AB 
				Vector2f A = inRigidBody[k]->vec_Vertex_World[inRigidBody[k]->vec_Index[index]];
				Vector2f B = inRigidBody[k]->vec_Vertex_World[inRigidBody[k]->vec_Index[index+1]];
				
				Vector2f ba = B - A;

				int y = static_cast<int>((inRigidBody[k]->vec_RigidParticle_World[p][1] - Translation_xp[1]) * H_INV);
				int x = static_cast<int>((inRigidBody[k]->vec_RigidParticle_World[p][0] - Translation_xp[0]) * H_INV);

				Vector2f base(x, y);

				// Loop over kernel domain
				for(int i=x-10;i<x+10;++i)
					for (int j = y-10; j < y+10; ++j)
					{						
						if (i >= X_GRID || i < 0 || j >= Y_GRID || j < 0)
							continue;

						Vector2f pa = Vector2f(i,j) * DX + Translation_xp - A;

						float h = pa.dot(ba) / ba.dot(ba);

						if (h >= 0 && h <= 1)  // node(ij) is valid to line (AB)
						{
							CDFGrid[i][j].A_ib[k] = 1;
							float dist = (pa - h * ba).norm();

							float det = pa[0] * ba[1] - pa[1] * ba[0];

							if (CDFGrid[i][j].T_ib[k] == 0) // Check if it is first input
							{
								if (det > 0) // node(ij) is outside of line 
									CDFGrid[i][j].T_ib[k] = 1;

								else
									CDFGrid[i][j].T_ib[k] = -1;

								CDFGrid[i][j].D_ib[k] = dist;
								CDFGrid[i][j].ClosestRigidParticle[k] = p;
							}


							else  // if it's not, check if it has smaller distance
							{
								if (dist < CDFGrid[i][j].D_ib[k]) // only update if it is closer to the line
								{
									if (det > 0) // node(ij) is outside of line 
										CDFGrid[i][j].T_ib[k] = 1;

									else
										CDFGrid[i][j].T_ib[k] = -1;

									CDFGrid[i][j].D_ib[k] = dist;
									CDFGrid[i][j].ClosestRigidParticle[k] = p;
								}
							}

							 
							

						}
					}
			}
		}



		for (int i = 0; i < CDFGrid.size(); ++i)
			for (int j = 0; j < CDFGrid.size(); ++j)
			{
				MPMCDfNode& node = CDFGrid[i][j];

				for (int k = 0; k < inRigidBody.size(); ++k)
				{
					float d_min = 0;

					if (node.A_ib[k] == 1)
					{
						if (node.ClosestBody == nullptr)
						{
							d_min = node.D_ib[k];
							node.ClosestBody = inRigidBody[k];
						}

						else
						{
							if (node.D_ib[k] < d_min)
							{
								d_min = node.D_ib[k];
								node.ClosestBody = inRigidBody[k];
							}
								
						}
					}
						

				}

				
			}
			
	}
}
```

## 2. Grid Particle -> MPM Particle 정보 전달
- A: MPM Particle 주변 Grid [-1,2] x [-1,2] 하나라도 A값이 Valid이면 MPM Particle의 A값도 Valid

```
if(mCdf->CDFGrid[i + x][j + y].A_ib[k] == 1)
	particles[p].A_pb[k] = 1;
```

- T: Grid Distance * Grid T * Kernel Weight를 합산 하여 양수이면 1, 아니면 -1 , A가 invalid일경우 T는 0

  <img src="https://github.com/user-attachments/assets/f09ca509-0eaf-478f-a5be-029c7972088e">

```
Tpr += Wip * mCdf->CDFGrid[i + x][j + y].D_ib[k] * mCdf->CDFGrid[i + x][j + y].T_ib[k];

if (particles[p].A_pb[k] == 1)
				{
					if (particles[p].T_pb[k] == 0)
					{
						if (Tpr > 0)
							particles[p].T_pb[k] = 1;

						else
							particles[p].T_pb[k] = -1;
					}	
```  



- Particle의 T값을 시각화: 빨간색은 T == 1 , 파란색은 T == -1 , 검은색은 T == 0

  <img src="https://github.com/user-attachments/assets/ad5482de-78bd-4774-a711-53d6f417736c">





- Distance와 Normal을 MLS를 통해 근사

- MLS란
임의의 일변수/다변수 연속함수가 주어졌을때

  <img src="https://github.com/user-attachments/assets/4821eead-553e-4f6e-a290-baceb2cf4f19">

다음과 같은 형태의 다항함수로 근사하는 기법
  
  <img src="https://github.com/user-attachments/assets/11c7149b-4ad9-4992-8da0-602006879468">

공식
 
 <img src="https://github.com/user-attachments/assets/c065689d-013e-4949-8099-637cddb002f1">
  
- MLS를 활용해 MPM Particle 점 주변 Grid에서의 정보들을 활용해 해당 MPM Particle에서의 Function Value (== Distance) 와 Gradient(== Normal) 을 Reconstruct

  <img src="https://github.com/user-attachments/assets/1184d444-8c70-461a-ab19-012652386603">


- Distance와 Normal을 근사하는 Code ( 자꾸 한번씩 nan으로 터지는 원인이 M의 역행렬을 구해주는데 determinant 예외처리를 안해줘서임을 확인, 해줬다)
```
Eigen::MatrixXf Q(16, 3);
Eigen::MatrixXf D(16, 16);
Eigen::MatrixXf M(3, 3);
Eigen::VectorXf v(16);

for (int y = bni; y < 3; y++) {
					for (int x = bni; x < 3; x++) {
Q(N,0) = 1; Q(N, 1) = -dist[0]; Q(N, 2) = -dist[1];
D(N,N) = Wip;
v[N] = mCdf->CDFGrid[i + x][j + y].D_ib[k] * mCdf->CDFGrid[i + x][j + y].T_ib[k];
}}

M = Q.transpose() * D * Q;
					
if(M.determinant() > 0)
{
Eigen::Vector3f result = M.inverse() * Q.transpose() * D * v;

particles[p].D_pb[k] = result[0];
particles[p].N_pb[k] = Vector2f(result[1], result[2]) / (Vector2f(result[1], result[2]).norm());
int asdf = 0;
}

```


## MPMParticle -> Grid (Compatiblity Check)
- Particle과 Grid 모두 물체들 밖에 있거나 Particle과 Grid 둘중 하나라도 invalid 하다면 Compatible (충돌처리 x)  아니라면 incompatible(충돌처리 o)
- Compatible한 Grid Node 에만 MPMParticle 정보를 전달해준다.

```
// Check Compatibility
int flag = 1;
// For All Bodies
for (int k = 0; k < RigidBodies.size(); ++k)
{
if ((particles[p].T_pb[k]>0 && mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k]>0)
	|| particles[p].T_pb[k] * mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k] == 0)
	continue;

else
	flag = 0;

}
```

## Grid -> MPM Particle 
- 위와 마찬가지로 Compatibility Check!

- 이번엔 incompatible한 경우 (충돌 처리, velocity 재조정 작업 진행)
1. 노멀 방향 상대속도를 구해서 0보다 크다면 벗어나고 있다는 뜻이므로 Original Velocity 그대로 둔다


```
float sg =  (originalvel - body->vec_RigidParticleVelocity[p]).dot(np); // 노멀 방향 상대속도				

if (sg > 0) // 벗어나는중
	Velocity = originalvel;
```


2. 아니라면 노멀 방향 상대 속도를 0으로 만들어 버리고 탄젠트 방향 상대 속도에 friction을 적용 (현재는 가장 간단하게 그냥 tangent 방향 속도도 없애버리는중 (Sticky Collision))


```
else // Approaching
	{
		float _dynamic_friction_coefficient = 0.9;

		Vector2f vt = (originalvel - body->vec_RigidParticleVelocity[p]).dot(line) * line;
		float xi = vt.norm() + _dynamic_friction_coefficient*sg;
		if (xi < 0)
			xi = 0;

		Velocity = body->vec_RigidParticleVelocity[p];//Vector2f(0);// body->vec_RigidParticleVelocity[p];
							
	}
```


3. Rigid Body Advection에도 필요한 Momentum 합산
 
```
Vector2f rp = body->vec_RigidParticle_World[p] - body->Translation;
Vector2f mvp = Wip * particles[p].Mp * (particles[p].Vp - Velocity);
AngularMomentum += rp[0] * mvp[1] - rp[1] * mvp[0];
```



## Penalty Force 적용
- 정확히 뭔지는 모르겠음. 물체 바깥으로 힘을 작용시켜준다.
 <img src="https://github.com/user-attachments/assets/e19ff984-394b-4a33-ae32-2a8d57b33622">

```
//Penalty Force
				
for (int k = 0; k < RigidBodies.size(); ++k)
{
	if (particles[p].T_pb[k] * particles[p].D_pb[k] < 0)
	{
		auto penalty = particles[p].D_pb[k] * particles[p].N_pb[k] * 5;
		particles[p].Vp += penalty * DeltaTime;

	}
}
```

## RigidBody Advection 적용

- 현재는 각운동만 적용시키고 있다.

```
RigidBodies[0]->Angular_Velocity += AngularMomentum / (RigidBodies[0]->Inertia);
```
  

 
	
   
  결과
  1. https://www.youtube.com/watch?v=tsLTYXdePdM
  2. https://www.youtube.com/watch?v=QILxCrJWBQ8
  3. https://www.youtube.com/watch?v=AS3-6qwPmFY


## MLS 최적화
    
- Moving Least Square 근사를 활용해 MPM을 최적화하는 기법 적용
- 중요변경 1.

변경전

  <img src="https://github.com/user-attachments/assets/52650957-acfb-412a-8f54-31bed3e2e8d2">
  
변경후
   
  <img src="https://github.com/user-attachments/assets/d4f52710-252d-4029-b754-1fccfbccae58">


  - 이로 인해
```
Vector2f inFi = particles[p].Ap * dWip;

#pragma omp atomic
					nodes[node_id].Fi[0] += inFi[0];
#pragma omp atomic
					nodes[node_id].Fi[1] += inFi[1];

```

위 처럼 Particle To Grid 단계에서 Fi 역시 전달해주고 Grid에서 이를 Velocity에 다시 적용시켜줘야 됐던 부분이


```
double Dinv = Dp_scal * H_INV * H_INV;
Matrix2f stress = -DeltaTime * (Dinv * particles[p].Ap)/ particles[p].Mp;
Matrix2f affine = stress + particles[p].Cp;
Vector2f NewVal = Wip * particles[p].Mp * (particles[p].Vp + affine * (-dist));
```


위 처럼 P2G 단계에서부터 Force를 New Velocity에 적용할수 있게 되어 atomic operation인 P2G 단계에서의 Force 전달을 생략할수 있게 되었다.

     
 - 중요변경 2. 
     

<img src="https://github.com/user-attachments/assets/824b0e6d-387c-4b3b-a245-1b2b53f34c23">

Velocity Gradient Field를 전단계에 이미 구해놓은 Cp로 근사한다. (Cp는 Bp를 통해 간단히 계산가능)



```
particles[p].Xp += Wip * (nodes[node_id].Xi + DeltaTime * nodes[node_id].Vi_col);
T += nodes[node_id].Vi_col.outer_product(dWip);
```


모든 파티클들이 인접노드들을 순회하며 행했던 Velocity Gradient와 Position Update가 생략되고 
Particle Position Update는 


```
     particles[p].Xp += DeltaTime * particles[p].Vp;
```


루프문을 돌 필요없이 이 와 같이 가장 간단한 형태로 축약된다.


Paricle Count : 7000 , dt: 0.005, 중력가속도: -10 , 1 frame 경과 시간 4ms 미만


## 5주차 과제
1. Stability 테스트
   - Rigid Body를 다양하게 만들어보고 각종 다양한 상황에서 Stable하게 돌아가는지 테스트

2. XPBD RigidBody Phisics Simulation을 적용시켜
   Rigid <-> Rigid는 XPBD, Sand <-> Sand는 MPM, Sand <-> Rigid는 MLS-CDF-MPM으로 처리 하는 것을 테스트

3. GPU로 옮기는 작업 후 테스트, 이 후 3D로 옮기는 작업

4. 최적화 방법을 최대한 적용해본다
   - "Principles towards Real-Time Simulation of Material Point Method on Modern GPUs (GDC and GTC 2022)" 공부하기
   
## 07.30
- 경계면의 바깥쪽(빨간색)과 안쪽(파란색)은 부호만 다를뿐 완전히 같은 동작을 해야하기 때문에 같은 상황에서 똑같은 결과가 나와야 하는데 바깥쪽 면은 정상적으로 모래를 밀어내나, 안쪽 면은 모래가 뚫고 지나가는 문제가 있어 해결중입니다.

- 정상 작동
  
     <img src="https://github.com/user-attachments/assets/eb879a64-2eb1-4dd9-adbf-0a3470910aa3">

- 문제 발생
  
     <img src="https://github.com/user-attachments/assets/11ff8a63-9130-4cd4-8284-a51c9f50f03a">

- orientation 적용 실험에 cos(PI)을 넣으면 문제가 생기나 -1을 넣으면 정상적으로 동작하는것을 확인

## 07.31 
- 이틀동안 골머리를 앓던 문제 세개 해결
  1. Rigid Body에 적용되던 Angular Advection이 여러번 테스트를 돌릴때마다 결과가 다르게 나오고. 그 결과가 물리적으로 올바르지 않아 보이던 문제.

기존의 다음과 같이 (이전 프레임 파티클 Velocity - 이번 프레임 파티클 Velocity)로 Momentum을 계산하던것을. 
 
```
//Angular Momentum
Vector2f rp = body->vec_RigidParticle_World[p] - body->Translation;
Vector2f mvp = Wip * particles[p].Mp * (particles[p].Vp - Velocity);
AngularMomentum += rp[0] * mvp[1] - rp[1] * mvp[0];
```

(이번 프레임의 응력과 중력가속도가 적용된 Velocity - 이번 프레임 최종 파티클 Velocity) 로 Momentum을 계산해줬더니 훨씬 그럴듯하고 안정적인 결과가 나옴

```
//Angular Momentum
Vector2f rp = body->vec_RigidParticle_World[p] - body->Translation;
Vector2f mvp = Wip * particles[p].Mp * (nodes[node_id].Vi_norigid - Velocity);// (originalvel - Velocity);
AngularMomentum += rp[0] * mvp[1] - rp[1] * mvp[0];
```

2. Orientation 계산할때의 조그마한 오차가 큰 오류를 발생시키는 문제 (ex) orientation 계산에 cos(PI)를 넣을때와 -1를 넣을때 결과가 크게 차이남.

CDF Grid의 T를 계산할때 기존의 determinant가 0보다 크면 오른쪽에 있다고 판정을 내리고 T를 1로 주던 코드를 determinant가 epsilon(1e-5)보다 크면 오른쪽에 있다고 판정을 내리는 코드로 바꿨더니 해결

```
float det = pa[0] * ba[1] - pa[1] * ba[0];

if (CDFGrid[i][j].T_ib[k] == 0) // Check if it is first input
{
	if (det > epsilon) // node(ij) is outside of line 
		CDFGrid[i][j].T_ib[k] = 1;

	else
		CDFGrid[i][j].T_ib[k] = -1;
}
```

3. 이틀 내내 고민했던 가장 까다로웠던 문제인 물체의 정가운데에 모래를 떨어뜨릴때 물체의 수평이 유지되지 않고 모래가 물체를 뚫고 들어가는 advection error가 쌓이다가 simulation이 터져버리는 문제
   
   G2P 단계에서 Compatibility 체크를 할때  || (particles[p].T_pb[k] < 0 && mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k] < 0) 조건 한줄 추가해준것으로 문제가 해결됐으나
   왜, 어떤 원리때문에 문제가 해결된것인지는 모름. 그냥 됨.
   

```
if ((particles[p].T_pb[k] > 0 && mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k] > 0)
|| (particles[p].T_pb[k] < 0 && mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k] < 0)
|| particles[p].T_pb[k] * mCdf->CDFGrid[node_base_X + x][node_base_Y + y].T_ib[k] == 0)
	continue;
```

- 수정 전

   <img src="https://github.com/user-attachments/assets/7a44d04b-a6e5-44f9-9857-5ac6ae78a6b1">

- 수정 후

   <img src="https://github.com/user-attachments/assets/e8126edd-982b-4a21-9465-d3d54a8567cb">

- 여전히 Advection error로 물체를 뚫고 지나가는 부분이 보이나 이를 파티클을 물체 바깥으로 밀어주는 Penalty Force를 줘서 error 수정중, error를 완전히 줄이기 위해 Penalty Force의 계수를 늘리면 물체 위에 쌓여있던 모래입자들이 어느 순간 펑 하고 터져버리는 문제가 발생한다.   

    
