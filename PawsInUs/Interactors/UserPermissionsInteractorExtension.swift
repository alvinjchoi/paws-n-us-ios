//
//  UserPermissionsInteractorExtension.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import UIKit

extension DIContainer.Interactors {
    var userPermissions: UserPermissionsInteractor {
        RealUserPermissionsInteractor(
            appState: appState,
            openAppSettings: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        )
    }
}