

import UIKit
import CoreData

class ViewControllerDetails: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate {
   

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveButton: UIButton! // We use it to activate the button
    
    
    // To show the Page by selection
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isEnabled = false // for button view
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as!AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
           
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {  // we use NSamanagedObject to get the data as a single object
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                            
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                            
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }

                }
                }
                
            }catch{
                
            }
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }

      // for finger detection
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(gestureRecognizer)
        
        
        //MARK: select images
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    //MARK: Select Image
    @objc func selectImage () {
        
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    // MARK: when clicking the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil)
        
        saveButton.isEnabled = true
    }
                                                       
    @objc func hideKeyBoard(){
            view.endEditing(true)
        
    }
    
    @IBAction func SaveButtonClicked(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newImage = NSEntityDescription.insertNewObject(forEntityName: "Images", into: context)
        
        
        newImage.setValue(nameText.text!, forKey: "name")
        newImage.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newImage.setValue(year, forKey: "year")
        }
        
        newImage.setValue(UUID(), forKey: "id")
        
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newImage.setValue(data, forKey: "image")
        
        do {
            try context.save() // database registration process
            print("success")
        }catch {
            print("error")
        }
        
        
        self.navigationController?.popViewController(animated: true)
        
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
    }
    
   

}
