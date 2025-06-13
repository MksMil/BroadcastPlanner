//
//  UpdateDelegateProtocol.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.06.2025.
//


protocol UpdateDelegateProtocol: AnyObject {
    func sync<DTO: CoreDataRepresentable>(with dtos: [DTO])
    func updateWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO)
    func removeWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO)
}