import Repeat
import SwiftUI

struct SearchTextField: View {
    @Environment(\.navigationStyle) private var navigationStyle

    @EnvironmentObject<NavigationModel> private var navigation
    @EnvironmentObject<RecentsModel> private var recents
    @EnvironmentObject<SearchModel> private var state

    @Binding var queryText: String
    @Binding var favoriteItem: FavoriteItem?

    private var queryDebouncer = Debouncer(.milliseconds(800))

    init(
        queryText: Binding<String>,
        favoriteItem: Binding<FavoriteItem?>? = nil
    ) {
        _queryText = queryText
        _favoriteItem = favoriteItem ?? .constant(nil)
    }

    var body: some View {
        ZStack {
            #if os(macOS)
                fieldBorder
            #endif

            HStack(spacing: 0) {
                #if os(macOS)
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                        .padding(.horizontal, 8)
                        .opacity(0.8)
                #endif
                TextField("Search...", text: $queryText) {
                    state.changeQuery { query in
                        query.query = state.queryText
                        navigation.hideKeyboard()
                    }
                    recents.addQuery(state.queryText, navigation: navigation)
                }
                .disableAutocorrection(true)
                .onChange(of: state.suggestionSelection) { newValue in
                    self.queryText = newValue
                }
                .onChange(of: queryText) { newValue in
                    queryDebouncer.callback = {
                        DispatchQueue.main.async {
                            state.queryText = newValue
                        }
                    }
                    queryDebouncer.call()
                }
                #if os(macOS)
                .frame(maxWidth: 190)
                .textFieldStyle(.plain)
                #else
                .textFieldStyle(.roundedBorder)
                .padding(.leading)
                .padding(.trailing, 15)
                #endif

                if !self.state.queryText.isEmpty {
                    #if os(iOS)
                        FavoriteButton(item: favoriteItem)
                            .id(favoriteItem?.id)
                            .labelStyle(.iconOnly)
                            .padding(.trailing)
                    #endif
                    clearButton
                } else {
                    #if os(macOS)
                        clearButton
                            .opacity(0)
                    #endif
                }
            }
        }
        .padding(.top, navigationStyle == .tab ? 10 : 0)
    }

    private var fieldBorder: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(Color.background)
            .frame(width: 250, height: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: 250, height: 31)
            )
    }

    private var clearButton: some View {
        Button(action: {
            queryText = ""
            self.state.queryText = ""
        }) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
            #if os(macOS)
                .frame(width: 14, height: 14)
            #else
                .frame(width: 18, height: 18)
            #endif
                .padding(.trailing, 3)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 10)
        .opacity(0.7)
    }
}
