//
//  TaskModel.swift
//  Done
//
//  Created by Kirthi Maharaj on 2021/09/09.
//

import Foundation
import CoreData

protocol TasksDataManagerDelegate: AnyObject {
    func fetchTasksSuccess(model: TaskModel, success: Bool)
}

protocol TaskTableViewCellDelegate: AnyObject {
    
    func didSelect(taskTableViewCell: TaskViewCell, didSelect: Bool)
    
    func didDeselect(taskTableViewCell: TaskViewCell, didDeselect: Bool)
    
}


class TaskModel {
    
    var managedObjectContext: NSManagedObjectContext { persistentContainer.viewContext }
    private var persistentContainer: NSPersistentContainer
    var task: [Tasks] = []
    //var taskD = [[Tasks](), [Tasks]()]
    
    var lastIndexTapped : Int = 0
    public weak var delegate: TasksDataManagerDelegate?
    var selectedSortType: SortModel = .sortDateAsc
    let sorting = Sorting()
    init(completionClosure: @escaping () -> ()) {
        persistentContainer = NSPersistentContainer(name: "Done")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completionClosure()
        }
    }
    
    var doneTaskEntities: [Tasks] {
        get {
            self.task.filter { taskEntity in
                taskEntity.isComplete
            }
        }
    }
    
    var count: Int {
        get {
            self.task.count
        }
    }
    
    
    func numberOfItemsFor(section: Int) -> Int {
        switch section {
        case 0:
            return task.filter({!$0.isComplete}).count
        case 1:
            return task.filter({$0.isComplete}).count
        default:
            fatalError("Too many sections")
        }
    }
    
    public func fetchTasks() {
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        fetchRequest.sortDescriptors = sorting.selectedSort + selectedSortType.getSortDescriptor()
        //fetchRequest.sortDescriptors = selectedSortType.getSortDescriptor()
        do {
            self.task = try self.managedObjectContext.fetch(fetchRequest)
            self.delegate?.fetchTasksSuccess(model: self, success: true)
        }
        catch {
            fatalError()
        }
    }
    
    
    func createTasks(_ task: DoneTask ,completion: @escaping (_ success: Bool)-> ()) {
        let newTask = Tasks(context: managedObjectContext)
        // newTask.colors =  task.color
        newTask.descriptions = task.descriptions
        newTask.dueDate = task.dueDate
        newTask.isComplete = task.isComplete
        newTask.name = task.name
        newTask.priorty = task.priorty
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
    public func saveTasks() {
        do {
            try self.managedObjectContext.save()
        }catch {
            fatalError()
        }
    }
    
    
    //    public func updatedTasks(_ task: DoneTask) {
    //        let update = Tasks(context: managedObjectContext)
    //
    //        // update.colors =  task.color
    //        update.descriptions = task.descriptions
    //        update.dueDate = task.dueDate
    //        update.isComplete = task.isComplete
    //        update.name = task.name
    //        update.priorty = task.priorty
    //        do {
    //            try self.managedObjectContext.save()
    //            fetchTasks()
    //        }catch {
    //            fatalError()
    //        }
    //
    //    }
    

    public func updateTask(task: DoneTask, atIndex index: Int) {
        guard index >= 0, index < self.count else {
            return
        }
        
        let entity = self.task[index]
        // entity.colors = task.color
        entity.descriptions = task.descriptions
        entity.dueDate = task.dueDate
        entity.isComplete = task.isComplete
        entity.name = task.name
        entity.priorty = entity.priorty

        
    }
    
    public func deleteTask(atIndex index: Int) {
        guard index >= 0, index < self.count, self.count > 0 else { return }
        
        let entity = self.task[index]
        self.managedObjectContext.delete(entity)
        
    }
    
    public func getTask(atIndex index: Int) -> DoneTask? {
        guard index >= 0, index < self.count else {
            return nil
        }
        let entity = self.task[index]
        
        let tasks = DoneTask(entity.descriptions ?? "empty description", entity.dueDate ?? Date(), entity.isComplete, entity.name ?? "empty name", Int(entity.priorty))
        
        return tasks
    }
 
}









//    public func createTask(_ task: DoneTask) {
//        let newTask = Tasks(context: self.managedObjectContext)
//        newTask.descriptions = task.descriptions
//        newTask.isComplete = task.isComplete
//        newTask.isDelete = task.isDelete
//        newTask.name = task.name
//
//    }
//        func fetchTasks(completion: @escaping (_ tasked: [DoneTask]) -> ()){
//            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
//            do {
//                let tasksData = try managedObjectContext.fetch(fetch) as! [Tasks]
//                let tasks = tasksData.compactMap { DoneTask(taskModel: $0) }
//                completion(tasks)
//            } catch {
//                fatalError("Could not save context: \(error)")
//            }
//        }
//
//    func getToday() -> DoneTask {
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
//
//    }

