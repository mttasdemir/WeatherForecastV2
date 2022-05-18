//
//  ForecastView.swift
//  WeatherForecast2
//
//  Created by Mustafa Taşdemir on 11.05.2022.
//

import SwiftUI

struct ForecastView: View {
    let rowGradient = LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom)
    let linearGradient = LinearGradient(colors: [.white, .blue], startPoint: .top, endPoint: .bottom)
    @State private var temp: Array<City> = []
    
    @State private var unit: Int = 1
    @State private var newCity: String = ""
    @State private var editMode: EditMode = .inactive
    @State private var isAddingCity: Bool = false
    @ObservedObject var forecastController: ForecastController
    
    @State private var error: Error?
    
    init(forecastController: ForecastController) {
        self.forecastController = forecastController
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(forecastController.cities) { city in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(rowGradient)
                        ForecastRow(city: city)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: { forecastController.remove(city) }, label: { Image(systemName: "trash.fill")})
                    }
                }
                .onDelete { index in
                    forecastController.cities.remove(atOffsets: index)
                }
                .onMove { (from, to) in
                    forecastController.cities.move(fromOffsets: from, toOffset: to)
                }
                .listRowBackground(EmptyView())
                .listRowSeparator(.hidden)
            }
            .environment(\.editMode, $editMode)
            .background(linearGradient)
            .ignoresSafeArea()
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing || isAddingCity {
                        Button("Done") {
                            editMode = .inactive
                            if isAddingCity {
                                newCity = newCity.isEmpty ? forecastController.allCities.first! : newCity
                                Task {
                                    do {
                                        try await forecastController.addCity(newCity)
                                    } catch {
                                        self.error = error
                                    }
                                }
                                isAddingCity = false
                            }
                        }
                    } else {
                        contextMenu
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditing || isAddingCity {
                        Button("Cancel") {
                            editMode = .inactive
                            isAddingCity = false
                            forecastController.cities = temp
                        }
                    }
                }
            }
        }
        .overlay {
            citySelectMenu
        }
        .alert("Error", isPresented: .constant(error == nil ? false : true)) {
            Button("Ok") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
        .refreshable {
            await forecastController.refreshForecast()
        }
    }
       
    var citySelectMenu: some View {
        Group {
            if isAddingCity {
                VStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxHeight: 150)
                        Picker("City", selection: $newCity) {
                            ForEach(forecastController.allCities, id: \.self) { city in
                                Text(city).font(.title).fontWeight(.semibold)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    
    var isEditing: Bool {
        editMode == .active ? true : false
    }
    
    var contextMenu: some View {
        Menu {
            Button {
                temp = forecastController.cities
                editMode = .active
            } label: { Label("Edit", systemImage: "pencil") }
            Picker("Unit", selection: $unit) {
                Text("Celsius").tag(1)
                Text("Fahrenheit").tag(2)
            }
            Button {
                temp = forecastController.cities
                isAddingCity = true
                newCity = ""
            } label: { Label("Add City", systemImage: "plus.circle") }
            .disabled(forecastController.allCities.count == 0)
        } label: { Image(systemName: "ellipsis.circle") }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(forecastController: ForecastController())
    }
}
