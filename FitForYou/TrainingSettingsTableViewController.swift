//
//  TrainingSettingsTableViewController.swift
//  FitForYou
//
//  Created by Markus B. on 02.06.24.
//

import UIKit

class TrainingSettingsTableViewController: UITableViewController {

    var trainingDevicesInCategories: [TrainingDeviceInCategory]?
    var deviceCategories: [DeviceCategory] = [DeviceCategory] ()

    struct PropertyKeys {
        static let trainingDeviceCell = "TrainingDeviceCell"
    }
 
    init?(coder: NSCoder, trainingDevices: [TrainingDeviceInCategory]?) {
        self.trainingDevicesInCategories = trainingDevices!
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        deviceCategories = [DeviceCategory.warmup, DeviceCategory.legs, DeviceCategory.back, DeviceCategory.abdominal, DeviceCategory.arms]
        
        let backButton = UIBarButtonItem()
        backButton.title = "Trainingsplan"
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return trainingDevicesInCategories!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingDevicesInCategories![section].trainingDevices.count
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return deviceCategories[section].rawValue
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myHeader = UIView()
        
        let label = UILabel()
        label.text = deviceCategories[section].rawValue
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textColor = .black
        label.sizeToFit()
        myHeader.addSubview(label)
        
        if (section < trainingDevicesInCategories!.count - 1) {
            let downButton = UIButton(frame: CGRect(x: 320, y: 5, width: 15, height: 15))
            downButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
            downButton.tag = section
            downButton.addTarget(self, action: #selector(moveSectionDown), for: .touchUpInside)
            myHeader.addSubview(downButton)
        }

        if (section > 0) {
            let upButton = UIButton(frame: CGRect(x: 350, y: 5, width: 15, height: 15))
            upButton.setImage(UIImage(systemName: "arrow.up"), for: .normal)
            upButton.tag = section
            upButton.addTarget(self, action: #selector(moveSectionUp), for: .touchUpInside)
            myHeader.addSubview(upButton)
        }
            
        return myHeader
    }

    @objc func moveSectionDown(_ button:UIButton){
        let trainingsDeviceInCategory = (trainingDevicesInCategories?.remove(at: button.tag))!
        trainingDevicesInCategories?.insert(trainingsDeviceInCategory, at: button.tag + 1)
        tableView.moveSection(button.tag, toSection:button.tag + 1)
        let deviveCategory = deviceCategories.remove(at: button.tag)
        deviceCategories.insert(deviveCategory, at: button.tag + 1)
        renumberKategories()
        tableView.reloadData()
    }

    @objc func moveSectionUp(_ button:UIButton){
        let trainingsDeviceInCategory = (trainingDevicesInCategories?.remove(at: button.tag))!
        trainingDevicesInCategories?.insert(trainingsDeviceInCategory, at: button.tag - 1)
        tableView.moveSection(button.tag, toSection:button.tag - 1)
        let deviveCategory = deviceCategories.remove(at: button.tag)
        deviceCategories.insert(deviveCategory, at: button.tag - 1)
        renumberKategories()
        tableView.reloadData()
    }

    fileprivate func renumberKategories() {
        if trainingDevicesInCategories!.count > 0 {
            for i in 0...trainingDevicesInCategories!.count - 1 {
                if trainingDevicesInCategories![i].trainingDevices.count > 0 {
                    trainingDevicesInCategories![i].category = i
                    for j in 0...trainingDevicesInCategories![i].trainingDevices.count - 1 {
                        trainingDevicesInCategories![i].trainingDevices[j].kategorie = i
                        if trainingDevicesInCategories![i].trainingDevices[j].deviceInPlan == nil {
                            trainingDevicesInCategories![i].trainingDevices[j].deviceInPlan = true
                        }
                    }
                }
            }
        }
     }
    
    @IBSegueAction func addTrainingsDevice(_ coder: NSCoder) -> TrainingDeviceFormViewController? {
        return TrainingDeviceFormViewController(coder: coder)
    }
    
    @IBAction func saveDevices(_ sender: Any) {
        performSegue(withIdentifier: "UnwindFromSettings", sender: self)
    }
    
    @IBAction func unwindToSettingViewController(segue: UIStoryboardSegue) {
        guard
            let trainingDeviceFormViewController = segue.source as?
                TrainingDeviceFormViewController,
            let trainingDevice = trainingDeviceFormViewController.trainingDevice
        else {
            return
        }

        trainingDevicesInCategories![trainingDevice.kategorie ?? 0].trainingDevices.append(trainingDevice)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.trainingDeviceCell, for: indexPath)
             
        let trainingDevice = trainingDevicesInCategories![indexPath.section].trainingDevices[indexPath.row]
        if trainingDevice.kategorie == nil {
            trainingDevicesInCategories![indexPath.section].trainingDevices[indexPath.row].kategorie = 0
        }
       
        cell.textLabel?.text = trainingDevice.bezeichnung
        cell.detailTextLabel?.text = trainingDevice.nummer
        if trainingDevice.deviceInPlan! {
            cell.selectionStyle = .none
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.textColor = .lightGray
            let imgView = UIImageView(image: UIImage(systemName: "list.clipboard"))
            cell.accessoryView = imgView
        } else {
            cell.selectionStyle = .default
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        return cell
    }
   
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let trainingDevice = trainingDevicesInCategories![indexPath.section].trainingDevices[indexPath.row]
        if trainingDevice.deviceInPlan! {
            return nil
        } else {
            trainingDevicesInCategories![indexPath.section].trainingDevices[indexPath.row].deviceInPlan = true
            tableView.reloadData()
            return indexPath
        }
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let trainingDevice = trainingDevicesInCategories![indexPath.section].trainingDevices[indexPath.row]
        if trainingDevice.deviceInPlan! {
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var swipeConfig: UISwipeActionsConfiguration

        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }

    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil,
        handler: { (action, view, completionHandler) in
            self.trainingDevicesInCategories?[indexPath.section].trainingDevices.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        })
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return deleteAction
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
