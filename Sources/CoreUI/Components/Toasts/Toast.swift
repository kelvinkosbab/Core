//
//  Toast.swift
//
//  Created by Kelvin Kosbab on 8/1/21.
//

import SwiftUI

// MARK: - Toast

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class Toast {
    
    // MARK: - Registering Toast Managers
    
    private static var registeredManagers: [AppSessionTarget : ToastStateManager] = [:]
    
    static func register(manager: ToastStateManager,
                         target: AppSessionTarget) {
        
        guard self.registeredManagers[target] == nil else {
            fatalError("Toast manager has already been registred for target: \(target.rawValue)")
        }
        
        self.registeredManagers[target] = manager
    }
    
    private static func managerNotConfiguredError(target: AppSessionTarget) -> String {
        return "Toast manager not configured for target: \(target.rawValue)"
    }
    
    // MARK: - ToastContent

    /// Defines content supported content for a toast.
    public struct Content {
        
        public enum SubContent : Equatable {
            case none
            case image(_ image: Image)
            case tintedImage(_ image: Image, _ tintColor: Color)
            
            @ViewBuilder
            func body() -> some View {
                switch self {
                case .none:
                    Rectangle()
                        .fill(.clear)
                case .image(let image):
                    image
                        .resizable()
                case .tintedImage(let image, let tintColor):
                    image
                        .resizable()
                        .foregroundColor(tintColor)
                }
            }
            
            public static func == (lhs: SubContent, rhs: SubContent) -> Bool {
                switch lhs {
                case .none:
                    switch rhs {
                    case .none: return true
                    default: return false
                    }
                case .image:
                    switch rhs {
                    case .image: return true
                    default: return false
                    }
                case .tintedImage:
                    switch rhs {
                    case .tintedImage: return true
                    default: return false
                    }
                }
            }
        }
        
        /// Primary title message.
        let title: String
        
        /// Optional description. This text will be displayed directly below the title.
        let description: String?
        
        /// Optional image and optional tint color displayed on tthe leading edge of the toast.
        let leading: SubContent

        /// Optional image and optional tint color displayed on tthe trailing edge of the toast.
        let trailing: SubContent
        
        /// Constructor.
        ///
        /// - Parameter title: Primary title message.
        /// - Parameter description: Optional description. This text will be displayed directly below the title.
        /// - Parameter leadingImage: Optional image and optional tint color displayed on tthe leading edge of the toast.
        /// - Parameter trailingImage: Optional image and optional tint color displayed on tthe trailing edge of the toast.
        public init(title: String,
                    description: String? = nil,
                    leading: Toast.Content.SubContent = .none,
                    trailing: Toast.Content.SubContent = .none) {
            self.title = title
            self.description = description
            self.leading = leading
            self.trailing = trailing
        }
    }
    
    // MARK: - Showing Toasts
    
    /// Shows a toast.
    ///
    /// - Parameter title: Primary title message.
    /// - Parameter description: Optional description. This text will be displayed directly below the title.
    /// - Parameter leading: Content to be displayed on the leading edge of the toast.
    /// - Parameter trailing: Content to be displayed on the trailing edge of the toast.
    /// - Parameter target: Target window to show the toast from.
    public static func show(title: String,
                            description: String? = nil,
                            leading: Toast.Content.SubContent = .none,
                            trailing: Toast.Content.SubContent = .none,
                            target: AppSessionTarget = .primary) {
        
        guard let manager = self.registeredManagers[target] else {
            fatalError(self.managerNotConfiguredError(target: target))
        }
        
        let content = Toast.Content(title: title,
                                    description: description,
                                    leading: leading,
                                    trailing: trailing)
        manager.show(content)
    }
}
