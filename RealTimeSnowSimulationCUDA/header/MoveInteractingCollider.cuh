/*==========================================================
File Name: MoveInteractingCollider.cuh

�ϴ� ��: ��ȣ�ۿ��ϴ� �浹ü���� �շ��� �������� �̵�

===========================================================*/
#pragma once
#include "Common.cuh"
#include "SnowCuda.h"

__global__
void moveInteractingColliders(Collider* dev_colliderInteracting ,float3* dev_colInterPos,const float dt, float3* debug, const ParamSet Param) {
	int index = threadIdx.x;
	if (index >= Param.num_interacting_collider)
		return;
	dev_colliderInteracting[index].force = dev_colliderInteracting[index].force + make_float3(0.f, 0.f, Param.gravity * (-1) * dev_colliderInteracting[index].mass);//�߷� ���ϱ�
	float3 accel = dev_colliderInteracting[index].force / dev_colliderInteracting[index].mass;//���ӵ� = ��/����
	dev_colliderInteracting[index].vel = dev_colliderInteracting[index].vel + dt * accel;
    dev_colInterPos[index] = dev_colInterPos[index] + dt * dev_colliderInteracting[index].vel;

    // �������
    if (dev_colInterPos[index].x < Param.startFloor.x + dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].x = Param.startFloor.x + dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }
    else if (dev_colInterPos[index].x > Param.endTop.x - dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].x = Param.endTop.x - dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }
    if (dev_colInterPos[index].y < Param.startFloor.y + dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].y = Param.startFloor.y + dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }
    else if (dev_colInterPos[index].y > Param.endTop.y - dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].y = Param.endTop.y - dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }
    if (dev_colInterPos[index].z < Param.startFloor.z + dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].z = Param.startFloor.z + dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }
    else if (dev_colInterPos[index].z > Param.endTop.z - dev_colliderInteracting[index].radius) {
        dev_colInterPos[index].z = Param.endTop.z - dev_colliderInteracting[index].radius;
        dev_colliderInteracting[index].vel.x = 0;
        dev_colliderInteracting[index].vel.y = 0;
        dev_colliderInteracting[index].vel.z = 0;
    }

}