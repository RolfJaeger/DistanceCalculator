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
 - Do more manual test
 - Add + - to DecimalDegree view
 */

/*
This view supports the following formats:
 # DMS: Degrees, Minutes, Seconds, e.g. 37° 23′ 22″
 # DDM: Degrees Decimal Minutes, e.g. 37.389°
 # Raymarine Format (DDD-MM.mmm), e.g. 37°23.367°
*/

struct DegreesEntryView: View {

    @Environment(\.horizontalSizeClass) var sizeClass

    var orientation: String
    var maxDegrees: Int
    
    @Binding var locDegrees: CLLocationDegrees
    @Binding var viewFormat: ViewFormat
    
    @State private var path = NavigationPath()

    @State var cllDegrees: CLLocationDegrees
    @State private var degrees: Int = -180
    @State private var decimalDegrees: Double = -179.001
    @State private var minutesForRaymarineView: Int = 59
    @State private var minutesForDMSView: Int = 59

    @State private var minutesInDecimalFormat:Double = 59.000
    @State private var degreeTenth: Int = 0
    @State private var degreeHundredth: Int = 0
    @State private var degreeThousandth: Int = 0

    @State private var minuteTenth: Int = 0
    @State private var minuteHundredth: Int = 0
    @State private var minuteThousandth: Int = 0

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
        initializeDegreeValues()
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
    
    fileprivate mutating func initializeDegreeValues() {
        let fractionalDegrees = decimalDegrees - Double(degrees)
        let decimalMinutes = fractionalDegrees * 60
        _minutesInDecimalFormat = State(initialValue: Double(decimalMinutes))
        _minutesForDMSView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        _minutesForRaymarineView = State(initialValue: Int(decimalMinutes.rounded(toPlaces: 3)))
        let decimalSeconds = Int(((minutesInDecimalFormat - Double(minutesForRaymarineView))*60).rounded())
        _seconds = State(initialValue: decimalSeconds)
        if seconds == 60 {
            _minutesForDMSView = State(initialValue: Int(decimalMinutes.rounded()))
            _seconds = State(initialValue: 0)
        }

        if let tryTenth = Int(extractTenth(degrees: decimalDegrees)) {
            _degreeTenth = State(initialValue: Int(tryTenth))
        }
        if let tryHundredth = Int(extractHundredth(degrees: decimalDegrees)) {
            _degreeHundredth = State(initialValue: Int(tryHundredth))
        }
        if let tryThousandth = Int(extractThousandth(degrees: decimalDegrees)) {
            _degreeThousandth = State(initialValue: Int(tryThousandth))
        }

        if let tryTenth = Int(extractTenth(degrees: minutesInDecimalFormat)) {
            _minuteTenth = State(initialValue: Int(tryTenth))
        }
        if let tryHundredth = Int(extractHundredth(degrees: minutesInDecimalFormat)) {
            _minuteHundredth = State(initialValue: Int(tryHundredth))
        }
        if let tryThousandth = Int(extractThousandth(degrees: minutesInDecimalFormat)) {
            _minuteThousandth = State(initialValue: Int(tryThousandth))
        }
        printValues()
    }
    
    fileprivate func printValues() {
        print("Values in Initialize")
        print("====================")
        print("DegreeTenth: \(degreeTenth)")
        print("DegreeHundredth: \(degreeHundredth)")
        print("DegreeThousandth: \(degreeThousandth)")

        print("")
        
        print("MinuteTenth: \(minuteTenth)")
        print("DegreeHundredth: \(minuteHundredth)")
        print("DegreeThousandth: \(minuteThousandth)")
    }
    var body: some View {
        VStack {
            EntryView
        }
        .onAppear() {
            //initializeDegreeValues()
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
            if sizeClass == .regular {
                HStack {
                    DecimalDegreesDetails
                    PlusMinusInDecimalDegreesView
                }
                .font(.largeTitle)
                .bold()
            } else {
                VStack {
                    DecimalDegreesDetails
                    PlusMinusInDecimalDegreesView
                }
                .font(.largeTitle)
                .bold()
            }
            Text("Tap and scroll or use + and -")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            
        }
    }

    fileprivate var DecimalDegreesDetails: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(Int(decimalDegrees))")
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Degrees, hideAll: false)
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
                Text("\(degreeTenth)")
                    .padding(.leading, -5)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Tenth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $degreeTenth) {
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
                    degreeTenth = Int(extractTenth(degrees: decimalDegrees))!
                }
                .onChange(of: degreeTenth) {
                    updateDegreesValueDecimalDegreesFormat()
                }
            }
            
            if !showHundredthPicker {
                Text("\(degreeHundredth)")
                    .padding(.leading, -5)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Hundredth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $degreeHundredth) {
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
                    degreeHundredth = Int(extractHundredth(degrees: decimalDegrees))!
                }
                .onChange(of: degreeHundredth) {
                    updateDegreesValueDecimalDegreesFormat()
                }
            }
            
            if !showThousandthPicker {
                Text("\(degreeThousandth)")
                    .padding(.leading, -5)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Thousandth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $degreeThousandth) {
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
                    degreeThousandth = Int(extractThousandth(degrees: decimalDegrees))!
                }
                .onChange(of: degreeThousandth) {
                    updateDegreesValueDecimalDegreesFormat()
                }
            }
            
            Text("°")
                .padding(.leading,-5)
        }
    }
    
    fileprivate func toggleViewOfSelectedPicker(_ pickerName: PickerName, hideAll: Bool) {
        
        showDegreesPicker = false
        showMinutesPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        
        if !hideAll {
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
    }
    
    var Raymarine_View: some View {
        VStack(alignment: .center) {
            if sizeClass == .regular {
                HStack {
                    RaymarineDetails
                    PlusMinusInRaymarineView
                }
                .font(.largeTitle)
                .bold()
            } else {
                VStack {
                    RaymarineDetails
                    PlusMinusInRaymarineView
                }
                .font(.largeTitle)
                .bold()
            }
            Text("Tap and scroll or use + and -")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var RaymarineDetails: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Degrees, hideAll: false)
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
                Text("\(minutesForRaymarineView)")
                    .padding(.leading,10)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Minutes, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minutesForRaymarineView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 50.0)
                            .font(.title)
                            .bold()
                    }
                }
                .padding(.leading, -50)
                .onChange(of: minutesForRaymarineView) {
                    updateDegreesValueForRaymarineFormat()
                }
                
            }
            Text(".")
            
            if !showTenthPicker {
                Text("\(minuteTenth)")
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Tenth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minuteTenth) {
                    ForEach(0...9, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 50.0)
                            .font(.title)
                            .bold()
                    }
                }
                .padding(.leading, -50)
                .onChange(of: minuteTenth) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            
            if !showHundredthPicker {
                Text("\(minuteHundredth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Hundredth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minuteHundredth) {
                    ForEach(0...9, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 50.0)
                            .font(.title)
                            .bold()
                    }
                }
                .padding(.leading, -50)
                .onChange(of: minuteHundredth) {
                    updateDegreesValueForRaymarineFormat()
                }
            }
            
            if !showThousandthPicker {
                Text("\(minuteThousandth)")
                    .padding(.leading,-5)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Thousandth, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minuteThousandth) {
                    ForEach(0...9, id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                            .frame(minWidth: 50.0)
                            .font(.title)
                            .bold()
                    }
                }
                .onChange(of: minuteThousandth) {
                    updateDegreesValueForRaymarineFormat()
                }
                .padding(.leading, -50)
            }
            Text("'")
        }
    }
    
    fileprivate var PlusMinusInRaymarineView: some View {
        HStack {
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if minuteThousandth < 9 {
                    minuteThousandth += 1
                }
                else {
                    let fractionalMinute = Int(String("\(minuteTenth)\(minuteHundredth)\(minuteThousandth)"))
                    if fractionalMinute == 999 {
                        if minutesForRaymarineView < 59 {
                            minutesForRaymarineView += 1
                            minutesInDecimalFormat += 1
                        } else {
                            if degrees < maxDegrees - 1 {
                                degrees += 1
                                minutesForRaymarineView = 0
                                minutesInDecimalFormat = 0.0
                            }
                        }
                        minuteThousandth = 0
                        minuteHundredth = 0
                        minuteTenth = 0
                    } else {
                        if minuteHundredth < 9 {
                            minuteHundredth += 1
                            minuteThousandth = 0
                        } else {
                            if minuteTenth < 9 {
                                minuteTenth += 1
                                minuteHundredth = 0
                            } else {
                                if minutesForRaymarineView < 59 {
                                    minutesForRaymarineView += 1
                                    minutesInDecimalFormat += 1
                                    minuteTenth = 0
                                } else {
                                    if degrees < maxDegrees - 1 {
                                        degrees += 1
                                        minutesInDecimalFormat = 0.0
                                        minuteTenth = 0
                                        minuteHundredth = 0
                                        minuteThousandth = 0
                                    }
                                }
                            }
                        }

                    }
                }
                updateDegreesValueForRaymarineFormat()
            }, label: {
                Text("+")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if minuteThousandth > 0 {
                    minuteThousandth -= 1
                }
                else {
                    let fractionalMinute = Int(String("\(minuteTenth)\(minuteHundredth)\(minuteThousandth)"))
                    if fractionalMinute == 000 {
                        if minutesForRaymarineView > 0 {
                            minutesForRaymarineView -= 1
                            minutesInDecimalFormat -= 1
                        } else {
                            if degrees > 0 {
                                degrees -= 1
                                minutesForRaymarineView = 59
                                minutesInDecimalFormat = 59.0
                            }
                        }
                        minuteThousandth = 9
                        minuteHundredth = 9
                        minuteTenth = 9
                    } else {
                        if minuteHundredth > 0 {
                            minuteHundredth -= 1
                            minuteThousandth = 9
                        } else {
                            if minuteTenth > 0 {
                                minuteTenth -= 1
                                minuteHundredth = 9
                            } else {
                                if minutesForRaymarineView < 59 {
                                    minutesForRaymarineView += 1
                                    minutesInDecimalFormat += 1
                                    minuteTenth = 0
                                } else {
                                    if degrees < maxDegrees - 1 {
                                        degrees += 1
                                        minutesInDecimalFormat = 0.0
                                        minuteTenth = 0
                                        minuteHundredth = 0
                                        minuteThousandth = 0
                                    }
                                }
                            }
                        }

                    }
                }
                updateDegreesValueForRaymarineFormat()
            }, label: {
                Text("-")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDecimalDegreesView: some View {
        HStack {
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if degreeThousandth < 9 {
                    degreeThousandth += 1
                }
                else {
                    let fractionalMinute = Int(String("\(degreeTenth)\(degreeHundredth)\(degreeThousandth)"))
                    if fractionalMinute == 999 {
                        if Int(decimalDegrees.rounded()) < maxDegrees {
                            decimalDegrees += 1
                        }
                        degreeThousandth = 0
                        degreeHundredth = 0
                        degreeTenth = 0
                    } else {
                        if degreeHundredth < 9 {
                            degreeHundredth += 1
                            degreeThousandth = 0
                        } else {
                            if degreeTenth < 9 {
                                degreeTenth += 1
                                degreeHundredth = 0
                                degreeThousandth = 0
                            } else {
                                if Int(decimalDegrees.rounded()) < maxDegrees - 1 {
                                    decimalDegrees += 1
                                    degreeTenth = 0
                                    degreeHundredth = 0
                                    degreeThousandth = 0
                                }
                            }
                        }

                    }
                }
                updateDegreesValueDecimalDegreesFormat()
            }, label: {
                Text("+")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if degreeThousandth > 0 {
                    degreeThousandth -= 1
                }
                else {
                    let fractionalDegrees = Int(String("\(degreeTenth)\(degreeHundredth)\(degreeThousandth)"))
                    if fractionalDegrees == 000 {
                        if decimalDegrees > 1 {
                            decimalDegrees -= 1
                            degreeThousandth = 9
                            degreeHundredth = 9
                            degreeTenth = 9
                        }
                    } else {
                        if degreeHundredth > 0 {
                            degreeHundredth -= 1
                            degreeThousandth = 9
                        } else {
                            if degreeTenth > 0 {
                                degreeTenth -= 1
                                degreeHundredth = 9
                                degreeThousandth = 9
                            } else {
                                if Int(decimalDegrees.rounded()) > 0  {
                                    decimalDegrees -= 1
                                    degreeTenth = 9
                                }
                            }
                        }

                    }
                }
                updateDegreesValueDecimalDegreesFormat()
            }, label: {
                Text("-")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDMSView: some View {
        HStack {
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if seconds < 59 {
                    seconds += 1
                } else {
                     if minutesForDMSView < 59 {
                         minutesForDMSView += 1
                         seconds = 0
                     } else {
                         if degrees < maxDegrees - 1 {
                             degrees += 1
                             minutesForDMSView = 0
                             seconds = 0
                         }
                     }
                }
                updateDegreesFromDMS()
            }, label: {
                Text("+")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
            Button(action: {
                toggleViewOfSelectedPicker(.Minutes, hideAll: true)
                if seconds >= 1 {
                    seconds -= 1
                } else {
                     if minutesForDMSView > 1 {
                         minutesForDMSView -= 1
                         seconds = 59
                     } else {
                         if degrees > 1 {
                             degrees -= 1
                             minutesForDMSView = 59
                             seconds = 59
                         }
                     }
                }
                updateDegreesFromDMS()
            }, label: {
                Text("-")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
        }
    }
    

    fileprivate func updateDegreesValue() {
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView, seconds: seconds)
        locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
    }
    
    fileprivate func updateDegreesFromDMS() {
        let decimalMinutes = Double(minutesForDMSView)/60
        let decimalSeconds = Double(seconds)/60/60
        locDegrees = CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
    }
    
    fileprivate func updateDegreesValueForRaymarineFormat() {
        let strDecimalMinutes = String(minutesForRaymarineView) + "." + String(minuteTenth) + String(minuteHundredth) + String(minuteThousandth)
        if let test = Double(strDecimalMinutes) {
            minutesInDecimalFormat = test
            locDegrees = CalculateDecimalDegrees(degrees: degrees, decimalMinutes: minutesInDecimalFormat)
        }
    }
    
    fileprivate func updateDegreesValueDecimalDegreesFormat_Rev0() {
        let strDecimalDegrees = String(degrees) + "." + String(degreeTenth) + String(degreeHundredth) + String(degreeThousandth)
        if let test = Double(strDecimalDegrees) {
            locDegrees = test
            decimalDegrees = locDegrees
        }
    }

    fileprivate func updateDegreesValueDecimalDegreesFormat() {
        let degrees = Int(decimalDegrees)
        let strDecimalDegrees = String(degrees) + "." + String(degreeTenth) + String(degreeHundredth) + String(degreeThousandth)
        if let test = Double(strDecimalDegrees) {
            locDegrees = test
            decimalDegrees = locDegrees
        }
    }

    var DMS_View: some View {
        VStack(alignment: .center) {
            if sizeClass == .regular {
                HStack {
                    DMSDetailsView
                    PlusMinusInDMSView
                }
                .font(.largeTitle)
                .bold()
            } else {
                VStack {
                    DMSDetailsView
                    PlusMinusInDMSView
                }
                .font(.largeTitle)
                .bold()
            }
            Text("Tap on any digit and then scroll.")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
    }

    fileprivate var DMSDetailsView: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Degrees, hideAll: false)
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
                    updateDegreesFromDMS()
                }
            }
            Text("\u{00B0}")
            
            if !showMinutesPicker {
                Text("\(minutesForDMSView)")
                //.frame(width: 100, height: 35, alignment: .trailing)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Minutes, hideAll: false)
                    }
            } else {
                PickerViewWithoutIndicator(selection: $minutesForDMSView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(.title)
                            .bold()
                            .tag(value)
                            .frame(minWidth: 250.0)
                    }
                }
                .onChange(of: minutesForDMSView) {
                    updateDegreesFromDMS()
                }
            }
            Text("'")
            
            if !showSecondsPicker {
                Text("\(seconds)")
                //.frame(width: 100, height: 35, alignment: .trailing)
                    .onTapGesture {
                        toggleViewOfSelectedPicker(.Seconds, hideAll: false)
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
                    updateDegreesFromDMS()
                }
            }
            Text("\"")
        }
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
        minutesForRaymarineView = intMinutes
        let dblSeconds = (fractionalMinutes - Double(intMinutes)) * 60
        let intSeconds = Int(dblSeconds)
        seconds = intSeconds
        minutesInDecimalFormat = CalculateDecimalMinutesFromMinutesAndSeconds(minutes: minutesForRaymarineView, seconds: seconds)
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
    //print("Degrees in extractTenth: \(String(degrees))")
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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
    let degreesRounded = Double(degrees).rounded(toPlaces: 3)
    let strDegrees = String(degreesRounded)
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

