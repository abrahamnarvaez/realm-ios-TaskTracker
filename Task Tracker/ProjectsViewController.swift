//
//  ProjectsViewController.swift
//
//
//  Created by MongoDB on 2020-05-04.
//

import Foundation
import UIKit
import RealmSwift

class ProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let userRealm: Realm
    var notificationToken: NotificationToken?
    var user: User?

    init(userRealm: Realm) {
        self.userRealm = userRealm

        super.init(nibName: nil, bundle: nil)

        // TODO: Observe user realm for user objects
        let usersInRealm = userRealm.objects(User.self)
        notificationToken = usersInRealm.observe { [weak self, usersInRealm] (changes) in
            self?.user = usersInRealm.first
            guard let tableView = self?.tableView else { return }
            tableView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // TODO: invalidate notificationToken
        notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the view.
        title = "Projects"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
        view.addSubview(tableView)

        // On the top left is a log out button.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonDidClick))
    }
    
    func openRealm(projectTitle: String, configuration: Realm.Configuration) {
        if UserDefaults.standard.bool(forKey: Constants.projectRealmHasOpenedAsync) {
            let realm = try! Realm(configuration: configuration)
            navigationController?.pushViewController(TasksViewController(realm: realm, title: projectTitle), animated: true)
        } else {
            UserDefaults.standard.setValue(true, forKey: Constants.projectRealmHasOpenedAsync)
            Realm.asyncOpen(configuration: configuration) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    fatalError("Failed to open realm: \(error)")
                case .success(let realm):
                    self?.navigationController?.pushViewController(
                        TasksViewController(realm: realm, title: projectTitle),
                        animated: true
                    );
                }
            }
        }
    }

    @objc func logOutButtonDidClick() {
        let alertController = UIAlertController(title: "Log Out", message: "", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "Yes, Log Out", style: .destructive, handler: {
            alert -> Void in
            print("Logging out...");
            app.currentUser?.logOut() { (error) in
                DispatchQueue.main.sync {
                    print("Logged out!");
                    self.view.window?.rootViewController = UINavigationController(rootViewController: WelcomeViewController())
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Each project should have its own row. Check the user memberOf
        // field for how many projects the user is a member of. However, the user
        // may not have loaded in yet. If that's the case, the user always has their
        // own project, so you should always return at least 1.
        // You always have at least one project (your own)
        return user?.memberOf.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none

        // TODO: Get project name using user's memberOf field and indexPath.row.
        // The user may not have loaded yet. Regardless, you always have your own project.
        let projectName = user?.memberOf[indexPath.row].name ?? "My Project"
        cell.textLabel?.text = projectName

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: open the realm for the selected project and navigate to the TasksViewController.
        // The project information is contained in the user's memberOf field.
        // The user may not have loaded yet. Regardless, the current user always has their own project.
        // A user's project partition value is "project=\(user.id!)". Use the user.configuration() with
        // the project's partition value to open the realm for that project.
        let currentUser = app.currentUser!
        let project = user?.memberOf[indexPath.row] ?? Project(partition: "project=\(currentUser.id)", name: "My Project")
        let projectTitle = "\(project.name!)'s Tasks"
        let configuration = currentUser.configuration(partitionValue: project.partition!)
        
        openRealm(projectTitle: projectTitle, configuration: configuration)
    }

}
