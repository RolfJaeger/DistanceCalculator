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
    
    @State private var plusMinusTarget: PlusMinusTarget = .THOUSANDTH
    
    @State private var isDegreesEditable = false
    @State private var isMinutesEditable = false
    @State private var isSecondsEditable = false
    @State private var isTenthEditable = false
    @State private var isHundredthEditable = false
    @State private var isThousandthEditable = true
    @State private var isTenThousandthEditable = false
    
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
            if sizeClass == .regular {
                switch viewFormat {
                case .DMS:
                    DMS_View_iPad
                case .DDM:
                    DecimalDegrees_View_iPad
                case .Raymarine:
                    Raymarine_View_iPad
                }
            } else {
                switch viewFormat {
                case .DMS:
                    DMS_View
                case .DDM:
                    DecimalDegrees_View
                case .Raymarine:
                    Raymarine_View
                }
            }
            Spacer()
        }
    }
    
    fileprivate var DecimalDegrees_View: some View {
        VStack(alignment: .center) {
            if sizeClass == .regular {
                HStack {
                    DecimalDegreesDetails_iPad
                    PlusMinusInDecimalDegreesView_iPad
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
            Instructions
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var Instructions: some View {
        VStack {
            Text("Tap and scroll or select the position")
            HStack {
                Text("you would like to edit by tapping on")
                Image(systemName: "applepencil.tip")
            }
            HStack {
                Text("and using the")
                Image(systemName: "plus.square")
                Text("and the")
                Image(systemName: "minus.square")
                Text("buttons.")
            }
        }
        .font(.footnote)
    }
    
    fileprivate var Instructions_iPad: some View {
        VStack {
            Text("Tap and scroll or select the position")
            HStack {
                Text("you would like to edit by tapping on")
                Image(systemName: "applepencil.tip")
            }
            HStack {
                Text("and using the")
                Image(systemName: "plus.square")
                Text("and the")
                Image(systemName: "minus.square")
                Text("buttons.")
            }
        }
        .font(Font.system(size: hintFont, weight: .regular, design: .default))
    }
    
    fileprivate var DecimalDegrees_View_iPad: some View {
        VStack(alignment: .center) {
            VStack {
                DecimalDegreesDetails_iPad
                PlusMinusInDecimalDegreesView_iPad
            }
            .font(Font.system(size: dataFont, weight: .regular, design: .default))
            .bold()
            Instructions_iPad
                .font(Font.system(size: hintFont, weight: .regular, design: .default))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            
        }
    }
    
    fileprivate var DecimalDegreesDetails: some View {
        HStack {
            if !showDegreesPicker {
                VStack {
                    Text("\(Int(decimalDegrees))")
                        .onTapGesture {
                            togglePickerVisibility(.Degrees)
                        }
                    VStack {
                        if isDegreesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isDegreesEditable = false
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isDegreesEditable = true
                                    isTenthEditable = false
                                    isHundredthEditable = false
                                    isThousandthEditable = false
                                    plusMinusTarget = .DEGREES
                                }
                        }
                    }
                    .padding(.top, 5)
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
            VStack {
                Text(".")
                    .padding(.leading, -10)
                Text("")
            }
            .padding(.bottom, 40)
            
            if !showTenthPicker {
                VStack {
                    Text("\(degreeTenth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Tenth)
                        }
                    VStack {
                        if isTenthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isTenthEditable = false
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isDegreesEditable = false
                                    isTenthEditable = true
                                    isHundredthEditable = false
                                    isThousandthEditable = false
                                    plusMinusTarget = .TENTH
                                }
                        }
                    }
                    .padding(.top, 5)
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
                VStack {
                    Text("\(degreeHundredth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Hundredth)
                        }
                    VStack {
                        if isHundredthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isHundredthEditable = false
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isDegreesEditable = false
                                    isTenthEditable = false
                                    isHundredthEditable = true
                                    isThousandthEditable = false
                                    plusMinusTarget = .HUNDREDTH
                                }
                        }
                    }
                    .padding(.top, 5)
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
                VStack {
                    Text("\(degreeThousandth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Thousandth)
                        }
                    VStack {
                        if isThousandthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isThousandthEditable = false
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 20, weight: .bold))
                                .onTapGesture {
                                    isDegreesEditable = false
                                    isTenthEditable = false
                                    isHundredthEditable = false
                                    isThousandthEditable = true
                                    plusMinusTarget = .THOUSANDTH
                                }
                        }
                    }
                    .padding(.top, 5)
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
                .padding(.bottom, 50)
        }
    }
    
    fileprivate func SwitchEdibility(target: PlusMinusTarget) {
        
        togglePickerVisibility()
        
        isDegreesEditable = false
        isMinutesEditable = false
        isSecondsEditable = false
        isTenthEditable = false
        isHundredthEditable = false
        isThousandthEditable = false
        isTenThousandthEditable = false
        
        switch target {
        case .DEGREES:
            isDegreesEditable = true
        case .MINUTES:
            isMinutesEditable = true
        case .SECONDS:
            isSecondsEditable = true
        case .TENTH:
            isTenthEditable = true
        case .HUNDREDTH:
            isHundredthEditable = true
        case .THOUSANDTH:
            isThousandthEditable = true
        case .TENTHOUSANDTH:
            isTenThousandthEditable = true
        }
    }
    
    
    fileprivate var DecimalDegreesDetails_iPad: some View {
        HStack {
            if !showDegreesPicker {
                VStack {
                    Text("\(Int(decimalDegrees))")
                        .onTapGesture {
                            togglePickerVisibility(.Degrees)
                        }
                    VStack {
                        if isDegreesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .DEGREES
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $degrees) {
                        ForEach(0...maxDegrees, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 120, height: 100)
                    .onChange(of: degrees) {
                        updateDegreesValue()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            VStack {
                Text(".")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showTenthPicker {
                VStack {
                    Text("\(degreeTenth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Tenth)
                        }
                    VStack {
                        if isTenthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .TENTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $degreeTenth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onAppear {
                        degreeTenth = Int(extractTenth(degrees: decimalDegrees))!
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
                .onChange(of: degreeTenth) {
                    updateDegreesValueDecimalDegreesFormat()
                }
            }
            
            if !showHundredthPicker {
                VStack {
                    Text("\(degreeHundredth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Hundredth)
                        }
                    VStack {
                        if isHundredthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .HUNDREDTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $degreeHundredth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onAppear {
                        degreeHundredth = Int(extractHundredth(degrees: decimalDegrees))!
                    }
                    .onChange(of: degreeHundredth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            if !showThousandthPicker {
                VStack {
                    Text("\(degreeThousandth)")
                        .padding(.leading, -5)
                        .onTapGesture {
                            togglePickerVisibility(.Thousandth)
                        }
                    VStack {
                        if isThousandthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .THOUSANDTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $degreeThousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onAppear {
                        degreeThousandth = Int(extractThousandth(degrees: decimalDegrees))!
                    }
                    .onChange(of: degreeThousandth) {
                        updateDegreesValueDecimalDegreesFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            VStack {
                Text("°")
                    .padding(.leading,-5)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
        }
        .font(Font.system(size: 80, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
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
    
    fileprivate func togglePickerVisibility(_ selectedPicker: PickerName? = nil) {
        showDegreesPicker = false
        showMinutesPicker = false
        showSecondsPicker = false
        showTenthPicker = false
        showHundredthPicker = false
        showThousandthPicker = false
        if selectedPicker != nil {
            switch selectedPicker {
            case .Degrees:
                showDegreesPicker.toggle()
            case .Minutes:
                showMinutesPicker.toggle()
            case .Seconds:
                showSecondsPicker.toggle()
            case .Tenth:
                showTenthPicker.toggle()
            case .Hundredth:
                showHundredthPicker.toggle()
            case .Thousandth:
                showThousandthPicker.toggle()
            default:
                _ = true
            }

            
        }
    }
    
    fileprivate var Raymarine_View: some View {
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
    
    fileprivate var Raymarine_View_iPad: some View {
        VStack(alignment: .center) {
            VStack {
                RaymarineDetails_iPad
                PlusMinusInRaymarineView_iPad
            }
            .font(Font.system(size: dataFont, weight: .regular, design: .default))
            .bold()
            Instructions
                .font(Font.system(size: hintFont, weight: .regular, design: .default))
                .padding(.top,10)
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var RaymarineDetails: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
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
                        togglePickerVisibility(.Minutes)
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
                        togglePickerVisibility(.Tenth)
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
                        togglePickerVisibility(.Hundredth)
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
                        togglePickerVisibility(.Thousandth)
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
    
    fileprivate var RaymarineDetails_iPad: some View {
        HStack {
            if !showDegreesPicker {
                VStack {
                    Text("\(degrees)")
                        .onTapGesture {
                            togglePickerVisibility(.Degrees)
                        }
                    VStack {
                        if isDegreesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .DEGREES
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $degrees) {
                        ForEach(0...maxDegrees, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 120, height: 100)
                    .onChange(of: degrees) {
                        updateDegreesValue()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            VStack {
                Text("\u{00B0}")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showMinutesPicker {
                VStack {
                    Text("\(minutesForRaymarineView)")
                        .padding(.leading,10)
                        .onTapGesture {
                            togglePickerVisibility(.Minutes)
                        }
                    VStack {
                        if isMinutesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .MINUTES
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $minutesForRaymarineView) {
                        ForEach(0...59, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 120, height: 100)
                    .onChange(of: minutesForRaymarineView) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            VStack {
                Text(".")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showTenthPicker {
                VStack {
                    Text("\(minuteTenth)")
                        .onTapGesture {
                            togglePickerVisibility(.Tenth)
                        }
                    VStack {
                        if isTenthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .TENTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $minuteTenth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteTenth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            if !showHundredthPicker {
                VStack {
                    Text("\(minuteHundredth)")
                        .padding(.leading,-5)
                        .onTapGesture {
                            togglePickerVisibility(.Hundredth)
                        }
                    VStack {
                        if isHundredthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .HUNDREDTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $minuteHundredth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteHundredth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            if !showThousandthPicker {
                VStack {
                    Text("\(minuteThousandth)")
                        .padding(.leading,-5)
                        .onTapGesture {
                            togglePickerVisibility(.Thousandth)
                        }
                    VStack {
                        if isThousandthEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .THOUSANDTH
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                VStack {
                    Picker("", selection: $minuteThousandth) {
                        ForEach(0...9, id: \.self) { value in
                            Text("\(value)")
                                .font(Font.system(size: 40, weight: .regular, design: .default))
                        }
                    }
                    .pickerStyle(.wheel)
                    .scaleEffect(2.0)
                    .frame(width: 50, height: 100)
                    .onChange(of: minuteThousandth) {
                        updateDegreesValueForRaymarineFormat()
                    }
                    Text(" ")
                        .font(.system(size: 30, weight: .bold))
                }
            }
            
            VStack {
                Text("'")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
        }
        .font(Font.system(size: 80, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
    }
    
    fileprivate var PlusMinusInRaymarineView: some View {
        HStack {
            Button(action: {
                PlusInRaymarineView()
            }, label: {
                Text("+")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
            Button(action: {
                MinusInRaymarineView()
            }, label: {
                Text("-")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInRaymarineView_iPad: some View {
        HStack {
            Button(action: {
                PlusInRaymarineView()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInRaymarineView()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDecimalDegreesView: some View {
        HStack {
            Button(action: {
                PlusInDecimalDegreeView()
            }, label: {
                Image(systemName: "plus.square")
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInDecimalDegreeView()
            }, label: {
                Image(systemName: "minus.square")
            })
            //.buttonStyle(.bordered)
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    fileprivate var PlusMinusInDecimalDegreesView_iPad: some View {
        HStack {
            Button(action: {
                PlusInDecimalDegreeView()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInDecimalDegreeView()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDMSView: some View {
        HStack {
            Button(action: {
                PlusInDMSView()
            }, label: {
                Text("+")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
            Button(action: {
                MinusInDMSView()
            }, label: {
                Text("-")
                    .font(.title3)
            })
            .buttonStyle(.bordered)
        }
    }
    
    fileprivate var PlusMinusInDMSView_iPad: some View {
        HStack {
            Button(action: {
                PlusInDMSView()
            }, label: {
                Image(systemName: "plus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
            Button(action: {
                MinusInDMSView()
            }, label: {
                Image(systemName: "minus.square")
                    .font(Font.system(size: 60, weight: .regular, design: .default))
            })
            //.buttonStyle(.bordered)
        }
    }
    
    fileprivate var DMS_View: some View {
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
    
    fileprivate var DMS_View_iPad: some View {
        VStack(alignment: .center) {
            VStack {
                DMSDetailsView_iPad
                PlusMinusInDMSView_iPad
            }
            .font(Font.system(size: dataFont, weight: .regular, design: .default))
            .bold()
            Instructions
                .font(Font.system(size: hintFont, weight: .regular, design: .default))
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var DMSDetailsView: some View {
        HStack {
            if !showDegreesPicker {
                Text("\(degrees)")
                    .onTapGesture {
                        togglePickerVisibility(.Degrees)
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
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
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
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
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
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            Text("\"")
        }
    }
    
    fileprivate var DMSDetailsView_iPad: some View {
        HStack {
            if !showDegreesPicker {
                VStack {
                    Text("\(degrees)")
                        .onTapGesture {
                            togglePickerVisibility(.Degrees)
                        }
                    VStack {
                        if isDegreesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .DEGREES
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                Picker("", selection: $degrees) {
                    ForEach(0...maxDegrees, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                .onChange(of: degrees) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            VStack {
                Text("\u{00B0}")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showMinutesPicker {
                VStack {
                    Text("\(minutesForDMSView)")
                        .onTapGesture {
                            togglePickerVisibility(.Minutes)
                        }
                    VStack {
                        if isMinutesEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .MINUTES
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                Picker("", selection: $minutesForDMSView) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                .onChange(of: minutesForDMSView) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            VStack {
                Text("'")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
            if !showSecondsPicker {
                VStack {
                    Text("\(seconds)")
                        .onTapGesture {
                            togglePickerVisibility(.Seconds)
                        }
                    VStack {
                        if isSecondsEditable {
                            Image(systemName: "pencil.and.outline")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    togglePickerVisibility()
                                }
                        } else {
                            Image(systemName: "applepencil.tip")
                                .font(.system(size: 30, weight: .bold))
                                .onTapGesture {
                                    plusMinusTarget = .SECONDS
                                    SwitchEdibility(target: plusMinusTarget)
                                }
                        }
                    }
                }
            } else {
                Picker("", selection: $seconds) {
                    ForEach(0...59, id: \.self) { value in
                        Text("\(value)")
                            .font(Font.system(size: 40, weight: .regular, design: .default))
                    }
                }
                .pickerStyle(.wheel)
                .scaleEffect(2.0)
                .frame(width: 120, height: 100)
                
                .onChange(of: seconds) {
                    locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
                }
            }
            
            VStack {
                Text("\"")
                    .padding(.leading, -10)
                    .padding(.bottom, 0)
                Text(" ")
                    .font(.system(size: 30, weight: .bold))
            }
            
        }
        .font(Font.system(size: 80, weight: .regular, design: .default))
        .padding(.top, 0)
        .padding(.bottom,5)
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
    
    fileprivate func updateDegreesFromDMS(degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
        let decimalMinutes = Double(minutes)/60
        let decimalSeconds = Double(seconds)/60/60
        return CLLocationDegrees(Double(degrees) + decimalMinutes + decimalSeconds)
    }
    
    fileprivate func updateDegreesFromDMS(originalDegrees: CLLocationDegrees, degrees: Int, minutes: Int, seconds: Int) -> CLLocationDegrees {
        //First calculate the original degrees in seconds
        let originalDegreesInSeconds = originalDegrees * 3600.0
        print("Original Degrees in Seconds: \(originalDegreesInSeconds)")
        //Now calculate the new degrees in seconds
        let newDegreesInSeconds = Double(degrees) * 3600.0
        let newMinutesInSeconds = Double(minutes) * 60.0
        let newTotalInSeconds = newDegreesInSeconds + newMinutesInSeconds + Double(seconds)
        print("New Degrees in Seconds: \(newTotalInSeconds)")
        //Now calculate the difference in seconds
        let secondsToAddOrSubtract = (newTotalInSeconds - originalDegreesInSeconds).rounded()
        print("Delta between Original and New: \(secondsToAddOrSubtract) sec")
        let degreesAfterUpdate = originalDegrees + secondsToAddOrSubtract/3600.0
        return degreesAfterUpdate
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
    
    fileprivate func PlusInRaymarineView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 { degrees += 1 }
        case .MINUTES:
            if minutesForRaymarineView < 59 { minutesForRaymarineView += 1 }
        case .SECONDS:
            _ = true
        case .TENTH:
            if minuteTenth < 9 { minuteTenth += 1 }
        case .HUNDREDTH:
            if minuteHundredth < 9 { minuteHundredth += 1 }
        case .THOUSANDTH:
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
        case .TENTHOUSANDTH:
            _ = true
        }
        
        updateDegreesValueForRaymarineFormat()
    }
    
    fileprivate func MinusInRaymarineView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForRaymarineView > 0 { minutesForRaymarineView -= 1 }
        case .SECONDS:
            let unused = true
        case .TENTH:
            if minuteTenth > 0 { minuteTenth -= 1 }
        case .HUNDREDTH:
            if minuteHundredth > 0 { minuteHundredth -= 1 }
        case .THOUSANDTH:
            if minuteThousandth > 0 { minuteThousandth -= 1 }
        case .TENTHOUSANDTH:
            let unused = true
        }
        updateDegreesValueForRaymarineFormat()
    }
    
    fileprivate func PlusInDecimalDegreeView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 {
                decimalDegrees += 1
            }
        case .MINUTES:
            _ = true
        case .SECONDS:
            _ = true
        case .TENTH:
            if degreeTenth  < 9 {
                degreeTenth += 1
            }
        case .HUNDREDTH:
            if degreeHundredth < 9 {
                degreeHundredth += 1
            }
        case .THOUSANDTH:
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
            
        case .TENTHOUSANDTH:
            _ = true
        }
        updateDegreesValueDecimalDegreesFormat()
    }
    
    fileprivate func MinusInDecimalDegreeView() {
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 {
                decimalDegrees -= 1
            }
        case .MINUTES:
            var dummy = 0
        case .SECONDS:
            var dummy = 0
        case .TENTH:
            if degreeTenth  > 0 {
                degreeTenth -= 1
            }
        case .HUNDREDTH:
            if degreeHundredth > 0 {
                degreeHundredth -= 1
            }
        case .THOUSANDTH:
            if degreeThousandth > 0 {
                degreeThousandth -= 1
            }
        case .TENTHOUSANDTH:
            var dummy = 0
        }
        updateDegreesValueDecimalDegreesFormat()
    }
    
    fileprivate func PlusInDMSView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees < maxDegrees - 1 {
                degrees += 1
            }
        case .MINUTES:
            if minutesForDMSView < 59 { minutesForDMSView += 1 }
        case .SECONDS:
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
        case .TENTH:
            _ = true
        case .HUNDREDTH:
            _ = true
        case .THOUSANDTH:
            _ = true
        case .TENTHOUSANDTH:
            _ = true
        }
        locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
    }

    fileprivate func MinusInDMSView() {
        
        togglePickerVisibility()
        
        switch plusMinusTarget {
        case .DEGREES:
            if degrees > 0 { degrees -= 1 }
        case .MINUTES:
            if minutesForDMSView > 0 { minutesForDMSView -= 1 }
        case .SECONDS:
            if seconds > 0 { seconds -= 1 }
        case .TENTH:
            _ = true
        case .HUNDREDTH:
            _ = true
        case .THOUSANDTH:
            _ = true
        case .TENTHOUSANDTH:
            _ = true
        }
        
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
        locDegrees = updateDegreesFromDMS(originalDegrees: locDegrees, degrees: degrees, minutes: minutesForDMSView, seconds: seconds)
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

struct PickerViewWithoutIndicator_iPad<Content: View, Selection: Hashable>: View {
    @Binding var selection: Selection
    var width: CGFloat
    @ViewBuilder var content: Content
    var body: some View {
        Picker("", selection: $selection) {
            content
        }
        .pickerStyle(.wheel)
        .frame(width: width)
        .frame(height: 150)
        .padding(.leading, 50)
    }
}

#Preview {
    @Previewable @State var viewFormat: ViewFormat = .DMS
    @Previewable @State var tmp = CLLocationDegrees(floatLiteral: 37.5899)
    @Previewable @State var orientation: String = "N"
    
    DegreesEntryView(orientation: orientation, locDegrees: $tmp, viewFormat: $viewFormat)
}

