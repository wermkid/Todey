import UIKit
import RealmSwift
class TodoListViewController: UITableViewController {
    var items:Results<ToDoListItem>?
    lazy var realm = try! Realm()
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
//        searchBar.delegate=self
    }
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",for: indexPath)
        cell.textLabel?.text = items?[indexPath.row].name ?? "Add ToDo"
        items?[indexPath.row].status ?? false ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row]{
            do{
                try self.realm.write{
                        item.status = !item.status
                    }
            }catch{
                print("Error updating Item status", error)
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Table View Data Source
    @IBAction func AddButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todo Item", message: "..", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { [self] action in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try realm.write{
                        let item = ToDoListItem()
                        item.name = textField.text!
                        item.status=false
                        let date = Date()
                        let format = DateFormatter()
                        format.dateFormat = "dd/MM/yyyy"
                        let ddate = format.string(from: date)
                        item.date = ddate
                        currentCategory.items.append(item)
                    }
                }catch{
                    print(error)
                }
            }
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
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "name",ascending: true)
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar
extension TodoListViewController:UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("name CONTAINS[cd] %@",searchBar.text!).sorted(byKeyPath:"date",ascending: true)
        tableView.reloadData()
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
