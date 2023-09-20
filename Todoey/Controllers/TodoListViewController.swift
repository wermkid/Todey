import UIKit
class TodoListViewController: UITableViewController {
    var items=[ToDoListDataItem]()
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
//    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let i = defaults.array(forKey: "ItemsForToDoList") as? [ToDoListDataItem]{
//            items = i
//        }
        loadItems()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("Called CellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell",for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        items[indexPath.row].status ? (cell.accessoryType = .checkmark) : (cell.accessoryType = .none)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].status = !items[indexPath.row].status
        saveData()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func AddButtonPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todo Item", message: "..", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            let item = ToDoListDataItem()
            item.name = textField.text!
            item.status=false
            self.items.append(item)
//            self.defaults.set(self.items, forKey: "ItemsForToDoList")
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
    func saveData(){
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(items)
            try data.write(to: dataPath!)
        }catch{
            print(error)
        }
    }
    func loadItems(){
        if let data = try? Data(contentsOf: dataPath!){
            let decoder = PropertyListDecoder()
            do{
                items = try decoder.decode([ToDoListDataItem].self, from: data)
            }
            catch{
                print(error)
            }
        }
    }
}
