//
//  VenueView.swift
//  WhereToEat
//
//  Created by Daria Kalmykova on 29.04.2020.
//  Copyright © 2020 Daria Kalmykova. All rights reserved.
//

import UIKit

class VenueView: UIView {
    private enum Constants {
        static let iconSide: CGFloat = 60
        static let favoriteSide: CGFloat = 36
        static let inset: CGFloat = 8
    }
    
    // To adjust space between labels for dynamic type
    private var textInset: CGFloat {
        guard titleLabel.text?.isNotEmpty ?? false
            && descriptionLabel.text?.isNotEmpty ?? false else { return 0 }
        
        let font = UIFont.systemFont(ofSize: 4)
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: font).lineHeight
    }
    
    private var iconSide: CGFloat {
        return traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 0 : Constants.iconSide
    }
        
    lazy var iconImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(width: Constants.iconSide, height: Constants.iconSide))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let font = UIFont.systemFont(ofSize: 20, weight: .medium)
        view.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: font)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    lazy var favoriteButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textAreaWidth = size.width
            - layoutMargins.width
            - Constants.inset * 2
            - iconSide
            - Constants.favoriteSide
        
        let textAreaSize = size.with(width: textAreaWidth)
        let textAreaFittedHeight = titleLabel.sizeThatFits(textAreaSize).height
            + descriptionLabel.sizeThatFits(textAreaSize).height
            + layoutMargins.height
            + textInset

        return size.with(height: max(layoutMargins.height + iconSide, textAreaFittedHeight))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = self.bounds.inset(by: layoutMargins)
        
        let (iconArea, restArea) = rect.divided(atDistance: iconSide, from: .minXEdge)
        let (favoriteButtonFrame, textArea) = restArea.divided(atDistance: Constants.favoriteSide, from: .maxXEdge)
        
        let textAreaMinusInsets = textArea.insetBy(dx: Constants.inset, dy: 0)
        
        let titleLabelHeight = titleLabel.sizeThatFits(textAreaMinusInsets.size).height
        let descriptionLabelHeight = descriptionLabel.sizeThatFits(textAreaMinusInsets.size).height

        let labelsHeight = titleLabelHeight + descriptionLabelHeight + textInset
        let minimizedTextAreaSize = textAreaMinusInsets.size.with(height: labelsHeight)
        let minimizedTextArea = textAreaMinusInsets.centered(with: minimizedTextAreaSize)
        
        let (titleLabelFrame, descriptionLabelArea) = minimizedTextArea.divided(atDistance: titleLabelHeight, from: .minYEdge)
        let (_, descriptionLabelFrame) = descriptionLabelArea.divided(atDistance: textInset, from: .minYEdge)
        
        iconImageView.frame = iconArea.centered(with: CGSize(width: iconSide, height: iconSide))
        favoriteButton.frame = favoriteButtonFrame
        titleLabel.frame = titleLabelFrame
        descriptionLabel.frame = descriptionLabelFrame
    }
    
    private func setupView() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(favoriteButton)
    }
}

private extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
