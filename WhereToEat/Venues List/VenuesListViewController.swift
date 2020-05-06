//
//  VenuesListViewController.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import UIKit
import DeepDiff
import NotificationBannerSwift
import Kingfisher

class VenuesListViewController: UIViewController {
    private enum Constants {
        static let venueReuseIdentifier = "Venue"
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var errorView: UIStackView!
    
    @IBOutlet private weak var errorReloadButton: UIButton!
    
    private var imagePrefetcher: ImagePrefetcher?
    
    private var tableViewSeparatorInset: UIEdgeInsets {
        let leftInset = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 16 : 84
        return UIEdgeInsets(top: 0, left: CGFloat(leftInset), bottom: 0, right: 0)
    }
    
    private var props: VenuesListProps?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        props?.onAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        props?.onDisappear()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTableViewSeparatorInset()
    }
        
    private func setupView() {
        setupTableView()
        setupErrorReloadButton()
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(VenueCollectionViewCell.self, forCellReuseIdentifier: Constants.venueReuseIdentifier)
        tableView.separatorInset = tableViewSeparatorInset
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func setupErrorReloadButton() {
        errorReloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        errorReloadButton.titleLabel?.adjustsFontForContentSizeCategory = true
        errorReloadButton.titleLabel?.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(for: UIFont.systemFont(ofSize: 15))
    }
    
    private func updateTableViewSeparatorInset() {
        tableView.separatorInset = tableViewSeparatorInset
    }
    
    @objc private func reload() {
        props?.onReload()
    }
    
    private func showError(with message: String) {
        if props?.venues?.isEmpty ?? true {
            self.errorView.isHidden = false
        }
        
        showErrorBanner(with: message)
    }
    
    private func showErrorBanner(with message: String) {
        guard NotificationBannerQueue.default.numberOfBanners <= 1 else { return }
        let banner = StatusBarNotificationBanner(title: message, style: .danger)
        banner.show(on: self)
    }
}

extension VenuesListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let venues = props?.venues else { return }
        let urls = indexPaths.compactMap { URL(string: venues[$0.row].imageUrl) }
        imagePrefetcher = ImagePrefetcher(urls: urls)
        imagePrefetcher?.start()
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        imagePrefetcher?.stop()
        imagePrefetcher = nil
    }
}

extension VenuesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props?.venues?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.venueReuseIdentifier, for: indexPath) as? VenueCollectionViewCell else  {
            assertionFailure("It seems the cell type isn't registered.")
            return UITableViewCell()
        }
        
        guard let venues = props?.venues, indexPath.row < venues.count else {
            // It seems it shouldn't happen.
            return UITableViewCell()
        }
        
        let venue = venues[indexPath.row]
        cell.configure(venue: venue) { [weak self] in
            self?.props?.onFavorite(venue)
        }
        
        return cell
    }
}

extension VenuesListViewController: VenuesListRenderer {
    func render(props: VenuesListProps) {
        guard isViewLoaded else {
            self.props = props
            return
        }
        
        activityIndicator.stopAnimating()
        
        guard props.error == nil, let newVenues = props.venues else {
            // TODO: Should think about a message based on the error
            showError(with: "Error!")
            return
        }
        
        errorView.isHidden = true
        
        let changes = diff(old: self.props?.venues ?? [], new: newVenues)
        tableView.reload(changes: changes, updateData: { [weak self] in
            self?.props = props
        })
    }
}

extension Venue: DiffAware {
    typealias DiffId = String
    
    var diffId: DiffId {
        return id
    }
    
    static func compareContent(_ old: Self, _ new: Self) -> Bool {
        return old.id == new.id
            && old.name == new.name
            && old.shortDescription == new.shortDescription
            && old.imageUrl == new.imageUrl
    }
}
