#pragma once
/*==========================================================
File Name: Compression.cuh

�� ���ڴ� ����� �շ¿� �ٰ��ؼ� �� ��ƼŬ�� d��, ������ ���� ������Ʈ

�̸� ���Ǿ�� �ϴ°�: �� ��ƼŬ�� positiveForce, negativeForce
���� ���: �� ��ƼŬ�� d,r�� ������Ʈ

===========================================================*/


#include "Common.cuh"
#include "SnowCuda.h"
#include "math_constants.h"



__global__
void compression(ParticleData* dev_pData, float* dev_radius,float3* debug, const unsigned int size,const ParamSet Param) {
    int stride = gridDim.x * blockDim.x;

    for (int idx = blockIdx.x * blockDim.x + threadIdx.x; idx < size; idx += stride) {
        
        //�� ���ڿ� �ۿ��ϴ� 4���� ��(�߷�,���ܷ�,���,������)�� x,y,z�������� ���ǹ����� ��, ���� ������ ���� ���� ����
        

        // compression (��ü�� ��׷����µ� ������ �ִ� ���� ���� ũ���� ������ ��������(ex/ x+ �������� 3N�� ��, x-�������� 1N�� ���� ������, ��ü�� �շ��� 2N���� ���ǹ������� �̵�������, ��ü��ü�� 1N�� ����ŭ ��׷����� ������ �ްԵ�)
        float minXSquare = fminf(dev_pData[idx].positiveForce.x * dev_pData[idx].positiveForce.x, dev_pData[idx].negativeForce.x * dev_pData[idx].negativeForce.x);
        float minYSquare = fminf(dev_pData[idx].positiveForce.y * dev_pData[idx].positiveForce.y, dev_pData[idx].negativeForce.y * dev_pData[idx].negativeForce.y);
        float minZSquare = fminf(dev_pData[idx].positiveForce.z * dev_pData[idx].positiveForce.z, dev_pData[idx].negativeForce.x * dev_pData[idx].negativeForce.x);

        float compressiveForces = sqrtf(minXSquare + minYSquare + minZSquare);//�з� ���

        float p_c = compressiveForces / (CUDART_PI_F * dev_pData[idx].radius * dev_pData[idx].radius);//�з��� ��ƼŬ �������� ����(�з� = ���������� �޴� �� N/m^2)

        float pi = 100.0f * dev_pData[idx].phase_snow + 900.0f * (1 - dev_pData[idx].phase_snow);
        float e = expf(1.0f);//�ڿ���� e
        float Dpi = Param.minForceW + Param.maxForceW * ((powf(e, (pi / 100.f - 1)) - 0.000335f) / 2980.96f);//�� ������ �� ����

        // update radius
        if (compressiveForces > Dpi)
        {
            dev_pData[idx].d = fmaxf(dev_pData[idx].d - Param.k_q * p_c, 0);

            dev_pData[idx].radius = dev_pData[idx].d * Param.radius_snow + (1 - dev_pData[idx].d) * Param.radius_ice;
            dev_pData[idx].phase_snow = dev_pData[idx].d;
        }
        dev_radius[idx] = dev_pData[idx].radius;
    }

}