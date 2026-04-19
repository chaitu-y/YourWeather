//
//  CityView.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import SwiftUI

struct CityView: View {
    @Bindable var viewModel: CityViewModel
    
    var body: some View {
        ScrollView {
            if let city = viewModel.selectedCity {
                VStack(alignment: .leading, spacing: 16) {
                    Text(city.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(city.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 32)
                    } else if let weather = city.weather {
                        weatherContent(weather)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ContentUnavailableView(
                    "No City Selected",
                    systemImage: "magnifyingglass",
                    description: Text("Tap the search button to find a city or use your current location.")
                )
                .padding(.top, 100)
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") {
                viewModel.resetError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong. Try again later.")
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task {
                        await viewModel.requestPermissionAndFetchWeatherForCurrentLocation()
                    }
                } label: {
                    Image(systemName: "location.fill")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.searchTapped()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
    
    
    private func weatherContent(_ weather: CityWeather) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(weather.temperature))°F")
                    .font(.system(size: 64, weight: .thin))

                Spacer()

                // There are so many icons for weather and they all are very light weight png files.
                // Weather can be very unpredictable, and thus there is no guarantee that the cached icons will be of much use.
                // So we are fetching the icon eery time we update the city weather.
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png")) { image in
                    image.resizable()
                } placeholder: {
                    Color.clear
                }
                .frame(width: 80, height: 80)
            }

            Text(weather.description.capitalized)
                .font(.title3)

            Text("Feels like \(Int(weather.feelsLike))°F")
                .foregroundStyle(.secondary)

            Divider()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                weatherDetail(icon: "thermometer.low", title: "Min", value: "\(Int(weather.tempMin))°F")
                weatherDetail(icon: "thermometer.high", title: "Max", value: "\(Int(weather.tempMax))°F")
                weatherDetail(icon: "humidity", title: "Humidity", value: "\(weather.humidity)%")
                weatherDetail(icon: "gauge.with.dots.needle.33percent", title: "Pressure", value: "\(weather.pressure) hPa")
                weatherDetail(icon: "wind", title: "Wind", value: String(format: "%.1f miles/hour", weather.windSpeed))
                weatherDetail(icon: "cloud", title: "Clouds", value: "\(weather.cloudiness)%")
                weatherDetail(icon: "cloud.rain", title: "Rain", value: "\(weather.rain ?? 0) mm/h")
            }
        }
    }

    private func weatherDetail(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(8)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
