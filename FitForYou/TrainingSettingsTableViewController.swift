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
        let label = UILabel()
        label.text = deviceCategories[section].rawValue
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textColor = .black
        label.sizeToFit()
        return label
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
        return cell
    }
  
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
