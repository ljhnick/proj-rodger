//
//  SavingViewController.swift
//  Project-Rodger
//
//  Created by Jiahao Li on 2/24/22.
//

import UIKit

class SavingViewController: UIViewController {
    
    var buttonList = [UIButton]()
    var mappingList = [MappingNode]()
    
    var sortedMappingList = [MappingNode]()
    var sortedButtonList = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        App.state.savingViewController = self
        
    }
    
    func updateButtons() {
        sortMapping()
        
        let buttonHeight = CGFloat(30)
        let retract = CGFloat(30)
        for (i, btn) in sortedButtonList.enumerated() {
            let width = view.frame.width - retract*sortedMappingList[i].hierarchy
            btn.frame = CGRect(x: retract*sortedMappingList[i].hierarchy, y: 0, width: width, height: buttonHeight)
            btn.center.y = CGFloat(i)*buttonHeight + buttonHeight/2
            btn.layer.cornerRadius = 5
            btn.setTitleColor(.white, for: .normal)
        }
    }
    
    func sortMapping() {
        sortedMappingList.removeAll()
        sortedButtonList.removeAll()
        for (i, mapping) in mappingList.enumerated() {
            if !(mapping.inputNode is MappingNode) && !(mapping.outputNode is MappingNode) {
                sortedMappingList.append(mappingList[i])
                sortedButtonList.append(buttonList[i])
            } else if mapping.inputNode is MappingNode {
                let index = sortedMappingList.firstIndex(of: mapping.inputNode as! MappingNode)
                sortedMappingList.insert(mappingList[i], at: index!+1)
                sortedButtonList.insert(buttonList[i], at: index!+1)
            } else if mapping.outputNode is MappingNode {
                let index = sortedMappingList.firstIndex(of: mapping.outputNode as! MappingNode)
                sortedMappingList.insert(mappingList[i], at: index!)
                sortedButtonList.insert(buttonList[i], at: index!)
            }
        }
    }
    
    func addAMapping(_ mapping: MappingNode) {
        if mapping is AffixingNode {
            let mappingBtn = UIButton(type: .system)
            mappingBtn.backgroundColor = .systemBlue
            // naming the mapping
            let name = mapping.name
            mappingBtn.setTitle(name, for: .normal)

            self.view.addSubview(mappingBtn)
            mappingBtn.addTarget(self, action: #selector(clickMapping), for: .touchUpInside)
            buttonList.append(mappingBtn)
            mappingList.append(mapping)
            updateButtons()
        } else if mapping is PhysicsSimulation {
            let mappingBtn = UIButton(type: .system)
            mappingBtn.backgroundColor = .systemGreen
            // naming the mapping
            let name = mapping.name
            mappingBtn.setTitle(name, for: .normal)

            self.view.addSubview(mappingBtn)
            mappingBtn.addTarget(self, action: #selector(clickMapping), for: .touchUpInside)
            buttonList.append(mappingBtn)
            mappingList.append(mapping)
            updateButtons()
        } else if mapping is InterpolationNode {
            let mappingBtn = UIButton(type: .system)
            mappingBtn.backgroundColor = .systemYellow
            // naming the mapping
            let name = mapping.name
            mappingBtn.setTitle(name, for: .normal)

            self.view.addSubview(mappingBtn)
            mappingBtn.addTarget(self, action: #selector(clickMapping), for: .touchUpInside)
            buttonList.append(mappingBtn)
            mappingList.append(mapping)
            updateButtons()
        } else if mapping is SwitchingNode {
            let mappingBtn = UIButton(type: .system)
            mappingBtn.backgroundColor = .systemCyan
            // naming the mapping
            let name = mapping.name
            mappingBtn.setTitle(name, for: .normal)
            
            self.view.addSubview(mappingBtn)
            mappingBtn.addTarget(self, action: #selector(clickMapping), for: .touchUpInside)
            buttonList.append(mappingBtn)
            mappingList.append(mapping)
            updateButtons()
        }
    }
    
    @objc func clickMapping(sender: UIButton!) {
        let index = buttonList.firstIndex(of: sender)
        let mappingNode = mappingList[index!]
        
        if !App.state.updatingStatus {
            if mappingNode is AffixingNode {
                App.state.mappingTemp = mappingNode
                mappingNode.nodeHighlighted()
                App.state.mappingViewController.updateMappingSection()
            } else if mappingNode is PhysicsSimulation {
                App.state.mappingTemp = mappingNode
                mappingNode.nodeHighlighted()
                App.state.mappingViewController.updateMappingSection()
            } else if mappingNode is InterpolationNode {
                App.state.mappingTemp = mappingNode
                mappingNode.nodeHighlighted()
                App.state.mappingViewController.updateMappingSection()
            } else if mappingNode is SwitchingNode {
                App.state.mappingTemp = mappingNode
                mappingNode.nodeHighlighted()
                App.state.mappingViewController.updateMappingSection()
            }
        } else {
            if App.state.updatingTarget == App.state.UPDATE_INPUT_TARGET {
                if mappingNode is SwitchingNode {
                    App.state.mappingTemp.inputNode = mappingNode
                    
                    App.state.mappingViewController.inTargetText.text = mappingNode.name
                    App.state.mappingViewController.inTargetText.endEditing(true)
                    App.state.STATES = App.state.STATES_MAPPING_ONOFF_INPUT
                    App.state.mappingTemp.setupStatesInputOutput()
                }
            } else if App.state.updatingTarget == App.state.UPDATE_OUTPUT_TARGET {
                App.state.mappingTemp.outputNode = mappingNode
                
                App.state.mappingViewController.outTargetText.text = mappingNode.name
                App.state.mappingViewController.outTargetText.endEditing(true)
                App.state.STATES = App.state.STATES_MAPPING_ONOFF_OUTPUT
                App.state.mappingTemp.setupStatesInputOutput()
            }
            
        }
        
    }

}
