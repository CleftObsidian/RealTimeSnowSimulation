/*==========================================
File name: Collision.cuh
�浹 ó�� �ڵ�
�浹 ��� ��ƼŬ���� velocity�� ������Ʈ��
===========================================*/


#include "Common.cuh"
#include "SnowCuda.h"
// collide two spheres using DEM method
__device__ 
float3 collideSpheres(
    float3 posA, 
    float3 posB,
    float3 velA,
    float3 velB,
    float radiusA, 
    float radiusB,
    const ParamSet Param
){
    // calculate relative position
    float3 relPos = posB - posA;
    float dist = getDistance(posA, posB);
    float collideDist = radiusA + radiusB;
    float3 force = make_float3(0.0f,0.0f,0.0f);
    if (dist < collideDist) {// �� ���� �浹�ߴٸ�
        float3 norm = relPos / dist;
        // relative velocity
        float3 relVel = velB - velA;
        // relative tangential velocity
        float3 tanVel = relVel - (dot(relVel, norm) * norm);
        // spring force
        force = -0.5f *  (collideDist - dist)/(collideDist) * 100  * norm;
        // dashpot (damping) force
        force = force + 0.02 * 10.f * relVel;
        // tangential shear force
        force = force + 0.1 * 10.f * tanVel;
        if (force.z > Param.particle_mass * Param.gravity * 1.2f) {
            force.z = Param.particle_mass * Param.gravity * 1.2f;
        }
    }
    return force;
}


__global__
void collide(float3* dev_pos,
    float3* dev_vel,
    float3* dev_force,
    Collider* dev_colliderNotInteracting,
    Collider* dev_colliderInteracting,
    float3* dev_colPos,
    float3* dev_colInterPos,
    ParticleData* dev_pData, 
    const unsigned int size,
    ParamSet Param) 
{
    int stride = gridDim.x * blockDim.x;

    float3 collide_Force;
    float3 force;
    for (int idx = blockIdx.x * blockDim.x + threadIdx.x; idx < size; idx += stride) {
        //��ȣ�ۿ��� collider�� ��� ������ ��ġ�� �ʴ� �浹 ���
        collide_Force = make_float3(0.f, 0.f, 0.f);
        for (int j = 0; j < Param.num_collider; j++) {
            force = collideSpheres(dev_pos[idx], dev_colPos[j], dev_vel[idx], dev_colliderNotInteracting[j].vel, dev_pData[idx].radius, dev_colliderNotInteracting[j].radius,Param);
            collide_Force = collide_Force + force;
            
        }
        //AddForceForCompression(collide_Force, dev_pData, idx);
        dev_force[idx] = dev_force[idx] + collide_Force;


        //��ȣ�ۿ��� collider�� ��� ������ ��ġ�� �浹 ���
        collide_Force = make_float3(0.f, 0.f, 0.f);
        for (int j = 0; j < Param.num_interacting_collider; j++) {
            force = collideSpheres(dev_pos[idx], dev_colInterPos[j], dev_vel[idx], dev_colliderInteracting[j].vel, dev_pData[idx].radius, dev_colliderInteracting[j].radius, Param);
            collide_Force = collide_Force + force;
           
            dev_colliderInteracting[j].force = dev_colliderInteracting[j].force - force;//�浹ü�� �浹��� ����
        }
        AddForceForCompression(collide_Force, dev_pData, idx);
        dev_force[idx] = dev_force[idx] + collide_Force;
    }
}

__global__
void calcColliderVelocity(
    float3* dev_colPos,
    float3* dev_preColPos, 
    Collider* dev_colliderNotInteracting,
    ParamSet Param,
    float dt){
    int stride = gridDim.x * blockDim.x;
    for (int idx = blockIdx.x * blockDim.x + threadIdx.x; idx < Param.num_collider; idx += stride) {
        dev_colliderNotInteracting[idx].vel = (dev_colPos[idx] - dev_preColPos[idx]) / dt;
        dev_preColPos[idx] = dev_colPos[idx];
    }
}