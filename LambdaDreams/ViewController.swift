//
//  ViewController.swift
//  LambdaDreams
//
//  Created by Visveswaran Rajamani on 4/26/16.
//  Copyright © 2016 Acidalia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Variables
    var noDays = 0 //Total Days
    var noWeekends = 0 //Weekends = Sat + Sun
    var noVacation = 15 //Vacation Days
    var noPersonal = 3 //Personal Days
    var noStat = 0 //Statutory Holidays
    var noWork = 0 //Working days
    var end = "2016-09-13"
    var secondDate = NSDate () //End Date
    let file = "properties.txt"
    let theta = 35000/(365*2 + 1) //$ decay per day
    
    //Outlets
    @IBOutlet var lblNoDays: UILabel!
    @IBOutlet var lblNoWeekends: UILabel!
    @IBOutlet var lblNoVacation: UILabel!
    @IBOutlet var lblNoStat: UILabel!
    @IBOutlet var lblNoWork: UILabel!
    @IBOutlet var lblAmount: UILabel!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check stored Data
        readAndUpdateData()
        
        //Update Labels
        updateNoDays()
        updateNoWeekends()
        updateNoVacation()
        updateNoStat()
        updateNoWork()
        updateAmount()
        
    }
    
    @IBAction func ExitNow(sender: AnyObject) {
        exit(0)
    }

    //Stored Data
    func readAndUpdateData(){
        
        if let dir:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file)
            
            let manager = NSFileManager.defaultManager()
            if(manager.fileExistsAtPath(path)){
                //File Exists
                do {
                    let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                    let text2Arr = text2.componentsSeparatedByString(";")
                    noVacation = Int(text2Arr[0])!
                    end = text2Arr[1]
                    print(String(noVacation) + "|" + end)
                }
                catch {}
            }
        }
    }
    
    //Update and store data
    func storeData() {
        let text = String(noVacation) + ";" + end
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //writing
            do {
                try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
        }
        
    }
    
    //Segue Function
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails" {
            let destinationController = segue.destinationViewController as! DetailViewController
            destinationController.vacationDays = String(noVacation)
            destinationController.endDate = end
        }
    }
    
    @IBAction func unwindFromSecondVC(segue: UIStoryboardSegue){
        let secondVC: DetailViewController = segue.sourceViewController as! DetailViewController
        
        if let _ = secondVC.txtVacation.text{
            let temp = Int(secondVC.txtVacation.text!)
            if temp >= 0 {
                noVacation = temp!
            }
        }
        
        if let _ = secondVC.txtDate.text {
            let temp = secondVC.txtDate.text!
            if temp != "" {
                end = temp
            }
        }
        
        storeData()
        viewDidLoad()
    }
    
    //-----------------------------------------------NEW FUNCTIONS
    
    func updateNoDays(){
        noDays = findDays("today", dt2: end)
        lblNoDays.text = String(noDays)
    }
    
    func updateNoWeekends() {
        let d2s = daysToSun(NSDate())
        let num = noDays - d2s
        
        if num == 0 {
            noWeekends = 1
        }
        else if num < 0 {
            noWeekends = 0
        }
        else {
            noWeekends = (Int((num)/7) + 1) * 2
            if findDayOfWeek(secondDate) == "Sunday" {
                noWeekends -= 1
            }
        }
        lblNoWeekends.text = String(noWeekends)
        //print("\(noDays), \(d2s), \(num), \(num/7), \(noWeekends)") //DEBUG
    }
    
    func updateNoVacation() {
        lblNoVacation.text = String(noVacation)
    }
    
    func updateNoStat() {
        let listofStatHolidays = ["2016-01-01", "2016-05-27", "2016-05-30", "2016-07-04", "2016-09-02", "2016-09-05"]
        let statList = returnDateArray(listofStatHolidays)
        noStat = 0
        secondDate = returnDateFromString(end)
        
        for item in statList {
            if (item.compare(NSDate()) == .OrderedDescending) || (item.compare(NSDate()) == .OrderedSame) {
                
                if(item.compare(secondDate) == .OrderedAscending){
                    //print("Later \(item)") //DEBUG
                    noStat += 1
                }
            }
        }
        lblNoStat.text = String(noStat)
    }
    
    func updateAmount(){
        //UPDATE Amount owed
        
        let amtOut = 35000 - (findDays("2015-09-14", dt2: "today") * theta)
        
        //Format as $
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        lblAmount.text = formatter.stringFromNumber(amtOut)
    }
    
    func updateNoWork(){
        noWork = noDays - noWeekends - noVacation - noStat
        lblNoWork.text = String(noWork)
    }
    
    //----------------------------------------------- END NEW FUNCTIONS
    
    //HELPERS
    
    func findDays(dt1: String, dt2: String) -> Int{
        //Takes 2 dates as String and returns the number of days between them as INT
        
        var FirDate = NSDate()
        var SecDate = NSDate()
        
        if (dt1 != "today"){
            FirDate = returnDateFromString(dt1)
        }
        if (dt2 != "today"){
            SecDate = returnDateFromString(dt2)
        }

        // Replace the hour (time) of both dates with 00:00
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let date1 = calendar.startOfDayForDate(FirDate)
        let date2 = calendar.startOfDayForDate(SecDate)
        
        let components = calendar.components(NSCalendarUnit.Day, fromDate: date1, toDate: date2, options: [])
        return components.day
    }
    
    func findDayOfWeek(tempDate: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.stringFromDate(tempDate)
    }
    
    func returnDateFromString(args: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(args)!
    }
    
    func daysToSun(firstDate: NSDate) -> Int {
        let currDay = findDayOfWeek(firstDate)
        var result = -1
        
        switch currDay {
        case "Monday":      result = 6
        case "Tuesday":     result = 5
        case "Wednesday":   result = 4
        case "Thursday":    result = 3
        case "Friday":      result = 2
        case "Saturday":    result = 1
        case "Sunday":      result = 0
        default:            print("Default: \(currDay)")
        }
        return result
    }
    
    func returnDateArray(args: [String]) -> [NSDate]{
        var result = [NSDate]()
        
        for item in args {
            result.append(returnDateFromString(item))
        }
        return result
    }



}

