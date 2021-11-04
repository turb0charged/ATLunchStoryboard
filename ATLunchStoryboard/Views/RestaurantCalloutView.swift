//
//  RestaurantAnnotationView.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 11/3/21.
//

import UIKit
import SnapKit
import MapKit
import SDWebImageMapKit

class RestaurantCalloutView:  UIView{
    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = .white
        view.layer.cornerRadius = 16.0
        return view
    }()

    private var titleLabel: UILabel = {
        return UILabel()
    }()

    private var totalRatingsLabel: UILabel = {
        return UILabel()
    }()

    private var supportingTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Supporting Text"
        return label
    }()

    private var restaurantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    fileprivate let fullStarImage: UIImage = UIImage(systemName: "star.fill")!
    fileprivate let halfStarImage: UIImage = UIImage(systemName: "star.lefthalf.fill")!
    fileprivate let emptyStarImage: UIImage = UIImage(systemName: "star")!

    init(annotation: MKAnnotation?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))

        if let restaurantAnnotation = annotation as? Restaurant {
            titleLabel.text = restaurantAnnotation.title
            totalRatingsLabel.text = "\(restaurantAnnotation.rating) (\(restaurantAnnotation.userRatingsTotal))"
            supportingTextLabel.text = restaurantAnnotation.priceLevelString + " * Supporting Text"

            if let photoRef = restaurantAnnotation.photoReference {
                if let url = URL(string: GooglePlacesConstants.BaseURL + GooglePlacesConstants.Paths.PlacePhoto) {
                    let referenceQuery = URLQueryItem(name: "photo_reference", value: photoRef)
                    let widthQuery = URLQueryItem(name: "maxwidth", value: "50")
                    let heightQuery = URLQueryItem(name: "maxheight", value: "50")
                    let keyQuery = URLQueryItem(name: "key", value: "AIzaSyDQSd210wKX_7cz9MELkxhaEOUhFP0AkSk")
                    if let finalizedURL = url.appending([referenceQuery,widthQuery,heightQuery,keyQuery]) {
                        restaurantImageView.sd_setImage(with: finalizedURL, placeholderImage: UIImage(systemName: "fork.knife.circle.fill")!)
                    }
                }
            }
            setupView()
        }
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(containerView)
        containerView.snp.makeConstraints{ make in
            make.top.left.right.bottom.equalToSuperview()
        }

        containerView.addSubview(restaurantImageView)
        restaurantImageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(4)
        }

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(restaurantImageView.snp.right)
            make.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }

        containerView.addSubview(totalRatingsLabel)
        totalRatingsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(restaurantImageView.snp.right)
            make.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }

        containerView.addSubview(supportingTextLabel)
        supportingTextLabel.snp.makeConstraints { make in
            make.top.equalTo(totalRatingsLabel.snp.bottom)
            make.left.equalTo(restaurantImageView.snp.right)
            make.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }
    }
}

extension URL {
        /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
        /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
                // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
            // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

            // return the url from new url components
        return urlComponents.url
    }
}
