//
//  PhysicsSimulation.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class PhysicsSimulation: MappingNode {
    var inputLocal = GraphicsNode()
    var outputLocal = GraphicsNode()
    
    var anchorA: CGPoint?
    var anchorB: CGPoint?
    
    var joint: SKPhysicsJoint?
    
    var physicalJointSwitching: SKPhysicsJoint?
    var activateStatusSwitching = false
    
    func setup(input: GraphicsNode, output: GraphicsNode, pointA: CGPoint?, pointB: CGPoint?) {
        inputLocal = input
        outputLocal = output
        
        inputNode = inputLocal
        outputNode = outputLocal
        
        anchorA = pointA
        anchorB = pointB
    
        
        if App.state.typeOfPhysics == App.state.PHYSICS_NONE { return }
        
        if App.state.typeOfPhysics == App.state.PHYSICS_SPRING {
            let physicalJoint = SKPhysicsJointSpring.joint(withBodyA: inputLocal.physicsBody!, bodyB: outputLocal.physicsBody!, anchorA: anchorA!, anchorB: anchorB!)
            physicalJoint.damping = 0.2
            physicalJoint.frequency = 1
            joint = physicalJoint
        } else {
            let physicalJoint = SKPhysicsJointLimit.joint(withBodyA: inputLocal.physicsBody!, bodyB: outputLocal.physicsBody!, anchorA: anchorA!, anchorB: anchorB!)
            joint = physicalJoint
        }
        
        App.state.scene.physicsWorld.add(joint!)

        // update the mapping ui
        let numOfMappings = App.state.mappingNodes.count
        self.name = "Mapping #\(numOfMappings), type: Physics"
        App.state.mappingViewController.updateMappingSection()
        
        isSetup = true
    }
    
    func changeStatusSwitching(activate: Bool, isCreatingNew: Bool) {
        if isCreatingNew {
            if activate {
                inputLocal.setupPhysicsBody()
                outputLocal.setupPhysicsBody()
                if !activateStatusSwitching {
                    physicalJointSwitching = SKPhysicsJointFixed.joint(withBodyA: inputLocal.physicsBody!, bodyB: outputLocal.physicsBody!, anchor: inputLocal.position)
                    App.state.scene.physicsWorld.add(physicalJointSwitching!)
                    activateStatusSwitching = true
                }
                
            } else {
                if physicalJointSwitching != nil && activateStatusSwitching {
                    App.state.scene.physicsWorld.remove(physicalJointSwitching!)
                    activateStatusSwitching = false
                }
                
            }
        } else {
            activateStatus = activate
        }
    }
    
    override func nodeHighlighted() {
        super.nodeHighlighted()
        inputLocal.highlightGraphics()
        outputLocal.highlightGraphics()
    }
    
    override func nodeNotHighlighted() {
        inputLocal.highlightGraphicsOff()
        outputLocal.highlightGraphicsOff()
    }
    
    override func updateMapping() {
        if activateStatus {
            inputLocal.velocity = (inputLocal.physicsBody!.isDynamic) ? inputLocal.physicsBody?.velocity : inputLocal.velocity
            outputLocal.velocity = (outputLocal.physicsBody!.isDynamic) ? outputLocal.physicsBody?.velocity : outputLocal.velocity
            return
        } else {
            App.state.scene.physicsWorld.remove(joint!)
        }
    }
}
