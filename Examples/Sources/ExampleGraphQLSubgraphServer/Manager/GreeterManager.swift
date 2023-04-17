import Vapor

actor GreeterManager {
    var people: [Person] = []

    func person(id: String) -> Person? {
        people.first { $0.id == id }
    }

    func greet(name: String) -> Person {
        let person = Person(id: UUID().uuidString, name: name)
        people.append(person)
        return person
    }
}

extension Application {
    struct Greeter {
        let application: Application
    }

    var greeter: Greeter { Greeter(application: self) }
}

extension Application.Greeter {
    struct ManagerKey: StorageKey {
        typealias Value = GreeterManager
    }

    var manager: GreeterManager {
        if let existing = application.storage[ManagerKey.self] {
            return existing
        } else {
            let new = GreeterManager()
            application.storage[ManagerKey.self] = new
            return new
        }
    }
}
