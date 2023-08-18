# FireThel

Get rid of redundant [Firebase](https://github.com/firebase/firebase-ios-sdk)
code
with FireThel! You can do CRUD operations in Firestore with a single line:

```swift
let reference = try await db.addDoc(model: restaurant, path: .getPath(for: .restaurant))
```
## Requirements
* Xcode 14.1+ | Swift 5.7+
* iOS 13.0+

## Usage

### Firestore

* #### Step 1:

    Add the library with [Swift Package Manager](https://www.swift.org/package-manager/). Choose FireThelFirestore.

* #### Step 2 (optional):

    Take advantage of the factory pattern and make your paths less error prone and
more syntactically pleasing!

    ```swift
    // MARK: - Factory for Firestore collection path
    extension String {
        enum CollectionPath {
            case restaurant
            case menu(restaurantId: String)
        }
        
        // Factory
        static func getPath(for path: CollectionPath) -> String {
            switch path {
            case .restaurant:
                return "restaurant"
            case .menu(let restaurantId):
                return "restaurant/\(restaurantId)/menu"
            }
        }
    }
    ```

* #### Step 3:

    Make your data model conform to `Codable` and add the `@DocumentID` property wrapper.  
    
    ```swift
    import FirebaseFirestoreSwift
    
    struct RestaurantMenu: Codable {
        @DocumentID var id: String?
        var specialDish: String
        var desert: String
    }
    ```
 
* #### Step 4: 
    
    Import the library with Firestore to create an instance of the database.

    ```swift
    import FireThelFirestore
    import FirebaseFirestore

    class SomeClass { 
        private let db = Firestore.firestore()
    }
    ```
* #### Step 5:
    
    Perform CRUD operations.

    ##### Create/Add:
    ```swift
    let restaurant = Restaurant(name: name, type: RestaurantType(rawValue: restaurantType)!)
    let menu = RestaurantMenu(specialDish: specialDish, desert: desert)

    // add(), if you want Firebase to take care of the id
    let reference = try await db.addDoc(model: restaurant, path: .getPath(for: .restaurant))

    // create(), if you want to update or set a doc with a custom id
    try await db.createDoc(
        model: menu,
        path: .getPath(for: .menu(restaurantId: reference.documentID)),
        documentId: reference.documentID
    )
    ```

    ##### Get:
    ```swift
    // get single
    let menu: RestaurantMenu = try await db.getDoc(path: .getPath(for: .menu(restaurantId: documentId)), documentId: documentId)

    // get all from collection
    let restaurants: [Restaurant] = try await db.getDocs(predicates: [.limit(to: 5)], path: .getPath(for: .restaurant))
    ```

    ##### Listen:
    ```swift
    listenerSubscription = db.observeCollection(path: .getPath(for: .restaurant), predicates: [.isEqualTo("type", "American")])
        .sink { completiom in
            switch completiom {
            case .finished:
                print("Finished")
            case .failure(let err):
                print("Listener err: \(err)")
            }
        } receiveValue: { [weak self] output in
            self?.restaurantsView.restaurants = output
        }

    ```

    ##### Listen with changes:
    ```swift
    private func listen() {
        listenerSubscription = db.observeCollection(path: .getPath(for: .restaurant), predicates: [.isEqualTo("type", "American")])
            .sink { completiom in
               
            } receiveValue: { [weak self] output in
                // Output need to match listener output.
                // With a function it's very clear what the generic type will be, and the compiler will compile
                self?.handleOutput(output)
            }
    }

    private func handleOutput(_ listenerOutputs: [ListenerOuput<Restaurant>]) {
        for output in listenerOutputs {
            switch output.changeType {
            case .added:
                print("New doc added")
            case .modified:
                print("Doc changed")
            case .removed:
                print("Doc removed")
            }
        }
    }
    ```

    ##### Update:

    ```swift
    let fields: [AnyHashable: Any] = [
        "name": name,
        "type": restaurantType
    ]
    try await db.updateDoc(fields, path: .getPath(for: .restaurant), documentId: documentId)
    ```

    ##### Delete:

    ```swift
    try await db.deleteDoc(path: .getPath(for: .restaurant), documentId: documentId)
    ```
