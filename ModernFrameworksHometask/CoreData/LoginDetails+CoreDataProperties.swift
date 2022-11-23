//
//  LoginDetails+CoreDataProperties.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 20.11.2022.
//
//

import Foundation
import CoreData


extension LoginDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoginDetails> {
        return NSFetchRequest<LoginDetails>(entityName: "LoginDetails")
    }

    @NSManaged public var userLogin: String?
    @NSManaged public var userPassword: String?

}

extension LoginDetails : Identifiable {

}
