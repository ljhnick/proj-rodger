//
//  Mapping.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import SpriteKit
import ARKit
import UIKit

extension Scene {

    func mappingTouchesBegan(_ touches: Set<UITouch>) {
        // update the mappings
        let nodesToUpdate = nodes(at: drawPathArray.first!)
        if App.state.mappingTemp is AffixingNode {
            switch App.state.updatingTarget {
            case App.state.UPDATE_INPUT_TARGET:
                guard let nodeToUpdate = nodesToUpdate.first(where: {$0 is LinkNode}) else { return }
                let mappingToUpdate = App.state.mappingTemp as! AffixingNode
                mappingToUpdate.update(input: (nodeToUpdate as! LinkNode), output: nil)
            case App.state.UPDATE_OUTPUT_TARGET:
                guard let nodeToUpdate = nodesToUpdate.first(where: {$0 is GraphicsNode}) else { return }
                App.state.mappingTemp.outputNode = nodeToUpdate
                let mappingToUpdate = App.state.mappingTemp as! AffixingNode
                mappingToUpdate.update(input: nil, output: (nodeToUpdate as! GraphicsNode))
            default:
                ()
            }
        }
        
        if App.state.mappingTemp is PhysicsSimulation {
            
        }
        
        if App.state.mappingTemp is InterpolationNode {
//            if let mapping = App.state.mappingTemp as? SwitchingNode {
//                if mapping.inputType == App.state.STATES_POSITION_MAG && App.state.mappingViewController.isUpdatingInState1 {
//
//                }
//            }
        }
    }
    
    func mappingTouchesMoved(_ touches: Set<UITouch>) {
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if mapping.inputType == App.state.STATES_POSITION_MAG && App.state.mappingViewController.isUpdatingInState1 {
                rectangle.removeFromParent()
                lineTemp.removeFromParent()
                let p1 = drawPathArray.first!
                let p2 = drawPathArray.last!
                let width = (p2-p1).x
                let height = (p2-p1).y
                rectangle = SKShapeNode(rect: CGRect(x: p1.x, y: p1.y, width: width, height: height))
                rectangle.lineWidth = 3
                self.addChild(rectangle)
            }
        }
    }
    
    func mappingTouchesEnded(_ touches: Set<UITouch>) {

        
        // switching node, draw another graphics
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if mapping.outputType == App.state.STATES_CHANGE_GRAPHICS && App.state.mappingViewController.isUpdatingOutState1 {
                if let output = mapping.outputNode as? GraphicsNode {
                    
                    App.state.secondPathTemp.move(to: drawPathArray[0])
                    for point in drawPathArray {
                        App.state.secondPathTemp.addLine(to: point)
                    }
//                    App.state.secondPathTemp.closeSubpath()
                    let line = SKShapeNode(path: App.state.secondPathTemp)
                    line.strokeColor = .systemRed
                    line.lineWidth = App.state.DRAWING_LINEWIDTH
                    let texture = SKView().texture(from: line)
                    let lineSprite = SKSpriteNode(texture: texture)
                    
                    mapping.outputStatesGraphics[0] = lineSprite
                    App.state.mappingViewController.outValue1.text = "click+2finish"
                    
//                    secondDrawingTemp = nodeToCombineSprite
                }
//                App.state.mappingViewController.isUpdatingOutState1 = false
                return
            }
            
            if mapping.outputType == App.state.STATES_PHYSIC_RELATION && App.state.mappingViewController.isUpdatingOutState1 {
                if mapping.isCreatingNewPhysics {
                    if let output = mapping.outputNode as? GraphicsNode {
                        let selectedNode = nodes(at: drawPathArray.last!)
                        let graphic = selectedNode.first(where: {$0 is GraphicsNode}) as! GraphicsNode
                        let mappingNode = PhysicsSimulation()
                        mappingNode.inputLocal = output
                        mappingNode.outputLocal = graphic
                        mapping.outputPhysics = mappingNode
                        App.state.mappingViewController.outValue1.text = "connected"
                    } else {
                        App.state.mappingViewController.outValue1.text = "not connected"
                    }
                }
                App.state.mappingViewController.isUpdatingOutState1 = false
                App.state.mappingViewController.outValue1.endEditing(true)
                
                return
            }
            
            if mapping.inputType == App.state.STATES_POSITION_MAG && App.state.mappingViewController.isUpdatingInState1 {
                rectangle.removeFromParent()
                let p1 = drawPathArray.first!
                let p2 = drawPathArray.last!
                mapping.inputRangeVector[0] = mapping.convertPointToReference(point: p1, reference: mapping.reference)
                mapping.inputRangeVector[1] = mapping.convertPointToReference(point: p2, reference: mapping.reference)
                
                App.state.mappingViewController.isUpdatingInState1 = false
                App.state.mappingViewController.inValue1.text = "point 1"
                App.state.mappingViewController.inValue2.text = "point 2"
                return
            }
        }
        
        if App.state.typeOfMapping == App.state.TYPE_AFFIXING {
            let outputNodes = nodes(at: drawPathArray.first!)
            let inputNodes = nodes(at: drawPathArray.last!)
            guard let selectedGraphicNode = outputNodes.first(where: {$0 is GraphicsNode}) else { return }
            guard let selectedLinkNode = inputNodes.first(where: {$0 is LinkNode}) else { return }
            
            // create mapping
            let mappingNode = AffixingNode()
            App.state.mappingTemp = mappingNode
            mappingNode.setup(input: selectedLinkNode as! LinkNode, output: selectedGraphicNode as! GraphicsNode)
            
            // add to the dataset
//            App.state.mappingNodes.append(mappingNode)
            App.state.mappingViewController.btnAdd()
        }
        
        if App.state.typeOfMapping == App.state.TYPE_PHYSICS {
            let start = nodes(at: drawPathArray.first!)
            let end = nodes(at: drawPathArray.last!)
            guard let graphic_1 = start.first(where: {$0 is GraphicsNode}) as? GraphicsNode else { return }
            guard let graphic_2 = end.first(where: {$0 is GraphicsNode}) as? GraphicsNode else { return }
            // check if multiple graphics is selected
            graphic_1.setupPhysicsBody()
            graphic_2.setupPhysicsBody()
            
            // check
            if graphic_1 == graphic_2 {
//                graphic_1.physicsBody?.isDynamic = false
                return }
            
            // create the node and update it to storage
            let mappingNode = PhysicsSimulation()
            App.state.mappingTemp = mappingNode
            
            mappingNode.setup(input: graphic_1, output: graphic_2, pointA: drawPathArray.first, pointB: drawPathArray.last)
            
            // add to dataset
//            App.state.mappingNodes.append(mappingNode)
            App.state.mappingViewController.btnAdd()
        }
        
       
        if App.state.selectingReference {
            let selectedNode = nodes(at: drawPathArray.last!)
            if let graphic = selectedNode.first(where: {$0 is GraphicsNode}) as? GraphicsNode {
                App.state.mappingTemp.reference = graphic
                App.state.mappingViewController.referenceTextField.text = graphic.name
            } else {
                App.state.mappingTemp.reference = nil
                App.state.mappingViewController.referenceTextField.text = "World"
            }
            App.state.selectingReference = false
            return
        }
        
        
        if App.state.typeOfMapping == App.state.TYPE_INTERPOLATION {
            // check if the text field is clicked
            if App.state.updatingStatus {
                if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
                    let nodesToUpdate = nodes(at: drawPathArray.first!)
                    let linkNode = nodesToUpdate.first(where: {$0 is LinkNode})
                    let markerNode = nodesToUpdate.first(where: {$0 is MarkerNode})
                    let graphicNode = nodesToUpdate.first(where: {$0 is GraphicsNode})
                    
                    if linkNode != nil {
                        let node = linkNode as! LinkNode
                        let pointInView = convertPoint(toView: node.midPositionOfMarkers)
                        App.state.mainViewController.createButtonMenu(position: pointInView, node: node)
                    }
                    
                    if markerNode != nil {
                        let node = markerNode as! MarkerNode
                        if node.isJoint {
                            let pointInView = convertPoint(toView: node.position)
                            App.state.mainViewController.createButtonMenu(position: pointInView, node: node)
                        }
                    }
                    
                    if graphicNode != nil {
                        let node = graphicNode as! GraphicsNode
                        let pointInView = convertPoint(toView: node.position)
                        App.state.mainViewController.createButtonMenu(position: pointInView, node: node)
                    }
                } else if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
                    let nodesToUpdate = nodes(at: drawPathArray.first!)
                    guard let graphicNode = nodesToUpdate.first(where: {$0 is GraphicsNode}) else { return }
                    let pointInView = convertPoint(toView: graphicNode.position)
                    App.state.mainViewController.createButtonMenu(position: pointInView, node: graphicNode)
                }
            }
            //
        }
        
        if App.state.typeOfMapping == App.state.TYPE_SWITCH_STATES {
            
            // select the input and output targets
            if App.state.updatingStatus {
                if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
                    let nodesToUpdate = nodes(at: drawPathArray.first!)
                    
                    if let linkNode = nodesToUpdate.first(where: {$0 is LinkNode}) as? LinkNode {
                        let pointInView = convertPoint(toView: linkNode.midPositionOfMarkers)
                        App.state.mainViewController.createButtonMenu(position: pointInView, node: linkNode)
                    }
                    if let markerNode = nodesToUpdate.first(where: {$0 is MarkerNode}) as? MarkerNode {
                        if markerNode.isJoint {
                            let pointInView = convertPoint(toView: markerNode.position)
                            App.state.mainViewController.createButtonMenu(position: pointInView, node: markerNode)
                        }
                    }
                    if let graphicNode = nodesToUpdate.first(where: {$0 is GraphicsNode}) as? GraphicsNode {
                        let pointInView = convertPoint(toView: graphicNode.position)
                        App.state.mainViewController.createButtonMenu(position: pointInView, node: graphicNode)
                    }
                    
                } else if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
                    let nodesToUpdate = nodes(at: drawPathArray.first!)
                    guard let graphicNode = nodesToUpdate.first(where: {$0 is GraphicsNode}) else { return }
                    let pointInView = convertPoint(toView: graphicNode.position)
                    App.state.mainViewController.createButtonMenu(position: pointInView, node: graphicNode)
                }
            }
            // specify the states
            
        }
    }
}
