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


class OKDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, I3DragDataSource, UIPopoverPresentationControllerDelegate, UserAddEditDelegate {
    
    
    @IBOutlet weak var leftTable: UITableView!
    @IBOutlet weak var middleTable: UITableView!
    @IBOutlet weak var rightTable: UITableView!
    @IBOutlet weak var addClient: UIBarButtonItem!

    
    var users = [NSManagedObject]()
    
    var dragCoodinator :I3GestureCoordinator = I3GestureCoordinator()
    
    let tap = UITapGestureRecognizer()
    
    var popViewController : PopUpViewControllerSwift!
    
    var leftData = NSMutableArray()
    var middleData = NSMutableArray()
    var rightData = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    
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
            users = results as! [NSManagedObject]
            
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
    
    func loadTablesWithUsers(){
        
        for okdUser in users
        {
            var user = convertOKDUserToUser(okdUser)
            
            if(user.tableNumber == 1){
                self.leftData.addObject(user);
            }
            else if(user.tableNumber == 2)
            {
                self.middleData.addObject(user);
            }
            else
            {
                self.rightData.addObject(user);
            }
        }
        
    }
    
    func convertOKDUserToUser(okdUser: NSManagedObject) -> User
    {
        var user :User = User(firstName: okdUser.valueForKey("firstName") as! String, lastName: okdUser.valueForKey("lastName") as! String, phoneNumber: okdUser.valueForKey("phoneNumber") as! String)
        
        user.tableNumber = (okdUser.valueForKey("tableNumber")?.integerValue)!
        
        return user
    }
    
    func findOKDUserFromUser(currentUser: User) -> Int
    {
        var user = 0
        
        for okdUser in users
        {
            if(currentUser.phoneNumber == okdUser.valueForKey("phoneNumber") as! String){
                user = users.indexOf(okdUser)!
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
    
    func saveUser(user: User)
    {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("OKDUser",
            inManagedObjectContext:managedContext)
        
        let index = findOKDUserFromUser(user)
        
        managedContext.deleteObject(users[index])
        users.removeAtIndex(index)
        
        let customer = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        customer.setValue(user.firstName, forKey: "firstName")
        customer.setValue(user.lastName, forKey: "lastName")
        customer.setValue(user.phoneNumber, forKey: "phoneNumber")
        customer.setValue(user.title, forKey: "title")
        customer.setValue(user.tableNumber, forKey: "tableNumber")
        
        
        do {
            try managedContext.save()
            findOKDUserFromUser(user)
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
        let exchangeData = fromDataSet.dataSet[from.row] as! User
        exchangeData.tableNumber = toDataSet.tableNumber
        
        //Update data sets
        self.saveUser(exchangeData)
        
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
    func userToAddEdit(controller: PopUpViewControllerSwift, addEditUser: User){
        self.saveUser(addEditUser)
        addEditUser.tableNumber = 1
        self.leftData.addObject(addEditUser)
        self.leftTable.reloadData()
    }
    
    
    //MARK: - Interface Actions
    @IBAction func newClient(sender: UIBarButtonItem) {
        self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
        self.popViewController.delegate = self
        self.popViewController.title = "Add New Client"
        self.popViewController.showInView(self.view, withMessage: "Add client here", animated: true)
    }
    
     func editMessageClient(){
        self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
        self.popViewController.delegate = self
        self.popViewController.title = "Edit and Message Client"
        self.popViewController.showInView(self.view, withMessage: "Profile", animated: true)
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
