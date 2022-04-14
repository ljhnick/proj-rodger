//
//  MappingViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/23/22.
//

import UIKit
import SpriteKit
import ARKit

class MappingViewController: UIViewController, UITextFieldDelegate {
    
    // Load the SKScene from 'Scene.sks'
    var skScene = Scene(fileNamed: "Scene")!

//    @IBOutlet weak var toggleWithStates: UISegmentedControl!
    @IBOutlet weak var toggleSubType: UISegmentedControl!

    @IBOutlet weak var mappingType: UILabel!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var inTargetText: UITextField!
    @IBOutlet weak var inValue1: UITextField!
    @IBOutlet weak var inValue2: UITextField!
    @IBOutlet weak var inValue3: UITextField!
    @IBOutlet weak var outTargetText: UITextField!
    @IBOutlet weak var outValue1: UITextField!
    @IBOutlet weak var outValue2: UITextField!
    @IBOutlet weak var outValue3: UITextField!
    @IBOutlet weak var referenceTextField: UITextField!
    @IBOutlet weak var btnNone: UIButton!
    @IBOutlet weak var btnSpring: UIButton!
    @IBOutlet weak var btnString: UIButton!
    @IBOutlet weak var btnRepetitive: UIButton!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var btnAddMoreStates: UIButton!
    
    @IBOutlet weak var btnWhite: UIButton!
    @IBOutlet weak var btnBlue: UIButton!
    @IBOutlet weak var btnYellow: UIButton!
    @IBOutlet weak var btnRed: UIButton!
    @IBOutlet weak var btnPurple: UIButton!
    @IBOutlet weak var btnGreen: UIButton!
    
    var isUpdatingInState1 = false
    var isUpdatingInState2 = false
    var isUpdatingOutState1 = false
    var isUpdatingOutState2 = false
    
    var isDrawingForSwitchingMapping = false
    var isRepetitive = true
    
    var isPhysics = false
    
    lazy var discLine = CAShapeLayer()
    lazy var contLine = CAShapeLayer()
//    @IBAction func toggleWithStatesAction(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            toggleSubType.setTitle("w/o simulation", forSegmentAt: 0)
//            toggleSubType.setTitle("w/ simulation", forSegmentAt: 1)
//            changeStatusStatesTextFields(false)
//        } else {
//            toggleSubType.setTitle("discrete", forSegmentAt: 0)
//            toggleSubType.setTitle("continuous", forSegmentAt: 1)
//            changeStatusStatesTextFields(true)
//        }
//        toggleSubTypeAction(toggleSubType)
//    }
    
    @IBAction func toggleSubTypeAction(_ sender: UISegmentedControl) {
        deactivatePhysics()
        btnRecord.isHidden = true
        btnAddMoreStates.isHidden = true
        isColorBtnHidden(true)
        if toggleSubType.selectedSegmentIndex == 0 {
            App.state.typeOfMapping = App.state.TYPE_AFFIXING
            App.state.mappingTemp = AffixingNode()
            mappingType.text = "Affixing"
            changeStatusStatesTextFields(false)
            
            instructionText.text = "Draw a line to directly connect the *Graphics*(#1) to the *Links*(#2)"
            
            btnAddMoreStates.isHidden = true
            
            inTargetText.text = "direct draw"
            outTargetText.text = "direct draw"
            
            discLine.removeFromSuperlayer()
            contLine.removeFromSuperlayer()
        } else if toggleSubType.selectedSegmentIndex == 1 {
            App.state.typeOfMapping = App.state.TYPE_SWITCH_STATES
            App.state.mappingTemp = SwitchingNode()
            mappingType.text = "Switching"
            changeStatusStatesTextFields(true)
            drawLinesForDisc()
            btnAddMoreStates.isHidden = true
            
            inTargetText.text = "click to select"
            outTargetText.text = "click to select"
            
            instructionText.text = "Specify the input/output target and then specify the states (the state between the #1 and #2 input states will trigger output state 1)"
        } else {
            App.state.typeOfMapping = App.state.TYPE_INTERPOLATION
            App.state.mappingTemp = InterpolationNode()
            mappingType.text = "Interpolation"
            changeStatusStatesTextFields(true)
            drawLinesForCont()
            btnAddMoreStates.isHidden = false
            instructionText.text = "Specify the input/output target and then specify the states (the output will be interpolated based on the input between the two states)"
            
            inTargetText.text = "click to select"
            outTargetText.text = "click to select"
        }
        
//        inTargetText.text = nil
//        outTargetText.text = nil
    }
    
    func drawLinesForDisc() {
        discLine.removeFromSuperlayer()
        contLine.removeFromSuperlayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 505, y: 75))
        path.addLine(to: CGPoint(x: 528, y: 75))
        
        path.close()
        path.move(to: CGPoint(x: 505, y: 120))
        path.addLine(to: CGPoint(x: 528, y: 75))
        
        discLine.path = path.cgPath
        discLine.strokeColor = UIColor.white.cgColor
        discLine.fillColor = UIColor.clear.cgColor
        discLine.lineWidth = 1
        
        self.view.layer.addSublayer(discLine)
    }
    
    func drawLinesForCont() {
        discLine.removeFromSuperlayer()
        contLine.removeFromSuperlayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 505, y: 75))
        path.addLine(to: CGPoint(x: 528, y: 75))
        
        path.close()
        path.move(to: CGPoint(x: 505, y: 120))
        path.addLine(to: CGPoint(x: 528, y: 120))
        
        contLine.path = path.cgPath
        contLine.strokeColor = UIColor.white.cgColor
        contLine.fillColor = UIColor.clear.cgColor
        contLine.lineWidth = 1
        
        self.view.layer.addSublayer(contLine)
    }
    
    @IBAction func referenceTextFieldPressed(_ sender: UITextField) {
        App.state.selectingReference = true
        provideVisualFeedback(sender)
    }
    
    @IBAction func inTargetClicked(_ sender: UITextField) {
        App.state.updatingStatus = true
        App.state.updatingTarget = App.state.UPDATE_INPUT_TARGET
        
        instructionText.text = "Click either a *Link*, a *Joint* or a *Graphic* to specify the input variable"
        provideVisualFeedback(sender)
    }
    
    @IBAction func outTargetClicked(_ sender: UITextField) {
        App.state.updatingStatus = true
        App.state.updatingTarget = App.state.UPDATE_OUTPUT_TARGET
        
        instructionText.text = "Click a *Graphic* to specify the output variable"
        provideVisualFeedback(sender)
    }
    
    @IBAction func inStateClicked1(_ sender: UITextField) {
        provideVisualFeedback(sender)
        isUpdatingInState1 = true
        
        instructionText.text = "Updating state #1 of the input, please type and click the + button"
        
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if mapping.inputType == App.state.STATES_POSITION_MAG {
                instructionText.text = "Draw a rectangle to specify the area of the position"
            }
        }
        
    }
    @IBAction func inStateClicked2(_ sender: UITextField) {
        provideVisualFeedback(sender)
        isUpdatingInState2 = true
    }
    @IBAction func outStateClicked1(_ sender: UITextField) {
        provideVisualFeedback(sender)
        isUpdatingOutState1 = true
        if let mappingNode = App.state.mappingTemp as? InterpolationNode {
            mappingNode.isBeingUpdated()
            mappingNode.interpolateOutput(u: 0)
            mappingNode.activateStatus = false
        }
    }
    @IBAction func outStateClicked2(_ sender: UITextField) {
        provideVisualFeedback(sender)
        isUpdatingOutState2 = true
        if let mappingNode = App.state.mappingTemp as? InterpolationNode {
            mappingNode.isBeingUpdated()
            mappingNode.interpolateOutput(u: 1)
            mappingNode.activateStatus = false
        }
    }
    
    
    @IBAction func addInState1(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        if let mapping = App.state.mappingTemp as? InterpolationNode {
            if isUpdatingInState1 {
                mapping.addAStateIn(index: 0, updateVal: inValue1.text!.CGFloatValue())
            } else {
                mapping.addAStateIn(index: 0)
                inValue1.text = String(format: "%.1f", mapping.uInput)
                if mapping.inputType == App.state.STATES_VELOCITY_Y || mapping.inputType == App.state.STATES_VELOCITY_X || mapping.inputType == App.state.STATES_VELOCITY_MAG || mapping.inputType == App.state.STATES_ANGLE_VEL || mapping.inputType == App.state.STATES_ANGULAR_VEL {
                    mapping.addAStateIn(index: 0, updateVal: App.state.selectedVelocity)
                    inValue1.text = String(format: "%.1f", App.state.selectedVelocity)
                }
            }
        }
        
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if mapping.inputType != App.state.STATES_MAPPING_ONOFF_INPUT && mapping.inputType != App.state.STATES_POSITION_MAG {
                if isUpdatingInState1 {
                    mapping.addAStateInput(index: 0, updateVal: inValue1.text!.CGFloatValue())
                } else {
                    mapping.addAStateInput(index: 0)
                    inValue1.text = String(format: "%.1f", mapping.currentInputValue)
                    if mapping.inputType == App.state.STATES_VELOCITY_Y || mapping.inputType == App.state.STATES_VELOCITY_X || mapping.inputType == App.state.STATES_VELOCITY_MAG || mapping.inputType == App.state.STATES_ANGLE_VEL || mapping.inputType == App.state.STATES_ANGULAR_VEL {
                        mapping.addAStateInput(index: 0, updateVal: App.state.selectedVelocity)
                        inValue1.text = String(format: "%.1f", App.state.selectedVelocity)
                    }
                }
            } else if mapping.inputType == App.state.STATES_MAPPING_ONOFF_INPUT {
        
            } else {
                inValue1.text = "Point 1"
            }
            
        }
        isUpdatingInState1 = false
        inValue1.endEditing(true)
    }
    
    @IBAction func addInState2(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        if let mapping = App.state.mappingTemp as? InterpolationNode {
            if isUpdatingInState2 {
                mapping.addAStateIn(index: 1, updateVal: inValue2.text!.CGFloatValue())
            } else {
                mapping.addAStateIn(index: 1)
                inValue2.text = String(format: "%.1f", mapping.uInput)
                if mapping.inputType == App.state.STATES_VELOCITY_Y || mapping.inputType == App.state.STATES_VELOCITY_X || mapping.inputType == App.state.STATES_VELOCITY_MAG || mapping.inputType == App.state.STATES_ANGLE_VEL || mapping.inputType == App.state.STATES_ANGULAR_VEL {
                    mapping.addAStateIn(index: 1, updateVal: App.state.selectedVelocity)
                    inValue2.text = String(format: "%.1f", App.state.selectedVelocity)
                }
            }
            
        }
        
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if mapping.inputType != App.state.STATES_MAPPING_ONOFF_INPUT && mapping.inputType != App.state.STATES_POSITION_MAG {
                if isUpdatingInState2 {
                    mapping.addAStateInput(index: 1, updateVal: inValue2.text!.CGFloatValue())
                } else {
                    mapping.addAStateInput(index: 1)
                    inValue2.text = String(format: "%.1f", mapping.currentInputValue)
                    if mapping.inputType == App.state.STATES_VELOCITY_Y || mapping.inputType == App.state.STATES_VELOCITY_X || mapping.inputType == App.state.STATES_VELOCITY_MAG || mapping.inputType == App.state.STATES_ANGLE_VEL || mapping.inputType == App.state.STATES_ANGULAR_VEL {
                        mapping.addAStateInput(index: 1, updateVal: App.state.selectedVelocity)
                        inValue2.text = String(format: "%.1f", App.state.selectedVelocity)
                    }
                    
                }
            } else if mapping.inputType == App.state.STATES_MAPPING_ONOFF_INPUT {
        
            } else {
                inValue2.text = "Point 2"
            }
            
        }
        isUpdatingInState2 = false
        inValue2.endEditing(true)
    }
    
    @IBAction func addOutState1(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        if let mapping = App.state.mappingTemp as? InterpolationNode {
            if App.state.STATES == App.state.STATES_TRANSFORMATION {
                mapping.addAStateOut(index: 0)
                outValue1.text = "Warp #1"
            } else {
                if isUpdatingOutState1 {
                    mapping.addAStateOut(index: 0, updateVal: outValue1.text!.CGFloatValue())
                } else {
                    mapping.addAStateOut(index: 0)
                }
                outValue1.text = "\(mapping.uOutputNonT)"
            }
            
        }
        
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if isUpdatingOutState1 {
                if mapping.outputType == App.state.STATES_COLOR_CHANGE {
                    mapping.outputStatesColor[0] = outValue1.backgroundColor!
                } else {
                    mapping.addAStateOutput(index: 0, updateVal: outValue1.text!.CGFloatValue())
                }
            } else {
                mapping.addAStateOutput(index: 0)
                outValue1.text = String(format: "%.1f", mapping.outputValue)
            }
            
        }
        isUpdatingOutState1 = false
        outValue1.endEditing(true)
        App.state.secondPathTemp = CGMutablePath()
    }
    
    @IBAction func addOutState2(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        if let mapping = App.state.mappingTemp as? InterpolationNode {
            if App.state.STATES == App.state.STATES_TRANSFORMATION {
                outValue2.text = "Warp #2"
                mapping.addAStateOut(index: 1)
            } else {
                if isUpdatingOutState2 {
                    mapping.addAStateOut(index: 1, updateVal: outValue2.text!.CGFloatValue())
                } else {
                    mapping.addAStateOut(index: 1)
                }
                outValue2.text = "\(mapping.uOutputNonT)"
            }
        }
        
        if let mapping = App.state.mappingTemp as? SwitchingNode {
            if isUpdatingOutState2 {
                if mapping.outputType == App.state.STATES_COLOR_CHANGE {
                    mapping.outputStatesColor[1] = outValue2.backgroundColor!
                } else {
                    mapping.addAStateOutput(index: 1, updateVal: outValue2.text!.CGFloatValue())
                }
//                mapping.addAStateOutput(index: 1, updateVal: outValue2.text!.CGFloatValue())
            } else {
                mapping.addAStateOutput(index: 1)
                outValue2.text = String(format: "%.1f", mapping.outputValue)
            }
        }
        isUpdatingOutState2 = false
        outValue2.endEditing(true)
    }
    
    @IBAction func btnRecord(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.isRecording.toggle()
        if !App.state.isRecording {
            // show the graph
            App.state.mainViewController.creatChart(time: App.state.timeArray, value: App.state.velocityArray)
            App.state.timeArray.removeAll()
            App.state.velocityArray.removeAll()
        }
    }
    
    @IBAction func btnPhysicsNone(_ sender: Any) {
        toggleSubType.selectedSegmentIndex = 0
        if btnNone.alpha == 1 {
            deactivatePhysics()
            toggleSubTypeAction(toggleSubType)
            return
        }
        App.state.typeOfPhysics = App.state.PHYSICS_NONE
        btnNone.alpha = 1
        btnSpring.alpha = 0.2
        btnString.alpha = 0.2
        isPhysics = true
        createPhysicsMapping()
        changeStatusStatesTextFields(false)
        instructionText.text = "Draw a line to assign one/two *Graphics* with physics body"
    }
    @IBAction func btnPhysicsSpring(_ sender: Any) {
        toggleSubType.selectedSegmentIndex = 0
        if btnSpring.alpha == 1 {
            deactivatePhysics()
            toggleSubTypeAction(toggleSubType)
            return
        }
        App.state.typeOfPhysics = App.state.PHYSICS_SPRING
        btnNone.alpha = 0.2
        btnSpring.alpha = 1
        btnString.alpha = 0.2
        isPhysics = true
        createPhysicsMapping()
        changeStatusStatesTextFields(false)
        instructionText.text = "Draw a line to assign two *Graphics* with physics body and connected with a Spring"

    }
    @IBAction func btnPhysicsString(_ sender: Any) {
        toggleSubType.selectedSegmentIndex = 0
        if btnString.alpha == 1 {
            deactivatePhysics()
            toggleSubTypeAction(toggleSubType)
            return
        }
        App.state.typeOfPhysics = App.state.PHYSICS_STRING
        btnNone.alpha = 0.2
        btnSpring.alpha = 0.2
        btnString.alpha = 1
        isPhysics = true
        createPhysicsMapping()
        changeStatusStatesTextFields(false)
        instructionText.text = "Draw a line to assign two *Graphics* with physics body and connected with a String"
    }
    
    func deactivatePhysics() {
        btnNone.alpha = 0.2
        btnSpring.alpha = 0.2
        btnString.alpha = 0.2
        App.state.typeOfPhysics = 0
        
        btnAddMoreStates.isHidden = false
        isPhysics = false
    }
    
    func createPhysicsMapping() {
        App.state.typeOfMapping = App.state.TYPE_PHYSICS
        App.state.mappingTemp = PhysicsSimulation()
        mappingType.text = "Physics"
        btnAddMoreStates.isHidden = true
    }
    
    @IBAction func btnSwitchRepetitive(_ sender: Any) {
        btnRepetitive.alpha = (btnRepetitive.alpha == 1) ? 0.2 : 1
        if btnRepetitive.alpha == 1 {
            isRepetitive = true
        } else {
            isRepetitive = false
        }
    }
    
    @IBAction func btnAdd() {
        App.state.mappingTemp.activateMapping()
        App.state.mappingTemp.didBeingUpdated()
        if !App.state.mappingTemp.isSetup { return }
        App.state.mappingNodes.append(App.state.mappingTemp)
        App.state.savingViewController.addAMapping(App.state.mappingTemp)
        
        // disable the user interaction
//        App.state.mappingTemp.isUserInteractionEnabled = false
        App.state.updatingStatus = false
        App.state.updatingTarget = 0
        App.state.mainViewController.velChart.removeFromSuperview()
        
        initInterface()
        
    }
    
    @IBAction func btnUpdate() {
        for mapping in App.state.mappingNodes {
            mapping.nodeNotHighlighted()
        }
        App.state.mappingTemp.activateMapping()
        App.state.mappingTemp.didBeingUpdated()
//        App.state.mappingTemp.isUserInteractionEnabled = false
//        updateMappingSection()
        App.state.updatingStatus = false
        App.state.updatingTarget = 0
        App.state.mainViewController.velChart.removeFromSuperview()
        
        inTargetText.text = nil
        outTargetText.text = nil
        inValue1.text = nil
        inValue2.text = nil
        outValue1.text = nil
        outValue2.text = nil
    }
    
    func initInterface() {
        inTargetText.text = nil
        outTargetText.text = nil
        inValue1.text = nil
        inValue2.text = nil
        outValue1.text = nil
        outValue2.text = nil
        
        inTargetText.endEditing(true)
        outTargetText.endEditing(true)
        inValue1.endEditing(true)
        inValue2.endEditing(true)
        outValue1.endEditing(true)
        outValue2.endEditing(true)
        
        toggleSubType.selectedSegmentIndex = 0
        toggleSubTypeAction(toggleSubType)
        
        btnRecord.isHidden = true
        btnAddMoreStates.isHidden = true
        
        outValue1.backgroundColor = .white
        outValue2.backgroundColor = .white
        
        App.state.DRAWING_COLOR = .white
    }
    
    func changeStatusStatesTextFields(_ bool: Bool) {
        inValue1.isUserInteractionEnabled = bool
        inValue2.isUserInteractionEnabled = bool
        outValue1.isUserInteractionEnabled = bool
        outValue2.isUserInteractionEnabled = bool
        referenceTextField.isUserInteractionEnabled = bool
        inTargetText.isUserInteractionEnabled = bool
        outTargetText.isUserInteractionEnabled = bool
        
        inValue1.alpha = bool ? 1 : 0.2
        inValue2.alpha = bool ? 1 : 0.2
        outValue1.alpha = bool ? 1 : 0.2
        outValue2.alpha = bool ? 1 : 0.2
        referenceTextField.alpha = bool ? 1 : 0.2
        inTargetText.alpha = bool ? 1 : 0.5
        outTargetText.alpha = bool ? 1 : 0.5
        
    }
    
    func updateMappingSection() {
        let mappingNode = App.state.mappingTemp
        
        mappingNode.isBeingUpdated()
        inTargetText.text = mappingNode.inputNode?.name
        outTargetText.text = mappingNode.outputNode?.name
        
        if let mapping = mappingNode as? InterpolationNode {
            inValue1.text = "\(mapping.inputStates[0])"
            inValue2.text = "\(mapping.inputStates[1])"
            outValue1.text = "\(mapping.outputStatesNonTransformation[0])"
            outValue2.text = "\(mapping.outputStatesNonTransformation[1])"
            if mapping.outputType == App.state.STATES_TRANSFORMATION {
                outValue1.text = "first"
                outValue2.text = "second"
            }
        }
        
        if let mapping = mappingNode as? SwitchingNode {
            inValue1.text = "\(mapping.inputRangeValue[0])"
            inValue2.text = "\(mapping.inputRangeValue[1])"
            outValue1.text = "\(mapping.outputStatesValue[0])"
            outValue2.text = "\(mapping.outputStatesValue[1])"
        }
        
        
        if mappingNode is AffixingNode {
//            toggleSubType.setTitle("w/o simulation", forSegmentAt: 0)
//            toggleSubType.setTitle("w/ simulation", forSegmentAt: 1)
//            toggleWithStates.selectedSegmentIndex = 0
            toggleSubType.selectedSegmentIndex = 0
            changeStatusStatesTextFields(false)
        } else if mappingNode is PhysicsSimulation {
//            toggleSubType.setTitle("w/o simulation", forSegmentAt: 0)
//            toggleSubType.setTitle("w/ simulation", forSegmentAt: 1)
//            toggleWithStates.selectedSegmentIndex = 0
            toggleSubType.selectedSegmentIndex = 0
            changeStatusStatesTextFields(false)
        } else if mappingNode is InterpolationNode {
//            toggleSubType.setTitle("discrete", forSegmentAt: 0)
//            toggleSubType.setTitle("continuous", forSegmentAt: 1)
//            toggleWithStates.selectedSegmentIndex = 1
            toggleSubType.selectedSegmentIndex = 2
            changeStatusStatesTextFields(true)
        } else if mappingNode is SwitchingNode {
//            toggleSubType.setTitle("discrete", forSegmentAt: 0)
//            toggleSubType.setTitle("continuous", forSegmentAt: 1)
//            toggleWithStates.selectedSegmentIndex = 1
            toggleSubType.selectedSegmentIndex = 1
            changeStatusStatesTextFields(true)
        }
        
        
    }
    
    @IBAction func colorWhite(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .white
        updateTextFieldBackgroundColor()
    }
    @IBAction func colorBlue(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .blue
        updateTextFieldBackgroundColor()
    }
    @IBAction func colorYellow(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .yellow
        updateTextFieldBackgroundColor()
    }
    @IBAction func colorRed(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .red
        updateTextFieldBackgroundColor()
    }
    @IBAction func colorPurple(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .purple
        updateTextFieldBackgroundColor()
    }
    @IBAction func colorGreen(_ sender: UIButton) {
        provideVisualFeedbackButton(sender)
        App.state.DRAWING_COLOR = .green
        updateTextFieldBackgroundColor()
    }
    
    func updateTextFieldBackgroundColor() {
        if isUpdatingOutState1 {
            outValue1.backgroundColor = App.state.DRAWING_COLOR
            addOutState1(UIButton())
        } else if isUpdatingOutState2 {
            outValue2.backgroundColor = App.state.DRAWING_COLOR
            addOutState2(UIButton())
        }
        isUpdatingOutState1 = false
        isUpdatingOutState2 = false
    }
    
    func isColorBtnHidden(_ bool: Bool) {
        btnWhite.isHidden = bool
        btnBlue.isHidden = bool
        btnYellow.isHidden = bool
        btnRed.isHidden = bool
        btnPurple.isHidden = bool
        btnGreen.isHidden = bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.state.mappingViewController = self
        
        referenceTextField.text = "World"
        inValue1.adjustsFontSizeToFitWidth = true
        inValue2.adjustsFontSizeToFitWidth = true
        outValue1.adjustsFontSizeToFitWidth = true
        outValue2.adjustsFontSizeToFitWidth = true
        
        inValue1.minimumFontSize = 10
        inValue2.minimumFontSize = 10
        outValue1.minimumFontSize = 10
        outValue2.minimumFontSize = 10
        
    }
    
    func provideVisualFeedback(_ sender: UITextField)
    {
        sender.alpha = 0.2
        UIView .animate(withDuration: 0.5, animations: {
            sender.alpha = 1
        }, completion: { completed in
            if completed {
                sender.backgroundColor = UIColor.white
            }
        })
    }
    
    func provideVisualFeedbackButton(_ sender: UIButton)
    {
        sender.alpha = 0.2
        UIView .animate(withDuration: 0.5, animations: {
            sender.alpha = 1
        })
    }
    
    func stringifyStatesType(stateTag: Int) -> String {
        switch stateTag {
        case App.state.STATES_POSITION_MAG:
            return "'s pos"
        case App.state.STATES_POSITION_X:
            return "'s pos x"
        case App.state.STATES_POSITION_Y:
            return "'s pos y"
        case App.state.STATES_ORI:
            return "'s ori"
        case App.state.STATES_VELOCITY_MAG:
            return "'s vel"
        case App.state.STATES_VELOCITY_X:
            return "'s vel x"
        case App.state.STATES_VELOCITY_Y:
            return "'s vel y"
        case App.state.STATES_ANGULAR_VEL:
            return "'s ang vel"
        case App.state.STATES_ANGLE:
            return "'s ang"
        case App.state.STATES_ANGLE_VEL:
            return "'s angvel"
        case App.state.STATES_DEPTH:
            return "'s depth"
        case App.state.STATES_TRANSFORMATION:
            return "'s trsfm"
        case App.state.STATES_SCALE:
            return "'s scale"
        case App.state.STATES_VISIBILITY:
            return "'s vis"
        case App.state.STATES_POSITION_OUTPUT:
            return "'s pos"
        case App.state.STATES_MAPPING_ONOFF_OUTPUT:
            return "'s on/off"
        case App.state.STATES_CHANGE_GRAPHICS:
            return " / gra"
        case App.state.STATES_COLOR_CHANGE:
            return " / color"
        case App.state.STATES_MAPPING_ONOFF_INPUT:
            return " / on/off"
        case App.state.STATES_PHYSIC_RELATION:
            return " / physics"
        default:
            return ""
        }
    }
}
