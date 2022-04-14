//
//  Scene.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/14/22.
//

import SpriteKit
import ARKit

class Scene: SKScene, SKPhysicsContactDelegate {
    
    var drawPathArray = [CGPoint]()
    var lineTemp = SKShapeNode()
    var pathTemp = CGMutablePath()
    var rectangle = SKShapeNode()
    var secondDrawingTemp: SKSpriteNode?
    var secondPathTemp = CGMutablePath()
    
    var startTime: TimeInterval!
    
    var timeArray = [TimeInterval]()
    var velocityArray = [CGFloat]()
    
    
        
    override func didMove(to view: SKView) {
        // Setup your scene here
        physicsWorld.contactDelegate = self
        print(1)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print(1)
//        contact.bodyA.node?.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 1000))
//        contact.bodyB.node?.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 1000))
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        // check if the touch is from the apple pencil
        guard let touch = touches.first else { return }
        if !touch.estimatedPropertiesExpectingUpdates.contains(.force) {
            return
        }
        
        // pick color
        if App.state.isPickingColor {
            let cameraImage = App.state.cameraImage!
            let src: UIImage? = UIImage(cgImage: cameraImage)
            
            let touch = touch.location(in: self)
            let touchPoint = convertPoint(toView: touch)
            
            let screenX = touchPoint.x
            let screenY = touchPoint.y
            
            let x = Int(screenX / App.state.sceneView.frame.width * (src?.size.width)!)
            let y = Int(screenY / 794 * (src?.size.height)!)
            
            let color = src?.pixelColor(x: x, y: y)
            let r = color!.redValue * 255
            let g = color!.greenValue * 255
            let b = color!.blueValue * 255
            
            App.state.pickedRed = Int32(r)
            App.state.pickedGreen = Int32(g)
            App.state.pickedBlue = Int32(b)
            
            print("b\(b) g\(g) r\(r)")
            
//            App.state.isPickingColor = false
            
//            return
        }
        
        let touchPoint = touch.location(in: self)
        drawPathArray.append(touchPoint)
        pathTemp.move(to: touchPoint)
        
        if App.state.currentState == App.state.STATE_MAPPING {
            mappingTouchesBegan(touches)
        }
        
        if App.state.currentState == App.state.STATE_ENDUSER {
            endUserTouchesBegan(touches)
        }
        
//        print(convertPoint(toView: touchPoint))
        

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !touch.estimatedPropertiesExpectingUpdates.contains(.force) {
            return
        }
        let touchPoint = touch.location(in: self)
        
        drawPathArray.append(touchPoint)
        
        pathTemp.addLine(to: touchPoint)
        self.removeChildren(in: [lineTemp])
        lineTemp.path = pathTemp
        lineTemp.strokeColor = .white
        lineTemp.lineWidth = App.state.DRAWING_LINEWIDTH
        self.addChild(lineTemp)
        
        if App.state.currentState == App.state.STATE_MAPPING {
            mappingTouchesMoved(touches)
        }
        
        if App.state.currentState == App.state.STATE_ENDUSER {
            endUserTouchesMoved(touches)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeChildren(in: [lineTemp])
        
        // add velocity
        if App.state.addVelocity {
            guard let touch = touches.first?.location(in: self) else { return }
            let nodes = nodes(at: touch)
            let graphic = nodes.first(where: {$0 is GraphicsNode})
            graphic?.physicsBody?.velocity = CGVector(dx: 600, dy: 0)
            
            return
        }
        
        if App.state.makeStable {
            guard let touch = touches.first?.location(in: self) else { return }
            let nodes = nodes(at: touch)
            let graphic = nodes.first(where: {$0 is GraphicsNode})
            graphic?.physicsBody?.isDynamic = false
            
            return
        }
        
        // Rigging of the object
        if App.state.currentState == App.state.STATE_RIGGING {
            // creat the path object
            let path = CGMutablePath()
            path.move(to: drawPathArray[0])
            for point in drawPathArray {
                path.addLine(to: point)
            }
            // check if the path contain the marker
            var selectedNodes = [MarkerNode]()
            for node in App.state.markerNodes {
                if path.contains(node.position) {
                    selectedNodes.append(node)
                }
            }
            // check if the selected marker can construct a link
            let linkNode = LinkNode()
            self.addChild(linkNode)
            if selectedNodes.count >= 2 {
                linkNode.setup(selectedNodes)
            }
        }
        
        // Drawing Graphics
        if App.state.currentState == App.state.STATE_DRAWING {
            let path = CGMutablePath()
            path.move(to: drawPathArray[0])
            for point in drawPathArray {
                path.addLine(to: point)
            }
            let graphicsToDraw = GraphicsNode()
            
            let line = SKShapeNode(path: path)
            line.lineWidth = App.state.DRAWING_LINEWIDTH
            line.strokeColor = App.state.DRAWING_COLOR
            let texture = SKView().texture(from: line)
            let lineSprite = SKSpriteNode(texture: texture)
            
            graphicsToDraw.setup(drawing: lineSprite)
            let center = CGPoint(x: line.frame.midX, y: line.frame.midY)
            graphicsToDraw.position = center
            self.addChild(graphicsToDraw)
            
            App.state.drawingViewController.updateDrawingList()
        }
        
        if App.state.currentState == App.state.STATE_GROUP {
            let path = CGMutablePath()
            path.move(to: drawPathArray[0])
            for point in drawPathArray {
                path.addLine(to: point)
            }
            // check if the line contains the sprite node (more than 1)
            var index = [Int]()
            var i = 0
            for node in App.state.drawingNodes {
                if path.contains(node.position) {
                    index.append(i)
                }
                i += 1
            }
            let graphicsToGroup = GraphicsNode()
            if index.count >= 2 {
                for index in index {
                    graphicsToGroup.drawingToGroup.append(App.state.drawingNodes[index])
                }
                graphicsToGroup.setupGroup()
            }
            
            App.state.drawingViewController.updateDrawingList()
        }
        
        // Creat mappings
        if App.state.currentState == App.state.STATE_MAPPING {
            mappingTouchesEnded(touches)
        }
        
        if App.state.currentState == App.state.STATE_ENDUSER {
            endUserTouchesEnded(touches)
        }
        
        
        pathTemp = CGMutablePath()
        drawPathArray.removeAll()
        
    
    }
    
    func btnRig() {
        if App.state.currentState == 0 {
            App.state.currentState = App.state.STATE_RIGGING
        }
    }
    
    func btnDraw() {
        App.state.currentState = App.state.STATE_DRAWING
    }
    
    func btnGroup() {
        App.state.currentState = App.state.STATE_GROUP
    }
    
    func btnMapping() {
        App.state.currentState = App.state.STATE_MAPPING
    }
    
    func btnAffix() {
        App.state.typeOfMapping = App.state.TYPE_AFFIXING
        
    }
    
    func btnPhysics() {
        App.state.typeOfMapping = App.state.TYPE_PHYSICS
    }
    
    func btnSwitchStates() {
        App.state.typeOfMapping = App.state.TYPE_SWITCH_STATES
    }
    
    func btnInterpolation() {
        App.state.typeOfMapping = App.state.TYPE_INTERPOLATION
    }
    
}
