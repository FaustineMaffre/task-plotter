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
    let labelIds: [LabelID]
    let projectLabels: IndexedArray<Label, LabelID>
    
    let onDropAction: (Label, Int) -> Void
    let onTapContent: (Int) -> TapContent
    let contextMenuContent: (Int) -> ContextContent
    
    let bottomContent: () -> BottomContent
    
    @State var isOnTapPopoverPresentedIndex: Int? = nil
    
    init(title: String? = nil,
         labelIds: [LabelID],
         projectLabels: IndexedArray<Label, LabelID>,
         onDropAction: @escaping (Label, Int) -> Void,
         onTapContent: @escaping (Int) -> TapContent,
         contextMenuContent: @escaping (Int) -> ContextContent,
         bottomContent: @escaping () -> BottomContent) {
        
        self.title = title
        self.labelIds = labelIds
        self.projectLabels = projectLabels
        
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
                    ForEach(self.labelIds.isEmpty ? [-1] : Array(self.labelIds.indices), id: \.self) { labelIndex in
                        if labelIndex < 0 {
                            HStack {
                                Spacer()
                                Text("No label")
                                    .foregroundColor(Color.white.opacity(0.2))
                                Spacer()
                            }
                        } else {
                            if let label = self.projectLabels.find(by: self.labelIds[labelIndex]) {
                                HStack {
                                    Spacer()
                                    LabelSelectorLabelView(label: label)
                                    Spacer()
                                }
                                .frame(height: 30)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if TapContent.self != EmptyView.self {
                                        self.isOnTapPopoverPresentedIndex = labelIndex
                                    }
                                }
                                .onDrag { DraggedElement.toItemProvider(label: label) }
                                .contextMenu { self.contextMenuContent(labelIndex) }
                                .popover(isPresented: self.generateIsOnTapPopoverPresented(labelIndex: labelIndex), content: { self.onTapContent(labelIndex) })
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                    }
                    .onInsert(of: [UTType.plainText]) { index, items in
                        items.forEach { item in
                            DraggedElement.toLabel(itemProvider: item, labels: self.projectLabels) {
                                if let label = $0 {
                                    self.onDropAction(label, index)
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
         labelIds: [LabelID],
         projectLabels: IndexedArray<Label, LabelID>,
         onDropAction: @escaping (Label, Int) -> Void) {
        
        self.init(title: title,
                  labelIds: labelIds,
                  projectLabels: projectLabels,
                  onDropAction: onDropAction,
                  onTapContent: { _ in EmptyView() },
                  contextMenuContent: { _ in EmptyView() },
                  bottomContent: { EmptyView() })
    }
}

// MARK: - Project

let projectModalSize = CGSize(width: 360, height: 540)

struct AvailableLabelColorsSelector: View {
    @Binding var selectedColor: String
    
    static let elementsByRow = Label.huesCount + 1
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
    @Binding var projectLabels: IndexedArray<Label, LabelID>
    
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
                    LabelsListView(labelIds: self.projectLabels.map(\.id),
                                   projectLabels: self.projectLabels,
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
    
    func moveLabel(label: Label, to index: Int) {
        DispatchQueue.main.async {
            if let taskLabelIndex = self.projectLabels.firstIndex(where: { $0.id == label.id }) {
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
    @State var projectLabels: IndexedArray<Label, LabelID> = IndexedArray<Label, LabelID>(id: \.id)
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Create a new project",
            propertiesView: {
                ProjectFormContent(projectName: self.$projectName, projectLabels: self.$projectLabels)
                
            }, modalSize: projectModalSize,
            createOrEditCondition: !self.projectName.isEmpty) {
            // create
            let newProject = Project(name: self.projectName, labels: self.projectLabels.elements) 
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
    @State var projectLabels: IndexedArray<Label, LabelID>
    
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
            var newVersion = Version(number: self.versionNumber)
            
            // get points per day/working days/hours from previous version, if there is one
            if let lastVersion = self.project.versions.last {
                newVersion.pointsPerDay = lastVersion.pointsPerDay
                newVersion.workingDays = lastVersion.workingDays
                newVersion.workingHours = lastVersion.workingHours
            }
            
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

let taskModalSize = CGSize(width: 600, height: 720)

struct TaskLabelSelector: View {
    @Binding var selectedLabelIds: [LabelID]
    let projectLabels: IndexedArray<Label, LabelID>
    
    var ҩavailableLabels: [LabelID] {
        self.projectLabels.map(\.id).substracting(other: self.selectedLabelIds)
    }
    
    @State var isDropTargeted: Bool = false
    static let spacingBetweenLists: CGFloat = 8
    
    var body: some View {
        HStack {
            // available
            LabelsListView(title: "Available",
                           labelIds: self.ҩavailableLabels,
                           projectLabels: self.projectLabels,
                           onDropAction: { label, _ in self.removeLabel(label: label) })
            
            // added
            LabelsListView(title: "Selected",
                           labelIds: self.selectedLabelIds,
                           projectLabels: self.projectLabels,
                           onDropAction: self.addLabel)
        }
    }
    
    func addLabel(label: Label, at index: Int) {
        DispatchQueue.main.async {
            if let availableLabel = self.ҩavailableLabels.first(where: { $0 == label.id }) {
                // inserting available label
                if self.selectedLabelIds.isEmpty {
                    // in case index would be outside bounds (because of empty labels)
                    self.selectedLabelIds.append(availableLabel)
                } else {
                    self.selectedLabelIds.insert(availableLabel, at: index)
                }
            } else if let taskLabelIndex = self.selectedLabelIds.firstIndex(where: { $0 == label.id }) {
                // label not available, we are moving a label in the same list
                self.selectedLabelIds.move(fromOffsets: IndexSet(arrayLiteral: taskLabelIndex), toOffset: index)
            }
        }
    }
    
    func removeLabel(label: Label) {
        DispatchQueue.main.async {
            self.selectedLabelIds.remove(label.id)
        }
    }
}

struct TaskFormContent: View {
    let projectLabels: IndexedArray<Label, LabelID>
    
    @Binding var taskTitle: String
    @Binding var taskLabels: [LabelID]
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
                TaskLabelSelector(selectedLabelIds: self.$taskLabels, projectLabels: self.projectLabels)
            }
            .frame(height: 400)
            
            // cost is not saved when tapping the edit button if we use a formatter (maybe because optional?)
            // so we use a string and convert it in onAppear (double? -> string) and edit (string -> double?)
            HStack(spacing: 20) {
                Text("Estimated cost")
                    .frame(width: Self.labelsWidth, alignment: .leading)
                TextField("", text: self.$taskCost.stringBinding(formatter: Common.costFormatter))
                    .frame(width: 60)
                Spacer()
            }
        }
    }
}

struct TaskCreationModal: View {
    @Binding var project: Project
    @Binding var version: Version
    
    let projectLabels: IndexedArray<Label, LabelID>
    let column: Column? // nil for tasks pool
    
    @State var taskTitle: String = ""
    @State var taskLabels: [LabelID] = []
    @State var taskDescription: String = ""
    @State var taskCost: Double? = nil
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Add a new task",
            propertiesView: {
                TaskFormContent(projectLabels: self.projectLabels,
                                taskTitle: self.$taskTitle,
                                taskLabels: self.$taskLabels,
                                taskDescription: self.$taskDescription,
                                taskCost: self.$taskCost)
                
            }, modalSize: taskModalSize,
            createOrEditCondition: !self.taskTitle.isEmpty) {
            // create
            let column = Column.columnTasksBinding(project: self.$project, version: self.$version, column: self.column)
            let newTask = Task(title: self.taskTitle,
                               labelIds: self.taskLabels,
                               description: self.taskDescription,
                               cost: self.taskCost)
            column.wrappedValue.append(newTask)
            
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
    @Binding var project: Project
    @Binding var version: Version
    
    let projectLabels: IndexedArray<Label, LabelID>
    let column: Column?
    
    let taskIndex: Int
    
    @State var taskTitle: String
    @State var taskLabelIds: [LabelID]
    @State var taskDescription: String
    @State var taskCost: Double?
    
    init(project: Binding<Project>, version: Binding<Version>, projectLabels: IndexedArray<Label, LabelID>, column: Column?, taskIndex: Int) {
        self._version = version
        self._project = project
        
        self.projectLabels = projectLabels
        self.column = column
        self.taskIndex = taskIndex
        
        let task = Column.columnTasksBinding(project: project, version: version, column: column).wrappedValue[taskIndex]
        self._taskTitle = State(initialValue: task.title)
        self._taskLabelIds = State(initialValue: task.labelIds)
        self._taskDescription = State(initialValue: task.description)
        self._taskCost = State(initialValue: task.cost)
    }
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit task",
            propertiesView: {
                TaskFormContent(projectLabels: self.projectLabels,
                                taskTitle: self.$taskTitle,
                                taskLabels: self.$taskLabelIds,
                                taskDescription: self.$taskDescription,
                                taskCost: self.$taskCost)
                
            }, modalSize: taskModalSize,
            createOrEditCondition: !self.taskTitle.isEmpty) {
            // edit
            let column = Column.columnTasksBinding(project: self.$project, version: self.$version, column: self.column)
            column.wrappedValue[self.taskIndex].title = self.taskTitle
            column.wrappedValue[self.taskIndex].labelIds = self.taskLabelIds
            column.wrappedValue[self.taskIndex].description = self.taskDescription
            column.wrappedValue[self.taskIndex].cost = self.taskCost
            
        } resetAction: {
            // reset task title, labels, description, cost
            self.taskTitle = ""
            self.taskLabelIds = []
            self.taskDescription = ""
            self.taskCost = nil
        }
    }
}

