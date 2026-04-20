//
//  CityViewController.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import UIKit

final class CityViewController: UIViewController {
    
    private let viewModel: CityViewModel
    private var isShowingAlert = false
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var loadingContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading weather..."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var weatherContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 64, weight: .thin)
        label.textColor = .label
        return label
    }()
    
    private lazy var weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var detailsGridView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.image = UIImage(systemName: "magnifyingglass")
        return imageView
    }()
    
    private lazy var emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .label
        label.text = "No City Selected"
        return label
    }()
    
    private lazy var emptyStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Tap the search button to find a city."
        return label
    }()
    
    
    init(viewModel: CityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupScrollView()
        setupEmptyState()
        updateUI()
    }
    
    private func setupNavigationBar() {
        let locationButton = UIBarButtonItem(
            image: UIImage(systemName: "location.fill"),
            style: .plain,
            target: self,
            action: #selector(locationButtonTapped)
        )
        
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
        
        navigationItem.leftBarButtonItem = locationButton
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            //Anchoring to safeAreaLayout will make sure the content in scroll view is not hidden in landscape
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // Add views to stack
        stackView.addArrangedSubview(cityNameLabel)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(loadingContainer)
        stackView.addArrangedSubview(weatherContainer)
        
        setupLoadingContainer()
        setupWeatherContainer()
    }
    
    private func setupLoadingContainer() {
        loadingContainer.addSubview(activityIndicator)
        loadingContainer.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: 32),
            
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor)
        ])
    }
    
    private func setupWeatherContainer() {
        let tempIconContainer = UIView()
        tempIconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        tempIconContainer.addSubview(temperatureLabel)
        tempIconContainer.addSubview(weatherIconImageView)
        
        weatherContainer.addSubview(tempIconContainer)
        weatherContainer.addSubview(descriptionLabel)
        weatherContainer.addSubview(feelsLikeLabel)
        weatherContainer.addSubview(divider)
        weatherContainer.addSubview(detailsGridView)
        
        NSLayoutConstraint.activate([
            tempIconContainer.topAnchor.constraint(equalTo: weatherContainer.topAnchor),
            tempIconContainer.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            tempIconContainer.trailingAnchor.constraint(equalTo: weatherContainer.trailingAnchor),
            
            temperatureLabel.leadingAnchor.constraint(equalTo: tempIconContainer.leadingAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: tempIconContainer.topAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: tempIconContainer.bottomAnchor),
            
            weatherIconImageView.trailingAnchor.constraint(equalTo: tempIconContainer.trailingAnchor),
            weatherIconImageView.topAnchor.constraint(equalTo: tempIconContainer.topAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 80),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            descriptionLabel.topAnchor.constraint(equalTo: tempIconContainer.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: weatherContainer.trailingAnchor),
            
            feelsLikeLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: weatherContainer.trailingAnchor),
            
            divider.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: weatherContainer.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            detailsGridView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            detailsGridView.leadingAnchor.constraint(equalTo: weatherContainer.leadingAnchor),
            detailsGridView.trailingAnchor.constraint(equalTo: weatherContainer.trailingAnchor),
            detailsGridView.bottomAnchor.constraint(equalTo: weatherContainer.bottomAnchor)
        ])
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateTitleLabel)
        emptyStateView.addSubview(emptyStateDescriptionLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 100),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateTitleLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 32),
            emptyStateTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -32),
            
            emptyStateDescriptionLabel.topAnchor.constraint(equalTo: emptyStateTitleLabel.bottomAnchor, constant: 8),
            emptyStateDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 32),
            emptyStateDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupBindings() {
        observeViewModel()
    }
    
    private func observeViewModel() {
        withObservationTracking {
            _ = viewModel.selectedCity
            _ = viewModel.isLoading
            _ = viewModel.showAlert
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.observeViewModel()
            }
        }
    }
    
    @objc private func locationButtonTapped() {
        Task {
            await viewModel.requestPermissionAndFetchWeatherForCurrentLocation()
        }
    }
    
    @objc private func searchButtonTapped() {
        viewModel.searchTapped()
    }
    
    private func updateUI() {
        if let city = viewModel.selectedCity {
            showCityContent(city)
        } else {
            showEmptyState()
        }
        
        if viewModel.showAlert, !isShowingAlert {
            showErrorAlertIfNeeded()
        }
    }
    
    private func showEmptyState() {
        scrollView.isHidden = true
        emptyStateView.isHidden = false
    }
    
    private func showCityContent(_ city: City) {
        scrollView.isHidden = false
        emptyStateView.isHidden = true
        
        cityNameLabel.text = city.name
        locationLabel.text = city.displayName
        
        if viewModel.isLoading {
            loadingContainer.isHidden = false
            weatherContainer.isHidden = true
            activityIndicator.startAnimating()
        } else if let weather = city.weather {
            loadingContainer.isHidden = true
            weatherContainer.isHidden = false
            activityIndicator.stopAnimating()
            updateWeatherContent(weather)
        } else {
            loadingContainer.isHidden = true
            weatherContainer.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func showErrorAlertIfNeeded() {
        guard let errorMessage = viewModel.errorMessage, !isShowingAlert else {
            return
        }
        
        isShowingAlert = true
        
        let alert = UIAlertController(
            title: "Error",
            message: errorMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isShowingAlert = false
            self?.viewModel.resetError()
        })
        
        present(alert, animated: true)
    }
    
    private func updateWeatherContent(_ weather: CityWeather) {
        temperatureLabel.text = "\(Int(weather.temperature))°F"
        descriptionLabel.text = weather.description.capitalized
        feelsLikeLabel.text = "Feels like \(Int(weather.feelsLike))°F"
        
        // Load weather icon
        if let url = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png") {
            loadImage(from: url, into: weatherIconImageView)
        }
        
        // Update details grid
        updateDetailsGrid(weather)
    }
    
    private func updateDetailsGrid(_ weather: CityWeather) {
        // Clear existing views
        detailsGridView.subviews.forEach { $0.removeFromSuperview() }
        
        let details = [
            ("thermometer.low", "Min", "\(Int(weather.tempMin))°F"),
            ("thermometer.high", "Max", "\(Int(weather.tempMax))°F"),
            ("humidity", "Humidity", "\(weather.humidity)%"),
            ("gauge.with.dots.needle.33percent", "Pressure", "\(weather.pressure) hPa"),
            ("wind", "Wind", String(format: "%.1f miles/hour", weather.windSpeed)),
            ("cloud", "Clouds", "\(weather.cloudiness)%"),
            ("cloud.rain", "Rain", "\(weather.rain ?? 0) mm/h")
        ]
        
        let columns = 2
        var yOffset: CGFloat = 0
        
        for (index, detail) in details.enumerated() {
            let detailView = createWeatherDetailView(icon: detail.0, title: detail.1, value: detail.2)
            detailsGridView.addSubview(detailView)
            
            let row = index / columns
            let column = index % columns
            let spacing: CGFloat = 12
            
            if column == 0 {
                // Left column
                NSLayoutConstraint.activate([
                    detailView.leadingAnchor.constraint(equalTo: detailsGridView.leadingAnchor),
                    detailView.topAnchor.constraint(equalTo: detailsGridView.topAnchor, constant: CGFloat(row) * (60 + spacing)),
                    detailView.widthAnchor.constraint(equalTo: detailsGridView.widthAnchor, multiplier: 0.48)
                ])
            } else {
                // Right column
                NSLayoutConstraint.activate([
                    detailView.trailingAnchor.constraint(equalTo: detailsGridView.trailingAnchor),
                    detailView.topAnchor.constraint(equalTo: detailsGridView.topAnchor, constant: CGFloat(row) * (60 + spacing)),
                    detailView.widthAnchor.constraint(equalTo: detailsGridView.widthAnchor, multiplier: 0.48)
                ])
            }
            
            yOffset = CGFloat(row + 1) * (60 + spacing)
        }
        
        // Set the height constraint for detailsGridView
        NSLayoutConstraint.activate([
            detailsGridView.heightAnchor.constraint(equalToConstant: yOffset)
        ])
    }
    
    private func createWeatherDetailView(icon: String, title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.quaternaryLabel.withAlphaComponent(0.2)
        container.layer.cornerRadius = 8
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = .label
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        
        container.addSubview(iconView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8),
            
            container.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return container
    }
    
    //TODO: This should be moved to viewmodel. Also if in progress, fetch should be cancelled when fetching weather for a new city
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
