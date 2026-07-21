import SwiftUI

struct PinsView: View {
  @Environment(AppState.self) private var appState

  var items: [HistoryItemDecorator]

  var body: some View {
    MultipleSelectionListView(items: items, spacing: Popup.itemSpacing) { previous, item, next, index in
      HistoryItemView(item: item, previous: previous, next: next, index: index)
    }
  }
}
