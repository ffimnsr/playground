//
//  FlagImage.swift
//  GuessTheFlag
//
//  Created by Edward Fitz Abucay on 9/20/24.
//

import SwiftUI

struct FlagImage: View {
    var image: String
    var body: some View {
        Image(image)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}
