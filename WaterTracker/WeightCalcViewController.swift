//
//  WeightCalcViewController.swift
//  WaterTracker
//
//  Created by Ryan Phillips on 7/19/17.
//  Copyright © 2017 Ryan Phillips. All rights reserved.
//

import UIKit
import CoreData

protocol DataSentDelegate {
    func updateWeight(weight: Int, units: Int)
    func calculateAmounts()
}

class WeightCalcViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate {
    
    var weights = ["Pounds (lbs)","Kilograms (kgs)"]
    var weightUnit: Int?
//    var newDescribeText: String
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "WaterTracker"
            titleLabel.font = UIFont(name: "Avenir next", size: 40)
            titleLabel.textColor = ColorScheme.darkPrimaryColor
        }
    }
    
    @IBOutlet weak var weightText: UITextField! {
        didSet {
            weightText.layer.borderWidth = 5
            weightText.layer.borderColor = ColorScheme.lightPrimaryColor.cgColor
            weightText.layer.cornerRadius = 30
            weightText.font = UIFont(name: "Avenir next", size: 20)
            weightText.textAlignment = .center
            weightText.text = nil
            weightText.keyboardType = .numberPad
            weightText.widthAnchor.constraint(equalToConstant: 200).isActive = true
            weightText.heightAnchor.constraint(equalToConstant: 60).isActive = true
            weightText.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    @IBOutlet weak var describeText: UITextView! {
        didSet {
            
            describeText.font = UIFont(name: "Avenir next", size: 12)
            describeText.textColor = .black
            describeText.textAlignment = .center
            describeText.translatesAutoresizingMaskIntoConstraints = false
            describeText.text = ""
            
        }
    }
    
    @IBOutlet weak var weightPicker: UIPickerView! {
        didSet {
            
            
        }
    }
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 30
            saveButton.layer.borderColor = ColorScheme.lightPrimaryColor.cgColor
            saveButton.layer.borderWidth = 5
            saveButton.backgroundColor = .white
            saveButton.setTitle("Save", for: .normal)
            saveButton.setTitleColor(ColorScheme.darkPrimaryColor, for: .normal)
            saveButton.titleLabel?.font = UIFont(name: "Avenir next", size: 15)
            saveButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
            saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
        }
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        setWeight()
        
    }
    
//    func describeText0() {
//
//        describeText.font = UIFont(name: "Avenir next", size: 12)
//        describeText.textColor = .black
//        describeText.text = "Goal based on 2/3 of body weight converted into ounces"
//        describeText.textAlignment = .center
//        describeText.translatesAutoresizingMaskIntoConstraints = false
//
//    }
//
//    func describeText1() {
//
//        describeText.font = UIFont(name: "Avenir next", size: 12)
//        describeText.textColor = .black
//        describeText.text = "Goal based on 2/3 of body weight converted into ounces"
//        describeText.textAlignment = .center
//        describeText.translatesAutoresizingMaskIntoConstraints = false
//
//    }
    
    
    //    let describeText2: UITextView = {
    //        let describe2 = UITextView()
    //        describe2.font = UIFont(name: "Avenir next", size: 12)
    //        describe2.textColor = .black
    //        describe2.text = "Goal based on body weight divided by 30 converted into milliliters"
    //        describe2.textAlignment = .center
    //        describe2.translatesAutoresizingMaskIntoConstraints = false
    //        return describe2
    //    }()
    
//    let saveButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.layer.cornerRadius = 30
//        button.layer.borderColor = ColorScheme.lightPrimaryColor.cgColor
//        button.layer.borderWidth = 5
//        button.backgroundColor = .white
//        button.setTitle("Save", for: .normal)
//        button.setTitleColor(ColorScheme.darkPrimaryColor, for: .normal)
//        button.titleLabel?.font = UIFont(name: "Avenir next", size: 15)
//        button.translatesAutoresizingMaskIntoConstraints = false
//
////        button.addTarget(self, action: #selector(setWeight), for: .touchUpInside)
//
//        return button
//    }()
    
    var delegate: DataSentDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightPicker.dataSource = self
        weightPicker.delegate = self
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WeightCalcViewController.dismissKeyboard))
        
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setWeight() {
        
        if delegate != nil {
            
            if weightText.text != "" {
                
                var units: Int
                let weight = weightText.text!
                
                if weightUnit == nil || weightUnit == 0 {
                    
                    units = 0
                    
                } else {
                    
                    units = 1
                    
                }
                
                delegate?.updateWeight(weight: Int(weight)!, units: units)
                delegate?.calculateAmounts()
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func updateText(text: String) {
        
        if weightUnit == nil || weightUnit == 0 {
            
            describeText.text = "Goal based on 2/3 of body weight converted into ounces"
            
        } else {
            
            describeText.text = "Goal based on body weight divided by 30 converted into milliliters"
            
        }
        
    }
   
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weights.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return weights[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weightUnit = pickerView.selectedRow(inComponent: 0)
    }
}
