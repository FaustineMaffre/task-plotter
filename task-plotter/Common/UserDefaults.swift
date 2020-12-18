//
//  UserDefaults.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Combine
import SwiftUI

@propertyWrapper
struct UserDefault<Value, StoredValue> {
    let key: String
    let defaultValue: Value
    
    let toValue: (StoredValue) -> Value
    let toStoredValue: (Value) -> StoredValue
    
    init(_ key: String, defaultValue: Value,
         toValue: @escaping (StoredValue) -> Value,
         toStoredValue: @escaping (Value) -> StoredValue) {
        self.key = key
        self.defaultValue = defaultValue
        self.toValue = toValue
        self.toStoredValue = toStoredValue
    }
    
    var wrappedValue: Value {
        get {
            if let storedValue = UserDefaults.standard.object(forKey: key) as? StoredValue {
                return self.toValue(storedValue)
            } else {
                return defaultValue
            }
        }
        set {
            UserDefaults.standard.set(self.toStoredValue(newValue), forKey: key)
        }
    }
}

extension UserDefault where Value == StoredValue {
    init(_ key: String, defaultValue: Value) {
        // no conversion required initializer
        self.init(key, defaultValue: defaultValue,
                  toValue: { $0 }, toStoredValue: { $0 })
    }
}

class UserDefaultsConfig: ObservableObject {
    /// Singleton.
    static let shared: UserDefaultsConfig = UserDefaultsConfig()
    private init() { }
    
    @UserDefault("is_tasks_pool_visible", defaultValue: false)
    var isTasksPoolVisible: Bool {
        willSet {
            if newValue != self.isTasksPoolVisible {
                self.objectWillChange.send()
            }
        }
    }
}
