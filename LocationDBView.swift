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
    @Binding var currentLocation: Location

    @State var showAlert = false
    @State var txtAlert = ""
    
    @State var codableLocations: [CodableLocation] = []
    @State var selectedCodableLocation: CodableLocation?

    @State private var isLocationAlreadyInDB = false
    @State private var isLocationSaved = false
    
    @State var showSaveLocationView = false
    @State var nameOfLocationToSave = ""
    @FocusState private var nameIsFocused: Bool
    
    private var locationOnEntry: Location
    
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
    
    init(viewFormat: Binding<ViewFormat>, currentLocation: Binding<Location>) {
        _viewFormat = viewFormat
        _currentLocation = currentLocation
        locationOnEntry = currentLocation.wrappedValue
        _codableLocations = State(initialValue: restoreSavedLocations())
        // Use for debugging GUI
        //_codableLocations = State(initialValue: initializeLongLocationsList())
    }
    
    var body: some View {
        VStack {
            Text("Location Database")
                .font(.title)
                .bold()
            SwitchFormatView
            CurrentLocationView
            DealWithSaveIntention
            if selectedCodableLocation != nil {
                SelectedLocationView
            }
            if showAlert {
                UserAlert
            }
            SavedLocationsView
            ControlButtons
            Spacer()
        }
    }
    
    fileprivate var SwitchFormatView: some View {
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

    fileprivate var CurrentLocationView: some View {
        VStack {
            Text("Current Location:")
            HStack {
                Text(DegreesToStringInSelectedFormat(degrees: currentLocation.coordinate.latitude, viewFormat: viewFormat))
                Text(DegreesToStringInSelectedFormat(degrees: currentLocation.coordinate.longitude, viewFormat: viewFormat))
            }
        }
    }

    fileprivate var DealWithSaveIntention: some View {
        VStack {
            if !isLocationAlreadyInDB {
                if !showSaveLocationView {
                    Button(action: {
                        showSaveLocationView.toggle()
                    }, label: {
                        Text("Save in Database")
                    })
                } else {
                    if !isLocationSaved {
                        SaveLocationView
                    }
                }
            }
        }
    }
    
    fileprivate var SelectedLocationView: some View {
        VStack {
            Text(selectedCodableLocation!.name)
            HStack {
                Text(DegreesToStringInSelectedFormat(degrees: selectedCodableLocation!.coordinate.latitude, viewFormat: viewFormat))
                Text(DegreesToStringInSelectedFormat(degrees: selectedCodableLocation!.coordinate.longitude, viewFormat: viewFormat))
            }
        }
        .padding(.top, 5)
    }
    
    fileprivate var SavedLocationsView: some View {
        VStack {
            if codableLocations.count == 0 {
                Text("You have not saved any locations yet.")
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Saved Locations")
                    .padding(.top,5)
                    .font(.headline)
                    .bold()
                VStack {
                    List {
                        ForEach(codableLocations, id: \.self) { location in
                        HStack {
                            Spacer()
                            Text(location.name)
                                .tag(location.id)
                            Spacer()
                        }
                        .frame(height: 10)
                        .onTapGesture {
                            selectedCodableLocation = CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), name: location.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    }
                    .environment(\.defaultMinListRowHeight, 10)
                    .listStyle(.plain)
                }
            }
        }
    }
    
    fileprivate var SaveLocationView: some View {
        VStack {
            Text("Name of Location:")
            TextField("5 characters or more", text: $nameOfLocationToSave)
                .focused($nameIsFocused)
                .font(.body)
                .frame(maxWidth: 200.0, alignment: .center) // Expands the frame and centers the content
                .border(Color.gray)
                .multilineTextAlignment(.center)
            if !isNameInLocationDatabase(name: nameOfLocationToSave) {
                Button(action: {
                    if nameOfLocationToSave.count >= 5 {
                        saveLocationInDatabase(location: currentLocation, nameOfLocation: nameOfLocationToSave)
                        nameIsFocused = false
                        showSaveLocationView.toggle()
                    } else {
                        txtAlert = "Too short."
                        showAlert = true
                    }
                }, label: {
                    Text("Save with this name")
                })
                .buttonStyle(.bordered)
                
            } else {
                if locationInDatabaseWithThisNameHasSameCoordinates(loc: currentLocation, nameToSave: nameOfLocationToSave, cLocs: codableLocations) {
                    Text("Already in your database")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Button(action: {
                        replaceLocationInDatabase(location: currentLocation, nameOfLocation: nameOfLocationToSave)
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
    
    fileprivate var ControlButtons: some View {
        VStack {
            if selectedCodableLocation != nil {
                Button(action: {
                    currentLocation = Location(coordinate: CLLocationCoordinate2D(latitude: selectedCodableLocation!.coordinate.latitude, longitude: selectedCodableLocation!.coordinate.longitude), name: currentLocation.name)
                    selectedCodableLocation = nil
                    isLocationAlreadyInDB = true
                }, label: { Text("Use Selected Location") })
                .buttonStyle(.bordered)
                HStack {
                    Button(action: {
                        selectedCodableLocation = nil
                        showSaveLocationView = false
                    }, label: { Text("Clear") })
                    .buttonStyle(.bordered)
                }
            }
            if !isSameCoordinate(loc1: currentLocation, loc2: locationOnEntry) {
                Button(action: {
                    currentLocation = locationOnEntry
                    showSaveLocationView = true
                    selectedCodableLocation = nil
                }, label: { Text("Restore") })
                .buttonStyle(.bordered)
            }
        }
    }
    
    fileprivate var UserAlert: some View {
        VStack {
            Text(txtAlert)
                .font(.caption)
                .foregroundColor(.black)
                .bold()
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button(action: {
                    showAlert = false
                }) {
                    Text("Ok")
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)

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
        //Must still save codableLocations
        let encoder = JSONEncoder()
        @AppStorage("MyLocations") var locationsStore: Data = Data()
        do {
            let jsonData = try encoder.encode(codableLocations)
            locationsStore = jsonData
            isLocationAlreadyInDB = false
            showSaveLocationView = false
            selectedCodableLocation = nil
        } catch {
            txtAlert = "An error occurred; unable to delete."
            showAlert = true
        }
    }
    
    fileprivate func isLocationAlreadyInDatabase(loc: CodableLocation, cLocs: [CodableLocation]) -> Bool {
        for cLoc in cLocs {
            if cLoc.coordinate.latitude == loc.coordinate.latitude && cLoc.coordinate.longitude == loc.coordinate.longitude {
                return true
            }
        }
        return false
    }
    
    fileprivate func nameOfLocationInDatabase(loc: Location, cLocs: [CodableLocation]) -> String {
        for cLoc in cLocs {
            if cLoc.coordinate.latitude == loc.coordinate.latitude && cLoc.coordinate.longitude == loc.coordinate.longitude {
                return cLoc.name
            }
        }
        return ""
    }
    
    fileprivate func locationInDatabaseWithThisNameHasSameCoordinates(loc: Location, nameToSave: String, cLocs: [CodableLocation]) -> Bool {
        for cLoc in cLocs {
            if cLoc.name == nameToSave {
                if cLoc.coordinate.latitude == loc.coordinate.latitude && cLoc.coordinate.longitude == loc.coordinate.longitude {
                    return true
                }

            }
        }
        return false
    }
    

    fileprivate func isNameInLocationDatabase(name: String) -> Bool {
        for location in codableLocations {
            if location.name == name {
                return true
            }
        }
        return false
    }
    
    fileprivate func isSameCoordinate(loc1: Location, loc2: Location) -> Bool {
        let lat1 = loc1.coordinate.latitude
        let long1 = loc1.coordinate.longitude
        let lat2 = loc2.coordinate.latitude
        let long2 = loc2.coordinate.longitude
        return lat1 == lat2 && long1 == long2
    }
    
    fileprivate func saveLocationInDatabase(location: Location, nameOfLocation: String) {
        let nameOfLocationInDB = nameOfLocationInDatabase(loc: location, cLocs: codableLocations)
        if nameOfLocationInDB != "" {
            isLocationAlreadyInDB = true
            txtAlert = "This location is already in database as '\(nameOfLocationInDB)"
            showAlert = true
            return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let newLocation = CodableLocation(coordinate: CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)), name: nameOfLocation)
        codableLocations.append(newLocation)
        codableLocations = codableLocations.sorted { $0.name < $1.name}
        @AppStorage("MyLocations") var locationsStore: Data = Data()
        do {
            let jsonData = try encoder.encode(codableLocations)
            locationsStore = jsonData
            showSaveLocationView.toggle()
            nameOfLocationToSave = ""
            isLocationSaved = true
        } catch {
            txtAlert = "An error occurred; unable to save."
            showAlert = true
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
    
    fileprivate func replaceLocationInDatabase(location: Location, nameOfLocation: String) {
        for i in 0..<codableLocations.count {
            if codableLocations[i].name == nameOfLocation {
                codableLocations[i].coordinate.latitude = location.coordinate.latitude
                codableLocations[i].coordinate.longitude = location.coordinate.longitude
            }
        }
        let encoder = JSONEncoder()
        @AppStorage("MyLocations") var locationsStore: Data = Data()
        do {
            let jsonData = try encoder.encode(codableLocations)
            locationsStore = jsonData
            showSaveLocationView.toggle()
            nameOfLocationToSave = ""
            isLocationSaved = true
            selectedCodableLocation = nil
        } catch {
            txtAlert = "An error occurred; unable to save."
            showAlert = true
        }
    }

    fileprivate func initializeLongLocationsList() -> [CodableLocation] {
        var cList = [CodableLocation]()
        let nCount = 15
        let cCoord = CodableCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0))
        for i in 0..<nCount {
            let cLoc = CodableLocation(coordinate: cCoord, name: "Test\(i+1)")
            cList.append(cLoc)
        }
        return cList
    }
}

#Preview {
    @Previewable @State var viewFormat: ViewFormat = .Raymarine
    @Previewable @State var location: Location = Location(coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: -120.0), name: "Test Loc")
    LocationDBView(viewFormat: $viewFormat, currentLocation: $location)
}
