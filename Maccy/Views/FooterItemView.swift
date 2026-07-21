import SwiftUI

struct FooterItemView: View {
  @Bindable var item: FooterItem
  @Environment(AppState.self) private var appState

  private var systemImage: String {
    switch item.title {
    case "clear", "clear_all":
      return "trash"
    case "preferences":
      return "gearshape"
    case "about":
      return "info.circle"
    case "quit":
      return "power"
    default:
      return "ellipsis"
    }
  }

  var body: some View {
    ConfirmationView(item: item) {
      Image(systemName: systemImage)
        .font(.system(size: 13, weight: .medium))
        .symbolRenderingMode(.hierarchical)
        .frame(maxWidth: .infinity)
        .frame(height: 26)
        .foregroundStyle(item.isSelected ? Color.accentColor : Color.secondary)
        .contentShape(Rectangle())
        .hoverSelectionId(item.id)
        .accessibilityLabel(Text(LocalizedStringKey(item.title)))
        .help(item.help ?? LocalizedStringKey(item.title))
    }
    .onHover { hovering in
      if hovering && appState.preview.state.isOpen {
        appState.preview.togglePreview()
      }
    }
  }
}
