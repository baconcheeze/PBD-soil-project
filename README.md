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
  
