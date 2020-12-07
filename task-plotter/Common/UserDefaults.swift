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

class UserDefaultsConfig: ObservableObject {
    /// Singleton.
    static let shared: UserDefaultsConfig = UserDefaultsConfig()
    private init() { }
    
    // MARK: - Selected project/version
    
    private static let stringToUuid = { (storedValue: String) -> UUID? in UUID(uuidString: storedValue) }
    private static let uuidToString = { (value: UUID?) -> String in if let value = value { return value.uuidString } else { return "" } }
    
    @UserDefault("selected_project_id", defaultValue: nil, toValue: stringToUuid, toStoredValue: uuidToString)
    var selectedProjectId: ProjectID? {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    @UserDefault("selected_version_id", defaultValue: nil, toValue: stringToUuid, toStoredValue: uuidToString)
    var selectedVersionId: VersionID? {
        willSet {
            self.objectWillChange.send()
        }
    }
}
