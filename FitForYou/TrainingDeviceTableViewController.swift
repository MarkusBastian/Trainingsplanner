import UIKit
import AVKit


class TrainingDeviceTableViewController: UITableViewController {
    
    struct PropertyKeys {
        static let trainingDeviceCell = "TrainingDeviceCell"
    }
    
    var inSwipe: Bool = false
    var myEdit: Bool = false
    var illegalMove: Bool = false
    var checkMarkInRows: [Int: Bool] = [:]
    var trainingDevicesInCategories: [TrainingDeviceInCategory] = []
    var deviceCategories: [DeviceCategory] = [DeviceCategory] ()

    
    fileprivate func initTrainingsCategories() {
        trainingDevicesInCategories =
        [TrainingDeviceInCategory(category: 0, trainingDevices: []),
         TrainingDeviceInCategory(category: 1, trainingDevices: []),
         TrainingDeviceInCategory(category: 2, trainingDevices: []),
         TrainingDeviceInCategory(category: 3, trainingDevices: []),
         TrainingDeviceInCategory(category: 4, trainingDevices: [])]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.title = "Bearbeiten"
        deviceCategories = [DeviceCategory.warmup, DeviceCategory.legs, DeviceCategory.back, DeviceCategory.abdominal, DeviceCategory.arms]
        initTrainingsCategories()
    }

    @IBAction func showInfoView(_ sender: Any) {
       let infoPopup = InfoPopupController()
        infoPopup.appear(sender: self)
    }
    
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if (!inSwipe) {
            myEdit = editing
        }
        if (myEdit == true) {
            self.editButtonItem.title = "Fertig"
        } else {
            self.editButtonItem.title = "Bearbeiten"
        }
    }

    fileprivate func saveTableData() {
        let propertyListEncoder = PropertyListEncoder()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("trainingDevices_test").appendingPathExtension("plist")
        let encodedtrainingDevices = try? propertyListEncoder.encode(trainingDevicesInCategories)
        try? encodedtrainingDevices?.write(to: archiveURL, options: .noFileProtection)
    }
    
    fileprivate func getRealRow (planIndexPath: IndexPath) -> Int {
        var realRowIndex: Int = 0
        var activeDevicesCounter = 0
        
        for i in 0...trainingDevicesInCategories[planIndexPath.section].trainingDevices.count - 1 {
            if trainingDevicesInCategories[planIndexPath.section].trainingDevices[i].deviceInPlan! {
                activeDevicesCounter += 1
            }
            if activeDevicesCounter - 1 == planIndexPath.row {
                realRowIndex = i
            }
        }
        
        return realRowIndex
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var realRowFrom: Int = getRealRow(planIndexPath: fromIndexPath)
        var realRowTo: Int = getRealRow(planIndexPath: to)
        
        let movedTrainingDevice = trainingDevicesInCategories[fromIndexPath.section].trainingDevices.remove(at: realRowFrom)
        trainingDevicesInCategories[to.section].trainingDevices.insert(movedTrainingDevice, at: realRowTo)
        if illegalMove {
            AudioServicesPlaySystemSound(1256)
            illegalMove = false
        }
        saveTableData()
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            illegalMove = true
        } else {
            illegalMove = false
        }
        return sourceIndexPath.section == proposedDestinationIndexPath.section ? proposedDestinationIndexPath : sourceIndexPath
    }

    fileprivate func loadTableData() {
        let propertyListDecoder = PropertyListDecoder()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("trainingDevices_test").appendingPathExtension("plist")
        if let retrievedtrainingDeviceData = try? Data(contentsOf: archiveURL),
            let decodedtrainingDevices = try?
            propertyListDecoder.decode(Array<TrainingDeviceInCategory>.self, from: retrievedtrainingDeviceData) {
            trainingDevicesInCategories = decodedtrainingDevices
        }
        if trainingDevicesInCategories.count > 0 {
            for i in 0...trainingDevicesInCategories.count - 1 {
                if trainingDevicesInCategories[i].trainingDevices.count > 0 {
                    for j in 0...trainingDevicesInCategories[i].trainingDevices.count - 1 {
                        if trainingDevicesInCategories[i].trainingDevices[j].deviceInPlan == nil {
                            trainingDevicesInCategories[i].trainingDevices[j].deviceInPlan = true
                        }
                    }
                }
            }
        }
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTableData()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int = 0
        
        for trainingsDevice in trainingDevicesInCategories[section].trainingDevices {
            if trainingsDevice.deviceInPlan! {
                count += 1
            }
        }
        return count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return trainingDevicesInCategories.count
    }

    fileprivate func buildCheckmarkDictionary() {
        checkMarkInRows = [:]
        for cell in tableView.visibleCells {
            let indexPath = tableView.indexPath(for: cell)
            let key: Int = indexPath!.section * 100 +  indexPath!.row
            if (cell.accessoryType == .checkmark) {
                checkMarkInRows[key] = true
            } else {
                checkMarkInRows[key] = false
            }
        }
    }
   
    @IBAction func unwindFromSettingsViewController(segue: UIStoryboardSegue) {
        guard
            let trainingsSettingsTableViewController = segue.source as?
                TrainingSettingsTableViewController,

                let trainingDevicesInCategories = trainingsSettingsTableViewController.trainingDevicesInCategories
        else {
            return
        }
        self.trainingDevicesInCategories = trainingDevicesInCategories
        saveTableData()
    }
    
    @IBSegueAction func settingsForTrainingsDevices(_ coder: NSCoder) -> TrainingSettingsTableViewController? {
        return  TrainingSettingsTableViewController(coder: coder, trainingDevices: trainingDevicesInCategories)
     }
    
    @IBSegueAction func editTrainingsDevice(_ coder: NSCoder, sender: Any?) -> TrainingDeviceFormViewController? {
        let trainingDeviceToEdit: TrainingDevice?
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            trainingDeviceToEdit = trainingDevicesInCategories[indexPath.section].trainingDevices[getRealRow(planIndexPath: indexPath)]
        } else {
            trainingDeviceToEdit = nil
        }
        
        buildCheckmarkDictionary()
        
        return TrainingDeviceFormViewController(coder: coder, trainingDevice: trainingDeviceToEdit)
    }

    @IBAction func unwindFromDeviceFormViewController(segue: UIStoryboardSegue) {
        guard
            let trainingDeviceFormViewController = segue.source as?
                TrainingDeviceFormViewController,
            let trainingDevice = trainingDeviceFormViewController.trainingDevice
        else {
            return
        }
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            var realRowIndex = getRealRow(planIndexPath: selectedIndexPath)
            if selectedIndexPath.section == trainingDevice.kategorie {
                trainingDevicesInCategories[selectedIndexPath.section].trainingDevices[realRowIndex] = trainingDevice
            } else {
                trainingDevicesInCategories[selectedIndexPath.section].trainingDevices.remove(at: realRowIndex)
                trainingDevicesInCategories[trainingDevice.kategorie ?? 0].trainingDevices.append(trainingDevice)
            }
        } else {
            trainingDevicesInCategories[trainingDevice.kategorie ?? 0].trainingDevices.append(trainingDevice)
        }
        saveTableData()
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.trainingDeviceCell, for: indexPath)
             
        let trainingDevice = trainingDevicesInCategories[indexPath.section].trainingDevices[getRealRow(planIndexPath: indexPath)]
        if trainingDevice.kategorie == nil {
            trainingDevicesInCategories[indexPath.section].trainingDevices[getRealRow(planIndexPath: indexPath)].kategorie = 0
        }
        var content = cell.defaultContentConfiguration()
        content.text = trainingDevice.bezeichnung + " " + String(trainingDevice.nummer)
        content.secondaryText = trainingDevice.description
        cell.showsReorderControl = true
        cell.contentConfiguration = content
        cell.accessoryType = checkMarkInRows[indexPath.section * 100 + indexPath.row] == true ? .checkmark : .none
        return cell
    }
        
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var swipeConfig: UISwipeActionsConfiguration

        if (!myEdit) {
            if (inSwipe) {
                return nil
            }
            let flagAction = self.contextualFlagAction(forRowAtIndexPath: indexPath)
            swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        } else {
            let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
            swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return swipeConfig
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return deviceCategories[section].rawValue
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = deviceCategories[section].rawValue
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textColor = .white
        label.sizeToFit()
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil,
        handler: { (action, view, completionHandler) in            
            self.trainingDevicesInCategories[indexPath.section].trainingDevices[self.getRealRow(planIndexPath: indexPath)].deviceInPlan = false
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveTableData()
            completionHandler(true)
        })
        deleteAction.image = UIImage(systemName: "arrowshape.turn.up.left")
        deleteAction.backgroundColor = UIColor.orange
        return deleteAction
    }
    
    func contextualFlagAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let flagAction = UIContextualAction(style: .normal, title: "Flag", handler: { (action, view, completionHandler) in
            if (self.tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) {
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            completionHandler(true)
        })
        inSwipe = true
        navigationItem.leftBarButtonItem?.isEnabled = false
        flagAction.image = UIImage(systemName: "flag")
        flagAction.backgroundColor = UIColor.orange
        return flagAction
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        inSwipe = false
        setEditing(false, animated: true)
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
}
