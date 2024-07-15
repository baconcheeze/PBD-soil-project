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
- 정지마찰이 제대로 적용되지 않는 문제가 있어 로직 수정
- Rigid Body 전체 흐름
  <img src="https://github.com/user-attachments/assets/46e01623-a67f-4ae6-b474-94bcf4cbcfc0">

-  Solve Collision Logic
  <img src="https://github.com/user-attachments/assets/16758256-a37d-4371-a091-8defee3264e2">
  <img src="https://github.com/user-attachments/assets/3d7afff4-da46-435a-85d8-bc5c0b02454e">
  <img src="https://github.com/user-attachments/assets/5b396243-fa1f-4401-8431-e7502e0b5ddb">
	  
   
     
## 2주차 목표
- PBD GPU로 처리하게 이식
- PBD Inner Particle Collision Detection (Continuous Collision Dectection, NeighborGrid Collision Detection)
- PBD Particle <-> Rigid Body Interaction 구현
- 흙 Particle이 떨어져서 풍차가 돌아가고, 쇠구슬이 떨어져서 쌓여있는 모래가 움푹 파이는 장면을 구현하는것이 목표.

  
