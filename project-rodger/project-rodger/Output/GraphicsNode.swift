//
//  GraphicsNode.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class GraphicsNode: SKNode {
    // storage
    var drawing = SKSpriteNode()
    var drawingToGroup = [GraphicsNode]()
    var initialTexture: SKTexture?
    
    // for switching states
    var drawingSecond: SKSpriteNode?
    var color = UIColor()
    
    // for interpolating transformation
    var isTransformation: Bool = false
    var transformationControl = [SIMD2<Float>]()
    var transformationState = [[SIMD2<Float>]]()
    var warpGeometryGrid = SKWarpGeometryGrid()
    var controlPoints = [SKShapeNode]()
    var selectedControlPoint: SKNode?
    
    // check if the graphic has physics body
    var isPhyscisBody: Bool = false
    var isDynamic: Bool = true
    
    // attribute
    var velocity: CGVector?
    
    
    func setup(drawing: SKSpriteNode) {
        self.drawing = drawing
        self.addChild(self.drawing)
        
        App.state.drawingNodes.append(self)
        let index = App.state.drawingNodes.firstIndex(of: self)
        self.name = "Graphics\(index!+1)"
        initialTexture = drawing.texture
        
    }
    
    func setupGroup() {
        let combinedNode = SKNode()
        for node in drawingToGroup {
            node.removeFromParent()
            App.state.drawingNodes.removeAll(where: {$0 == node})
            combinedNode.addChild(node)
        }
        
        let combinedNodeTexture = SKView().texture(from: combinedNode)
        let combinedNodeSprite = SKSpriteNode(texture: combinedNodeTexture)
        let combinedCenter = calculateCombinedCenterPosition(combinedNode: combinedNode)
        
        setup(drawing: combinedNodeSprite)
//        self.drawing = combinedNodeSprite
//        combinedNodeSprite.color = .red
//        combinedNodeSprite.colorBlendFactor = 1.0
        
//        combinedNodeSprite.physicsBody = SKPhysicsBody(texture: combinedNodeSprite.texture!, size: combinedNodeSprite.size)
        
        self.position = combinedCenter
//        self.addChild(combinedNodeSprite)
//        self.name = "graphics"
        
//        App.state.drawingNodes.append(self)
        App.state.scene.addChild(self)
    }
    
    func setupPhysicsBody() {
        if isPhyscisBody { return }
        isPhyscisBody = true
        
        self.physicsBody = SKPhysicsBody(texture: drawing.texture!, size: drawing.size)
        self.physicsBody?.isDynamic = isDynamic
        self.physicsBody?.restitution = 1
        self.physicsBody?.linearDamping = 0
    }
    
    func highlightGraphics() {
        drawing.color = .red
        drawing.colorBlendFactor = 1.0
    }
    
    func highlightGraphicsOff() {
        drawing.color = .white
        drawing.colorBlendFactor = 1.0
    }
    
    func calculateCombinedCenterPosition(combinedNode: SKNode) -> CGPoint {
        var minX: CGFloat?
        var minY: CGFloat?
        var maxX: CGFloat?
        var maxY: CGFloat?
        
        for node in combinedNode.children {
            minX = (node.calculateAccumulatedFrame().minX <= minX ?? node.calculateAccumulatedFrame().minX) ? node.calculateAccumulatedFrame().minX : minX
            minY = (node.calculateAccumulatedFrame().minY <= minY ?? node.calculateAccumulatedFrame().minY) ? node.calculateAccumulatedFrame().minY : minY
            maxX = (node.calculateAccumulatedFrame().maxX >= maxX ?? node.calculateAccumulatedFrame().maxX) ? node.calculateAccumulatedFrame().maxX : maxX
            maxY = (node.calculateAccumulatedFrame().maxY >= maxY ?? node.calculateAccumulatedFrame().maxY) ? node.calculateAccumulatedFrame() .maxY : maxY
        }
        
        let center = CGPoint(x: (minX!+maxX!)/2, y: (minY!+maxY!)/2)
        return center
    }
    
    func setupTransformationControl() {
        warpGeometryGrid = SKWarpGeometryGrid(columns: 2, rows: 2)
        let width = drawing.size.width
        let height = drawing.size.height
        for i in 0..<warpGeometryGrid.vertexCount {
            let scaledX = warpGeometryGrid.sourcePosition(at: i).x
            let scaledY = warpGeometryGrid.sourcePosition(at: i).y
            transformationControl.append(warpGeometryGrid.sourcePosition(at: i))
            let controlPointNode = SKShapeNode(circleOfRadius: 5)
            let cornerStart = CGPoint(x: -width/2, y: -height/2)
            controlPointNode.position.x = cornerStart.x + CGFloat(scaledX) * width
            controlPointNode.position.y = cornerStart.y + CGFloat(scaledY) * height
            controlPoints.append(controlPointNode)
            self.addChild(controlPointNode)
        }
        isUserInteractionEnabled = true
    }
    
    func applyWarping(warping: [SIMD2<Float>]) {
        drawing.warpGeometry = warpGeometryGrid.replacingByDestinationPositions(positions: warping)
        // update the position of control points based on warping
        for i in 0..<warping.count {
            controlPoints[i].position.x = (CGFloat(warping[i].x) - 0.5) * drawing.size.width
            controlPoints[i].position.y = (CGFloat(warping[i].y) - 0.5) * drawing.size.height
        }
    }
    
    func hideControlPoints() {
        for point in controlPoints {
            if point.parent != nil {
                point.removeFromParent()
            }
            
        }
        
        isUserInteractionEnabled = false
    }
    
    func showControlPoints() {
        for point in controlPoints {
            if point.parent == nil {
                self.addChild(point)
            }
        }
        
        isUserInteractionEnabled = true
    }
    
    func updateWarping() {
        for i in 0..<warpGeometryGrid.vertexCount {
            let pos = controlPoints[i].position
            let warpControlPointX = pos.x/drawing.size.width + 0.5
            let warpControlPointY = pos.y/drawing.size.height + 0.5
            let warpControlPoint = SIMD2(Float(warpControlPointX), Float(warpControlPointY))
            transformationControl[i] = warpControlPoint
        }
        
        applyWarping(warping: transformationControl)
    }
    
    func switchToDrawing(_ drawingToSwitch: SKSpriteNode) {
        drawingSecond?.removeFromParent()
        drawing.removeFromParent()
        
        drawingSecond = drawingToSwitch
        self.addChild(drawingSecond!)
//        if index == 1 {
//            self.addChild(drawing)
//        } else if index == 0 {
//            self.addChild(drawingSecond!)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        let selectedNodes = nodes(at: touchPoint)
        selectedControlPoint = selectedNodes.first(where: {$0 is SKShapeNode})
        if selectedControlPoint == nil {
            if let node = selectedNodes.first(where: {$0 is SKSpriteNode}) as? SKSpriteNode {
                selectedControlPoint = node
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self) else { return }
        if selectedControlPoint is SKShapeNode {
            selectedControlPoint?.position = touchPoint
            updateWarping()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedControlPoint = nil
    }
}
