//
//  MappingNode.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class MappingNode: SKNode {
    // define the input and the output
    var inputNode: SKNode?
    var outputNode: SKNode?
    var reference: SKNode?
    
    var hierarchy = CGFloat.zero
    
    // whether it has hierachy
    var activateStatus: Bool = true
    
    // whether it is setup
    var isSetup: Bool = false

    func updateMapping() {
        // definition of the function in sub classes
    }
    
    func updateHierarchy() {
        if let input = inputNode as? MappingNode {
            if input.hierarchy >= self.hierarchy {
                self.hierarchy = input.hierarchy + 1
            }
        }
        
        if let output = outputNode as? MappingNode {
            if output.hierarchy <= self.hierarchy {
                output.hierarchy = self.hierarchy + 1
            }
        }
    }
    
    func nodeHighlighted() {
        for mapping in App.state.mappingNodes {
            mapping.nodeNotHighlighted()
        }
    }
    
    func nodeNotHighlighted() {
        
    }
    
    func activateMapping() {
        
    }
    
    func setupStatesInputOutput() {
        
    }
    
    func isBeingUpdated() {
        
    }
    
    func didBeingUpdated() {
        
    }
}
