import Defaults
import SwiftUI

enum SelectionAppearance {
  case none
  case topConnection
  case bottomConnection
  case topBottomConnection

  func rect(cornerRadius: CGFloat) -> some Shape {
    var cornerRadii = RectangleCornerRadii()
    switch self {
    case .none:
      cornerRadii.topLeading = cornerRadius
      cornerRadii.topTrailing = cornerRadius
      cornerRadii.bottomLeading = cornerRadius
      cornerRadii.bottomTrailing = cornerRadius
    case .topConnection:
      cornerRadii.bottomLeading = cornerRadius
      cornerRadii.bottomTrailing = cornerRadius
    case .bottomConnection:
      cornerRadii.topLeading = cornerRadius
      cornerRadii.topTrailing = cornerRadius
    case .topBottomConnection:
      break
    }
    return .rect(cornerRadii: cornerRadii)
  }
}

enum ListItemStyle: Equatable {
  case card
  case menu
  case plain
}

struct ListItemView<Title: View, ID: Hashable>: View {
  var id: ID
  var selectionId: UUID
  var appIcon: ApplicationImage?
  var image: NSImage?
  var accessoryImage: NSImage?
  var attributedTitle: AttributedString?
  var shortcuts: [KeyShortcut]
  var isSelected: Bool
  var selectionIndex: Int?
  var help: LocalizedStringKey?
  var selectionAppearance: SelectionAppearance = .none
  var style: ListItemStyle = .plain
  @ViewBuilder var title: () -> Title

  @Default(.showApplicationIcons) private var showIcons
  @Environment(AppState.self) private var appState
  @Environment(ModifierFlags.self) private var modifierFlags

  private var horizontalContentPadding: CGFloat {
    return style == .card ? 10 : 0
  }

  private var titleLineLimit: Int {
    return style == .card ? 3 : 1
  }

  private var minimumHeight: CGFloat {
    return style == .card ? Popup.itemHeight : 22
  }

  @ViewBuilder
  var body: some View {
    let row = HStack(spacing: 0) {
      if showIcons, let appIcon {
        VStack {
          Spacer(minLength: 0)
          AppImageView(appImage: appIcon, size: NSSize(width: 15, height: 15))
          Spacer(minLength: 0)
        }
        .padding(.leading, style == .card ? 0 : 4)
        .padding(.vertical, 5)
      }

      Spacer()
        .frame(width: showIcons ? 5 : (style == .card ? 0 : 10))

      if let accessoryImage {
        Image(nsImage: accessoryImage)
          .accessibilityIdentifier("copy-history-item")
          .padding(.trailing, 5)
          .padding(.vertical, 5)
      }

      if let image {
        Image(nsImage: image)
          .accessibilityIdentifier("copy-history-item")
          .padding(.trailing, 5)
          .padding(.vertical, 5)
      } else {
        ListItemTitleView(
          attributedTitle: attributedTitle,
          lineLimit: titleLineLimit,
          title: title
        )
          .padding(.trailing, 5)
      }

      Spacer()

      HStack(spacing: 5) {
        if let index = selectionIndex {
          Text("\(index + 1)")
            .font(.caption)
            .frame(minWidth: 10, alignment: .center)
            .padding(3)
            .background(
              Color.secondary.opacity(isSelected ? 0.5 : 0.8),
              in: Capsule()
            )
            .foregroundStyle(Color.white)
        }

        if !shortcuts.isEmpty {
          ZStack(alignment: .trailing) {
            ForEach(shortcuts) { shortcut in
              let visible = shortcut.isVisible(shortcuts, modifierFlags.flags)
              KeyboardShortcutView(shortcut: shortcut)
                .opacity(visible ? 1 : 0)
                .frame(width: visible ? nil : 0)
            }
          }
        }
      }
      .padding(.trailing, style == .card ? 0 : 10)
    }
    .padding(.horizontal, horizontalContentPadding)
    .padding(.vertical, style == .card ? 8 : 0)
    .frame(minHeight: minimumHeight)
    .id(id)
    .frame(maxWidth: .infinity, alignment: .leading)
    .hoverSelectionId(selectionId)

    if style == .card {
      row
        .foregroundStyle(Color.primary)
        .background(
          isSelected
            ? Color.accentColor.opacity(0.16)
            : Color(nsColor: .controlBackgroundColor).opacity(0.72),
          in: RoundedRectangle(cornerRadius: Popup.cornerRadius, style: .continuous)
        )
        .overlay {
          RoundedRectangle(cornerRadius: Popup.cornerRadius, style: .continuous)
            .stroke(
              isSelected
                ? Color.accentColor
                : Color(nsColor: .separatorColor).opacity(0.55),
              lineWidth: isSelected ? 1.5 : 1
            )
        }
        .contentShape(RoundedRectangle(cornerRadius: Popup.cornerRadius, style: .continuous))
        .help(help ?? "")
    } else {
      row
        .foregroundStyle(isSelected ? Color.white : .primary)
        // macOS 26 broke hovering if no background is present.
        // The slight opacity white background is a workaround.
        .background(isSelected ? Color.accentColor.opacity(0.8) : .white.opacity(0.001))
        .clipShape(selectionAppearance.rect(cornerRadius: Popup.cornerRadius))
        .help(help ?? "")
    }
  }
}
