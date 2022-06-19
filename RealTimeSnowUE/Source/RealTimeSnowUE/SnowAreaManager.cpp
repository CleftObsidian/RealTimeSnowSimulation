// Fill out your copyright notice in the Description page of Project Settings.


#include "SnowAreaManager.h"

// Sets default values
ASnowAreaManager::ASnowAreaManager()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

}
ASnowAreaManager::~ASnowAreaManager()
{
	for (auto& i : m_heightMaps)
	{
		int** point = i.Value;
		for (int j = 0; j < m_numVerticalHeightMap; j++)
		{
			delete[] point[j];
		}
		delete[] point;
	}
}
// Called when the game starts or when spawned
void ASnowAreaManager::BeginPlay()
{
	Super::BeginPlay();

}

// Called every frame
void ASnowAreaManager::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

void ASnowAreaManager::InitManager(FVector startFloor, FVector endFloor, int numHorizontalArea, int numVerticalArea,int numHorizontalHeightMap, int numVerticalHeightMap)
{
	m_startFloor = startFloor;
	m_width = (endFloor - startFloor).X;
	m_length = (endFloor - startFloor).Y;
	m_height = (endFloor - startFloor).Z;
	m_numHorizonArea = numHorizontalArea;
	m_numVerticalArea = numVerticalArea;
	m_numHorizonHeightMap = numHorizontalHeightMap;
	m_numVerticalHeightMap = numVerticalHeightMap;
	m_oneAreaWidth = m_width / m_numHorizonArea; //���� �� ĭ�� ũ��
	m_oneAreaLength = m_length / m_numVerticalArea; // ���� �� ĭ�� ũ��

	
	for (int i = 0; i < m_numVerticalArea; i++)
	{
		for (int j = 0; j < m_numHorizonArea; j++)
		{
			int** heightMap = new int* [m_numVerticalHeightMap];
			for (int k = 0; k < m_numVerticalHeightMap; k++)
			{
				heightMap[k] = new int[m_numHorizonHeightMap];
				for (int l = 0; l < m_numHorizonHeightMap; l++)
				{
					heightMap[k][l] = m_initHeightZ;//FMath::RandRange(0, 30);
				}
			}
			m_heightMaps.Add(j+ i * m_numHorizonArea, heightMap);
		}
	}

}

void ASnowAreaManager::UpdateHeightmap(TArray<float> XPos, TArray<float> YPos, TArray<float> ZPos, int key)
{
	int** heightMapArea = GetHeightMap(key); //�츮�� �ٲ� Area
	int AreaX = key % m_numHorizonArea; //����� Area x
	int AreaY = key / m_numHorizonArea; //����� Area y
	int HeightX, HeightY; //����Ʈ�� ���ο��� x,y ��ġ �ε���
	int Height; //����Ʈ�� �����ϴ� ��
	float oneHeightWidth = m_oneAreaWidth / m_numHorizonHeightMap;//����Ʈ�� ���ο��� ���� �� ĭ�� ũ��
	float oneHeightLength = m_oneAreaLength / m_numVerticalHeightMap; //����Ʈ�� ���ο��� ���� �� ĭ�� ũ��
	for (int k = 0; k < m_numVerticalHeightMap; k++)//���� heightmap �ʱ�ȭ
	{
		for (int l = 0; l < m_numHorizonHeightMap; l++)
		{
			heightMapArea[k][l] = 20;
		}
	}
	for (int i = 0; i < XPos.Num(); i++) {
		Height = GetintByZPosition(ZPos[i] * 100 + (ZPos[0] * -100) + 11.0f) ;
		HeightX = int(((XPos[i]*100 - m_startFloor.X) - (AreaX * m_oneAreaWidth)) / oneHeightWidth); // Area ���ο����� x��
		HeightY = int(((YPos[i] * 100 - m_startFloor.Y) - (AreaY * m_oneAreaLength)) / oneHeightLength); //Area ���ο����� y��
		HeightX = FMath::Clamp(HeightX, 0, m_numHorizonHeightMap-1);
		HeightY = FMath::Clamp(HeightY, 0, m_numVerticalHeightMap-1);
		if (heightMapArea[HeightY][HeightX] < Height) // ���� ������ Ŭ ��쿡��
			heightMapArea[HeightY][HeightX] = Height; //�� �������.
	}
}

TArray<ASnowActorCpp*> ASnowAreaManager::GetSnowActors()
{
	return m_snowActors;
}

int ASnowAreaManager::GetAreaKey(FVector position)
{
	return int((position.X-m_startFloor.X) / m_oneAreaWidth)  + int((position.Y-m_startFloor.Y)/m_oneAreaLength) * m_numVerticalArea;
}

TArray<FVector> ASnowAreaManager::GetVertices(int key)
{
	int** heightMap = GetHeightMap(key);
	TArray<FVector> result;
	for (int i = 0; i < m_numVerticalHeightMap; i++)
	{
		for (int j = 0; j < m_numHorizonHeightMap; j++)
		{
			FVector temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length /m_numVerticalArea) + i * GetLengthPerHeightMapBlock(),
				GetintByZPosition(heightMap[i][j]));
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock() + GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock(),
				GetintByZPosition(heightMap[i][j]));
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock() + GetLengthPerHeightMapBlock(),
				GetintByZPosition(heightMap[i][j]));
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock() + GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock() + GetLengthPerHeightMapBlock(),
				GetintByZPosition(heightMap[i][j]));
			result.Add(temp);

			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock(),
				0);
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock() + GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock(),
				0);
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock() + GetLengthPerHeightMapBlock(),
				0);
			result.Add(temp);
			temp = FVector(m_startFloor.X + (key % m_numHorizonArea) * (m_width / m_numHorizonArea) + j * GetWidthPerHeightMapBlock() + GetWidthPerHeightMapBlock(),
				m_startFloor.Y + (key / m_numHorizonArea) * (m_length / m_numVerticalArea) + i * GetLengthPerHeightMapBlock() + GetLengthPerHeightMapBlock(),
				0);
			result.Add(temp);
		}
	}
	
	return result;
}
TArray<int> ASnowAreaManager::GetIndices()
{
	TArray<int> result;
	static int VERTICES_PER_CUBE = 8;
	for (int i = 0; i < m_numVerticalHeightMap; i++)
	{
		for (int j = 0; j < m_numHorizonHeightMap; j++)
		{
			int stride = (i * m_numHorizonHeightMap + j) * VERTICES_PER_CUBE;
			result.Add(stride + 1);
			result.Add(stride);
			result.Add(stride + 2);

			result.Add(stride + 1);
			result.Add(stride + 2);
			result.Add(stride + 3);

			result.Add(stride + 2);
			result.Add(stride );
			result.Add(stride + 4);

			result.Add(stride + 6);
			result.Add(stride + 2);
			result.Add(stride + 4);

			result.Add(stride + 3);
			result.Add(stride + 2);
			result.Add(stride + 6);

			result.Add(stride + 7);
			result.Add(stride + 3);
			result.Add(stride + 6);

			result.Add(stride + 1);
			result.Add(stride + 3);
			result.Add(stride + 7);

			result.Add(stride + 1);
			result.Add(stride + 7);
			result.Add(stride + 5);

			result.Add(stride);
			result.Add(stride + 1);
			result.Add(stride + 5);

			result.Add(stride + 4);
			result.Add(stride );
			result.Add(stride + 5);


		}

	}
	return result;
}

int** ASnowAreaManager::GetHeightMap(int key)
{
	return *m_heightMaps.Find(key);
}
float ASnowAreaManager::GetZPositionByChar(char cha)
{
	return (float)cha;
}
int ASnowAreaManager::GetintByZPosition(float zPosition)
{
	return zPosition;
}
float ASnowAreaManager::GetWidthPerHeightMapBlock()
{
	return m_width/ (float)m_numHorizonArea / (float)m_numHorizonHeightMap;
}
float ASnowAreaManager::GetLengthPerHeightMapBlock()
{
	return m_length/(float)m_numVerticalArea / (float)m_numVerticalHeightMap;
}

