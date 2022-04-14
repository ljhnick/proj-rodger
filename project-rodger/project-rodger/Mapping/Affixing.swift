//
//  Affixing.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class AffixingNode: MappingNode {
    
    var inputLocal: LinkNode!
    var outputLocal: GraphicsNode!
    
    var refCenter = CGPoint()
    var refOri = CGFloat()
    var refDepth = CGFloat()
    
    var refGraphicCenter = CGPoint()
    var refGraphicZRot = CGFloat()
    
    var isNameGenerated = false
    
    func setup(input: LinkNode, output: GraphicsNode) {
        inputLocal = input
        outputLocal = output
        
        inputNode = inputLocal
        outputNode = outputLocal
        
        // the graphic in the mapping will not be affected by gravity
        output.isDynamic = false
        
        // record the reference
        createReference()
        
        // check if the mapping is setup
        isSetup = true
        
        // update name
        if !isNameGenerated {
            let numOfMappings = App.state.mappingNodes.count
            self.name = "Mapping #\(numOfMappings), type: Affixing"
            isNameGenerated = false
        }
        
        
        // update the mapping ui
        App.state.mappingViewController.updateMappingSection()
    }
    
    func update(input: LinkNode? = nil, output: GraphicsNode? = nil) {
        nodeNotHighlighted()
        inputLocal = (input == nil) ? inputLocal : input
        outputLocal = (output == nil) ? outputLocal : output
        setup(input: inputLocal, output: outputLocal)
        nodeHighlighted()
    }
    
    func createReference() {
        refCenter = inputLocal.midPositionOfMarkers
        refOri = inputLocal.orientation
        refDepth = inputLocal.depth
        
        refGraphicCenter = outputLocal.position
        refGraphicZRot = outputLocal.zRotation
    }
    
    override func nodeHighlighted() {
        super.nodeHighlighted()
        inputLocal.highlightLink()
        outputLocal.highlightGraphics()
    }
    
    override func nodeNotHighlighted() {
        inputLocal.highlightLinkOff()
        outputLocal.highlightGraphicsOff()
    }
    
    override func updateMapping() {
        if !activateStatus { return }
        if !isSetup { return }
        
        var depthScale = refDepth/inputLocal.depth
        depthScale = 1
        
        let rotAng = inputLocal.orientation - refOri
        let dx_ref = (refGraphicCenter.x - refCenter.x)*depthScale
        let dy_ref = (refGraphicCenter.y - refCenter.y)*depthScale
        
        let dx = cos(rotAng)*dx_ref - sin(rotAng)*dy_ref
        let dy = sin(rotAng)*dx_ref + cos(rotAng)*dy_ref
        
        let posX_graphics = inputLocal.midPositionOfMarkers.x + dx
        let posY_graphics = inputLocal.midPositionOfMarkers.y + dy
        
        outputLocal.zRotation = rotAng + refGraphicZRot
        outputLocal.position = CGPoint(x: posX_graphics, y: posY_graphics)
        
        // with depth detection
        outputLocal.setScale(depthScale)
        
        outputLocal.velocity = inputLocal.posVel
    }

}
