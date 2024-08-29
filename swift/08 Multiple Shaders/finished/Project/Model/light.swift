//
//  light.swift
//  Project
//
//  Created by Andrew Mengede on 3/7/2022.
//

import Foundation

class Light {
    
    var type: lightType
    var position: simd_float3?
    var eulers: simd_float3?
    var forwards: vector_float3?
    var color: vector_float3
    var t: Float?
    var rotationCenter: vector_float3?
    var pathRadius: Float?
    var pathPhi: Float?
    var eulerVelocity: vector_float3?
    var angularVelocity: Float?
    
    
    init(color: vector_float3) {
        
        self.type = UNDEFINED
        self.color = color
        
    }
    
    func declareDirectional(forwards: simd_float3) {
        self.type = DIRECTIONAL
        self.forwards = forwards
    }
    
func declareSpotlight(
        position: simd_float3, eulers: simd_float3,
        eulerVelocity: vector_float3
    ) {
        self.type = SPOTLIGHT
        self.position = position
        self.eulers = eulers
        self.t = 0.0;
        self.eulerVelocity = eulerVelocity;
    }
    
    func declarePointlight(
        rotationCenter: vector_float3, pathRadius: Float,
        pathPhi: Float, angularVelocity: Float
    ) {
        self.type = POINTLIGHT
        self.rotationCenter = rotationCenter
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.t = 0.0
        self.angularVelocity = angularVelocity
        self.position = rotationCenter
    }
    
    func update() {
        
        if type == DIRECTIONAL {
            

        } else if type == SPOTLIGHT {
            
            // SPOTLIGHT에서 오일러 각도를 변경 (이것은 특정 애니메이션 효과를 위한 것으로 가정)
            eulers![1] += eulerVelocity![1] // 변경된 부분: eulerVelocity에 기반한 회전
            if (eulers![1] > 360) {
                eulers![1] -= 360
            }
            
            let pitch = eulers![0] * .pi / 180.0
            let yaw = eulers![1] * .pi / 180.0
            
            forwards = [
                cos(pitch) * cos(yaw),
                sin(pitch),
                cos(pitch) * sin(yaw)
            ]
            
        } else if type == POINTLIGHT {
            // POINTLIGHT에서의 궤도 계산
            position![0] = rotationCenter![0] + pathRadius! * cos(pathPhi! * .pi / 180.0) * cos(t!)
            position![1] = rotationCenter![1] + pathRadius! * sin(pathPhi! * .pi / 180.0)
            position![2] = rotationCenter![2] + pathRadius! * cos(pathPhi! * .pi / 180.0) * sin(t!)

            t! += angularVelocity! * 0.1;
            if t! > (2.0 * .pi) {
                t! -= 2.0 * .pi
            }
        }
    }

    
    func update1() {
            
        if type == DIRECTIONAL {
                
            forwards = [
                cos(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                sin(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                cos(eulers![1] * .pi / 180.0)
            ]
                
        } else if type == SPOTLIGHT {
            
            eulers![1] += 1
            if (eulers![1] > 360) {
                eulers![1] -= 360
            }
            
            forwards = [
                cos(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                sin(eulers![2] * .pi / 180.0) * sin(eulers![1] * .pi / 180.0),
                cos(eulers![1] * .pi / 180.0)
            ]
            
        } else if type == POINTLIGHT {
            position![0] = rotationCenter![0] + pathRadius! * cos(t!) * sin(pathPhi! * .pi / 180.0)
            position![1] = rotationCenter![1] + pathRadius! * sin(t!) * sin(pathPhi! * .pi / 180.0)
            position![2] = rotationCenter![2] + pathRadius! * cos(pathPhi! * .pi / 180.0)
            
            t! += angularVelocity! * 0.1;
            if t! > (2.0 * .pi) {
                t! -= 2.0 * .pi
            }
        }
        
    }
}
