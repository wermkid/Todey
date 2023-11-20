import UIKit
import RealmSwift
import ChameleonFramework
class CategoryViewController: SwipeTableViewController {
    lazy var realm = try! Realm()
    var categories : Results<Category>?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigationBar = navigationController?.navigationBar else {
            fatalError("Navigation Bar has not yet been created, but is called.")
        }
        navigationBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    // MARK: - Table View data source
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "Lifestyle, Chill Goods, etc", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){ action in
            let category = Category()
            category.categoryName = textField.text!
            self.saveData(category: category)
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder="Create new item"
            textField=alertTextField
        }
        present(alert, animated: true)
    }
    
    // MARK: - Table view Delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].categoryName ?? "Nothing to show!"
        if categories?[indexPath.row].color == ""{
            cell.backgroundColor = UIColor.randomFlat()
            do{
                try realm.write {
                    categories?[indexPath.row].color = (cell.backgroundColor?.hexValue())!
                }
            }catch{
                print(error)
            }
        }
        else{
            cell.backgroundColor=UIColor(hexString: categories![indexPath.row].color)
//            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor, returnFlat: true)
        }
//        print((categories?[indexPath.row].color)!)
        return cell
    }
//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDoListItems", sender:self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destination.selectedCategory = categories?[indexPath.row]
        }
    }
    // MARK: - Sync Data
    func saveData(category: Category){
        do{
            try realm.write({
                realm.add(category)
            })
        }catch
        {
            print("Failed to save data locally, try again",error.localizedDescription)
        }
        tableView.reloadData()
    }
    func loadItems(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let categoryToBeRemoved = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryToBeRemoved)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
