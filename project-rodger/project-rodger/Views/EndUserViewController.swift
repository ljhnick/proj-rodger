//
//  EndUserViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 3/21/22.
//

import UIKit
import SpriteKit

class EndUserViewController: UIViewController {

    @IBOutlet weak var inputTargetTextField: UITextField!
    @IBOutlet weak var outputTargetTextField: UITextField!
    
    lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
//        label.font = label.font.withSize(12)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    lazy var button1: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 110, width: 80, height: 30)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    lazy var button2: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 90, y: 110, width: 80, height: 30)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    lazy var button3: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 220, y: 110, width: 80, height: 30)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.setTitle("Back2draw", for: .normal)
        
        button.addAction(UIAction(handler: {action in
            App.state.currentState = App.state.STATE_DRAWING
            self.STEP = self.STEP_ACTION_DRAW
            self.updateInteractiveSection()
        }), for: .touchUpInside)
        
        return button
    }()
    
    var inputNode = SKNode()
    var outputNode = SKNode()
    
    var STEP = 0
    var STEP_ACTION_RIG = 4
    var STEP_ACTION_DRAW = 5
    var STEP_ACTION_GROUP = 6
    var STEP_ACTION_SELECT_INPUT = 1
    var STEP_ASK_OUTPUT_IS_MAPPING = 2
    var STEP_ACTION_SELECT_OUTPUT = 3
    var STEP_ACTION_SELECT_OUTPUT_MAPPING = 7
    var STEP_ASK_CONNECTION = 8
    var STEP_ASK_SIMULATION = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        App.state.endUserViewController = self
        
        self.view.addSubview(questionLabel)
        updateInteractiveSection()
    }
    
    func promptRetry() {
        questionLabel.text = "Please retry"
    }
    
    func promptSuccess() {
        questionLabel.text = "Success"
    }
    
    func resetBeforeEachStep() {
        button1.removeTarget(nil, action: nil, for: .allEvents)
        button2.removeTarget(nil, action: nil, for: .allEvents)
        button1.removeFromSuperview()
        button2.removeFromSuperview()
    }
    
    func updateInteractiveSection() {
        resetBeforeEachStep()
        
        switch STEP {
        case 0:
            button1.setTitle("Start", for: .normal)
            button1.addAction(UIAction(handler: {action in
                App.state.currentState = App.state.STATE_RIGGING
                self.STEP = self.STEP_ACTION_RIG
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
        case STEP_ACTION_RIG:
            questionLabel.text = "Please RIG the object by circling around the markers"
            questionLabel.textColor = .systemRed
            
            button1.setTitle("Finish", for: .normal)
            button1.addAction(UIAction(handler: {action in
                App.state.currentState = App.state.STATE_DRAWING
                
                self.STEP = self.STEP_ACTION_DRAW
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
        case STEP_ACTION_DRAW:
            button3.removeFromSuperview()
            
            questionLabel.text = "Please DRAW graphics \n(or GROUP graphics)"
            questionLabel.textColor = .systemRed
            
            button1.setTitle("Finish", for: .normal)
            button2.setTitle("Group", for: .normal)
            
            button1.addAction(UIAction(handler: {action in
                App.state.currentState = App.state.STATE_ENDUSER
                self.STEP = self.STEP_ACTION_SELECT_INPUT
                self.updateInteractiveSection()
                self.view.addSubview(self.button3)
            }), for: .touchUpInside)
            
            button2.addAction(UIAction(handler: {action in
                App.state.currentState = App.state.STATE_GROUP
                self.STEP = self.STEP_ACTION_GROUP
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
            view.addSubview(button2)
        case STEP_ACTION_GROUP:
            questionLabel.text = "Please GROUP graphics by circling around graphics"
            questionLabel.textColor = .systemRed
            
            button1.setTitle("Finish", for: .normal)
            button1.addAction(UIAction(handler: {action in
                App.state.currentState = App.state.STATE_DRAWING
                self.STEP = self.STEP_ACTION_DRAW
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
            
            
        case STEP_ACTION_SELECT_INPUT:
            questionLabel.text = "Please select the INPUT TARGET (what is controlling the output?)"
            questionLabel.textColor = .systemRed
                
            
            button1.setTitle("Finish", for: .normal)
            button1.addAction(UIAction(handler: {action in
                self.STEP = self.STEP_ASK_OUTPUT_IS_MAPPING
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
        case STEP_ASK_OUTPUT_IS_MAPPING:
            questionLabel.text = "Do you want it to control another mapping (create a rule or logic)?"
            questionLabel.textColor = .systemBlue
            
            button1.setTitle("Yes", for: .normal)
            button2.setTitle("No", for: .normal)
            button1.addAction(UIAction(handler: {action in
                self.STEP = self.STEP_ACTION_SELECT_OUTPUT_MAPPING
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            button2.addAction(UIAction(handler: {action in
                self.STEP = self.STEP_ACTION_SELECT_OUTPUT
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
            view.addSubview(button2)
        case STEP_ACTION_SELECT_OUTPUT:
            questionLabel.text = "Please select the OUTPUT TARGET (what is changing its graphical property?)"
            questionLabel.textColor = .systemRed
            
            button1.setTitle("Finish", for: .normal)
            button1.addAction(UIAction(handler: {action in
                self.STEP = self.STEP_ASK_CONNECTION
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
        case STEP_ACTION_SELECT_OUTPUT_MAPPING:
            ()
        case STEP_ASK_CONNECTION:
            questionLabel.text = "Do you want to physcially connect the two targets?"
            questionLabel.textColor = .systemBlue
            
            button1.setTitle("Yes", for: .normal)
            button2.setTitle("No", for: .normal)
            button1.addAction(UIAction(handler: {action in
                self.STEP = self.STEP_ASK_SIMULATION
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            button2.addAction(UIAction(handler: {action in
                // STEP STATES
//                self.STEP = self.STEP_ACTION_SELECT_OUTPUT
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
            view.addSubview(button2)

        case STEP_ASK_SIMULATION:
            questionLabel.text = "Do you want to connect the two targets with an elastic string?"
            questionLabel.textColor = .systemBlue
            
            button1.setTitle("Yes", for: .normal)
            button2.setTitle("No", for: .normal)
            button1.addAction(UIAction(handler: {action in
                // Physical relationship node
                
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            button2.addAction(UIAction(handler: {action in
                // Affixing node
                let mapping = AffixingNode()
                App.state.mappingTemp = mapping
                if let input = self.inputNode as? LinkNode {
                    if let output = self.outputNode as? GraphicsNode {
                        mapping.setup(input: input, output: output)
                    }
                } else if let input = self.inputNode as? GraphicsNode {
                    if let output = self.outputNode as? LinkNode {
                        mapping.setup(input: output, output: input)
                    }
                }
                App.state.mappingNodes.append(mapping)
                self.STEP = self.STEP_ACTION_SELECT_INPUT
                self.updateInteractiveSection()
            }), for: .touchUpInside)
            
            view.addSubview(button1)
            view.addSubview(button2)
        default:
            ()
        }
    }
    
    
    

}
