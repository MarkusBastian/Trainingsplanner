//
//  trainingDeviceFormViewController.swift
//  FavoritetrainingDevice
//
//  Created by Markus B. on 01.04.24.
//

import UIKit

class TrainingDeviceFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var bezeichnung: UITextField!
    @IBOutlet var nummer: UITextField!
    @IBOutlet var einstellung: UITextField!
    @IBOutlet var gewicht: UITextField!
    @IBOutlet var kommentar: UITextField!
    @IBOutlet var kategorie: UITextField!
    
    let categoryPicker = UIPickerView()
    var trainingDevice: TrainingDevice?
    var pickerData: [DeviceCategory] = [DeviceCategory] ()
    var calledFromSettingsController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        kategorie.inputView = categoryPicker

        pickerData = [DeviceCategory.warmup, DeviceCategory.legs, DeviceCategory.back, DeviceCategory.abdominal, DeviceCategory.arms]

        updateView()
    }
    

    init?(coder: NSCoder, trainingDevice: TrainingDevice?) {
        self.trainingDevice = trainingDevice
        self.calledFromSettingsController = false
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        self.calledFromSettingsController = true
        super.init(coder: coder)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let kategorie: Optional<Int> = categoryPicker.selectedRow(inComponent: 0)
        guard let trainingDeviceBezeichnung = bezeichnung.text,
              let trainingDeviceNummer = nummer.text,
              let trainingDeviceEinstellung = einstellung.text,
              let trainingDeviceGewicht = gewicht.text,
              let trainingDeviceKommentar = kommentar.text,
              let trainingsDeviceKategorie = kategorie else {return}

        trainingDevice = TrainingDevice(bezeichnung: trainingDeviceBezeichnung, nummer: trainingDeviceNummer, einstellung: trainingDeviceEinstellung, gewicht: trainingDeviceGewicht, kommentar: trainingDeviceKommentar, kategorie: trainingsDeviceKategorie, deviceInPlan: false)
        
        if calledFromSettingsController {
            performSegue(withIdentifier: "UnwindToSettingsController", sender: self)
        } else {
            performSegue(withIdentifier: "UnwindTrainingDevice", sender: self)
        }
    }
    
    func updateView() {
        if let unwrappedtrainingDevice = trainingDevice {
            bezeichnung.text = unwrappedtrainingDevice.bezeichnung
            nummer.text = unwrappedtrainingDevice.nummer
            einstellung.text = unwrappedtrainingDevice.einstellung
            gewicht.text = unwrappedtrainingDevice.gewicht
            kommentar.text = unwrappedtrainingDevice.kommentar
            kategorie.text = pickerData[unwrappedtrainingDevice.kategorie ?? 0].rawValue
            categoryPicker.selectRow(unwrappedtrainingDevice.kategorie ?? 0, inComponent: 0, animated: true)
        } else {
            kategorie.text = pickerData[0].rawValue
            categoryPicker.selectRow(0, inComponent: 0, animated: true)
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        trainingDevice?.kategorie = row
        kategorie.text = pickerData[row].rawValue
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
