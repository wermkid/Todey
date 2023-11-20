import UIKit
import RealmSwift
import ChameleonFramework
class TodoListViewController: SwipeTableViewController {
    var items:Results<ToDoListItem>?
    lazy var realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let colorHex = selectedCategory?.color{
            title = selectedCategory!.categoryName
            guard let navigationBar = navigationController?.navigationBar else {
                fatalError("Navigation Bar has not yet been created, but is called.")
            }
            navigationBar.tintColor =  UIColor(hexString: colorHex)
            if let navcolor = UIColor(hexString: colorHex){
                navigationBar.barTintColor = ContrastColorOf(navcolor, returnFlat: true)
                navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:ContrastColorOf(navcolor, returnFlat: true)]
                searchBar.backgroundColor = navcolor
            }
        }
    }
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = items?[indexPath.row].name ?? "Add ToDo"
        items?[indexPath.row].status ?? false ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        
        if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row+1)/CGFloat(items!.count)){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            
            
        }
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
        let alert = UIAlertController(title: "Add new Todo Item", message: "Running, Petting a dog..", preferredStyle: .alert)
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do{
                try realm.write {
                    realm.delete(item)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
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
