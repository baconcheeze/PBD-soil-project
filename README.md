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

## 2024.07.06
- 모래 PBR을 PBD Particle 렌더링에 활용
- PBD로직 Compute Shader로 옮기는 작업 진행중.
  <img src="https://github.com/baconcheeze/PBD-soil-project/assets/116047186/e1417e3c-8ddf-4d7f-995f-b000ac2274fa">


## 2주차 목표
- PBD GPU로 처리하게 이식
- PBD Inner Particle Collision Detection (Continuous Collision Dectection, NeighborGrid Collision Detection)
- PBD Particle <-> Rigid Body Interaction 구현
- 흙 Particle이 떨어져서 풍차가 돌아가고, 쇠구슬이 떨어져서 쌓여있는 모래가 움푹 파이는 장면을 구현하는것이 목표.

  
