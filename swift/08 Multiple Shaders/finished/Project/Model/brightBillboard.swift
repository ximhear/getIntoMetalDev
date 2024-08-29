//
//  brightBillboard.swift
//  Project
//
//  Created by Andrew Mengede on 4/8/2022.
//

import Foundation

class BrightBillboard {
    
    var position: simd_float3
    var model: matrix_float4x4
    var color: vector_float3
    var t: Float
    var rotationCenter: vector_float3
    var pathRadius: Float
    var pathPhi: Float
    var angularVelocity: Float
    
    init(position: simd_float3, color: vector_float3, rotation_center: vector_float3, pathRadius: Float, pathPhi: Float, angularVelocity: Float) {
        
        self.position = position
        self.color = color
        self.t = 0
        self.rotationCenter = rotation_center
        self.pathRadius = pathRadius
        self.pathPhi = pathPhi
        self.angularVelocity = angularVelocity
        self.model = Matrix44.create_identity()
        
    }
    
    func update(viewerPosition: simd_float3) {
        
        position[0] = rotationCenter[0] + pathRadius * cos(t) * sin(pathPhi * .pi / 180.0)
        position[1] = rotationCenter[1] + pathRadius * cos(pathPhi * .pi / 180.0)
        position[2] = rotationCenter[2] + pathRadius * sin(t) * sin(pathPhi * .pi / 180.0)
        
        t += angularVelocity * 0.01;
        if t > (2.0 * .pi) {
            t -= 2.0 * .pi
        }
        
        let selfToViewer: simd_float3 = viewerPosition - position
        let theta: Float = simd.atan2(selfToViewer[0], selfToViewer[2]) * 180.0 / .pi
        let horizontalDistance: Float = sqrtf(selfToViewer[2] * selfToViewer[2] + selfToViewer[0] * selfToViewer[0])
        let phi: Float = -simd.atan2(selfToViewer[1], horizontalDistance) * 180.0 / .pi
        model = Matrix44.create_from_rotation(eulers: [-90, 90, 0])
        model = Matrix44.create_from_rotation(eulers: [phi, theta, 0]) * model
        model = Matrix44.create_from_translation(translation: position) * model
    }
    
}
