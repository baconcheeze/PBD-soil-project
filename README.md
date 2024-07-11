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
  - 가장 핵심인 입자간의 Contact Resolution 처리 :
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4cd9bc0c-dc01-48a5-961c-d2cefd6b1d0d"> 
    



```

```


- Static Friction Coefficient: 0.3  // Kinetic Friction Coefficient: 0.3 // Adhesion Coefficient: 0.0
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/2f13c215-ca78-45df-a325-2f461a84378a"> 
- Static Friction Coefficient: 1.5  // Kinetic Friction Coefficient: 1.5 // Adhesion Coefficient: 0.0
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/4c7ba685-b7de-4ad7-87a5-17ff3a4132dd"> 

- Static Friction Coefficient: 0.3  // Kinetic Friction Coefficient: 0.3 // Adhesion Coefficient: 0.2
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/85949d06-c0a9-411e-9572-85e782385b64"> 
- Static Friction Coefficient: 1.5  // Kinetic Friction Coefficient: 1.5 // Adhesion Coefficient: 0.2
  - <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/bf245dda-99c8-4656-82d7-20cf22eb3f13">

  
     
## 2주차 목표
- PBD GPU로 처리하게 이식
- PBD Inner Particle Collision Detection (Continuous Collision Dectection, NeighborGrid Collision Detection)
- PBD Particle <-> Rigid Body Interaction 구현
- 흙 Particle이 떨어져서 풍차가 돌아가고, 쇠구슬이 떨어져서 쌓여있는 모래가 움푹 파이는 장면을 구현하는것이 목표.

  
