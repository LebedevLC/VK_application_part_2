//
//  UserGroupsViewController.swift
//  VK_application
//
//  Created by Сергей Чумовских  on 13.07.2021.
//

import SwiftUI
import Foundation
import RealmSwift

class UserGroupsViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    // для перехода по сеге
    var tapedInAvatar = false
    // для клавиатуры
    private var tapGesture: UITapGestureRecognizer?
    // данные групп
    private var afGroups = GroupsServices()
    
    var groupsAloma: [GroupsItems] = []
    var filteredGroups: [GroupsItems] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupsAloma()
    }
    
    // MARK: - БД
    
    // Делаем запрос в сеть для обновления БД
    private func getGroupsAloma() {
        afGroups.getMyGroups(userId: UserSession.shared.userId) {[weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadData()
                self.tableView.reloadData()
            }
        }
    }
    
    // Загрузка данных из Realm
    private func loadData() {
        do {
            let realm = try Realm()
            // Чтение из БД по параметру myOwnerId
            let groups = realm.objects(GroupsItems.self).filter("ownerId == %@", UserSession.shared.userId)
            self.groupsAloma = Array(groups)
            self.filteredGroups = self.groupsAloma
            self.tableView.reloadData()
        } catch { print(error) }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ProfileGroup2VC" else {return}
        if let vc = segue.destination as? ProfileGroupVC {
            guard let send = sender as? Int else {
                print("FAIL cast")
                return}
            searchBar.text = nil
            vc.groupID = send
        }
    }
}

// MARK: - Extension UserGroups: UISearchBarDelegate

extension UserGroupsViewController: UISearchBarDelegate {
    
    // функция активируется при изменении текста в searchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredGroups = []
        if searchText.isEmpty {
            filteredGroups = groupsAloma
        } else {
            // проходим по массиву groups в поиске введенных символов без учета регистра
            for group in groupsAloma {
                if group.name.lowercased().contains(searchText.lowercased()) {
                    filteredGroups.append(group)
                }
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Добавляем обработчик жестов, когда пользователь вызвал клавиаруту у UISearchBar
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tableView.addGestureRecognizer(tapGesture!)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Убираем обработчик нажатий, когда пользователь ткнул в другое место
        tableView.removeGestureRecognizer(tapGesture!)
        // Так-же обнуляем обработчик
        tapGesture = nil
    }
    
    @objc func hideKeyboard() {
        self.tableView?.endEditing(true)
    }
    
}

// MARK: - TableView

extension UserGroupsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UserGroupTableViewCell.reusedIdentifire, for: indexPath) as? UserGroupTableViewCell
        else {
            return UITableViewCell()
        }
        let group = filteredGroups[indexPath.row]
        cell.configure(group: group)
        cell.avatarTapped = { [weak self] in
            self?.tapedInAvatar = true
            self?.performSegue(withIdentifier: "ProfileGroup2VC", sender: group.id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              !indexPath.isEmpty
        else { return }
        let groupID = filteredGroups[indexPath.row].id
        showDeleteAlert(id: groupID)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ProfileGroup2VC", sender: filteredGroups[indexPath.row].id)
    }
    
}

// MARK: - Delete Alert

extension UserGroupsViewController {
    
    private func showDeleteAlert(id: Int) {
        let alertController = UIAlertController(title: "Удалить группу?", message: "Это действие действительно внесет изменения в ваш список групп", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            let leaveGroup = GroupsServices()
            leaveGroup.getLeaveGroup(groupID: id) {[weak self] result in
                guard self != nil else {
                    print("fail self")
                    return }
                switch result {
                case .success(let answer):
                    print("Leave to groupID = \(id) = \(answer)")
                case .failure:
                    print("Leave to gropID = \(id) = FAIL")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: {})
    }
}
