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

enum PickerName: String {
    case Degrees = "Degrees"
    case Minutes = "Minutes"
    case Tenth = "Tenth"
    case Hundredth = "Hundredth"
    case Thousandth = "Thousandth"
    case Seconds = "Seconds"
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
    @State private var tenth: Int = 0
    @State private var hundredth: Int = 0
    @State private var thousandth: Int = 0
    @State private var seconds: Int = 45
    
    @State private var showDecimal = false
    @State private var showDegreesMinSec = false
    
    @State private var showDegreesPicker = false
    @State private var showMinutesPicker = false
    @State private var showTenthPicker = false
    @State private var showHundredthPicker = false
    @State private var showThousandthPicker = false
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

    /*
    fileprivate mutating func InitializeDMS(decimalDegrees: Double) {
        print("Decimal Degrees in Init: \(decimalDegrees)")
        let fractionalDegrees = decimalDegrees - Double(degrees)
        minutesInDecimalFormat = fractionalDegrees * 60
        print("Decimal Minutes in Init: \(minutesInDecimalFormat)")
        minutes = Int(minutesInDecimalFormat)
        seconds = Int((minutesInDecimalFormat - Double(minutes))*60)
    }
    */
    
    var body: some View {
        VStack {
            EntryView
        }
        .onAppear() {
            minutesInDecimalFormat = decimalDegrees - Double(degrees)
            minutesInDecimalFormat = minutesInDecimalFormat * 60
            minutes = Int(minutesInDecimalFormat)
            seconds = Int((minutesInDecimalFormat - Double(minutes))*60)
            if let tryTenth = Int(extractTenth(degrees: decimalDegrees)) {
                tenth = tryTenth
            }
            if let tryHundredth = Int(extractHundredth(degrees: decimalDegrees)) {
                hundredth = tryHundredth
            }
            if let tryThousandth = Int(extractThousandth(degrees: decimalDegrees)) {
                thousandth = tryThousandth
            }

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

    private var DecimalDegrees_View_Rev0: some View {
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

    private var DecimalDegrees_View: some View {
        VStack(alignment: .center) {
            VStack {
                HStack {
                    if !showDegreesPicker {
                        Text("\(Int(decimalDegrees))")
                            .onTapGesture {
                                toggleViewOfSelectedPicker(.Degrees)
                            }
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
                    Text(".")
                        .padding(.leading, -10)
                    
                    if !showTenthPicker {
                        Text("\(extractTenth(degrees: decimalDegrees))")
                            .padding(.leading, -5)
                            .onTapGesture {
                                toggleViewOfSelectedPicker(.Tenth)
                            }
                    } else {
                        PickerViewWithoutIndicator(selection: $tenth) {
                            ForEach(0...9, id: \.self) { value in
                                Text("\(value)")
                                    .tag(value)
                                    .frame(minWidth: 50.0)
                                    .font(.title)
                                    .bold()
                            }
                        }
                        .padding(.leading, -50)
                        .onAppear {
                            tenth = Int(extractTenth(degrees: decimalDegrees))!
                        }
                        .onChange(of: tenth) {
                            updateDegreesValueDecimalDegreesFormat()
                        }
                    }
                    
                    if !showHundredthPicker {
                        Text("\(extractHundredth(degrees: decimalDegrees))")
                            .padding(.leading, -5)
                            .onTapGesture {
                                toggleViewOfSelectedPicker(.Hundredth)
                            }
                    } else {
                        PickerViewWithoutIndicator(selection: $hundredth) {
                            ForEach(0...9, id: \.self) { value in
                                Text("\(value)")
                                    .tag(value)
                                    .frame(minWidth: 50.0)
                                    .font(.title)
                                    .bold()
                            }
                        }
                        .padding(.leading, -50)
                        .onAppear {
                            hundredth = Int(extractHundredth(degrees: decimalDegrees))!
                        }
                        .onChange(of: hundredth) {
                            updateDegreesValueDecimalDegreesFormat()
                        }
                    }
                    
                    if !showThousandthPicker {
                        Text("\(extractThousandth(degrees: decimalDegrees))")
                            .padding(.leading, -5)
                            .onTapGesture {
                                toggleViewOfSelectedPicker(.Thousandth)
                            }
                    } else {
                        PickerViewWithoutIndicator(selection: $thousandth) {
                            ForEach(0...9, id: \.self) { value in
                                Text("\(value)")
                                    .tag(value)
                                    .frame(minWidth: 50.0)
                                    .font(.title)
                                    .bold()
                            }
                        }
                        .padding(.leading, -50)
                        .onAppear {
                            thousandth = Int(extractThousandth(degrees: decimalDegrees))!
                        }
                        .onChange(of: thousandth) {
                            updateDegreesValueDecimalDegreesFormat()
                        }
                    }
                    
                    Text("°")
                        .padding(.leading,-5)
                }
                .font(.largeTitle)
                .bold()
                Text("Tap and scroll.")
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity)
    }

    fileprivate func toggleViewOfSelectedPicker(_ pickerName: PickerName) {
        
        showDegreesPicker = false
        showMinutesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        
        switch pickerName {
        case .Degrees:
            showDegreesPicker.toggle()
        case .Minutes:
            showMinutesPicker.toggle()
        case .Tenth:
            showTenthPicker.toggle()
        case .Hundredth:
            showHundredthPicker.toggle()
        case .Thousandth:
            showThousandthPicker.toggle()
        default:
            showSecondsPicker.toggle()
        }
    }
    
    var Raymarine_View: some View {
        VStack(alignment: .center) {
            HStack {
                if !showDegreesPicker {
                    Text("\(degrees)")
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Degrees)
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
                    Text("\(Int(minutesInDecimalFormat))")
                        .padding(.leading,10)
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Minutes)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $minutes) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                                .frame(minWidth: 50.0)
                                .font(.title)
                                .bold()
                        }
                    }
                    .padding(.leading, -50)
                    .onChange(of: minutes) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    
                }
                Text(".")
                
                if !showTenthPicker {
                    Text("\(extractTenth(degrees: minutesInDecimalFormat))")
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Tenth)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $tenth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                                .frame(minWidth: 50.0)
                                .font(.title)
                                .bold()
                        }
                    }
                    .padding(.leading, -50)
                    .onChange(of: tenth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                }
                
                if !showHundredthPicker {
                    Text("\(extractHundredth(degrees: minutesInDecimalFormat))")
                        .padding(.leading,-5)
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Hundredth)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $hundredth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                                .frame(minWidth: 50.0)
                                .font(.title)
                                .bold()
                        }
                    }
                    .padding(.leading, -50)
                    .onChange(of: hundredth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                }
                
                if !showThousandthPicker {
                    Text("\(extractThousandth(degrees: minutesInDecimalFormat))")
                        .padding(.leading,-5)
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Thousandth)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $thousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                                .frame(minWidth: 50.0)
                                .font(.title)
                                .bold()
                        }
                    }
                    .onChange(of: thousandth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    .padding(.leading, -50)
                }
                
                Text("'")
                
            }
            .font(.largeTitle)
            .bold()
            Text("Tap and scroll.")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate func updateDegreesValue() {
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutes, seconds: seconds)
        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
    }
    
    fileprivate func updateDegreesValueForRaymarineFormat() {
        let strDecimalMinutes = String(minutes) + "." + String(tenth) + String(hundredth) + String(thousandth)
        if let test = Double(strDecimalMinutes) {
            minutesInDecimalFormat = test
            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
        }
    }
    
    fileprivate func updateDegreesValueDecimalDegreesFormat() {
        let strDecimalDegrees = String(degrees) + "." + String(tenth) + String(hundredth) + String(thousandth)
        if let test = Double(strDecimalDegrees) {
            locDegrees = test
            decimalDegrees = locDegrees
        }
    }
    
    var DMS_View: some View {
        VStack(alignment: .center) {
            HStack {
                if !showDegreesPicker {
                    Text("\(degrees)")
                        .onTapGesture {
                            toggleViewOfSelectedPicker(.Degrees)
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
                            toggleViewOfSelectedPicker(.Minutes)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $minutes) {
                        ForEach(0...59, id: \.self) { value in
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
                            toggleViewOfSelectedPicker(.Seconds)
                        }
                } else {
                    PickerViewWithoutIndicator(selection: $seconds) {
                        ForEach(0...59, id: \.self) { value in
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
            Text("Tap on any digit and then scroll.")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
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

fileprivate func extractTenth(degrees: CLLocationDegrees) -> String {
    print("Degrees in tens: \(String(degrees))")
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 1 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let tensIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 1, limitedBy: strDegrees.endIndex)
        return String(strDegrees[tensIndex!])
    } else {
        return "0"
    }
}

fileprivate func extractHundredth(degrees: CLLocationDegrees) -> String {
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 2 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let hundredsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 2, limitedBy: strDegrees.endIndex)
        return String(strDegrees[hundredsIndex!])
    } else {
        return "0"
    }
}

fileprivate func extractThousandth(degrees: CLLocationDegrees) -> String {
    let strDegrees = String(degrees)
    let periodIndex = strDegrees.firstIndex(of: ".")
    //NOTE: CLLocationsDegrees values ALWAYS contain a period
    if strDegrees.distance(from: periodIndex!, to: strDegrees.endIndex) > 3 {
        let periodPosition: Int = strDegrees.distance(from: strDegrees.startIndex, to: periodIndex!)
        let thousandsIndex = strDegrees.index(strDegrees.startIndex, offsetBy: periodPosition + 3, limitedBy: strDegrees.endIndex)
        return String(strDegrees[thousandsIndex!])
    } else {
        return "0"
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
    @Previewable @State var viewFormat: ViewFormat = .DDM
    @Previewable @State var tmp = CLLocationDegrees(floatLiteral: 37.5899)
    @Previewable @State var orientation: String = "N"
    
    DegreesEntryView(orientation: orientation, locDegrees: $tmp, viewFormat: $viewFormat)
}

