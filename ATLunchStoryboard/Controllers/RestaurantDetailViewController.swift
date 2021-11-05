//
//  RestaurantDetailViewController.swift
//  ATLunchStoryboard
//
//  Created by Hector Castillo on 11/4/21.
//

import UIKit
import SnapKit
import SDWebImage

class RestaurantDetailViewController: UIViewController {

    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = .white
        return view
    }()

    private var titleLabel: UILabel = {
        return UILabel()
    }()

    private var totalRatingsLabel: UILabel = {
        return UILabel()
    }()

    private var restaurantImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let restaurant: Restaurant

    init(restaurant: Restaurant){
        self.restaurant = restaurant
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        setupView()
    }

    func setupView() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints{ make in
            make.top.left.right.bottom.equalToSuperview()
        }

        containerView.addSubview(restaurantImageView)
        restaurantImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview().offset(32)
        }

        if let photoRef = restaurant.photoReference {
            if let url = URL(string: GooglePlacesConstants.BaseURL + GooglePlacesConstants.Paths.PlacePhoto) {
                let referenceQuery = URLQueryItem(name: "photo_reference", value: photoRef)
                let widthQuery = URLQueryItem(name: "maxwidth", value: "400")
                let heightQuery = URLQueryItem(name: "maxheight", value: "400")
                let keyQuery = URLQueryItem(name: "key", value: GooglePlacesConstants.apiKey)
                if let finalizedURL = url.appending([referenceQuery,widthQuery,heightQuery,keyQuery]) {
                    restaurantImageView.sd_setImage(with: finalizedURL, placeholderImage: UIImage(systemName: "fork.knife.circle.fill")!)
                }
            }
        }

        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(restaurantImageView.snp.bottom)
        }
        titleLabel.text = restaurant.title

        containerView.addSubview(totalRatingsLabel)
        totalRatingsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
        }
        totalRatingsLabel.text = "\(restaurant.rating) (\(restaurant.userRatingsTotal))"
    }
}
