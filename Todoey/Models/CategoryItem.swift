import Foundation
import RealmSwift

class Category:Object{
    @Persisted var categoryName:String = ""
    @Persisted var items = List<ToDoListItem>()
}
