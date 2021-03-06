//
//  ToastView.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import SwiftUI

#if !os(macOS)

// MARK: - ToastView

/// Displayable content for a toast.
@available(iOS 13.0, macOS 12.0, tvOS 13.0, watchOS 6.0, *)
struct ToastView : View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding private var content: ToastContent
    
    private let imageSize: CGFloat = Spacing.large
    
    init(_ content: Binding<ToastContent>) {
        self._content = content
    }
    
    var body: some View {
        HStack {
            if self.content.leading != .none || self.content.trailing != .none {
                
                self.renderSubContent(self.content.leading.body(), isLeading: true)
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.tiny)
                    .padding(.horizontal, Spacing.base)
                
                self.renderSubContent(self.content.trailing.body(), isLeading: false)
                
            } else {
                
                self.getTextContent(title: content.title, description: content.description)
                    .padding(.vertical, Spacing.small)
                    .padding(.horizontal, Spacing.xxl)
            }
        }
        .frame(minWidth: .zero,
               maxWidth: 330,
               minHeight: 54,
               maxHeight: .infinity)
        .fixedSize(horizontal: true,
                   vertical: true)
        .coreContainer(shadowStyle: .none,
                       backgroundStyle: self.colorScheme == .light ? .blur(.systemChromeMaterial) : .blur(.systemThinMaterial),
                       cornerStyle: .capsule)
    }
    
    private func getTextContent(title: String, description: String?) -> some View {
        VStack(spacing: Spacing.tiny) {
            Text(title)
                .footnoteBoldStyle(appFont: .systemBold)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.primary)
            if let description = description {
                Text(description)
                    .footnoteStyle(appFont: .systemRegular)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    @ViewBuilder
    private func renderSubContent<Content>(_ content: Content, isLeading: Bool) -> some View where Content: View {
        content
            .frame(width: self.imageSize, height: self.imageSize)
            .padding(.vertical, Spacing.tiny)
            .padding(isLeading ? .leading : .trailing, Spacing.base)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 13.0, macOS 11, tvOS 13.0, watchOS 6.0, *)
struct ToastView_Previews: PreviewProvider {
    
    static let image: Image = Image(systemName: "heart.circle.fill")
    
    static var previews: some View {
        VStack(spacing: Spacing.base) {
            ToastView(.constant(ToastContent(title: "One")))
            ToastView(.constant(ToastContent(title: "Two",
                                             leading: .tintedImage(self.image, .green))))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello")))
            ToastView(.constant(ToastContent(title: "Two",
                                             description: "Hello",
                                             leading: .tintedImage(self.image, .blue),
                                             trailing: .tintedImage(self.image, .blue))))
        }
    }
}

#endif
#endif
