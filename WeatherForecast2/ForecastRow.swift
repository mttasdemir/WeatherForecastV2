//
//  ForecastRow.swift
//  WeatherForecast2
//
//  Created by Mustafa Taşdemir on 17.05.2022.
//

import SwiftUI

struct ForecastRow: View {
    let city: City
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(city.name).font(.largeTitle).padding(.top, 5)
                Text(city.country).font(.caption)
            }
            Spacer()
            VStack {
                Text("\(city.forecast?.temperature ?? 0)\u{00B0}").font(.system(size: 40))
                Text(city.forecast?.weatherDescriptions[0] ?? "-").font(.caption)
                    .padding(.trailing, 15)
            }
            Spacer()
            AsyncImage(url: URL(string: city.forecast?.weatherIcons[0] ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 60, height: 60, alignment: .center)
            .clipShape(Circle())
            .padding([.top, .trailing], 10)
        }
        .padding([.leading, .bottom], 10)
    }
}


struct ForecastRow_Previews: PreviewProvider {
    static var previews: some View {
        ForecastRow(city: City.sampleData)
    }
}
