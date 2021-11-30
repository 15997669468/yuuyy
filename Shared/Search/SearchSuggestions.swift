import SwiftUI

struct SearchSuggestions: View {
    @EnvironmentObject<RecentsModel> private var recents
    @EnvironmentObject<SearchModel> private var state

    var body: some View {
        List {
            Button {
                state.changeQuery { query in
                    query.query = state.queryText
                    state.fieldIsFocused = false
                }

                recents.addQuery(state.queryText)
            } label: {
                HStack(spacing: 5) {
                    Label(state.queryText, systemImage: "magnifyingglass")
                        .lineLimit(1)
                }
            }
            #if os(macOS)
            .onHover(perform: onHover(_:))
            #endif

            ForEach(visibleSuggestions, id: \.self) { suggestion in
                Button {
                    state.queryText = suggestion
                } label: {
                    HStack(spacing: 0) {
                        Label(state.queryText, systemImage: "arrow.up.left.circle")
                            .lineLimit(1)
                            .layoutPriority(2)
                            .foregroundColor(.secondary)

                        Text(querySuffix(suggestion))
                            .lineLimit(1)
                            .layoutPriority(1)
                    }
                }
                #if os(macOS)
                .onHover(perform: onHover(_:))
                #endif
            }
        }
        #if os(macOS)
        .buttonStyle(.link)
        #endif
    }

    private var visibleSuggestions: [String] {
        state.querySuggestions.collection.filter {
            $0.compare(state.queryText, options: .caseInsensitive) != .orderedSame
        }
    }

    private func querySuffix(_ suggestion: String) -> String {
        suggestion.replacingFirstOccurrence(of: state.queryText.lowercased(), with: "")
    }

    #if os(macOS)
        private func onHover(_ inside: Bool) {
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    #endif
}

struct SearchSuggestions_Previews: PreviewProvider {
    static var previews: some View {
        SearchSuggestions()
            .injectFixtureEnvironmentObjects()
    }
}
