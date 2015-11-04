//
//  OKDViewController.swift
//  Oaked
//
//  Created by braeden on 2015-10-27.
//  Copyright © 2015 Braeden Robak. All rights reserved.
//

import UIKit
import QuartzCore

class OKDViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, I3DragDataSource, UIPopoverPresentationControllerDelegate, UserAddEditDelegate {
    
    
    @IBOutlet weak var leftTable: UITableView!
    @IBOutlet weak var middleTable: UITableView!
    @IBOutlet weak var rightTable: UITableView!
    @IBOutlet weak var addClient: UIBarButtonItem!

    
    var users = [User]()
    
    var dragCoodinator :I3GestureCoordinator = I3GestureCoordinator()
    
    var popViewController : PopUpViewControllerSwift!
    
    var leftData = NSMutableArray()
    var middleData = NSMutableArray()
    var rightData = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data :OKDSimpleData = OKDSimpleData(title: "Test title")
        
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
        
        
        let editSelector : Selector = "edit:"
        let cellTapGesture = UITapGestureRecognizer(target: self.leftTable, action: editSelector)
        cellTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(cellTapGesture)
        
        
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
    
    func userToAddEdit(user: User){
        
    }
    
    //MARK: - Interface Actions
    @IBAction func newClient(sender: UIBarButtonItem) {
        self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
        self.popViewController.title = "Add New Client"
        self.popViewController.showInView(self.view, withMessage: "Add client here", animated: true)
        /*
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("TestViewController"))! as UIViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(500,600)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRectMake(100,100,0,0)
        
        self.presentViewController(nav, animated: true, completion: nil)*/
    }
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! PopUpViewControllerSwift
        controller.delegate = self
    }
    
    
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? PopUpViewControllerSwift, user = sourceViewController.user {
            // Add a user
            //let newIndexPath = NSIndexPath(forRow: users.count, inSection: 0)
            users.append(user)
            //tableView.insert
        }
    }
    
    
}
