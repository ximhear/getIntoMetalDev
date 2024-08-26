//
//  Scene.swift
//  Transformations
//
//  Created by Andrew Mengede on 2/3/2022.
//

import Foundation
import SwiftUI

/*
 In order to be considered as an environmental object,
 the game scene must conform to the "Observable" protocol.
 In order to be observable, we mark which variables will be
 "Published" upon update.
 */
class GameScene : ObservableObject {
    
    @Published var player: Entity
    @Published var mouse: Billboard
    @Published var sun: Light
    @Published var spotlight: Light
    @Published var cubes: [Entity]
    @Published var groundTiles: [Entity]
    @Published var pointLights: [Light]
    
    
    init() {
        
        groundTiles = []
        cubes = []
        pointLights = []
        
        let newPlayer = Entity()
        newPlayer.addCameraComponent(position: [0.0, 0.0, -4.0], eulers: [0.0, 0.0, 0.0])
        player = newPlayer
        
        let newMouse = Billboard(position: [0.0, 0.0, 1.0])
        mouse = newMouse
        
        let newSpotlight = Light(color: [1.0, 0.0, 0.0])
        newSpotlight.declareSpotlight(position: [-2, 0.0, 3.0], eulers: [0.0, 0.0, 180.0], eulerVelocity: [0.0, 0.0, 45.0])
        spotlight = newSpotlight;
        
        let newSun = Light(color: [1.0, 1.0, 0.0])
        newSun.declareDirectional(eulers: [0.0, 135.0, 45.0])
        sun = newSun
        sun.update()
        
        let newCube = Entity()
        newCube.addTransformComponent(position: [0.0, 0.0, 1.0], eulers: [0.0, 0.0, 0.0])
        cubes.append(newCube)
        
        let newTile = Entity()
        newTile.addTransformComponent(position: [0.0, 0.0, 0.0], eulers: [90.0, 0.0, 0.0])
        groundTiles.append(newTile)
        
        var newPointLight = Light(color: [0.0, 1.0, 1.0])
        newPointLight.declarePointlight(rotationCenter: [0.0, 0.0, 1.0], pathRadius: 2.0, pathPhi: 60.0, angularVelocity: 1.0)
        pointLights.append(newPointLight)
        newPointLight = Light(color: [0.0, 0.0, 1.0])
        newPointLight.declarePointlight(rotationCenter: [0.0, 0.0, 1.0], pathRadius: 3.0, pathPhi: 0.0, angularVelocity: 2.0)
        pointLights.append(newPointLight)
        
    }
    
    func updateView() {
        self.objectWillChange.send()
    }
    
    func update() {
        
        player.update()
        
        for cube in cubes {
            cube.update()
        }
        
        for ground in groundTiles {
            ground.update()
        }
        
        spotlight.update()
        
        for light in pointLights {
            light.update()
        }
        
        mouse.update(viewerPosition: player.position!)
        
        updateView()
    }
    
    func spinPlayer(offset: CGSize) {
        
        let dTheta: Float = Float(offset.width)
        let dPhi: Float = Float(offset.height)
        
        player.eulers!.z -= 0.001 * dTheta
        player.eulers!.y += 0.001 * dPhi
        
        if player.eulers!.z < 0 {
            player.eulers!.z -= 360
        } else if player.eulers!.z > 360 {
            player.eulers!.z -= 360
        }
        
        if player.eulers!.y < 1 {
            player.eulers!.y = 1
        } else if player.eulers!.y > 179 {
            player.eulers!.y = 179
        }
        
    }
    
    func strafePlayer(offset: CGSize) {
        
        let rightAmount: Float = Float(offset.width) / 1000
        
        let upAmount: Float = Float(offset.height) / 1000
        
        self.player.strafe(rightAmount: rightAmount, upAmount: upAmount)
        
    }
    
}
