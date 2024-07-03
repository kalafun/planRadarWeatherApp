//
//  CitiesView.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import CoreData
import SwiftUI

struct CitiesView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @State var showsSearchCitiesView = false
    @State var showsHistoricalView = false
    @State var weatherDetailCity: City?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \City.createdAt, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<City>

    var body: some View {
        List {
            ForEach(items) { item in
                HStack(spacing: 20) {
                    HStack() {
                        Text(item.name ?? "")
                            .foregroundStyle(Styler.Color.title)
                            .font(.system(size: 17, weight: .bold))
                            .listRowSeparatorTint(Styler.Color.button)

                        Spacer()
                    }
                    .background()
                    .onTapGesture {
                        weatherDetailCity = item
                    }

                    Button {
                        showsHistoricalView = true
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Styler.Color.subtitle)
                    }
                }
                //                        Text(item.timestamp!, formatter: itemFormatter)
            }
            //            .onDelete(perform: deleteItems)
        }
        .padding(.top, 38)
        .listStyle(.plain)
        .navigationTitle("CITIES")
        .navigationBarTitleTextColor(Styler.Color.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 0) {
                            Image("Button_right")
                                .offset(x: 16, y: 24)
                            Spacer()
                        }
                    }

                    Button {
                        showsSearchCitiesView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .offset(x: 24)
                    .tint(Styler.Color.button)
                }
            }
        }
        .navigationDestination(item: $weatherDetailCity) { city in
            WeatherDetailView(
                viewModel: WeatherDetailView.ViewModel(
                    moc: viewContext,
                    city: city
                )
            )
        }
        .sheet(isPresented: $showsSearchCitiesView) {
            NavigationStack {
                SearchCitiesView(viewModel: SearchCitiesView.ViewModel(moc: viewContext))
            }
        }
        .sheet(isPresented: $showsHistoricalView) {
            Text("Historical View is going to be here")
        }
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

#Preview {
    NavigationStack {
        CitiesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}
