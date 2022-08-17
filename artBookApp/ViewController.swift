

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    

    @IBOutlet weak var tableView: UITableView!
    
    
    var  nameArray = [String]()
    var idArray = [UUID]()
    
    
    var selectedPainting = ""
    var selectedPaintingId: UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    // DATA DRAWING FUNCTION
    @objc func getData(){
        
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        
        let appDelegate = UIApplication.shared.delegate as!AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {  
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                        
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    
                    self.tableView.reloadData()
            }
                
            }
            print("success")
        }catch{
               print("error")
        }
    }

    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! ViewControllerDetails
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    
    // MARK: data deletion process
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as!AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // birtane fetch request oluşturmamız gerekıyor:Bu nedemek
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
            
            
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let receivedID = result.value(forKey: "id") as? UUID{
                            if receivedID == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                
            }
            
        }
    }

}

