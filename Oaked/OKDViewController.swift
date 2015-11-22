//
//  OKDViewController.swift
//  Oaked
//
//  Created by braeden on 2015-10-27.
//  Copyright © 2015 Braeden Robak. All rights reserved.
//

import UIKit
import QuartzCore

class OKDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, I3DragDataSource, UIPopoverPresentationControllerDelegate, CustomerProfileDelegate, CustomerAddDelegate {
    
    
    @IBOutlet weak var leftTable: UITableView!
    @IBOutlet weak var middleTable: UITableView!
    @IBOutlet weak var rightTable: UITableView!
    @IBOutlet weak var addClient: UIBarButtonItem!
    
    var customers = [Customer]()
    
    var dragCoodinator :I3GestureCoordinator = I3GestureCoordinator()
    
    let tap = UITapGestureRecognizer()
    var tapCount:Int = 0
    var tapTimer:NSTimer?
    var tappedRow:Int?
    
    var popViewController : PopUpViewControllerSwift!
    var addCustomerPopupViewController : AddCustomerPopUpViewControllerSwift!
    
    var leftData = NSMutableArray()
    var middleData = NSMutableArray()
    var rightData = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let data :OKDSimpleData = OKDSimpleData(title: "Test title")
        let data :Customer = Customer(id: "1", firstName: "John", lastName: "Appleseed", phoneNumber: "403-123-4567")
        
        self.leftData.addObject(data)
        
        self.leftTable.dataSource = self
        self.leftTable.delegate = self
        self.leftTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.middleTable.dataSource = self
        self.middleTable.delegate = self
        self.middleTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.rightTable.dataSource = self
        self.rightTable.delegate = self
        self.rightTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.dragCoodinator = I3GestureCoordinator.basicGestureCoordinatorFromViewController(self, withCollections: [self.leftTable,self.middleTable,self.rightTable])
        
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: "editMessageClient")
        //view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Helper
    func getDataSetFor(tableView: UITableView) -> NSMutableArray{
        var dataSet = NSMutableArray()
        
        if(tableView == self.leftTable){
            dataSet = self.leftData
        }
        else if(tableView == self.middleTable)
        {
            dataSet = self.middleData
        }
        else
        {
            dataSet = self.rightData
        }
        
        return dataSet
    }
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDataSetFor(tableView).count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",forIndexPath: indexPath)
        
        let tableData = getDataSetFor(tableView)
        
        let data = tableData.objectAtIndex(indexPath.row)
        
        cell.textLabel?.text = data.title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //checking for double taps here
        if(tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row){
            let tableData = getDataSetFor(tableView)
            let cellData = tableData.objectAtIndex(indexPath.row)
            
            if let cellCustomer = cellData as? Customer {
                self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
                self.popViewController.delegate = self
                self.popViewController.customer = cellCustomer
                self.popViewController.showInView(self.view, animated: true)
            }
            
            tapTimer?.invalidate()
            tapTimer = nil
            tapCount = 0
        }
        else if(tapCount == 0){
            //This is the first tap. If there is no tap till tapTimer is fired, it is a single tap
            tapCount = tapCount + 1;
            tappedRow = indexPath.row;
            tapTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "tapTimerFired:", userInfo: nil, repeats: false)
        }
        else if(tappedRow != indexPath.row){
            //tap on new row
            tapCount = 0;
            if(tapTimer != nil){
                tapTimer?.invalidate()
                tapTimer = nil
            }
        }
    }
    
    func tapTimerFired(aTimer:NSTimer){
        //timer fired, there was a single tap on indexPath.row = tappedRow
        if(tapTimer != nil){
        tapCount = 0;
        tappedRow = -1;
        }
    }
    
    //MARK: - I3DragDataSource
    func canItemBeDraggedAt(at: NSIndexPath!, inCollection collection: UIView!) -> Bool {
        //All items can be moved
        return true
    }
    
    func dropItemAt(from: NSIndexPath!, fromCollection: UIView!, toItemAt to: NSIndexPath!, onCollection toCollection: UIView!) {
        //TODO
        let fromTableView = fromCollection as! UITableView
        let toTableView = toCollection as! UITableView
        
        //Get dataSet for given collections
        let fromDataSet = getDataSetFor(fromTableView)
        let toDataSet = getDataSetFor(toTableView)
        
        //Data to be exchanged
        let exchangeData = fromDataSet[from.row]
        
        //Update data sets
        fromDataSet.removeObjectAtIndex(from.row)
        toDataSet.insertObject(exchangeData, atIndex: to.row)
        
        //Update table views
        fromTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: from.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        toTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: to.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        
        
    }
    
    func dropItemAt(from: NSIndexPath!, fromCollection: UIView!, toPoint to: CGPoint, onCollection toCollection: UIView!) {
        //TODO
        let toDataSet = getDataSetFor(toCollection as! UITableView)
        
        let toIndex = NSIndexPath(forItem: toDataSet.count, inSection: 0)
        
        self.dropItemAt(from, fromCollection: fromCollection, toItemAt: toIndex, onCollection: toCollection)
        
    }
    
    func rearrangeItemAt(from: NSIndexPath!, withItemAt to: NSIndexPath!, inCollection collection: UIView!) {
        //TODO
    }
    
    func canItemAt(from: NSIndexPath!, fromCollection: UIView!, beDroppedAtPoint at: CGPoint, onCollection toCollection: UIView!) -> Bool {
        //Can always be moved
        return true
    }
    
    func canItemAt(from: NSIndexPath!, fromCollection: UIView!, beDroppedTo to: NSIndexPath!, onCollection toCollection: UIView!) -> Bool {
        //Can always be moved
        return true
    }
    
    //MARK: - Delegate methods
    
    // Customer Profile
    func customerProfileToDisplay(controller: PopUpViewControllerSwift, customerProfile: Customer) {
        customers.append(customerProfile)
        //let data :User = User(firstName: "John", lastName: "Appleseed", phoneNumber: "403-123-4567")
        self.leftData.addObject(customerProfile)
        self.leftTable.reloadData()
    }
    
    // Add customer
    func customerToAdd(controller: AddCustomerPopUpViewControllerSwift, addCustomer: Customer){
        customers.append(addCustomer)
        //let data :User = User(firstName: "John", lastName: "Appleseed", phoneNumber: "403-123-4567")
        self.leftData.addObject(addCustomer)
        self.leftTable.reloadData()
    }
    
    //MARK: - Interface Actions
    @IBAction func newClient(sender: UIBarButtonItem) {
        self.addCustomerPopupViewController = AddCustomerPopUpViewControllerSwift(nibName: "AddCustomerPopupViewController", bundle: nil)
        self.addCustomerPopupViewController.delegate = self
        self.addCustomerPopupViewController.title = "Add New Customer"
        self.addCustomerPopupViewController.showInView(self.view, withMessage: "Add Customer", animated: true)
    }
    
     func editMessageClient(){
        self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
        self.popViewController.delegate = self
        self.popViewController.title = "Edit and Message Client"
        self.popViewController.showInView(self.view, animated: true)
    }
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

    
    
}
