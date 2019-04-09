//
//  ItemSelectorViewController.swift
//  Action
//
//  Created by Keith Norman on 4/9/19.
//

import UIKit

protocol SelectorItem {
    var title: String { get }
}

extension String: SelectorItem {
    var title: String {
        return self
    }
}

struct IdentifiableItem: SelectorItem {
    let id: String
    let title: String
}

protocol ItemSelectorDelegate: NSObjectProtocol {
    func didSelectOtherOption(tag: String)
}

class ItemSelectorViewController<Item: SelectorItem>: UITableViewController {
    let rowHeight: CGFloat = 40.0
    var isUseAnotherEnabled = false
    var useAnotherTitle: String?

    weak var delegate: ItemSelectorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = rowHeight
        tableView.separatorStyle = .none
    }

    var items: [Item] = [] {
        didSet {
            setPreferredContentSize()
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if index < items.count {
            self.delegate?.didSelectOtherOption(tag: items[index].title)
        } else {
            //didTapUseAnother.onNext(())
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.font = UIFont(name: "InterUI-Medium", size: 14)
        let index = indexPath.row
        if index < items.count {
            cell.textLabel?.text = items[index].title
        } else {
            cell.textLabel?.text = useAnotherTitle
        }
        return cell
    }

    // MARK: - Private

    private func setPreferredContentSize() {
        let screenSize = UIScreen.main.bounds
        let count = items.count
        preferredContentSize = CGSize(
            width: screenSize.width * 0.95,
            height: min(rowHeight * CGFloat(count), screenSize.height * 0.95))
    }
}
