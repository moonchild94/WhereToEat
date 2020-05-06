//
//  VenueCollectionViewCell.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import UIKit
import Kingfisher

class VenueCollectionViewCell: UITableViewCell {
    private lazy var venueView: VenueView = {
        let view = VenueView()
        view.favoriteButton.addTarget(self, action: #selector(onFavorite), for: .touchUpInside)
        return view
    }()
    
    private var favorite: Bool = false
    private var onFavoriteAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        venueView.frame = contentView.bounds
        /* it's necessary because sometimes frame is changed but not size
         but frames in venue view have to be recalculated according new data. */
        venueView.setNeedsLayout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return venueView.sizeThatFits(size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clean()
    }
    
    func configure(venue: Venue, onFavoriteAction: @escaping () -> Void) {
        favorite = venue.favorite
        
        venueView.titleLabel.text = venue.name
        venueView.descriptionLabel.text = venue.shortDescription
        
        setupIcon(with: venue.imageUrl)
        setupFavorite(venue.favorite)
        
        self.onFavoriteAction = onFavoriteAction
    }
    
    private func clean() {
        venueView.iconImageView.kf.cancelDownloadTask()
        venueView.iconImageView.image = nil
    }
    
    private func setupIcon(with url: String) {
        venueView.iconImageView.kf.indicatorType = .activity
        
        let options: KingfisherOptionsInfo = [.scaleFactor(UIScreen.main.scale),
                                              .transition(.flipFromTop(1)),
                                              .processor(DownsamplingImageProcessor(size: venueView.iconImageView.frame.size))]
        venueView.iconImageView.kf.setImage(with: URL(string: url), options: options) { result in
            switch result {
            case .success:
                NSLog("Image load succeed for url: \(url)")
            case .failure(let error):
                NSLog("Image load failed for url: \(url). Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupFavorite(_ favorite: Bool) {
        let imageName = favorite ? Resources.Images.favorite : Resources.Images.unfavorite
        venueView.favoriteButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc private func onFavorite() {
        favorite = !favorite
        
        if let imageView = venueView.favoriteButton.imageView {
            UIView.transition(with: imageView,
                              duration: 0.7,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                                guard let self = self else { return }
                                self.setupFavorite(self.favorite)
            }) { _ in }
        }
        
        onFavoriteAction?()
    }
    
    private func setupView() {
        contentView.addSubview(venueView)
    }
}
