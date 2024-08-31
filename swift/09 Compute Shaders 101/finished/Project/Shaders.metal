//
//  Shaders.metal
//  Project
//
//  Created by Andrew Mengede on 13/8/2022.
//

#include <metal_stdlib>
#include "definitions.h"

using namespace metal;

bool hit(Ray ray, Sphere sphere);
float distance_to_sphere(Sphere sphere, Ray ray);

kernel void ray_tracing_kernel(texture2d<float, access::write> color_buffer [[texture(0)]],
                    uint2 grid_index [[thread_position_in_grid]]) {
    int width = color_buffer.get_width();
    int height = color_buffer.get_height();
    
    int min_dimension = min(width, height);
    float horizontal_coefficient = (float(grid_index[0]) - width / 2) / min_dimension;
    float vertical_coefficient = (float(grid_index[1]) - height / 2) / min_dimension;

    // Update the direction vectors for the left-handed coordinate system
    float3 forwards = float3(0.0, 0.0, 1.0);
    float3 right = float3(1.0, 0.0, 0.0);
    float3 up = float3(0.0, 1.0, 0.0);
    
    Sphere mySphere;
    mySphere.center = float3(0.0, 0.0, 3.0);
    mySphere.radius = 1.0;
    
    Ray myRay;
    myRay.origin = float3(0.0, 0.0, 0.0);
    myRay.direction = normalize(forwards + horizontal_coefficient * right + vertical_coefficient * up);
    
    float4 color = float4(0.1, 0.2, 0.3, 1.0);
    
    if (hit(myRay, mySphere)) {
        color = float4(1.0, 0.1, 0.3, 1.0);
    }
  
    color_buffer.write(color, grid_index);
}

bool hit(Ray ray, Sphere sphere) {
    
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(ray.direction, ray.origin - sphere.center);
    float c = dot(ray.origin - sphere.center, ray.origin - sphere.center) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4.0 * a * c;

    return discriminant > 0;
    
}

/*
 
 레이와 구체의 충돌 여부를 판단하는 판별식(discriminant)을 유도하기 위해서는 먼저 레이와 구체의 수학적 표현을 이해하고, 이를 결합하여 충돌 조건을 도출해야 합니다.

 ### 1. 레이의 수학적 표현

 레이(Ray)는 3D 공간에서 하나의 시작점(원점)과 방향으로 정의됩니다. 레이는 다음과 같이 표현할 수 있습니다:

 \[
 \mathbf{P}(t) = \mathbf{O} + t \cdot \mathbf{D}
 \]

 여기서,
 - \(\mathbf{P}(t)\)는 레이 상의 한 점을 나타냅니다.
 - \(\mathbf{O}\)는 레이의 시작점(원점, origin)입니다.
 - \(\mathbf{D}\)는 레이의 방향 벡터(direction)입니다.
 - \(t\)는 매개변수로, 레이의 시작점에서부터 얼마나 멀리 떨어져 있는지를 나타냅니다. \(t\)는 음수일 수도 있고, 양수일 수도 있습니다.

 ### 2. 구체의 수학적 표현

 구체(Sphere)는 중심점(C)과 반지름(r)으로 정의됩니다. 구체는 다음 방정식으로 나타낼 수 있습니다:

 \[
 (\mathbf{P} - \mathbf{C}) \cdot (\mathbf{P} - \mathbf{C}) = r^2
 \]

 여기서,
 - \(\mathbf{P}\)는 구체 표면 위의 한 점입니다.
 - \(\mathbf{C}\)는 구체의 중심점(center)입니다.
 - \(r\)는 구체의 반지름(radius)입니다.
 - \(\cdot\)은 벡터의 내적(dot product)을 의미합니다.

 ### 3. 레이-구체 충돌 문제

 레이와 구체가 만난다는 것은 레이의 어떤 점 \(\mathbf{P}(t)\)가 구체의 표면 위에 있다는 것을 의미합니다. 따라서, \(\mathbf{P}(t)\)를 구체의 방정식에 대입하여 충돌 여부를 판별할 수 있습니다.

 레이의 표현 \(\mathbf{P}(t) = \mathbf{O} + t \cdot \mathbf{D}\)를 구체의 방정식에 대입하면:

 \[
 (\mathbf{O} + t \cdot \mathbf{D} - \mathbf{C}) \cdot (\mathbf{O} + t \cdot \mathbf{D} - \mathbf{C}) = r^2
 \]

 이를 전개하면:

 \[
 (\mathbf{O} - \mathbf{C}) \cdot (\mathbf{O} - \mathbf{C}) + 2t \cdot (\mathbf{D} \cdot (\mathbf{O} - \mathbf{C})) + t^2 \cdot (\mathbf{D} \cdot \mathbf{D}) = r^2
 \]

 이 방정식은 \(t\)에 대한 2차 방정식입니다. 표준적인 2차 방정식의 형태로 정리하면:

 \[
 t^2 \cdot (\mathbf{D} \cdot \mathbf{D}) + 2t \cdot (\mathbf{D} \cdot (\mathbf{O} - \mathbf{C})) + ((\mathbf{O} - \mathbf{C}) \cdot (\mathbf{O} - \mathbf{C}) - r^2) = 0
 \]

 이를 \(t\)에 대한 일반적인 2차 방정식의 형태로 나타내면:

 \[
 a t^2 + b t + c = 0
 \]

 여기서,

 - \(a = \mathbf{D} \cdot \mathbf{D}\): 레이 방향 벡터 \(\mathbf{D}\)의 자기 내적, 즉 방향 벡터의 크기의 제곱입니다. 일반적으로 방향 벡터는 정규화되어 있으므로 \(a = 1\)이 됩니다.
 - \(b = 2 \cdot (\mathbf{D} \cdot (\mathbf{O} - \mathbf{C}))\): 레이의 방향 벡터와 구체 중심에서 레이의 시작점으로 향하는 벡터 간의 내적에 2를 곱한 값입니다.
 - \(c = (\mathbf{O} - \mathbf{C}) \cdot (\mathbf{O} - \mathbf{C}) - r^2\): 레이 시작점에서 구체 중심까지의 거리의 제곱에서 구체의 반지름의 제곱을 뺀 값입니다.

 ### 4. 판별식(Discriminant)의 유도

 2차 방정식의 해는 다음과 같은 판별식으로 구할 수 있습니다:

 \[
 t = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
 \]

 여기서 중요한 부분은 루트 안의 표현인 \(b^2 - 4ac\)입니다. 이것을 **판별식(discriminant)**이라고 합니다.

 - **판별식 > 0**: 레이와 구체가 두 점에서 만난다는 의미입니다. 레이가 구체를 통과합니다.
 - **판별식 = 0**: 레이와 구체가 한 점에서 만난다는 의미입니다. 레이가 구체에 접합니다.
 - **판별식 < 0**: 레이와 구체가 만나지 않는다는 의미입니다. 레이는 구체를 비켜갑니다.

 따라서, 함수에서는 판별식 \(b^2 - 4ac\)의 값이 0보다 큰지를 검사하여 레이와 구체의 충돌 여부를 판단합니다:

 ```cpp
 float discriminant = b * b - 4.0 * a * c;
 return discriminant > 0;
 ```

 ### 요약

 레이-구체 충돌 문제는 레이와 구체의 수학적 방정식을 결합하여 2차 방정식의 형태로 나타냅니다. 이 2차 방정식의 해의 존재 여부를 판별식(discriminant)을 통해 판단하며, 이 값이 양수이면 레이와 구체가 교차하고, 음수이면 교차하지 않는다는 결론을 내립니다.
 
 */
