import UIKit
import CoreData
class CategoryViewController: UITableViewController {
    var categories = [CategoryItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    // MARK: - Table View data source
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "Lifestyle, Chill Goods, etc", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){ action in
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let category = CategoryItem(context: context)
            category.categoryName = textField.text!
            self.categories.append(category)
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
    
    // MARK: - Table view Delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItem",for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].categoryName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToDoListItems", sender:self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destination.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Sync Data
    func saveData(){
        do{
            try context.save()
        }catch
        {
            print("Failed to save context",error)
        }
        tableView.reloadData()
    }
    func loadItems(for request:NSFetchRequest<CategoryItem> = CategoryItem.fetchRequest()){
        do{
            categories = try context.fetch(request)
        }catch{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
}
