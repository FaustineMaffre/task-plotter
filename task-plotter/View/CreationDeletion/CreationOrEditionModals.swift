//
//  CreationOrEditionModals.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Generics

enum CreationOrEditionMode: Identifiable {
    case creation, edition
    
    var id: CreationOrEditionMode { self }
}

struct CreationOrEditionModal<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    
    let mode: CreationOrEditionMode
    
    let titleText: String
    let propertiesView: () -> Content
    
    let modalSize: CGSize
    
    let createOrEditCondition: Bool
    
    let createOrEditAction: () -> Void
    let cancelAction: () -> Void
    let resetAction: () -> Void
    
    var createOrEditButtonText: String {
        switch self.mode {
        case .creation: return "Create"
        case .edition: return "Edit"
        }
    }
    
    init(mode: CreationOrEditionMode,
         titleText: String,
         propertiesView: @escaping () -> Content,
         modalSize: CGSize,
         createOrEditCondition: Bool,
         createOrEditAction: @escaping () -> Void,
         cancelAction: @escaping () -> Void = {},
         resetAction: @escaping () -> Void) {
        
        self.mode = mode
        
        self.titleText = titleText
        self.propertiesView = propertiesView
        
        self.modalSize = modalSize
        
        self.createOrEditCondition = createOrEditCondition
        
        self.createOrEditAction = createOrEditAction
        self.cancelAction = cancelAction
        self.resetAction = resetAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(self.titleText)
                .font(.headline)
            
            Spacer()
                .frame(height: 20)
            
            self.propertiesView()
            
            Spacer()
            
            HStack {
                Button("Cancel", action: self.cancel)
                    .keyboardShortcut(.cancelAction)
                
                Button(self.createOrEditButtonText, action: self.createOrEdit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!self.createOrEditCondition)
            }
        }
        .padding()
        .frame(width: self.modalSize.width, height: self.modalSize.height)
    }
    
    func createOrEdit() {
        if self.createOrEditCondition {
            self.createOrEditAction()
            
            self.presentationMode.wrappedValue.dismiss()
            self.resetAction()
        }
    }
    
    func cancel() {
        self.cancelAction()
        
        self.presentationMode.wrappedValue.dismiss()
        self.resetAction()
    }
}

// MARK: - View of labels, used in project and task

struct LabelSelectorLabelView: View {
    let label: Label
    
    var body: some View {
        Text(self.label.name)
            .foregroundColor(Label.foregroundOn(background: self.label.color))
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: self.label.color)))
    }
}

struct LabelsListView<BottomContent: View, TapContent: View, ContextContent: View>: View {
    let title: String?
    let labels: [Label]
    
    let onDropAction: (String, Int) -> Void
    let onTapContent: (Int) -> TapContent
    let contextMenuContent: (Int) -> ContextContent
    
    let bottomContent: () -> BottomContent
    
    @State var isOnTapPopoverPresentedIndex: Int? = nil
    
    init(title: String? = nil,
         labels: [Label],
         onDropAction: @escaping (String, Int) -> Void,
         onTapContent: @escaping (Int) -> TapContent,
         contextMenuContent: @escaping (Int) -> ContextContent,
         bottomContent: @escaping () -> BottomContent) {
        
        self.title = title
        self.labels = labels
        self.onDropAction = onDropAction
        self.onTapContent = onTapContent
        self.contextMenuContent = contextMenuContent
        self.bottomContent = bottomContent
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let title = self.title {
                Text(title)
                    .bold()
            }
            
            VStack(spacing: 0) {
                List {
                    ForEach(labels.isEmpty ? [-1] : Array(self.labels.indices), id: \.self) { labelIndex in
                        if labelIndex < 0 {
                            HStack {
                                Spacer()
                                Text("No label")
                                    .foregroundColor(Color.white.opacity(0.2))
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                LabelSelectorLabelView(label: self.labels[labelIndex])
                                Spacer()
                            }
                            .frame(height: 30)
                            .onTapGesture {
                                if TapContent.self != EmptyView.self {
                                    self.isOnTapPopoverPresentedIndex = labelIndex
                                }
                            }
                            .onDrag { NSItemProvider(object: self.labels[labelIndex].name as NSString) }
                            .contextMenu { self.contextMenuContent(labelIndex) }
                            .popover(isPresented: self.generateIsOnTapPopoverPresented(labelIndex: labelIndex), content: { self.onTapContent(labelIndex) })
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                    .onInsert(of: [UTType.plainText]) { index, items in
                        items.forEach { item in
                            _ = item.loadObject(ofClass: String.self) { str, _ in
                                if let labelName = str {
                                    self.onDropAction(labelName, index)
                                }
                            }
                        }
                    }
                }
                
                self.bottomContent()
            }
            .border(Color.white.opacity(0.1))
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
    
    func generateIsOnTapPopoverPresented(labelIndex: Int) -> Binding<Bool> {
        Binding {
            labelIndex == self.isOnTapPopoverPresentedIndex
        } set: {
            self.isOnTapPopoverPresentedIndex = $0 ? labelIndex : nil
        }
    }
}

extension LabelsListView where BottomContent == EmptyView, TapContent == EmptyView, ContextContent == EmptyView {
    init(title: String? = nil,
         labels: [Label],
         onDropAction: @escaping (String, Int) -> Void) {
        
        self.init(title: title,
                  labels: labels,
                  onDropAction: onDropAction,
                  onTapContent: { _ in EmptyView() },
                  contextMenuContent: { _ in EmptyView() },
                  bottomContent: { EmptyView() })
    }
}

// MARK: - Project

let projectModalSize = CGSize(width: 320, height: 420)

struct AvailableLabelColorsSelector: View {
    @Binding var selectedColor: String
    
    static let elementsByRow = Label.huesCount
    var rowCounts: Int {
        Label.availableColors.count / Self.elementsByRow
    }
    func colorAt(row: Int, column: Int) -> String {
        Label.availableColors[row * Self.elementsByRow + column]
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<self.rowCounts, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<Self.elementsByRow, id: \.self) { column in
                        let color = self.colorAt(row: row, column: column)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: color))
                                .frame(width: 24, height: 24)
                                .onTapGesture {
                                    self.selectedColor = color
                                }
                            
                            if color == self.selectedColor {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(Label.foregroundOn(background: color))
                                    .imageScale(.small)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProjectFormContent: View {
    @Binding var projectName: String
    @Binding var projectLabels: [Label]
    
    static let labelsWidth: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                Text("Name")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TextField("", text: self.$projectName)
            }
            
            HStack(alignment: .top, spacing: 20) {
                Text("Labels")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                
                VStack(spacing: 0) {
                    LabelsListView(labels: self.projectLabels,
                                   onDropAction: self.moveLabel,
                                   onTapContent: { labelIndex in
                                    VStack(spacing: 8) {
                                        TextField("", text: self.generateLabelNameBinding(labelIndex: labelIndex))
                                        AvailableLabelColorsSelector(selectedColor: self.generateLabelColorBinding(labelIndex: labelIndex))
                                    }
                                    .padding(10)
                                   },
                                   contextMenuContent: { labelIndex in
                                    Button("Delete") {
                                        // delete (without warning)
                                        self.deleteLabel(at: labelIndex)
                                    }
                                   },
                                   bottomContent: {
                                    CreateDeleteEditButton(image: Image(systemName: "plus"), text: "Create a label", action: self.createLabel)
                                   })
                }
            }
        }
    }
    
    func generateLabelNameBinding(labelIndex: Int) -> Binding<String> {
        Binding {
            if self.projectLabels.indices.contains(labelIndex) {
                return self.projectLabels[labelIndex].name
            } else {
                return "Oops"
            }
        } set: {
            if self.projectLabels.indices.contains(labelIndex) {
                self.projectLabels[labelIndex].name = $0
            }
        }
    }
    
    func generateLabelColorBinding(labelIndex: Int) -> Binding<String> {
        Binding {
            if self.projectLabels.indices.contains(labelIndex) {
                return self.projectLabels[labelIndex].color
            } else {
                return "Oops"
            }
        } set: {
            if self.projectLabels.indices.contains(labelIndex) {
                self.projectLabels[labelIndex].color = $0
            }
        }
    }
    
    func createLabel() {
        self.projectLabels.append(Label.nextAvailableLabel(labels: self.projectLabels))
    }
    
    func moveLabel(withName name: String, to index: Int) {
        DispatchQueue.main.async {
            if let taskLabelIndex = self.projectLabels.firstIndex(where: { $0.name == name }) {
                self.projectLabels.move(fromOffsets: IndexSet(arrayLiteral: taskLabelIndex), toOffset: index)
            }
        }
    }
    
    func deleteLabel(at index: Int) {
        self.projectLabels.remove(at: index)
    }
}

struct ProjectCreationModal: View {
    let repository: Repository
    
    @State var projectName: String = ""
    @State var projectLabels: [Label] = []
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Create a new project",
            propertiesView: {
                ProjectFormContent(projectName: self.$projectName, projectLabels: self.$projectLabels)
                
            }, modalSize: projectModalSize,
            createOrEditCondition: !self.projectName.isEmpty) {
            // create
            let newProject = Project(name: self.projectName,
                                     labels: self.projectLabels) 
            self.repository.addProject(newProject, selectIt: true)
            
        } resetAction: {
            // reset project name
            self.projectName = ""
        }
    }
}

struct ProjectEditionModal: View {
    let repository: Repository
    let projectIndex: Int
    
    @State var projectName: String
    @State var projectLabels: [Label]
    
    init(repository: Repository, projectIndex: Int) {
        self.repository = repository
        
        self.projectIndex = projectIndex
        
        let project = repository.projects[projectIndex]
        self._projectName = State(initialValue: project.name)
        self._projectLabels = State(initialValue: project.labels)
    }
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit project",
            propertiesView: {
                ProjectFormContent(projectName: self.$projectName, projectLabels: self.$projectLabels)
                
            }, modalSize: projectModalSize,
            createOrEditCondition: !self.projectName.isEmpty) {
            // edit
            self.repository.projects[projectIndex].name = self.projectName
            self.repository.projects[projectIndex].labels = self.projectLabels
            
        } resetAction: {
            // reset project name
            self.projectName = ""
        }
    }
}

// MARK: - Version

let versionModalSize = CGSize(width: 300, height: 130)

struct VersionFormContent: View {
    @Binding var versionNumber: String
    
    var body: some View {
        
        HStack(spacing: 20) {
            Text("Number")
            TextField("", text: self.$versionNumber)
        }
    }
}

struct VersionCreationModal: View {
    @Binding var project: Project
    
    @State var versionNumber: String = ""
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Add a new version",
            propertiesView: {
                VersionFormContent(versionNumber: self.$versionNumber)

            }, modalSize: versionModalSize,
            createOrEditCondition: !self.versionNumber.isEmpty) {
            // create
            let newVersion = Version(number: self.versionNumber)
            self.project.addVersion(newVersion, selectIt: true)

        } resetAction: {
            // reset version number
            self.versionNumber = ""
        }
    }
}

struct VersionEditionModal: View {
    @Binding var project: Project
    let versionIndex: Int
    
    @State var versionNumber: String
    
    init(project: Binding<Project>, versionIndex: Int) {
        self._project = project
        
        self.versionIndex = versionIndex
        
        let version = project.wrappedValue.versions[versionIndex]
        self._versionNumber = State(initialValue: version.number)
    }
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit version",
            propertiesView: {
                VersionFormContent(versionNumber: self.$versionNumber)

            }, modalSize: versionModalSize,
            createOrEditCondition: !self.versionNumber.isEmpty) {
            // edit
            self.project.versions[versionIndex].number = self.versionNumber

        } resetAction: {
            // reset project name
            self.versionNumber = ""
        }
    }
}

// MARK: - Task

let taskModalSize = CGSize(width: 500, height: 680)

struct TaskLabelSelector: View {
    @Binding var selectedLabels: [Label]
    let allLabels: [Label]
    
    var ҩavailableLabels: [Label] {
        self.allLabels.substracting(other: self.selectedLabels)
    }
    
    @State var isDropTargeted: Bool = false
    static let spacingBetweenLists: CGFloat = 8
    
    var body: some View {
        HStack {
            // available
            LabelsListView(title: "Available",
                           labels: self.ҩavailableLabels,
                           onDropAction: { labelName, _ in self.removeLabel(withName: labelName) })
            
            // added
            LabelsListView(title: "Selected",
                           labels: self.selectedLabels,
                           onDropAction: self.addLabel)
        }
    }
    
    func addLabel(withName name: String, at index: Int) {
        DispatchQueue.main.async {
            if let availableLabel = self.ҩavailableLabels.first(where: { $0.name == name }) {
                // inserting available label
                if self.selectedLabels.isEmpty {
                    // in case index would be outside bounds (because of empty labels)
                    self.selectedLabels.append(availableLabel)
                } else {
                    self.selectedLabels.insert(availableLabel, at: index)
                }
            } else if let taskLabelIndex = self.selectedLabels.firstIndex(where: { $0.name == name }) {
                // label not available, we are moving a label in the same list
                self.selectedLabels.move(fromOffsets: IndexSet(arrayLiteral: taskLabelIndex), toOffset: index)
            }
        }
    }
    
    func removeLabel(withName name: String) {
        DispatchQueue.main.async {
            self.selectedLabels.remove(name, by: \.name)
        }
    }
}

struct TaskFormContent: View {
    let labels: [Label]
    
    @Binding var taskTitle: String
    @Binding var taskLabels: [Label]
    @Binding var taskDescription: String
    @Binding var taskCost: Double?
    
    static let labelsWidth: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                Text("Title")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TextField("", text: self.$taskTitle)
            }
            
            HStack(alignment: .top, spacing: 20) {
                Text("Description")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TextEditor(text: self.$taskDescription)
                    .font(.body)
                    .border(Color.white.opacity(0.1))
            }
            
            HStack(alignment: .top, spacing: 20) {
                Text("Labels")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TaskLabelSelector(selectedLabels: self.$taskLabels, allLabels: self.labels)
            }
            
            // cost is not saved when tapping the edit button if we use a formatter (maybe because optional?)
            // so we use a string and convert it in onAppear (double? -> string) and edit (string -> double?)
            HStack(spacing: 20) {
                Text("Estimated cost")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TextField("", text: self.generateCostBinding())
            }
        }
    }
    
    func generateCostBinding() -> Binding<String> {
        Binding {
            Common.costFormatter.string(for: self.taskCost) ?? ""
        } set: {
            if $0.isEmpty {
                // empty cost string: no cost
                self.taskCost = nil
            } else if let parsedCost = Common.costFormatter.number(from: $0) {
                // non-empty cost string that can be parsed: set cost
                self.taskCost = parsedCost.doubleValue
            }
            // non-empty cost string that cannot be parsed: cost not updated
        }
    }
}

struct TaskCreationModal: View {
    @Binding var version: Version
    
    let labels: [Label]
    let column: Column
    
    @State var taskTitle: String = ""
    @State var taskLabels: [Label] = []
    @State var taskDescription: String = ""
    @State var taskCost: Double? = nil
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Add a new task",
            propertiesView: {
                TaskFormContent(labels: self.labels,
                                taskTitle: self.$taskTitle,
                                taskLabels: self.$taskLabels,
                                taskDescription: self.$taskDescription,
                                taskCost: self.$taskCost)
                
            }, modalSize: taskModalSize,
            createOrEditCondition: !self.taskTitle.isEmpty) {
            // create
            let newTask = Task(title: self.taskTitle,
                               labels: self.taskLabels,
                               description: self.taskDescription,
                               cost: self.taskCost)
            self.version.addTask(column: self.column, newTask)
            
        } resetAction: {
            // reset task title, labels, description, cost
            self.taskTitle = ""
            self.taskLabels = []
            self.taskDescription = ""
            self.taskCost = nil
        }
    }
}

struct TaskEditionModal: View {
    @Binding var version: Version
    
    let labels: [Label]
    let column: Column
    
    let taskIndex: Int
    
    @State var taskTitle: String
    @State var taskLabels: [Label]
    @State var taskDescription: String
    @State var taskCost: Double?
    
    init(version: Binding<Version>, labels: [Label], column: Column, taskIndex: Int) {
        self._version = version
        
        self.labels = labels
        self.column = column
        self.taskIndex = taskIndex
        
        let task = version.wrappedValue.tasksByColumn[column]![taskIndex]
        self._taskTitle = State(initialValue: task.title)
        self._taskLabels = State(initialValue: task.labels)
        self._taskDescription = State(initialValue: task.description)
        self._taskCost = State(initialValue: task.cost)
    }
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit task",
            propertiesView: {
                TaskFormContent(labels: self.labels,
                                taskTitle: self.$taskTitle,
                                taskLabels: self.$taskLabels,
                                taskDescription: self.$taskDescription,
                                taskCost: self.$taskCost)
                
            }, modalSize: taskModalSize,
            createOrEditCondition: !self.taskTitle.isEmpty) {
            // edit
            self.version.tasksByColumn[self.column]![self.taskIndex].title = self.taskTitle
            self.version.tasksByColumn[self.column]![self.taskIndex].labels = self.taskLabels
            self.version.tasksByColumn[self.column]![self.taskIndex].description = self.taskDescription
            self.version.tasksByColumn[self.column]![self.taskIndex].cost = self.taskCost
            
        } resetAction: {
            // reset task title, labels, description, cost
            self.taskTitle = ""
            self.taskLabels = []
            self.taskDescription = ""
            self.taskCost = nil
        }
    }
}

