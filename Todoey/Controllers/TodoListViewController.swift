import UIKit
import CoreData
class TodoListViewController: UITableViewController {
    var items=[ToDoListItems]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : CategoryItem?{
        didSet{
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadItems()
//        searchBar.delegate=self
    }
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        items[indexPath.row].status ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        context.delete(items[indexPath.row])
//        items.remove(at: indexPath.row)
        items[indexPath.row].status = !items[indexPath.row].status
        saveData()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Table View Data Source
    @IBAction func AddButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todo Item", message: "..", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let item = ToDoListItems(context: context)
            item.name = textField.text!
            item.status=false
            item.toCategoryParent = self.selectedCategory
            self.items.append(item)
            self.saveData()
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="Create new item"
            textField=alertTextField
        }
        present(alert, animated: true)
    }
    // MARK: - Sync Data
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    func saveData(){
        do{
            try context.save()
        }catch
        {
            print("Failed to save context",error)
        }
        tableView.reloadData()
    }
    func loadItems(for request:NSFetchRequest<ToDoListItems> = ToDoListItems.fetchRequest(),predicate:NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "toCategoryParent.categoryName MATCHES %@", selectedCategory!.categoryName!)
        if let predicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,predicate])
        }
        else{
            request.predicate = categoryPredicate
        }
        
        do{
            items = try context.fetch(request)
        }catch{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar
extension TodoListViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<ToDoListItems> = ToDoListItems.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        loadItems(for: request,predicate: predicate)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0{
            loadItems()
        }
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
   
}
