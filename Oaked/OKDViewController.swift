//
//  OKDViewController.swift
//  Oaked
//
//  Created by braeden on 2015-10-27.
//  Copyright © 2015 Braeden Robak. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData
import Oaked

class OKDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, I3DragDataSource, UIPopoverPresentationControllerDelegate, CustomerProfileDelegate, CustomerAddDelegate {
    
    
    @IBOutlet weak var leftTable: UITableView!
    @IBOutlet weak var middleTable: UITableView!
    @IBOutlet weak var rightTable: UITableView!
    @IBOutlet weak var addClient: UIBarButtonItem!
    
    @IBOutlet weak var leftTableLabel: UILabel!
    @IBOutlet weak var middleTableLabel: UILabel!
    @IBOutlet weak var rightTableLabel: UILabel!
    
    
    // turn this into var customers = [NSManagedObject]()
    var customers = [NSManagedObject]()
    
    var appDelegate = AppDelegate()
    var managedContext = NSManagedObjectContext()
    
    
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
        
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = appDelegate.managedObjectContext
        
        //let data :OKDSimpleData = OKDSimpleData(title: "Test title")
        //let data :User = User(firstName: "John", lastName: "Appleseed", phoneNumber: "403-123-4567")
        
        //self.leftData.addObject(data)
        
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
        
        /** Uncomment to delete everything saved
        
        let fetchRequest = NSFetchRequest(entityName: "OKDUser")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        
        do {
            try managedContext.executeRequest(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        */
        
        
        //view.addGestureRecognizer(tap)
        //view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        //Sparkle Sparkle
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:titleTextColour, NSFontAttributeName: titleFont]
        
        self.navigationItem.rightBarButtonItem?.tintColor = buttonColour
        self.navigationItem.rightBarButtonItem?.tintColor = buttonColour
        
        
        /** Use for dark pro version
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent;
        self.view.backgroundColor = UIColor.darkGrayColor()
        self.leftTable.backgroundColor = UIColor.darkGrayColor()
        self.middleTable.backgroundColor = UIColor.darkGrayColor()
        self.rightTable.backgroundColor = UIColor.darkGrayColor()
        **/
        
        
        self.leftTableLabel.textColor = titleTextColour
        self.middleTableLabel.textColor = titleTextColour
        self.rightTableLabel.textColor = titleTextColour
        
    }
    
    // Loads up data from Core Data
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "OKDUser")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            customers = results as! [NSManagedObject]
            
            self.loadTablesWithUsers();
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Helper
    
    //Get the dataSet and number (probably should be a enum) for a given table view
    func getDataSetFor(tableView: UITableView) -> (dataSet:NSMutableArray,tableNumber: Int){
        var dataSet = NSMutableArray()
        var tableNumber = 0
        
        if(tableView == self.leftTable){
            dataSet = self.leftData
            tableNumber = 1
        }
        else if(tableView == self.middleTable)
        {
            dataSet = self.middleData
            tableNumber = 2
        }
        else
        {
            dataSet = self.rightData
            tableNumber = 3
        }
        
        
        return (dataSet,tableNumber)
    }
    
    
    //Takes the list of all users and sorts them into their respective table's data set
    func loadTablesWithUsers(){
        
        for odkCustomer in customers
        {
            let customer = convertOKDCustomerToCustomer(odkCustomer)
            
            if(customer.tableNumber == 1){
                self.leftData.addObject(customer);
            }
            else if(customer.tableNumber == 2)
            {
                self.middleData.addObject(customer);
            }
            else
            {
                self.rightData.addObject(customer);
            }
        }
        
    }
    
    //Convert the CoreData user to a table view User object
    func convertOKDCustomerToCustomer(okdCustomer: NSManagedObject) -> Customer
    {
        let customer :Customer = Customer(id: "1", firstName: okdCustomer.valueForKey("firstName") as! String, lastName: okdCustomer.valueForKey("lastName") as! String, phoneNumber: okdCustomer.valueForKey("phoneNumber") as! String)
        
        customer.tableNumber = (okdCustomer.valueForKey("tableNumber")?.integerValue)!
        
        return customer
    }
    
    //Find the CoreData OKDUser object given a table view used User object
    func findOKDUserFromUser(currentUser: Customer) -> Int
    {
        var user = 0
        
        for okdUser in customers
        {
            if(currentUser.phoneNumber == okdUser.valueForKey("phoneNumber") as! String){
                user = customers.indexOf(okdUser)!
            }
        }
        return user
    }
    
    //MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDataSetFor(tableView).dataSet.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",forIndexPath: indexPath)
        
        let tableData = getDataSetFor(tableView)
        
        let data = tableData.dataSet.objectAtIndex(indexPath.row)
        
        cell.textLabel?.text = data.valueForKey("firstName") as? String
        cell.textLabel?.text?.appendContentsOf(" ")
        cell.textLabel?.text?.appendContentsOf((data.valueForKey("lastName") as? String)!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //checking for double taps here
        if(tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row){
            let tableData = getDataSetFor(tableView)
            let cellData = tableData.dataSet[indexPath.row]
            //let cellData = tableData.objectAtIndex(indexPath.row)
            
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
    
    //Save a given table view User object into a CoreData OKDUser and save it in CoreData
    func saveCustomer(user: Customer){
        
        let entity =  NSEntityDescription.entityForName("OKDUser",
            inManagedObjectContext:managedContext)

        let index = findOKDUserFromUser(user)
        
        /**
        if (customers.count > 0){
            managedContext.deleteObject(customers[index])
            customers.removeAtIndex(index)
        }
        **/

        let customer = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        customer.setValue(user.firstName, forKey: "firstName")
        customer.setValue(user.lastName, forKey: "lastName")
        customer.setValue(user.phoneNumber, forKey: "phoneNumber")
        customer.setValue(user.title, forKey: "title")
        customer.setValue(user.tableNumber, forKey: "tableNumber")
        
        
        do {
            try managedContext.save()
            customers.append(customer)
            
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - I3DragDataSource
    func canItemBeDraggedAt(at: NSIndexPath!, inCollection collection: UIView!) -> Bool {
        //All items can be moved
        return true
    }
    
    func dropItemAt(from: NSIndexPath!, fromCollection: UIView!, toItemAt to: NSIndexPath!, onCollection toCollection: UIView!) {
        
        let fromTableView = fromCollection as! UITableView
        let toTableView = toCollection as! UITableView
        
        //Get dataSet for given collections
        let fromDataSet = getDataSetFor(fromTableView)
        let toDataSet = getDataSetFor(toTableView)
        
        //Data to be exchanged
        let exchangeData = fromDataSet.dataSet[from.row] as! Customer
        exchangeData.tableNumber = toDataSet.tableNumber
        
        //Find index of old data and delete it
        let index = findOKDUserFromUser(exchangeData)
        managedContext.deleteObject(customers[index])
        customers.removeAtIndex(index)
        
        //Save user using Core Data
        self.saveCustomer(exchangeData)
        
        //Update user sets
        fromDataSet.dataSet.removeObjectAtIndex(from.row)
        toDataSet.dataSet.insertObject(exchangeData, atIndex: to.row)
        
        //Update table views
        fromTableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: from.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        toTableView.insertRowsAtIndexPaths([NSIndexPath(forItem: to.row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        
        
    }
    
    func dropItemAt(from: NSIndexPath!, fromCollection: UIView!, toPoint to: CGPoint, onCollection toCollection: UIView!) {
        let toDataSet = getDataSetFor(toCollection as! UITableView)
        
        let toIndex = NSIndexPath(forItem: toDataSet.dataSet.count, inSection: 0)
        
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
        
        //Update the table reference
        //Always 1 as they get put into the left table when a user first comes in
        customerProfile.tableNumber = 1
        
        //Save user to core data
        self.saveCustomer(customerProfile)
        
        //Add to the table views data and reload the table
        self.leftData.addObject(customerProfile)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    // Add customer
    func customerToAdd(controller: AddCustomerPopUpViewControllerSwift, addCustomer: Customer){
        //Update the table reference
        //Always 1 as they get put into the left table when a user first comes in
        addCustomer.tableNumber = 1
        
        //Save user to core data
        self.saveCustomer(addCustomer)
        
        
        //Add to the table views data and reload the table
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
    
}
