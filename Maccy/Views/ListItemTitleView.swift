import SwiftUI

struct ListItemTitleView<Title: View>: View {
  var attributedTitle: AttributedString?
  var lineLimit: Int = 1
  @ViewBuilder var title: () -> Title

  var body: some View {
    if let attributedTitle {
      Text(attributedTitle)
        .accessibilityIdentifier("copy-history-item")
        .lineLimit(lineLimit)
        .truncationMode(.middle)
    } else {
      title()
        .accessibilityIdentifier("copy-history-item")
        .lineLimit(lineLimit)
        .truncationMode(.middle)
        // Workaround for macOS 26 to avoid flipped text
        // https://github.com/p0deje/Maccy/issues/1113
        .drawingGroup()
    }
  }
}
