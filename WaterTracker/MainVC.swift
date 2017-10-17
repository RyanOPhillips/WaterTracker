//
//  MainVC.swift
//  WaterTracker
//
//  Created by Ryan Phillips on 7/18/17.
//  Copyright © 2017 Ryan Phillips. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, DataSentDelegate {
    
    let defaults:UserDefaults = UserDefaults.standard
    var controller: NSFetchedResultsController<User>!
    var addedArray: [Int] = []
    var isPounds = true
    var maxAmount: Double = 0
    var amounts = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128]
    var date = Date()

    
    @IBOutlet weak var waterView: UIView! {
        didSet {
            waterView.backgroundColor = ColorScheme.defaultPrimaryColor
            waterView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var waterHeight: NSLayoutConstraint! {
        didSet {
            var height: Double = 0
            if addedArray.count > 0 {
                for amount in addedArray {
                    height += Double(amount)
                }
                height = 192 * Double(height) / maxAmount
                height = (height < 192 ? height : 192)
            }
            waterHeight.constant = CGFloat(height)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "WaterTracker"
            titleLabel.font = UIFont(name: "Avenir next", size: 30)
            titleLabel.textColor = ColorScheme.darkPrimaryColor
            titleLabel.textAlignment = .center
        }
    }

    @IBOutlet weak var goalLabel: UILabel! {
        didSet {
            goalLabel.text = "Goal"
            goalLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
            goalLabel.textColor = ColorScheme.darkPrimaryColor
        }
    }
    
    @IBOutlet weak var completedLevelLabel: UILabel! {
        didSet {
            completedLevelLabel.font = UIFont(name: "Avenir next", size: 18)
            completedLevelLabel.textColor = ColorScheme.darkPrimaryColor
        }
    }

    @IBOutlet weak var halfLevelLabel: UILabel! {
        didSet {
            halfLevelLabel.font = UIFont(name: "Avenir next", size: 18)
            halfLevelLabel.textColor = ColorScheme.darkPrimaryColor
        }
    }
    
    @IBOutlet weak var emptyLevelLabel: UILabel! {
        didSet {
            emptyLevelLabel.font = UIFont(name: "Avenir next", size: 18)
            emptyLevelLabel.textColor = ColorScheme.darkPrimaryColor
        }
    }
    
    @IBOutlet weak var currentLevelLabel: UILabel! {
        didSet {
            currentLevelLabel.text = "0"
            currentLevelLabel.font = UIFont(name: "AvenirNext-Bold", size: 25)
            currentLevelLabel.textColor = .lightGray
            currentLevelLabel.textAlignment = .center
        }
    }

    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    @IBOutlet weak var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = 40
            addButton.layer.borderColor = ColorScheme.lightPrimaryColor.cgColor
            addButton.layer.borderWidth = 5
            addButton.backgroundColor = .white
            addButton.setTitle("Add", for: .normal)
            addButton.setTitleColor(ColorScheme.darkPrimaryColor, for: .normal)
            addButton.titleLabel?.font = UIFont(name: "Avenir next", size: 18)
            addButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            addButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
            addButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.set(true, forKey: "HasAppBeenOpenedBefore")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate Goal",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(goToSetWeight))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(clearWaterLevel))
        
        pickerView.selectRow(15, inComponent: 0, animated: true)
        attemptFetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        attemptFetch()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let selectedPicker: Int = pickerView.selectedRow(inComponent: 0)
        addedArray.append(selectedPicker + 1)
        
        calculateAmounts()
        
    }
    
    func calculateAmounts() {

        var total: Double = 0
        for amount in addedArray {
            total += Double(amount)
        }
        currentLevelLabel.text = "\(Int(total))"

        waterView.layoutIfNeeded()

        UIView.animate(withDuration: 20) {
            total = 192 * Double(total) / self.maxAmount
            total = (total < 192 ? total : 192)
            self.waterHeight.constant = CGFloat(total)
            self.waterView.layoutIfNeeded()
        }
    }
    
    // This function is called from the Weight
    func updateWeight(weight: Int, units: Int) {
        var user: User!
        user = User(context: context)
        user.weight = Int16(weight)
        user.units = Int16(units)
        user.date = Date() as NSDate
        ad.saveContext()
        attemptFetch()
    }
    
    func clearWaterLevel(){
        waterHeight.constant = 0
        currentLevelLabel.text = "0"
        addedArray.removeAll()
    }
    
    // Right Navigation Bar action
    func goToSetWeight(){
        performSegue(withIdentifier: "toSetWeight", sender: nil)
    }
    
    // Prepare for seque to view controller where you can set your weight
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetWeight" {
            let weightCalcVC: WeightCalcViewController = segue.destination as! WeightCalcViewController
            weightCalcVC.delegate = self
        }
    }
    
    // Retreiving Core Data
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let weightSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [weightSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        do {
            try self.controller.performFetch()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
        guard let information = controller.fetchedObjects else { return }
        
        if information.count > 0 {
            let currentInformation = information[0]
            
            if currentInformation.units == 0 {
                isPounds = true
                maxAmount = Double(currentInformation.weight) * 2/3
                goalLabel.text = "\(Int(maxAmount)) oz"
            } else {
                isPounds = false
                maxAmount = Double(currentInformation.weight) / 30 * 1000
                
                goalLabel.text = "\(Int(maxAmount)) ml"
            }
            pickerView.reloadAllComponents()
            print("WEIGHT: \(currentInformation.weight)")
            print("UNITS: \(currentInformation.units)")
        }
    }
    
    // Three below functions describe the pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return amounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch isPounds {
        case true:
            return "\(amounts[row]) oz"
        default:
            return "\(amounts[row]) ml"
        }
    }
}

