//
//  DetailViewController.swift
//  LambdaDreams
//
//  Created by Visveswaran Rajamani on 5/23/16.
//  Copyright © 2016 Acidalia. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtVacation: UITextField!

    
    var vacationDays:String!
    var endDate:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if vacationDays != nil {
            txtVacation.text = vacationDays
        }
        
        if endDate != nil {
            txtDate.text = endDate
        }
    }
    
    @IBAction func cancelOut(sender: AnyObject) {
        
    }
    @IBAction func textFieldEditing(sender: UITextField) {
        
        //Create the view
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        
        let datePickerView  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, 0, 0))
        datePickerView.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        
        handleDatePicker(datePickerView) // Set the date on start.
        
    }
    
    
    func handleDatePicker(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func doneButton(sender:UIButton){
        txtDate.resignFirstResponder()
    }
}
