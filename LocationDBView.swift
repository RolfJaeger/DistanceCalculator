//
//  LocationDBView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 1/29/26.
//

import SwiftUI
import CoreLocation

struct LocationDBView: View {
    
    @Binding var viewFormat: ViewFormat
    
    @State var locations: [Location] = [Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0), name: "Test1"),Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test2"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test3"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test4"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test5"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test6"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test7"), Location(coordinate: CLLocationCoordinate2D(latitude: 38.0, longitude: -122.0), name: "Test8")
        ]
    
    @State var codableLocations: [CodableLocation] = [
        /*
        CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test1"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test2"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test3"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test4"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test5"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test6"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test7"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test8"), CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test9"),
         */
            ]
    @State var selectedLocation = Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0), name: "Test Location")

    @State var selectedCodableLocation = CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0)), name: "Test1")

    @State var showSaveLocationView = false
    @State var nameOfLocationToSave = ""
    @FocusState private var nameIsFocused: Bool
    
    var txtSwitchFormat: String {
        switch viewFormat {
        case .DMS:
            return "Switch to Raymarine Format"
        case .DDM:
            return "Switch to Deg Min Sec"
        case .Raymarine:
            return "Switch to Decimal Degress"
        }
    }
    
    init(viewFormat: Binding<ViewFormat>) {
        _viewFormat = viewFormat
        _locations = State(initialValue: [Location]())
        _codableLocations = State(initialValue: restoreSavedLocations())
    }
    
    var body: some View {
        VStack {
            Text("Location Vault")
                .font(.title)
                .bold()
            FormatView
            Text("Current Location:")
            HStack {
                Text(DegreesToStringInSelectedFormat(degrees: selectedLocation.coordinate.latitude, viewFormat: viewFormat))
                Text(DegreesToStringInSelectedFormat(degrees: selectedLocation.coordinate.longitude, viewFormat: viewFormat))
            }
            if !showSaveLocationView {
                Button(action: {
                    showSaveLocationView.toggle()
                }, label: {
                    Text("Save in Database")
                })
            } else {
                SaveLocationView
            }
            Text("Location Database")
                .padding(.top,20)
                .font(.headline)
                .bold()
            if codableLocations.count == 0 {
                Text("You have not saved any locations yet.")
                    .padding(.top, 0)
            } else {
                VStack {
                    List{
                        ForEach(codableLocations, id: \.self) { location in
                            HStack {
                                Spacer()
                                Text(location.name)
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    Button(action: {
                        useSelectedLocation()
                    }, label: {
                        Text("Use selected location.")
                    })
                    .buttonStyle(.bordered)
                }
            }
            Spacer()
        }
    }
    
    fileprivate var FormatView: some View {
        VStack {
            VStack {
                Text("Location Format")
                    .bold()
                switch viewFormat {
                case .DMS:
                    Text("Degrees | Minutes | Seconds")
                case .DDM:
                    Text("Decimal Degrees")
                case .Raymarine:
                    Text("Degrees | Decimal Minutes")
                }
            }
            Button(action: {
                switch viewFormat {
                case .DMS:
                    viewFormat = .Raymarine
                case .DDM:
                    viewFormat = .DMS
                case .Raymarine:
                    viewFormat = .DDM
                }
            }, label: {Text(txtSwitchFormat)})
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var SaveLocationView: some View {
        VStack {
            Text("Name of Location:")
            TextField("Enter more than 5 Characters", text: $nameOfLocationToSave)
                .focused($nameIsFocused)
                .font(.title3)
                .frame(maxWidth: 200.0, alignment: .center) // Expands the frame and centers the content
                .border(Color.gray)
                .multilineTextAlignment(.center)
            if nameOfLocationToSave.count >= 5 {
                if !isNameInLocationDatabase(name: nameOfLocationToSave) {
                    Button(action: {
                        saveLocationInDatabase(location: selectedCodableLocation, nameOfLocationToSave: nameOfLocationToSave)
                        nameIsFocused = false
                        showSaveLocationView.toggle()
                    }, label: {
                        Text("Save with this name")
                    })
                    .buttonStyle(.bordered)
                    
                } else {
                    Button(action: {
                        replaceLocationInDatabase(location: selectedCodableLocation, nameOfLocationToSave: nameOfLocationToSave)
                        nameIsFocused = false
                        showSaveLocationView.toggle()
                    }, label: {
                        Text("Replace existing location.")
                            .foregroundColor(.red)
                    })
                    .buttonStyle(.bordered)
                }
            }
        }
        
    }
    
    fileprivate func removeDuplicateLocations(cLocs: [CodableLocation]) -> [CodableLocation] {
        var uniqueLocs = [CodableLocation]()
        for cLoc in cLocs {
            if isLocationAlreadyInDatabase(loc: cLoc, cLocs: uniqueLocs) != true {
                uniqueLocs.append(cLoc)
            }
        }
        return uniqueLocs
    }
    
    fileprivate func deleteItems(at offsets: IndexSet) {
        codableLocations.remove(atOffsets: offsets)
    }
    
    fileprivate func isLocationAlreadyInDatabase(loc: CodableLocation, cLocs: [CodableLocation]) -> Bool {
        for cLoc in cLocs {
            if cLoc.coordinate.latitude == loc.coordinate.latitude && cLoc.coordinate.longitude == loc.coordinate.longitude {
                return true
            }
        }
        return false
    }
    
    fileprivate func isNameInLocationDatabase(name: String) -> Bool {
        for location in locations {
            if location.name == name {
                return true
            }
        }
        return false
    }
    
    fileprivate func saveLocationInDatabase(location: CodableLocation, nameOfLocationToSave: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let newLocation = CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: selectedCodableLocation.coordinate.latitude, longitude: selectedCodableLocation.coordinate.longitude)), name: nameOfLocationToSave)
        codableLocations.append(newLocation)
        codableLocations = codableLocations.sorted { $0.name < $1.name}
        @AppStorage("MyLocations") var locationsStore: Data = Data()
        do {
            let jsonData = try encoder.encode(codableLocations)
            locationsStore = jsonData
        } catch {
            print("Encoding Error")
        }
    }

    fileprivate func restoreSavedLocations() -> [CodableLocation] {
        var c = [CodableLocation]()
        @AppStorage("MyLocations") var locationsStore: Data = Data()
        if let savedLocations = try? JSONDecoder().decode([CodableLocation].self, from: locationsStore) {
            c = savedLocations.sorted { $0.name < $1.name }
            c = removeDuplicateLocations(cLocs: c)

        }
        return c
    }
    
    fileprivate func replaceLocationInDatabase(location: CodableLocation, nameOfLocationToSave: String) {
    }

    fileprivate func useSelectedLocation() {
        
    }
}

#Preview {
    @Previewable @State var viewFormat: ViewFormat = .Raymarine
    LocationDBView(viewFormat: $viewFormat)
}

