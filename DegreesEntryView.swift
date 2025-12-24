//
//  LatLongEntryView.swift
//  MapPlayground
//
//  Created by Rolf Jaeger on 8/24/25.
//

import SwiftUI
import CoreLocation

/*
TODO List:
 - Distinguish between Lat and Long when setting the allowable limits for the degrees (how?)
 */

/*
This view supports the following formats:
 # DMS: Degrees, Minutes, Seconds, e.g. 37° 23′ 22″
 # DDM: Degrees Decimal Minutes, e.g. 37.389°
 # Raymarine Format (DDD-MM.mmm), e.g. 37°23.367°
*/

enum ViewFormat: String {
    case DMS = "Degrees-Mins-Secs"
    case DDM = "Decimal Degrees"
    case Raymarine = "Raymarine"
}

struct DegreesEntryView: View {

    var orientation: String
    var maxDegrees: Int
    
    @Binding var locDegrees: CLLocationDegrees
    @Binding var viewFormat: ViewFormat
    
    @State private var path = NavigationPath()

    @State var cllDegrees: CLLocationDegrees
    @State private var degrees: Int = -180
    @State private var decimalDegrees: Double = -179.001
    @State private var minutes: Int = 59
    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var seconds: Int = 45
    
    @State private var showDecimal = false
    @State private var showDegreesMinSec = false
    
    @State private var showDegreesPicker = false
    @State private var showMinutesPicker = false
    @State private var showSecondsPicker = false

    @FocusState private var isDecimalDegreesFieldFocused: Bool
    @FocusState private var isDegreesFieldFocused: Bool
    @FocusState private var isDecimalMinutesFieldFocused: Bool
    @FocusState private var isMinutesFieldFocused: Bool
    @FocusState private var isSecondsFieldFocused: Bool

    init(orientation: String, locDegrees: Binding<CLLocationDegrees>, viewFormat: Binding<ViewFormat>) {
        self.orientation = orientation
        if orientation == "N" || orientation == "S" {
            maxDegrees = 90
        } else {
            maxDegrees = 180
        }
            
        
        _locDegrees = locDegrees // Initialize the @Binding
        _cllDegrees =  State(initialValue: locDegrees.wrappedValue)
        _degrees = State(initialValue: Int(locDegrees.wrappedValue))
        _decimalDegrees = State(initialValue: Double(locDegrees.wrappedValue))
        _viewFormat = viewFormat
    }

    fileprivate mutating func InitializeDMS(decimalDegrees: Double) {
        print("Decimal Degrees in Init: \(decimalDegrees)")
        let fractionalDegrees = decimalDegrees - Double(degrees)
        minutesInDecimalFormat = fractionalDegrees * 60
        print("Decimal Minutes in Init: \(minutesInDecimalFormat)")
        minutes = Int(minutesInDecimalFormat)
        seconds = Int((minutesInDecimalFormat - Double(minutes))*60)
    }
    
    var body: some View {
        VStack {
            EntryView
        }
        .onAppear() {
            minutesInDecimalFormat = decimalDegrees - Double(degrees)
            minutesInDecimalFormat = minutesInDecimalFormat * 60
            minutes = Int(minutesInDecimalFormat)
            seconds = Int((minutesInDecimalFormat - Double(minutes))*60)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var EntryView_Debugging: some View {
        VStack {
            DecimalDegrees_View
            Raymarine_View
            DMS_View
            Spacer()
        }
    }

    private var EntryView: some View {
        VStack {
            switch viewFormat {
            case .DMS:
                DMS_View
            case .DDM:
                DecimalDegrees_View
            case .Raymarine:
                Raymarine_View
            }
            Spacer()
        }
    }

    private var DecimalDegrees_View: some View {
        VStack(alignment: .center) {
            HStack {
                TextField("Enter degrees", value: $decimalDegrees, format: .number)
                    .focused($isDecimalDegreesFieldFocused)                 .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .frame( width: 200, height: 35, alignment: .leading)
                    .onChange(of:decimalDegrees, {
                        CalcMinutesAndSecondsFromDecimalDegrees(degrees: decimalDegrees)
                        locDegrees = decimalDegrees
                        degrees = Int(decimalDegrees)
                    })
                    .contextMenu {
                        FormatSwitchButtons
                    }
                
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                // Determine the direction of the drag and adjust the value
                                let dragAmount = gesture.translation.height
                                if dragAmount < -10 { // Dragging upwards
                                    if decimalDegrees < 180.00 {
                                        decimalDegrees += 0.01
                                    }
                                } else if dragAmount > 10 { // Dragging downwards
                                    if decimalDegrees > -180.00 {
                                        decimalDegrees -= 0.01
                                    }
                                }
                                // Reset the gesture state to allow for continuous changes
                                // (Optional, depending on desired behavior)
                            }
                            .onEnded { _ in
                                // You can add logic here if needed when the drag ends
                            }
                    )
                
                
                Text("°")
                    .padding(.leading, -50)
            }
            .font(.largeTitle)
            .bold()
        }
        .frame(maxWidth: .infinity)
    }

    private var Raymarine_View_Rev0: some View {
        HStack {
            VStack {
                HStack {
                    if !showDegreesPicker {
                        Text("\(degrees)")
                            .onTapGesture {
                                showDegreesPicker.toggle()
                                showMinutesPicker = false
                                showSecondsPicker = false
                            }
                    } else {
                        PickerViewWithoutIndicator(selection: $degrees) {
                            ForEach(0...maxDegrees, id: \.self) { value in
                                Text("\(value)")
                                    .tag(value)
                                    .frame(minWidth: 550.0)
                                .font(.title)
                                .bold()
                            }
                        }
                        .onChange(of: degrees) {
                            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                        }
                    }
                    Text("\u{00B0}")
                }
            }
            VStack {
                HStack {
                    TextField("Enter Minutes in Decimal Format", value:  $minutesInDecimalFormat, format: .number)
                        .focused($isDecimalMinutesFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 150, height: 35, alignment: .trailing)
                        .onChange(of: minutesInDecimalFormat, {
                            minutes = Int(minutesInDecimalFormat)
                            seconds = CalculateIntSecondsFromDecimalMinutes(minutesInDecimalFormat: minutesInDecimalFormat)
                            locDegrees = Double(degrees) + minutesInDecimalFormat/60
                            print("LocDegrees: \(locDegrees)")
                            print("Degrees: \(String(describing: degrees)) | Minutes: \(minutes) | Seconds: \(seconds)")
                        })
                    
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    // Determine the direction of the drag and adjust the value
                                    let dragAmount = gesture.translation.height
                                    if dragAmount < -10 { // Dragging upwards
                                        if minutesInDecimalFormat < 60.0 {
                                            minutesInDecimalFormat += 0.1
                                        }
                                    } else if dragAmount > 10 { // Dragging downwards
                                        if minutesInDecimalFormat >= 0.1 {
                                            minutesInDecimalFormat -= 0.1
                                        }
                                    }
                                    // Reset the gesture state to allow for continuous changes
                                    // (Optional, depending on desired behavior)
                                }
                                .onEnded { _ in
                                    // You can add logic here if needed when the drag ends
                                }
                        )
                    Text("'")
                }
            }
        }
        .frame(width: 800, height: 30, alignment: .center)
        .padding(.top, 20)
        .font(.largeTitle)
        .bold()
    }
    
    private var Raymarine_View: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        showDegreesPicker.toggle()
                        showMinutesPicker = false
                        showSecondsPicker = false
                    }
            } else {
                PickerViewWithoutIndicator(selection: $degrees) {
                    ForEach(0...maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 550.0)
                        .font(.title)
                        .bold()
                    }
                }
                .onChange(of: degrees) {
                    locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                }
            }
            Text("\u{00B0}")
            
            TextField("Enter Minutes in Decimal Format", value:  $minutesInDecimalFormat, format: .number)
                .focused($isDecimalMinutesFieldFocused)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .frame(width: 150, height: 35, alignment: .leading)
                .onChange(of: minutesInDecimalFormat, {
                    minutes = Int(minutesInDecimalFormat)
                    seconds = CalculateIntSecondsFromDecimalMinutes(minutesInDecimalFormat: minutesInDecimalFormat)
                    locDegrees = Double(degrees) + minutesInDecimalFormat/60
                    print("LocDegrees: \(locDegrees)")
                    print("Degrees: \(String(describing: degrees)) | Minutes: \(minutes) | Seconds: \(seconds)")
                })
            Text("'")

        }
        .font(.largeTitle)
        .bold()
    }
    
    private var DMS_View_Rev0: some View {
        HStack {
            TextField("Enter degrees", value: $degrees, format: .number)
                .focused($isDegreesFieldFocused)                 .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .frame(width: 100, height: 35, alignment: .trailing)
            
                .onChange(of: degrees, {
                    minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                    locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                })
                .contextMenu {
                    FormatSwitchButtons
                }
                        
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Determine the direction of the drag and adjust the value
                            let dragAmount = gesture.translation.height
                            if dragAmount < -10 { // Dragging upwards
                                if degrees < 180 {
                                    degrees += 1
                                }
                            } else if dragAmount > 10 { // Dragging downwards
                                if degrees > -180 {
                                    degrees -= 1
                                }
                            }
                            minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                            print("locDegrees in DMS_View: \(locDegrees)")
                            // Reset the gesture state to allow for continuous changes
                            // (Optional, depending on desired behavior)
                        }
                        .onEnded { _ in
                            // You can add logic here if needed when the drag ends
                        }
                    )


            
            Text("°")
            TextField("Enter minutes", value: $minutes, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .focused($isMinutesFieldFocused)                            .frame(width: 60)
                .onChange(of: minutes, {
                    if isMinutesFieldFocused {
                        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                    }
                })
            
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Determine the direction of the drag and adjust the value
                            let dragAmount = gesture.translation.height
                            if dragAmount < -10 { // Dragging upwards
                                if minutes < 60 {
                                    minutes += 1
                                }
                            } else if dragAmount > 10 { // Dragging downwards
                                if minutes > 0 {
                                    minutes -= 1
                                }
                            }
                            degrees = degrees + minutes/60
                            minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                            // Reset the gesture state to allow for continuous changes
                            // (Optional, depending on desired behavior)
                        }
                        .onEnded { _ in
                            // You can add logic here if needed when the drag ends
                        }
                    )


            Text("'")
            TextField("Enter Seconds", value: $seconds, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)                .focused($isSecondsFieldFocused)                                            .frame(width: 60)
                .onChange(of: seconds, {
                    if isSecondsFieldFocused {
                        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
                    }
                })
            
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Determine the direction of the drag and adjust the value
                            let dragAmount = gesture.translation.height
                            if dragAmount < -10 { // Dragging upwards
                                if seconds < 60 {
                                    seconds += 1
                                }
                            } else if dragAmount > 10 { // Dragging downwards
                                if seconds > 0 {
                                    seconds -= 1
                                }
                            }
                            minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
                            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)

                            // Reset the gesture state to allow for continuous changes
                            // (Optional, depending on desired behavior)
                        }
                        .onEnded { _ in
                            // You can add logic here if needed when the drag ends
                        }
                    )


            Text("''")
        }
        .font(.largeTitle)
        .bold()
    }

    
    fileprivate func updateDegreesValue() {
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
    }
    
    var DMS_View: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        showDegreesPicker.toggle()
                        showMinutesPicker = false
                        showSecondsPicker = false
                    }
                    //.frame(width: 100, height: 35, alignment: .trailing)
            } else {
                PickerViewWithoutIndicator(selection: $degrees) {
                    ForEach(0...maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 50.0)
                        .font(.title)
                        .bold()
                    }
                }
                .onChange(of: degrees) {
                    updateDegreesValue()
                }
            }
            Text("\u{00B0}")

            if !showMinutesPicker {
                Text("\(minutes)")
                    //.frame(width: 100, height: 35, alignment: .trailing)
                    .onTapGesture {
                        showMinutesPicker.toggle()
                        showDegreesPicker = false
                        showSecondsPicker = false
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minutes) {
                    ForEach(0...60, id: \.self) { value in
                        Text("\(value)")
                            .font(.title)
                            .bold()
                            .tag(value)
                            .frame(minWidth: 250.0)
                    }
                }
                .onChange(of: minutes) {
                    updateDegreesValue()
                }
            }
            Text("'")
            
            if !showSecondsPicker {
                Text("\(seconds)")
                    //.frame(width: 100, height: 35, alignment: .trailing)
                    .onTapGesture {
                        showSecondsPicker.toggle()
                        showDegreesPicker = false
                        showMinutesPicker = false
                    }
            } else {
                PickerViewWithoutIndicator(selection: $seconds) {
                    ForEach(0...60, id: \.self) { value in
                        Text("\(value)")
                            .font(.title)
                            .bold()
                            .tag(value)
                            .frame(minWidth: 250.0)
                    }
                }
                .onChange(of: seconds) {
                    updateDegreesValue()
                }
            }
            Text("\"")
        }
        .font(.largeTitle)
        .bold()
    }

    private var FormatSwitchButtons: some View {
        VStack {
            if viewFormat != .Raymarine {
                Button("Switch to Raymarine") {
                    viewFormat = .Raymarine
                }
            }
            if viewFormat != .DMS {
                Button("Switch to Deg-Min-Sec") {
                    viewFormat = .DMS
                }
            }
            if viewFormat != .DDM {
                Button("Switch to Decimal") {
                    viewFormat = .DDM
                }
            }
        }
    }
    
    /*
    fileprivate func FormatDegreesFromDecimalDegrees(decimalDegrees: Double) -> Double {
        guard let dblDegrees = Double(strDecimalDegrees) else {
            minutes = "0"
            return 0.0
        }
        let intDegrees = Int(dblDegrees)
        return String(intDegrees)
    }
    */
    
    /*
    fileprivate func ConvertToDecimalDegrees() -> String {
        guard let fltFractionalMinutes = Float(minutesInDecimalFormat) else {
            return "?"
        }
        let fltFractionalDegrees = fltFractionalMinutes/60
        guard let fltDecimalDegrees = Float(degrees) else {
            return "?"
        }
        var result: Float
        if fltDecimalDegrees < 0 {
            result = fltDecimalDegrees - fltFractionalDegrees
        } else {
            result = fltDecimalDegrees + fltFractionalDegrees
        }
        return String(format: "%.3f", result)
    }
    */
    
    fileprivate func CalcMinutesAndSecondsFromDecimalDegrees(degrees: Double) {
        let intDegrees = Int(degrees)
        let fractionalMinutes = (degrees - Double(intDegrees)) * 60
        let intMinutes = Int(fractionalMinutes)
        minutes = intMinutes
        let dblSeconds = (fractionalMinutes - Double(intMinutes)) * 60
        let intSeconds = Int(dblSeconds)
        seconds = intSeconds
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
    }

    fileprivate func ConvertDegreesStringToCLLocationDegrees(degrees: String) -> CLLocationDegrees {
        return CLLocationDegrees(floatLiteral: 89.0)
    }
    
    /*
    fileprivate func TruncateDegreesToInteger() -> Binding<String> {
        Binding(
            get: {
                // This closure is called when the binding's value is read
                guard let fltDegrees = Float(degrees) else {
                    return "0"
                }
                let intDegrees = Int(fltDegrees)
                return String(intDegrees)            },
            set: { newValue in
                // This closure is called when the binding's value is set
                degrees = newValue
            }
        )
    }
    */
    
    fileprivate func TruncateDegreesToInteger(strDegrees: String) -> String {
        return "122"
    }
    
    fileprivate func CalculateDecimalDegrees_Rev0(degrees: Int, decimalMinutes: Double) -> CLLocationDegrees {
        var decimalDegrees: Double
        if degrees < 0 {
            decimalDegrees = Double(degrees) - decimalMinutes/60
        } else {
            decimalDegrees = Double(degrees) + decimalMinutes/60
        }
        return CLLocationDegrees(decimalDegrees)
    }

    fileprivate func CalculateDecimalDegrees(degrees: Int, decimalMinutes: Double) -> CLLocationDegrees {
        var decimalDegrees: Double
        decimalDegrees = Double(degrees) + decimalMinutes/60
        return CLLocationDegrees(decimalDegrees)
    }

    fileprivate func CalculateIntMinutesFromDecimalMinutes(strMinutesInDecimalFormat: String) -> String {
        
        guard let fltMinute = Float(strMinutesInDecimalFormat) else {
            return "0"
        }
        let intMinute = Int(fltMinute)
        return String(intMinute)
    }

    fileprivate func CalculateIntSecondsFromDecimalMinutes(minutesInDecimalFormat: Double) -> Int {
        
        let intMinute = Int(minutesInDecimalFormat)
        let seconds = (minutesInDecimalFormat - Double(intMinute)) * 60
        return Int(seconds)
    }
    
    fileprivate func CalculateDecimalMinutesFromMinutesAndSeconds(minutes: Int, seconds: Int) -> Double {
        let totalSeconds = minutes * 60 + seconds
        return Double(totalSeconds)/60.0
    }

}

/// Helpers
struct PickerViewWithoutIndicator<Content: View, Selection: Hashable>: View {
    @Binding var selection: Selection
    @ViewBuilder var content: Content
    var body: some View {
        Picker("", selection: $selection) {
            content
        }
        .pickerStyle(.wheel)
        .frame(width: 50)
        .padding(.leading, 50)
    }
}

#Preview {
    @Previewable @State var viewFormat: ViewFormat = .Raymarine
    @Previewable @State var tmp = CLLocationDegrees(floatLiteral: 37.5899)
    @Previewable @State var orientation: String = "N"
    
    DegreesEntryView(orientation: orientation, locDegrees: $tmp, viewFormat: $viewFormat)
}

