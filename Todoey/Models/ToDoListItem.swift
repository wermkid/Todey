import Foundation
import RealmSwift
import Darwin
class ToDoListItem: Object {
    @Persisted var name:String = ""
    @Persisted var status: Bool = false
    @Persisted var date : String?
    var parent = LinkingObjects(fromType: Category.self, property: "items")
}
