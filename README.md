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
   
     


  
