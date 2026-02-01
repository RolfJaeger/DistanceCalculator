//
//  DistanceView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 12/18/25.
//

/*
TODO List:
 - Show alert when user taps 'Hemisphere'
 */

/*
Expected values (for changes in Latitude):
 - Degrees | Decimal Minutes (Raymarine) View:
    0.001 minutes = 0.001 nm
 - Degrees | Minutes | Seconds (DMS) View:
    1 second = 1/60 of 1 minute = 1/60 nm = 0.0166 nm
 - Decimal Degrees View:
    0.001 degrees = 1/1000 of 60nm = 0.06 nm
 */

import SwiftUI
import CoreLocation

struct DistanceView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass

    @ObservedObject var locationManager = LocationManager()
    
    //@Binding var Location1: Location
    @State var Location1 = Location(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "Location 1")
    @State var Location2 = Location(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "Location 2")
        
    @State var viewFormat: ViewFormat

    @State var loc1LatViewVisible = false
    @State var loc1LongViewVisible = false
    @State var loc2LatViewVisible = false
    @State var loc2LongViewVisible = false

    @State var NortSouthLoc1 = "S"
    @State var EastWestLoc1 = "E"
    @State var NortSouthLoc2 = "N"
    @State var EastWestLoc2 = "E"

    @State var hintVisible = true
    @State private var showDialog = false

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
    
    init(viewFormat: ViewFormat) {
        self.locationManager = LocationManager()
        // Initialize bindings and state wrappers first
        self._viewFormat = State(initialValue: viewFormat)

        // Now safe to use the already-initialized properties
        if let userLocation = self.locationManager.lastKnownLocation {
            // Round to 3 places
            let lat1 = Double(userLocation.latitude).rounded(toPlaces: 3)
            let lon1 = Double(userLocation.longitude).rounded(toPlaces: 3)
            let detectedLoc1 = Location(coordinate: CLLocationCoordinate2D(latitude: lat1, longitude: lon1), name: "Location 1")
            self._Location1 = State(initialValue: detectedLoc1)
            let detectedLoc2 = Location(coordinate: CLLocationCoordinate2D(latitude: lat1, longitude: lon1), name: "Location 2")
            self._Location2 = State(initialValue: detectedLoc2)
            // Update backing state wrapper correctly

            self._NortSouthLoc1 = lat1 < 0 ? State(initialValue: "S") : State(initialValue: "N")
            self._EastWestLoc1 = lon1 < 0 ? State(initialValue: "W") : State(initialValue: "E")
            self._NortSouthLoc2 = lat1 < 0 ? State(initialValue: "S") : State(initialValue: "N")
            self._EastWestLoc2 = lon1 < 0 ? State(initialValue: "W") : State(initialValue: "E")
            
        } else {
            // Default values when no location available
            // Keep existing Location1 as provided by binding; only reset second location
            self.NortSouthLoc2 = "N"
            // keep East/West for loc1 as-is
            self.EastWestLoc2 = "E"
            self.hintVisible = false
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if sizeClass == .regular {
                        MainView_iPad
                    } else {
                        MainView
                    }
                }
                if showDialog {
                    UserDialog
                }
            }
        }
    }
    
    fileprivate var MainView: some View {
        VStack {
            Text("Plotting Helper")
                .font(.title)
                .bold()
                .padding()
            FormatView
                .padding(.bottom, 10)
            Text("Distance")
                .font(.title2)
                .bold()
                .padding(.bottom, 0)
            DistanceView
            Button(action: {
                if let userLocation = locationManager.lastKnownLocation {
                    Location1.coordinate.latitude = userLocation.latitude.rounded(toPlaces: 3)
                    Location1.coordinate.longitude = userLocation.longitude.rounded(toPlaces: 3)
                }
            }, label: {
                Text("Location 1")
                    .font(.title2)
                    .bold()
            })
            .buttonStyle(.bordered)
            .padding(.top, 10)
            .padding(.bottom, 5)
            Location1Details
            Button(action: {
                if let userLocation = locationManager.lastKnownLocation {
                    Location2.coordinate.latitude = userLocation.latitude.rounded(toPlaces: 3)
                    Location2.coordinate.longitude = userLocation.longitude.rounded(toPlaces: 3)
                }
            }, label: {
                Text("Location 2")
                    .font(.title2)
                    .bold()
            })
            .buttonStyle(.bordered)
            .padding(.top, 10)
            .padding(.bottom, 5)
            Location2Details
            
            HintView
            Spacer()
            NavigationLink(
                destination:
                    LocationsOnMap(
                        Location1: $Location1,Location2: $Location2,
                        latSpan: calcLatDelta(),
                        longSpan: calcLongDelta()
                    ),
                label: {
                Text("Show Locations on Map")
                    .font(.title3)
                    .padding(.top, 20)
            })

        }
    }

    fileprivate var MainView_iPad: some View {
        VStack {
            Text("Plotting Helper")
                .font(Font.system(size: 60, weight: .bold, design: .default))
                .font(.title)
                .bold()
                .padding()
            FormatView_iPad
                .padding(.bottom, 10)
            Text("Distance")
                .font(Font.system(size: 40, weight: .bold, design: .default))
                .bold()
                .padding(.bottom, 0)
            DistanceView_iPad
            Text("Location 1")
                .font(Font.system(size: 40, weight: .bold, design: .default))
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location1Details_iPad
            Text("Location 2")
                .font(Font.system(size: 40, weight: .bold, design: .default))
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location2Details_iPad
            
            HintView_iPad
            Spacer()
            NavigationLink(
                destination:
                    LocationsOnMap(
                        Location1: $Location1,Location2: $Location2,
                        latSpan: calcLatDelta(),
                        longSpan: calcLongDelta()
                    ),
                label: {
                Text("Show Locations on Map")
                    .font(Font.system(size: 30, weight: .bold, design: .default))
                    .padding(.top, 20)
                    .padding(.bottom, 20)
            })

        }
    }

    fileprivate var HintView: some View {
        VStack {
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
                if hintVisible {
                    Text("Initially your location is shown.")
                        .padding(.top, 20)
                    Text("Tap coordinates to modify")
                    Text("or tap the location buttons to ping.")
                }
            }
        }
    }
    
    fileprivate var HintView_iPad: some View {
        VStack {
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
                if hintVisible {
                    Text("Initially your location is shown.")
                        .padding(.top, 20)
                    Text("Tap coordinates to modify.")
                }
            }
        }
        .font(Font.system(size: hintFont, weight: .regular, design: .default))
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
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
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
    }

    fileprivate var FormatView_iPad: some View {
        VStack {
            VStack {
                Text("Location Format")
                    .font(Font.system(size: subtitleFont, weight: .bold, design: .default))
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
            .font(Font.system(size: subtitleFont, weight: .regular, design: .default))
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
                Button(action: {
                    switch viewFormat {
                    case .DMS:
                        viewFormat = .Raymarine
                    case .DDM:
                        viewFormat = .DMS
                    case .Raymarine:
                        viewFormat = .DDM
                    }
                }, label: {
                    Text(txtSwitchFormat)
                        .font(Font.system(size: buttonFont - 10.0, weight: .regular, design: .default))
                })
                .buttonStyle(.bordered)
            }
        }
    }

    fileprivate var Loc1Minimized: some View {
        HStack {
            Spacer()
            if Location1.coordinate.latitude < 0 {
                Text("S")
            } else {
                Text("N")
            }
            Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Lat)
                }
            Text(" | ")
            if Location1.coordinate.longitude < 0 {
                Text("W")
            } else {
                Text("E")
            }
            Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.longitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Long)
                    
                }
            Spacer()
        }
        .font(.title2)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    fileprivate var Loc1Minimized_iPad: some View {
        HStack {
            Spacer()
            if Location1.coordinate.latitude < 0 {
                Text("S")
            } else {
                Text("N")
            }
            Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Lat)
                }
            Text(" | ")
            if Location1.coordinate.longitude < 0 {
                Text("W")
            } else {
                Text("E")
            }
            Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.longitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc1Long)
                }
            Spacer()
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    fileprivate var TopButtons: some View {
        HStack {
            Spacer()
            Button(action: {
                showDialog = true
            }, label: {
                Text("Hemisphere")
            })
            .buttonStyle(.bordered)
            Text(" | ")
            MinimizeButton
            Spacer()
        }
        .padding(.top, 10)
    }
    
    fileprivate var TopButtons_iPad: some View {
        HStack {
            Spacer()
            Button(action: {
                showDialog = true
            }, label: {
                Text("Hemisphere")
            })
            .font(Font.system(size: 25, weight: .regular, design: .default))
            .buttonStyle(.bordered)
            Text(" | ")
            MinimizeButton_iPad
            Spacer()
        }
        .padding(.top, 10)
    }
    
    fileprivate var NorthSouth_Loc1: some View {
        VStack {
            if Location1.coordinate.latitude < 0 {
                Text("S")
            } else {
                Text("N")
            }
        }
    }
    
    fileprivate var NorthSouth_Loc2: some View {
        VStack {
            if Location2.coordinate.latitude < 0 {
                Text("S")
            } else {
                Text("N")
            }
        }
    }
    
    fileprivate var EastWest_Loc1: some View {
        VStack {
            if Location1.coordinate.longitude < 0 {
                Text("W")
            } else {
                Text("E")
            }
        }
    }
    
    fileprivate var EastWest_Loc2: some View {
        VStack {
            if Location2.coordinate.longitude < 0 {
                Text("W")
            } else {
                Text("E")
            }
        }
    }
    
    fileprivate var Loc1LatExpanded: some View {
        VStack {
            TopButtons
            HStack {
                Spacer()
                NorthSouth_Loc1
                Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.latitude, viewFormat: viewFormat))
                Spacer()
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 180)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 180)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 180)
            }
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Loc1LatExpanded_iPad: some View {
        VStack {
            TopButtons_iPad
            HStack {
                Spacer()
                NorthSouth_Loc1
                Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.latitude, viewFormat: viewFormat))
                Spacer()
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 280)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 280)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: NortSouthLoc1, locDegrees: $Location1.coordinate.latitude)
                    .frame(height: 280)
            }
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Loc1LongExpanded: some View {
        VStack {
            TopButtons
            HStack {
                Spacer()
                EastWest_Loc1
                Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc1LongViewVisible = false
                    }
                Spacer()
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 180)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 180)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 180)
            }
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Loc1LongExpanded_iPad: some View {
        VStack {
            TopButtons_iPad
            HStack {
                Spacer()
                EastWest_Loc1
                Text(DegreesToStringInSelectedFormat(degrees: Location1.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc1LongViewVisible = false
                    }
                Spacer()
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 280)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 280)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: EastWestLoc1, locDegrees: $Location1.coordinate.longitude)
                    .frame(height: 280)
            }
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Location1Details: some View {
        VStack {
            HStack {
                if !loc1LatViewVisible && !loc1LongViewVisible {
                    Loc1Minimized
                }
            }
            if loc1LatViewVisible {
                Loc1LatExpanded
            }
            
            if loc1LongViewVisible {
                Loc1LongExpanded
            }
        }
    }

    fileprivate var Location1Details_iPad: some View {
        VStack {
            HStack {
                if !loc1LatViewVisible && !loc1LongViewVisible {
                    Loc1Minimized_iPad
                }
            }
            if loc1LatViewVisible {
                Loc1LatExpanded_iPad
            }
            
            if loc1LongViewVisible {
                Loc1LongExpanded_iPad
            }
        }
    }

    fileprivate var Loc2Minimized: some View {
        HStack {
            Spacer()
            NorthSouth_Loc2
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Lat)
                }
            Text(" | ")
            EastWest_Loc2
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Long)
                }
            Spacer()
        }
        .font(.title2)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    fileprivate var Loc2Minimized_iPad: some View {
        HStack {
            Spacer()
            NorthSouth_Loc2
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Lat)
                }
            Text(" | ")
            EastWest_Loc2
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Long)
                }
            Spacer()
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }

    fileprivate var Loc2LatExpanded: some View {
        VStack {
            TopButtons
            HStack {
                NorthSouth_Loc2
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LatViewVisible = false
                    }
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 180)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 180)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 180)
            }
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Loc2LatExpanded_iPad: some View {
        VStack {
            TopButtons_iPad
            HStack {
                NorthSouth_Loc2
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LatViewVisible = false
                    }
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 280)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 280)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
                    .frame(height: 280)
            }
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Loc2LongExpanded: some View {
        VStack {
            TopButtons
            HStack {
                EastWest_Loc2
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LongViewVisible = false
                    }
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 180)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 180)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 180)
            }
        }
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Loc2LongExpanded_iPad: some View {
        VStack {
            TopButtons_iPad
            HStack {
                EastWest_Loc2
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LongViewVisible = false
                    }
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 280)
            case .DDM:
                DecimalDegreesEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 280)
            case .Raymarine:
                RaymarineFormatEntryView(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
                    .frame(height: 280)
            }
        }
        .font(Font.system(size: dataFont, weight: .regular, design: .default))
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }

    fileprivate var Location2Details: some View {
        VStack {
            HStack {
                if !loc2LatViewVisible && !loc2LongViewVisible {
                    Loc2Minimized
                }
            }
            if loc2LatViewVisible {
                Loc2LatExpanded
            }
            if loc2LongViewVisible {
                Loc2LongExpanded
            }
        }
    }

    fileprivate var Location2Details_iPad: some View {
        VStack {
            HStack {
                if !loc2LatViewVisible && !loc2LongViewVisible {
                    Loc2Minimized_iPad
                }
            }
            if loc2LatViewVisible {
                Loc2LatExpanded_iPad
            }
            if loc2LongViewVisible {
                Loc2LongExpanded_iPad
            }
        }
    }

    fileprivate var DistanceView: some View {
        HStack {
            Spacer()
            Text(CalculateDistance(Loc1: Location1, Loc2: Location2))
            Text("nm")
            Spacer()
        }
        .font(.title)
    }

    fileprivate var DistanceView_iPad: some View {
        HStack {
            Spacer()
            Text(CalculateDistance(Loc1: Location1, Loc2: Location2))
            Text("nm")
            Spacer()
        }
        .font(Font.system(size: 40, weight: .regular, design: .default))
    }

    fileprivate var MinimizeButton: some View {
        VStack {
            if loc1LatViewVisible || loc1LongViewVisible || loc2LatViewVisible || loc2LongViewVisible {
                Button(action: {
                    loc1LatViewVisible = false
                    loc1LongViewVisible = false
                    loc2LatViewVisible = false
                    loc2LongViewVisible = false
                }, label: {
                    Text("Minimize")
                })
                .buttonStyle(.bordered)
            }
        }
    }
    
    fileprivate var MinimizeButton_iPad: some View {
        VStack {
            if loc1LatViewVisible || loc1LongViewVisible || loc2LatViewVisible || loc2LongViewVisible {
                Button(action: {
                    loc1LatViewVisible = false
                    loc1LongViewVisible = false
                    loc2LatViewVisible = false
                    loc2LongViewVisible = false
                }, label: {
                    Text("Minimize")
                })
                .font(Font.system(size: 25, weight: .regular, design: .default))
                .buttonStyle(.bordered)
            }
        }
    }
    
    fileprivate var UserDialog: some View {
        VStack {
            Text("Are you sure you want to switch hemisphere ?")
                .font(.title)
                .foregroundColor(.black)
                .bold()
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                Button(action: {
                    showDialog = false
                    if loc1LatViewVisible {
                        Location1.coordinate.latitude = -Location1.coordinate.latitude
                        NortSouthLoc1 = (NortSouthLoc1 == "N") ? "S" : "N"
                    }
                    if loc2LatViewVisible {
                        Location2.coordinate.latitude = -Location2.coordinate.latitude
                        NortSouthLoc2 = (NortSouthLoc2 == "N") ? "S" : "N"
                    }
                    if loc1LongViewVisible {
                        Location1.coordinate.longitude = -Location1.coordinate.longitude
                        EastWestLoc1 = (EastWestLoc1 == "E") ? "W" : "E"
                    }
                    if loc2LongViewVisible {
                        Location2.coordinate.longitude = -Location2.coordinate.longitude
                        EastWestLoc2 = (EastWestLoc2 == "E") ? "W" : "E"
                    }
                }) {
                    Text("Yes")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    // NO action
                    showDialog = false
                }) {
                    Text("No")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(Color.gray.opacity(0.2))
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
    
    fileprivate func SetViewVisibility(viewName: ViewName) {
        loc1LatViewVisible = false
        loc1LongViewVisible = false
        loc2LatViewVisible = false
        loc2LongViewVisible = false
        switch viewName {
        case .Loc1Lat:
            loc1LatViewVisible.toggle()
        case .Loc1Long:
            loc1LongViewVisible.toggle()
        case .Loc2Lat:
            loc2LatViewVisible.toggle()
        case .Loc2Long:
            loc2LongViewVisible.toggle()
        }
    }
    
    fileprivate func DegreesToString(degrees: CLLocationDegrees) -> String {
        if degrees < 0 {
            return "\(-degrees)"
        } else {
            return "\(degrees)"
        }
    }
    
    fileprivate func calcLatDelta() -> CLLocationDegrees {
        let delta = abs(Location1.coordinate.latitude - Location2.coordinate.latitude) * 1.1
        return delta
    }

    fileprivate func calcLongDelta() -> CLLocationDegrees {
        let delta = abs(Location1.coordinate.longitude - Location2.coordinate.longitude) * 1.1
        return delta
    }

}

#Preview {
    var viewFormat: ViewFormat = .DDM
    DistanceView(viewFormat: viewFormat)
}

