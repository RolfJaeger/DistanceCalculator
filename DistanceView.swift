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
            let detectedLocation = Location(coordinate: CLLocationCoordinate2D(latitude: lat1, longitude: lon1), name: "Location 1")
            // Update backing state wrapper correctly
            self._Location1 = State(initialValue: detectedLocation)
            self._Location2 = State(initialValue: detectedLocation)

            // Set hemisphere states based on signs
            self.NortSouthLoc1 = lat1 < 0 ? "S" : "N"
            self.EastWestLoc1 = lon1 < 0 ? "W" : "E"

            // Initialize Location 2 defaults to current location as well
            self.NortSouthLoc2 = self.NortSouthLoc1
            self.EastWestLoc2 = self.EastWestLoc1
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
                        MainView_iPhone
                    }
                    NavigationLink(
                        destination:
                            LocationsOnMap(
                                Location1: $Location1,Location2: $Location2 ),
                        label: {
                        Text("Show Locations on Map")
                            .font(.title3)
                            .padding(.top, 20)
                    })
                }
                if showDialog {
                    UserDialog
                }
            }
        }
    }
    
    fileprivate var MainView_iPhone: some View {
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
            Text("Location 1")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location1Details
            Text("Location 2")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .padding(.bottom, 5)
            Location2Details
            
            HintView
            Spacer()
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
        }
    }

    fileprivate var HintView: some View {
        VStack {
            if !loc1LatViewVisible && !loc1LongViewVisible && !loc2LatViewVisible && !loc2LongViewVisible {
                if hintVisible {
                    Text("Initially your location is shown.")
                        .padding(.top, 20)
                    Text("Tap coordinates to modify.")
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
    
    fileprivate var Loc1LatExpanded: some View {
        VStack {
            TopButtons
            HStack {
                Spacer()
                if Location1.coordinate.latitude < 0 {
                    Text("S")
                } else {
                    Text("N")
                }
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
        //.containerRelativeFrame(.horizontal)
        .border(.primary, width: 2)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    fileprivate var Loc1LatExpanded_iPad: some View {
        VStack {
            TopButtons_iPad
            HStack {
                Spacer()
                Text(NortSouthLoc1)
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
                Text(EastWestLoc1)
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
                Text(EastWestLoc1)
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
            Text(NortSouthLoc2)
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Lat)
                }
            Text(" | ")
            Text(EastWestLoc2)
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
            Text(NortSouthLoc2)
            Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                .onTapGesture {
                    SetViewVisibility(viewName: .Loc2Lat)
                }
            Text(" | ")
            Text(EastWestLoc2)
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
                Text(NortSouthLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LatViewVisible = false
                    }
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView_Rev0(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
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
                Text(NortSouthLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.latitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LatViewVisible = false
                    }
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView_Rev0(hemisphere: NortSouthLoc2, locDegrees: $Location2.coordinate.latitude)
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
                Text(EastWestLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LongViewVisible = false
                    }
            }
            .font(.title)
            switch viewFormat {
            case .DMS:
                DMSEntryView_Rev0(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
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
                Text(EastWestLoc2)
                Text(DegreesToStringInSelectedFormat(degrees: Location2.coordinate.longitude, viewFormat: viewFormat))
                    .onTapGesture {
                        loc2LongViewVisible = false
                    }
            }
            switch viewFormat {
            case .DMS:
                DMSEntryView_Rev0(hemisphere: EastWestLoc2, locDegrees: $Location2.coordinate.longitude)
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
    
    private var UserDialog: some View {
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
                        NortSouthLoc1 = (NortSouthLoc1 == "N") ? "S" : "N"
                    }
                    if loc2LatViewVisible {
                        NortSouthLoc2 = (NortSouthLoc2 == "N") ? "S" : "N"
                    }
                    if loc1LongViewVisible {
                        EastWestLoc1 = (EastWestLoc1 == "E") ? "W" : "E"
                    }
                    if loc2LongViewVisible {
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
    
    fileprivate func CalculateDistance_Rev0(
        latLoc1: CLLocationDegrees,
        longLoc1: CLLocationDegrees,
        latLoc2: CLLocationDegrees,
        longLoc2: CLLocationDegrees) -> String {
            
        let latLoc1WithSign = NortSouthLoc1 == "S" ? -latLoc1 : latLoc1
        
        let latLoc2WithSign = NortSouthLoc2 == "S" ? -latLoc2 : latLoc2
        
        let longLoc1WithSign = EastWestLoc1 == "W" ? -longLoc1 : longLoc1
            
        let longLoc2WithSign = EastWestLoc2 == "W" ? -longLoc2 : longLoc2

        let p1 = CLLocationCoordinate2D(latitude: latLoc1WithSign, longitude: longLoc1WithSign)
        let p2 = CLLocationCoordinate2D(latitude: latLoc2WithSign, longitude: longLoc2WithSign)

        let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        let nauticalMilesPerKilometer = 0.539957
        let strDistance = String(format: "%.4f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
        return strDistance
    }

    fileprivate func CalculateDistance(
        Loc1: Location,
        Loc2: Location
    ) -> String {

        let p1 = CLLocationCoordinate2D(latitude: Loc1.coordinate.latitude, longitude: Loc1.coordinate.longitude)
        let p2 = CLLocationCoordinate2D(latitude: Loc2.coordinate.latitude, longitude: Loc2.coordinate.longitude)

        let location1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let location2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        let nauticalMilesPerKilometer = 0.539957
        let strDistance = String(format: "%.4f", location2.distance(from: location1) * nauticalMilesPerKilometer / 1000)
        return strDistance
    }

    /*
    fileprivate func LatLongToString(lat: CLLocationDegrees, long: CLLocationDegrees, viewFormat: ViewFormat) -> String {
        var strLat = lat >= 0.0 ? "N" : "S"
        switch viewFormat {
        case .DMS:
            strLat = strLat + DegreesInDMS(degrees: lat)
        case .DDM:
            strLat = strLat + DecimalDegrees(degrees: lat)
        case .Raymarine:
            strLat = strLat + DegreesInRaymarineFormat(degrees: lat)
        }
        var strLong = long >= 0.0 ? "E" : "W"
        switch viewFormat {
        case .DMS:
            strLong = strLong + DegreesInDMS(degrees: long)
        case .DDM:
            strLong = strLong + DecimalDegrees(degrees: long)
        case .Raymarine:
            strLong = strLong + DegreesInRaymarineFormat(degrees: long)
        }
        let strLatLong = strLat + " | " + strLong
        return strLatLong
    }
    */
    
    fileprivate func DegreesToStringInSelectedFormat(degrees: CLLocationDegrees, viewFormat: ViewFormat) -> String {
        var strDegrees: String
        switch viewFormat {
        case .DMS:
            strDegrees = DegreesInDMS(degrees: degrees)
        case .DDM:
            strDegrees = DecimalDegrees(degrees: degrees)
        case .Raymarine:
            strDegrees = DegreesInRaymarineFormat(degrees: degrees)
        }
        return strDegrees
    }

    fileprivate func DegreesToString(degrees: CLLocationDegrees) -> String {
        if degrees < 0 {
            return "\(-degrees)"
        } else {
            return "\(degrees)"
        }
    }
    
    fileprivate func DecimalDegrees(degrees: CLLocationDegrees) -> String {
        var decimalDegrees = Double(degrees).rounded(toPlaces: 4)
        if decimalDegrees < 0 {
            decimalDegrees = -decimalDegrees
        }
        return "\(decimalDegrees)\u{00B0}"
    }

    fileprivate func DegreesInDMS(degrees: CLLocationDegrees) -> String {
        let degreesWithoutSign = degrees < 0 ? -degrees : degrees
        var d = Int(degreesWithoutSign)
        var fractualMinutes = (degreesWithoutSign - Double(d)) * 60
        if fractualMinutes == 60 {
            d += 1
            fractualMinutes = 0
        }
        var m = Int(fractualMinutes)
        var doubleSeconds = Double((fractualMinutes - Double(m))*60).rounded(toPlaces: 0)
        if doubleSeconds == 60 {
            m += 1
            doubleSeconds = 0
        }
        let s = Int(doubleSeconds.rounded(toPlaces: 0))
        return "\(d)\u{00B0} \(m)' \(s)\""
    }

    fileprivate func DegreesInRaymarineFormat(degrees: CLLocationDegrees) -> String {
        var d = Int(degrees)
        var fractualMinutes = Double((degrees - Double(d)) * 60).rounded(toPlaces: 4)
        if degrees < 0 {
            d = -d
            if fractualMinutes < 0 {
                fractualMinutes = -fractualMinutes
            }
        }
        return "\(d)\u{00B0} \(fractualMinutes)'"
    }

}

#Preview {
    var viewFormat: ViewFormat = .DDM
    DistanceView(viewFormat: viewFormat)
}

