import Foundation
import RealmSwift
import ChameleonFramework
class Category:Object{
    @Persisted var categoryName:String = ""
    @Persisted var items = List<ToDoListItem>()
    @Persisted var color:String = ""
}
