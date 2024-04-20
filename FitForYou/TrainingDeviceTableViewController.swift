import UIKit

class TrainingDeviceTableViewController: UITableViewController {
    
    struct PropertyKeys {
        static let trainingDeviceCell = "TrainingDeviceCell"
    }
    var inSwipe: Bool = false
    var myEdit: Bool = false
    var trainingDevices: [TrainingDevice] = []
    var checkMarkInRows: [Int: Bool] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.title = "Bearbeiten"

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
        let encodedtrainingDevices = try? propertyListEncoder.encode(trainingDevices)
        try? encodedtrainingDevices?.write(to: archiveURL, options: .noFileProtection)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedTrainingDevice = trainingDevices.remove(at: fromIndexPath.row)
        trainingDevices.insert(movedTrainingDevice, at: to.row)
        
        saveTableData()
    }

    fileprivate func loadTableData() {
        let propertyListDecoder = PropertyListDecoder()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("trainingDevices_test").appendingPathExtension("plist")
        if let retrievedtrainingDeviceData = try? Data(contentsOf: archiveURL),
           let decodedtrainingDevices = try?
            propertyListDecoder.decode(Array<TrainingDevice>.self, from: retrievedtrainingDeviceData) {
            trainingDevices = decodedtrainingDevices
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTableData()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingDevices.count
    }
    
    fileprivate func buildCheckmarkDictionary() {
        checkMarkInRows = [:]
        for cell in tableView.visibleCells {
            if (cell.accessoryType == .checkmark) {
                checkMarkInRows[tableView.indexPath(for: cell)!.row] = true
            } else {
                checkMarkInRows[tableView.indexPath(for: cell)!.row] = false
            }
        }
    }
    
    @IBSegueAction func editTrainingDevice(_ coder: NSCoder, sender: Any?) -> TrainingDeviceFormViewController? {
        let trainingDeviceToEdit: TrainingDevice?
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            trainingDeviceToEdit = trainingDevices[indexPath.row]
        } else {
            trainingDeviceToEdit = nil
        }
        
        buildCheckmarkDictionary()
        
        return TrainingDeviceFormViewController(coder: coder, trainingDevice: trainingDeviceToEdit)
    }
    
    @IBSegueAction func addTrainingDevice(_ coder: NSCoder) -> TrainingDeviceFormViewController? {
        buildCheckmarkDictionary()
        return TrainingDeviceFormViewController(coder: coder)
    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        guard
            let trainingDeviceFormViewController = segue.source as?
                TrainingDeviceFormViewController,
            let trainingDevice = trainingDeviceFormViewController.trainingDevice
        else {
            return
        }
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            trainingDevices[selectedIndexPath.row] = trainingDevice
        } else {
            trainingDevices.append(trainingDevice)
        }
        
        saveTableData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.trainingDeviceCell, for: indexPath)
             
        let trainingDevice = trainingDevices[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = trainingDevice.bezeichnung + " " + String(trainingDevice.nummer)
        content.secondaryText = trainingDevice.description
        cell.showsReorderControl = true
        cell.contentConfiguration = content
        cell.accessoryType = checkMarkInRows[indexPath.row] == true ? .checkmark : .none
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
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil,
        handler: { (action, view, completionHandler) in            
            self.trainingDevices.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveTableData()
            completionHandler(true)
        })
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
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
