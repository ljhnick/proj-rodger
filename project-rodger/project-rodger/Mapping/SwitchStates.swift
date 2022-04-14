//
//  SwitchStates.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/21/22.
//

import ARKit
import SpriteKit
import SceneKit

class SwitchingNode: MappingNode {
//    var reference: SKNode?
    var isRepetitive = true
    var isSatisfied = false
    
    var inputType = App.state.STATES_NONE
    var outputType = App.state.STATES_NONE
    
    var currentStateIndex = 0
    
    var currentInputValue = CGFloat()
    var currentInputVector = CGPoint()
    var currentInputBool = Bool()
    
    var inputRangeValue = Array(repeating: CGFloat.zero, count: 2)
    var inputRangeVector = Array(repeating: CGPoint.zero, count: 2)
    var inputRangeBool = Array(repeating: Bool(), count: 2)
    
    var outputValue = CGFloat()
    var outputTransform = [SIMD2<Float>]()
    var outputGraphics = SKSpriteNode()
    var outputPhysics = PhysicsSimulation()
    var outputMappingOnOff = Bool()
    var outputColor = UIColor()
    
    var outputSelfOnOff = Bool()
    
    var outputStatesValue = Array(repeating: CGFloat(), count: 2)
    var outputStatesTransform = Array(repeating: [SIMD2<Float>](), count: 2)
    var outputStatesGraphics = Array(repeating: SKSpriteNode(), count: 2)
    var outputStatesPhysics = Array(repeating: Bool(), count: 2)
    var outputStatesMappingOnOff = [true, false]
    var outputStatesColor = Array(repeating: UIColor(), count: 2)
    
    var outputStatesSelfOnOff = Array(repeating: Bool(), count: 2)
    
    var isCreatingNewPhysics = false
    
    func setup() {
        if let output = outputNode as? MappingNode {
            output.activateStatus = false
            App.state.mappingViewController.outValue1.text = "1"
            App.state.mappingViewController.outValue2.text = "0"
            isRepetitive = App.state.mappingViewController.isRepetitive
            output.hierarchy = self.hierarchy + 1
        }
        
        if let output = outputNode as? GraphicsNode {
            if outputType == App.state.STATES_TRANSFORMATION {
                output.setupTransformationControl()
            }
            if outputType == App.state.STATES_COLOR_CHANGE {
                outputStatesColor[0] = .white
                outputStatesColor[1] = .white
            }
            if outputType == App.state.STATES_PHYSIC_RELATION {
                for mapping in App.state.mappingNodes {
                    if mapping is PhysicsSimulation {
                        if mapping.inputNode == output || mapping.outputNode == output {
                            outputPhysics = mapping as! PhysicsSimulation
                            outputStatesPhysics[0] = false
                            outputStatesPhysics[1] = true
                            App.state.mappingViewController.outValue1.text = "0"
                            App.state.mappingViewController.outValue2.text = "1"
                            isCreatingNewPhysics = false
                            break
                        }
                    }
                }
                if outputPhysics.inputNode == nil {
                    outputStatesPhysics[0] = true
                    outputStatesPhysics[1] = false
                    App.state.mappingViewController.outValue1.text = "1"
                    App.state.mappingViewController.outValue2.text = "0"
                    isCreatingNewPhysics = true
                }
            }
            if outputType == App.state.STATES_CHANGE_GRAPHICS {
                if let output = outputNode as? GraphicsNode {
                    outputStatesGraphics[1] = output.drawing
                }
            }
        }
        
        if let input = inputNode as? SwitchingNode {
            inputRangeBool[0] = true
            inputRangeBool[1] = false
            App.state.mappingViewController.inValue1.text = "1"
            App.state.mappingViewController.inValue2.text = "0"
            self.hierarchy = input.hierarchy + 1
        }
        
        let numOfMappings = App.state.mappingNodes.count
        self.name = "Mapping #\(numOfMappings), type: Switching"
    }
    
    func activateState(index: Int) {
        switch outputType {
        case App.state.STATES_MAPPING_ONOFF_OUTPUT:
            if let mapping = outputNode as? MappingNode {
                mapping.activateStatus = outputStatesMappingOnOff[index]
            }
        case App.state.STATES_TRANSFORMATION:
            if let output = outputNode as? GraphicsNode {
                output.applyWarping(warping: outputStatesTransform[index])
            }
        case App.state.STATES_CHANGE_GRAPHICS:
            if let output = outputNode as? GraphicsNode {
//                output.switchToDrawing(index: index)
                output.switchToDrawing(outputStatesGraphics[index])
            }
        case App.state.STATES_COLOR_CHANGE:
            if let output = outputNode as? GraphicsNode {
                let color = outputStatesColor[index]
                output.drawing.color = color
                output.drawing.colorBlendFactor = 1.0
            }
        case App.state.STATES_PHYSIC_RELATION:
            outputPhysics.changeStatusSwitching(activate: outputStatesPhysics[index], isCreatingNew: isCreatingNewPhysics)
        case App.state.STATES_SCALE:
            if let output = outputNode as? GraphicsNode {
                output.setScale(outputStatesValue[index])
            }
        case App.state.STATES_VISIBILITY:
            if let output = outputNode as? GraphicsNode {
                output.alpha = outputStatesValue[index]
            }
        case App.state.STATES_MAPPING_ONOFF_INPUT:
            outputSelfOnOff = outputStatesSelfOnOff[index]
        default:
            ()
        }
    }

    func addAStateInput(index: Int, updateVal: CGFloat? = nil) {
        getCurrentIntput()
        if inputType != App.state.STATES_MAPPING_ONOFF_INPUT && inputType != App.state.STATES_POSITION_MAG {
            inputRangeValue[index] = currentInputValue
            if updateVal != nil {
                inputRangeValue[index] = updateVal!
            }
        }
        
        if inputType == App.state.STATES_POSITION_MAG {
            inputRangeVector[index] = currentInputVector
        }
    }
    
    func addAStateOutput(index: Int, updateVal: CGFloat? = nil) {
        getCurrentOutput()
        if outputType == App.state.STATES_MAPPING_ONOFF_OUTPUT {
            guard let value = updateVal else { return }
            if value == 1 {
                outputStatesMappingOnOff[index] = true
            } else if value == 0 {
                outputStatesMappingOnOff[index] = false
            }
            return
        }
        if outputType == App.state.STATES_TRANSFORMATION {
            getWarpingGeometry()
            outputStatesTransform[index] = outputTransform
            return
        }
        if outputType == App.state.STATES_CHANGE_GRAPHICS {
            ()
            return
        }
        if outputType == App.state.STATES_PHYSIC_RELATION {
            ()
            return
        }
        if outputType == App.state.STATES_COLOR_CHANGE {
            ()
            return
        }
        
        if updateVal == nil {
            outputStatesValue[index] = outputValue
        } else {
            outputStatesValue[index] = updateVal!
        }
    }
    
    func getCurrentIntput() {
        if let input = inputNode as? SwitchingNode {
            currentInputBool = input.outputStatesSelfOnOff[input.currentStateIndex]
        }
        switch inputType {
        case App.state.STATES_POSITION_MAG:
            currentInputVector = convertPointToReference(point: inputNode!.position, reference: self.reference)
        case App.state.STATES_POSITION_X:
            currentInputValue = convertPointToReference(point: inputNode!.position, reference: self.reference).x
        case App.state.STATES_POSITION_Y:
            currentInputValue = convertPointToReference(point: inputNode!.position, reference: self.reference).y
        case App.state.STATES_ORI:
            if let input = inputNode as? LinkNode {
                currentInputValue = input.orientation
            }
            if let input = inputNode as? GraphicsNode {
                currentInputValue = input.zRotation
            }
        case App.state.STATES_VELOCITY_MAG:
            if let input = inputNode as? LinkNode {
                currentInputValue = sqrt(input.posVel.dx * input.posVel.dx + input.posVel.dy * input.posVel.dy)
            }
            if let input = inputNode as? GraphicsNode {
                currentInputValue = sqrt(input.velocity!.dx * input.velocity!.dx + input.velocity!.dy * input.velocity!.dy)
            }
        case App.state.STATES_VELOCITY_X:
            if let input = inputNode as? LinkNode {
                currentInputValue = input.posVel.dx
            }
            if let input = inputNode as? GraphicsNode {
                currentInputValue = input.velocity!.dx
            }
        case App.state.STATES_VELOCITY_Y:
            if let input = inputNode as? LinkNode {
                currentInputValue = input.posVel.dy
            }
            if let input = inputNode as? GraphicsNode {
                currentInputValue = input.velocity!.dy
            }
        case App.state.STATES_ANGULAR_VEL:
            if let input = inputNode as? LinkNode {
                currentInputValue = input.angVel
            }
        case App.state.STATES_ANGLE:
            if let input = inputNode as? MarkerNode {
                currentInputValue = input.ang
            }
        case App.state.STATES_ANGLE_VEL:
            if let input = inputNode as? MarkerNode {
                currentInputValue = input.angVel
            }
        case App.state.STATES_DEPTH:
            if let input = inputNode as? LinkNode {
                currentInputValue = input.depth
            }
        default:
            ()
        }
    }
    
    func getCurrentOutput() {
        if outputType == App.state.STATES_MAPPING_ONOFF_OUTPUT {
            ()
            return
        }
        if outputType == App.state.STATES_TRANSFORMATION {
            getWarpingGeometry()
            return
        }
        if outputType == App.state.STATES_CHANGE_GRAPHICS {
            ()
            return
        }
        if outputType == App.state.STATES_PHYSIC_RELATION {
            ()
            return
        }
        if outputType == App.state.STATES_COLOR_CHANGE {
            ()
            return
        }
        
        switch outputType {
        case App.state.STATES_SCALE:
            if let output = outputNode as? GraphicsNode {
                outputValue = output.xScale
            }
        case App.state.STATES_VISIBILITY:
            if let output = outputNode as? GraphicsNode {
                outputValue = output.alpha
                print(outputValue)
            }
        default:
            ()
        }
        
    }
    
    // if the output is the transformation of graphics
    func getWarpingGeometry() {
        if let output = outputNode as? GraphicsNode {
            outputTransform = output.transformationControl
        }
    }
    
    func convertPointToReference(point: CGPoint, reference: SKNode?) -> CGPoint {
        guard let ref = reference else { return point }
        return convert(point, to: ref)
    }
    
    override func activateMapping() {
        if inputNode != nil && outputNode != nil {
            isSetup = true
        }
        
        if inputNode != nil && outputNode == nil {
            outputStatesSelfOnOff[0] = true
            outputStatesSelfOnOff[1] = false
            outputType = App.state.STATES_MAPPING_ONOFF_INPUT
            isSetup = true
            let numOfMappings = App.state.mappingNodes.count
            self.name = "Mapping #\(numOfMappings), type: On/Off"
        }
    }
    
    override func setupStatesInputOutput() {
        if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
            inputType = App.state.STATES
            App.state.mappingViewController.inTargetText.text = inputNode!.name! + App.state.mappingViewController.stringifyStatesType(stateTag: App.state.STATES)
        } else if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
            outputType = App.state.STATES
            App.state.mappingViewController.outTargetText.text = outputNode!.name! + App.state.mappingViewController.stringifyStatesType(stateTag: App.state.STATES)
        }
        
        if inputType != App.state.STATES_NONE && outputType != App.state.STATES_NONE {
            setup()
        }
    }
    
    override func updateMapping() {
        updateHierarchy()
        if !activateStatus { return }
        if !isRepetitive && isSatisfied { return }
        
        getCurrentIntput()
        // check if the input is in the range
        var flag = false
        if inputType != App.state.STATES_MAPPING_ONOFF_INPUT && inputType != App.state.STATES_POSITION_MAG {
            if currentInputValue <= inputRangeValue.max()! && currentInputValue >= inputRangeValue.min()! {
                flag = true
            }
        }
        
        if inputType == App.state.STATES_POSITION_MAG {
            let x = currentInputVector.x
            let y = currentInputVector.y
            if x < max(inputRangeVector[0].x, inputRangeVector[1].x) && x > min(inputRangeVector[0].x, inputRangeVector[1].x) {
                if y < max(inputRangeVector[0].y, inputRangeVector[1].y) && y > min(inputRangeVector[0].y, inputRangeVector[1].y) {
                    flag = true
                } else {
                    flag = false
                }
            } else {
                flag = false
            }
            
        }
        
        if inputType == App.state.STATES_MAPPING_ONOFF_INPUT {
            flag = currentInputBool
//            print(flag)
        }
        
        if flag {
            currentStateIndex = 0
            activateState(index: 0)
            isSatisfied = true
        } else {
            currentStateIndex = 1
            activateState(index: 1)
        }
        
    }
    
    override func isBeingUpdated() {
        if outputType == App.state.STATES_TRANSFORMATION {
            if let output = outputNode as? GraphicsNode {
                output.showControlPoints()
            }
//            activateStatus = false
        }
    }
    
    override func didBeingUpdated() {
        if outputType == App.state.STATES_TRANSFORMATION {
            if let output = outputNode as? GraphicsNode {
                output.hideControlPoints()
            }
        }
        
        activateStatus = true
    }
}
